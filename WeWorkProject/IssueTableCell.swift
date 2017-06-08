//
//  IssueTableCell.swift
//  WeWorkProject
//
//  Created by Colin on 6/7/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
import UIKit

class IssueTableCell: UITableViewCell, URLSessionDelegate, UITextViewDelegate {
    @IBOutlet weak var IssueNumber: UILabel!
    @IBOutlet weak var IssueTitle: UITextField!
    @IBOutlet weak var IssueDescription: UITextView!
    @IBOutlet weak var IssueStatus: UISwitch!
    
    weak var issue:Issue?
    
    @IBAction func ChangeIssueStatus(_ sender: Any) {
        guard let button = sender as? UISwitch, button === IssueStatus else {
            //tied to something other than the issueStatus switch for the cell
            return
        }
        if button.isOn {
            issue?.state = "open"
        } else {
            issue?.state = "closed"
        }
        do {
            var updatePath:String = (issue?.path)!
            updatePath.append("?access_token=\(oauth_Token)")
            let updateURL:URL = URL.init(string: updatePath)!
            var urlRequest:URLRequest = URLRequest.init(url: updateURL)
            urlRequest.httpMethod = "PATCH"
            
            var parametersDict:[String: Any] = [String:Any]()
            parametersDict["state"] = issue?.state
            
            let jsonData = try JSONSerialization.data(withJSONObject: parametersDict as Any, options:JSONSerialization.WritingOptions.prettyPrinted )
            let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let editTask = session.uploadTask(with: urlRequest, from: jsonData, completionHandler: {(data:Data?,response:URLResponse?,error:Error?) in
                if(error == nil){
                    let httpResponse:HTTPURLResponse = (response as? HTTPURLResponse)!
                     if httpResponse.statusCode == 200 {
                        //everything is good.
                     } else {
                        //something in the communication failed reset the local issue status
                        if button.isOn {
                            self.issue?.state = "open"
                            button.setOn(true, animated: true)
                        } else {
                            self.issue?.state = "closed"
                            button.setOn(false, animated: true)
                        }
                     }

 
                } else {
                    print("error response when connecting to github: \(String(describing: error))" )
                    //something in the communication failed reset the local issue status
                    if button.isOn {
                        self.issue?.state = "open"
                        button.setOn(true, animated: true)
                    } else {
                        self.issue?.state = "closed"
                        button.setOn(false, animated: true)
                    }

                }
            } )
            editTask.resume()
            session.finishTasksAndInvalidate()
        } catch {
            print("error converting dictionary to JSON")
        }
    }
    @IBAction func saveChanges(_ sender: Any){
        do {
            var updatePath:String = (issue?.path)!
            updatePath.append("?access_token=\(oauth_Token)")
            let updateURL:URL = URL.init(string: updatePath)!
            var urlRequest:URLRequest = URLRequest.init(url: updateURL)
            urlRequest.httpMethod = "PATCH"
            
            var parametersDict:[String: Any] = [String:Any]()
            parametersDict["title"] = IssueTitle.text
            parametersDict["body"] = IssueDescription.text
            
            let jsonData = try JSONSerialization.data(withJSONObject: parametersDict as Any, options:JSONSerialization.WritingOptions.prettyPrinted )
            let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let editTask = session.uploadTask(with: urlRequest, from: jsonData, completionHandler: {(data:Data?,response:URLResponse?,error:Error?) in
                if(error == nil){
                    let httpResponse:HTTPURLResponse = (response as? HTTPURLResponse)!
                    if httpResponse.statusCode == 200 {
                        //everything is good.
                        self.issue?.title = self.IssueTitle.text!
                        self.issue?.descriptionString = self.IssueDescription.text
                    } else {
                        //something in the communication failed reset the local issue values
                        
                        self.IssueDescription.text = self.issue?.descriptionString
                    }
                    
                    
                } else {
                    print("error response when connecting to github: \(String(describing: error))" )
                    //something in the communication failed reset the local issue values
                    self.IssueTitle.text = self.issue?.title
                    self.IssueDescription.text = self.issue?.descriptionString                    
                }
            } )
            editTask.resume()
            session.finishTasksAndInvalidate()
        } catch {
            print("error converting dictionary to JSON")
        }
    }

    //MARK: URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if (error == nil) {
        }
    }

}
