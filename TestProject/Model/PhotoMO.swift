//
//  Photo.swift
//  TestProject
//
//  Created by Anson on 2015-12-09.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import CoreData

// The following constants are the strings in .xcdatamodeld
let CoreData_EntityName_Photo = "Photo"
let CoreData_Photo_Album = "albumId"
let CoreData_Photo_Id = "id"
let CoreData_Photo_Url = "url"
let CoreData_Photo_Title = "title"
let CoreData_Photo_Thumbnail = "thumbnailUrl"

@objc
class PhotoMO: NSManagedObject{
    
    // @NSManaged property names (need to be consistent with the attributes in core data)
    @NSManaged var albumId: Int64
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var thumbnailUrl: String
    
    var imageRecord: ImageRecordMO?
    
    
    func setValues(dict dict: Dictionary<String, AnyObject>){
        if let albumId = dict["albumId"] as? Int{
            self.albumId = Int64(albumId)
        }
        if let id = dict["id"] as? Int{
            self.id = Int64(id)
        }
        if let title = dict["title"] as? String{
            self.title = title
        }
        if let urlString = dict["url"] as? String{
            self.url = urlString
        }
        if let thumbnailUrlString = dict["thumbnailUrl"] as? String{
            self.thumbnailUrl = thumbnailUrlString
        }
    }
    
    class func queryInBackground(id id: Int32, onComplete handler: (PhotoMO) -> Void){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            do{
                let privateQueueContext = ContextManager.getPrivateContext()
                let fetchRequest = NSFetchRequest(entityName: CoreData_EntityName_Photo)
                fetchRequest.predicate = NSPredicate(format: "\(CoreData_Photo_Id) == %@", id)
                let results = try privateQueueContext.executeFetchRequest(fetchRequest)
                if let result = results[0] as? PhotoMO{
                    dispatch_async(dispatch_get_main_queue()){
                        handler(result)
                    }
                }
            }
            catch{
                NSLog("Failure to fetch photo: \(error)")
            }
        }
    }
    
}
