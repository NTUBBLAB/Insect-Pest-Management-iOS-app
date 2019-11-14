import Foundation
import XLPagerTabStrip
import SwiftyJSON
import UserNotifications


struct FarmButton{
    var farmName = ""
    var button = UIButton()
    var farmCity = ""
}

class HomePagingController: UIViewController {
    let scrollView = UIScrollView()
    let buttonScrollView = UIScrollView()
    var farmButtons = [FarmButton]()
    let farmLabel = UILabel()
    
    
    var locations = [String]()
    var city = [String]()
    var currentCity: String?
    var currentLoc: String?
    
    var pestLabels = [UILabel]()
    var pestNameLabels = [UILabel]()
    var envLabels = [UILabel]()
    var alarmLabels = [UILabel]()
    
    var currentTemp: String!
    var currentHumd: String!
    var currentLight: String!
    
    let summaryCell = UIView()
    let weatherView = WeatherView()
    let chineseDict = ["CHIAYI_GH": "嘉義育家", "JINGPIN_GH": "京品", "YUNLIN_GH": "雲林福成", "TAINANDARES_GH": "台南農改場洋桔梗溫室", "TAINANMO_FF": "台南農改場芒果園", "TAICHUNGSB_GH": "草屯光之莓草莓園", "QINGYUAN_GH": "擎園蝴蝶蘭溫室", "TEST_GH": "測試溫室"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]){ (granted, error) in
            
        }
        
        let notification = UNMutableNotificationContent()
        notification.title = "Hi"
        notification.body = "123"
        
        let date = Date().addingTimeInterval(10)
        
        let dateComponet = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponet, repeats: true)
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: notification, trigger: trigger)
        
        center.add(request){ (error) in
            
        }
        
        let defaults = UserDefaults.standard
        locations = defaults.array(forKey: "locations") as! [String]
        city = defaults.array(forKey: "city") as! [String]
        print(locations)
        print(city)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1500)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.white
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        view.backgroundColor = .white
        view.addConstraints(
            [NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.frame.width),
             NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height)]
        )
        
        buttonScrollView.contentSize = CGSize(width: self.locations.count*70, height: 100)
        buttonScrollView.translatesAutoresizingMaskIntoConstraints = false
        buttonScrollView.backgroundColor = UIColor.white
        buttonScrollView.isScrollEnabled = true
        scrollView.addSubview(buttonScrollView)
        //scrollView.backgroundColor = .white
        scrollView.addConstraints(
            [NSLayoutConstraint(item: buttonScrollView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: buttonScrollView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: buttonScrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant:  view.frame.width),
             NSLayoutConstraint(item: buttonScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100)]
        )
        
        self.currentLoc = locations[0]
        self.currentCity = city[0]
        for i in 0..<self.locations.count{
            setFarmButtons(loc: self.locations[i], x:CGFloat(20+70*i), y:20, w: 50, h:50)
            
        }
        
        setSummaryCell()
        getEnvData()
        getPestData()
        
        weatherView.city = self.currentCity
        weatherView.getCurrentWeather(view: view)
        
        weatherView.frame = CGRect(x:20, y: 300, width: view.frame.width-40, height: 300)
        weatherView.drawShadow()
        
        scrollView.addSubview(weatherView)
        scrollView.addConstraints([NSLayoutConstraint(item: weatherView, attribute:.top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 530),
                                   NSLayoutConstraint(item: weatherView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 20),
                                   NSLayoutConstraint(item: weatherView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 300),
                                   NSLayoutConstraint(item: weatherView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (view.frame.width-40))])
        
        let calendarView = CalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .gray
        calendarView.register(DateCell.self, forCellWithReuseIdentifier: "dateCell")
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self
        
        
        
        scrollView.addSubview(calendarView)
        scrollView.addConstraints([NSLayoutConstraint(item: calendarView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 850),
                                   NSLayoutConstraint(item: calendarView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 20),
                                   NSLayoutConstraint(item: calendarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400),
                                   NSLayoutConstraint(item: calendarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (view.frame.width-40))])
        
    }
    func setFarmButtons(loc: String, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        let farmButton = UIButton()
        var button = FarmButton()
        button.button = farmButton
        button.farmName = loc
        button.farmCity = self.currentCity!
        
        farmButton.backgroundColor = .white
        farmButton.translatesAutoresizingMaskIntoConstraints = false
        
        farmButton.setTitle(loc, for: .normal)
        farmButton.setTitleColor(.white, for: .normal)
        farmButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        farmButton.titleLabel?.textColor = .black
//        farmButton.titleLabel?.backgroundColor = .blue
        farmButton.imageView?.contentMode = .scaleAspectFit
        farmButton.setImage( UIImage(named: "ghouse"), for: UIControl.State.normal)
        farmButton.setImage( UIImage(named: "ghouse_selected"), for: UIControl.State.selected)
        farmButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        farmButton.addTarget(self, action: #selector(buttonClicked), for: UIControl.Event.touchUpInside)
        //print(farmButton.titleLabel)
        buttonScrollView.addSubview(farmButton)
        buttonScrollView.addConstraints([NSLayoutConstraint(item: farmButton, attribute:.top, relatedBy: .equal, toItem: buttonScrollView, attribute: .top, multiplier: 1, constant: y),
                             NSLayoutConstraint(item: farmButton, attribute: .left, relatedBy: .equal, toItem: buttonScrollView, attribute: .left, multiplier: 1, constant: x),
                             NSLayoutConstraint(item: farmButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: w),
                             NSLayoutConstraint(item: farmButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: h)])
        if button.farmName == currentLoc{
            button.button.isSelected = true
        }
        farmButtons.append(button)
    }
    func setSummaryCell(){
        
        summaryCell.frame = CGRect(x:20, y: 100, width: view.frame.width-40, height: 400)
        summaryCell.translatesAutoresizingMaskIntoConstraints = false
        summaryCell.backgroundColor = .white
        summaryCell.layer.cornerRadius = 2
        //summaryCell.layer.borderWidth = 1
        summaryCell.drawShadow()
        scrollView.addSubview(summaryCell)
        scrollView.addConstraints([NSLayoutConstraint(item: summaryCell, attribute:.top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 100),
                                   NSLayoutConstraint(item: summaryCell, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 20),
                                   NSLayoutConstraint(item: summaryCell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400),
                                   NSLayoutConstraint(item: summaryCell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (view.frame.width-40))])
        
        farmLabel.translatesAutoresizingMaskIntoConstraints = false
        farmLabel.textAlignment = .center
        farmLabel.text = chineseDict[self.currentLoc!]
        farmLabel.font = UIFont.systemFont(ofSize: 18)
        
        summaryCell.addSubview(farmLabel)
        summaryCell.addConstraints([NSLayoutConstraint(item: farmLabel, attribute:.centerX, relatedBy: .equal, toItem: summaryCell, attribute: .centerX, multiplier: 1, constant: 0),
                                    NSLayoutConstraint(item: farmLabel, attribute: .top, relatedBy: .equal, toItem: summaryCell, attribute: .top, multiplier: 1, constant: 20),
                                    NSLayoutConstraint(item: farmLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
                                    NSLayoutConstraint(item: farmLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200)])
        
        let moreButton = UIButton(frame: CGRect(x: 0, y: 350, width: (view.frame.width-40), height: 50))
        moreButton.setTitleColor(.black, for: UIControl.State.normal)
        moreButton.setTitle("MORE", for: UIControl.State.normal)
        
        //moreButton.layer.borderWidth = 1
        moreButton.addTarget(self, action: #selector(moreSelected), for: UIControl.Event.touchUpInside)
        summaryCell.addSubview(moreButton)
        
        setEnvIcon(view: summaryCell, imageName: "HomeIcon_Temp", x: 50, y: 80, w: 50, h: 50)
        setEnvIcon(view: summaryCell, imageName: "HomeIcon_Humid", x: (self.view.frame.width/2-45), y: 80, w: 50, h: 50)
        setEnvIcon(view: summaryCell, imageName: "HomeIcon_Light", x: self.view.frame.width-140, y: 80, w: 50, h: 50)
        
    }
    func setEnvIcon(view: UIView, imageName: String, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: x),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: y),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: w),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: h)
            ])
    }
    func getEnvData(){
        
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_envi_current.php?loc=" + self.currentLoc!)
        // print(url)
        URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do{
                //print("GETTING CURRENT ENVS")
                
                let currentEnvJson = try JSON(data: data!)
                DispatchQueue.main.async {
                    if currentEnvJson["status"] == 3{
                        if self.envLabels.count != 0{
                            for label in self.envLabels{
                                label.removeFromSuperview()
                            }
                        }
                        
                        self.currentTemp = currentEnvJson["values"][0].stringValue
                        self.currentHumd = currentEnvJson["values"][1].stringValue
                        self.currentLight = currentEnvJson["values"][2].stringValue
                        
                        
                        self.setEnvValue(view: self.summaryCell, value: self.currentTemp, x: 50, y: 150, w: 50, h: 30)
                        self.setEnvValue(view: self.summaryCell, value: self.currentHumd, x: (self.view.frame.width/2-45), y: 150, w: 50, h: 30)
                        self.setEnvValue(view: self.summaryCell, value: self.currentLight, x: self.view.frame.width-140, y: 150, w: 50, h: 30)
                        //cell.currentEnv = [currentTemp + " °C", currentHumid + " %", currentLight + " lux"]
                    }
                    else{
                        if self.envLabels.count != 0{
                            for label in self.envLabels{
                                label.removeFromSuperview()
                            }
                        }
                    }
                }
                
            }
            catch let jsonError{
                print(jsonError)
            }
        }.resume()
        
    }
    func getPestData(){
        
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_insect_current.php?loc=" + self.currentLoc!)
        URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do{
                let pestJson = try JSON(data: data!)
                DispatchQueue.main.async {
                    if pestJson["status"] == 3{
                        if self.pestLabels.count != 0{
                            for label in self.pestLabels{
                                label.removeFromSuperview()
                            }
                            for label in self.pestNameLabels{
                                label.removeFromSuperview()
                            }
                            for label in self.alarmLabels{
                                label.removeFromSuperview()
                            }
                        }
                       
                        var species_array_cn = [String]()
                        var species_array = [String]()
                        var count_array = [Int]()
                        var alarm = Dictionary<String, [Int]>()
                        var i = 0
                        for insect in pestJson["species_cn"].arrayObject as! [String]{
                            species_array_cn.append(insect)
                            alarm[insect] = (pestJson["alarms"][i].arrayObject as! [Int])
                            i += 1
                        }
                        for count in pestJson["counts"].arrayObject as! [Int]{
                            count_array.append(count)
                        }
                        for sp in pestJson["species"].arrayObject as! [String]{
                            species_array.append(sp)
                        }
                        for i in 0..<species_array.count{
                            self.setPest(view: self.summaryCell, pestName: species_array[i], pestCount: count_array[i], x: 50, y: CGFloat(200+30*i), w: 80, h: 20)
                        }
                        self.setPestAlarm(view: self.summaryCell, alarm: alarm, count: count_array, spec: species_array_cn)
                    }
                    else{
                        if self.pestLabels.count != 0{
                            for label in self.pestLabels{
                                label.removeFromSuperview()
                            }
                            for label in self.pestNameLabels{
                                label.removeFromSuperview()
                            }
                            for label in self.alarmLabels{
                                label.removeFromSuperview()
                            }
                        }
                    }
                     
                }
                //print(pestJson["status"])
                
            }
            catch let jsonError{
                print(jsonError)
            }
        }.resume()
    }
    func setPestAlarm(view: UIView, alarm: Dictionary<String, [Int]>, count: [Int], spec: [String]){
        for i in 0..<alarm.count {
            let alarmLabel = UILabel()
            
            let level = alarm[spec[i]]
            alarmLabel.textColor = UIColor.black
            if count[i] <= level![1]{
                alarmLabel.text = "low"
                alarmLabel.backgroundColor = .green
                
            }
            else if (count[i] > level![1]) && (count[i] < level![2]){
                alarmLabel.text = "guarded"
                alarmLabel.backgroundColor = .blue
                alarmLabel.textColor = UIColor.white
            }
            else if (count[i] > level![2]) && (count[i] < level![3]){
                alarmLabel.text = "high"
                alarmLabel.backgroundColor = .yellow
            }
            else{
                alarmLabel.text = "severe"
                alarmLabel.backgroundColor = .red
            }
            //speciesLabel.text = species[i]
            
            alarmLabel.translatesAutoresizingMaskIntoConstraints = false
            alarmLabel.textAlignment = NSTextAlignment.center
            
            view.addSubview(alarmLabel)
            view.addConstraints([
                NSLayoutConstraint(item: alarmLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: (self.view.frame.width-140)),
                NSLayoutConstraint(item: alarmLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: CGFloat(200+30*i)),
                NSLayoutConstraint(item: alarmLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 70),
                NSLayoutConstraint(item: alarmLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)
            ])
            self.alarmLabels.append(alarmLabel)
        }
    }
    func setPest(view: UIView, pestName: String, pestCount: Int, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        let pestNameLabel = UILabel()
        let pestCountLabel = UILabel()
        //let pestAlarmLabel = UILabel()
        pestNameLabel.translatesAutoresizingMaskIntoConstraints = false
        pestNameLabel.text = pestName
        pestNameLabel.textAlignment = .left
        
        view.addSubview(pestNameLabel)
        view.addConstraints([
            NSLayoutConstraint(item: pestNameLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: x),
            NSLayoutConstraint(item: pestNameLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: y),
            NSLayoutConstraint(item: pestNameLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: w),
            NSLayoutConstraint(item: pestNameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: h)
            ])
        
        pestCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pestCountLabel.text = String(pestCount)
        pestCountLabel.textAlignment = .center
        
        view.addSubview(pestCountLabel)
        view.addConstraints([
            NSLayoutConstraint(item: pestCountLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: ((self.view.frame.width-40)/2-25)),
            NSLayoutConstraint(item: pestCountLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: y),
            NSLayoutConstraint(item: pestCountLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: pestCountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)
            ])
        
        
       
        
        self.pestNameLabels.append(pestNameLabel)
        self.pestLabels.append(pestCountLabel)
        
    }
    func setEnvValue(view: UIView, value: String, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.textAlignment = .center
        view.addSubview(valueLabel)
        view.addConstraints([
            NSLayoutConstraint(item: valueLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: x),
            NSLayoutConstraint(item: valueLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: y),
            NSLayoutConstraint(item: valueLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: w),
            NSLayoutConstraint(item: valueLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: h)
        ])
        self.envLabels.append(valueLabel)
        
    }
    
    @objc func buttonClicked(sender: UIButton)
    {
        
        
        if (!sender.isSelected){
            sender.isSelected = !sender.isSelected;
            self.currentLoc = sender.titleLabel?.text
            getEnvData()
            getPestData()
            farmLabel.text = self.chineseDict[self.currentLoc!]
        }
        for button in farmButtons{
            if button.button.isSelected == true && button.farmName != currentLoc{
                button.button.isSelected = false
            }
        }
        weatherView.city = self.city[self.locations.firstIndex(of: self.currentLoc!)!]
        weatherView.getCurrentWeather(view: view)
        
       
    }
    @objc func moreSelected(sender: UIButton){
        let pager = storyboard?.instantiateViewController(withIdentifier: "PagerMenu") as? PagerTabStrip
        //farmDetail?.name = locations[indexPath.row]
        pager?.location = self.currentLoc!
        //print(locations[indexPath.item])
        self.navigationController?.pushViewController(pager!, animated: true)
    }
}

extension UIView{
    public func drawShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        
        //self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: self.frame.height-50, width: self.frame.width, height: 50)).cgPath
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
