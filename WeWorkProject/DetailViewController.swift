//
//  DetailViewController.swift
//  WeWorkProject
//
//  Created by Colin on 6/6/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDelegate {

    @IBOutlet weak var repoDescriptionView: UITextView!
    @IBOutlet weak var repoNameField: UITextField!
    @IBOutlet weak var repoURL: UIButton!
    @IBOutlet weak var issuesTableView: UITableView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionvView: UITextView!
   
    weak var repository:Repository? {
        didSet {
            // Update the view.
            configureView()
        }
    }


    @IBAction func newIssue(_ sender: Any) {
        do {
            
            let authIssuePath:String = (repository?.issuesPath.appending("?access_token=\(oauth_Token)"))!
            let updateURL:URL = URL.init(string: authIssuePath)!
            var urlRequest:URLRequest = URLRequest.init(url: updateURL)
            urlRequest.httpMethod = "POST"
            
            var parametersDict:[String: Any] = [String:Any]()
            parametersDict["title"] = titleField.text//will be the value from the titleField
            parametersDict["body"] = descriptionvView.text //will be the value from the descriptionView
            parametersDict["state"] = "open"
            
            let jsonData = try JSONSerialization.data(withJSONObject: parametersDict as Any, options:JSONSerialization.WritingOptions.prettyPrinted )
            let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let newIssueTask = session.uploadTask(with: urlRequest, from: jsonData, completionHandler: {(data:Data?,response:URLResponse?,error:Error?) in
                if(error == nil){
                    let responseContents:String = String.init(data: data!, encoding: String.Encoding.utf8)!
                    print("new issue response: \(responseContents)")
                    let httpResponse:HTTPURLResponse = (response as? HTTPURLResponse)!
                    print("\n\n http Response status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 201 {
                        //everything is good. add the new issue to the UI
                        do {
                            let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                            print("issues response dictionary: \n \(responseDictionary  ?? [String:Any]())")
                            let issue = Issue.init(content:responseDictionary!)
                            
                            let newIssuePath:IndexPath = IndexPath(row: (self.repository?.issues.count)!, section: 0)
                            self.repository?.issues.append(issue)
                            
                            self.issuesTableView.insertRows(at: [newIssuePath], with: .automatic)
                            
                            self.performSelector(onMainThread: #selector(self.resetNewIssueUI), with: self, waitUntilDone: false)
                        } catch {
                            print("Error was nil but something failed in deserializing the data")
                        }
                        
                    } else {
                        //something in the communication failed reset the local issue status
                    }
                    
                } else {
                    print("error response when connecting to github: \(String(describing: error))" )
                    //something in the communication failed reset the local issue status
                }
            } )
            
            newIssueTask.resume()
            session.finishTasksAndInvalidate()
            
        } catch {
            print("error converting dictionary to JSON")
        }

    }
    @IBAction func openRepoLink() {
        UIApplication.shared.open(URL.init(string:(repository?.repoPath)!)!, options: [String:Any](), completionHandler: nil)
    }
    
    func resetNewIssueUI() {
        self.titleField.text = ""
        self.descriptionvView.text = "Leave a Comment..."
    }
    func configureView() {
        // Update the user interface for the detail item.
        if repository != nil {
            navigationItem.title = repository?.name
            if let nameField = repoNameField {
                nameField.text = "this is a test"
                let name:String = (repository?.name)!
                nameField.text = name
            }
            if let descriptionField = repoDescriptionView {
                descriptionField.text = repository?.descriptionString
            }
            if let URLfield = repoURL {
                URLfield.setTitle(repository?.repoPath, for: .normal)
            }
            if let tableView = issuesTableView {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //UITableViewDataSource functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:IssueTableCell = tableView.dequeueReusableCell(withIdentifier: "IssueTableCell") as! IssueTableCell
        
        
        cell.IssueNumber.text = "\(repository?.issues[indexPath.last!].number ?? -1)"
        if let cellTitle = cell.IssueTitle {
            cellTitle.text = repository?.issues[indexPath.last!].title
        }
        if let cellDescription = cell.IssueDescription {
            cellDescription.text = repository?.issues[indexPath.last!].descriptionString
        }
        if repository?.issues[indexPath.last!].state == "open" {
            cell.IssueStatus.setOn(true, animated: true)
        } else {
            cell.IssueStatus.setOn(false, animated: true)
        }
        
        cell.issue = repository?.issues[indexPath.last!]

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository?.issues.count ?? 0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    //UITableViewDelegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    //MARK: URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if (error == nil) {
            //seesion ended successfully
        }
    }
    
}

