//
//  PhotoSearchViewController.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/15.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class PhotoSearchViewController: UIViewController {
    
    @IBOutlet weak var photoListCollectionView: UICollectionView!
    @IBOutlet weak var photoSearchBar: UISearchBar!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var notingView: UIView!
    
    private let photoSearchApi = PhotoSearchApi()
    private let provider = ImageListProvider()
    
    private var tags = ""
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - private
    private func setup() {
        self.photoSearchApi.photoSearchAPIDelegate = self
        self.photoListCollectionView.delegate = self
        self.photoListCollectionView.dataSource = self.provider
        self.photoSearchBar.delegate = self
        self.photoSearchBar.placeholder = "キーワードを入力してください"
    }
    
    private func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
        
        photoSearchApi.reset()
    }
}

// MARK: - PhotoSearchAPIDelegate
extension PhotoSearchViewController: PhotoSearchAPIDelegate {
    func searchResult(result: PhotoSearchAPIStatus) {
       
        switch result {
        case .successLoad(let result):
            self.photoSearchApi.updateTotal(total: result.photos.pages)
            self.provider.setPhotoList(imageList: result.photos.photo)
            
            if self.photoSearchApi.current() == 1 {
                // 検索時にスクロールを上まで戻す
                self.photoListCollectionView.scrollToTop()
            }
            
            DispatchQueue.main.async {
                self.photoListCollectionView.reloadData()
                self.notingView.isHidden = true
            }
        case .error(let error):
            self.showAlert(title: "エラーが発生しました", message: "エラーコード：\(error.nsError.code)")
        case .offline:
            self.showAlert(title: "ネットワーク環境の良い環境で再度お試しください。", message: nil)
        case .emptyData:
            self.showAlert(title: "検索結果は0件です。", message: nil)
            self.notingView.isHidden = false
        }
        
        self.indicator.stopAnimating()
        self.indicatorView.isHidden = true
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoSearchViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard hasMorePhotoList() else {
            return
        }
        nextloadPhotoList()
    }
    
    private func hasMorePhotoList() -> Bool {
        
        if photoListCollectionView.isScrollEnd() {
            
            if photoSearchApi.waiting() {
                return false
            }
            return photoSearchApi.isMoreRequest()
        }
        return false
    }
    
    private func nextloadPhotoList() {
        photoSearchApi.incement()
        photoSearchApi.requestAPI(seachWord: self.tags)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoSearchViewController: UICollectionViewDelegateFlowLayout {
    
    // アイテムの大きさを設定
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = self.view.frame.width / 3 - 1 // セル同士の横幅分の1
        
        return CGSize(width: size, height: size)
    }
    
    // コレクションビュー自体の周りのinset（セル同士のinsetはstoryboardで）
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let inset: CGFloat = 0
        
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
}

// MARK: - UISearchBarDelegate
extension PhotoSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchWord = searchBar.text else {
            return
        }
        self.tags = searchWord
        self.provider.imageList = []
        photoSearchApi.reset()
        
        self.indicatorView.isHidden = false
        self.indicator.startAnimating()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.photoSearchApi.requestAPI(seachWord: self.tags)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.canResignFirstResponder {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
        }
    }
}

// Error側をNSErrorも使えるように拡張
extension Error {
    fileprivate var nsError: NSError {
        return (self as NSError)
    }
}

extension UIScrollView {
    
    // スクロールを上まで戻す
    func scrollToTop(animated: Bool = false) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
    
    /// スクロールが終わっているか
    ///
    /// - Returns: true: 終わっている、false: 終わっていない
    func isScrollEnd() -> Bool {
        return self.contentOffset.y >= (self.contentSize.height - self.bounds.size.height)
    }
}
