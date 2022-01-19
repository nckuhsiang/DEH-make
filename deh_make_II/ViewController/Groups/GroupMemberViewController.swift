//
//  GroupMemberViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/11/24.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

var group_ID = "-1"

class GroupMemberViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var GroupItem: GroupClass!
    var item: GrouopMemberClass!
    var itemSource : [GrouopMemberClass] = []
    
    @IBOutlet weak var inviteTextView: UILabel!
    @IBOutlet weak var addUsernameTextView: UITextField!
    @IBOutlet weak var addUserButtonView: UIButton!
    @IBOutlet weak var addUsernameTextField: UITextField!
    @IBOutlet weak var groupMemberListTable: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemSource.count)
        return itemSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupMemberCell = tableView.dequeueReusableCell(withIdentifier: "groupMemberCell", for: indexPath)
        let groupLeaderCell = tableView.dequeueReusableCell(withIdentifier: "groupLeaderCell", for: indexPath)
        
        if (itemSource[indexPath.row].identifier == "leader") {
            print("name:" + itemSource[indexPath.row].name)
            groupLeaderCell.textLabel?.text = itemSource[indexPath.row].name
            return groupLeaderCell
        } else {
            print("name:" + itemSource[indexPath.row].name)
            groupMemberCell.textLabel?.text = itemSource[indexPath.row].name
            return groupMemberCell
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        itemSource = []
        getGroupMember()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupMemberListTable.delegate = self
        groupMemberListTable.dataSource = self
        
        if GroupItem != nil {
            if GroupItem.role == "member" {
                inviteTextView.text = NSLocalizedString("Member List", comment: "")
                addUsernameTextView.isHidden = true
                addUserButtonView.isHidden = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        itemSource = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //"username": "iop181917"

    @IBAction func addMemberAction(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        //var json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        json["sender_name"] = JSON(Rights)
        json["receiver_name"] = JSON(addUsernameTextField.text ?? "")
        if GroupItem != nil {
            json["group_id"] = JSON(GroupItem.id)
        } else {
            json["group_id"] = JSON(group_ID)
        }
        json["message_type"] = JSON("Invite")
        json["coi_name"] = JSON(COIname)
        
        let parameters = ["group_message_info": json.description ]
        
        Alamofire.request(GroupInviteUrl, method: .post, parameters: parameters).responseJSON{ response in
            var alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: "", preferredStyle: .alert)
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                print("Request: ")
                print(post)
                let message = post["message"]
                switch message {
                    case "Already in group!":
                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Already in group!", comment: ""), preferredStyle: .alert)
                    case "Without this person!":
                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Without this person!", comment: ""), preferredStyle: .alert)
                    case "Already invite!":
                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Already invite!", comment: ""), preferredStyle: .alert)
                    case "Invite success!":
                        alertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Invite success!", comment: ""), preferredStyle: .alert)
                        self.addUsernameTextField.text = ""
                    default:
                        alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: "????", preferredStyle: .alert)
                }
            }
            
            self.present(alertController, animated: true, completion: nil)
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil)
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }
    
    func getGroupMember(){
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        //var json = JSON(data: "{}".data(using: String.Encoding.utf8)!)
        json["username"] = JSON(Rights)
        
        if GroupItem != nil {
            json["group_id"] = JSON(GroupItem.id)
        } else {
            json["group_id"] = JSON(group_ID)
        }
        json["coi_name"] = JSON(COIname)
        
        let parameters = ["member_info": json.description ]
        
        Alamofire.request(GroupGetMemberUrl, method: .post, parameters: parameters).responseJSON{ response in
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                let result = post["result"].array ?? []
                print(post)
                for i in 0..<result.count {
                    let member_name = result[i]["member_name"].string ?? ""
                    let member_identifier = result[i]["member_role"].string ?? ""
                    
                    self.item = GrouopMemberClass(name: member_name, identifier: member_identifier)
                    self.itemSource.append(self.item)
                }
            }
            self.groupMemberListTable.reloadData()
        }
    }
}
