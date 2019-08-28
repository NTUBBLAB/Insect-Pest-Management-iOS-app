//
//  FarmSummaryCollectionViewCell.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/7/31.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class FarmSummaryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var farmName: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var pestLabel1: UILabel!
    
    var loaction: String!
    var currenctEnv: [String]? {
        didSet {
            setEnv(data: currenctEnv!)
        }
    }
    var farmLabel: String? {
        didSet {
            setFarmName(farmName: farmLabel!)
        }
    }
    var species: [String]? {
        didSet {
            setPestLabel(species: species!)
        }
    }
    var count: [Int]? {
        didSet {
            setPestCount(counts: count!)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    func setupCell(){
        backgroundColor = UIColor.white
        setTempImage()
        setHumidImage()
        setLightImage()
    }
    func setEnv(data: [String]){
        //let tempLabel = UILabel()
        //let humidLabel = UILabel()
        //let lightLabel = UILabel()
        let colorTabel = [UIColor.red, UIColor.blue, UIColor.orange]
        let labelDis = (Int(contentView.frame.width) - 160)/2
        for i in 0..<data.count{
            let dataLabel = UILabel()
            dataLabel.text = data[i]
            dataLabel.textAlignment = NSTextAlignment.center
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            dataLabel.textColor = colorTabel[i]
            contentView.addSubview(dataLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: dataLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: CGFloat(80+labelDis*i)),
                NSLayoutConstraint(item: dataLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: -50),
                NSLayoutConstraint(item: dataLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                NSLayoutConstraint(item: dataLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        }
        
        
    }
    func setPestCount(counts: [Int]){
        let countLabelDis = Int(contentView.frame.width)/counts.count
        for i in 0..<counts.count {
            let countLabel = UILabel()
            
            countLabel.text = String(counts[i])
            countLabel.textColor = UIColor.black
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            countLabel.textAlignment = NSTextAlignment.center
            
            contentView.addSubview(countLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: countLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: CGFloat(countLabelDis*i)),
                NSLayoutConstraint(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 50),
                NSLayoutConstraint(item: countLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                NSLayoutConstraint(item: countLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
                ])
        }
    }
    func setPestLabel(species: [String]){
        let speciesLabelDis = Int(contentView.frame.width)/species.count
        for i in 0..<species.count {
            let speciesLabel = UILabel()
            
            speciesLabel.text = species[i]
            speciesLabel.textColor = UIColor.black
            speciesLabel.translatesAutoresizingMaskIntoConstraints = false
            speciesLabel.textAlignment = NSTextAlignment.center
            
            contentView.addSubview(speciesLabel)
            contentView.addConstraints([
                NSLayoutConstraint(item: speciesLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: CGFloat(speciesLabelDis*i)),
                NSLayoutConstraint(item: speciesLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: speciesLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                NSLayoutConstraint(item: speciesLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        }
    }
    func setFarmName(farmName: String){
        let farmLabel = UILabel()
        farmLabel.text = farmName
        farmLabel.textAlignment = NSTextAlignment.center
        farmLabel.translatesAutoresizingMaskIntoConstraints = false
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
