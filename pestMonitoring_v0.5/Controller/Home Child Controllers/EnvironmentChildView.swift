
//  ChildExampleViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//

import Foundation
import XLPagerTabStrip
import Charts

class EnvironmentChildView: UIViewController,  IndicatorInfoProvider {
    
    var location = "none"
    var itemInfo: IndicatorInfo = "View"
    
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawCharts()
        
        
        
        
    }
    func drawCharts() {
        let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.white
            v.contentSize = CGSize(width: view.frame.width, height: 2000)
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
        let environmentData = Environment(location: self.location)
        environmentData.getDailyEnv(type: "T") { (result) in
            DispatchQueue.main.async {
                //draw temperature chart
                var dates = [String]()
                for day in result[0] as! [String]{
                    let temp = day.components(separatedBy: ["-", " "])
                    dates.append(temp[1] + "-" + temp[2])
                    //print(day)
                }
                self.drawTempChart(data: dates, Temp: result[1] as! [Double], scrollView: scrollView)
            }
        }
        environmentData.getDailyEnv(type: "H") { (result) in
            DispatchQueue.main.async {
                //draw humidity chart
                var dates = [String]()
                for day in result[0] as! [String]{
                    let temp = day.components(separatedBy: ["-", " "])
                    dates.append(temp[1] + "-" + temp[2])
                    //print(day)
                }
                self.drawHumidChart(data: dates, Humid: result[1] as! [Double], scrollView: scrollView)
            }
        }
        environmentData.getDailyEnv(type: "L") { (result) in
            DispatchQueue.main.async {
                //draw humidity chart
                var dates = [String]()
                for day in result[0] as! [String]{
                    let temp = day.components(separatedBy: ["-", " "])
                    dates.append(temp[1] + "-" + temp[2])
                    //print(day)
                }
                self.drawLightChart(data: dates, Light: result[1] as! [Double], scrollView: scrollView)
            }
        }
    }
    // MARK: - IndicatorInfoProvider
    func drawTempChart(data: [String], Temp: [Double], scrollView: UIScrollView){
        
        
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()
        //let zip_temp = zip(data, Temp)
//        for dates in stride(from: 0, to: data.endIndex, by: 10){
//            newData.append(data[dates])
//        }
        for row in 0..<Temp.count{
            let value = ChartDataEntry(x: Double(row), y: Temp[row], data: data[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "temperature")
        line1.colors = [NSUIColor.red]
        line1.drawCirclesEnabled = false
        //let tempDataset = ChartDataSet(entries: lineChartEntry, label: "temperature")
        //let tempData = ChartData(dataSet: tempDataset)
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        //axis
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        
        lineChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
        lineChart.xAxis.labelRotationAngle = 45
        //lineChart.xAxis.labelCount = data.count
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.legend.enabled = false
        //title
        lineChart.chartDescription?.text = "Daily temperature"
        //lineChart.chartDescription?.positio
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        
        
        
        scrollView.addSubview(lineChart)
        scrollView.backgroundColor = .white
        
        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 50))
        
        scrollView.addConstraints(
            [NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 375),
             NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)]
            
        )
    }
    func drawHumidChart(data: [String], Humid: [Double], scrollView: UIScrollView){
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()
        //let zip_temp = zip(data, Temp)
        //        for dates in stride(from: 0, to: data.endIndex, by: 10){
        //            newData.append(data[dates])
        //        }
        for row in 0..<Humid.count{
            let value = ChartDataEntry(x: Double(row), y: Humid[row], data: data[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "humidity")
        line1.colors = [NSUIColor.blue]
        line1.drawCirclesEnabled = false
        //let tempDataset = ChartDataSet(entries: lineChartEntry, label: "temperature")
        //let tempData = ChartData(dataSet: tempDataset)
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        //axis
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        
        lineChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
        lineChart.xAxis.labelRotationAngle = 45
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.legend.enabled = false
        //title
        lineChart.chartDescription?.text = "Daily Humidity"
        //lineChart.chartDescription?.positio
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        
        
        
        scrollView.addSubview(lineChart)
        scrollView.backgroundColor = .white

        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 500))
        scrollView.addConstraints(
            [NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 375),
             NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)])
    }
    func drawLightChart(data: [String], Light: [Double], scrollView: UIScrollView){
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "light intensity"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()
        //let zip_temp = zip(data, Temp)
        //        for dates in stride(from: 0, to: data.endIndex, by: 10){
        //            newData.append(data[dates])
        //        }
        for row in 0..<Light.count{
            let value = ChartDataEntry(x: Double(row), y: Light[row], data: data[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "light intensity")
        line1.colors = [NSUIColor.orange]
        line1.drawCirclesEnabled = false
        //let tempDataset = ChartDataSet(entries: lineChartEntry, label: "temperature")
        //let tempData = ChartData(dataSet: tempDataset)
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        //axis
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        
        lineChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
        lineChart.xAxis.labelRotationAngle = 45
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 204/255, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.legend.enabled = false
        //title
        lineChart.chartDescription?.text = "Daily light intensity"
        //lineChart.chartDescription?.positio
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        
        
        
        scrollView.addSubview(lineChart)
        scrollView.backgroundColor = .white
        
        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 950))
        scrollView.addConstraints(
            [NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 375),
             NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)])
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}
