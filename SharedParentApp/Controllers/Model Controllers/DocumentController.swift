//
//  DocumentsController.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/9/21.
//

import UIKit
import CloudKit

class DocumentController {
    
    static let shared = DocumentController()
    
    var documents: [Document] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    
    func createAndSave(with title: String, text: String, documentImage: UIImage?, completion: @escaping (Result<String, DocumentError>) -> Void) {
        guard let currentAccount = AccountController.shared.currentAccount else { return completion(.failure(.noAccount))}
        let accountReference = CKRecord.Reference(recordID: currentAccount.recordID, action: .deleteSelf)

        
        let newDocument = Document(title: title, text: text, documentImage: documentImage, accountReference: accountReference)
        
        let record = CKRecord(document: newDocument)
        
        publicDB.save(record) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record else {return completion(.failure(.couldNotUnwrap))}
            guard let savedDocument = Document(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            self.documents.insert(savedDocument, at: 0)
            completion(.success("Successfully created and saved a Document."))
        }
        
    }

    func fetchAllDocuments(completion: @escaping (Result<String, DocumentError>) -> Void) {
        
        let fetchAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: DocumentStrings.kRecord, predicate: fetchAllPredicate)
        
            publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            let fetchedDocuments = records.compactMap({ Document(ckRecord: $0) })
            
            self.documents = fetchedDocuments
            completion(.success("Successfully fetched Documents"))
        }
    }
    
    func updateDocuments(documents: Document, completion: @escaping (Result<Document, DocumentError>) -> Void) {
        
        let record = CKRecord(document: documents)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            guard let updateDocument = Document(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updateDocument))
            }
        publicDB.add(updateOperation)
    }
    
    func deleteDocuments(documents: Document, completion: @escaping (Result<Bool, DocumentError>) -> Void) {
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [documents.recordID])
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
    
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, DocumentError>) -> Void) {
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
    
    
    
    
    

