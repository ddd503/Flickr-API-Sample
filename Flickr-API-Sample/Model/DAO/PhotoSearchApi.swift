//
//  PhotoSearchApi.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/15.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

/// API通信の結果
enum PhotoSearchAPIStatus {
    case successLoad(PhotoSearchResponse)
    case offline
    case emptyData
    case error(Error)
}

/// API通信の結果通知プロトコル
protocol PhotoSearchAPIDelegate: class {
    func searchResult(result: PhotoSearchAPIStatus)
}

/**
 APIと通信しAPIステータスをコントローラーへ返す
 */
final class PhotoSearchApi {
    
    private var isLoading = false
    private var requestCount = 1
    private var totalCount = 1
    
    // MARK: - リクエストカウント管理
    
    // 必要な取得開始ページを返す
    func current() -> Int {
        return requestCount
    }
    
    // ページカウントをリセット
    func reset() {
        requestCount = 1
    }
    
    // 追加取得の場合
    func incement() {
        requestCount += 1
    }
    
    // 取得カウントの更新
    func updateTotal(total: Int) {
        totalCount = total
    }
    
    /// 追加取得すべきかどうか
    ///
    /// - Returns: ture: する、false: しない
    func isMoreRequest() -> Bool {
        return totalCount > requestCount * SearchParamsBuilder.perPage
    }
    
    // MARK: - リクエスト可否判定
    
    /// API通信をするか
    ///
    /// - Returns: true: する、false: しない
    func waiting() -> Bool {
        return isLoading
    }
    
    weak var photoSearchAPIDelegate: PhotoSearchAPIDelegate?
    
    func requestAPI(seachWord: String) {
        
        if !ApiClient.onLineNetwork() {
            photoSearchAPIDelegate?.searchResult(result: .offline)
            return
        }
        
        isLoading = true
        
        let parameters = SearchParamsBuilder.create(searchWord: seachWord, page: current())
        
        let router = UrlRequester.searchAPI(parameters)
        
        ApiClient.request(router: router) { [weak self] result in
            switch result {
            case .success(let jsonData):
                do {
                    let decoder = JSONDecoder()
                    // スネークケースタイプKeyでもcodableしてくれる
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let photoSearchResponse = try decoder.decode(PhotoSearchResponse.self, from: jsonData)
                    
                    guard
                        let myClass = self,
                        myClass.validationCheck(response: photoSearchResponse) else {
                            return
                    }
                    
                    self?.photoSearchAPIDelegate?.searchResult(result: .successLoad(photoSearchResponse))
                    
                } catch let error {
                    self?.photoSearchAPIDelegate?.searchResult(result: .error(error))
                }
            case .failure(let error):
                self?.photoSearchAPIDelegate?.searchResult(result: .error(error))
            }
            self?.isLoading = false
        }
    }
    
    /// 各種バリデーションチェック（必要に応じて追加）
    private func validationCheck(response: PhotoSearchResponse) -> Bool {
        if response.photos.photo.isEmpty {
            /// 取得件数が0の時
            self.photoSearchAPIDelegate?.searchResult(result: .emptyData)
            return false
        }
        return true
    }
}
