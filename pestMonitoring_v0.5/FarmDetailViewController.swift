//
//  FarmDetailViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/6.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//import Parchment

class FarmDetailViewController: UIViewController {

   
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var testLabel: UILabel!
    var name = "123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.testLabel.text = name
//        let detailView = storyboard?.instantiateViewController(withIdentifier: "detailSubView") as? detailSubView
//        if(segmentedControl.selectedSegmentIndex == 0){
//            detailView?.labelName = "tab1"
//        }
//        else{
//            detailView?.labelName = "tab2"
//        }
        
        setupMenuBar()

        
    }
    
    let menubar: farmMenuBar = {
        let mb = farmMenuBar()
        //mb.frame = CGRect(x: 300, y: 300, width: 300, height: 300)
        //mb.backgroundColor = UIColor.blue
        return mb
    }()
    let newView = UIView()
    
    private func setupMenuBar(){
        self.view.addSubview(menubar)
        let views = ["menubar" : menubar]
        let menuConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menubar]|", options: .alignAllTop, metrics: nil, views: views)
        let cn2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[menubar(50)]", options: .alignAllTop, metrics: nil, views: views)
        
        print("???")
        menubar.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        self.view.addConstraint(menuConstraint[0])
        self.view.addConstraint(cn2[0])
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
