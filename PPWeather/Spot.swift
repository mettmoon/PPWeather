//
//  Spot.swift
//  PPWeather
//
//  Created by Hayden on 2014. 11. 13..
//  Copyright (c) 2014년 WEJOApps. All rights reserved.
//

import Foundation
import CoreData

class Spot: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var altitude: NSNumber
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var weatherDay: NSSet

}
