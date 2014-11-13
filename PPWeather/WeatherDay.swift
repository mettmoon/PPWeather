//
//  WeatherDay.swift
//  PPWeather
//
//  Created by Hayden on 2014. 11. 13..
//  Copyright (c) 2014년 WEJOApps. All rights reserved.
//

import Foundation
import CoreData

class WeatherDay: NSManagedObject {

    @NSManaged var sunrise: NSDate
    @NSManaged var sunset: NSDate
    @NSManaged var date: NSDate
    @NSManaged var weatherTime: NSSet
    @NSManaged var spot: Spot
    let dateFormatter:NSDateFormatter! = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    func dateString() -> String{
        return dateFormatter.stringFromDate(date)
    }

}
