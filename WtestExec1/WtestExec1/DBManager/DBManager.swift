//
//  DBManager.swift
//  WtestExec1
//
//  Created by Nuno Domingues on 04/08/2019.
//  Copyright © 2019 Nuno Domingues. All rights reserved.
//

import Foundation
import RealmSwift

protocol ParseFinishedDelegate {
    func populateList(with objects: Results<PostalCode>)
}


class DBManager {

    
    var delegate: ParseFinishedDelegate?
    
    func getDataFromDB() -> Results<PostalCode> {
        let realm = try! Realm()
        let results: Results<PostalCode> = realm.objects(PostalCode.self)
        
        return results
    }
    
    //    func addDataToDB(object: PostalCode) {
    //        try! database.write {
    //            database.add(object)
    //
    //            //            print("Added New Object")
    //        }
    //    }
    
    func filterDB(withSearch search: String) -> Results<PostalCode> {
        let realm = try! Realm()
        let filtered = realm.objects(PostalCode.self).filter("postalCodeLocation CONTAINS[cd] %@ OR postalCode CONTAINS %@ OR postalCodeExtension CONTAINS %@", search, search, search)
        
        return filtered
    }
    
    func parseDataToRealm(withData data: Data) {
        
        DispatchQueue.global().async {
            do {
                //                print("Parsing")
                //Put Activity Indicator
                let realm = try! Realm()
                
                let csvHandler = try CSVHandler(contentsOfData: data)
                let rows = csvHandler.rows
                
                try realm.write {
                    var i = 1
                    for row in rows {
                        let postalCodeNumber = row["num_cod_postal"]
                        let postalCodeExtension = row["ext_cod_postal"]
                        let postalCodeLocation = row["desig_postal"]
                        
                        let postalCodeItem = PostalCode(id: i, postalCode: postalCodeNumber ?? "", postalCodeExtension: postalCodeExtension ?? "", postalCodeLocation: postalCodeLocation ?? "")
                        
                        realm.add(postalCodeItem)
                        i = i + 1
                    }
                }
                
            } catch let err {
                
                print(err)
            }
            self.delegate?.populateList(with: self.getDataFromDB())
        }
    }
    
}
