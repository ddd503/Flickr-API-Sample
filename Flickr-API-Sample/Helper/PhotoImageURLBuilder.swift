//
//  PhotoImageURLBuilder.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/17.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

final class PhotoImageURLBuilder {
    
    static func build(with photo: Photo) -> String {
        return "https://farm\(String(describing: photo.farm)).staticflickr.com/" +
        "\(String(describing: photo.server))/\(String(describing: photo.photoId))_" +
        "\(String(describing: photo.secret)).jpg"
    }
}
