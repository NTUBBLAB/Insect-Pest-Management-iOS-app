//
//  InboxTableViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2020/1/2.
//  Copyright © 2020年 Lab405. All rights reserved.
//

import UIKit
import UserNotifications


class InboxTableViewCell: UITableViewCell{
    
    var receivedTimeLabel = UILabel()
    var notificationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        receivedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(receivedTimeLabel)
        self.addSubview(notificationLabel)
        
        self.addConstraints([NSLayoutConstraint(item: notificationLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10),
                             NSLayoutConstraint(item: notificationLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5),
                             NSLayoutConstraint(item: notificationLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                             NSLayoutConstraint(item: notificationLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
        self.addConstraints([NSLayoutConstraint(item: receivedTimeLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10),
                             NSLayoutConstraint(item: receivedTimeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5),
                             NSLayoutConstraint(item: receivedTimeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
                             NSLayoutConstraint(item: receivedTimeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class InboxTableViewController: UITableViewController {

    let center = UNUserNotificationCenter.current()
    var notificationTime = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.refreshControl?.isEnabled = true
        getNotificaitons()
        print(self.notificationTime.count)
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        self.tableView.register(InboxTableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    @objc func refresh(sender: AnyObject){
        //print("123")
        getNotificaitons()
        self.reloadInputViews()
        self.refreshControl?.endRefreshing()
    }
    func getNotificaitons(){
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //let myString = formatter.string(from: Date()) // string purpose I add here
        
        center.getDeliveredNotifications() { (nots) in
            
            print("notificaiton counts: ", nots.count)
            for not in nots{
                let dateSent = not.date
                let date = formatter.string(from: dateSent)
                self.notificationTime.append(date)
            }
            print(self.notificationTime)
        }
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.notificationTime.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! InboxTableViewCell
        cell.receivedTimeLabel.text = self.notificationTime[indexPath.row]
        cell.notificationLabel.text = "123"

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
