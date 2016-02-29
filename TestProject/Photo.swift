//
//  Photo.swift
//  TestProject
//
//  Created by Anson on 2015-12-12.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit

class Photo{
    var albumId = 1
    var id = 1
    var title = ""
    var url = ""
    var thumbnailUrl = ""
    var imageRecord: ImageRecord?
    var isImageLoading = false
    var size = CGSize(width: 600, height: 600)
    
    func setValues(dict dict: Dictionary<String, AnyObject>){
        if let albumId = dict["albumId"] as? Int{
            self.albumId = albumId
        }
        if let id = dict["id"] as? Int{
            self.id = id
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

    func clearMemory(){
        if let record = imageRecord{
            record.image = nil
            imageRecord = nil
        }
    }
}