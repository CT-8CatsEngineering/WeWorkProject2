//
//  MasterViewController.swift
//  WeWorkProject
//
//  Created by Colin on 6/6/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

let oauth_Token = ""//put your oauth Token here

class MasterViewController: UITableViewController, URLSessionDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var currentUser:User? = nil
    @IBOutlet var masterTableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.retrieveUserInfo()
        currentUser = User.init(isTemp: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    //retrieve the information about the authenticated user
    func retrieveUserInfo() {
        let searchURL:URL = URL.init(string: "https://api.github.com/user?access_token=\(oauth_Token)")!
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let sessionTask:URLSessionDownloadTask = session.downloadTask(with: searchURL, completionHandler: {(url:URL?,response:URLResponse?,error:Error?) in
            if(error == nil){
                do {
                    let data:Data = try Data.init(contentsOf: url!)
                    let responseDictionary:Dictionary? = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                    //print("user response dictionary: \n \(responseDictionary ?? [String: Any]())")
                    
                    self.currentUser = User.init(contentsDictionary: responseDictionary!)
                    
                    var avatarPath = responseDictionary?["avatar_url"] as! String
                    var reposPath = responseDictionary?["repos_url"] as! String
                    
                    avatarPath.append("?access_token=\(oauth_Token)")
                    let avatarURL:URL = URL.init(string: avatarPath)!
                    self.downloadImage(session: session, imageURL: avatarURL)
                    
                    reposPath.append("?access_token=\(oauth_Token)")
                    let reposURL:URL = URL.init(string: reposPath)!
                    self.retrieveReposInformation(session: session, reposURL: reposURL)
                } catch {
                    print("Error was nil but something failed in deserializing the data")
                }
            } else {
                print("error response when connecting to flicker: \(String(describing: error))" )
            }
        } )
        sessionTask.resume()
        session.finishTasksAndInvalidate()
    }

    func retrieveReposInformation(session:URLSession, reposURL:URL) {
        let reposSessionTask:URLSessionDownloadTask = session.downloadTask(with: reposURL, completionHandler: {(url:URL?,response:URLResponse?,error:Error?)
            in
            if (error == nil) {
                do {
                    let data:Data = try Data.init(contentsOf: url!)
                    let responseArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [Any]
                    for repo in (responseArray)!{
                        let responseDictionary:Dictionary = repo as! [String:Any]
                        //print("repos response dictionary: \n \(responseDictionary)")
                        let repo:Repository = Repository.init(content: responseDictionary)
                        self.currentUser?.repos.append(repo)
                    }
                    
                } catch {
                    print("Error was nil but something failed in deserializing the data")
                }
            } else {
                print("error response when connecting to flicker: \(String(describing: error))" )
            }
            
        })
        reposSessionTask.resume()
        
    }
    
    
    //download the image at the url
    func downloadImage(session:URLSession, imageURL:URL) {
        let sessionTask:URLSessionDownloadTask = session.downloadTask(with: imageURL, completionHandler: {(url:URL?,response:URLResponse?,error:Error?) in
            
            do {
                if (error == nil){
                    let data:Data = try Data.init(contentsOf: url!)
                    let downloadedImage:UIImage = UIImage(data: data)!
                    self.currentUser?.avatarImage = downloadedImage
                } else {
                    print("error response: \(String(describing: error)) \nwhen downloading file at URL: \(imageURL)")
                }
            } catch {
                print("Error converting downloaded data into a UIImage or adding it to the contentImages array")
            }
        } )
        sessionTask.resume()
        
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                let currentIndex = indexPath.last
                controller.repository = currentUser?.repos[currentIndex!]
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return (currentUser?.repos.count)! 
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.first == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableCell
            
            cell.UserAvatar.image = currentUser?.avatarImage
            cell.UserName.text = currentUser?.name
            cell.UserBio.text = currentUser?.bio

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableCell", for: indexPath) as! RepoTableCell
            
            let repo:Repository = (currentUser?.repos[indexPath.last!])!
            
            cell.RepoNameField.text = repo.name
            cell.RepoDescription.text = repo.descriptionString
                        
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.first == 0 {
            return 145
        } else {
            return 90
        }
    }

    //MARK: URLSessionDelegate
    func reloadUI() {
        navigationItem.title = self.currentUser?.login
        masterTableview.reloadData()
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if (error == nil) {
            //seesion ended successfully
            performSelector(onMainThread: #selector(reloadUI), with: self, waitUntilDone: false)
        }
    }


}

