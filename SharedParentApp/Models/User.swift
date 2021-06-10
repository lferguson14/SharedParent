//
//  primaryUser.swift
//  SharedParentApp
//
//  Created by Lizzie Ferguson on 6/7/21.
//

import UIKit
import CloudKit

struct UserStrings {
    
    static let kRecord = "User"
    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kAppleUser = "appleUser"
    
    //add isPrimary
    static let kaccountReference = "accountReference"
    //static let kPhotoAsset = "photoAsset"
}

class User {
   
    var firstName: String
    var lastName: String
    
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    var accountReference: CKRecord.Reference?
   // var profilePhoto: UIImage?
   
      
//    var photoData: Data?
//
//    var photoAsset: CKAsset {
//        get {
//            let tempDirectory = NSTemporaryDirectory()
//            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
//            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
//            do {
//                try photoData?.write(to: fileURL)
//            } catch {
//                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//            }
//            return CKAsset(fileURL: fileURL)
//        }
//    }
    
    init(firstName: String, lastName: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference, accountReference: CKRecord.Reference? /*,profilePhoto: UIImage? = nil*/) {
 
    self.firstName = firstName
    self.lastName = lastName
    self.recordID = recordID
    self.appleUserRef = appleUserRef
    self.accountReference = accountReference
    //self.profilePhoto = profilePhoto
    
    }
    
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let firstName = ckRecord[UserStrings.kFirstName] as? String,
              let lastName = ckRecord[UserStrings.kLastName] as? String,
              let appleUserRef = ckRecord[UserStrings.kAppleUser] as? CKRecord.Reference
              
                else { return nil }
        let accountReference = ckRecord[UserStrings.kaccountReference] as? CKRecord.Reference
//        var foundPhoto: UIImage?
//        if let photoAsset = ckRecord[UserStrings.kPhotoAsset] as? CKAsset {
//            do {
//                let data = try Data(contentsOf: photoAsset.fileURL!)
//                foundPhoto = UIImage(data: data)
//            } catch {
//                print("Could not transform asset to data")
//
//            }
//        }
        self.init(firstName: firstName, lastName: lastName, recordID: ckRecord.recordID, appleUserRef: appleUserRef, accountReference: accountReference/*, profilePhoto: foundPhoto*/)
    }
}

extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.kRecord, recordID: user.recordID)
        setValuesForKeys([
            UserStrings.kFirstName : user.firstName,
            UserStrings.kLastName : user.lastName,
            UserStrings.kAppleUser : user.appleUserRef,
            //UserStrings.kPhotoAsset : user.photoAsset
            
        ])
        if let reference = user.accountReference {
            self.setValue(reference, forKey: UserStrings.kaccountReference)
            
        }
    }
}
