//
//  Account.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/9/21.
//

import Foundation
import CloudKit

struct AccountStrings {
    
    static let kRecord = "account"
    static let kUsername = "username"
    static let kPassword = "password"
    static let kChildren = "children"
    
}

class Account {
    
    let recordID: CKRecord.ID
    var username: String
    var password: String
    var children: [String]
    
//    var adminUser: User?
//    var coParents: [User]
//    var documents: [Document]
//    var contacts: [Contact]
//    var notes: [Note]
//
    
    
    
    
    init(recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), username: String, password: String,  children: [String] = []/*, adminUser: User? = nil, coParents: [User] = [], documents: [Document] = [], contacts: [Contact] = [], notes: [Note] = []*/) {
        self.username = username
        self.password = password
        self.children = children
//        self.adminUser = adminUser
//        self.coParents = coParents
//        self.documents = documents
//        self.contacts = contacts
//        self.notes = notes
        self.recordID = recordID
        
    }
}

extension Account {
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[AccountStrings.kUsername] as? String,
              let password = ckRecord[AccountStrings.kPassword] as? String else { return nil }
        
        var children: [String] = []
        if let result = ckRecord[AccountStrings.kChildren] as? [String] {
            children = result
        }
        
        self.init(recordID: ckRecord.recordID, username: username, password: password, children: children)
    }
}

extension CKRecord {
    convenience init(account: Account) {
        self.init(recordType: AccountStrings.kRecord, recordID: account.recordID)
        setValuesForKeys([
            AccountStrings.kUsername: account.username,
            AccountStrings.kPassword : account.password
            
        ])
        if account.children.count > 0 {
            self.setValue(account.children, forKey: AccountStrings.kChildren)
        }
    }
}
