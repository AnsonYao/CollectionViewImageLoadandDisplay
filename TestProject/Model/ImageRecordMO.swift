//
//  ImageRecord.swift
//  TestProject
//
//  Created by Anson on 2015-12-11.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import CoreData
import UIKit
// The following constants are the strings in .xcdatamodeld
let CoreData_EntityName_ImageRecord = "ImageRecord"
let CoreData_ImageRecord_Data = "data"
let CoreData_ImageRecord_Date = "updateDate"
let CoreData_ImageRecord_URL = "urlString"

@objc
class ImageRecordMO: NSManagedObject{
    @NSManaged var urlString: String
    @NSManaged var updateDate: NSDate
    @NSManaged var data: NSData
    
    func setValues(record: ImageRecord){
        urlString = record.urlString
        updateDate = record.updateDate
        data = record.data
    }
    
    class func queryInBackground(url url: String, onComplete handler: (ImageRecord?, NSError?) -> Void){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            do{
                // Need to get a new context for background thread
                let context = ContextManager.getPrivateContext()
                let fetchRequest = NSFetchRequest(entityName: CoreData_EntityName_ImageRecord)
                fetchRequest.predicate = NSPredicate(format: "\(CoreData_ImageRecord_URL) == %@", url)
                let results = try context.executeFetchRequest(fetchRequest)
                let errorNotFound = NSError(domain: "Cocoa Query", code: 1, userInfo: ["message" : "obj not found"])
                let errorExpired = NSError(domain: "Cocoa Query", code: 1, userInfo: ["message" : "obj expired"])
                if results.count > 0 {
                    if let result = results[0] as? ImageRecordMO{
                        if NSDate().timeIntervalSinceDate(result.updateDate) > Cache_Expire_Time_Interval{
                            context.deleteObject(result)
                            handler(nil, errorExpired)
                        }
                        let record = ImageRecord(imageRecordMO: result)
                        dispatch_async(dispatch_get_main_queue()){
                            handler(record, nil)
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue()){
                            handler(nil, errorNotFound)
                        }
                    }
                }
                else{
                    dispatch_async(dispatch_get_main_queue()){
                        handler(nil, errorNotFound)
                    }
                }
            }
            catch{
                NSLog("Failure to fetch photo: \(error)")
            }
        }
    }
}