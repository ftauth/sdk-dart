import Flutter
import UIKit
import FTAuth

public class SwiftFTAuthFlutterPlugin: NSObject, FlutterPlugin {
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
    let instance = SwiftFTAuthFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "storageInit":
        // No-op
        result(nil)
    case "storageGet":
        guard let key = call.arguments as? String else {
            result(FTAuthError(errorCode: .invalidArguments).flutterError)
            return
        }
        do {
            let data = try keystore.get(key)
            result(data)
        } catch {
            handleKeystoreError(error: error, result: result)
        }
    case "storageSet":
        guard let map = call.arguments as? [String: String],
              let key = map["key"], let value = map["value"] else {
            result(FTAuthError(errorCode: .invalidArguments).flutterError)
            return
        }
        do {
            try keystore.save(key, value: value.data(using: .utf8)!)
            result(nil)
        } catch {
            handleKeystoreError(error: error, result: result)
        }
    case "storageDelete":
        guard let key = call.arguments as? String else {
            result(FTAuthError(errorCode: .invalidArguments).flutterError)
            return
        }
        do {
            try keystore.delete(key)
            result(nil)
        } catch {
            handleKeystoreError(error: error, result: result)
        }
    case "storageClear":
        do {
            try keystore.clear()
            result(nil)
        } catch {
            handleKeystoreError(error: error, result: result)
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
    
    func handleKeystoreError(error: Error, result: FlutterResult) {
        guard let keystoreError = error as? Keystore.KeystoreError else {
            result(FTAuthError(errorCode: .unknown, details: error.localizedDescription).flutterError)
            return
        }
        result(keystoreError.flutterError)
    }
    
    func handleLoginReponse(queryParams: [String: String]?, error: Error?, result: FlutterResult) {
        if let error = error {
            guard let authError = error as? AuthenticationError else {
                result(FTAuthError(errorCode: .authUnknown, details: error.localizedDescription).flutterError)
                return
            }
            result(authError.flutterError)
        }
        
        
        guard let queryParams = queryParams else {
            result(FTAuthError(errorCode: .authUnknown).flutterError)
            return
        }
        
        result(queryParams)
    }
}
