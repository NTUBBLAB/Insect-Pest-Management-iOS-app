//
//  login.swift
//  BBLab
//
//  Created by Lab405 on 2019/3/12.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON

class login_ViewController: UIViewController, UITextFieldDelegate {
    
    struct GV {
        static var location: String? = ""
        static var CN_location: String? = ""
        static var autologin: Int? = 0
    }
    
    var defaults : UserDefaults!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var remember: UISwitch!
    @IBOutlet weak var buttonstyle: UIButton!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var banner: UIImageView!
    
    @IBAction func buttonaction(_ sender: Any) {
        GV.autologin = 0
        let input = account.text!+password.text!
        let regex = try! NSRegularExpression(pattern: "\\s")
        let numberOfWhitespaceCharacters = regex.numberOfMatches(in: input, range: NSRange(location: 0, length: input.utf16.count))
        if numberOfWhitespaceCharacters != 0{
            self.toastView(messsage:"帳號密碼需全為英文字母及數字" , view: self.view)
        }
        else if numberOfWhitespaceCharacters == 0 {
            let defaults = UserDefaults.standard
            let postJson: [String: Any] = ["username": account.text!, "password": password.text!]
            //print(postJson)
            let jsonData = try? JSONSerialization.data(withJSONObject: postJson)
            let loginURL = URL(string: "http://140.112.94.123:20000/PEST_DETECT/account/login.php")
            var request = URLRequest(url: loginURL!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            print("GET Location")
            
            let spinnerView = setSpinner()
            URLSession.shared.dataTask(with: request){ (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil{
                    print(error!)
                    return
                }
                do{
                    
                    let json = try JSON(data: data!)
                    DispatchQueue.main.async {
                        spinnerView.removeFromSuperview()
                        if json["status"] == 0{
                            print("success")
                            let locations = json["locations"].arrayObject as! [String]
                            defaults.set(locations, forKey: "locations")
                            defaults.set(self.account.text!,forKey: "accountKey")
                            defaults.set(self.password.text!,forKey: "passwordKey")
                            defaults.synchronize()
                            self.performSegue(withIdentifier: "login", sender: self)
                        }
                        else{
                            let alert = UIAlertController(title: "Error!", message: "帳號或密碼錯誤", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {action in
                                print("123")
                            
                                
                            }
                            ))
                            self.present(alert, animated: true)
                            return
                        }
                        
                        print(json)
                        
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
        let fullscreensize = UIScreen.main.bounds.size
        
        buttonstyle?.backgroundColor = UIColor(red:0.13, green:0.46, blue:0.84, alpha:1.0)
        
        //        logo?.frame=CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.width*0.274)
        //        logo?.center=CGPoint(x: fullscreensize.width*0.5 , y:fullscreensize.width*0.137+bounds!)
        //        self.view.addSubview(logo)
        self.view.backgroundColor = UIColor(red:1.00, green:0.99, blue:0.98, alpha:1.0)
        banner?.frame = CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.width*0.172)
        banner?.center = CGPoint(x: fullscreensize.width*0.5, y: fullscreensize.width*0.086+UIApplication.shared.statusBarFrame.height)
        //self.view.addSubview(banner)
        
        account?.placeholder = "帳號"
        account?.borderStyle = .roundedRect
        account?.clearButtonMode = .whileEditing
        account?.keyboardType = .default
        account?.returnKeyType = .done
        account?.textColor = UIColor.black
        account?.backgroundColor = UIColor.lightGray
        account?.center = CGPoint(x: fullscreensize.width*0.5, y: fullscreensize.height*0.445)
        
        password?.placeholder = "密碼"
        password?.borderStyle = .roundedRect
        password?.clearButtonMode = .whileEditing
        password?.keyboardType = .default
        password?.returnKeyType = .done
        password?.textColor = UIColor.black
        password?.backgroundColor = UIColor.lightGray
        password?.center = CGPoint(x: fullscreensize.width*0.5, y: fullscreensize.height*0.5)
        
        remember?.center = CGPoint(x: fullscreensize.width*0.615, y: fullscreensize.height*0.56)
        label?.center = CGPoint(x: fullscreensize.width*0.4, y: fullscreensize.height*0.56)
        buttonstyle?.center = CGPoint(x: fullscreensize.width*0.5, y: fullscreensize.height*0.625)
        
        defaults = UserDefaults.standard
        //print(defaults.string(forKey: "autoLogin"))
        
        if defaults.string(forKey: "autoLogin") == "1"{
            print("set")
            account.text = defaults.string(forKey: "accountKey")
            password.text = defaults.string(forKey: "passwordKey")
            buttonaction(self)
        }
        else if defaults.string(forKey: "autoLogin") == "2"{
            account.text = defaults.string(forKey: "accountKey")
            password.text = defaults.string(forKey: "passwordKey")
        }
        else{
            account.text = ""
            password.text = ""
        }
        
        self.account.delegate = self
        self.password.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    func toastView(messsage : String, view: UIView ){
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300,  height : 50))
        toastLabel.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.96, alpha:1.0)
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = messsage
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        })
    }
    
    @objc func dismisskeyboard(){
        //print("AAAAAAAAAAAAAAAAAAAAAAAa")
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public func requesturl(url: String, handler: @escaping (String) -> Void)
    {
        let requestURL = URL(string: url)
        struct JSONData: Decodable{
            var RESULT : [Result]
            struct Result : Decodable{
                var LOCATION: String
                var CN_LOCATION: String
            }
        }
        let requestTask = URLSession.shared.dataTask(with: requestURL!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            let decoder = JSONDecoder()
            if let data = data, let dataList = try? decoder.decode(JSONData.self, from: data) {
                for result in dataList.RESULT{
                    print(result.LOCATION)
                    GV.CN_location = result.CN_LOCATION
                    handler(result.LOCATION);
                    print("")
                }
                print(dataList.RESULT)
            }
            else {print("Error...")}
            if(error != nil) {
                print("Error: \(error)")
            }
        }
        requestTask.resume()
    }
    func setSpinner() -> UIView{
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        view.addSubview(spinnerView)
        
        return spinnerView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
