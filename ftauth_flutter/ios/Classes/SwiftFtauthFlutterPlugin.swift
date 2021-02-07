import Flutter
import UIKit
import FTAuth

public class SwiftFtauthFlutterPlugin: NSObject, FlutterPlugin {
    private let keystore = Keystore()
    
    // Retain a strong reference so it is not deallocated while presenting
    private var authenticationSession: WebViewLauncher
    
    override init() {
        print("Initializing \(type(of: self))")
        if #available(iOS 12.0, *) {
            authenticationSession = AuthenticationSession()
        } else {
            authenticationSession = AuthenticationSessionCompat()
        }
        super.init()
    }
    
    deinit {
        print("Deinitializing \(type(of: self))")
    }
    
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
            switch error as? Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(nil)
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            default:
                result(FlutterError(code: "UNKNOWN", message: "An unknown error occurred", details: nil))
            }
        }
    case "storageSet":
        guard let map = call.arguments as? [String: String], let key = map["key"], let value = map["value"] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        do {
            try keystore.save(key.data(using: .utf8)!, value: value.data(using: .utf8)!)
            result(nil)
        } catch {
            switch error as? Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Nil key was passed", details: nil))
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            default:
                result(FlutterError(code: "UNKNOWN", message: "An unknown error occurred", details: nil))
            }
        }
    case "storageDelete":
        guard let key = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        do {
            try keystore.delete(key.data(using: .utf8))
            result(nil)
        } catch {
            switch error as? Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(nil)
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            default:
                result(FlutterError(code: "UNKNOWN", message: "An unknown error occurred", details: nil))
            }
        }
    case "storageClear":
        do {
            try keystore.clear()
            result(nil)
        } catch {
            switch error as? Keystore.KeystoreError {
            case .access(let details):
                result(FlutterError(code: "KEYSTORE_ACCESS", message: "Could not access keystore", details: details))
            case .keyNotFound(_):
                result(nil)
            case .unknown(let details):
                result(FlutterError(code: "KEYSTORE_UNKNOWN", message: "An unknown error occurred", details: details))
            default:
                result(FlutterError(code: "UNKNOWN", message: "An unknown error occurred", details: nil))
            }
        }
    case "login":
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.authenticationSession.launchURL(call.arguments as? String) { [unowned self] (queryParams, error) in
                self.handleLoginReponse(queryParams: queryParams, error: error, result: result)
            }
        }
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    func handleLoginReponse(queryParams: [String: String]?, error: Error?, result: FlutterResult) {
        if let error = error {
            switch error as? AuthenticationError {
            case .auth(let error, let errorDescription, let errorURI):
                result(FlutterError(code: "AUTH_EXCEPTION", message: error, details: [
                    "description": errorDescription,
                    "uri": errorURI,
                ]))
            case .cancelled:
                result(FlutterError(code: "AUTH_CANCELLED", message: "The login process was cancelled", details: nil))
            case .unknown(let details):
                result(FlutterError(code: "AUTH_UNKNOWN", message: "An unknown error occurred", details: details))
            default:
                result(FlutterError(code: "AUTH_UNKNOWN", message: "An unknown error occurred", details: nil))
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
