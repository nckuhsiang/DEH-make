//
//  GroupMessageTableViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2018/2/7.
//  Copyright © 2018年 Ray Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GroupMessageTableViewController: UITableViewController {
    var item2: messageClass!
    var itemSource2 : [messageClass] = []
    let parameters = [
    "username": UserDefaults.standard.value(forKey: "username") as? String ?? "",
    "language": UserDefaults.standard.value(forKey: "language") as? String ?? "",
    "coi_name": UserDefaults.standard.value(forKey: "COIname") as? String ?? ""]

    
    
    @IBOutlet var groupMessageListTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        getGroupMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getGroupMessage(){
        itemSource2 = []
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        //var json = JSON(data: "{}".data(using: String.Encoding.utf8)!)
        json["username"] = JSON(parameters["username"] ?? "")
        let parameters = ["notification": json.description ]
        Alamofire.request(GroupGetNotifiUrl, method: .post, parameters: parameters).responseJSON{ response in
            print("Get Group Message. Request!")
            
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
//                print(post)
                let message = post["message"]
                if message == "have notification" {
                    let result = post["result"].array ?? []
                    for i in 0..<result.count {
                        print(result[i])
                        let group_name = result[i]["group_name"].string ?? ""
                        let sender_name = result[i]["sender_name"].string ?? ""
                        let message_type = result[i]["group_role"].string ?? ""
                        let group_id = result[i]["group_id"]
                        
                        self.item2 = messageClass(group_name: group_name, sender_name: sender_name, message_type: message_type, group_id:  String(describing: group_id))
                        self.itemSource2.append(self.item2)
                    }
                } else {
                    let Alert = UIAlertController(title: "目前沒有群組訊息", message: "", preferredStyle: .alert)
                    self.present(Alert, animated: true, completion: nil)
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        Alert.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
            self.groupMessageListTable.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemSource2.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MemberRequestCell = tableView.dequeueReusableCell(withIdentifier: "MemberRequestCell", for: indexPath)
        let LeaderRequestCell = tableView.dequeueReusableCell(withIdentifier: "LeaderRequestCell", for: indexPath)
        
        if itemSource2[indexPath.row].message_type == "MemberRequest" {
            MemberRequestCell.textLabel?.text = itemSource2[indexPath.row].sender_name + " 給您的一則申請"
            return MemberRequestCell
        } else {
            LeaderRequestCell.textLabel?.text = itemSource2[indexPath.row].sender_name + " 給您的一則邀請"
            return LeaderRequestCell
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = ""
        var locationAlert = UIAlertController(title: "" + itemSource2[indexPath.row].group_name, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        
        var okAction = UIAlertAction ( title: "OK", style: .default, handler: { (action: UIAlertAction) in })
        let rejectAction = UIAlertAction (title: "拒絕", style: .default, handler: { (action: UIAlertAction) in
            self.applyMessageRequest(indexPath, "Reject")
        })
        
        if itemSource2[indexPath.row].message_type == "MemberRequest" {
            locationAlert = UIAlertController(title: "邀請您加入" + itemSource2[indexPath.row].group_name, message: message, preferredStyle: .alert)
            okAction = UIAlertAction ( title: "同意加入", style: .default, handler: { (action: UIAlertAction) in
                self.applyMessageRequest(indexPath, "Agree")
            })
        } else {
            locationAlert = UIAlertController(title: "向您申請加入" + itemSource2[indexPath.row].group_name, message: message, preferredStyle: .alert)
            okAction = UIAlertAction ( title: "批准加入", style: .default, handler: { (action: UIAlertAction) in
                self.applyMessageRequest(indexPath, "Agree")
            })
        }
        
        locationAlert.addAction(okAction)
        locationAlert.addAction(rejectAction)
        locationAlert.addAction(cancelAction)
        present(locationAlert, animated: true, completion: nil)
    }

    func applyMessageRequest(_ ndxPath: IndexPath, _ returnAction: String){
        UIApplication.shared.beginIgnoringInteractionEvents()
        let url = GroupInviteUrl
        
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        
        json["sender_name"] = JSON(itemSource2[ndxPath.row].sender_name)
        json["receiver_name"] = JSON(parameters["username"] ?? "")
        json["group_id"] = JSON(itemSource2[ndxPath.row].group_id)
        json["message_type"] = JSON(returnAction)
        let parameters = ["group_message_info": json.description ]
        print(json)
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON{ response in
            var success = false
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                print("Request: ")
                print(post)
                let message = post["message"]
                if (message == "Group management success!" || post["message"] == "Join success!" || message == "Reject success!") {
                    success = true
                }
                if success {
                    print(ndxPath.row)
                    print(self.itemSource2.count)
                    self.itemSource2.remove(at: ndxPath.row)
                }
                self.groupMessageListTable.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
}

