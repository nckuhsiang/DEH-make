//
//  NewImagePOIViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/10/11.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import AVFoundation
import MapKit
import Alamofire

class NewImagePOIViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    var item: GroupClass!
    var itemSource : [GroupClass] = []
    var db :SQLiteConnect?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var isPhotoTakenFromCamera = false      //供後續判斷相片來源
    var isAddingPOIInfo = true              //供後續判斷為新增或修改
    let parameters = ["username": Rights, "language": LanguageChange, "coi_name": COIname]
    var folderPath = ""
    var audioPathURL = ""
    var imagePathURL = ""
    var nowPOIId = 0
    
    //使用左右按鈕可以左右切換多張照片
    var photoArray : [UIImage] = []
    var photoUrl : [String] = []
    var indexOfPhoto = 0
    var PlaceMark = ""
    
    var POIitem : POIClass!
    var POISource : [POIClass] = []
    
    let geoCoder = CLGeocoder()
    let subjectPickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let formatPickerView = UIPickerView()
    let groupPickerView = UIPickerView()
    var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()    // 創建 locationManager
    let recoder_manager = RecordManager()   //初始化
    let folder_manager = creatFolder()      //初始化
    
    let LoactioController = UIAlertController(title: NSLocalizedString("Positioning...", comment: ""), message: NSLocalizedString("Please wait a moment", comment: ""), preferredStyle: .alert)

    let subjectOption   = SubjectOption
    let typeOption      = TypeOption
    let formatOption    = FormatOption
    
    var groupOption = [
        NSLocalizedString("Myself", comment: "")
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nowPhotoNumber: UILabel!
    @IBOutlet weak var totalPhotoNumber: UILabel!
    @IBOutlet weak var lineBarView: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var formatTextField: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newImageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var rightButtonView: UIButton!
    @IBOutlet weak var leftButtonView: UIButton!
    @IBOutlet weak var deleteImageButtonView: UIButton!
    @IBOutlet weak var playnarratorNuttonView: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //MARK:- 似乎沒有實際作用，已註解
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGroupInfo()
        
        folderPath = folder_manager.createFolder()
        
        scrollView.keyboardDismissMode = .onDrag

        // 配置 ImagePicker
        imagePicker.delegate            = self
        
        // 配置 TextField
        titleTextField.delegate         = self
        longitudeTextField.delegate     = self
        latitudeTextField.delegate      = self
        //subjectTextField.delegate       = self
        //typeTextField.delegate          = self
        formatTextField.delegate        = self
        keywordTextField.delegate       = self
        descriptionTextField.delegate   = self
        groupTextField.delegate         = self
        
//        subjectTextField.text = subjectOption[0]
//        typeTextField.text = typeOption[0]
        formatTextField.text = formatOption[0]
        groupTextField.text = groupOption[0]
        
        titleTextField.returnKeyType        = .done
        longitudeTextField.returnKeyType    = .done
        latitudeTextField.returnKeyType     = .done
        keywordTextField.returnKeyType      = .done
        descriptionTextField.returnKeyType  = .done
        
        // 配置 locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        
        // 配置 PickerView
//        subjectPickerView.delegate = self
//        subjectPickerView.dataSource = self
//        subjectPickerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//        subjectTextField.inputView = subjectPickerView
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
        
        deleteImageButtonView.isHidden = true
        rightButtonView.isHidden = true
        leftButtonView.isHidden = true
        lineBarView.isHidden = true
        playnarratorNuttonView.isHidden = true
        
        if !isAddingPOIInfo {
            titleTextField.text = POIitem.POI_title
            longitudeTextField.text = POIitem.POI_longitude
            latitudeTextField.text = POIitem.POI_latitude
            //subjectTextField.text = "Activation and Reconstructed"
            //typeTextField.text = "Natural Landscape"
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
                    let temp = "." + String(cString: sqlite3_column_text(statement, 3))
                    print(temp,"......")
                    if media_set == "1" {
                        photoUrl.append(temp)
                        let imageFromPath = UIImage(contentsOfFile: temp) ?? UIImage()
                        photoArray.append(imageFromPath)
                    } else if media_set == "8" {
                        audioPathURL = temp
                    }
                }
                sqlite3_finalize(statement)
            }
            
            indexOfPhoto = photoArray.count - 1
            imageView.image = photoArray[0]
            lineBarView.isHidden = false
            deleteImageButtonView.isHidden = false
            nowPhotoNumber.text = "1"
            totalPhotoNumber.text = "\(indexOfPhoto + 1)"
            
            if photoArray.count >= 2 {
                leftButtonView.isHidden = false
                rightButtonView.isHidden = false
            }
        }
        
        if audioPathURL != "" {
            playnarratorNuttonView.isHidden = false
        }
        
    }
    
    @IBAction func getLocationBarButton(_ sender: UIBarButtonItem) {
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            self.present(LoactioController, animated: true, completion: nil)
        
            UIApplication.shared.beginIgnoringInteractionEvents()
            locationManager.requestLocation()
            
        } else if (CLLocationManager.authorizationStatus() == .denied) {
            let AlertController = UIAlertController(title: NSLocalizedString("Ｗarning", comment: ""), message: NSLocalizedString("Our App need the location service.\nTo change the permissions, go to Settings> DEH Make II> Location Services ON!", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            AlertController.addAction(okAction)
            
            self.present(AlertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func loadImageButton(_ sender: UIBarButtonItem) {
        if(latitudeTextField.text == "" || longitudeTextField.text == ""){
            let myAlert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Please complete the location information first", comment: ""), preferredStyle: .alert)
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        }
        
        if(photoArray.count == 5){
            let myAlert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Reached the maximum number of pictures", comment: ""), preferredStyle: .alert)
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(
            title: NSLocalizedString("Image source", comment: ""),
            message: NSLocalizedString("Please select the access method", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let uploadTextFileAction = UIAlertAction(
            title: NSLocalizedString("Camera", comment: ""),
            style: UIAlertActionStyle.default) { (action) -> Void in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .camera
                self.isPhotoTakenFromCamera = true //相片來源是通過相機
                self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let uploadImageFileAction = UIAlertAction(
            title: NSLocalizedString("Album", comment: ""),
            style: UIAlertActionStyle.default) { (action) -> Void in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .photoLibrary
                self.isPhotoTakenFromCamera = false
                self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        
        alertController.addAction(uploadTextFileAction)
        alertController.addAction(uploadImageFileAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion:  nil)
    }
    
    @IBAction func startRecodeBarBotton(_ sender: UIBarButtonItem) {
        if(latitudeTextField.text == "" || longitudeTextField.text == ""){
            let myAlert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Please complete the location information first", comment: ""), preferredStyle: .alert)
            /// 14. 產生OK Button
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                print("back")
            })
            
            myAlert.addAction(okAction)
            present(myAlert, animated: true, completion: nil)
        } else {
            playnarratorNuttonView.isHidden = false
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
            
            /// 16. 把ok按鈕加到警告控制器
            myAlert.addAction(okAction)
            
            /// 17. 顯示警告控制器
            present(myAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func savePOIInfoBarBotton(_ sender: UIBarButtonItem) {
        let title = "'" + titleTextField.text! + "'"
        let latitude = "'" + latitudeTextField.text! + "'"
        let longitude = "'" + longitudeTextField.text! + "'"
        let description = "'" + descriptionTextField.text! + "'"
        let subject = "'" + "Activation and Reconstructed" + "'"
        let type = "'" + "Natural Landscape" + "'"
        let keyword = "'" + keywordTextField.text! + "'"
        let format = "'" + formatTextField.text! + "'"
        let address = "'" + PlaceMark + "'"
        let group = "'" + groupTextField.text! + "'"
        
        var alertController = UIAlertController()
        
        if title == "''" || latitude == "''" || longitude == "''" || description == "''" || subject == "''" || type == "''" || keyword == "''" || format == "''" || address == "''" || group == "''" || photoArray.count == 0 {
            
            if title == "''" || latitude == "''" || longitude == "''" || description == "''" || subject == "''" || type == "''" || keyword == "''" || format == "''" || group == "''" || address == "''" {
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Please fill all the fields", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            } else if photoArray.count == 0{
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Have not joined the picture", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            }
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
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
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
            db = SQLiteConnect(path: sqlitePath)
            
            if !isAddingPOIInfo {
                alertController = UIAlertController(title: NSLocalizedString("Successfully modified", comment: ""), message: NSLocalizedString("Continue to add the next POI", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)
                
                let id = "\(POIitem.id)"
                let media_type = "'Image'"
                
                if let mydb = db {
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
                
                let media_type = "'Image'"
                
                if let mydb = db {
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
            
            if let mydb = db {
                let statement = mydb.fetch("POI", cond: "1 == 1", order: nil)
                while sqlite3_step(statement) == SQLITE_ROW{
                    let id = sqlite3_column_int(statement, 0)
                    nowPOIId = Int(id)
                }
                sqlite3_finalize(statement)
            }
            
            if !isAddingPOIInfo {
                let index = photoArray.count
                
                if let mydb = db{
                    let _ = mydb.delete("POIMedia", cond: "POI_id", id: POIitem.id)
                }
                
                for i in 0..<index {
                    let url = photoUrl[i]
                    if let mydb = db{
                        let _ = mydb.insert("POIMedia", rowInfo:[
                            "POI_id": "'\(POIitem.id)'",
                            "POI_media_set": "'1'",
                            "POI_media_path": "'" + url + "'",
                            ]
                        )
                    }
                }
                
                if audioPathURL != "" {
                    let url = audioPathURL
                    if let mydb = db{
                        let _ = mydb.insert("POIMedia", rowInfo:[
                            "POI_id": "'\(POIitem.id)'",
                            "POI_media_set": "'8'",
                            "POI_media_path": "'" + url + "'",
                            ]
                        )
                    }
                }
            } else {
                let index = photoArray.count
                for i in 0..<index {
                    let url = photoUrl[i]
                    if let mydb = db{
                        let _ = mydb.insert("POIMedia", rowInfo:[
                            "POI_id": "'\(nowPOIId)'",
                            "POI_media_set": "'1'",
                            "POI_media_path": "'" + url + "'",
                            ]
                        )
                    }
                }
                if audioPathURL != "" {
                    let url = audioPathURL
                    if let mydb = db{
                        let _ = mydb.insert("POIMedia", rowInfo:[
                            "POI_id": "'\(nowPOIId)'",
                            "POI_media_set": "'8'",
                            "POI_media_path": "'" + url + "'",
                            ]
                        )
                    }
                }
            }
            
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            titleTextField.text = ""
            longitudeTextField.text = ""
            latitudeTextField.text = ""
            //subjectTextField.text = "Activation and Reconstructed"
            //typeTextField.text = "Natural Landscape"
            formatTextField.text = ""
            keywordTextField.text = ""
            descriptionTextField.text = ""
            groupTextField.text = ""
            
            audioPathURL = ""
            imagePathURL = ""
            
            photoArray = []
            photoUrl = []
            indexOfPhoto = 0
            PlaceMark = ""
            
            imageView.isHidden = true
            rightButtonView.isHidden = true
            leftButtonView.isHidden = true
            nowPhotoNumber.isHidden = true
            totalPhotoNumber.isHidden = true
            lineBarView.isHidden = true
            deleteImageButtonView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
                UIApplication.shared.endIgnoringInteractionEvents()
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    @IBAction func playRecodeButton(_ sender: UIButton) {
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

    @IBAction func deleteImageButton(_ sender: UIButton) {
        if !photoArray.isEmpty {
            if(photoArray.count > 1){
                print(indexOfPhoto)
                photoArray.remove(at: indexOfPhoto)
                photoUrl.remove(at: indexOfPhoto)
                indexOfPhoto = 0
                
                let alertController = UIAlertController(title: NSLocalizedString("Delet success!", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                })
                
                imageView.image = photoArray[0]
                nowPhotoNumber.text = "1"
                totalPhotoNumber.text = "\(photoArray.count)"
            } else {
                photoArray.remove(at: 0)
                photoUrl.remove(at: 0)
                indexOfPhoto = 0
                
                let alertController = UIAlertController(title: NSLocalizedString("Delet success!", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                })
                
                imageView.isHidden = true
                rightButtonView.isHidden = true
                leftButtonView.isHidden = true
                nowPhotoNumber.isHidden = true
                totalPhotoNumber.isHidden = true
                lineBarView.isHidden = true
                deleteImageButtonView.isHidden = true
                
            }
        }
        
        if(photoArray.count < 2){
            leftButtonView.isHidden = true
            rightButtonView.isHidden = true
        }
    }
    
    @IBAction func leftButton(_ sender: UIButton) {
        print(indexOfPhoto)
        if indexOfPhoto <= 0 {
            print("已是第一張")
            indexOfPhoto = 0
        }else{
            indexOfPhoto = indexOfPhoto - 1
        }
        nowPhotoNumber.text = "\(indexOfPhoto + 1)"
        imageView.image = photoArray[indexOfPhoto]
    }
    
    @IBAction func rightButton(_ sender: UIButton) {
        if indexOfPhoto >= photoArray.count - 1{
            print("已是最後一張")
            indexOfPhoto = photoArray.count - 1
        }else{
            indexOfPhoto = indexOfPhoto + 1
        }
        nowPhotoNumber.text = "\(indexOfPhoto + 1)"
        imageView.image = photoArray[indexOfPhoto]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 以下鍵盤相關設定
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()    // 鍵盤 return 返回
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
    
    // imagePickerController 圖片設定
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[ UIImagePickerControllerOriginalImage ] as? UIImage
        imageView.image = image
        imageView.isHidden = false

        picker.allowsEditing = true
        
        //store image into DEH-Image folder
        let imageToSave : NSData = UIImageJPEGRepresentation(image!, 0.8)! as NSData
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let imagePathURL = folderPath + "/IMG_" + timestamp.description + ".jpg"
        print("Image Time : \(timestamp)")
        print("Image Path : " + imagePathURL)
        imageToSave.write(toFile: imagePathURL, atomically: true)
        dismiss(animated: true, completion: nil)
        
        //get the url of image
        photoUrl.append(imagePathURL)
        photoArray.append(image!) //always allow to append
        print(imagePathURL)
        print(image!)
        indexOfPhoto = photoArray.count - 1 //refresh the index of photo
        
        lineBarView.isHidden = false
        deleteImageButtonView.isHidden = false
        nowPhotoNumber.isHidden = false
        totalPhotoNumber.isHidden = false
        nowPhotoNumber.text = "\(indexOfPhoto + 1)"
        totalPhotoNumber.text = "\(indexOfPhoto + 1)"
        
        //print(photoArray.count)
        if photoArray.count >= 2 {
            leftButtonView.isHidden = false
            rightButtonView.isHidden = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
