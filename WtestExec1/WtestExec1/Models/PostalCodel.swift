//
//  PostalCodel.swift
//  WtestExec1
//
//  Created by Nuno Domingues on 04/08/2019.
//  Copyright © 2019 Nuno Domingues. All rights reserved.
//

import Foundation
import RealmSwift

class PostalCode: Object {
    @objc dynamic var ID = -1
    @objc dynamic var postalCode: String = ""
    @objc dynamic var postalCodeExtension: String = ""
    @objc dynamic var postalCodeLocation: String = ""
    
    @objc open override class func primaryKey() -> String? { return "ID" }
    
    convenience init(id: Int, postalCode: String, postalCodeExtension: String, postalCodeLocation: String) {
        self.init()
        self.ID = id
        self.postalCode = postalCode
        self.postalCodeExtension = postalCodeExtension
        self.postalCodeLocation = postalCodeLocation
    }
    
//    init(withId id: Int, withPostalCodeNumber postalCode: String?, withExtension postalCodeExtension: String?, onLocation location: String?) {
//        self.ID = id
//        self.postalCode = postalCode ?? ""
//        self.postalCodeExtension = postalCodeExtension ?? ""
//        self.postalCodeLocation = location ?? ""
//    }
}
