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
        navigationItem.title = NSLocalizedString(location, comment: "")
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemTitleColor = .blue
        settings.style.selectedBarBackgroundColor = .blue
        
        buttonBarView.selectedBar.backgroundColor = .blue
        
        buttonBarView.backgroundColor = UIColor.white
        
        //buttonBarView.tintColor = UIColor.blue
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        
        let EnvironChildView = EnvironmentChildView(itemInfo: IndicatorInfo(title: NSLocalizedString("Environment", comment: "")))
        EnvironChildView.location = self.location
        let pestChildView = PestChildView(itemInfo: IndicatorInfo(title: NSLocalizedString("Pest", comment: "")))
        pestChildView.location = self.location
        let diseaseChildView = DiseaseChildView(itemInfo: IndicatorInfo(title: NSLocalizedString("Disease", comment: "")))
        diseaseChildView.location = self.location
        let nodeView = NodeChildView(itemInfo: IndicatorInfo(title: NSLocalizedString("Nodal", comment: "")))
        nodeView.location = self.location
        
        guard isReload else {
            return [nodeView, pestChildView, EnvironChildView, diseaseChildView]
        }
        
        var childViewControllers = [nodeView, pestChildView, EnvironChildView, diseaseChildView]
        
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
