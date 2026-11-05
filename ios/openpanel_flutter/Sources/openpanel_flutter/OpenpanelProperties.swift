import CoreFoundation
import Foundation

enum OpenpanelProperties {
    static func normalize(_ properties: [String: Any]) -> [String: Any] {
        properties.mapValues { normalizeValue($0) }
    }

    private static func normalizeValue(_ value: Any) -> Any {
        // StandardMessageCodec supplies NSNumber, and the upstream AnyCodable
        // tests Int before Bool. Unbox CFBoolean before handing it to the SDK.
        if let number = value as? NSNumber,
           CFGetTypeID(number) == CFBooleanGetTypeID() {
            return number.boolValue
        }
        if let properties = value as? [String: Any] {
            return normalize(properties)
        }
        if let values = value as? [Any] {
            return values.map { normalizeValue($0) }
        }
        return value
    }
}
