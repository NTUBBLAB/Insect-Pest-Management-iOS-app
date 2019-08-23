
//  ChildExampleViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//

import Foundation
import XLPagerTabStrip
import Charts

class EnvironmentViewController: UIViewController, IndicatorInfoProvider {
    
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
        
        
        let environmentData = Environment(location: self.location)
        environmentData.getDailyEnv(type: "T") { (result) in
            DispatchQueue.main.async {
                print(result)
                self.drawChart(data: result[0] as! [String], Temp: result[1] as! [Double])
            }
        }
        
    }
    
    // MARK: - IndicatorInfoProvider
    func drawChart(data: [String], Temp: [Double]){
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.noDataText = "chart1"
        
        var lineChartEntry = [ChartDataEntry]()
        //let zip_temp = zip(data, Temp)
        for row in 0..<Temp.count{
            let value = ChartDataEntry(x: Double(row), y: Temp[row])
            lineChartEntry.append(value)
        }
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "temp")
        line1.colors = [NSUIColor.red]
        line1.drawCirclesEnabled = false
        //let tempDataset = ChartDataSet(entries: lineChartEntry, label: "temperature")
        //let tempData = ChartData(dataSet: tempDataset)
        let linedata = LineChartData()
        linedata.addDataSet(line1)
        
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
        lineChart.xAxis.labelCount = data.count / 10
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.data = linedata
    
        lineChart.animate(xAxisDuration: 1.5)
        
        
        
        
        
        view.addSubview(lineChart)
        view.backgroundColor = .white
        
        view.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: lineChart, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -50))
        view.addConstraints(
            [NSLayoutConstraint(item: lineChart, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 600),
             NSLayoutConstraint(item: lineChart, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)]
            
        )
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
