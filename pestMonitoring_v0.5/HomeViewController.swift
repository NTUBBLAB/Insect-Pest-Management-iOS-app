//
//  HomeViewController.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/7/4.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import Charts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var FarmLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var HumidLabel: UILabel!
    @IBOutlet weak var LightLabel: UILabel!
    
    
    
    struct GV {
        static var db: String? = ""
        static var site: String? = ""
        static var admin: Int? = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.noDataText = "No data"
        GV.site = "YUNLIN_GH"
        self.FarmLabel?.text = GV.site
        
        let numPests = [4.0 , 15.0, 20.0, 3.0, 23.0]
        let classes = ["Fly", "Gnat", "Mothfly", "Thrips", "Whitefly"]
        drawPestBarChart(classes: classes, numOfPests: numPests)
        
        refresh(location: GV.site)
        // Do any additional setup after loading the view.
    }
    
    public func refresh(location: String!){
        let db_url : String = "http://140.112.94.123:20000/PEST_DETECT/_android/get_number_of_dbs.php?location="+location
        GV.site = location
        //self.location?.text = location
        print("set_text"+location)
        requestdb(url: db_url) { (result) in
            GV.db = result
            print("getting mean env")
            let T_url : String = "http://140.112.94.123:20000/PEST_DETECT/_android/data_envi_mean.php?LOCATION="+GV.site!+"&TYPE=T";
            let H_url : String = "http://140.112.94.123:20000/PEST_DETECT/_android/data_envi_mean.php?LOCATION="+GV.site!+"&TYPE=H";
            let L_url : String = "http://140.112.94.123:20000/PEST_DETECT/_android/data_envi_mean.php?LOCATION="+GV.site!+"&TYPE=L";
            self.requestenv(url: T_url){ (result) in
                var rounded_T = Double(result) ?? 0
                rounded_T = round(rounded_T*10)/10
                self.TempLabel?.text = String(rounded_T)+" °C"
            }
            self.requestenv(url: H_url) { (result) in
                var rounded_H = Double(result) ?? 0
                rounded_H = round(rounded_H*10)/10
                self.HumidLabel?.text = String(rounded_H)+" %"
            }
            self.requestenv(url: L_url) { (result) in
                var rounded_L = Double(result) ?? 0
                rounded_L = round(rounded_L*10)/10
                self.LightLabel?.text = String(rounded_L)+" lux"
            }
            DispatchQueue.main.async {
                let charturl = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_android/envi_table.php?location="+GV.site!+"&db="+GV.db!+"&lang=cn")
                
                //self.webview2?.load(URLRequest(url: URL(string: "http://140.112.94.123:20000/PEST_DETECT/_sub-components/home/table.php?db="+ViewController.GV.db!+"&location="+ViewController.GV.site!)!))
                //self.webview1?.scrollView.isScrollEnabled = true
            }
        }
    }
    public func drawPestBarChart(classes: [String], numOfPests: [Double]){
        barChart.noDataText = "No data retrieved"
        
        
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<classes.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y:Double(numOfPests[i]))
            dataEntries.append(dataEntry)
        }
        
        let pestDataSet = BarChartDataSet(entries: dataEntries, label: nil)
        let pestData = BarChartData(dataSet: pestDataSet)
        pestDataSet.colors = self.setChartColors(numOfColors: classes.count)
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: classes)
        barChart.xAxis.labelCount = classes.count
        barChart.data = pestData
        barChart.legend.enabled = false
        barChart.animate(yAxisDuration: 1.5)
        
        
        
    }
    public func setChartColors(numOfColors: Int) -> [UIColor]{
        var colors: [UIColor] = []
        colors = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
//        for _ in 0..<numOfColors {
//            let red = Double(arc4random_uniform(256))
//            let green = Double(arc4random_uniform(256))
//            let blue = Double(arc4random_uniform(256))
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)
//        }
        return colors
    }
    public func requestdb(url: String, handler: @escaping (String) -> Void)
    {
        let requestURL = URL(string: url)
        struct dbjson: Decodable{
            var RESULT : [Result]
            struct Result : Decodable{
                var NUM: String
            }
        }
        let requestTask = URLSession.shared.dataTask(with: requestURL!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data, let dataList = try? JSONDecoder().decode( dbjson.self, from: data) {
                for result in dataList.RESULT{
                    print(result.NUM )
                    DispatchQueue.main.sync {
                        handler(result.NUM);
                        print("DONE DISPATCH")
                    }
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
    public func requestenv(url: String, handler: @escaping (String) -> Void)
    {
        let requestURL = URL(string: url)
        struct dbjson: Decodable{
            var RESULT : [Result]
            struct Result : Decodable{
                var VALUE: Double
            }
        }
        let requestTask = URLSession.shared.dataTask(with: requestURL!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data, let dataList = try? JSONDecoder().decode( dbjson.self, from: data) {
                for result in dataList.RESULT{
                    print(result.VALUE)
                    DispatchQueue.main.async {
                        handler(String(result.VALUE));
                        print("DONE DISPATCH")
                    }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
