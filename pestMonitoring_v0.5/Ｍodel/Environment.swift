//
//  Environment.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/7/31.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class Environment: NSObject {
    var temp: Double?
    var humid: Double?
    var light: Double?
    var dbNum: String?
    public var farm: String?
    init(location: String) {
        super.init()
        self.farm = location
    }
    func getCurrentEnv(location: String, handler: @escaping ([String]) -> Void) {
        
        self.getDbNumber(dbUrl: "http://140.112.94.123:20000/PEST_DETECT/_android/get_number_of_dbs.php?location" + farm!){ (result) in
            let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_envi_current.php?db=" + result + "&loc=" + self.farm!)
            // print(url)
            URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    print(error!)
                    return
                }
                do{
                    print("GETTING CURRENT ENVS")
                    let currentEnvJson = try JSON(data: data!)
                    let currentTemp = currentEnvJson["T"][0].stringValue
                    let currentHumid = currentEnvJson["H"][0].stringValue
                    let currentLight = currentEnvJson["L"][0].stringValue
                    handler([currentTemp, currentHumid, currentLight])
                }
                catch let jsonError{
                    print(jsonError)
                }
            }.resume()
        }
            
        
    }
    func getDbNumber(dbUrl: String, handler: @escaping (String) -> Void) {
        let url = URL(string: dbUrl)
        
//        let json = JSON(data: url)
        
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
//
                let json = try JSON(data: data!)
                print("GETTING DB RESULT")
                
                //self.dbNum?.append(json["RESULT"][0]["NUM"].stringValue)
                //let results = json["RESULT"][0]["NUM"].string
                handler(json["RESULT"][0]["NUM"].stringValue)
                //print(dbNumber)
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
    }
    
}
