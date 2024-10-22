//
//  AuthError.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/8/23.
//

import Foundation
import Foundation
import Firebase

enum AuthError: Error {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userDisabled
    case tooManyRequests
    case unknown

    init(authErrorCode: AuthErrorCode.Code) {
        switch authErrorCode {
        case .invalidEmail:
            self = .invalidEmail
        case .wrongPassword:
            self = .wrongPassword
        case .userNotFound:
            self = .userNotFound
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .weakPassword:
            self = .weakPassword
        case .networkError:
            self = .networkError
        case .userDisabled:
            self = .userDisabled
        case .tooManyRequests:
            self = .tooManyRequests
        default:
            self = .unknown
        }
    }

    var description: String {
        switch self {
        case .invalidEmail:
            return "The email address is invalid. Please try again."
        case .wrongPassword:
            return "The password you entered is incorrect. Please try again."
        case .userNotFound:
            return "No account found for this email. Please create an account."
        case .emailAlreadyInUse:
            return "The email address is already in use. Please try a different one."
        case .weakPassword:
            return "Your password is too weak. It must be at least 6 characters long."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .userDisabled:
            return "This account has been disabled."
        case .tooManyRequests:
            return "Too many requests. Please try again later."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
