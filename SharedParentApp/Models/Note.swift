//
//  Notes.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/4/21.
//

import UIKit
import CloudKit

struct NoteStrings {
    
    static let kRecord = "note"
    static let kTitle = "title"
    static let kText = "text"
    static let kaccountReference = "accountReference"
}
  
class Note {
    
    let recordID: CKRecord.ID
    let title: String
    let text: String
    var accountReference: CKRecord.Reference?
 
    init(recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), title: String, text: String, accountReference: CKRecord.Reference?) {
        self.recordID = recordID
        self.title = title
        self.text = text
      
 }
}

extension Note {
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[NoteStrings.kTitle] as? String,
         let text = ckRecord[NoteStrings.kText] as? String
        
        else { return nil }
        
        let accountReference = ckRecord[NoteStrings.kaccountReference] as? CKRecord.Reference
        
        
        self.init(recordID: ckRecord.recordID, title: title, text: text, accountReference: accountReference)
    }
}

extension CKRecord {
    convenience init(note: Note) {
    self.init(recordType: NoteStrings.kRecord, recordID: note.recordID)
    setValuesForKeys([
        NoteStrings.kTitle : note.title,
        NoteStrings.kText : note.text
        
        ])
        
        if let reference = note.accountReference {
            self.setValue(reference, forKey: NoteStrings.kaccountReference)
            
        }
    }
}
