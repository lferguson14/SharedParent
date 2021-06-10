//
//  Notes.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/9/21.
//

import Foundation
import CloudKit

class NoteController {
    
    static let shared = NoteController()
    
    var notes: [Note] = []
 
    let publicDB = CKContainer.default().publicCloudDatabase


func createAndSave(with title: String, text: String, completion: @escaping (Result<String, NoteError>) -> Void) {
    guard let currentAccount = AccountController.shared.currentAccount else { return completion(.failure(.noAccount))}
    let accountReference = CKRecord.Reference(recordID: currentAccount.recordID, action: .deleteSelf)
    
    let newNote = Note(title: title, text: text, accountReference: accountReference)
   
    let record = CKRecord(note: newNote)
    
    publicDB.save(record) { record, error in
        if let error = error {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            return completion(.failure(.ckError(error)))
        }
        guard let record = record else {return completion(.failure(.couldNotUnwrap))}
        guard let savedNotes = Note(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
        
        self.notes.insert(savedNotes, at: 0)
        completion(.success("Successfully created and saved a New Note."))
    }
}
    
    func fetchAllNotes(completion: @escaping (Result<String, NoteError>) -> Void) {
        
        let fetchAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: NoteStrings.kRecord, predicate: fetchAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            let fetchedNotes = records.compactMap({ Note(ckRecord: $0) })
            
            self.notes = fetchedNotes
            completion(.success("Successfully fetched Notes"))
        }
    }
    
    func updateNote(note: Note, completion: @escaping (Result<Note, NoteError>) -> Void) {
        
        let record = CKRecord(note: note)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            guard let updateNotes = Note(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updateNotes))
            }
        publicDB.add(updateOperation)
        
    }
    
    func deleteNote(note: Note, completion: @escaping (Result<Bool, NoteError>) -> Void) {
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [note.recordID])
        deleteOperation.savePolicy = .changedKeys
        deleteOperation.qualityOfService = .userInteractive
        deleteOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            return completion(.failure(.ckError(error)))
        }
        
        if records?.count == 0 {
            print("Deleted record from Cloudkit")
            completion(.success(true))
        } else {
            return completion(.failure(.unexpectedRecordsFound))
            }
        }
    publicDB.add(deleteOperation)
    }
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, NoteError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference))
            }
        }
    }
    
}
