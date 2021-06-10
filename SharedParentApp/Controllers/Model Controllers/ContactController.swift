//
//  ContactsController.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/9/21.
//

import CloudKit


class ContactController {
    
    static let shared = ContactController()
    
    var contacts:  [Contact] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    

    func createAndSave(with name: String, phoneNumber: String, completion: @escaping (Result<String, ContactError>) -> Void) {
        guard let currentAccount = AccountController.shared.currentAccount else { return completion(.failure(.noAccount))}
        let accountReference = CKRecord.Reference(recordID: currentAccount.recordID, action: .deleteSelf)
        let newContact = Contact(name: name, phoneNumber: phoneNumber, accountReference: accountReference)
        
        let record = CKRecord(contact: newContact)
        
        publicDB.save(record) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record else {return completion(.failure(.couldNotUnwrap))}
            guard let savedContact = Contact(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            self.contacts.insert(savedContact, at: 0)
            completion(.success("Successfully created and saved a Contacts."))
        }
        
    }


    func fetchAllContacts(completion: @escaping (Result<String, ContactError>) -> Void) {
        
        let fetchAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: ContactStrings.kRecord, predicate: fetchAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            let fetchedContact = records.compactMap({ Contact(ckRecord: $0) })
           
            self.contacts = fetchedContact
            
            completion(.success("Successfully fetched Contacts"))
        }
        
    }



func updateContact(contact: Contact, completion: @escaping (Result<Contact, ContactError>) -> Void) {
    
    let record = CKRecord(contact: contact)
    
    let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
    updateOperation.savePolicy = .changedKeys
    updateOperation.qualityOfService = .userInteractive
    updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
        if let error = error {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            return completion(.failure(.ckError(error)))
        }
        
        guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
        guard let updateContact = Contact(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
        
        completion(.success(updateContact))
        }
    publicDB.add(updateOperation)
    

}

func deleteContact(contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
    
    let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
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
    
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, ContactError>) -> Void) {
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

