import Flutter
import UIKit
import OpenPanel

public class OpenpanelFlutterPlugin: NSObject, FlutterPlugin {
    private var isCollectionEnabled = false

    private var defaultProperties: [String: Any] {
        let device = UIDevice.current
        var properties: [String: Any] = [
            "platform": "ios",
            "brand": "Apple",
            "model": device.model,
            "osVersion": device.systemVersion
        ]
        properties["appVersion"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        properties["buildNumber"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return properties
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.openpanel/openpanel_flutter", binaryMessenger: registrar.messenger())
        let instance = OpenpanelFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "setCollectionEnabled":
            handleSetCollectionEnabled(call, result: result)
        case "track":
            handleTrack(call, result: result)
        case "identify":
            handleIdentify(call, result: result)
        case "increment":
            handleIncrement(call, result: result)
        case "decrement":
            handleDecrement(call, result: result)
        case "alias":
            handleAlias(call, result: result)
        case "setGlobalProperties":
            handleSetGlobalProperties(call, result: result)
        case "setProfileId":
            handleSetProfileId(call, result: result)
        case "clear":
            OpenPanel.clear()
            OpenPanel.setGlobalProperties(defaultProperties)
            result(nil)
        case "flush":
            OpenPanel.flush()
            result(nil)
        case "ready":
            OpenPanel.ready()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "clientId is required", details: nil))
            return
        }

        let clientSecret = args["clientSecret"] as? String
        let apiUrl = args["apiUrl"] as? String
        let waitForProfile = args["waitForProfile"] as? Bool
        let disabled = args["disabled"] as? Bool
        let automaticTracking = args["automaticTracking"] as? Bool

        isCollectionEnabled = disabled != true
        let options = OpenPanel.Options(
            clientId: clientId,
            clientSecret: clientSecret,
            apiUrl: apiUrl,
            waitForProfile: waitForProfile,
            // Options is a value type in the Swift SDK. Capture the collection
            // switch so toggling it does not initialize lifecycle observers again.
            filter: { [weak self] _ in self?.isCollectionEnabled == true },
            automaticTracking: automaticTracking
        )

        OpenPanel.initialize(options: options)
        OpenPanel.setGlobalProperties(defaultProperties)
        result(nil)
    }

    private func handleSetCollectionEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "enabled is required", details: nil))
            return
        }

        isCollectionEnabled = enabled
        result(nil)
    }

    private func handleTrack(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let name = args["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "name is required", details: nil))
            return
        }

        var properties = OpenpanelProperties.normalize(args["properties"] as? [String: Any] ?? [:])
        if let profileId = args["profileId"] as? String {
            properties["profileId"] = profileId
        }

        OpenPanel.track(name: name, properties: properties)
        result(nil)
    }

    private func handleIdentify(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let profileId = args["profileId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "profileId is required", details: nil))
            return
        }

        let firstName = args["firstName"] as? String
        let lastName = args["lastName"] as? String
        let email = args["email"] as? String
        let avatar = args["avatar"] as? String
        let properties = OpenpanelProperties.normalize(args["properties"] as? [String: Any] ?? [:])

        let payload = IdentifyPayload(
            profileId: profileId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatar: avatar,
            properties: properties.mapValues { AnyCodable($0) }
        )

        OpenPanel.identify(payload: payload)
        result(nil)
    }

    private func handleIncrement(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let profileId = args["profileId"] as? String,
              let property = args["property"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "profileId and property are required", details: nil))
            return
        }

        let value = args["value"] as? Int
        OpenPanel.increment(payload: IncrementPayload(profileId: profileId, property: property, value: value))
        result(nil)
    }

    private func handleDecrement(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let profileId = args["profileId"] as? String,
              let property = args["property"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "profileId and property are required", details: nil))
            return
        }

        let value = args["value"] as? Int
        OpenPanel.decrement(payload: DecrementPayload(profileId: profileId, property: property, value: value))
        result(nil)
    }

    private func handleAlias(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let profileId = args["profileId"] as? String,
              let alias = args["alias"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "profileId and alias are required", details: nil))
            return
        }

        OpenPanel.alias(payload: AliasPayload(profileId: profileId, alias: alias))
        result(nil)
    }

    private func handleSetGlobalProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let properties = args["properties"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "properties is required", details: nil))
            return
        }

        OpenPanel.setGlobalProperties(OpenpanelProperties.normalize(properties))
        result(nil)
    }

    private func handleSetProfileId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let profileId = args["profileId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "profileId is required", details: nil))
            return
        }

        OpenPanel.identify(payload: IdentifyPayload(profileId: profileId))
        result(nil)
    }
}
