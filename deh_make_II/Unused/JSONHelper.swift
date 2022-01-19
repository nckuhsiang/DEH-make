//
//  JSONHelper.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/10/30.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class JSONhelper {
    let NEW_DEH_API  = "http://deh.csie.ncku.edu.tw:8080/api/v1"
    func authorization() -> String {
        var token = ""
        let parm = ["username": "test03", "password": "0a291f120e0dc2e51ad32a9303d50cac"]
            Alamofire.request("http://deh.csie.ncku.edu.tw:8080/api/v1/grant", method: .post, parameters: parm)
                .validate()
                .responseJSON{ response in
                    if response.result.isFailure {
                        print("Response error")
                    } else {
                        let json = JSON(response.result.value!)
                        token = json["token"].stringValue
                        print("token: " + token)
                    }
        }
        return token
    }
}
