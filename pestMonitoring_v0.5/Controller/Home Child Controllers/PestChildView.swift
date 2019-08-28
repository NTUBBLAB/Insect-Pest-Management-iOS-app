
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
        let pest = Pest(location: self.location)
        pest.getDailyPest(){ (dates, values, species) in
            DispatchQueue.main.async {
                for i in 0..<species.count{
                    self.drawPestCharts(dates: dates, values: values[species[i]] as! [Int], num: i, scrollView: scrollView)
                }
            }
        }
    }
    func drawPestCharts(dates: [String], values: [Int], num: Int, scrollView: UIScrollView){
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.noDataText = "No data available"
        
        var pestDataEntry = [BarChartDataEntry]()
        
        for i in 0..<values.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]), data: dates[i])
            pestDataEntry.append(dataEntry)
        }
        let bar = BarChartDataSet(entries: pestDataEntry, label: "count")
        bar.colors = [UIColor.black]
        
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
        barChart.drawBordersEnabled = true
        scrollView.addSubview(barChart)
        scrollView.backgroundColor = .white
        
        scrollView.addConstraint(NSLayoutConstraint(item: barChart, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: barChart, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: CGFloat(num*400+50)))
        
        scrollView.addConstraints(
            [NSLayoutConstraint(item: barChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: CGFloat(view.frame.width - 50)),
             NSLayoutConstraint(item: barChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 300)]
        )
        
    }
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
