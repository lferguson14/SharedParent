//
//  Contacts.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/8/21.
//

import Foundation
import CloudKit

struct ContactStrings {
    
    static let kRecord = "contact"
    static let kName = "name"
    static let kPhoneNumber = "phoneNumber"
    static let kaccountReference = "accountReference"
}

class Contact {
    
    let recordID: CKRecord.ID
    var name: String
    var phoneNumber: String
    var accountReference: CKRecord.Reference?
    
    init(recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), name: String, phoneNumber: String, accountReference: CKRecord.Reference?) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.recordID = recordID
        self.accountReference = accountReference
        
    }
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[ContactStrings.kName] as? String,
              let phoneNumber = ckRecord[ContactStrings.kPhoneNumber] as? String else { return nil }
        
        let accountReference = ckRecord[ContactStrings.kaccountReference] as? CKRecord.Reference
        
        
        self.init(recordID: ckRecord.recordID, name: name, phoneNumber: phoneNumber, accountReference: accountReference)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactStrings.kRecord, recordID: contact.recordID)
        setValuesForKeys([
            ContactStrings.kName : contact.name,
            ContactStrings.kPhoneNumber : contact.phoneNumber
            
        ])
        
        if let reference = contact.accountReference {
            self.setValue(reference, forKey: ContactStrings.kaccountReference)
        }
    }
}
