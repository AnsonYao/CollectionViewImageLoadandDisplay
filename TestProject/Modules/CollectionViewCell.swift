//
//  CollectionViewCell.swift
//  TestProject
//
//  Created by Anson on 2015-12-09.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateImage(image: UIImage){
        imageView.image = image
    }
}
