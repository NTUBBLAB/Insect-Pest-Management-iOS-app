//
//  CollectionViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/26.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    let locations = ["CHIAYI_GH", "YUNLIN_GH", "TAICHUNGSB_GH", "TAINANMO_FF"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"
        navigationItem.titleView?.backgroundColor = UIColor.blue
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(FarmSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        //homeCollectionView.register(FarmSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let farmDetail = storyboard?.instantiateViewController(withIdentifier: "FarmDetailViewController") as? FarmDetailViewController
        let pager = storyboard?.instantiateViewController(withIdentifier: "PagerMenu") as? PagerTabStrip
        farmDetail?.name = locations[indexPath.row]
        pager?.location = locations[indexPath.row]
        self.navigationController?.pushViewController(pager!, animated: true)
    }
    override func collectionView(_ collcetionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let cell = collcetionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FarmSummaryCollectionViewCell

        cell.farmName?.text = locations[indexPath.row]
        cell.farmLabel = locations[indexPath.row]
        let currentPest = Pest(location: locations[indexPath.row])
        
        currentPest.getCurrentPest(){ (result1, result2) in
            DispatchQueue.main.async {
                cell.species = result1
                cell.count = result2
                //cell.test = result1
                //cell.species.append("Thrips")
                print("RESULT 1: ")
                print(result1)
                //print(result2)
            }
            
        }
        let currentEnv = Environment(location: locations[indexPath.row])

        currentEnv.getCurrentEnv(location: locations[indexPath.row]) { (result) in
            DispatchQueue.main.async {
                cell.tempLabel?.text = result[0] + " °C"
                cell.humidLabel?.text = result[1] + " %"
                cell.lightLabel?.text = result[2] + " lux"
                cell.currenctEnv = [result[0] + " °C", result[1] + " %", result[2] + " lux"]
                //cell.loaction = "1234"
            }
        }
        cell.loaction = "123"
        //cell.test = "test"
        print("location")
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
        
        return CGSize(width: view.frame.width, height: 360)
    }
    
    
 
}
