//
//  Warning.swift
//  TourGuideTracking
//
//  Created by Duc Nguyen on 11/16/16.
//  Copyright © 2016 Quoc Huy Ngo. All rights reserved.
//

import Foundation

class Warning {
    
    var categoryWarning:String?
    var distance:String?
    var lat:String?
    var long:String?
    var warningName:String?
    var description: String?
    
    init(categoryWarning: String, distance:String, lat: String,long: String , warningName: String, description: String)
    {
        self.categoryWarning = categoryWarning
        self.distance = distance
        self.lat = lat
        self.long = long
        self.warningName = warningName
        self.description = description
    }
}
