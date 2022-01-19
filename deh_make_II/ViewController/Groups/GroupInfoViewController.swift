//
//  GroupInfoViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/11/21.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var language = "中文"

class GroupInfoViewController: UIViewController, UITextFieldDelegate {
    var GroupItem: GroupClass!
    var isAddingGroupInfo = true
    var action = "creat"
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupInfoTextField: UITextField!
    
    @IBOutlet weak var updateGroupInfoButtonView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameTextField.isUserInteractionEnabled = false
        groupInfoTextField.isUserInteractionEnabled = false
        groupNameTextField.delegate = self
        groupInfoTextField.delegate = self
        
        if !isAddingGroupInfo {
            groupNameTextField.text = GroupItem.name
            groupInfoTextField.text = GroupItem.info
            group_ID = GroupItem.id
            print(GroupItem.role)
            
            if GroupItem.role == "leader" {
                updateGroupInfoButtonView.setTitle(NSLocalizedString("Edit", comment: ""), for: UIControlState())
                action = "Edit"
            } else {
                updateGroupInfoButtonView.isHidden = true
            }
            
            
        } else {
            updateGroupInfoButtonView.setTitle(NSLocalizedString("Creat", comment: ""), for: UIControlState())
            groupNameTextField.isUserInteractionEnabled = true
            groupInfoTextField.isUserInteractionEnabled = true
            action = "Creat"
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func updateGroupInfoButtonAction(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        var alertController = UIAlertController()
        
        if action == "Creat" {
            if groupNameTextField.text == "" || groupInfoTextField.text == ""{
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Please fill all the fields", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            } else {
                var json: JSON
                do {
                    json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
                } catch _ {
                    json = JSON("")
                }
                
                json["group_name"] = JSON(groupNameTextField.text ?? "")
                json["group_leader_name"] = JSON(Rights)
                json["group_info"] = JSON(groupInfoTextField.text ?? "")
                json["language"] = JSON(LanguageChange)
                json["verification"] = JSON("0")
                json["open"] = JSON("1")
                json["coi_name"] = JSON(COIname)
                let parameters = ["group_information": json.description ]
                
                Alamofire.request(GroupCreatUrl, method: .post, parameters: parameters).responseJSON{ response in
                    print("Get Group Info. Request!")
                    
                    if let value: AnyObject = response.result.value as AnyObject? {
                        let post = JSON(value)
                        print(post)
                        group_ID = String(describing: post["group_id"])
                        print(group_ID)
                        if post["message"] == "create group successed!" {
                            alertController = UIAlertController(title: NSLocalizedString("Information", comment: ""), message: NSLocalizedString("Creat Group successed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            self.present(alertController, animated: true, completion: nil)
                            let delay = 1.0 * Double(NSEC_PER_SEC)
                            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                                UIApplication.shared.endIgnoringInteractionEvents()
                            })
                            self.groupNameTextField.isUserInteractionEnabled = false
                            self.groupInfoTextField.isUserInteractionEnabled = false
                            self.updateGroupInfoButtonView.setTitle(NSLocalizedString("Edit", comment: ""), for: UIControlState())
                            self.action = "Edit"
                        } else {
                            alertController = UIAlertController(title: NSLocalizedString("Information", comment: ""), message: NSLocalizedString("Creat Group failed", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            self.present(alertController, animated: true, completion: nil)
                            let delay = 1.0 * Double(NSEC_PER_SEC)
                            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                                UIApplication.shared.endIgnoringInteractionEvents()
                            })
                        }
                    }
                }
            }
        } else if action == "Edit" {
            groupNameTextField.isUserInteractionEnabled = true
            groupInfoTextField.isUserInteractionEnabled = true
            updateGroupInfoButtonView.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState())
            action = "Update"
            UIApplication.shared.endIgnoringInteractionEvents()
        } else {
            if groupNameTextField.text == "" || groupInfoTextField.text == ""{
                alertController = UIAlertController(title: NSLocalizedString("Information Error", comment: ""), message: NSLocalizedString("Please fill all the fields", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                self.present(alertController, animated: true, completion: nil)
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            } else {
                var json: JSON
                do {
                    json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
                } catch _ {
                    json = JSON("")
                }
                //var json = JSON(data: "{}".data(using: String.Encoding.utf8)!)
                json["group_name"] = JSON(groupNameTextField.text ?? "")
                json["group_info"] = JSON(groupInfoTextField.text ?? "")
                json["group_id"] = JSON(GroupItem.id)
                let parameters = ["group_update_info": json.description ]
                
                Alamofire.request(GroupUpdateUrl, method: .post, parameters: parameters).responseJSON{ response in
                    print("Get Group Info. Request!")
                    
                    if let value: AnyObject = response.result.value as AnyObject? {
                        let post = JSON(value)
                        if post["message"] == "update success!" {
                            alertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Save success", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            self.present(alertController, animated: true, completion: nil)
                            let delay = 1.0 * Double(NSEC_PER_SEC)
                            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                            })
                        }
                        print(post)
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
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
}
