//
//  AccountController.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/10/21.
//

import Foundation
import CloudKit

class AccountController {
    
    static let shared = AccountController()
    
    var currentAccount: Account?
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    
    func createAndSave(with username: String, password: String, children: [String], completion: @escaping (Result<String, AccountError>) -> Void) {
        let newAccount = Account(username: username, password: password, children: children)
        
        let record = CKRecord(account: newAccount)
        
        publicDB.save(record) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record else {return completion(.failure(.couldNotUnwrap))}
            guard let savedAccount = Account(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            self.currentAccount = savedAccount
            completion(.success("Successfully created and saved Account."))
        }
        
    }
    
    func fetchAccountWith(reference: CKRecord.Reference, completion: @escaping (Result<String, AccountError>) -> Void) {
        
        let predicate = NSPredicate(format: "recordID = %@", CKRecord.ID(recordName: reference.recordID.recordName))
        
        let query = CKQuery(recordType: AccountStrings.kRecord, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            let fetchedAccount = Account(ckRecord: record)
            
            self.currentAccount = fetchedAccount
            
            completion(.success("Successfully fetched Account"))
        }
        
    }
    
    
    func updateAccount(account: Account, completion: @escaping (Result<Account, AccountError>) -> Void) {
        
        let record = CKRecord(account: account)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            guard let updateAccount = Account(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updateAccount))
        }
        publicDB.add(updateOperation)
        
    }
    func deleteAccount(account: Account, completion: @escaping (Result<Bool, AccountError>) -> Void) {
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [account.recordID])
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
    
}


