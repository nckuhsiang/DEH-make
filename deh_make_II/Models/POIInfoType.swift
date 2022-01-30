//
//  POIInfoType.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/10/18.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation

class POIClass : NSObject {
    var id: Int32
    var POI_title: String!          //
    var POI_latitude: String!       //
    var POI_longitude: String!      //
    var POI_description: String!    //
    var POI_address: String!
    var POI_subject: String!        //
    var POI_type: String!           //
    var POI_keyword: String!        //
    var POI_period: String!
    var POI_year: Int32
    var POI_height: String!         //
    var POI_scope: String!
    var POI_format: String!
    var POI_source: String!
    var POI_rights: String!
    var POI_open: Int32
    var POI_identifier: String!
    var POI_language: String!
    var POI_media_type: String!
    var group_name: String!
    var POI_media_set: [String]
    
    init(id: Int32,POI_title: String, POI_latitude: String, POI_longitude: String, POI_description: String, POI_address: String, POI_subject: String, POI_type: String, POI_keyword: String, POI_period: String, POI_year: Int32, POI_height: String, POI_scope: String, POI_format: String, POI_source: String, POI_rights: String, POI_open: Int32, POI_identifier: String, POI_language: String, POI_media_type: String, group_name: String, POI_media_set: [String]) {
        self.id = id
        self.POI_title = POI_title
        self.POI_latitude = POI_latitude
        self.POI_longitude = POI_longitude
        self.POI_description = POI_description
        self.POI_address = POI_address
        self.POI_subject = POI_subject
        self.POI_type = POI_type
        self.POI_keyword = POI_keyword
        self.POI_period = POI_period
        self.POI_year = POI_year
        self.POI_height = POI_height
        self.POI_scope = POI_scope
        self.POI_format = POI_format
        self.POI_source = POI_source
        self.POI_rights = POI_rights
        self.POI_open = POI_open
        self.POI_identifier = POI_identifier
        self.POI_language = POI_language
        self.POI_media_type = POI_media_type
        self.group_name = group_name
        self.POI_media_set = POI_media_set
    }
}
