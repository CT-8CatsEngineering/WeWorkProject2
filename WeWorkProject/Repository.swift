//
//  Repository.swift
//  WeWorkProject
//
//  Created by Colin on 6/6/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation


class Repository: NSObject, URLSessionDelegate {
    let name:String
    let repoPath:String
    let id:Int
    let descriptionString:String
    var issuesPath:String
    
    var issues:[Issue] = [Issue]()
    
    init(content:[String:Any]) {
        
        name = content["name"] as! String
        repoPath = content["html_url"] as! String
        id = content["id"] as! Int
        if content["description"] is NSNull {
            descriptionString = ""
        } else {
            descriptionString = content["description"] as! String
        }
        
        issuesPath = content["issues_url"] as! String  //"issues_url": https://api.github.com/repos/CT-8CatsEngineering/GradeBook/issues{/number}
        let substringIndex = issuesPath.index(issuesPath.endIndex, offsetBy: -9)
        issuesPath = issuesPath.substring(to: substringIndex)
 
        super.init()
        
        var getIssuesPath = issuesPath.appending("?state=all")
        getIssuesPath.append("&access_token=\(oauth_Token)")
        let issuesURL:URL = URL.init(string: getIssuesPath)!
        
        
        self.retrieveIssueInformation(issuesURL: issuesURL)
    }
    func retrieveIssueInformation(issuesURL:URL) {
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let issuesSessionTask:URLSessionDownloadTask = session.downloadTask(with: issuesURL, completionHandler: {(url:URL?,response:URLResponse?,error:Error?)
            in
            if (error == nil) {
                do {
                    let data:Data = try Data.init(contentsOf: url!)
                    let responseArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [Any]
                    for issue in (responseArray)!{
                        let responseDictionary:Dictionary = issue as! [String:Any]
                        //print("issues response dictionary: \n \(responseDictionary )")
                        let issue = Issue.init(content:responseDictionary)
                        self.issues.append(issue)
                    }
                } catch {
                    print("Error was nil but something failed in deserializing the data")
                }
            } else {
                print("error response when connecting to github: \(String(describing: error))" )
            }
            
        })
        issuesSessionTask.resume()
        session.finishTasksAndInvalidate()

    }
    //MARK: URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if (error == nil) {
            //seesion ended successfully
        }
    }

}
