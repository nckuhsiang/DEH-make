//
//  NewVoicePOIViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/10/11.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import SwiftyJSON
import MapKit
import Alamofire

class NewVoicePOIViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate, AVAudioRecorderDelegate, UINavigationControllerDelegate {
    var db :SQLiteConnect?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()  // 設置中間 loading 圖示
    let parameters = ["username": Rights, "language": LanguageChange, "coi_name": COIname]
    var item: GroupClass!
    var itemSource : [GroupClass] = []
    var folderPath = ""                     //供後續判斷相片來源
    var isAddingPOIInfo = true              //供後續判斷為新增或修改
    var audioPathURL = ""
    var explainAudioPathURL = ""
    var nowPOIId = 0
    var PlaceMark = ""

    
    var POIitem : POIClass!
    var POISource : [POIClass] = []
    // get the table index for further use
    var indexRow:Int = -2
    
    let geoCoder = CLGeocoder()
    let subjectPickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let formatPickerView = UIPickerView()
    let groupPickerView = UIPickerView()
    let locationManager = CLLocationManager()       // 創建 locationManager
    let folder_manager = creatFolder()              //初始化
    let recoder_manager = RecordManager()           //初始化
    let explainRecording_manager = RecordManager()  //初始化
    
    let LoactioController = UIAlertController(title: NSLocalizedString("Positioning...", comment: ""), message: NSLocalizedString("Please wait a moment", comment: ""), preferredStyle: .alert)
    
    let subjectOption   = SubjectOption
    let typeOption      = TypeOption
    let formatOption    = FormatOption
    
    var groupOption = [
        NSLocalizedString("Myself", comment: "")
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var formatTextField: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    
    @IBOutlet weak var playAudioButtonView: UIButton!
    @IBOutlet weak var playNarratorButtonView: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderPath = folder_manager.createFolder()
        
        getGroupInfo()
        
        scrollView.keyboardDismissMode = .onDrag
        
        // 配置 TextField
        titleTextField.delegate = self
        titleTextField.delegate = self
        longitudeTextField.delegate = self
        latitudeTextField.delegate = self
//        subjectTextField.delegate = self
//        typeTextField.delegate = self
        formatTextField.delegate = self
        keywordTextField.delegate = self
        descriptionTextField.delegate = self
        groupTextField.delegate         = self
        
        titleTextField.returnKeyType        = .done
        longitudeTextField.returnKeyType    = .done
        latitudeTextField.returnKeyType     = .done
        keywordTextField.returnKeyType      = .done
        descriptionTextField.returnKeyType  = .done
        
//        subjectTextField.text = subjectOption[0]
//        typeTextField.text = typeOption[0]
        formatTextField.text = formatOption[0]
        groupTextField.text = groupOption[0]
        
        playAudioButtonView.isHidden = true
        playNarratorButtonView.isHidden = true
        
        // 配置 locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // 配置 PickerView
//        subjectPickerView.delegate = self
//        subjectPickerView.dataSource = self
//        subjectTextField.inputView = subjectPickerView
//        subjectPickerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//        subjectTextField.tag = 100
//        typePickerView.delegate = self
//        typePickerView.dataSource = self
//        typePickerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//        typeTextField.inputView = typePickerView
//        typeTextField.tag = 100
        formatPickerView.delegate = self
        formatPickerView.dataSource = self
        formatPickerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        formatTextField.inputView = formatPickerView
        formatTextField.tag = 100
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupPickerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        groupTextField.inputView = groupPickerView
        groupTextField.tag = 100
        
        if !isAddingPOIInfo {
            titleTextField.text = POIitem.POI_title
            longitudeTextField.text = POIitem.POI_longitude
            latitudeTextField.text = POIitem.POI_latitude
//            subjectTextField.text = POIitem.POI_subject
//            typeTextField.text = POIitem.POI_type
            formatTextField.text = POIitem.POI_format
            keywordTextField.text = POIitem.POI_keyword
            descriptionTextField.text = POIitem.POI_description
            groupTextField.text = POIitem.group_name
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
            db = SQLiteConnect(path: sqlitePath)
            
            if let mydb = db {
                //var index = 0
                let statement = mydb.fetch("POIMedia", cond: "POI_id == \(POIitem.id)", order: nil)
                print(statement)
                while sqlite3_step(statement) == SQLITE_ROW {
                    let media_set = String(cString: sqlite3_column_text(statement, 2))
                    let temp = String(cString: sqlite3_column_text(statement, 3))
                    
                    if media_set == "2" {
                        explainAudioPathURL = temp
                        playAudioButtonView.isHidden = false
                    } else if media_set == "8" {
                        audioPathURL = temp
                        playNarratorButtonView.isHidden = false
                    }
                }
                sqlite3_finalize(statement)
            }
        }
    }
    
