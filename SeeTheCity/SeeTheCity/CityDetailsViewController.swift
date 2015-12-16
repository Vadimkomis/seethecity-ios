//
// Copyright 2016 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//

import Alamofire
import MapKit
import SwiftyJSON
import TwitterKit
import UIKit

class CityDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var attractionTableView: UITableView!
    
    var city: City?
    var selectedAttraction: Attraction?
    var attractions = [Attraction]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        attractionTableView.delegate = self
        attractionTableView.dataSource = self
        
        loadRankedAttractions()
        
        self.title = city!.name
    }
    
    func loadRankedAttractions() {
        
        let ranked_attractions_url: String = "\(Constants.host)/api/cities/\(city!.id)/ranked_attractions"
        
        Alamofire.request(.GET, ranked_attractions_url)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("Error retrieving ranked attractions.")
                    return
                }
                
                if let responseValue: AnyObject = response.result.value {
                    let jsonResponse = JSON(responseValue)
                    
                    for attractionsDict in jsonResponse.array! {
                        
                        let attraction = Attraction(
                            id: attractionsDict["id"].int!,
                            name: attractionsDict["name"].string!,
                            handle: attractionsDict["handle"].string!,
                            latitude: Double(attractionsDict["centroid_lat"].string!)!,
                            longitude: Double(attractionsDict["centroid_long"].string!)!,
                            tweetCount: attractionsDict["tweets_count"].int!,
                            profileImage: "",
                            profileBanner: ""
                        )
                        
                        self.attractions.append(attraction)
                    }
                    
                    self.attractionTableView.reloadData()
                    self.loadAttractionImages()
                    self.loadCityMap()
                    self.loadAttractionPins()
                }
        }
    }
    
    func loadAttractionImages() {
        
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
        var screenNames = ""
        var clientError : NSError?
        
        for i in 0..<self.attractions.count {
            if screenNames == "" {
                screenNames = self.attractions[i].handle
            } else {
                screenNames = screenNames + ",\(self.attractions[i].handle)"
            }
        }
        
        let params = ["screen_name": screenNames, "include_entities": "false"]
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET",
            URL: statusesShowEndpoint,
            parameters: params,
            error: &clientError
        )

        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            guard connectionError == nil else {
                print("Error: \(connectionError)")
                return
            }
            
            do {
                let json : AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)

                let jsonResponse = JSON(json!)
                
                for userDict in jsonResponse.array! {
                    
                    if let attraction_index = self.attractions.indexOf({$0.handle.lowercaseString == userDict["screen_name"].string!.lowercaseString}) {

                        if let profileImage = userDict["profile_image_url_https"].string {
                            self.attractions[attraction_index].profileImage = profileImage
                        }
                        
                        if let profileBanner = userDict["profile_banner_url"].string {
                            self.attractions[attraction_index].profileBanner = profileBanner
                        }

                    }
                }
                
                self.attractionTableView.reloadData()
            } catch {
                print("Error retrieving attraction images.")
            }
        }
    }
    
    func loadCityMap() {
        
        let spanPadding: Double = 1.5
        
        let minLatitude = attractions.map{$0.latitude}.minElement()!
        let maxLatitude = attractions.map{$0.latitude}.maxElement()!
        let minLongitude = attractions.map{$0.longitude}.minElement()!
        let maxLongitude = attractions.map{$0.longitude}.maxElement()!


        let latitudeSpan = maxLatitude - minLatitude
        let longitudeSpan = maxLongitude - minLongitude
        
        let centerLocation = CLLocation(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        
        let coordinateRegion = MKCoordinateRegionMake(centerLocation.coordinate, MKCoordinateSpan( latitudeDelta: latitudeSpan * spanPadding, longitudeDelta: longitudeSpan * spanPadding))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadAttractionPins() {
        
        var pins = [MKPointAnnotation]()
        
        for i in 0...(attractions.count-1) {
            
            let pin = MKPointAnnotation()
            
            pin.coordinate = CLLocationCoordinate2D(
                latitude: attractions[i].latitude,
                longitude: attractions[i].longitude
            )
            
            pin.title = attractions[i].name
            
            pins.append(pin)
        }
        
        mapView.addAnnotations(pins)
    }
    
    // MARK: - Table view data source
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "attractionDetailsSegue" {
            let attractionDetailsViewController = segue.destinationViewController as! AttractionDetailsViewController
            
            attractionDetailsViewController.attraction = selectedAttraction
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return attractions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AttractionTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AttractionTableViewCell
        
        let attraction = attractions[indexPath.row]
        
        cell.nameLabel.text = attraction.name
        cell.handleLabel.text = "@\(attraction.handle)"
        cell.tweetCountLabel.text = String(attraction.tweetCount)
        
        if attraction.profileImage != "" {
            if let url:NSURL = NSURL(string: attraction.profileImage)! {
                if let data:NSData = NSData(contentsOfURL : url)! {
                    cell.profileImage.image = UIImage(data : data)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedAttraction = attractions[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        performSegueWithIdentifier("attractionDetailsSegue", sender: self)
    }

}

