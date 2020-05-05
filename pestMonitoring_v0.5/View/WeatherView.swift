//
//  WeatherView.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/11/13.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class WeatherView: UIView{
    
    var city: String?
    
    let titleLabel = UILabel()
    
    let tempLabel = UILabel()
    let humdLabel = UILabel()
    let rainLabel = UILabel()
    let windLabel = UILabel()
    
    var forecastViews = [UILabel]()
    var currentWeatherLabels = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        //self.layer.borderWidth = 0.5
        //self.drawShadow()
        print(self.frame.width)
        self.setCurrentLabels()
        setEnvIcon(view: self)
        
        
        //self.getCurrentWeather()
    }
    func setEnvIcon(view: UIView){
        let humdView = UIImageView()
        humdView.image = UIImage(named: "HomeIcon_Humid")
        humdView.contentMode = .scaleAspectFill
        humdView.clipsToBounds = true
        humdView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(humdView)
        view.addConstraints([
            NSLayoutConstraint(item: humdView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: humdView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: humdView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: humdView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        let rainView = UIImageView()
        rainView.image = UIImage(named: "rain")
        rainView.contentMode = .scaleAspectFill
        rainView.clipsToBounds = true
        rainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rainView)
        view.addConstraints([
            NSLayoutConstraint(item: rainView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rainView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: rainView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: rainView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
        let windView = UIImageView()
        windView.image = UIImage(named: "windspeed")
        windView.contentMode = .scaleAspectFill
        windView.clipsToBounds = true
        windView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(windView)
        view.addConstraints([
            NSLayoutConstraint(item: windView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: windView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: windView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: windView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            ])
    }
    func setCurrentLabels(){
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.text = "City"
        titleLabel.font = UIFont.systemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        self.addConstraints([NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
                             NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)])
        
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        //tempLabel.text = "22"
        tempLabel.font = UIFont.systemFont(ofSize: 22)
        tempLabel.textColor = .red
        tempLabel.textAlignment = .center
        self.addSubview(tempLabel)
        self.addConstraints([NSLayoutConstraint(item: tempLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: tempLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 50),
                             NSLayoutConstraint(item: tempLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
                             NSLayoutConstraint(item: tempLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)])
        
        rainLabel.translatesAutoresizingMaskIntoConstraints = false
        //rainLabel.text = "22"
        rainLabel.textAlignment = .center
        self.addSubview(rainLabel)
        self.addConstraints([NSLayoutConstraint(item: rainLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: rainLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 150),
                             NSLayoutConstraint(item: rainLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                             NSLayoutConstraint(item: rainLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)])
        humdLabel.translatesAutoresizingMaskIntoConstraints = false
        //humdLabel.text = "22"
        humdLabel.textAlignment = .center
        self.addSubview(humdLabel)
        self.addConstraints([NSLayoutConstraint(item: humdLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20),
                             NSLayoutConstraint(item: humdLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 150),
                             NSLayoutConstraint(item: humdLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                             NSLayoutConstraint(item: humdLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)])
        windLabel.translatesAutoresizingMaskIntoConstraints = false
        //windLabel.text = "22"
        windLabel.textAlignment = .center
        self.addSubview(windLabel)
        self.addConstraints([NSLayoutConstraint(item: windLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -30),
                             NSLayoutConstraint(item: windLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 150),
                             NSLayoutConstraint(item: windLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 60),
                             NSLayoutConstraint(item: windLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)])
        
        
    }
    func setForecastViews( x: CGFloat, date: String, highTemp: String, lowTemp: String){
        let forecast = UILabel()
        //forecast.backgroundColor = .cyan
        forecast.numberOfLines = 0
        forecast.translatesAutoresizingMaskIntoConstraints = false
        let line1 = date
        let line2 = highTemp
        let line3 = lowTemp
        
        
        let attributeString = NSMutableAttributedString(string: line1 + "\n" + line2 + "\n" + line3)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSRange(location: line1.count+line2.count+1, length: line3.count+1))
        forecast.textAlignment = NSTextAlignment.center
        forecast.attributedText = attributeString
        
        self.addSubview(forecast)
        self.addConstraints([NSLayoutConstraint(item: forecast, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: (self.bounds.width/5)*x),
                             NSLayoutConstraint(item: forecast, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 200),
                             NSLayoutConstraint(item: forecast, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (self.bounds.width/5)),
                             NSLayoutConstraint(item: forecast, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100)])
        forecastViews.append(forecast)
    }
    func getCurrentWeather(view: UIView){
        let spinner = Spinner()
        let spinnerView = spinner.setSpinnerView(view: view)
        
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_local_weather.php?city=" + self.city!.split(separator: " ")[0] + "%20" + self.city!.split(separator: " ")[1])
        //print(self.city)
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                
                DispatchQueue.main.async {
                    if json["DATES"].arrayObject != nil{
                        let dates = json["DATES"].arrayObject as! [String]
                        let temp = json["TPREDS"].arrayObject as! [String]
                        var newDates = [String]()
                        self.titleLabel.text = NSLocalizedString( self.city!, comment: "city")
                        self.tempLabel.text = json["T"].stringValue + " °C"
                        self.humdLabel.text = json["H"].stringValue + " %RH"
                        self.rainLabel.text = json["RPOP"].stringValue + "%"
                        self.windLabel.text = json["WS"].stringValue + "m/s"
                        for date in dates{
                            let newDate = String(date.split(separator: "-")[1] + "-" + date.split(separator: "-")[2])
                            newDates.append(newDate)
                        }
                        if self.forecastViews.count>0{
                            for view in self.forecastViews{
                                view.removeFromSuperview()
                            }
                        }
                        for i in 0..<5{
                            
                            self.setForecastViews(x: CGFloat(i), date: newDates[2*i], highTemp: temp[2*i], lowTemp: temp[2*i+1])
                        }
                        //self.Date.text = time[0]
                        
                    }
                    spinnerView.removeFromSuperview()
                }
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


