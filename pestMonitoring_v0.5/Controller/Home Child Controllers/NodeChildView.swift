

import Foundation
import XLPagerTabStrip
import SwiftyJSON

class NodeChildView: UIViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "View"
    var location = ""
    
    var nodeStat: [Int]?
    var numOfNodes: Int?
    var species: [String]?
    var species_cn: [String]?
    var counts: Dictionary<String, [Int]>?
    var images: [String]?
    var temp: [Int]?
    var humd: [Int]?
    var light: [Int]?
    var times: [String]?
    
    let scrollView = UIScrollView()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.white
        
        scrollView.isScrollEnabled = true
        
        fetchData()
        
       
        view.addSubview(scrollView)
        
        view.backgroundColor = .white
        
        view.addConstraints(
            [NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.frame.width),
             NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height)]
        )
        
        
    }
    func fetchData(){
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/data_nodal.php?loc=" + self.location)
        URLSession.shared.dataTask(with: url!){ (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                //
                let json = try JSON(data: data!)
                //print(json)
                DispatchQueue.main.async {
                    if json["status"] == 3{
                        self.numOfNodes = json["nodes"].intValue
                        self.nodeStat = json["nodestat"].arrayObject as? [Int]
                        self.species = json["species"].arrayObject as? [String]
                        self.species_cn = json["species_cn"].arrayObject as? [String]
                        self.temp = json["envi"]["T"].arrayObject as? [Int]
                        self.humd = json["envi"]["H"].arrayObject as? [Int]
                        self.light = json["envi"]["L"].arrayObject as? [Int]
                        
                        self.times = json["dates"].arrayObject as? [String]
                        do{
                            try self.counts = json["counts"].dictionaryObject as? Dictionary<String, [Int]>
                        }
                        catch let error{
                            print(error)
                        }
                        self.images = json["images"].arrayObject as? [String]
                        
                        self.scrollView.contentSize = CGSize(width: Int(self.view.frame.width), height: self.numOfNodes!*300)
                        for i in 0..<self.numOfNodes!{
                            self.drawNodeCell(cells: i, scroll: self.scrollView)
                        }
                        //print(self.times)
                    }
                    else{
                        return
                    }
                }
                
                
                
                
            }
            catch let jsonError{
                print(jsonError)
            }
        }.resume()
    }
    func drawNodeCell(cells: Int, scroll: UIScrollView){
        let cellView = UIView(frame: CGRect(x: 10, y: 20+270*cells, width: Int(view.frame.width-20), height: 250))
        
        cellView.backgroundColor = .white
        drawShadow(view: cellView)
        scroll.addSubview(cellView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "裝置 " + String(cells+1)
        cellView.addSubview(titleLabel)
        cellView.addConstraints([NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 5),
                                 NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                                 NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        if self.times?[cells] != nil{
            timeLabel.text = "上次更新時間： " + self.times![cells]
        }
        else{
            timeLabel.text = "上次更新時間： 無"
        }
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        if self.nodeStat![cells] == -1{
            timeLabel.textColor = .red
        }
        else{
            timeLabel.textColor = .black
        }
        
        cellView.addSubview(timeLabel)
        cellView.addConstraints([NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 25),
                                 NSLayoutConstraint(item: timeLabel, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 10),
                                 NSLayoutConstraint(item: timeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 300),
                                 NSLayoutConstraint(item: timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
        setTemp(cellView: cellView, node: cells)
        setHumd(cellView: cellView, node: cells)
        setLight(cellView: cellView, node: cells)
        if (self.species != nil) && (self.counts != nil){
            //print(self.species!)
            //print(self.counts)
            setPest(cellView: cellView, species: self.species!, counts: self.counts!, node: cells)
        }
        
    }
   
    func setTemp(cellView: UIView, node: Int){
        let tempImageView = UIImageView()
        tempImageView.image = UIImage(named: "HomeIcon_Temp")
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        cellView.addSubview(tempImageView)
        cellView.addConstraints([
            NSLayoutConstraint(item: tempImageView, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(60)),
            NSLayoutConstraint(item: tempImageView, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: tempImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: tempImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)
            ])
        
        let tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.text = String(self.temp![node]) + " °C"
        tempLabel.textAlignment = .left
        cellView.addSubview(tempLabel)
        cellView.addConstraints([NSLayoutConstraint(item: tempLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 60),
                                 NSLayoutConstraint(item: tempLabel, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 50),
                                 NSLayoutConstraint(item: tempLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
                                 NSLayoutConstraint(item: tempLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
    }
    func setHumd(cellView: UIView, node: Int){
        let humdImageView = UIImageView()
        humdImageView.image = UIImage(named: "HomeIcon_Humid")
        humdImageView.contentMode = .scaleAspectFill
        humdImageView.clipsToBounds = true
        humdImageView.translatesAutoresizingMaskIntoConstraints = false
        cellView.addSubview(humdImageView)
        cellView.addConstraints([
            NSLayoutConstraint(item: humdImageView, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(60)),
            NSLayoutConstraint(item: humdImageView, attribute: .centerX, relatedBy: .equal, toItem: cellView, attribute: .centerX, multiplier: 1, constant: -50),
            NSLayoutConstraint(item: humdImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: humdImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)
            ])
        
        let humdLabel = UILabel()
        humdLabel.translatesAutoresizingMaskIntoConstraints = false
        humdLabel.text = String(self.humd![node]) + " %RH"
        humdLabel.textAlignment = .right
        cellView.addSubview(humdLabel)
        cellView.addConstraints([NSLayoutConstraint(item: humdLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 60),
                                 NSLayoutConstraint(item: humdLabel, attribute: .centerX, relatedBy: .equal, toItem: cellView, attribute: .centerX, multiplier: 1, constant: 0),
                                 NSLayoutConstraint(item: humdLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                                 NSLayoutConstraint(item: humdLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
    }
    func setLight(cellView: UIView, node: Int){
        let lightImageView = UIImageView()
        lightImageView.image = UIImage(named: "HomeIcon_Light")
        lightImageView.contentMode = .scaleAspectFill
        lightImageView.clipsToBounds = true
        lightImageView.translatesAutoresizingMaskIntoConstraints = false
        cellView.addSubview(lightImageView)
        cellView.addConstraints([
            NSLayoutConstraint(item: lightImageView, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(60)),
            NSLayoutConstraint(item: lightImageView, attribute: .right, relatedBy: .equal, toItem: cellView, attribute: .right, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: lightImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: lightImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)
            ])
        
        let lightLabel = UILabel()
        lightLabel.translatesAutoresizingMaskIntoConstraints = false
        lightLabel.text = String(self.light![node]) + " lux"
        lightLabel.textAlignment = .right
        cellView.addSubview(lightLabel)
        cellView.addConstraints([NSLayoutConstraint(item: lightLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 60),
                                 NSLayoutConstraint(item: lightLabel, attribute: .right, relatedBy: .equal, toItem: cellView, attribute: .right, multiplier: 1, constant: -30),
                                 NSLayoutConstraint(item: lightLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                                 NSLayoutConstraint(item: lightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
    }
    func setPest(cellView: UIView, species: [String], counts: Dictionary<String, [Int]>, node: Int){
        //var i = 0
        for i in 0..<species.count{
            let pestLabel = UILabel()
            pestLabel.translatesAutoresizingMaskIntoConstraints = false
            pestLabel.text = species_cn![i]
            pestLabel.textAlignment = .left
            cellView.addSubview(pestLabel)
            cellView.addConstraints([NSLayoutConstraint(item: pestLabel, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(100+30*i)),
                                     NSLayoutConstraint(item: pestLabel, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 15),
                                     NSLayoutConstraint(item: pestLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
                                     NSLayoutConstraint(item: pestLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
            
            let pestCount = UILabel()
            pestCount.translatesAutoresizingMaskIntoConstraints = false
            pestCount.text = String(counts[species[i]]![node])
            pestCount.textAlignment = .left
            cellView.addSubview(pestCount)
            cellView.addConstraints([NSLayoutConstraint(item: pestCount, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(100+30*i)),
                                     NSLayoutConstraint(item: pestCount, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 100),
                                     NSLayoutConstraint(item: pestCount, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
                                     NSLayoutConstraint(item: pestCount, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20)])
            }
        let stickyPaper = UIImageView()
//        if let filePath = Bundle.main.path(forResource: self.images![node], ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
//            print(self.images![node])
//            stickyPaper.contentMode = .scaleAspectFit
//            stickyPaper.image = image
//        }
        setImage(urlString: self.images![node], image: stickyPaper)
        stickyPaper.contentMode = .scaleAspectFill
        stickyPaper.clipsToBounds = true
        stickyPaper.translatesAutoresizingMaskIntoConstraints = false
        
        //stickyPaper.layer.borderWidth = 1
        //stickyPaper.backgroundColor = .green
        cellView.addSubview(stickyPaper)
        cellView.addConstraints([
            NSLayoutConstraint(item: stickyPaper, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: CGFloat(100)),
            NSLayoutConstraint(item: stickyPaper, attribute: .left, relatedBy: .equal, toItem: cellView, attribute: .left, multiplier: 1, constant: 150),
            NSLayoutConstraint(item: stickyPaper, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.frame.width-180),
            NSLayoutConstraint(item: stickyPaper, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 140)])
            //i = i + 1
        
    }
    func setImage(urlString: String, image: UIImageView){
        //let urlString = "http://www.foo.com/myImage.jpg"
        //print(urlString)
        var newUrl = ""
        if(urlString.split(separator: " ").count == 2){
            newUrl = urlString.split(separator: " ")[0] + "%20" + urlString.split(separator: " ")[1]
        }
        //print(newUrl)
        guard let url = URL(string: String(newUrl)) else {return}
        
        //print(urlString)
        //print(url)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Failed fetching image:", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                return
            }
            
            DispatchQueue.main.async {
                image.image = UIImage(data: data!)
            }
        }.resume()
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
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
