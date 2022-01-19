//
//  GroupClassType.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/11/30.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation

class messageClass: NSObject {
    var group_name: String
    var sender_name: String
    var message_type: String
    var group_id: String
    
    init(group_name: String, sender_name: String, message_type: String, group_id: String){
        self.group_name = group_name
        self.sender_name = sender_name
        self.message_type = message_type
        self.group_id = group_id
    }
}

class GroupClass: NSObject {
    var name:   String
    var role:   String
    var info:   String
    var id:     String
    
    init(name: String, role: String, info: String, id: String){
        self.name = name
        self.role = role
        self.info = info
        self.id = id
    }
}

class GrouopMemberClass: NSObject {
    var name: String
    var identifier: String
    
    init(name: String, identifier: String){
        self.name = name
        self.identifier = identifier
    }
}
