//
//  AppViewController.swift
//  Gamp
//
//  Created by Mikhail Larionov on 7/19/14.
//  Copyright (c) 2014 Mikhail Larionov. All rights reserved.
//

import UIKit

class AppViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollForCards: UIScrollView!
    
    var cards:Array<GACardView> = []
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Label
        var label = UILabel(frame: CGRectMake(0, 0, 200, 20))
        label.center = CGPointMake(self.view.frame.width/2, 40)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = PNGreenColor
        label.font = UIFont(name: "Avenir-Medium", size:23.0)
        label.text = "General metrics"
        self.view.addSubview(label)
        
        // Card
        for var buildNumber = 0; buildNumber < builds.count; buildNumber++
        {
            var card:GACardView? = GACardView.instanceFromNib()
            if let currentCard = card {
                
                // Build number
                currentCard.buildString = builds[buildNumber].build
                
                // Date and time
                let dateStringFormatter = NSDateFormatter()
                dateStringFormatter.dateFormat = "MM.dd.yyyy"
                var startDate = dateStringFormatter.dateFromString(builds[buildNumber].date)
                var endDate = (buildNumber == 0 ? NSDate(timeIntervalSinceNow: -86400*1) : dateStringFormatter.dateFromString(builds[buildNumber-1].date))
                var endDateMinusMonth = endDate.dateByAddingTimeInterval(-86400*30)
                if endDateMinusMonth.compare(startDate) == NSComparisonResult.OrderedDescending
                {
                    startDate = endDateMinusMonth
                }
                currentCard.startDate = startDate
                currentCard.endDate = endDate
                
                var dateEnd = NSDate(timeIntervalSinceNow: -86400*1)
                var dateStart = NSDate(timeIntervalSinceNow: -86400*31)

                // Sizing and updating card layout
                currentCard.frame.origin = CGPoint(x: Int(currentCard.frame.width)*buildNumber, y: 50)
                currentCard.frame.size.height = self.view.frame.size.height - currentCard.frame.origin.y;
                currentCard.prepare()
                
                // Adding to the scroll and to the array
                cards.append(currentCard)
                self.scrollForCards.addSubview(currentCard)
                
                // Changing scroll size
                if buildNumber == 0
                {
                    currentCard.load()
                    self.scrollForCards.frame.size.width = currentCard.frame.width
                    self.scrollForCards.contentSize = CGSize(width: currentCard.frame.width * CGFloat(builds.count), height: self.scrollForCards.frame.height)
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        var indexOfPage = scrollForCards.contentOffset.x / scrollForCards.frame.width;
        var currentPage = Int(indexOfPage);
        if !cards[currentPage].loadingStarted
        {
            cards[currentPage].load()
        }
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
