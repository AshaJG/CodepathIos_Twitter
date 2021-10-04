//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Ashley Jo-ann Grant on 9/25/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweet : Int!
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweet()
//        numberOfTweet = 20
        myRefreshControl.addTarget(self,action:#selector(loadTweet), for:.valueChanged)
        tableView.refreshControl = myRefreshControl
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150 
        //run the actual app
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweet()
    }
    
   @objc func loadTweet(){
       numberOfTweet = 20
       let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
       let myParams = ["count": numberOfTweet]
        
       TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any],
                                                        success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()//empty the list of tweets
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData() //repopulate the list
          
            
        }, failure: { Error in
            print("Could not retrieve tweets! oh no!")
        })
       self.myRefreshControl.endRefreshing()
    }
    
    func loadMoreTweets(){
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweet = numberOfTweet + 20
        let myParams = ["count" : numberOfTweet]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any],
                                                        success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()//empty the list of tweets
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData() //repopulate the list
            //self.myRefreshControl.endRefreshing()
            
        }, failure: { Error in
            print("Could not retrieve tweets! oh no!")
        })
        self.myRefreshControl.endRefreshing()
    }
    // WHEN THE USER GETS TO THE END OF THE PAGE
   /*  func tableView( tableView: UITableView, willDisplay cell : UITableView, forRowAt indexPath:IndexPath){
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
        
    }*/
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.set(false,forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        //inserting the image
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data{
            cell.profileImageView.image = UIImage(data:imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

   

}
