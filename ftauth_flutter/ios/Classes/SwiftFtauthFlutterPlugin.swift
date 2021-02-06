import Flutter
import UIKit
import FTAuth

public class SwiftFtauthFlutterPlugin: NSObject, FlutterPlugin {
    private let keystore = Keystore()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ftauth_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftFtauthFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "storageInit":
        result(FlutterMethodNotImplemented)
    case "storageGet":
        guard let key = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        do {
            let data = try keystore.get(key.data(using: .utf8))
            result(data)
        } catch {
            switch error as! Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(nil)
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            }
        }
    case "storageSet":
        guard let map = call.arguments as? [String: FlutterStandardTypedData], let key = map["key"], let value = map["value"] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        do {
            try keystore.save(key.data, value: value.data)
            result(nil)
        } catch {
            switch error as! Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Nil key was passed", details: nil))
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            }
        }
    case "storageDelete":
        result(FlutterMethodNotImplemented)
    case "login":
        if #available(iOS 12.0, *) {
            AuthenticationSession().launchURL(call.arguments as? String) { (queryParams, error) in
                self.handleLoginReponse(queryParams: queryParams, error: error, result: result)
            }
        } else if #available(iOS 11.0, *) {
            AuthenticationSessionCompat().launchURL(call.arguments as? String) { (queryParams, error) in
                self.handleLoginReponse(queryParams: queryParams, error: error, result: result)
            }
        }
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    func handleLoginReponse(queryParams: [String: String]?, error: Error?, result: FlutterResult) {
        if let error = error {
            switch error as! AuthenticationError {
            case .auth(let error, let errorDescription, let errorURI):
                result(FlutterError(code: "AUTH_EXCEPTION", message: error, details: [
                    "description": errorDescription,
                    "uri": errorURI,
                ]))
            case .cancelled:
                result(FlutterError(code: "AUTH_CANCELLED", message: "The login process was cancelled", details: nil))
            case .unknown(let details):
                result(FlutterError(code: "AUTH_UNKNOWN", message: "An unknown error occurred", details: details))
            }
            return
        }
        
        guard let queryParams = queryParams else {
            result(FlutterError(code: "AUTH_UNKNOWN", message: "An unknown error occurred", details: nil))
            return
        }
        
        result(queryParams)
    }
}
