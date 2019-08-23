//
//  PagerTabStrip.swift
//  pestMonitoring_v0.5
//
//  Created by Lab405 on 2019/8/20.
//  Copyright © 2019年 Lab405. All rights reserved.
//

import XLPagerTabStrip
import Foundation

class PagerTabStrip: ButtonBarPagerTabStripViewController {
    
    var location = "none"
    var isReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.style.buttonBarItemBackgroundColor = .blue
        buttonBarView.selectedBar.backgroundColor = .white
        buttonBarView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        //buttonBarView.tintColor = UIColor.blue
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let EnvironChildView = EnvironmentViewController(itemInfo: "Environment")
        EnvironChildView.location = self.location
        //let child_3 = TableChildExampleViewController(style: .grouped, itemInfo: "Table View 2")
        let child_4 = ChildExampleViewController(itemInfo: "Weather")
        //let child_5 = TableChildExampleViewController(style: .plain, itemInfo: "Table View 3")
        let child_6 = ChildExampleViewController(itemInfo: "Pest")
        //let child_7 = TableChildExampleViewController(style: .grouped, itemInfo: "Table View 4")
        let child_8 = ChildExampleViewController(itemInfo: "Disease")
        
        guard isReload else {
            return [EnvironChildView, child_4, child_6, child_8]
        }
        
        var childViewControllers = [EnvironChildView, child_4, child_6, child_8]
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }

}
