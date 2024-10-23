import Foundation
import FirebaseFirestore

enum FirestoreError: Error {
    case documentNotFound
    case permissionDenied
    case networkError
    case quotaExceeded
    case unknownError

    init(firestoreErrorCode: FirestoreErrorCode.Code?) {
        switch firestoreErrorCode {
        case .some(.notFound):
            self = .documentNotFound
        case .some(.permissionDenied):
            self = .permissionDenied
        case .some(.unavailable):
            self = .networkError
        case .some(.resourceExhausted):
            self = .quotaExceeded
        default:
            self = .unknownError
        }
    }

    var description: String {
        switch self {
        case .documentNotFound:
            return "The requested document was not found."
        case .permissionDenied:
            return "You do not have permission to access this resource."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .quotaExceeded:
            return "You have exceeded the quota for this operation."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
