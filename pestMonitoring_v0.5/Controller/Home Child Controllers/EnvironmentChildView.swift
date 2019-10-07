
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
        //view.backgroundColor = UIColor.gray
        navigationItem.title = self.location
    
        drawCharts()
    }
    func drawCharts() {
        let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.gray
            v.contentSize = CGSize(width: view.frame.width, height: 1300)
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
        
        let view1 = UIView(frame: CGRect(x: 10, y: 50, width: self.view.frame.width-20, height: 250))
        let title = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 50))
        let infoLabel = UILabel(frame: CGRect(x: 250, y: 50, width: self.view.frame.width-270, height: 200))
        setText(infoView: infoLabel, data: Temp, type: "T")

        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()

        for row in 0..<Temp.count{
            let value = ChartDataEntry(x: Double(row), y: Temp[row], data: data[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "temperature")
        line1.colors = [NSUIColor.red]
        line1.drawCirclesEnabled = false
        line1.drawValuesEnabled = false
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
        lineChart.xAxis.labelRotationAngle = 90
        //lineChart.xAxis.labelCount = data.count
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.point
        lineChart.legend.enabled = false
        //title
        //lineChart.chartDescription?.text = "Daily temperature"
        
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart
        //lineChart.layer.borderWidth = CGFloat(2)
        //lineChart.layer.borderColor = UIColor.red.cgColor
        scrollView.addSubview(view1)
        scrollView.backgroundColor = .white
        
        
        scrollView.addConstraint(NSLayoutConstraint(item: view1, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))

        drawShadow(view: view1)
        
        view1.addSubview(lineChart)
        //view1.layer.borderColor = UIColor.blue.cgColor
        //view1.layer.borderWidth = CGFloat(2)
        view1.backgroundColor = .white
        view1.addConstraints([NSLayoutConstraint(item: lineChart, attribute: .left, relatedBy: .equal, toItem: view1, attribute: .left, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .top, multiplier: 1, constant: 50),
                              NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250),
                              NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        view1.addSubview(title)
        title.text = "溫度"
        title.textColor = .red
        title.backgroundColor = .white
        
        view1.addSubview(infoLabel)
        
    }
    func drawHumidChart(data: [String], Humid: [Double], scrollView: UIScrollView){
        let humidView = UIView(frame: CGRect(x: 10, y: 320, width: self.view.frame.width-20, height: 250))
        let humidTitle = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 50))
        let humidInfo = UILabel(frame: CGRect(x: 250, y: 50, width: self.view.frame.width-270, height: 200))
        setText(infoView: humidInfo, data: Humid, type: "H")
        
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        //var newData = [String]()
        var lineChartEntry = [ChartDataEntry]()

        for row in 0..<Humid.count{
            let value = ChartDataEntry(x: Double(row), y: Humid[row], data: data[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "humidity")
        line1.colors = [NSUIColor.blue]
        line1.drawCirclesEnabled = false
        line1.drawValuesEnabled = false
        //data
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        //axis
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        
        lineChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
        lineChart.xAxis.labelRotationAngle = 90
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.legend.enabled = false
        //title
        lineChart.chartDescription?.enabled = false
        //lineChart.chartDescription?.positio
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        //lineChart.layer.borderColor = UIColor.blue.cgColor
        //lineChart.layer.borderWidth = CGFloat(2)
    
        scrollView.addSubview(humidView)
        scrollView.backgroundColor = .white
        
        
        scrollView.addConstraint(NSLayoutConstraint(item: humidView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))

        drawShadow(view: humidView)
        
        humidView.addSubview(lineChart)
        //view1.layer.borderColor = UIColor.blue.cgColor
        //view1.layer.borderWidth = CGFloat(2)
        humidView.backgroundColor = .white
        humidView.addConstraints([NSLayoutConstraint(item: lineChart, attribute: .left, relatedBy: .equal, toItem: humidView, attribute: .left, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: humidView, attribute: .top, multiplier: 1, constant: 50),
                              NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250),
                              NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        humidView.addSubview(humidTitle)
        humidTitle.text = "濕度"
        humidTitle.textColor = .blue
        humidTitle.backgroundColor = .white
        
        humidView.addSubview(humidInfo)
    }
    func drawLightChart(data: [String], Light: [Double], scrollView: UIScrollView){
        
        let lightView = UIView(frame: CGRect(x: 10, y: 590, width: self.view.frame.width-20, height: 250))
        let lightTitle = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 50))
        let lightInfo = UILabel(frame: CGRect(x: 250, y: 50, width: self.view.frame.width-270, height: 200))
        setText(infoView: lightInfo, data: Light, type: "L")
        
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
        line1.drawValuesEnabled = false
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
        lineChart.xAxis.labelRotationAngle = 90
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 204/255, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        lineChart.marker = marker
        lineChart.legend.enabled = false
        //title
        lineChart.chartDescription?.enabled = false
        //lineChart.chartDescription?.text = "Daily light intensity"
        //lineChart.chartDescription?.positio
        //data
        lineChart.data = linedata
        lineChart.animate(xAxisDuration: 0.5)
        //lineChart.
        scrollView.addSubview(lightView)
        scrollView.backgroundColor = .white
        
        
        scrollView.addConstraint(NSLayoutConstraint(item: lightView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        drawShadow(view: lightView)
        
        
        lightView.addSubview(lineChart)
        lightView.backgroundColor = .white
        lightView.addConstraints([NSLayoutConstraint(item: lineChart, attribute: .left, relatedBy: .equal, toItem: lightView, attribute: .left, multiplier: 1, constant: 0),
                                  NSLayoutConstraint(item: lineChart, attribute: .top, relatedBy: .equal, toItem: lightView, attribute: .top, multiplier: 1, constant: 50),
                                  NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250),
                                  NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)])
        lightView.addSubview(lightTitle)
        lightTitle.text = "照度"
        lightTitle.textColor = .orange
        lightTitle.backgroundColor = .white
        
        lightView.addSubview(lightInfo)
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    func setText(infoView: UILabel, data: [Double], type: String){
        var unit = ""
        var color = UIColor()
        
        if type == "T"{
            unit = " °C"
            color = UIColor.red
        }
        else if type == "H"{
            unit = " %RH"
            color = UIColor.blue
        }
        else{
            unit = " lux"
            color = UIColor.orange
        }
        
        infoView.numberOfLines = 0
        
        let line1 = String(data[data.count-1]) + unit
        var line2 = ""
        let diff = Int(data[data.count-1] - data[data.count-2])
        
        if diff > 0{
            line2 = String(diff) + unit + " higher than yesterday"
        }
        else if diff < 0{
            line2 = String(abs(diff)) + unit + " lower than yesterday"
        }
        else{
            line2 = "Same as yesterday"
        }
        
        let attributeString = NSMutableAttributedString(string: line1 + "\n" + line2)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: line1.count))
        infoView.textAlignment = NSTextAlignment.center
        infoView.attributedText = attributeString
        
        
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
}
