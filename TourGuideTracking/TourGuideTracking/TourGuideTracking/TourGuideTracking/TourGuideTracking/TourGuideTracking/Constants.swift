//
//  Constants.swift
//  TourGuideTracking
//
//  Created by Quoc Huy Ngo on 10/11/16.
//  Copyright © 2016 Quoc Huy Ngo. All rights reserved.
//
import UIKit
struct URLs {
    //static let URL_BASE:String = "http://localhost/tourtracking"
    static let URL_BASE:String = "http://tourtracking.esy.es/tourtracking"
    static let URL_IMAGE_BASE:String = "http://localhost/tourtracking/images"
    static let URL_LOGIN:String = URL_BASE + "/login"
    static let URL_GET_TOURGUIDE = URL_BASE + "/tourguides"
    static let URL_GET_TOURS:String = URL_BASE + "/tours"

    
    static func makeURL(url:String, param:Int )->String{
        return String(format: url + "/%d", param)
    }
    
    static func makeURL_EXTEND(url:String, extend:String,param:Int )->String{
        return String(format: url + "/%d" + extend, param)
    }
}

struct URL_EXTEND{
    static let TOURS:String = "/tours"
    static let PLACES:String = "/places"
    static let TOURISTS_LOCATION:String = "/tourists/location"
    static let SCHEDULE:String = "/schedules"
}

struct ERROR_MESSAGE{
    static let CONNECT_SERVER:String = "Connect server problems"
}
