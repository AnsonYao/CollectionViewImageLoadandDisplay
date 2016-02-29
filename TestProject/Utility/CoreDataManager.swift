//
//  DataPersistanceManager.swift
//  TestProject
//
//  Created by Anson on 2015-12-13.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager{
    
    static func saveImageRecordInBackground(record: ImageRecord){
        let context = ContextManager.getPrivateContext()
        context.performBlock { () -> Void in
            let entity = NSEntityDescription.entityForName(CoreData_EntityName_ImageRecord, inManagedObjectContext: context)
            let imageRecord = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! ImageRecordMO
            imageRecord.setValues(record)
            do{
                try context.save()
            }
            catch{
            }

        }
    }
    
    static func mergeAndSaveContext(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            do{
                try ContextManager.getMainContext().save()
            }
            catch{
            }
        })
    }

}