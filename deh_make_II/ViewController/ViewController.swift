//
//  ViewController.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/10/10.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var SuperToken = ""
var COIname = ""
var Rights = ""
var Identifier = ""
var LanguageChange = "中文"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var db :SQLiteConnect?
    var item : POIClass!
    var itemSource : [POIClass] = []
    let JsonHelp = JSONhelper()
    
    @IBOutlet weak var POITableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        itemSource.removeAll(keepingCapacity: true)
        let Language = String(Locale.current.identifier.characters.split(separator: "_").first!)
        
        if (UserDefaults.standard.bool(forKey: "first")){
            print(UserDefaults.standard.bool(forKey: "first"))
            self.performSegue(withIdentifier: "firstPageShowSegue", sender: self)
            UserDefaults.standard.set(false, forKey: "first")
        } else {
            print(UserDefaults.standard.bool(forKey: "first"))
        }
        
        if Language == "zh"{
            LanguageChange = "中文"
            language = "中文"
        }else if Language == "en"{
            LanguageChange = "英文"
            language = "英文"
        }else if Language == "ja"{
            LanguageChange = "日文"
            language = "日文"
        }else{
            LanguageChange = "中文"
            language = "中文"
        }
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            let statement = mydb.fetch("POI", cond: "1 == 1", order: nil)
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let POI_title = String(cString: sqlite3_column_text(statement, 1))
                let POI_latitude = String(cString: sqlite3_column_text(statement, 2))
                let POI_longitude = String(cString: sqlite3_column_text(statement, 3))
                let POI_description = String(cString: sqlite3_column_text(statement, 4))
                let POI_subject = String(cString: sqlite3_column_text(statement, 5))
                let POI_type = String(cString: sqlite3_column_text(statement, 6))
                let POI_keyword = String(cString: sqlite3_column_text(statement, 7))
                let POI_address = String(cString: sqlite3_column_text(statement, 18))
                let POI_period = "現代台灣"
                let POI_year = 2018
                let POI_height = ""
                let POI_scope = ""
                let POI_format = String(cString: sqlite3_column_text(statement, 12))
                let POI_source = ""
                let POI_rights = ""
                let POI_open = 0
                let POI_identifier = ""
                let POI_language = LanguageChange
                let POI_media_type = String(cString: sqlite3_column_text(statement, 19))
                let group_name = String(cString: sqlite3_column_text(statement, 20))
                let POI_media_set = ""
                
                item = POIClass(id: id, POI_title: POI_title, POI_latitude: POI_latitude, POI_longitude: POI_longitude, POI_description: POI_description, POI_address: POI_address, POI_subject: POI_subject, POI_type: POI_type, POI_keyword: POI_keyword, POI_period: POI_period, POI_year: Int32(POI_year), POI_height: POI_height, POI_scope: POI_scope, POI_format: POI_format, POI_source: POI_source, POI_rights: POI_rights, POI_open: Int32(POI_open), POI_identifier: POI_identifier, POI_language: POI_language, POI_media_type: POI_media_type, group_name: group_name, POI_media_set: [POI_media_set])
                itemSource.append(item)
                print(item)
            }
            sqlite3_finalize(statement)
        }
        POITableView.reloadData()
        
        checkLogin()
    }
    
    func checkLogin(){
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        db = SQLiteConnect(path: sqlitePath)
        if let mydb = db {
            let statement = mydb.fetch("UserInfo", cond: "1 == 1", order: nil)
            while sqlite3_step(statement) == SQLITE_ROW{
                Rights = String(cString: sqlite3_column_text(statement, 1))
                Identifier = String(cString: sqlite3_column_text(statement, 3))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        POITableView.delegate = self
        POITableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        grantToken()
        // 資料庫檔案的路徑
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            // create table
            let _ = mydb.createTable("POI", columnsInfo:[
                "id integer primary key autoincrement",
                "POI_title text",//
                "POI_latitude text",//
                "POI_longitude text",//
                "POI_description text",//
                "POI_subject text",//
                "POI_type text",//
                "POI_keyword text",//
                "POI_period text",
                "POI_year integer",
                "POI_height text",
                "POI_scope integer",
                "POI_format text",//
                "POI_source text",
                "POI_rights text",
                "POI_open text",
                "POI_identifier text",
                "POI_language text",
                "POI_address text",
                "POI_media_type text",
                "group_name",
                "POI_media_set text"
                ]
            )
            
            let _ = mydb.createTable("POIMedia", columnsInfo: [
                "id integer primary key autoincrement",
                "POI_id text",
                "POI_media_set text",
                "POI_media_path text",
                ]
            )
            
            let _ = mydb.createTable("UserInfo", columnsInfo: [
                "id integer primary key autoincrement",
                "UserName text",
                "PassWord text",
                "Identifier text",
                ]
            )
            
            let _ = mydb.createTable("GroupInfo", columnsInfo: [
                "id integer primary key autoincrement",
                "GroupName text",
                "GroupRole text",
                "GroupInfo text"
                ]
            )
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let mediaType: String = itemSource[indexPath.row].POI_media_type!
        let Imagecell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        let Aduiocell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath)
        let Vediocell = tableView.dequeueReusableCell(withIdentifier: "VedioCell", for: indexPath)

        if mediaType == "Image" {
            // Configure the cell...
            Imagecell.textLabel?.text = itemSource[indexPath.row].POI_title
            Imagecell.detailTextLabel?.text = itemSource[indexPath.row].group_name
            // Imagecell.detailTextLabel?.text = NSLocalizedString("Image", comment: "")
            
            return Imagecell
        }
        else if mediaType == "Audio" {
            // Configure the cell...
            Aduiocell.textLabel?.text = itemSource[indexPath.row].POI_title
            Aduiocell.detailTextLabel?.text = itemSource[indexPath.row].group_name
            // Aduiocell.detailTextLabel?.text = NSLocalizedString("Audio", comment: "")
            
            return Aduiocell
        }
        else {
            // Configure the cell...
            Vediocell.textLabel?.text = itemSource[indexPath.row].POI_title
            Vediocell.detailTextLabel?.text = itemSource[indexPath.row].group_name
            // Vediocell.detailTextLabel?.text = NSLocalizedString("Video", comment: "")
            
            return Vediocell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "upLoadImagePOI" {
            if let indexPath = POITableView.indexPathForSelectedRow {
                let newImagePOIController = segue.destination as! NewImagePOIViewController
                newImagePOIController.POIitem = itemSource[indexPath.row]
                newImagePOIController.isAddingPOIInfo = false
            }
        } else if segue.identifier == "upLoadAudioPOI" {
            if let indexPath = POITableView.indexPathForSelectedRow {
                let newAudioPOIController = segue.destination as! NewVoicePOIViewController
                newAudioPOIController.POIitem = itemSource[indexPath.row]
                newAudioPOIController.isAddingPOIInfo = false
            }
        } else if segue.identifier == "upLoadVedioPOI" {
            if let indexPath = POITableView.indexPathForSelectedRow {
                let newVedioPOIController = segue.destination as! NewVedioPOIViewController
                newVedioPOIController.POIitem = itemSource[indexPath.row]
                newVedioPOIController.isAddingPOIInfo = false
            }
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action, indexPath) in
            // Delete the row from the data source
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
            let itemDelete = self.itemSource[indexPath.row]
            
            let id = itemDelete.id
            //let title = itemDelete.POI_title
            
            self.db = SQLiteConnect(path: sqlitePath)
            if let mydb = self.db {
                let _ = mydb.delete("POI", cond: "id", id: id)
            }
            
            self.itemSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let upload = UITableViewRowAction(style: .normal, title: NSLocalizedString("Upload", comment: "")) { (action, indexPath) in
            if Rights == "" || Identifier == "" {
                let myAlert = UIAlertController(title: NSLocalizedString("Login Error!", comment: ""), message: NSLocalizedString("Please login", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                    print("尚未登入")
                })

                myAlert.addAction(okAction)
                self.present(myAlert, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("Uploading...", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)

                var json: JSON
                do {
                    json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
                } catch _ {
                    json = JSON("")
                }
                //var json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)

                json["POI_title"] = JSON(self.itemSource[indexPath.row].POI_title)
                json["latitude"] = JSON(self.itemSource[indexPath.row].POI_latitude)
                json["longitude"] = JSON(self.itemSource[indexPath.row].POI_longitude)
                json["POI_description"] = JSON(self.itemSource[indexPath.row].POI_description)
                json["POI_address"] = JSON(self.itemSource[indexPath.row].POI_address)
                json["subject"] = JSON(self.itemSource[indexPath.row].POI_subject)
                json["type"] = JSON(self.itemSource[indexPath.row].POI_type)
                json["keyword"] = JSON(self.itemSource[indexPath.row].POI_keyword)
                json["period"] = JSON(self.itemSource[indexPath.row].POI_period)
                json["year"] = JSON(self.itemSource[indexPath.row].POI_year)
                json["height"] = 0
                json["scope"] = JSON(self.itemSource[indexPath.row].POI_scope)
                json["format"] = JSON(self.itemSource[indexPath.row].POI_format)
                json["source"] = ""
                json["rights"] = JSON(Rights)
                json["open"] = JSON(self.itemSource[indexPath.row].POI_open)
                json["identifier"] = JSON(Identifier)
                json["language"] = JSON(LanguageChange)
                json["COI_name"] = JSON(String(COIname))
                
                if self.itemSource[indexPath.row].group_name == "屬於自己" || self.itemSource[indexPath.row].group_name == "Myself" {
                    json["group_name"] = ""
                } else {
                    json["group_name"] = JSON(self.itemSource[indexPath.row].group_name)
                }

                var mediaObject : [JSON] = []
                var medaiUrl : [String] = []
                if let mydb = self.db {
                    let statement = mydb.fetch("POIMedia", cond: "1 == 1", order: nil)
                    while sqlite3_step(statement) == SQLITE_ROW{
                        
                        var mediajson: JSON
                        do {
                            mediajson = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
                        } catch _ {
                            mediajson = JSON("")
                        }
                        
                        //var mediajson = JSON(data: "{}".data(using: String.Encoding.utf8)!)
                        let id = String(cString: sqlite3_column_text(statement, 1))
                        let media_type = String(cString: sqlite3_column_text(statement, 2))
                        var url = String(cString: sqlite3_column_text(statement, 3))

                        if id == String(self.itemSource[indexPath.row].id) {
                            if media_type == "1" {
                                medaiUrl.append(url)
                                let start = url.index(url.endIndex, offsetBy: -18)
                                let end = url.index(url.endIndex, offsetBy: 0)
                                url = String(url[start..<end])
                                mediajson["media_type"] = "image"
                                mediajson["media_format"] = 1
                                mediajson["media_path"] = JSON(url)
                            } else if media_type == "2" {
                                medaiUrl.append(url)
                                let start = url.index(url.endIndex, offsetBy: -21)
                                let end = url.index(url.endIndex, offsetBy: 0)
                                url = String(url[start..<end])
                                mediajson["media_type"] = "audio"
                                mediajson["media_format"] = 2
                                mediajson["media_path"] = JSON(url)
                            } else if media_type == "4" {
                                medaiUrl.append(url)
                                let start = url.index(url.endIndex, offsetBy: -20)
                                let end = url.index(url.endIndex, offsetBy: 0)
                                url = String(url[start..<end])
                                mediajson["media_type"] = "video"
                                mediajson["media_format"] = 4
                                mediajson["media_path"] = JSON(url)
                            } else if media_type == "8" {
                                medaiUrl.append(url)
                                let start = url.index(url.endIndex, offsetBy: -21)
                                let end = url.index(url.endIndex, offsetBy: 0)
                                url = String(url[start..<end])
                                mediajson["media_type"] = "audio"
                                mediajson["media_format"] = 8
                                mediajson["media_path"] = JSON(url)
                            }
                            mediaObject.append(mediajson)
                        }
                    }
                    sqlite3_finalize(statement)
                    json["media_set"] = JSON(mediaObject)
                }

                let parameters = ["content": json.description]

                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        for i in 0 ..< json["media_set"].count{
                            if json["media_set"][i]["media_type"] == "image"{
                                print("[[[Uploading JPG]]]")
                                let fileName = String(describing: json["media_set"][i]["media_path"])
                                let UploadMedia = medaiUrl[i]
                                let UploadfileUrl = URL(fileURLWithPath: UploadMedia)

                                print("File Name: ")
                                print(fileName)
                                print("Photo NSURL : ")
                                print(UploadfileUrl)

                                multipartFormData.append(UploadfileUrl, withName: "data", fileName: fileName, mimeType: "image/jpeg")
                            } else if json["media_set"][i]["media_type"] == "audio"{
                                print("[[[Uploading ACC]]]")
                                let fileName = String(describing: json["media_set"][i]["media_path"])
                                let UploadMedia = medaiUrl[i]
                                let UploadfileUrl = URL(fileURLWithPath: UploadMedia)

                                print("File Name: ")
                                print(fileName)
                                print("Photo NSURL : ")
                                print(UploadfileUrl)

                                multipartFormData.append(UploadfileUrl, withName: "data", fileName: fileName, mimeType: "audio/aac")
                            } else if json["media_set"][i]["media_type"] == "video"{
                                print("[[[Uploading MOV]]]")
                                let fileName = String(describing: json["media_set"][i]["media_path"])
                                let UploadMedia = medaiUrl[i]
                                let UploadfileUrl = URL(fileURLWithPath: UploadMedia)

                                print("File Name: ")
                                print(fileName)
                                print("Photo NSURL : ")
                                print(UploadfileUrl)

                                multipartFormData.append(UploadfileUrl, withName: "data", fileName: fileName, mimeType: "video/MOV")
                            }
                        }

                        for (key, value) in parameters {
                            print(value)
                            multipartFormData.append(value.data(using: .utf8)!, withName: key)
                        }

                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: UploadPOIUrl, method: .post, headers: ["Authorization": "Token " + SuperToken], encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                if let value: AnyObject = response.result.value as AnyObject? {
                                    let post = JSON(value)
                                    print(post)
                                    let poiid = String(describing: post["id"])
                                    alertController.dismiss(animated: true, completion: nil)
                                    if post["message"].string == "file uploaded!" {
                                        print("上傳成功")
                                        
                                        let myAlert = UIAlertController(title: NSLocalizedString("File Uploaded", comment: ""), message: NSLocalizedString("Share to friends", comment: ""), preferredStyle: .alert)
                                        let shareAction = UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { (action: UIAlertAction) in
                                            print(poiid)
                                            self.shareAction(poiid)
                                        })
                                        let okAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action: UIAlertAction) in
                                            print("完成")
                                        })

                                        print("刪除cell")
                                        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
                                        let itemDelete = self.itemSource[indexPath.row]

                                        let id = itemDelete.id
                                        //let title = itemDelete.POI_title

                                        self.db = SQLiteConnect(path: sqlitePath)
                                        if let mydb = self.db {
                                            let _ = mydb.delete("POI", cond: "id", id: id)
                                        }

                                        myAlert.addAction(okAction)
                                        myAlert.addAction(shareAction)
                                        self.present(myAlert, animated: true, completion: nil)
                                        
                                        self.itemSource.remove(at: indexPath.row)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        
                                    } else if post["message"].string == "upload failed!" {
                                        print("上傳失敗")
                                        
                                        let myAlert = UIAlertController(title: NSLocalizedString("Upload Failed", comment: ""), message: NSLocalizedString("Please inshare your network is connected", comment: ""), preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                            print("完成")
                                        })

                                        myAlert.addAction(okAction)
                                        self.present(myAlert, animated: true, completion: nil)
                                    }
                                }
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                    }
                )
            }
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        upload.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        return [delete, upload]
    }
    
    func grantToken(){
        let SuperName = "test03"
        let SuperPassword = "0a291f120e0dc2e51ad32a9303d50cac"
        let Superparameters = ["username": SuperName, "password": SuperPassword]
        Alamofire.request("http://deh.csie.ncku.edu.tw:8080/api/v1/grant", method: .post, parameters: Superparameters)
            .responseJSON{ response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                    if response.object(forKey: "message")! as! String == "aithorization granted"{
                        SuperToken = response.object(forKey: "token")! as! String
                        print("Super Token : \(SuperToken)")
                    } else {
                        print("ERROR")
                    }
                default:
                    print("Request failed")
                    break
                }
        }
    }
    
    func shareAction(_ id: String){
        let url = POIDetailUrl
        print(id)
        let shareLink = url + id
        
        let shareInterestController = UIActivityViewController(activityItems: [shareLink], applicationActivities: nil)
        shareInterestController.accessibilityLabel = "分享"
        shareInterestController.excludedActivityTypes = [UIActivityType.mail, UIActivityType.message]
        self.present(shareInterestController, animated: true, completion: nil)
    }
}

