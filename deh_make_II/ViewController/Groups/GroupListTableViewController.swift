//
//  GroupListTableViewController.swift
//  deh_make_II
//
//  Created by 阮盟雄 on 2020/9/7.
//  Copyright © 2020 Ray Chen. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

// 加上Search Bar 需繼承
class GroupListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var groupListTable :UITableView!
    var groupNameList : [String] = []
    var searchController: UISearchController!
    var isShowResult : Bool = false
    var searchedGroup :[String] = []
    let parameters = [
       "username": UserDefaults.standard.value(forKey: "username") as? String ?? "",
       "language": UserDefaults.standard.value(forKey: "language") as? String ?? "",
       "coi_name": UserDefaults.standard.value(forKey: "COIname") as? String ?? ""]
      
    
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.sizeToFit()
        
        // 設定代理UISearchResultsUpdating的協議
        self.searchController.searchResultsUpdater = self as UISearchResultsUpdating
        
        // 設定代理UISearchBarDelegate的協議
        self.searchController.searchBar.delegate = self as UISearchBarDelegate
        
        // 預設為true，若是沒改為false，則在搜尋時整個TableView的背景顏色會變成灰底的
        self.searchController.obscuresBackgroundDuringPresentation = false
        
        // 將searchBar掛載到tableView上
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        //輸入時顯示Search Bar
        self.searchController.hidesNavigationBarDuringPresentation = false
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGroups()
        print(groupNameList.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchController.isActive = false
    }
    
    
    
    
    //注意當search運作時不能以tableview彈出訊息
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)
        let name = isShowResult ? searchedGroup[indexPath.row]:groupNameList[indexPath.row]
        print("選擇的是 \(name)")
        let controller = UIAlertController(title: NSLocalizedString("Join", comment: ""), message: NSLocalizedString("Join", comment: "")+" \(name)?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (_) in
            self.memberApplyMessage(name)
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        controller.addAction(cancelAction)
        _ = isShowResult ?
            self.searchController.present(controller, animated: true, completion: nil):
            self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowResult {
            // 若是有查詢結果則顯示查詢結果集合裡的資料
            return self.searchedGroup.count
        } else {
            return self.groupNameList.count
        }
        
        // #warning Incomplete implementation, return the number of rows
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupListIdentifer = "GroupListCell"
        let groupListcell = tableView.dequeueReusableCell(withIdentifier: groupListIdentifer, for: indexPath)
        if self.isShowResult {
            // 若是有查詢結果則顯示查詢結果集合裡的資料
            groupListcell.textLabel?.text = String(searchedGroup[indexPath.row])
        } else {
            groupListcell.textLabel?.text = String(groupNameList[indexPath.row])
        }
        //        groupListcell.textLabel?.text = groupNameList[indexPath.row]
        //String(indexPath.row)
        
        
        // Configure the cell...
        
        return groupListcell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 法蘭克選擇不需實作，因有遵守UISearchResultsUpdating協議的話，則輸入文字的當下即會觸發updateSearchResults，所以等同於同一件事做了兩次(可依個人需求決定，也不一定要跟法蘭克一樣選擇不實作)
    }
    
    // 點擊searchBar上的取消按鈕
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 依個人需求決定如何實作
        // ...
    }
    
    // 點擊searchBar的搜尋按鈕時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 法蘭克選擇不需要執行查詢的動作，因在「輸入文字時」即會觸發updateSearchResults的delegate做查詢的動作(可依個人需求決定如何實作)
        // 關閉瑩幕小鍵盤
        
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // 若是沒有輸入任何文字或輸入空白則直接返回不做搜尋的動作
//        if self.searchController.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
//            return
//        }
        
        self.filterDataSource()
        print("")
    }
    
    func filterDataSource() {
        self.searchedGroup = groupNameList.filter({(name) -> Bool in
            print(self.searchController.searchBar.text ?? "")
            return name.contains(self.searchController.searchBar.text ?? "0")
        })
        if (self.searchController.searchBar.text ?? "").isEmpty{
            self.isShowResult = false
        }
        else {
            self.isShowResult = true
        }
        
        if self.searchedGroup.count>0 {
            //            self.isShowResult = true
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.init(rawValue: 1)! // 顯示TableView的格線
        } else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none // 移除TableView的格線
            // 可加入一個查找不到的資料的label來告知使用者查不到資料...
            // ...
        }
        
        self.tableView.reloadData()
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func getGroups(){
    
    var json2: JSON
    do {
        json2 = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
    } catch _ {
        json2 = JSON("")
    }
    
    json2["coi_name"] = JSON(parameters["coi_name"] ?? "")
    json2["user_name"] = JSON(parameters["username"] ?? "")
    //        let parameters = ["member_info": json2.description ]
    let parameters = json2.dictionaryValue
    Alamofire.request(GroupGetListUrl, method: .post, parameters: parameters).responseJSON{ response in
        switch response.result
        {
        case .success :
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                let result = post["result"].array ?? []
                print(post)
                for i in 0..<result.count {
                    self.groupNameList.append(result[i]["group_name"].string ?? "")
                }
            }
        case .failure:
            break
            
        }
        self.groupNameList=self.groupNameList.sorted()
        self.groupListTable.reloadData()
    }
    print(self.groupNameList.count)
    
}
    func memberApplyMessage(_ groupName: String) {
        var alertController = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        var json: JSON
        do {
            json = try JSON(data: "{}".data(using: String.Encoding.utf8)!)
        } catch _ {
            json = JSON("")
        }
        
        json["sender_name"] = JSON(parameters["username"] ?? "")
        json["group_name"] = JSON(groupName)
        let parameters = ["join_info": json.description ]
        
        Alamofire.request(GroupMemberJoinUrl, method: .post, parameters: parameters).responseJSON{ response in
            if let value: AnyObject = response.result.value as AnyObject? {
                let post = JSON(value)
                print("Request: ")
                let requestMes = post["message"]
                print(requestMes)
                switch requestMes {
                case "The group is not exist!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("The group is not exist!", comment: ""), preferredStyle: .alert)
                case "Can not send request for myself!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Can not send request for yourself!", comment: ""), preferredStyle: .alert)
                case "Member is in this group!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("You already in the group!", comment: ""), preferredStyle: .alert)
                case "Leader has invited the member!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Administrator has invited members!", comment: ""), preferredStyle: .alert)
                case "Member has allocated request!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("You have allocated request!", comment: ""), preferredStyle: .alert)
                case "Send request successfully!":
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: NSLocalizedString("Send request successfully!", comment: ""), preferredStyle: .alert)
                default:
                    alertController = UIAlertController(title: NSLocalizedString("Warn", comment: ""), message: "?????", preferredStyle: .alert)
                }
            }
            _ = self.isShowResult ?
                self.searchController.present(alertController, animated: true, completion: nil):
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
