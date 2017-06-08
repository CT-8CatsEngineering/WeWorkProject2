//
//  User.swift
//  WeWorkProject
//
//  Created by Colin on 6/6/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
import UIKit

class User:NSObject {
    
    let name:String
    let bio:String
    let avatarPath:String
    let id:Int
    let userPath:String
    let login:String
    let location:String
    
    var avatarImage:UIImage = #imageLiteral(resourceName: "BlankAvatar")
    var repos:[Repository] = [Repository]()
    
    init(contentsDictionary:[String:Any]) {
        
        name = contentsDictionary["name"] as! String
        bio = contentsDictionary["bio"] as! String
        avatarPath = contentsDictionary["avatar_url"] as! String
        id = contentsDictionary["id"] as! Int
        userPath = contentsDictionary["url"] as! String
        login = contentsDictionary["login"] as! String
        location = contentsDictionary["location"] as! String
        
        super.init()
    }
    
    init(isTemp:Bool) {//init a temp user so that we don't crash initially when we are still downloading the user information.
        name = "Temp"
        bio = "bio"
        avatarPath = "avatar_url"
        id = -1
        userPath = "url"
        login = "login"
        location = "location"
        
        super.init()

    }
}
