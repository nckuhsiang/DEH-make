//
//  COITableViewController.swift
//  UItest1010
//
//  Created by Ray Chen on 2018/7/14.
//  Copyright © 2018年 Ray Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class COITableViewController: UITableViewController {
    
    var COIList : [String] = []
    var selecedCOI : IndexPath = [0, 0]
    
    @IBOutlet var COIListTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        getCOIInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        COIListTableView.delegate = self
        COIListTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCOIInfo(){
        COIList = []
        COIList.append("deh")
        Alamofire.request(GetCOIListUrl, method: .get).responseJSON{ response in
            print("Get COI Info. Request!")
            if let value: AnyObject = response.result.value as AnyObject? {
                
                let post = JSON(value)
                let result = post["result"].array ?? []
                for i in 0..<result.count {
                    let coi_name = result[i]["coi_name"].string ?? ""
                    
                    self.COIList.append(coi_name)
                }
            }
            self.COIListTableView.reloadData()
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return COIList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Choose the organization to which your attraction belongs", comment: "")
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let Coicell = tableView.dequeueReusableCell(withIdentifier: "COInameCell", for: indexPath)
        if COIList[indexPath.row] == "deh" {
            Coicell.textLabel?.text = "DEH 文史脈流"
            Coicell.imageView?.image = UIImage(named: "deh_icon")
        } else if COIList[indexPath.row] == "extn" {
            Coicell.textLabel?.text = "NCKU 踏溯台南"
            Coicell.imageView?.image = UIImage(named: "extn_icon")
        } else {
            Coicell.textLabel?.text = COIList[indexPath.row]
            Coicell.imageView?.image = UIImage(named: "deh_icon")
        }
        return Coicell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        COIname = COIList[indexPath.row]
        
        tableView.cellForRow(at: selecedCOI)?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selecedCOI = indexPath
        self.navigationController?.popViewController(animated: true)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
