
//  ChildExampleViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//

import Foundation
import XLPagerTabStrip
import Charts

class PestChildView: UIViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "View"
    var location = "none"
    
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
    func drawCharts(){
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
        let pest = Pest(location: self.location)
        pest.getDailyPest(){ (dates, values, species) in
            DispatchQueue.main.async {
                var date = [String]()
                var valueInt = [Int]()
                for day in dates{
                    let temp = day.components(separatedBy: ["-", " ", "'"])
                    date.append(temp[2] + "-" + temp[3])
                    print(temp[2] + "-" + temp[3])
                }
//                for spec in species{
//                    for val in values[spec]{
//
//                    }
//                }
                
                for i in 0..<species.count{
                    
                    self.drawPestCharts(dates: date, values: values[species[i]] as! [Double], num: i, scrollView: scrollView, species: species[i])
                }
            }
        }
    }
    func drawPestCharts(dates: [String], values: [Double], num: Int, scrollView: UIScrollView, species: String){
        let barView = UIView(frame: CGRect(x: 10, y: 270*num+20, width: Int(scrollView.frame.width-20), height: 250))
        let barTitle = UILabel(frame: CGRect(x: 10, y:0, width: 100, height:50))
        let barInfo = UILabel(frame: CGRect(x: 250, y: 0, width: Int(scrollView.frame.width-270), height: 200))
        setPestInfo(data: values, infoLabel: barInfo, species: species)
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.noDataText = "No data available"
        
        var pestDataEntry = [BarChartDataEntry]()
        
        for i in 0..<values.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]), data: dates[i])
            pestDataEntry.append(dataEntry)
        }
        let bar = BarChartDataSet(entries: pestDataEntry, label: "count")
        bar.colors = [UIColor(red: 0, green: 0.4588, blue: 0.1059, alpha: 1.0)] //dark green
        bar.drawValuesEnabled = false
        let barData = BarChartData()
        barData.addDataSet(bar)
        
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        
        barChart.rightAxis.enabled = false
        //lineChart.xAxis.drawLabelsEnabled = false
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        barChart.xAxis.labelRotationAngle = 90
        //lineChart.xAxis.labelCount = data.count
        //marker
        let marker:BalloonMarker = BalloonMarker(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 25.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)//CGSize(75.0, 35.0)
        barChart.marker = marker
        barChart.legend.enabled = false
        //title
        //barChart.chartDescription?.text = "count"
        //lineChart.chartDescription?.positio
        //data
        barChart.data = barData
        barChart.animate(xAxisDuration: 0.5)
        //barChart.drawBordersEnabled = true
        
        scrollView.addSubview(barView)
        barView.addSubview(barChart)
        barView.backgroundColor = .white
        drawShadow(view: barView)
        
        barView.addConstraint(NSLayoutConstraint(item: barChart, attribute: .left, relatedBy: .equal, toItem: barView, attribute: .left, multiplier: 1, constant: 0))
        barView.addConstraint(NSLayoutConstraint(item: barChart, attribute: .top, relatedBy: .equal, toItem: barView, attribute: .top, multiplier: 1, constant: 50))
        
        barView.addConstraints(
            [NSLayoutConstraint(item: barChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: CGFloat(250)),
             NSLayoutConstraint(item: barChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)]
        )
        //set title
        barView.addSubview(barTitle)
        barView.addConstraints([NSLayoutConstraint(item: barTitle, attribute: .top, relatedBy: .equal, toItem: barView, attribute: .top, multiplier: 1, constant: 0),
                                NSLayoutConstraint(item: barTitle, attribute: .left, relatedBy: .equal, toItem: barView, attribute: .left, multiplier: 1, constant: 0)])
        barTitle.text = species
        //set info
        barView.addSubview(barInfo)
        
    }
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    func setPestInfo(data: [Double], infoLabel: UILabel, species: String){
        let countLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 30, height: 50))
        let image = UIImage(named: "insect_" + species)
        let pestImage = UIImageView(frame: CGRect(x: 35, y: 5, width: 50, height: 50))
        pestImage.image = image
        countLabel.text = String(data[data.count-1])
        infoLabel.addSubview(countLabel)
        infoLabel.addSubview(pestImage)
        
        let info = UILabel(frame: CGRect(x: 5, y: 60, width: infoLabel.frame.width, height: 150))
        let diff = data[data.count-1] - data[data.count-2]
        info.numberOfLines = 0
        if diff > 0{
            info.text = String(diff) + " more than yesterday"
        }
        else if diff < 0{
            info.text = String(abs(diff)) + " less than yesterday"
            
        }
        else{
            info.text = "Same as yesterday"
        }
        
        infoLabel.addSubview(info)
        
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
