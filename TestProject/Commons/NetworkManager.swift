//
//  File.swift
//  TestProject
//
//  Created by Anson on 2015-12-09.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit
import CoreData

public class NetworkManager {
    static func getPhotosinBackground(url urlString: String, onCompletion handler: ([Photo]) -> Void){
        if let url = NSURL(string: urlString){
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let error = error{
                    NSLog(error.description)
                }
                else{
                    if let data = data{
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [Dictionary<String, AnyObject>]{
                                var photos = [Photo]()
                                for dict in json{
                                    let photo = Photo()
                                    photo.setValues(dict: dict)
                                    photos.append(photo)
                                }
                                dispatch_async(dispatch_get_main_queue()){
                                    handler(photos)
                                }
                            }
                        }
                        catch let error as NSError{
                            NSLog(error.description)
                        }
                    }
                }
            })
        // fetch data in background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            task.resume()
        }
    }
}


static func getImageRecordinBackground(url urlString: String, onCompletion handler: (ImageRecord) -> Void){
    NSLog("photoURL: " + urlString)
    if let url = NSURL(string: urlString){
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            if let error = error{
                NSLog(error.description)
            }
            else{
                if let data = data{
                    let imageRecord = ImageRecord()
                    imageRecord.data = data
                    imageRecord.urlString = urlString
                    dispatch_async(dispatch_get_main_queue()){
                        handler(imageRecord)
                    }
                }
            }
        })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            task.resume()
        }
    }
}

}