    @IBAction func getLocationBarButton(_ sender: Any) {
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            self.present(LoactioController, animated: true, completion: nil)
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            locationManager.requestLocation()
        }
        else if (CLLocationManager.authorizationStatus() == .denied) {
            let AlertController = UIAlertController(title: NSLocalizedString("Ｗarning", comment: ""), message: NSLocalizedString("Our App need the location service.\nTo change the permissions, go to Settings> DEH Make II> Location Services ON!", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            AlertController.addAction(okAction)
            self.present(AlertController, animated: true, completion: nil)
        }
    }

    @IBAction func explainRecordingBarButton(_ sender: UIBarButtonItem) {
        if(latitudeTextField.text == "" || longitudeTextField.text == ""){
            let myAlert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Please complete the location information first", comment: ""), preferredStyle: .alert)
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        } else {
            playAudioButtonView.isHidden = false
            let timestamp = Int(NSDate().timeIntervalSince1970)
            explainAudioPathURL = folderPath + "/ExplainRecord_" + timestamp.description + ".aac"
            print("Explain Audio Time : \(timestamp)")
            print("Explain Audio Path : " + explainAudioPathURL)
            
            explainRecording_manager.beginRecord(explainAudioPathURL)//开始录音
            
            let myAlert = UIAlertController(title: NSLocalizedString("Record the voice of the attractions", comment: ""), message: NSLocalizedString("It will stop automatically after recording 150 seconds\nClick OK to finish", comment: ""), preferredStyle: .alert)
            
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.explainRecording_manager.stopRecord(self.explainAudioPathURL)//结束录音
                /// 12. 調整session狀態為Playback & setActive為false
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } catch {
                    print("Can't set audio session")
                }
                do {
                    try AVAudioSession.sharedInstance().setActive(false)
                } catch {
                    print("Can't set audio session")
                }
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func playExplainRecordingButton(_ sender: UIButton) {
        if explainAudioPathURL != ""{
            var player: AVAudioPlayer?
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: explainAudioPathURL))
                print("歌曲長度：\(player!.duration)")
                player!.play()
            } catch let err {
                print("播放失敗:\(err.localizedDescription)")
            }
            let playAlert = UIAlertController(title: NSLocalizedString("The audio is playing", comment: ""), message: NSLocalizedString("Click OK to stop playing", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                player?.stop()
                print("Stop play recode!")
            })
            
            playAlert.addAction(okAction)
            present(playAlert, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Not recorded", comment: ""), message: NSLocalizedString("Please record and listen again", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func mediaRecordingBarButton(_ sender: UIBarButtonItem) {
        if(latitudeTextField.text == "" || longitudeTextField.text == ""){
            let myAlert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Please complete the location information first", comment: ""), preferredStyle: .alert)
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        } else {
            playNarratorButtonView.isHidden = false
            let timestamp = Int(NSDate().timeIntervalSince1970)
            audioPathURL = folderPath + "/Record_" + timestamp.description + ".aac"
            print("Audio Time : \(timestamp)")
            print("Audio Path : " + audioPathURL)
            
            recoder_manager.beginRecord(audioPathURL)//开始录音
            
            let myAlert = UIAlertController(title: NSLocalizedString("Record attractions explanation", comment: ""), message: NSLocalizedString("It will stop automatically after recording 150 seconds\nClick OK to finish", comment: ""), preferredStyle: .alert)
            
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.recoder_manager.stopRecord(self.audioPathURL)//结束录音
                /// 12. 調整session狀態為Playback & setActive為false
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } catch {
                    print("Can't set audio session")
                }
                do {
                    try AVAudioSession.sharedInstance().setActive(false)
                } catch {
                    print("Can't set audio session")
                }
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func playMediaRecordingButton(_ sender: UIButton) {
        if audioPathURL != ""{
            var player: AVAudioPlayer?
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPathURL))
                print("歌曲長度：\(player!.duration)")
                player!.play()
            } catch let err {
                print("播放失敗:\(err.localizedDescription)")
            }
            let playAlert = UIAlertController(title: NSLocalizedString("The tour is playing", comment: ""), message: NSLocalizedString("Click OK to stop playing", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                player?.stop()
                print("Stop play recode!")
            })
            
            playAlert.addAction(okAction)
            present(playAlert, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Not recorded", comment: ""), message: NSLocalizedString("Please record and listen again", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func savePOIInfoBarButton(_ sender: UIBarButtonItem) {
        let title = "'" + titleTextField.text! + "'"
        let latitude = "'" + latitudeTextField.text! + "'"
        let longitude = "'" + longitudeTextField.text! + "'"
        let description = "'" + descriptionTextField.text! + "'"
        let subject = "'" + "Activation and Reconstructed" + "'"
        let type = "'" + "Natural Landscape" + "'"
        let keyword = "'" + keywordTextField.text! + "'"
        let format = "'" + formatTextField.text! + "'"
        var address = "'" + PlaceMark + "'"
        let group = "'" + groupTextField.text! + "'"
        
        var alertController = UIAlertController()
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        db = SQLiteConnect(path: sqlitePath)
        
        if title == "''" || latitude == "''" || longitude == "''" || description == "''" || subject == "''" || type == "''" || keyword == "''" || format == "''" || address == "''" || group == "''" || explainAudioPathURL == "" {
            
            if title == "''" || latitude == "''" || longitude == "''" || description == "''" || subject == "''" || type == "''" || keyword == "''" || format == "''" || group == "''" || address == "''" {
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Please fill all the fields", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            } else if explainAudioPathURL == "" {
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Have not joined the audio", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            }
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        } else if ((latitudeTextField.text! as NSString).floatValue > 90 || (latitudeTextField.text! as NSString).floatValue < -90 || (longitudeTextField.text! as NSString).floatValue > 180 || (longitudeTextField.text! as NSString).floatValue < -180) {
            print("ERROR")
            print(longitudeTextField.text!, latitudeTextField.text!)
            print((longitudeTextField.text! as NSString).floatValue, (latitudeTextField.text! as NSString).floatValue)
            alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Please fill the correct position", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })
        } else {
            UIApplication.shared.beginIgnoringInteractionEvents()
            let geoCoder = CLGeocoder()
            let currentLocation = CLLocation(
                latitude: (latitudeTextField.text! as NSString).doubleValue,
                longitude: (longitudeTextField.text! as NSString).doubleValue
            )
            
            geoCoder.reverseGeocodeLocation(
                currentLocation, completionHandler: {
                    (placemarks, error) -> Void in
                    if error != nil {
                        // 這邊可以加入一些你的 Try Error 機制
                        print("ERROR")
                        return
                    }
                    if placemarks != nil && (placemarks?.count)! > 0{
                        let placeMark = placemarks?[0].name
                        //這邊拼湊轉回來的地址
                        print(placeMark ?? "")
                        self.PlaceMark = placeMark!
                    }
            })
            
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if !self.isAddingPOIInfo {
                    alertController = UIAlertController(title: NSLocalizedString("Successfully modified", comment: ""), message: NSLocalizedString("Continue to add the next POI", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    let id = "\(self.POIitem.id)"
                    let media_type = "'Audio'"
                    address = "'" + self.PlaceMark + "'"
                    if let mydb = self.db {
                        let _ = mydb.update("POI", cond: "id = \(id)", rowInfo: [
                            "POI_title": title,
                            "POI_latitude": latitude,
                            "POI_longitude": longitude,
                            "POI_description": description,
                            "POI_subject": subject,
                            "POI_type": type,
                            "POI_keyword": keyword,
                            "POI_format": format,
                            "POI_media_type": media_type,
                            "POI_address": address,
                            "group_name": group
                            ])
                    }
                }else {
                    alertController = UIAlertController(title: NSLocalizedString("Save successfully", comment: ""), message: NSLocalizedString("Continue to add the next POI", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    let media_type = "'Audio'"
                    address = "'" + self.PlaceMark + "'"
                    if let mydb = self.db {
                        let _ = mydb.insert("POI", rowInfo:[
                            "POI_title": title,
                            "POI_latitude": latitude,
                            "POI_longitude": longitude,
                            "POI_description": description,
                            "POI_subject": subject,
                            "POI_type": type,
                            "POI_keyword": keyword,
                            "POI_format": format,
                            "POI_media_type": media_type,
                            "POI_address": address,
                            "group_name": group
                            ])
                    }
                }
                
                if let mydb = self.db {
                    let statement = mydb.fetch("POI", cond: "1 == 1", order: nil)
                    while sqlite3_step(statement) == SQLITE_ROW{
                        let id = sqlite3_column_int(statement, 0)
                        self.nowPOIId = Int(id)
                    }
                    sqlite3_finalize(statement)
                }
                
                if !self.isAddingPOIInfo {
                    if let mydb = self.db{
                        let _ = mydb.delete("POIMedia", cond: "POI_id", id: self.POIitem.id)
                    }
                    
                    if self.explainAudioPathURL != "" {
                        let url = self.explainAudioPathURL
                        if let mydb = self.db{
                            let _ = mydb.insert("POIMedia", rowInfo:[
                                "POI_id": "'\(self.POIitem.id)'",
                                "POI_media_set": "'2'",
                                "POI_media_path": "'" + url + "'",
                                ]
                            )
                        }
                    }
                    
                    if self.audioPathURL != "" {
                        let url = self.audioPathURL
                        if let mydb = self.db{
                            let _ = mydb.insert("POIMedia", rowInfo:[
                                "POI_id": "'\(self.POIitem.id)'",
                                "POI_media_set": "'8'",
                                "POI_media_path": "'" + url + "'",
                                ]
                            )
                        }
                    }
                } else {
                    if self.explainAudioPathURL != "" {
                        let url = self.explainAudioPathURL
                        if let mydb = self.db{
                            let _ = mydb.insert("POIMedia", rowInfo:[
                                "POI_id": "'\(self.nowPOIId)'",
                                "POI_media_set": "'2'",
                                "POI_media_path": "'" + url + "'",
                                ]
                            )
                        }
                    }
                    
                    if self.audioPathURL != "" {
                        let url = self.audioPathURL
                        if let mydb = self.db{
                            let _ = mydb.insert("POIMedia", rowInfo:[
                                "POI_id": "'\(self.nowPOIId)'",
                                "POI_media_set": "'8'",
                                "POI_media_path": "'" + url + "'",
                                ]
                            )
                        }
                    }
                }
                
                let delay2 = 1.0 * Double(NSEC_PER_SEC)
                let time2 = DispatchTime.now() + Double(Int64(delay2)) / Double(NSEC_PER_SEC)
                
                self.titleTextField.text = ""
                self.longitudeTextField.text = ""
                self.latitudeTextField.text = ""
//                self.subjectTextField.text = ""
//                self.typeTextField.text = ""
                self.formatTextField.text = ""
                self.keywordTextField.text = ""
                self.descriptionTextField.text = ""
                self.groupTextField.text = ""
                
                self.explainAudioPathURL = ""
                self.audioPathURL = ""
                
                DispatchQueue.main.asyncAfter(deadline: time2, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.navigationController?.popToRootViewController(animated: true)
                })
            })
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 以下鍵盤相關設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)  // 鍵盤 return 返回
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()    // 點擊鍵盤以外地方結束鍵盤
        return true
    }
    
    // 以下為 UIPIckerView 授權設定
    // UIPickerView 設定欄位數量
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerView 設定每個欄位的內容，與顏色外觀
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string = "myString"
        // 將 string 的值更新為陣列 sub/type/for 的第 row 項資料
//        if (pickerView == subjectPickerView){
//            string = subjectOption[row]
//        } else if (pickerView == typePickerView){
//            string = typeOption[row]
//        } else if (pickerView == formatPickerView){
//            string = formatOption[row]
//        } else {
//            string = groupOption[row]
//        }
        
        if (pickerView == formatPickerView){
            string = formatOption[row]
        } else {
            string = groupOption[row]
        }
        // 設定顯示外觀
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }
    
    // UIPickerView 設定欄位數量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if (pickerView == subjectPickerView){
//            return subjectOption.count
//        } else if (pickerView == typePickerView){
//            return typeOption.count
//        } else if (pickerView == formatPickerView) {
//            return formatOption.count
//        } else {
//            return groupOption.count
//        }
        
        if (pickerView == formatPickerView) {
            return formatOption.count
        } else {
            return groupOption.count
        }
    }
    
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 將 UITextField 的值更新為陣列 meals 的第 row 項資料
//        if (pickerView == subjectPickerView){
//            subjectTextField.text = subjectOption[row]
//        } else if (pickerView == typePickerView){
//            typeTextField.text = typeOption[row]
//        } else if (pickerView == formatPickerView) {
//            formatTextField.text = formatOption[row]
//        } else {
//            groupTextField.text = groupOption[row]
//        }
        
        if (pickerView == formatPickerView) {
            formatTextField.text = formatOption[row]
        } else {
            groupTextField.text = groupOption[row]
        }
    }
    
