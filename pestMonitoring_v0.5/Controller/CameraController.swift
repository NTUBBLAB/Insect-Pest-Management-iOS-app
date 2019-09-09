//
//  CameraController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/28.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class CameraController: UIViewController {

    @IBAction func logoutAction(_ sender: Any) {
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
