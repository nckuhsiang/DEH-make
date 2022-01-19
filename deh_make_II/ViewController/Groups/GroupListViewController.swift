//
//  GroupListViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/11/21.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GroupListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var db :SQLiteConnect?
    var item: GroupClass!
    var item2: messageClass!
    var itemSource : [GroupClass] = []
    var itemSource2 : [messageClass] = []
    let parameters = ["username": Rights, "language": LanguageChange, "coi_name": COIname]
    let messageController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Message sanding!", comment: ""), preferredStyle: .alert)
    
    @IBOutlet weak var groupListTableView: UITableView!
    @IBOutlet weak var messageButtonView: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        getGroupMessage()
        getGroupInfo()
        
        messageButtonView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupListTableView.delegate = self
        groupListTableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        itemSource = []
        itemSource2 = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    @IBAction func joinGroup(_ sender: UIBarButtonItem) {
//        //UIApplication.shared.beginIgnoringInteractionEvents()
//        let alertController = UIAlertController(title: NSLocalizedString("JOIN", comment: ""), message: NSLocalizedString("Please enter the group name for you want to join!", comment: ""), preferredStyle: .alert)
//
//        alertController.addTextField(configurationHandler: {(textField) in
//            textField.placeholder = NSLocalizedString("Group Name", comment: "")
//        })
//
//        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style:.cancel)
//        let confirm = UIAlertAction(title: NSLocalizedString("Send", comment: ""), style:.default) { (action) in
//            let group_name = (alertController.textFields?.first)! as UITextField
//            if group_name.text != "" {
//                self.memberApplyMessage(group_name.text!)
//            } else {
//                let mesage = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Please enter the group name for you want to join!", comment: ""), preferredStyle: .alert)
//                self.present(mesage, animated: true, completion: nil)
//                let delay = 1.0 * Double(NSEC_PER_SEC)
//                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: time, execute: {
//                    mesage.dismiss(animated: true, completion: nil)
//                    //UIApplication.shared.endIgnoringInteractionEvents()
//                })
//            }
//        }
//
//        alertController.addAction(cancel)
//        alertController.addAction(confirm)
//        present(alertController, animated: true, completion: nil)
//    }
    
//    func memberApplyMessage(_ groupName: String) {
//        var alertController = UIAlertController(title: nil, message: "", preferredStyle: .alert)
//        var json: JSON
//        do {
//            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
//        } catch _ {
//            json = JSON("")
//        }
//        
//        json["sender_name"] = JSON(Rights)
//        json["group_name"] = JSON(groupName)
//        let parameters = ["join_info": json.description ]
//        
//        Alamofire.request(GroupMemberJoinUrl, method: .post, parameters: parameters).responseJSON{ response in
//            if let value: AnyObject = response.result.value as AnyObject? {
//                let post = JSON(value)
//                print("Request: ")
//                let requestMes = post["message"]
//                print(requestMes)
//                switch requestMes {
//                    case "The group is not exist!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("The group is not exist!", comment: ""), preferredStyle: .alert)
//                    case "Can not send request for myself!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Can not send request for yourself!", comment: ""), preferredStyle: .alert)
//                    case "Member is in this group!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("You already in the group!", comment: ""), preferredStyle: .alert)
//                    case "Leader has invited the member!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Administrator has invited members!", comment: ""), preferredStyle: .alert)
//                    case "Member has allocated request!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("You have allocated request!", comment: ""), preferredStyle: .alert)
//                    case "Send request successfully!":
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Send request successfully!", comment: ""), preferredStyle: .alert)
//                    default:
//                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: "?????", preferredStyle: .alert)
//                }
//            }
//            self.present(alertController, animated: true, completion: nil)
//            let delay = 1.0 * Double(NSEC_PER_SEC)
//            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//            DispatchQueue.main.asyncAfter(deadline: time, execute: {
//                alertController.dismiss(animated: true, completion: nil)
//                UIApplication.shared.endIgnoringInteractionEvents()
//            })
//        }
//    }
    
    func getGroupMessage(){
        itemSource2 = []
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        
        json["username"] = JSON(Rights)
        let parameters = ["notification": json.description ]
        Alamofire.request(GroupGetNotifiUrl, method: .post, parameters: parameters).responseJSON{ response in
            print("Get Group Message. Request!")
            
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                print(post)
                if post["message"] == "have notification" {
                    self.messageButtonView.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
            }
        }
    }
    
    func getGroupInfo(){
        itemSource = []
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
            self.groupListTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemSource.count + itemSource2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        var messageCell: GroupMessageCell? = tableView.dequeueReusableCell(withIdentifier: "messageCell") as? GroupMessageCell
        
        if(messageCell == nil) {
            messageCell = GroupMessageCell(style: UITableViewCellStyle.default, reuseIdentifier: "messageCell")
        }
        
        if itemSource[indexPath.row].role == "leader" {
            groupCell.imageView?.image = #imageLiteral(resourceName: "leaderrr")
        } else {
            groupCell.imageView?.image = #imageLiteral(resourceName: "leaderlisticon")
        }
        groupCell.textLabel?.text = itemSource[indexPath.row].name
        
        if itemSource[indexPath.row].role == "leader" {
            groupCell.detailTextLabel?.text = NSLocalizedString("Leader", comment: "")
        } else {
            groupCell.detailTextLabel?.text = NSLocalizedString("Member", comment: "")
        }
        
        return groupCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewGroupInfoSegue"{
            if let indexPath = groupListTableView.indexPathForSelectedRow {
                let tabBarController = segue.destination as! UITabBarController
                let groupInfoPage = tabBarController.viewControllers![0] as! GroupInfoViewController
                let groupMemberPage = tabBarController.viewControllers![1] as! GroupMemberViewController
                
                groupInfoPage.GroupItem = itemSource[indexPath.row - itemSource2.count]
                groupMemberPage.GroupItem = itemSource[indexPath.row - itemSource2.count]
                
                groupInfoPage.isAddingGroupInfo = false
                print(groupInfoPage.GroupItem, groupInfoPage.isAddingGroupInfo)
            }
        }
    }
}
