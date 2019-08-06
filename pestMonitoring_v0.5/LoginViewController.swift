//
//  login.swift
//  BBLab
//
//  Created by Lab405 on 2019/3/12.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit

class login_ViewController: UIViewController {
    
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
            if remember?.isOn == true {
                GV.autologin = 0
                defaults.set(account.text!,forKey: "accountkey")
                defaults.set(password.text!,forKey: "passwordkey")
                defaults.set("0",forKey:"autologin")
                defaults.synchronize()
            }
            if remember?.isOn == false{
                defaults.removeObject(forKey: "accountkey")
                defaults.removeObject(forKey: "passwordkey")
                
                defaults.synchronize()
            }
            if(account.text!=="admin" && password.text!=="admin101"){
                GV.location = "admin"
                self.performSegue(withIdentifier:"login",sender:self)
            }
            let url : String = "http://140.112.94.123:20000/PEST_DETECT/_android/get_login.php?username="+account.text!+"&password="+password.text!
            requesturl(url: url) { (result) in
                GV.location = result
                print(GV.location!)
                if (self.account.text!=="admin"){ GV.location = "admin"}
                DispatchQueue.main.sync {
                    if(GV.location == "CHIAYI_GH"){
                        self.toastView(messsage: "嘉義", view: self.view)
                    }
                    if(GV.location == "YUNLIN_GH"){
                        self.toastView(messsage: "雲林", view: self.view)
                    }
                    if(GV.location == "none"){
                        self.toastView(messsage: "帳號密碼錯誤", view: self.view)
                    }
                    if(GV.location != "none"){
                        self.performSegue(withIdentifier:"login",sender:self)
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullscreensize = UIScreen.main.bounds.size
        
        buttonstyle?.backgroundColor = UIColor(red:0.13, green:0.46, blue:0.84, alpha:1.0)
        
        //        logo?.frame=CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.width*0.274)
        //        logo?.center=CGPoint(x: fullscreensize.width*0.5 , y:fullscreensize.width*0.137+bounds!)
        //        self.view.addSubview(logo)
        self.view.backgroundColor = UIColor(red:1.00, green:0.99, blue:0.98, alpha:1.0)
        banner?.frame = CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.width*0.172)
        banner?.center = CGPoint(x: fullscreensize.width*0.5, y: fullscreensize.width*0.086+UIApplication.shared.statusBarFrame.height)
        self.view.addSubview(banner)
        
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
        if defaults.string(forKey: "accountkey") != nil {
            remember?.setOn(true, animated: true)
            account?.text = defaults.string(forKey: "accountkey")
            password?.text = defaults.string(forKey: "passwordkey")
            print("autologin_status")
            print(GV.autologin)
            if(GV.autologin==0){
                buttonstyle.sendActions(for: .touchUpInside)
                print("sendaction")
            }
            defaults.synchronize()
        }
        print("initial")
        print(defaults.string(forKey: "accountkey"));
        if defaults.string(forKey: "accountkey") == nil {
            remember?.setOn(false, animated: true)
            print("NOTHINGGGGGGGGGG")
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismisskeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
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
        print("AAAAAAAAAAAAAAAAAAAAAAAa")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
