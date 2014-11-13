//
//  ViewController.swift
//  PPWeather
//
//  Created by Hayden on 2014. 11. 13..
//  Copyright (c) 2014년 WEJOApps. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UITableViewController {
    var managedObjectContext:NSManagedObjectContext! = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    let dataArray:NSMutableArray! = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        var targetSpot:Spot? = nil
        let identifier = "221640"
        let fetchRequest = NSFetchRequest(entityName: "Spot")
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        let result = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)
        if result!.count > 0 {
            targetSpot = result?.first as? Spot
        }else {
            targetSpot = NSEntityDescription.insertNewObjectForEntityForName("Spot", inManagedObjectContext: managedObjectContext) as? Spot
            targetSpot?.identifier = identifier
        }
        if let targetSpot = targetSpot {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let set = targetSpot.weatherDay .filteredSetUsingPredicate(NSPredicate(format: "dateString == %@", dateFormatter.stringFromDate(NSDate()))!)
            if set.count > 0 {
                
            }else{
                let url = NSURL(string: "http://www.windguru.cz/int/index.php?sc=\(identifier)&sty=m_spot")
                let request = NSURLRequest(URL: url!)
                if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
                    
                    if let resultString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        let keyRange = resultString.rangeOfString("wg_fcst_tab_data_1")
                        let startRange = resultString.rangeOfString("{", options: NSStringCompareOptions.allZeros, range: NSMakeRange(keyRange.location, 100))
                        let endRange = resultString.rangeOfString(";", options: NSStringCompareOptions.allZeros, range: NSMakeRange(keyRange.location, resultString.length - keyRange.location))
                        let string = resultString.substringWithRange(NSMakeRange(startRange.location, endRange.location - startRange.location)) as NSString
                        if let json = NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableContainers, error: nil) as? NSDictionary {
                            targetSpot.name = json.objectForKey("spot") as String
                            targetSpot.latitude = json.objectForKey("lat") as NSNumber
                            targetSpot.longitude = json.objectForKey("lon") as NSNumber
                            targetSpot.altitude = json.objectForKey("lat") as NSNumber
                            let sunDateFormatter = NSDateFormatter()
                            sunDateFormatter.dateFormat = "HH:mm"
                            let newWeatherDay = NSEntityDescription.insertNewObjectForEntityForName("WeatherDay", inManagedObjectContext: managedObjectContext) as WeatherDay
                            newWeatherDay.sunrise = sunDateFormatter.dateFromString(json.objectForKey("sunrise") as String)!
                            newWeatherDay.sunset = sunDateFormatter.dateFromString(json.objectForKey("sunset") as String)!
                            newWeatherDay.date = NSDate()
                            newWeatherDay.spot = targetSpot
                            let fcst = json.objectForKey("fcst")?.objectForKey("3") as NSDictionary
                            let calendar = NSCalendar.currentCalendar()
                            let initTimeStamp = (fcst.objectForKey("initstamp") as NSNumber).doubleValue as NSTimeInterval
                            for var i = 0 ; i < (fcst.objectForKey("MCDC") as NSArray).count ; i++ {
                                let newWeatherTime = NSEntityDescription.insertNewObjectForEntityForName("WeatherTime", inManagedObjectContext: managedObjectContext) as WeatherTime
//                                newWeatherTime.date
                                let calendarUnit = NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitHour|NSCalendarUnit.CalendarUnitMinute|NSCalendarUnit.CalendarUnitSecond
                                
                                let dateComponents = calendar.components(calendarUnit, fromDate: NSDate(timeIntervalSince1970:initTimeStamp))
                                dateComponents.hour = ((fcst.objectForKey("hr_h") as NSArray).objectAtIndex(i) as NSString).integerValue
                                let day = ((fcst.objectForKey("hr_d") as NSArray).objectAtIndex(i) as NSString).integerValue
                                if dateComponents.day > day{
                                    dateComponents.month++
                                }
                                func abc(string:String) -> NSNumber?{
                                    if let object = (fcst.objectForKey(string) as NSArray).objectAtIndex(i) as? NSObject {
                                        if object == NSNull() {
                                            return nil
                                        }else{
                                            return object as? NSNumber
                                        }
                                    }else{
                                        return nil
                                    }
                                }
                                dateComponents.day = day
                                let dateA = calendar.dateFromComponents(dateComponents)
                                NSLog("%@", dateA!)
                                newWeatherDay.date = dateA!
                                newWeatherTime.updatedDate = NSDate()
                                newWeatherTime.windSpeed = (fcst.objectForKey("WINDSPD") as NSArray).objectAtIndex(i) as NSNumber
                                newWeatherTime.windGusts = (fcst.objectForKey("GUST") as NSArray).objectAtIndex(i) as NSNumber
                                newWeatherTime.windDirection = (fcst.objectForKey("WINDDIR") as NSArray).objectAtIndex(i) as NSNumber
                                newWeatherTime.temperature = (fcst.objectForKey("TMPE") as NSArray).objectAtIndex(i) as NSNumber
//                                newWeatherTime.isotherm = (fcst.objectForKey("WINDSPD") as NSArray).objectAtIndex(i) as NSNumber
                                if let value = abc("HCDC") {
                                    newWeatherTime.cloudCoverHigh = value
                                }
                                if let value = abc("MCDC") {
                                    newWeatherTime.cloudCoverMid = value
                                }
                                if let value = abc("LCDC") {
                                    newWeatherTime.cloudCoverLow = value
                                }
                                newWeatherTime.precip = (fcst.objectForKey("PCPT") as NSArray).objectAtIndex(i) as NSNumber
                                newWeatherTime.windguruRating = (fcst.objectForKey("WINDSPD") as NSArray).objectAtIndex(i) as NSNumber
                                newWeatherTime.weatherDay = newWeatherDay
                            }
                            
                        }
                        
                        
                    }
                }

            }

            
        }
        self.dataArray.addObjectsFromArray(managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "WeatherTime"), error: nil)!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if let weatherTime = self.dataArray.objectAtIndex(indexPath.row) as? WeatherTime {
            if let date = weatherTime.date {
                cell.textLabel.text = dateFormatter.stringFromDate(date)
            }
            cell.detailTextLabel?.text = weatherTime.temperature.stringValue
            
        }
        return cell
    }
    let dateFormatter:NSDateFormatter! = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

}

