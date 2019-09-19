//
//  DiseaseChildView.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/9/7.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import Charts
import SwiftyJSON
class DiseaseChildView: UIViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "View"
    var location = ""
    
    var values = [Double]()
    var dates = [String]()
    var crops = [String]()
    var disease_name = "Tomato"
    
    var currentIR = ""
    var currentAlarm = 1.0
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    func setView(){
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
        let diseaseData = Disease(location: self.location)
        diseaseData.getDisease(location: self.location) { (result) in
            print(result)
            DispatchQueue.main.async {
                
                var values = [Double]()
                var dates = [String]()
                
                let val = result[1] as! [Double]
                let dat = result[2] as! [String]
                for i in val.count - 7..<val.count{
                    let sep = dat[i].components(separatedBy: [" ", "-", "'"])
                    values.append(val[i])
                    dates.append(sep[2] + "-" + sep[3])
                    
                }
                //print(values)
                //print(dates)
                
                self.values = values
                self.dates = dates
                self.crops = result[3] as! [String]
                self.disease_name = result[0] as! String
                //print(self.disease_name)
                self.currentIR = String(self.values[self.values.count - 1])
                self.drawCharts(scrollView: scrollView)
            }
        }
        
    }
    func drawCharts(scrollView: UIScrollView){
        let view1 = UIView(frame: CGRect(x: 10, y: 20, width: self.view.frame.width - 20, height: 500))
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: view1.frame.width, height: 30))
        let infoLabel = UILabel(frame: CGRect(x: 260, y: 50, width: self.view.frame.width - 270, height: 200))
        setText(infoLabel: infoLabel)
        
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()
        
        for row in 0..<self.values.count{
            let value = ChartDataEntry(x: Double(row), y: self.values[row], data: self.dates[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "temperature")
        line1.colors = [NSUIColor.blue]
        line1.drawCirclesEnabled = true
        line1.circleRadius = 2
        line1.drawValuesEnabled = false
        //let tempDataset = ChartDataSet(entries: lineChartEntry, label: "temperature")
        //let tempData = ChartData(dataSet: tempDataset)
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        //axis
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        //lineChart.leftAxis.valueFormatter =
        lineChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.dates)
        lineChart.xAxis.labelRotationAngle = 90
        //lineChart.xAxis.labelCount = data.count
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        //lineChart.point
        lineChart.legend.enabled = false
        //title
        //lineChart.chartDescription?.text = ""
        
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        let barChart = drawBarChart()
        
        scrollView.addSubview(view1)
        scrollView.backgroundColor = .white
        
        
        scrollView.addConstraint(NSLayoutConstraint(item: view1, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        
        drawShadow(view: view1)
        let IRLabel = UILabel(frame: CGRect(x: 5, y: 30, width: 200, height: 20))
        IRLabel.text = "累積三日罹病指數"
        let DSVLabel = UILabel(frame: CGRect(x: 5, y: 270, width: 200, height: 20))
        DSVLabel.text = "警戒指數"
        //IRLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
        view1.addSubview(IRLabel)
        view1.addSubview(DSVLabel)
        
        view1.addSubview(lineChart)
        view1.backgroundColor = .white
        view1.addConstraints([NSLayoutConstraint(item: lineChart, attribute: .left, relatedBy: .equal, toItem: view1, attribute: .left, multiplier: 1, constant: 5),
                              NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .top, multiplier: 1, constant: 50),
                              NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250),
                              NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        view1.addSubview(barChart)
        view1.addConstraints([NSLayoutConstraint(item: barChart, attribute: .left, relatedBy: .equal, toItem: view1, attribute: .left, multiplier: 1, constant: 5),
                              NSLayoutConstraint(item: barChart, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .top, multiplier: 1, constant: 290),
                              NSLayoutConstraint(item: barChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250),
                              NSLayoutConstraint(item: barChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        view1.addSubview(title)
        title.text = self.disease_name
        title.textColor = .red
        title.textAlignment = .center
        title.backgroundColor = .white
        
        
        view1.addSubview(infoLabel)
        //infoLabel.text = alarms[Int(setLevels(data: self.values[self.values.count - 1]) - 1)]
        //infoLabel.textColor = setColors(data: setLevels(data: self.values[self.values.count - 1]))
    }
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
    func drawBarChart() -> BarChartView{
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.noDataText = "No data available"
        
        var pestDataEntry = [BarChartDataEntry]()
        var levels = [Double]()
        for i in 0..<self.values.count{
            let level = setLevels(data: Double(values[i]))
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: level, data: self.dates[i])
            pestDataEntry.append(dataEntry)
            levels.append(level)
        }
        self.currentAlarm = levels[levels.count-1]
        let bar = BarChartDataSet(entries: pestDataEntry, label: "count")
        var colors = [UIColor]()
        for i in 0..<levels.count{
            colors.append(setColors(data: levels[i]))
        }
        bar.colors = colors
        //bar.colors = [UIColor(red: 0, green: 0.4588, blue: 0.1059, alpha: 1.0)] //dark green
        bar.drawValuesEnabled = false
        let barData = BarChartData()
        barData.addDataSet(bar)
        
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.axisMaximum = 5
        barChart.leftAxis.axisMinimum = 0
        barChart.leftAxis.granularity = 1
        barChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.dates)
        barChart.xAxis.labelRotationAngle = 90
        //lineChart.xAxis.labelCount = data.count
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        barChart.marker = marker
        barChart.legend.enabled = false
        
        //data
        barChart.data = barData
        barChart.animate(xAxisDuration: 0.5)
        return barChart
    }
    func setLevels(data: Double) -> Double{
       
        if data <= 2.88{
            return 1
        }
        else if data <= 5.76 && data > 2.88{
            
            return 2
        }
        else if data <= 8.64 && data > 5.76{
            
            return 3
        }
        else if data <= 11.52 && data > 8.64{
            
            return 4
        }
        else{
            return 5
        }
        
    }
    
    func setColors(data: Double) -> UIColor{
        
        if data <= 1{
            return UIColor.green
        }
        else if data <= 2 && data > 1{
           
            return UIColor.blue
        }
        else if data <= 3 && data > 2{
           
            return UIColor.yellow
        }
        else if data <= 4 && data > 3{
        
            return UIColor.orange
        }
        else{
            return UIColor.red
        }
        
    }
    func setText(infoLabel: UILabel){
        infoLabel.numberOfLines = 0
        let alarms = ["低", "警戒", "較高", "高", "嚴重"]
        
        let line1 = "罹病指數"
        let line2 = self.currentIR
        let line3 = "警戒指數"
        let line4 = alarms[Int(self.currentAlarm) - 1]
        
        let attributeString = NSMutableAttributedString(string: line1 + "\n" + line2 + "\n" + "\n" + line3 + "\n" + line4)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: setColors(data: Double(self.currentAlarm)), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSRange(location: line1.count+line2.count+line3.count + 4, length: line4.count))
        attributeString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)], range: NSRange(location: line1.count + 1, length: line2.count))
        
        infoLabel.textAlignment = NSTextAlignment.center
        infoLabel.attributedText = attributeString
    }
    
}
