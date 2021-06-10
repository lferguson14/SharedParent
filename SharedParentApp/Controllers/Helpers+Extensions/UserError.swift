//
//  UserError.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/8/21.
//

import Foundation

enum UserError: Error {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    case noUserFor
    case noAccount
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to find a user"
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete."
        case .noUserLoggedIn:
            return "There is currently no user logged in."
        case .noUserFor:
            return "No user was found to be associated."
        case .noAccount:
            return "No account was found."
        }
    }
}
