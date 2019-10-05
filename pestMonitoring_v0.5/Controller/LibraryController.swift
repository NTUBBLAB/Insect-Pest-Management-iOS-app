//
//  LibraryController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/19.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import WebKit

class LibraryController: UIViewController{

    @IBOutlet weak var webView1: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.webView1.uiDelegate = self
        //let spin = Spinner()
        //let spinnerView = spin.setSpinnerView(view: view)
        
        let request = URLRequest(url: URL(string: "http://m.tndais.gov.tw/diagnosis/index.asp")!)
        webView1?.load(request)
        
        
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
