//
//  WeatherController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/16.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class WeatherController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var textField2 = UITextField()
    var townText = UITextField()
    
    
    
    var locations: [String: Dictionary <String, Int>] = [:]
    var textField = UITextField(frame: CGRect(x: 5, y: 40, width: 100, height: 100))
    
    var city = "嘉義縣"
    var town = "六腳鄉"
    var postCode = "615"
    //var date: String?
    
    //let mainView =  UIView()
    let currentTemp = UILabel()
    var currentHumid = UILabel()
    var currentRain = UILabel()
    var currentWind = UILabel()
    //@IBOutlet weak var dateLabel: UILabel!
    
    var todayView = UIView()
    var firstDay = UIView()
    var secondDay = UIView()
    var thirdDay = UIView()
    var fourthDay = UIView()
    var fifthDay = UIView()
    
    let humdImg = UIImageView()
    let rainImg = UIImageView()
    let windImg = UIImageView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var cities = [String]()
        var towns = [String]()
        for city in locations{
            cities.append(city.key)
        }
        
        if self.city != nil{
            for town in locations[self.city]!{
                towns.append(town.key)
            }
        }
        
        if component == 0{
            return cities.count
        }
        else{
            return towns.count
        }
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var cities = [String]()
        var towns = [String]()
        for city in locations{
            cities.append(city.key)
        }
        
        if self.city != nil{
            for town in locations[self.city]!{
                towns.append(town.key)
            }
            
        }
        if component == 0{
            pickerView.reloadComponent(1)
            return cities[row]
            
        }
        else{
           return towns[row]
        }
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        var cities = [String]()
        var towns = [String]()
        
        for city in locations{
            cities.append(city.key)
        }
        
        if self.city != nil{
            for town in locations[self.city]!{
                towns.append(town.key)
            }
        }
        if component == 0{
            self.textField2.text = cities[row]
            self.city = cities[row]
            pickerView.reloadComponent(1)
        }
        else{
            self.townText.text = towns[row]
            self.town = towns[row]
            self.postCode = String(locations[self.city]![self.town]!)
            getCurrentWeather(postalCode: self.postCode)
            getPrecipitation(postalCode: self.postCode)
            print(self.postCode)
            
        }
        
    }
    @objc func donePicker() {
        textField2.resignFirstResponder()
        townText.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.white
            v.contentSize = CGSize(width: view.frame.width, height: 1000)
            v.isScrollEnabled = true
            return v
        }()
        view.addSubview(scrollView)
        
        view.backgroundColor = .white
        
        view.addConstraints(
            [NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.frame.width),
             NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height)]
        )
        
        setViews(scrollView: scrollView)
        getPostalCode()
        
        let picker = UIPickerView()
        picker.backgroundColor = .white

        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        textField2.inputView = picker
        textField2.inputAccessoryView = toolBar
        picker.delegate = self
        
        townText.inputView = picker
        townText.inputAccessoryView = toolBar
        
        

        self.textField2.text = self.city
        self.townText.text = self.town
        //self.postCode = "613"
        getCurrentWeather(postalCode: self.postCode)
        getPrecipitation(postalCode: self.postCode)
        getForecasts()
    }

    func drawShadow(view: UIView){
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 1
        
        view.layer.shadowPath = UIBezierPath(rect: view.frame).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    func getPostalCode(){
        let url = URL(string: "https://agriapi.tari.gov.tw/api/CWB_PreWeathers/allPostalCode?projectkey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0bmFtZSI6IlBlc3RfMDEiLCJuYW1lIjoiTlRVQkJMQUJfUGVzdCIsImlhdCI6MTU1NzEwNjQxMX0.u3udopC3XGpV0sRy_olvuFx-mTPnrUY5c4E0y1bgx0A")
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                //print(json)
                self.locations = json["output"]["data"].dictionaryObject! as! [String : Dictionary<String, Int>]
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
            
        
    }
    func getCurrentWeather(postalCode: String){
        
        let url = URL(string: "https://agriapi.tari.gov.tw/api/CWB_ObsWeathers/observation?postalCode=" + postalCode + "&hours=1&projectkey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0bmFtZSI6IlBlc3RfMDEiLCJuYW1lIjoiTlRVQkJMQUJfUGVzdCIsImlhdCI6MTU1NzEwNjQxMX0.u3udopC3XGpV0sRy_olvuFx-mTPnrUY5c4E0y1bgx0A")
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                //print(json)
                
                let humid = Int(json["output"]["data"][0]["humd"].doubleValue*100)
                
                DispatchQueue.main.async {
                    self.currentTemp.text = json["output"]["data"][0]["temp"].stringValue + " °C"
                    self.currentHumid.text = String(humid) + " %RH"
                    self.currentWind.text = json["output"]["data"][0]["wdsd"].stringValue + " m/s"
                    //self.Date.text = time[0]
                }
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
            }.resume()
    }
    func getPrecipitation(postalCode: String){
        let eleName = "PoP12h"
        let url = URL(string: "https://agriapi.tari.gov.tw/api/CWB_PreWeathers/predictions?postalCode=" + postalCode + "&eleName=" + eleName + "&projectkey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0bmFtZSI6IlBlc3RfMDEiLCJuYW1lIjoiTlRVQkJMQUJfUGVzdCIsImlhdCI6MTU1NzEwNjQxMX0.u3udopC3XGpV0sRy_olvuFx-mTPnrUY5c4E0y1bgx0A")
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                let pop = json["output"]["data"][0]["eleValue"].stringValue + "%"
                //print(json)
                DispatchQueue.main.async {
                    self.currentRain.text = pop
                }
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
    }
    func getForecasts(){
        let url = URL(string: "https://agriapi.tari.gov.tw/api/CWB_PreWeathers/predictions?postalCode=" + self.postCode + "&eleName=" + "T" + "&projectkey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0bmFtZSI6IlBlc3RfMDEiLCJuYW1lIjoiTlRVQkJMQUJfUGVzdCIsImlhdCI6MTU1NzEwNjQxMX0.u3udopC3XGpV0sRy_olvuFx-mTPnrUY5c4E0y1bgx0A")
        let spinner = Spinner()
        let spinnerView = spinner.setSpinnerView(view: view)
        //let request = URLSession.shared
    
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                let array = json["output"]["data"]
                var dateArray = [(String, String)]()
                
                //print(array)
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let result = dateFormatter.string(from: today) + "T23:59:59.000Z"
                
                for dict in array{
                    //print(dict.1)
                    if (dict.1.dictionaryObject!["startTime"] as! String) > result {
                        dateArray.append((dict.1.dictionaryObject!["startTime"] as! String, dict.1.dictionaryObject!["eleValue"] as! String) )
                    }
                }
                //print(dateArray)
                dateArray = dateArray.sorted(by: {$0.0 < $1.0})
                DispatchQueue.main.async {
                    spinnerView.removeFromSuperview()
                    self.setForecasts(data: dateArray)
                }

                
            }
            catch let jsonError{
                print(jsonError)
            }
            
            }.resume()
    }
    func setViews(scrollView: UIScrollView){
        //let mainView = UIView(frame: CGRect(x: 10, y: 10, width: view.frame.width-20, height: 350))
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.backgroundColor = .white
        mainView.layer.borderWidth = 1
        mainView.layer.cornerRadius = 2
        scrollView.addSubview(mainView)
        scrollView.addConstraints([NSLayoutConstraint(item: mainView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: mainView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 20),
                             NSLayoutConstraint(item: mainView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: (scrollView.frame.width-20)),
                             NSLayoutConstraint(item: mainView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 300)
                             ])
        
        self.currentTemp.translatesAutoresizingMaskIntoConstraints = false
        self.currentTemp.backgroundColor = .white
        self.currentTemp.textAlignment = .center
        self.currentTemp.textColor = .red
        self.currentTemp.font = self.currentTemp.font.withSize(30)
        mainView.addSubview(self.currentTemp)
        mainView.addConstraints([NSLayoutConstraint(item: self.currentTemp, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1, constant: -10),
                                 NSLayoutConstraint(item: self.currentTemp, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: self.currentTemp, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 150),
                                 NSLayoutConstraint(item: self.currentTemp, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200)])
        
        self.textField2.translatesAutoresizingMaskIntoConstraints = false
        self.textField2.textAlignment = .center
        self.textField2.borderStyle = UITextField.BorderStyle.roundedRect
        mainView.addSubview(self.textField2)
        mainView.addConstraints([NSLayoutConstraint(item: self.textField2, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: self.textField2, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 10, constant: 10),
                                 NSLayoutConstraint(item: self.textField2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
                                 NSLayoutConstraint(item: self.textField2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)])
        self.townText.translatesAutoresizingMaskIntoConstraints = false
        self.townText.textAlignment = .center
        self.townText.borderStyle = UITextField.BorderStyle.roundedRect
        mainView.addSubview(self.townText)
        mainView.addConstraints([NSLayoutConstraint(item: self.townText, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: self.townText, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1, constant: 100),
                                 NSLayoutConstraint(item: self.townText, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
                                 NSLayoutConstraint(item: self.townText, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)])
        self.currentHumid.translatesAutoresizingMaskIntoConstraints = false
        self.currentHumid.textAlignment = .center
        mainView.addSubview(self.currentHumid)
        mainView.addConstraints([NSLayoutConstraint(item: self.currentHumid, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: self.currentHumid, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -10),
                                 NSLayoutConstraint(item: self.currentHumid, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30),
                                 NSLayoutConstraint(item: self.currentHumid, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)])
        self.currentRain.translatesAutoresizingMaskIntoConstraints = false
        self.currentRain.textAlignment = .center
        mainView.addSubview(self.currentRain)
        mainView.addConstraints([NSLayoutConstraint(item: self.currentRain, attribute: .centerX, relatedBy: .equal, toItem: mainView, attribute: .centerX, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: self.currentRain, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -10),
                                 NSLayoutConstraint(item: self.currentRain, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30),
                                 NSLayoutConstraint(item: self.currentRain, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)])
        self.currentWind.translatesAutoresizingMaskIntoConstraints = false
        self.currentWind.textAlignment = .center
        mainView.addSubview(self.currentWind)
        mainView.addConstraints([NSLayoutConstraint(item: self.currentWind, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1, constant: -10),
                                 NSLayoutConstraint(item: self.currentWind, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -10),
                                 NSLayoutConstraint(item: self.currentWind, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30),
                                 NSLayoutConstraint(item: self.currentWind, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)])
        
        self.humdImg.translatesAutoresizingMaskIntoConstraints = false
        self.humdImg.contentMode = .scaleAspectFill
        self.humdImg.image = UIImage(named: "HomeIcon_Humid")
        self.humdImg.clipsToBounds = true
        mainView.addSubview(self.humdImg)
        mainView.addConstraints([NSLayoutConstraint(item: self.humdImg, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1, constant: 35),
                                 NSLayoutConstraint(item: self.humdImg, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -60),
                                 NSLayoutConstraint(item: self.humdImg, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
                                 NSLayoutConstraint(item: self.humdImg, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50)])
        self.rainImg.translatesAutoresizingMaskIntoConstraints = false
        self.rainImg.image = UIImage(named: "rain")
        self.rainImg.contentMode = .scaleAspectFill
        self.rainImg.clipsToBounds = true
        mainView.addSubview(self.rainImg)
        mainView.addConstraints([NSLayoutConstraint(item: self.rainImg, attribute: .centerX, relatedBy: .equal, toItem: mainView, attribute: .centerX, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: self.rainImg, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -60),
                                 NSLayoutConstraint(item: self.rainImg, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
                                 NSLayoutConstraint(item: self.rainImg, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50)])
        self.windImg.translatesAutoresizingMaskIntoConstraints = false
        self.windImg.image = UIImage(named: "windspeed")
        self.windImg.contentMode = .scaleAspectFill
        self.windImg.clipsToBounds = true
        mainView.addSubview(self.windImg)
        mainView.addConstraints([NSLayoutConstraint(item: self.windImg, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1, constant: -35),
                                 NSLayoutConstraint(item: self.windImg, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: -60),
                                 NSLayoutConstraint(item: self.windImg, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
                                 NSLayoutConstraint(item: self.windImg, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50)])
        
        let views = [self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay]

        for i in 0..<views.count{
            //drawShadow(view: view)
            views[i].translatesAutoresizingMaskIntoConstraints = false
            views[i].layer.borderWidth = 1
            views[i].layer.cornerRadius = 2
            //views[i].backgroundColor = .gray
            
            scrollView.addSubview(views[i])
            scrollView.addConstraint(NSLayoutConstraint(item: views[i], attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: views[i], attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: CGFloat(330+60*i)))
            scrollView.addConstraint(NSLayoutConstraint(item: views[i], attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: (scrollView.frame.width-20)))
            scrollView.addConstraint(NSLayoutConstraint(item: views[i], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))
            
            //view.backgroundColor = .cyan
        }
    }
    func setForecasts(data: [(String, String)]){
        let views = [self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay]
        
        for i in 0..<5{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = formatter.date(from: data[2*i].0)
            formatter.dateFormat = "yyyy-MM-dd"
            let resultDate = formatter.string(from: date!)
            
            let dayLabel = UILabel(frame: CGRect(x: views[i].frame.width-100, y: (views[i].frame.height - 20) / 2, width: 50, height: 20))
            let nightLabel = UILabel(frame: CGRect(x: views[i].frame.width-50, y: (views[i].frame.height - 20) / 2, width: 50, height: 20))
            let dateLabel = UILabel(frame: CGRect(x: 10, y: (views[i].frame.height - 20) / 2, width: 150, height: 20))
            
            views[i].addSubview(dayLabel)
            views[i].addSubview(nightLabel)
            views[i].addSubview(dateLabel)
            
            dateLabel.text = resultDate
            dayLabel.text = data[i*2+1].1
            nightLabel.text = data[i*2].1
            
            dayLabel.textColor = .black
            nightLabel.textColor = .gray
            
        }
    }
    
}
