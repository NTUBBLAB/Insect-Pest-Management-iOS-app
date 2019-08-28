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
                    //print("GETTING CURRENT ENVS")
                    let currentEnvJson = try JSON(data: data!)
                    let currentTemp = currentEnvJson["values"][0].stringValue
                    let currentHumid = currentEnvJson["values"][1].stringValue
                    let currentLight = currentEnvJson["values"][2].stringValue
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
        
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                //print("GETTING DB RESULT")
                handler(json["RESULT"][0]["NUM"].stringValue)
        
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
    }
    public func getDailyEnv(type: String, handler: @escaping ([Any]) -> Void){
        let dailyURL = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_envi_daily.php?loc=" + self.farm! + "&type=" + type)
        URLSession.shared.dataTask(with: dailyURL!){ (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                //
                let json = try JSON(data: data!)
                let allDates = json["dates"].arrayObject
                let allValues = json["values"].arrayObject
                let dates = Array(allDates![allDates!.count-14 ..< allDates!.count])
                
                let values = Array(allValues![allValues!.count-14 ..< allValues!.count])
                //print("GETTING DB RESULT")
                handler([dates, values])
                
            }
            catch let jsonError{
                print(jsonError)
            }
        }.resume()
    }
    
}
