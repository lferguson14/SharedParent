//
//  NotesError.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/9/21.
//

import Foundation

enum NoteError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noAccount
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return "There was an error -- \(error) -- \(error.localizedDescription)."
        case .couldNotUnwrap:
            return "There was an error unwrapping the Note."
        case .unexpectedRecordsFound:
            return "There were unexpected records found on CloudKit"
        case .noAccount:
            return "No account was found."
        }
    }
}
