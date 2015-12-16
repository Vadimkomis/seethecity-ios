//
// Copyright 2016 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//

import UIKit
import Alamofire
import TwitterKit
import Charts
import SwiftyJSON

class AttractionDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties'
    
    var attraction: Attraction!
    var interests = [String]()
    
    @IBOutlet weak var audienceInterestsTableView: UITableView!
    @IBOutlet weak var tweetsChartView: BarChartView!
    @IBOutlet weak var attractionBannerImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        audienceInterestsTableView.delegate = self
        audienceInterestsTableView.dataSource = self
        
        loadDailyTweetCount()
        loadAudienceInterests()
        loadAttractionBannerImage()
        
        self.title = attraction!.name
    }
    
    func loadDailyTweetCount() {

        let daily_tweets_url: String = "\(Constants.host)/api/attractions/\(attraction.id)/daily_tweet_count"
        
        Alamofire.request(.GET, daily_tweets_url)
            .responseJSON { response in
                guard response.result.error == nil else {
                print("Error retrieving daily tweet count.")
                return
            }
        
            if let responseValue: AnyObject = response.result.value {
                
                let jsonResponse = JSON(responseValue)
                var tweetDays = [String]()
                var tweetCounts = [Double]()
        
                for tweetCountDict in jsonResponse.array! {
        
                    let tweetDay = tweetCountDict["day_of_week"].string!
                    let tweetCount = tweetCountDict["tweets_count"].int!
                    
                    tweetDays.append(tweetDay)
                    tweetCounts.append(Double(tweetCount))
                    
                    self.loadTweetsChartView(tweetDays, tweetCounts: tweetCounts)
                    
                }
            }
        }
    }
    
    func loadAudienceInterests() {
        
        let interests_to_display: Int = 3
        
        let audience_interests_url: String = "\(Constants.host)/api/attractions/\(attraction.id)/top_interests"
        
        Alamofire.request(.GET, audience_interests_url)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("Error retrieving audience interests.")
                    return
                }
                
                if let responseValue: AnyObject = response.result.value {
                    
                    let jsonResponse = JSON(responseValue)
                    
                    for i in 0..<interests_to_display {
                        if let interest = jsonResponse[i]["interest"].string {
                        
                            self.interests.append(interest)
                            self.audienceInterestsTableView.reloadData()
                        }
                    }
                    
                }
        }
    }
    
    func loadTweetsChartView(tweetDays: [String], tweetCounts: [Double]) {
        var dataEntries = [BarChartDataEntry]()
        
        for i in 0..<tweetDays.count {
            let dataEntry = BarChartDataEntry(value: tweetCounts[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries)
        
        let chartData = BarChartData(xVals: tweetDays, dataSet: chartDataSet)
        
        chartDataSet.valueTextColor = UIColor.whiteColor()
        chartDataSet.setColor(ColorPalette.Blue)
        
        tweetsChartView.descriptionText = ""
        tweetsChartView.noDataTextDescription = ""
        tweetsChartView.xAxis.setLabelsToSkip(0)
        tweetsChartView.xAxis.labelPosition = .Bottom
        tweetsChartView.xAxis.drawGridLinesEnabled = false
        tweetsChartView.legend.enabled = false
        tweetsChartView.leftAxis.enabled = false
        tweetsChartView.rightAxis.enabled = false
        tweetsChartView.animate(yAxisDuration: 0.5, easingOption: .EaseInQuad)
        tweetsChartView.gridBackgroundColor = UIColor.whiteColor()
        
        tweetsChartView.data = chartData

    }
    
    func loadAttractionBannerImage() {
        if self.attraction.profileBanner != "" {
            if let url:NSURL? = NSURL(string: attraction.profileBanner) {
                if let data:NSData = NSData(contentsOfURL : url!)! {
                    attractionBannerImageView.image = UIImage(data : data)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "twitterTimelineSegue" {
            let twitterTimelineViewController = segue.destinationViewController as! AttractionTwitterTimelineViewController
            
            twitterTimelineViewController.handle = attraction.handle
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.interests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AudienceInterestsTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AudienceInterestsTableViewCell
        
        let interest = interests[indexPath.row]

        cell.interestLabel.text = interest
        
        return cell
    }
}
