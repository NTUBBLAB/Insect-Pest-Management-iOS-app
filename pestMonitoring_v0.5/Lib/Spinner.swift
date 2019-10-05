//
//  Spinner.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/19.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

struct Spinner{
    //var spinner: UIView
    func setSpinnerView(view: UIView) -> UIView{
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        view.addSubview(spinnerView)
        
        return spinnerView
    }
}

//extension UIView{
//    func drawShadow(){
//
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.8
//        self.layer.shadowOffset = CGSize.zero
//        self.layer.shadowRadius = 2
//
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
