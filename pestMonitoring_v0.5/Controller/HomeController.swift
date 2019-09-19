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
    
    func fetchData(){
        //cell.farmLabel = locations[indexPath.row]
        
        for loc in self.locations{
            let env = Environment(location: loc)
            let cell = FarmCell()
            cell.farmlabel = loc
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
                            spinnerView.removeFromSuperview()
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
                        var species_array = [String]()
                        var count_array = [Int]()
                        for insect in pestJson["species"].arrayObject as! [String]{
                            species_array.append(insect)
                        }
                        for count in pestJson["counts"].arrayObject as! [Int]{
                            count_array.append(count)
                        }
                        cell.species = species_array
                        cell.pestCount = count_array
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                       
                    }
                    catch let jsonError{
                        print(jsonError)
                    }
                }.resume()
                self.farmCell.append(cell)
            }
            
            
//            let currentPest = Pest(location: loc)
//            currentPest.getCurrentPest(){ (result1, result2) in
//
//                    cell.species = result1
//                    cell.pestCount = result2
//
//            }
//            let currentEnv = Environment(location: loc)
//
//            currentEnv.getCurrentEnv(location: loc) { (result) in
//
//                    cell.farmlabel = loc
//                    cell.currentEnv = [result[0] + " °C", result[1] + " %", result[2] + " lux"]
//
//            }
//            DispatchQueue.main.async {
//                self.farmCell.append(cell)
//                self.collectionView.reloadData()
//            }
            
        }
       
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        locations = defaults.array(forKey: "locations") as! [String]
        fetchData()
        
        navigationItem.title = "Home"
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
        pager?.location = locations[indexPath.row]
        self.navigationController?.pushViewController(pager!, animated: true)
    }
    override func collectionView(_ collcetionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let cell = collcetionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FarmSummaryCollectionViewCell

        //cell.farmName?.text = locations[indexPath.row]
        print(pestCell.count)
        cell.data = farmCell[indexPath.row]
        //cell.pest = pestCell[indexPath.item]
        //print(farmCell[indexPath.item].pestCount?.count)
        //print(cell.data?.species!.count)
//        //let pestNum = self.farmCell[indexPath.row].pestCount?.count
       
//        //cell.loaction = "123"
        //cell.test = "test"
        //print("location")
        //cell.backgroundColor = UIColor.white
        
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
