//
//  FarmSummaryCollectionViewCell.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/7/31.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class FarmCell: NSObject{
    var currentEnv: [String]?
    var farmlabel: String?
    var species: [String]?
    var pestCount: [Int]?
    var alarm: Dictionary<String, [Int]>?
    var pestCheck = 1
    
}
class PestCell: NSObject{
    
    var labels = [UILabel]()
}

class FarmSummaryCollectionViewCell: UICollectionViewCell {
    
    
    var loaction: String!
    
    var pestSpecies: Int!
    var data: FarmCell? {
        didSet{
            for view in contentView.subviews{
                view.removeFromSuperview()
            }
            setupCell()
            if data?.currentEnv != nil{
                setEnv(data: (data?.currentEnv)!)
            }
            
            if data?.farmlabel != nil{
                setFarmName(farmName: (data?.farmlabel)!)
            }
            if data?.pestCheck == 1{
                if data?.pestCount != nil{
                    if data?.pestCount?.count != 0{
                        setPestCount(counts: (data?.pestCount)!)
                    }
                    
                }
                if data?.species != nil{
                    if data?.species?.count != 0{
                        setPestLabel(species: (data?.species)!)
                    }
                }
                if data?.species != nil{
                    if data?.alarm != nil{
                        if data?.pestCount != nil{
                            setPestAlarm(alarm: (data?.alarm)!, count: (data?.pestCount)!, spec: (data?.species)!)
                        }
                    }
                }
            }
            else{
                setPestException()
            }
        }
    }
    var pest: PestCell? {
        didSet {
            
        }
    }

    let farmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    let tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.red
        return label
    }()
    let humidLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.blue
        return label
    }()
    let lightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.orange
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for views in contentView.subviews{
            views.removeFromSuperview()
        }
        setupCell()
    }
    func setupCell(){
        backgroundColor = UIColor.white
        setTempImage()
        setHumidImage()
        setLightImage()
        
    }
    func setEnv(data: [String]){
        let labelArray = [tempLabel, humidLabel, lightLabel]
        //let colorTabel = [UIColor.red, UIColor.blue, UIColor.orange]
        let labelDis = (Int(contentView.frame.width) - 160)/2
        for i in 0..<labelArray.count{
            labelArray[i].text = data[i]
            contentView.addSubview(labelArray[i])
            contentView.addConstraints([
                NSLayoutConstraint(item: labelArray[i], attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: CGFloat(80+labelDis*i)),
                NSLayoutConstraint(item: labelArray[i], attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -50),
                NSLayoutConstraint(item: labelArray[i], attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                NSLayoutConstraint(item: labelArray[i], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        }
        
        
    }
    

    func setPestCount(counts: [Int]){
        //let countLabelDis = Int(contentView.frame.width)/counts.count
        for i in 0..<counts.count {
            let countLabel = UILabel()
            
            countLabel.text = String(counts[i])
            countLabel.textColor = UIColor.black
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            countLabel.textAlignment = NSTextAlignment.center
            
            contentView.addSubview(countLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: countLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: CGFloat(50*i)),
                NSLayoutConstraint(item: countLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                NSLayoutConstraint(item: countLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        }
    }
    func setPestLabel(species: [String]){
        
        // let speciesLabelDis = Int(contentView.frame.height)/species.count
        
        
        for i in 0..<species.count {
            let speciesLabel = UILabel()
            
            speciesLabel.text = species[i]
            speciesLabel.textColor = UIColor.black
            speciesLabel.translatesAutoresizingMaskIntoConstraints = false
            speciesLabel.textAlignment = NSTextAlignment.left
            
            contentView.addSubview(speciesLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: speciesLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 20),
                NSLayoutConstraint(item: speciesLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: CGFloat(50*i)),
                NSLayoutConstraint(item: speciesLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                NSLayoutConstraint(item: speciesLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        }
    }
    func setPestAlarm(alarm: Dictionary<String, [Int]>, count: [Int], spec: [String]){
        for i in 0..<alarm.count {
            let alarmLabel = UILabel()
            
            let level = alarm[spec[i]]
            alarmLabel.textColor = UIColor.black
            if count[i] <= level![1]{
                alarmLabel.text = "低"
                alarmLabel.backgroundColor = .green
                
            }
            else if (count[i] > level![1]) && (count[i] < level![2]){
                alarmLabel.text = "警戒"
                alarmLabel.backgroundColor = .blue
                alarmLabel.textColor = UIColor.white
            }
            else if (count[i] > level![2]) && (count[i] < level![3]){
                alarmLabel.text = "較高"
                alarmLabel.backgroundColor = .yellow
            }
            else{
                alarmLabel.text = "嚴重"
                alarmLabel.backgroundColor = .red
            }
            //speciesLabel.text = species[i]
            
            alarmLabel.translatesAutoresizingMaskIntoConstraints = false
            alarmLabel.textAlignment = NSTextAlignment.center
            
            contentView.addSubview(alarmLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: alarmLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: contentView.frame.width - 70),
                NSLayoutConstraint(item: alarmLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: CGFloat(50*i)),
                NSLayoutConstraint(item: alarmLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
                NSLayoutConstraint(item: alarmLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
                ])
        }
    }
    func setPestException(){
        let exceptionLabel = UILabel()
        exceptionLabel.text = "目前沒有可顯示的害蟲資料"
        exceptionLabel.translatesAutoresizingMaskIntoConstraints = false
        exceptionLabel.textAlignment = .center
        contentView.addSubview(exceptionLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: exceptionLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: exceptionLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: exceptionLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: exceptionLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
        ])
        
    }
    func setFarmName(farmName: String){
        farmLabel.text = farmName
        contentView.addSubview(farmLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: farmLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: farmLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -150),
            NSLayoutConstraint(item: farmLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
            NSLayoutConstraint(item: farmLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
        ])
        
    }
    func setTempImage(){
        let tempImageView = UIImageView()
        tempImageView.image = UIImage(named: "HomeIcon_Temp")
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tempImageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: tempImageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: CGFloat(80)),
            NSLayoutConstraint(item: tempImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: tempImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: tempImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
        ])
    }
    func setHumidImage(){
        let humidImageView = UIImageView()
        humidImageView.image = UIImage(named: "HomeIcon_Humid")
        humidImageView.contentMode = .scaleAspectFill
        humidImageView.clipsToBounds = true
        humidImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(humidImageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: humidImageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: humidImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: humidImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: humidImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
    }
    func setLightImage(){
        let lightImageView = UIImageView()
        lightImageView.image = UIImage(named: "HomeIcon_Light")
        lightImageView.contentMode = .scaleAspectFill
        lightImageView.clipsToBounds = true
        lightImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lightImageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: lightImageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -80),
            NSLayoutConstraint(item: lightImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: lightImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: lightImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
