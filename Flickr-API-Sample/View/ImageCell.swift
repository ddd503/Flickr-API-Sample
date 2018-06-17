//
//  ImageCell.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/17.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Kingfisher
import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var imageUrlString: String? {
        didSet {
            guard
                let imageUrlString = self.imageUrlString,
                let imageUrl = URL(string: imageUrlString) else { return }
            
            self.imageView.kf.setImage(with: imageUrl)
            
        }
    }
}
