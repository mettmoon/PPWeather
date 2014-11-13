//
//  WeatherTime.swift
//  PPWeather
//
//  Created by Hayden on 2014. 11. 13..
//  Copyright (c) 2014년 WEJOApps. All rights reserved.
//

import Foundation
import CoreData

class WeatherTime: NSManagedObject {

    @NSManaged var date: NSDate?
    @NSManaged var updatedDate: NSDate
    @NSManaged var windSpeed: NSNumber
    @NSManaged var windGusts: NSNumber
    @NSManaged var windDirection: NSNumber
    @NSManaged var temperature: NSNumber
    @NSManaged var isotherm: NSNumber
    @NSManaged var cloudCoverHigh: NSNumber
    @NSManaged var cloudCoverMid: NSNumber
    @NSManaged var cloudCoverLow: NSNumber
    @NSManaged var precip: NSNumber
    @NSManaged var windguruRating: NSNumber
    @NSManaged var weatherDay: WeatherDay

}
