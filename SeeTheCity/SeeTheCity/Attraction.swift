//
// Copyright 2016 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//

import UIKit

struct Attraction {
    
    let id: Int
    let name: String
    let handle: String
    let latitude: Double
    let longitude: Double
    let tweetCount: Int
    var profileImage: String
    var profileBanner: String
    
    
    init(id: Int, name: String, handle: String, latitude: Double, longitude: Double, tweetCount: Int, profileImage: String, profileBanner: String) {
        
        self.id = id
        self.name = name
        self.handle = handle
        self.latitude = latitude
        self.longitude = longitude
        self.tweetCount = tweetCount
        self.profileImage = profileImage
        self.profileBanner = profileBanner
    }
    
}

