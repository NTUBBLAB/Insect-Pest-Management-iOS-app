//
//  CollectionViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/26.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON
//private let reuseIdentifier = "Cell"

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    
    @IBAction func logoutAction(_ sender: Any) {
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    var locations = [String]()
    
    var farmCell = [FarmCell]()
    var pestCell = [PestCell]()
    let chineseDict = ["CHIAYI_GH": "嘉義育家", "JINGPIN_GH": "京品洋桔梗溫室", "YUNLIN_GH": "雲林福成", "TAINANDARES_GH": "台南農改場洋桔梗溫室", "TAINANMO_FF": "台南農改場芒果園", "TAICHUNGSB_GH": "草屯光之莓草莓園", "QINGYUAN_GH": "擎園蝴蝶蘭溫室", "TEST_GH": "測試溫室"]
    func fetchData(){
        //cell.farmLabel = locations[indexPath.row]
        
        for loc in self.locations{
            print(loc)
            let env = Environment(location: loc)
            let cell = FarmCell()
            if chineseDict[loc] != nil{
                cell.farmlabel = chineseDict[loc]
            }
            else{
                cell.farmlabel = loc
            }
            let spinner = Spinner()
            let spinnerView = spinner.setSpinnerView(view: view)
            env.getDbNumber(dbUrl: "http://140.112.94.123:20000/PEST_DETECT/_android/get_number_of_dbs.php?location" + loc){ (result) in
                let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_envi_current.php?db=" + result + "&loc=" + loc)
                // print(url)
                URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    do{
                        //print("GETTING CURRENT ENVS")
                        
                        let currentEnvJson = try JSON(data: data!)
                        
                        if currentEnvJson["status"] == 3{
                            let currentTemp = currentEnvJson["values"][0].stringValue
                            let currentHumid = currentEnvJson["values"][1].stringValue
                            let currentLight = currentEnvJson["values"][2].stringValue
                            cell.currentEnv = [currentTemp + " °C", currentHumid + " %", currentLight + " lux"]
                        }
                        else{
                            print("No data available")
                            cell.currentEnv = ["None", "None", "None"]
                            //handler(["none", "none", "none"])
                            //return
                        }
                        //self.farmCell.append(cell)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    catch let jsonError{
                        print(jsonError)
                    }
                }.resume()
            }
            env.getDbNumber(dbUrl: "http://140.112.94.123:20000/PEST_DETECT/_android/get_number_of_dbs.php?location=" + loc) { (result) in
                let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_insect_current.php?db=" + result + "&loc=" + loc)
                URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    do{
                        let pestJson = try JSON(data: data!)
                        
                        //print(pestJson["status"])
                        if pestJson["status"] == 3{
                            print(pestJson["alarms"])
                            print(pestJson)
                            var species_array = [String]()
                            var count_array = [Int]()
                            var alarm = Dictionary<String, [Int]>()
                            var i = 0
                            for insect in pestJson["species_cn"].arrayObject as! [String]{
                                species_array.append(insect)
                                alarm[insect] = (pestJson["alarms"][i].arrayObject as! [Int])
                                i += 1
                            }
                            for count in pestJson["counts"].arrayObject as! [Int]{
                                count_array.append(count)
                            }
                            cell.species = species_array
                            cell.pestCount = count_array
                            cell.alarm = alarm
                        }
                        else{
                            cell.pestCheck = 0
                        }
                        
                        //print(cell.alarm)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                       
                    }
                    catch let jsonError{
                        print(jsonError)
                    }
                }.resume()
                DispatchQueue.main.async {
                    spinnerView.removeFromSuperview()
                    self.farmCell.append(cell)
                    self.collectionView.reloadData()
                }
                
            }
            
            
        }
       
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        locations = defaults.array(forKey: "locations") as! [String]
        fetchData()
        //print(self.farmCell)
        navigationItem.title = "儀表板"
        navigationItem.titleView?.backgroundColor = UIColor.blue
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(FarmSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return farmCell.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let farmDetail = storyboard?.instantiateViewController(withIdentifier: "FarmDetailViewController") as? FarmDetailViewController
        let pager = storyboard?.instantiateViewController(withIdentifier: "PagerMenu") as? PagerTabStrip
        //farmDetail?.name = locations[indexPath.row]
        pager?.location = locations[indexPath.item]
        //print(locations[indexPath.item])
        self.navigationController?.pushViewController(pager!, animated: true)
    }
    
    override func collectionView(_ collcetionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let cell = collcetionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FarmSummaryCollectionViewCell

      
        //print(pestCell.count)
        print(self.farmCell[indexPath.item].farmlabel)
        cell.data = self.farmCell[indexPath.item]
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false

        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width - 30, height: 360)
    }
    
    
 
}
