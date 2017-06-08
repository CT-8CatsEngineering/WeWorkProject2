//
//  Issue.swift
//  WeWorkProject
//
//  Created by Colin on 6/6/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
    

class Issue: NSObject {
    var title:String
    var descriptionString:String
    var state:String
    var number:Int
    var path:String

    var contentDict:[String:Any]
    
    init(content:[String:Any]) {
        title = content["title"] as! String
        descriptionString = content["body"] as! String
        state = content["state"] as! String
        number = content["number"] as! Int
        path = content["url"] as! String

        contentDict = content
        
        super.init()
    }
}
