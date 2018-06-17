//
//  SearchParamsBuilder.swift
//  Flickr-API-Sample
//
//  Created by kawaharadai on 2018/06/15.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

final class SearchParamsBuilder {
    
    /// 通信に使用するのAPIKey
    static let apiKey = "自身のkey"
    
    /// 1ページあたりの表示件数
    static let perPage = 50
    
    /// 検索ワードを受け取り、必要なパラメータをセットして返す
    ///
    /// - Parameter searchWord: 検索ワード
    /// - Returns: パラメータの配列
    static func create(searchWord: String, page: Int) -> [String: Any] {
        var params = [String: Any]()
        params["method"] = "flickr.photos.search"
        params["api_key"] = apiKey
        params["nojsoncallback"] = "1"
        params["format"] = "json"
        params["tags"] = searchWord
        params["per_page"] = "\(perPage)"
        params["page"] = "\(page)"
        return params
    }
}
