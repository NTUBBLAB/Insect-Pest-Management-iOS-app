//
//  RegistrationController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/28.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegistrationController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpwd: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var number: UITextField!
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        let postJson: [String: Any] = ["username": username.text!, "password": password.text!, "name": name.text!, "email": email.text!, "contact": number.text!]
        //print(postJson)
        if checkTextField() == true{
            let jsonData = try? JSONSerialization.data(withJSONObject: postJson)
            let loginURL = URL(string: "http://140.112.94.123:20000/PEST_DETECT/account/register.php")
            var request = URLRequest(url: loginURL!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            print("GET Location")
            
            URLSession.shared.dataTask(with: request){ (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil{
                    print(error!)
                    return
                }
                do{
                    
                    let json = try JSON(data: data!)
                    print(json["status"])
                    if json["status"].int == 0{
                        DispatchQueue.main.async {
                            print("success!")
                            let alert = UIAlertController(title: "Success!", message: "Successfully created new account", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {action in
                                    print("123")
                                    self.performSegue(withIdentifier: "toLogin", sender: self)
                            
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
        password.isSecureTextEntry = true
        confirmpwd.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    func checkTextField() -> Bool{
        if (name.text?.isEmpty)! || (username.text?.isEmpty)! || (password.text?.isEmpty)! || (confirmpwd.text?.isEmpty)! || (email.text?.isEmpty)! || (number.text?.isEmpty)! {
            let alert = UIAlertController(title: "Error!", message: "All fields need to be filled", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            return false
        }
        if password.text! != confirmpwd.text! {
            let alert = UIAlertController(title: "Warning", message: "Passwords don't match", preferredStyle: .alert)
            
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
