//
//  ImageRecord.swift
//  TestProject
//
//  Created by Anson on 2015-12-12.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit

class ImageRecord{
    var urlString = ""
    var updateDate = NSDate()
    var data = NSData()
    var image: UIImage?
    
    init(imageRecordMO: ImageRecordMO){
        self.urlString = imageRecordMO.urlString
        self.updateDate = imageRecordMO.updateDate
        self.data = imageRecordMO.data
    }
    init(){}
}