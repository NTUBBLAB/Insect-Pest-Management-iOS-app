//
//  CalendarView.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/11/14.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import UIKit
import SwiftyJSON
import JTAppleCalendar

class WhiteSectionHeaderView: JTAppleCollectionReusableView {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    let title =  UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
   
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
    }
    
}

class PinkSectionHeaderView: JTAppleCollectionReusableView {
    
    let title =  UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func draw(_ rect: CGRect) {
         self.addSubview(title)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let r1 = CGRect(x: 0, y: 0, width: 25, height: 25)
        context.addRect(r1)
        context.fillPath()
        context.setStrokeColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        context.addEllipse(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        context.strokePath()
    }
    
}

class DateCell: JTAppleCell {
    var dateLabel = UILabel()
    var selectedView = UIView()
    var currentDate: String?{
        didSet{
            //setBackgroundColor()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        //dateLabel.backgroundColor = .blue
        self.addSubview(dateLabel)
        self.addConstraints([NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0  ),
                              NSLayoutConstraint(item: dateLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
                              NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.bounds.height),
                              NSLayoutConstraint(item: dateLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.bounds.width)])
        
        selectedView.translatesAutoresizingMaskIntoConstraints = false
       
        self.addSubview(selectedView)
        self.addConstraints([NSLayoutConstraint(item: selectedView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0  ),
                             NSLayoutConstraint(item: selectedView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: selectedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.bounds.height),
                             NSLayoutConstraint(item: selectedView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.bounds.width)])
         selectedView.isHidden = true
    }
    func setBackgroundColor(){
        selectedView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
        selectedView.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CalendarView: JTAppleCalendarView{
   // let testLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var testCalendar = Calendar.current
    override init() {
        super.init()
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.allowsMultipleSelection = true
        //register(DateCell.self, forCellWithReuseIdentifier: "dateCell")
        //self.addSubview(testLabel)
        //testLabel.text = "123"
        //self.delegate = self
        //self.isScrollEnabled = false
        self.isPagingEnabled = true
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension HomePagingController: JTAppleCalendarViewDelegate{
    
    func handleCellSelected(cell: DateCell, cellState: CellState){
        if cellState.isSelected {
            
            //cell.currentDate
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC+8")
            let dateClicked = dateFormatter.string(from: cellState.date)
            showSprayingOptions(date: dateClicked, cell: cell)
            
        }
        else{
            cell.selectedView.isHidden = true
        }
    }
    func setCalendarCells(cell: DateCell, cellState: CellState, date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //cell.currentDate = dateFormatter.string(from: date)
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC+8")
        //print(cellState.date)
        //print(date)
        //print(self.sprayDays.count)
        for i in 0..<self.sprayDays.count{
            if( dateFormatter.string(from: cellState.date) == self.sprayDays[i]){
//                //print(dateFormatter.string(from: date))
//                cell.selectedView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
//                cell.selectedView.isHidden = false
//                cell.selectedView.layer.cornerRadius = 5
//                print(cell.dateLabel)
                if(self.pesticides[i] == "2"){
                    cell.selectedView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
                    cell.selectedView.isHidden = false
                    cell.selectedView.layer.cornerRadius = 13
                }

                if(self.pesticides[i] == "1"){

                    cell.selectedView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
                    cell.selectedView.isHidden = false
                    cell.selectedView.layer.cornerRadius = 5
                    print(self.sprayDays[i])
                    print("set")
                }
                if(self.pesticides[i] == "0"){
                    cell.selectedView.isHidden = true
                }

            }
        }
    }
    func configureCell(view: JTAppleCell?, cellState: CellState, date: Date) {
        guard let cell = view as? DateCell  else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        cell.dateLabel.text = dateFormatter.string(from: cellState.date)
        //print(dateFormatter.string(from: cellState.date))
        
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        setCalendarCells(cell: cell, cellState: cellState, date: date)
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        //setCalendarCells(cell: cell, cellState: cellState, date: date)
        configureCell(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState, date: date)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState, date: date)
    }
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return true
    }
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        let monthSize = MonthSize(defaultSize: 50)
        return monthSize
    }
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        //let date = range.start
        //let month = testCalendar.component(.month, from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMM"
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "WhiteSectionHeaderView", for: indexPath) as! WhiteSectionHeaderView
        header.title.text = formatter.string(from: range.start)

        return header
    }
    func showSprayingOptions(date: String, cell: DateCell) {
        let alert = UIAlertController(title: "農藥噴灑選項", message: "請選擇您噴灑農藥的方式", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "依照建議噴灑", style: UIAlertAction.Style.default , handler: { (_) in
            cell.selectedView.layer.cornerRadius = 13
            cell.selectedView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
            cell.bringSubviewToFront(cell.dateLabel)
            cell.selectedView.isHidden = false
            
            self.saveSprayingDate(type: "2", date: date)
            
        }))
        
        alert.addAction(UIAlertAction(title: "一般噴灑", style: .default, handler: { (_) in
            cell.selectedView.layer.cornerRadius = 13
            cell.selectedView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
            cell.bringSubviewToFront(cell.dateLabel)
            cell.selectedView.isHidden = false
            
            self.saveSprayingDate(type: "1", date: date)
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .destructive, handler: { (_) in
            cell.selectedView.isHidden = true
            self.saveSprayingDate(type: "0", date: date)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func saveSprayingDate(type: String, date: String){
        let url = URL(string: "http://140.112.94.123:20000/PEST_DETECT/_app/save_pesticide_calendar.php?loc=" + self.currentLoc! + "&pesticide=" + type + "&date=" + date)
        URLSession.shared.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error!)
                return
            }
            do {
                let json = try JSON(data: data!)
                
                DispatchQueue.main.async {
                    print(json)
                }
                
            }
            catch let jsonError{
                print(jsonError)
            }
            
        }.resume()
        
    }
}
extension HomePagingController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "2017-01-01")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6)
    }
    
}
