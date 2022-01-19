//
//  createFolder.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/10/25.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation

class creatFolder {
    var folderPath = ""
    
    func createFolder() -> String {
        print("DEH Folder Creating")
        let fileManager1 = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPaths = (documentsDirectory as! NSString).appendingPathComponent("DEH-Image")
        
        if fileManager1.fileExists(atPath: dataPaths){
            print("Folder already exist!")
            folderPath = dataPaths
            print("Following is DEH photo path : ")
            print(folderPath)  ///var/mobile/Containers/Data/Application/5D894EEA-04BD-4AB9-A2F8-12D32711AFD4/Documents/DEH-Image
        }
        else{
            do {
                try FileManager.default.createDirectory(atPath: dataPaths, withIntermediateDirectories: false, attributes: nil)
                folderPath = dataPaths
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return folderPath
    }
}
