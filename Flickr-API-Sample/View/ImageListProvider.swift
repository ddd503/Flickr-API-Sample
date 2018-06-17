//
//  ImageListProvider.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/17.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class ImageListProvider: NSObject {
    var imageList = [Photo]()
    
    func setPhotoList(imageList: [Photo]) {
        self.imageList.append(contentsOf: imageList)
    }
}

extension ImageListProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier,
                                                            for: indexPath) as? ImageCell else {
                                                                fatalError("cell is nil")
        }
        cell.imageUrlString = PhotoImageURLBuilder.build(with: imageList[indexPath.row])
        
        return cell
    }
}
