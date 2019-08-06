//
//  FarmDetailViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/6.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class FarmDetailViewController: UIViewController {

    
    @IBOutlet weak var testLabel: UILabel!
    var name = "123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testLabel.text = name
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
