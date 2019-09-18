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
    
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var townText: UITextField!
    
    
    
    var locations: [String: Dictionary <String, Int>] = [:]
    var textField = UITextField(frame: CGRect(x: 5, y: 40, width: 100, height: 100))
    
    var city = "嘉義縣"
    var town = "朴子市"
    var postCode = "613"
    //var date: String?
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentHumid: UILabel!
    @IBOutlet weak var currentRain: UILabel!
    @IBOutlet weak var currentWind: UILabel!
    //@IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var firstDay: UIView!
    @IBOutlet weak var secondDay: UIView!
    @IBOutlet weak var thirdDay: UIView!
    @IBOutlet weak var fourthDay: UIView!
    @IBOutlet weak var fifthDay: UIView!
    
    
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

        getPostalCode()
        setViews()
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
        view.layer.shadowRadius = 2.5
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
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
                
                //let time = json["output"]["data"][0]["obsTime"].stringValue.components(separatedBy: ["T"])
                let humid = Int(json["output"]["data"][0]["humd"].doubleValue*100)
                //print(json["output"]["data"][0]["humd"].String)
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
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
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
                    self.setForecasts(data: dateArray)
                }

                
            }
            catch let jsonError{
                print(jsonError)
            }
            
            }.resume()
    }
    func setViews(){
        let views = [self.todayView, self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay]
        for view in views{
            drawShadow(view: view!)
            view!.layer.cornerRadius = 2
            //view?.backgroundColor = .cyan
        }
    }
    func setForecasts(data: [(String, String)]){
        let views = [self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay]
        //print(data)
        for i in 0..<5{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = formatter.date(from: data[2*i].0)
            formatter.dateFormat = "yyyy-MM-dd"
            let resultDate = formatter.string(from: date!)
            
            let dayLabel = UILabel(frame: CGRect(x: views[i]!.frame.width-100, y: (views[i]!.frame.height - 20) / 2, width: 50, height: 20))
            let nightLabel = UILabel(frame: CGRect(x: views[i]!.frame.width-50, y: (views[i]!.frame.height - 20) / 2, width: 50, height: 20))
            let dateLabel = UILabel(frame: CGRect(x: 10, y: (views[i]!.frame.height - 20) / 2, width: 150, height: 20))
            views[i]?.addSubview(dayLabel)
            views[i]?.addSubview(nightLabel)
            views[i]?.addSubview(dateLabel)
            
            dateLabel.text = resultDate
            dayLabel.text = data[i*2+1].1
            nightLabel.text = data[i*2].1
            
            dayLabel.textColor = .black
            nightLabel.textColor = .gray
            
            
        }
    }
    

}
