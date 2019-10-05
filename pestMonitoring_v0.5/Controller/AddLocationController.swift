//
//  AddLocationController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/20.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddLocationController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let array = ["溫室", "戶外"]
        return array[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let array = ["溫室", "戶外"]
        inOut.text = array[row]
    }
    
    @IBOutlet weak var farmCode: UITextField!
    
    @IBOutlet weak var inOut: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var crops: UITextField!
    
    @IBOutlet weak var numberOfNodes: UITextField!
    
    @IBOutlet weak var farmSize: UITextField!
    
    @IBOutlet weak var comments: UITextView!
    
    @IBOutlet weak var saveResults: UIButton!
    
    @IBAction func actionSave(_ sender: Any) {
        if(checkTextField() == true){
            //print("done")
            var code = farmCode.text
            if inOut.text == "溫室"{
                code = code! + "_GH"
            }
            else{
                code = code! + "_FF"
            }
            let postJson = ["name": code, "real_name": location.text, "city": city.text, "crops": crops.text, "actual_size": farmSize.text, "nodes": numberOfNodes.text]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: postJson)
            let loginURL = URL(string: "http://140.112.94.123:20000/PEST_DETECT/account/add_location.php")
            var request = URLRequest(url: loginURL!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            //print("GET Location")
            
            let spinner = Spinner()
            let spinnerView = spinner.setSpinnerView(view: view)
            
            URLSession.shared.dataTask(with: request){ (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    print(error!)
                    return
                }
                do{
                    let json = try JSON(data: data!)
                    print(json)
                    if json["status"] == 0{
                        DispatchQueue.main.async {
                            spinnerView.removeFromSuperview()
                            let alert = UIAlertController(title: "Success!", message: "Successfully created new account", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {action in
                                print("123")
                                //self.performSegue(withIdentifier: "toLogin", sender: self)
                                
                            }
                            ))
                            
                            self.present(alert, animated: true)
                        }
                            
                    }
                    
                }
                catch let jsonerror{
                    print(jsonerror)
                    
                }
                
            }.resume()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setPicker()
        comments.layer.borderWidth = 1
        // Do any additional setup after loading the view.
    }
    func setPicker(){
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
        
        inOut.inputView = picker
        inOut.inputAccessoryView = toolBar
        picker.delegate = self
    }
    @objc func donePicker() {
        inOut.resignFirstResponder()
        //townText.resignFirstResponder()
    }
    func checkTextField() -> Bool{
        
        if (inOut.text?.isEmpty)! || (location.text?.isEmpty)! || (city.text?.isEmpty)! || (crops.text?.isEmpty)! || (numberOfNodes.text?.isEmpty)! || (farmSize.text?.isEmpty)!   {
            
            let alert = UIAlertController(title: "Error!", message: "All fields need to be filled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return false
        }
        
        return true
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
