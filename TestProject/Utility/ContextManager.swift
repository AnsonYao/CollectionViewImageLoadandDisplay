//
//  ContextManager.swift
//  TestProject
//
//  Created by Anson on 2015-12-09.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit
import CoreData

// The following constants are the strings in .xcdatamodeld




class ContextManager{
    
    // Get context on a private queue, for Async calls in CoreData.
    static func getPrivateContext() -> NSManagedObjectContext{
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = ContextManager.getMainContext()
        return context
    }
    
    // Get context on a UI main queue, only used as a parent.
    static func getMainContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainQueueContext = appDelegate.managedObjectContext
        return mainQueueContext
    }
    
    // Save main context
    static func saveMainContext(){
            do{
                try ContextManager.getMainContext().save()
            }
            catch{
                NSLog("main context failed to save")
            }
    }
}
