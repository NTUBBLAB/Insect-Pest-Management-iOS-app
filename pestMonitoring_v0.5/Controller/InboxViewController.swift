//
//  InboxViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2020/1/2.
//  Copyright © 2020年 Lab405. All rights reserved.
//

import UIKit
import UserNotifications

class InboxViewController: UIViewController {

    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        center.getDeliveredNotifications(){ (notifications) in
            for sent in notifications{
                print(sent.date)
                
            }
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
