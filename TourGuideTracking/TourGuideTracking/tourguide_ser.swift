//
//  tourguide_ser.swift
//  TourGuideTracking
//
//  Created by Duc Nguyen on 11/14/16.
//  Copyright © 2016 Quoc Huy Ngo. All rights reserved.
//

import Foundation

class tourguide_ser {
    
    var tourguide_id:Int?
    var tourguide_name:String?
    var email:String? = ""
    var phone:String?
    var display_photo:String?
    
    init(tourguide_id: Int, tourguide_name:String, email: String,phone: String , display_photo: String)
    {
        self.tourguide_id = tourguide_id
        self.tourguide_name = tourguide_name
        self.email = email
        self.phone = phone
        self.display_photo = display_photo
    }
}
