//
//  SummaryViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/10/25.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit



class SummaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "NTU IPM"
        
        setSummaryCell()
        // Do any additional setup after loading the view.
    }
    
    func setSummaryCell(){
        let summaryCell = UIView()
        let titleCell = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-30, height: 60))
        titleCell.text = "TEST"
        titleCell.textAlignment = .center
        
        summaryCell.backgroundColor = hexStringToUIColor(hex: "#F7F3E3")
        titleCell.backgroundColor = hexStringToUIColor(hex: "AF9164")
        
        summaryCell.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryCell)
        summaryCell.addSubview(titleCell)
        summaryCell.layer.cornerRadius = 10
        // add summaryCell constraints
        view.addConstraints([NSLayoutConstraint(item: summaryCell, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: summaryCell, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: summaryCell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.view.frame.width - 30),
                             NSLayoutConstraint(item: summaryCell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)])
       
        
    }

    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
extension UIImageView{
    public func maskCircle(anyImage: UIImage){
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        
        self.image = anyImage
    }
}
