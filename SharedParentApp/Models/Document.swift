//
//  Documents.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/7/21.
//

import UIKit
import CloudKit

struct DocumentStrings {
    
    static let kRecord = "document"
    static let kTitle = "title"
    static let kText = "text"
    static let kPhotoAsset = "photoAsset"
    static let kaccountReference = "accountReference"
}

class Document {
    let recordID: CKRecord.ID
    let title: String
    let text: String
    var accountReference: CKRecord.Reference?
    var documentImage: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var photoData: Data?
    
    var photoAsset: CKAsset? {
        get {
            guard photoData != nil else { return nil }
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    
    init(recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), title: String, text: String, documentImage: UIImage?, accountReference: CKRecord.Reference?) {
        self.title = title
        self.text = text
        self.recordID = recordID
        self.accountReference = accountReference
    }
}

extension Document {
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[DocumentStrings.kTitle] as? String,
              let text = ckRecord[DocumentStrings.kText] as? String
        else { return nil }
        
        let accountReference = ckRecord[DocumentStrings.kaccountReference] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[DocumentStrings.kPhotoAsset] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data")
                
            }
        }
        self.init(recordID: ckRecord.recordID, title: title, text: text, documentImage: foundPhoto, accountReference: accountReference)
    }
}

extension CKRecord {
    convenience init(document: Document) {
        self.init(recordType: DocumentStrings.kRecord, recordID: document.recordID)
        setValuesForKeys([
            DocumentStrings.kTitle : document.title,
            DocumentStrings.kText : document.text
        ])
       
        if let docPhoto = document.photoAsset {
            self.setValue(docPhoto, forKey: DocumentStrings.kPhotoAsset)
            
        }
        
        if let reference = document.accountReference {
            self.setValue(reference, forKey: DocumentStrings.kaccountReference)
            
        }
    }
}
