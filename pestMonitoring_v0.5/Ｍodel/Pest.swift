//
//  Pest.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/26.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class Pest: NSObject {
    var species: [String]?
    var counts: [Int]?
    public var farm: String?
    
    init(location: String) {
        super.init()
        self.farm = location
    }
    func getCurrentPest(counts: @escaping ([String], [Int], Dictionary<String, [Int]>) -> Void){
        
        self.getDbNumber(dbUrl: "http://140.112.94.123:20000/PEST_DETECT/_android/get_number_of_dbs.php?location=" + farm!) { (result) in
            let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_insect_current.php?db=" + result + "&loc=" + self.farm!)
            URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    print(error!)
                    return
                }
                do{
                    let pestJson = try JSON(data: data!)
                    
                    //print(pestJson["status"])
                    var species_array = [String]()
                    var count_array = [Int]()
                    var alarm = Dictionary<String, [Int]>()
                    var i = 0
                    for insect in pestJson["species_cn"].arrayObject as! [String]{
                        species_array.append(insect)
                        alarm[insect] = (pestJson["alarm"][i].arrayObject as! [Int])
                        i += 1
                    }
                        
                    for count in pestJson["counts"].arrayObject as! [Int]{
                        count_array.append(count)
                    }
                    
                    counts(species_array, count_array, alarm)
                }
                catch let jsonError{
                    print(jsonError)
                }
            }.resume()
            
        }
    }
    
    func getDailyPest(handler: @escaping ([String], [String:Any], [String]) -> Void){
        let dailyURL = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_insect_daily.php?loc=" + self.farm! + "&latest=1")
        URLSession.shared.dataTask(with: dailyURL!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do{
                let json = try JSON(data: data!)
                
                var dates = [String]()
                var values = [Any]()
                for day in json["dates"].arrayObject as! [String]{
                    dates.append(day)
                }
                
                handler(dates, json["values"].dictionaryObject!, json["species"].arrayObject as! [String])
            }
            catch let jsonError{
                print(jsonError)
            }
        }.resume()
        
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
    

}
