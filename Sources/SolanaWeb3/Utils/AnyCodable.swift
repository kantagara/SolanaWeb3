import Foundation

/// Minimal in-module replacement for the external `AnyCodable` dependency.
///
/// We use this to move arbitrary JSON payloads across the WebView bridge without depending on
/// third-party packages. This type is intentionally JSON-only:
/// - null, bool, number, string, array, object
public struct AnyCodable: Codable, Equatable {
  fileprivate let json: JSONValue

  /// Underlying Foundation representation (`NSNull`, `Bool`, `Int`/`Double`, `String`,
  /// `[Any]`, `[String: Any]`).
  public var value: Any { json.foundationValue }

  public init(_ value: Any?) {
    self.json = JSONValue(value)
  }

  public init(from decoder: Decoder) throws {
    self.json = try JSONValue(from: decoder)
  }

  public func encode(to encoder: Encoder) throws {
    try json.encode(to: encoder)
  }
}

/// JSON-only value tree (Codable + Equatable).
fileprivate enum JSONValue: Equatable {
  case null
  case bool(Bool)
  case int(Int)
  case double(Double)
  case string(String)
  case array([JSONValue])
  case object([String: JSONValue])

  init(_ any: Any?) {
    guard let any else {
      self = .null
      return
    }

    if let wrapped = any as? AnyCodable {
      self = wrapped.json
      return
    }

    switch any {
    case is NSNull:
      self = .null
    case let b as Bool:
      self = .bool(b)
    case let i as Int:
      self = .int(i)
    case let i as Int64:
      self = .int(Int(i))
    case let i as UInt:
      self = .int(Int(i))
    case let d as Double:
      self = .double(d)
    case let f as Float:
      self = .double(Double(f))
    case let n as NSNumber:
      // Best-effort: preserve integers when possible.
      if CFNumberIsFloatType(n) {
        self = .double(n.doubleValue)
      } else {
        self = .int(n.intValue)
      }
    case let s as String:
      self = .string(s)
    case let arr as [Any]:
      self = .array(arr.map { JSONValue($0) })
    case let arr as [AnyCodable]:
      self = .array(arr.map { $0.json })
    case let dict as [String: Any]:
      var out: [String: JSONValue] = [:]
      out.reserveCapacity(dict.count)
      for (k, v) in dict {
        out[k] = JSONValue(v)
      }
      self = .object(out)
    case let dict as [String: AnyCodable]:
      var out: [String: JSONValue] = [:]
      out.reserveCapacity(dict.count)
      for (k, v) in dict {
        out[k] = v.json
      }
      self = .object(out)
    default:
      // Last resort: try to JSON-encode Encodable objects via JSONSerialization roundtrip.
      // If that fails, stringify to avoid crashing.
      if let data = try? JSONSerialization.data(withJSONObject: any, options: []),
         let obj = try? JSONSerialization.jsonObject(with: data, options: []) {
        self = JSONValue(obj)
      } else {
        self = .string(String(describing: any))
      }
    }
  }

  var foundationValue: Any {
    switch self {
    case .null:
      return NSNull()
    case .bool(let b):
      return b
    case .int(let i):
      return i
    case .double(let d):
      return d
    case .string(let s):
      return s
    case .array(let a):
      return a.map { $0.foundationValue }
    case .object(let o):
      var out: [String: Any] = [:]
      out.reserveCapacity(o.count)
      for (k, v) in o {
        out[k] = v.foundationValue
      }
      return out
    }
  }
}

extension JSONValue: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = .null
      return
    }

    if let b = try? container.decode(Bool.self) {
      self = .bool(b)
      return
    }

    // Try Int before Double to preserve integer-ness when possible.
    if let i = try? container.decode(Int.self) {
      self = .int(i)
      return
    }

    if let d = try? container.decode(Double.self) {
      self = .double(d)
      return
    }

    if let s = try? container.decode(String.self) {
      self = .string(s)
      return
    }

    if let a = try? container.decode([JSONValue].self) {
      self = .array(a)
      return
    }

    if let o = try? container.decode([String: JSONValue].self) {
      self = .object(o)
      return
    }

    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null:
      try container.encodeNil()
    case .bool(let b):
      try container.encode(b)
    case .int(let i):
      try container.encode(i)
    case .double(let d):
      try container.encode(d)
    case .string(let s):
      try container.encode(s)
    case .array(let a):
      try container.encode(a)
    case .object(let o):
      try container.encode(o)
    }
  }
}


