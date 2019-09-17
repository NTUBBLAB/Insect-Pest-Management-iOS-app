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
    
    var city: String?
    var town: String?
    var postCode: String?
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentHumid: UILabel!
    @IBOutlet weak var currentRain: UILabel!
    @IBOutlet weak var Date: UILabel!
    
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
            for town in locations[self.city!]!{
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
            for town in locations[self.city!]!{
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
            for town in locations[self.city!]!{
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
            self.postCode = String(locations[self.city!]![self.town!]!)
            getCurrentWeather(postalCode: self.postCode!)
        }
        
    }
    @objc func donePicker() {
        textField2.resignFirstResponder()
        townText.resignFirstResponder()
    }
    
    let navItemHeight = 0
    //let scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
    }

    func drawShadow(view: UIView){
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
        
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
                print(json)
                self.locations = json["output"]["data"].dictionaryObject! as! [String : Dictionary<String, Int>]
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
            
        
    }
    func getCurrentWeather(postalCode: String){
        
        let url = URL(string: "https://agriapi.tari.gov.tw/api/CWB_ObsWeathers/observation?postalCode=" + postalCode + "&projectkey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcm9qZWN0bmFtZSI6IlBlc3RfMDEiLCJuYW1lIjoiTlRVQkJMQUJfUGVzdCIsImlhdCI6MTU1NzEwNjQxMX0.u3udopC3XGpV0sRy_olvuFx-mTPnrUY5c4E0y1bgx0A")
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                DispatchQueue.main.async {
                    self.currentTemp.text = json["output"]["data"][0]["temp"].stringValue
                    self.currentHumid.text = json["output"]["data"][0]["humd"].stringValue
                }
                
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
            }.resume()
    }
    func setViews(){
        let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.white
            v.contentSize = CGSize(width: view.frame.width, height: 1200)
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
        
        setTodayWeather(scrollView: scrollView)
        setForecasts(scrollView: scrollView)
    }
    func setTodayWeather(scrollView: UIScrollView){
        let currentView = UIView(frame: CGRect(x: 5, y: navItemHeight+10, width: Int(view.frame.width - 10), height: 300))
        let textField = UITextField(frame: CGRect(x: 5, y: 5, width: 100, height: 20))
        
        currentView.backgroundColor = .blue
        drawShadow(view: currentView)
        scrollView.addSubview(currentView)
        currentView.addSubview(textField)
    }
    func setForecasts(scrollView: UIScrollView){
        for i in 0..<6 {
            let width = view.frame.width
            let forecastView = UIView(frame: CGRect(x: 5, y: navItemHeight + 320+120*i, width: Int(width - 10), height: 100))
            forecastView.backgroundColor = .green
            drawShadow(view: forecastView)
            scrollView.addSubview(forecastView)
        }
    }

}
