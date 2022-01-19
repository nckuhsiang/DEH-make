//
//  UserLogingViewController.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/10/30.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import IDZSwiftCommonCrypto
import CommonCrypto
import Alamofire
import SwiftyJSON
import SafariServices

var UserHadLogin = false

class UserLogingViewController: UIViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {
    var db :SQLiteConnect?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonView: UIButton!
    @IBOutlet weak var coiiconImageView: UIImageView!
    @IBOutlet weak var coinameTextField: UILabel!
    
    @IBAction func registActionButton(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: UserRegistUrl)!)
        
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func loginActionButton(_ sender: UIButton) {
        var UserPassword = passwordTextField!.text!
        let UserName = usernameTextField!.text!
        
        UserPassword = MD5(UserPassword)!
        if UserHadLogin {
            logoutAction(UserName)
        } else {
            logCheck(userName: UserName, passWord: UserPassword, token: SuperToken)
        }
    }
    
    @IBAction func moreInfoOfDEH(_ sender: UIButton) {
        var homePageUrl : String = ""
        if COIname == "deh" {
            homePageUrl = DEHHomePageUrl
        } else if COIname == "extn" {
            homePageUrl = ExpTainanHomePageUrl
        } else {
            homePageUrl = DEHHomePageUrl
        }
        
        let svc = SFSafariViewController(url: URL(string: homePageUrl)!)
        
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func changeCOIButtonAction(_ sender: UIButton) {
        let changeCOIalert = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("If you switch the attraction, you will log out of the current account.", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                self.logoutAction(Rights)
                self.performSegue(withIdentifier: "chooseCOISegue", sender: nil)
        })
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        )
        
        changeCOIalert.addAction(cancelAction)
        changeCOIalert.addAction(okAction)
        
        if UserHadLogin {
            self.present(changeCOIalert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "chooseCOISegue", sender: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if COIname == "" {
            self.performSegue(withIdentifier: "chooseCOISegue", sender: nil)
        } else {
            if COIname == "deh" {
                coinameTextField.text = "文史脈流"
                coiiconImageView.image = UIImage(named: "deh_icon")
            } else if COIname == "extn" {
                coinameTextField.text = "踏溯台南"
                coiiconImageView.image = UIImage(named: "extn_icon")
            } else {
                coinameTextField.text = "文史脈流"
                coiiconImageView.image = UIImage(named: "deh_icon")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        if Rights != ""{
            UserHadLogin = true
            usernameTextField.text = Rights
            passwordTextField.text = "********"
            loginButtonView.setTitle(NSLocalizedString("Logout", comment: ""), for: UIControlState())
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 以下鍵盤相關設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)  // 鍵盤 return 返回
    }
    
    func logoutAction(_ UserName: String) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        self.db = SQLiteConnect(path: sqlitePath)
        if let mydb = self.db {
            let _ = mydb.delete_user("UserInfo", cond: "UserName", user: "'" + UserName + "'")
        }
        usernameTextField.text = ""
        passwordTextField.text = ""
        loginButtonView.setTitle(NSLocalizedString("Login", comment: ""), for: UIControlState())
        Rights = ""
        Identifier = ""
        UserHadLogin = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()    // 點擊鍵盤以外地方結束鍵盤
        return true
    }
    
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = string.data(using: String.Encoding.utf8) {
            d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    func logCheck(userName: String, passWord: String, token: String){
        let parameters = ["username": userName, "password": passWord, "coi_name": COIname]
        let loginHeaders = ["Authorization": "Token " + token]
        print(parameters)
        
        Alamofire.request(UserLoginUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: loginHeaders).responseJSON{ response in
            print("login check response result")
            
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                if post["username"].string == userName {
                    print("Welcome")
                    self.loginButtonView.setTitle(NSLocalizedString("Logout", comment: ""), for: UIControlState())
                    
                    Rights = post["username"].string!
                    Identifier = post["role"].string!
                    UserHadLogin = true
                    
                    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
                    
                    self.db = SQLiteConnect(path: sqlitePath)
                    
                    if let mydb = self.db{
                        let _ = mydb.insert("UserInfo", rowInfo:[
                            "UserName": "'" + userName + "'",
                            "PassWord": "'" + passWord + "'",
                            "Identifier": "'" + Identifier + "'"
                            ]
                        )
                    }
                    
                    let alertController = UIAlertController(title: NSLocalizedString("Login Success", comment: ""), message: NSLocalizedString("Welcome back", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alertController, animated: true, completion: nil)
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        alertController.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    print("Failed Login")
                    UserHadLogin = false
                    
                    let alertController = UIAlertController(title: NSLocalizedString("Login Fail", comment: ""), message: NSLocalizedString("Please enter the correct account and password", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
