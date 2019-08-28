//
//  EnvironViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/7/30.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class EnvironViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //@IBOutlet weak var homeCollectionView: UICollectionView!
    
    
    let locations = ["CHIAYI_GH", "YUNLIN_GH", "TAICHUNGSB_GH", "TAINANMO_FF"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"
        //homeCollectionView.register(FarmSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let farmDetail = storyboard?.instantiateViewController(withIdentifier: "FarmDetailViewController") as? FarmDetailViewController
        let pager = storyboard?.instantiateViewController(withIdentifier: "PagerMenu") as? PagerTabStrip
        farmDetail?.name = locations[indexPath.row]
        pager?.location = locations[indexPath.row]
        self.navigationController?.pushViewController(pager!, animated: true)
    }
    func collectionView(_ collcetionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let cell = collcetionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FarmSummaryCollectionViewCell
        
        cell.farmName.text = locations[indexPath.row]
        
        let currentEnv = Environment(location: locations[indexPath.row])
        
        currentEnv.getCurrentEnv(location: locations[indexPath.row]) { (result) in
            DispatchQueue.main.async {
                cell.tempLabel.text = result[0] + " °C"
                cell.humidLabel.text = result[1] + " %"
                cell.lightLabel.text = result[2] + " lux"
            }
        }
        
        let currentPest = Pest(location: locations[indexPath.row])
        currentPest.getCurrentPest(){ (result1, result2) in
            //cell.species = result1
            print(result1)
            print(result2)
        }
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
