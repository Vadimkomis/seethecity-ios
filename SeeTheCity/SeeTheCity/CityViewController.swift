//
// Copyright 2016 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//

import Alamofire
import SwiftyJSON
import UIKit

class CityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var cityTableView: UITableView!
    
    var selectedCity: City?
    var cities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityTableView.delegate = self
        cityTableView.dataSource = self
        
        addNavBarIcon()
        loadCities()
        
    }
    
    func loadCities() {
        
        let cities_url: String = "\(Constants.host)/api/cities"
        
        Alamofire.request(.GET, cities_url)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("Error retrieving cities.")
                    return
                }
                    
                if let responseValue: AnyObject = response.result.value {
                    let jsonResponse = JSON(responseValue)
                    
                    for cityDict in jsonResponse.array! {
                        
                        let city = City(
                            id: cityDict["id"].int!,
                            name: cityDict["name"].string!
                        )
                        
                        self.cities.append(city)
                    }

                    self.cityTableView.reloadData()
                }
            }
    }
    
    func addNavBarIcon() {
        self.navigationController?.navigationBar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "SeetheCityNavIcon")
        imageView.constraints
        imageView.image = image

        navigationItem.titleView = imageView
    }

    // MARK: - Table view data source
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cityDetailsSegue" {
            let cityDetailsViewController = segue.destinationViewController as! CityDetailsViewController
            
            cityDetailsViewController.city = selectedCity
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cities.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CityTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CityTableViewCell
        
        let city = cities[indexPath.row]
        
        cell.nameLabel.text = city.name

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCity = cities[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        performSegueWithIdentifier("cityDetailsSegue", sender: self)
    }

}
