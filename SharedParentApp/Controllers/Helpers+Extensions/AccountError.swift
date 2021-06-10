//
//  AccountError.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/10/21.
//

import Foundation

enum AccountError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return "There was an error -- \(error) -- \(error.localizedDescription)."
        case .couldNotUnwrap:
            return "There was an error unwrapping the Account."
        case .unexpectedRecordsFound:
            return "There were unexpected records found on CloudKit"
        }
    }
}
