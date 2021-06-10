//
//  UserController.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/8/21.
//

import UIKit
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    var currentUser: User?
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    

    func createUserWith(_ username: String, password: String, firstName: String, lastName: String, isPrimary: Bool, completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserReference { (result) in
            switch result {
            
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                guard let currentAccount = AccountController.shared.currentAccount else { return completion(.failure(.noAccount))}
                let accountReference = CKRecord.Reference(recordID: currentAccount.recordID, action: .deleteSelf)
                
                let newUser = User(firstName: firstName, lastName: lastName, appleUserRef: reference, accountReference: accountReference)
                let record = CKRecord(user: newUser)
                self.publicDB.save(record) { (record, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = record,
                          let savedUser = User(ckRecord: record)
                    else { return completion(.failure(.couldNotUnwrap)) }
                    
                    print("Create User: \(record.recordID.recordName) successfully")
                    completion(.success(savedUser))
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }


    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn)) }
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.kAppleUser, reference])
                let query = CKQuery(recordType: UserStrings.kRecord, predicate: predicate)
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = records?.first,
                        let foundUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap)) }
                    
                    print("Fetched User: \(record.recordID.recordName) successfully")
                    completion(.success(foundUser))
                }
            case.failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {
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
    
    func updateUser(user: User, completion: @escaping (Result<User, UserError>) -> Void) {
        
        let record = CKRecord(user: user)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            guard let updateUser = User(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updateUser))
            }
        publicDB.add(updateOperation)
        

    }
    
    func deleteUser(user: User, completion: @escaping (Result<Bool, UserError>) -> Void) {
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [user.recordID])
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