    // 以下 Loaction 設定
    // Location 取得後 print 與設定給 TextField 顯示
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations{
            print("緯度:\(location.coordinate.latitude) 經度:\(location.coordinate.longitude) 取得時間:\(location.timestamp.description)")
            longitudeTextField.text = String(format:"%f", location.coordinate.longitude)
            latitudeTextField.text = String(format:"%f", location.coordinate.latitude)
            activityIndicator.stopAnimating()
            LoactioController.dismiss(animated: true, completion: nil)
            UIApplication.shared.endIgnoringInteractionEvents()
            
            let message = NSLocalizedString("longitude", comment: "") + ": \(location.coordinate.longitude)\n" + NSLocalizedString("latitude", comment: "") + ": \(location.coordinate.latitude)"
            
            let locationAlert = UIAlertController(title: NSLocalizedString("Your location", comment: ""), message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print(self.PlaceMark)
            })
            let geoCoder = CLGeocoder()
            let currentLocation = CLLocation(
                latitude: (latitudeTextField.text! as NSString).doubleValue,
                longitude: (longitudeTextField.text! as NSString).doubleValue
            )
            
            geoCoder.reverseGeocodeLocation(
                currentLocation, completionHandler: {
                    (placemarks, error) -> Void in
                    if error != nil {
                        // 這邊可以加入一些你的 Try Error 機制
                        print("ERROR")
                        return
                    }
                    /*  name            街道地址
                     *  country         國家
                     *  province        省籍
                     *  locality        城市
                     *  sublocality     縣市、區
                     *  route           街道、路名
                     *  streetNumber    門牌號碼
                     *  postalCode      郵遞區號
                     */
                    if placemarks != nil && (placemarks?.count)! > 0{
                        let placeMark = placemarks?[0].name
                        //這邊拼湊轉回來的地址
                        print(placeMark ?? "")
                        self.PlaceMark = placeMark!
                    }
            })
            locationAlert.addAction(okAction)
            present(locationAlert, animated: true, completion: nil)
        }
    }
    
    // Location 存取權限檢查
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("使用者尚未進行權限設定")
            // Location 若尚未進行權限設定，則進行詢問
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            print("位置服務設置為[失敗]（使用者拒絕位置存取）")
            break
        case .restricted:
            print("此應用程序不能使用位置服務(用戶並未拒絕位置存取)")
            break
        case .authorizedAlways:
            print("永遠允許取得位置訊息")
            break
        case .authorizedWhenInUse:
            print("僅在啟動時才允許獲取位置信息")
            break
        }
    }
    
    // Location 取得失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置取得失敗")
    }
    
    func getGroupInfo(){
        Alamofire.request(GroupGetGroupUrl, method: .post, parameters: parameters).responseJSON{ response in
            print("Get Group Info. Request!")
            
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                let result = post["result"].array ?? []
                for i in 0..<result.count {
                    let name = result[i]["group_name"].string ?? ""
                    let role = result[i]["role"].string ?? ""
                    let id = result[i]["group_id"]
                    let info = result[i]["group_info"].string ?? ""
                    
                    self.item = GroupClass(name: name, role: role, info: info, id: String(describing: id))
                    self.itemSource.append(self.item)
                }
            }
            
            for i in self.itemSource {
                self.groupOption.append(i.name)
            }
            print(self.groupOption)
        }
    }
}
