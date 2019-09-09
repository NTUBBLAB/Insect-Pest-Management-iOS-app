//
//  Disease.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/7.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON


class Disease: NSObject {

    var farm: String?
    var disease = [String]()
    init(location: String) {
        super.init()
        self.farm = location
    }
    func getDisease(location: String, handler: @escaping ([Any]) -> Void){
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_disease_dailyacc.php?loc=" + self.farm! + "&latest=1")
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                
                //print()
                let disease_name = json["disease_names_cn"].stringValue
                let values = json["diseases"][0]["values"][0].arrayObject as! [Double]
                let dates = json["diseases"][0]["dates"][0].arrayObject as! [String]
                let crops = json["crops"].arrayObject as! [String]
                
                
                handler([disease_name, values, dates, crops])
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
            }.resume()
        
    }
}
