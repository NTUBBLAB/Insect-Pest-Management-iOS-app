//
//  SettingsController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/16.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    let defaults = UserDefaults.standard
    
    var hour: String?
    var minute: String?
    
    @IBOutlet weak var autoLogin: UISwitch!
    @IBOutlet weak var notifDate: UILabel!
    
    @IBAction func getDate(_ sender: Any) {
        let selectedDate = self.date.date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        self.hour = formatter.string(from: selectedDate)
        
        formatter.dateFormat = "mm"
        
        
        self.minute = formatter.string(from: selectedDate)
        
        defaults.set(Int(self.hour!), forKey: "hour")
        defaults.set(Int(self.minute!), forKey: "minute")
        defaults.synchronize()
        self.notifDate.text = NSLocalizedString("Notification time", comment: "") + self.hour! + ":" + self.minute!
    }
    
    @IBOutlet weak var date: UIDatePicker!
    
    @IBAction func changed(_ sender: Any) {
        if autoLogin.isOn{
            defaults.set("1", forKey: "autoLogin")
            defaults.synchronize()
        }
        else{
            defaults.set("0", forKey: "autoLogin")
            defaults.synchronize()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.date.isHidden = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC+8")
        //formatter.dateFormat = "mm"
        let default_date = formatter.date(from: "19:00")
        
        
        //print(default_date)
        self.notifDate.text = "通知時間: " + formatter.string(from: default_date!)
        
        if autoLogin.isOn{
            defaults.set("1", forKey: "autoLogin")
            defaults.synchronize()
        }
        else{
            defaults.set("0", forKey: "autoLogin")
            defaults.synchronize()
        }
        // self.tableView.register(InboxTableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            let height:CGFloat = date.isHidden ? 0.0 : 216.0
            return height
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if indexPath.row == 3{
            defaults.set("2", forKey: "autoLogin")
            defaults.synchronize()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        else if indexPath.row == 1{
            date.isHidden = !date.isHidden
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tableView.beginUpdates()
                // apple bug fix - some TV lines hide after animation
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.endUpdates()
            })
        }
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//        if indexPath.row == 3{
//
//            return cell
//        }
//        else{
//            return nil
//        }
//    }
    

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
