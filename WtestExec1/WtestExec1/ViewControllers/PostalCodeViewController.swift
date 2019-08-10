//
//  ViewController.swift
//  WtestExec1
//
//  Created by Nuno Domingues on 04/08/2019.
//  Copyright © 2019 Nuno Domingues. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class PostalCodeViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            self.searchTextField.clearButtonMode = .whileEditing
        }
    }
    @IBOutlet weak var postalCodeTableview: UITableView! {
        didSet {
            self.postalCodeTableview.separatorStyle = .none
        }
    }
    
    // MARK: - Vars
    var objectsList: Results<PostalCode>?
    var isSearchActive: Bool = false
    var items: Results<PostalCode>?
    var filteredItems: Results<PostalCode>?
    let dbManager = DBManager()
    let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        dbManager.delegate = self
        
//        items = DBManager.sharedInstance.getDataFromDB()
//
//        if items?.count == 0 {
//            fetchDataToDB()
//        fetchDataToDB { (results) in
//            self.objectsList = results
//            self.postalCodeTableview.reloadData()
//        }
//        }
        
        activity.isHidden = true
        view.addSubview(activity)
        
        
        let checkRealm = try! Realm()
        if checkRealm.objects(PostalCode.self).count == 0 {
            fetchData()
        }
        else {
            objectsList = checkRealm.objects(PostalCode.self)
        }
        
        
        
        postalCodeTableview.delegate = self
        postalCodeTableview.dataSource = self
        searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for:.editingChanged)
        
//        let data = fetchData()
//        parseToRealm(withCSV: data)
        
//        let realm = try! Realm()
//
//        objectsList = realm.objects(PostalCode.self)
        
//        fetchData()
    }
    
    func fetchData() {
        
//        var receivedData: Data?
        
        DispatchQueue(label: "background").async {
            let url = Identifiers.sourceURL
            
            self.startActivity()
            print("Fetching")
            Alamofire.request(url).validate().responseData(completionHandler: { (responseData) in
                
                let result = responseData.result
                if let error = result.error {
                    print(error.localizedDescription)
                }
                
                guard let data = result.value else { return }
                
                self.parseToRealm(withCSV: data)
                
            })
        }
    }
    
    func parseToRealm(withCSV csvData: Data) {
        DispatchQueue(label: "background").async {
            autoreleasepool{
                do {
                    print("Parse")
                    
                    //                print("Parsing")
                    //Put Activity Indicator
                    let realm = try! Realm()
                    
                    let csvHandler = try CSVHandler(contentsOfData: csvData)
                    let rows = csvHandler.rows
                    
                    try realm.write {
                        var i = 0
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
                    let realm = try! Realm()
                    realm.deleteAll()
                }
                
                            }
            
            DispatchQueue.main.async {
                
                let realmx = try! Realm()
                
                self.objectsList = realmx.objects(PostalCode.self)
                
                self.stopActivity()
                self.postalCodeTableview.reloadData()
            }
            
        }
        
        
        let realm = try! Realm()
        objectsList = realm.objects(PostalCode.self)
        postalCodeTableview.reloadData()
    }
    
    func startActivity() {
        DispatchQueue.main.async {
            self.activity.isHidden = false
            self.activity.contentScaleFactor = 2
            self.activity.color = .red
            self.activity.startAnimating()
            self.activity.center = self.view.center
        }
    }
    
    func stopActivity() {
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            self.activity.hidesWhenStopped = true
        }
    }
    
    func fetchDataToDB() {

        let url = Identifiers.sourceURL
        DispatchQueue.global().async {
            print("Fetching")
            Alamofire.request(url).validate().responseData { (responseData) in
                
                let result = responseData.result
                if let error = result.error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = result.value else { return }
                
                
                print("Parsing")
                self.dbManager.parseDataToRealm(withData: data)
//                self.postalCodeTableview.reloadData()
                print("sdf")
//                self.items = DBManager.sharedInstance.getDataFromDB()
//                DispatchQueue.main.async {
                
//                completion(DBManager.sharedInstance.getDataFromDB())
//                }
                
                
                
                
            }

        }
    }
}

extension PostalCodeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(DBManager.sharedInstance.getDataFromDB().count)
        
//        return objectsList?.count ?? 0
        
        if isSearchActive {
            return filteredItems?.count ?? 0
        }
        else {
            return objectsList?.count ?? 0
        }
        
//        if isSearchActive {
//            return filteredItems?.count ?? 0
//        } else {
//            return items?.count ?? 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.cellIdentifier, for: indexPath) as UITableViewCell
//        guard let postalCodeItems = objectsList else { return cell }
        
//        let postalCodeItem = postalCodeItems[indexPath.row]
        
//        cell.textLabel?.text = "\(postalCodeItem.postalCode)-\(postalCodeItem.postalCodeExtension), \(postalCodeItem.postalCodeLocation)"
        
        let objItem = objectsList?[indexPath.row]
        let filteredItem = filteredItems?[indexPath.row]
        
        if isSearchActive {
            cell.textLabel?.text = "\(filteredItem?.postalCode ?? "")-\(filteredItem?.postalCodeExtension ?? ""), \(filteredItem?.postalCodeLocation ?? "")"
        }
        else {
            cell.textLabel?.text = "\(objItem?.postalCode ?? "")-\(objItem?.postalCodeExtension ?? ""), \(objItem?.postalCodeLocation ?? "")"
        }
        
//        let filteredItem = filteredItems?[indexPath.row]
//        let item = items?[indexPath.row]
//
//        if isSearchActive {
//            cell.textLabel?.text = "\(filteredItem?.postalCode ?? "")-\(filteredItem?.postalCodeExtension ?? ""), \(filteredItem?.postalCodeLocation ?? "")"
//        }
//        else {
//            cell.textLabel?.text = "\(item?.postalCode ?? "")-\(item?.postalCodeExtension ?? "") \(item?.postalCodeLocation ?? "")"
//        }
        
        return cell
    }
}

extension PostalCodeViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField ){
        if self.searchTextField.text != "" {
            isSearchActive = true
            self.filteredItems = dbManager.filterDB(withSearch: self.searchTextField.text ?? "")
            postalCodeTableview.reloadData()
        }
        else {
            isSearchActive = false
            postalCodeTableview.reloadData()
        }
    }
}

extension PostalCodeViewController: ParseFinishedDelegate {
    
    
    
    func populateList(with objects: Results<PostalCode>) {
        print("DELEGATEEEEEEEEeeeeee")
//        DispatchQueue.global().async {
            let realm = try! Realm()
            
            self.objectsList = realm.objects(PostalCode.self)
            
        print(self.objectsList?.count)
        
        DispatchQueue.main.async {
            self.postalCodeTableview.reloadData()
        }
        
        
        
        
//        }
        
        
        
    }
    
    
}

private extension PostalCodeViewController {
    struct Identifiers {
        static let cellIdentifier: String = "PostalCodeCell"
        static let sourceURL: URL = URL(string: "https://raw.githubusercontent.com/centraldedados/codigos_postais/master/data/codigos_postais.csv")!
    }
}
