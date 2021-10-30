//
//  Error.swift
//  FTAuth
//
//  Created by Dillon Nys on 2/13/21.
//

import Foundation
import Flutter
import FTAuth

extension FTAuthError {
    var flutterError: FlutterError {
        FlutterError(code: errorCode.rawValue, message: description, details: details)
    }
}

extension AuthenticationError {
    var flutterError: FlutterError {
        switch self {
        case .auth(let error, let errorDescription, let errorUri):
            var details = error
            if let errorDescription = errorDescription {
                details += ": \(errorDescription)"
            }
            if let errorUri = errorUri {
                details += ". Visit \(errorUri) for more information."
            }
            return FTAuthError(errorCode: .auth, details: details).flutterError
        case .cancelled:
            return FTAuthError(errorCode: .authCancelled).flutterError
        case .unknown(let details):
            return FTAuthError(errorCode: .authUnknown, details: details).flutterError
        }
    }
}

extension Keystore.KeystoreError {
    var flutterError: FlutterError {
        switch self {
        case .access(let details):
            return FTAuthError(errorCode: .keystoreAccess, details: details).flutterError
        case .keyNotFound(let key):
            return FTAuthError(errorCode: .keyNotFound, details: key).flutterError
        case .unknown(let details):
            return FTAuthError(errorCode: .keystoreUnknown, details: details).flutterError
        }
    }
}
