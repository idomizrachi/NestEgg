//
//  NestEggHttpClient.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/6/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation


@objc public class NestEggHttpRequest: NSObject {
    public var url: String
    public var headers: [String:String]?
    
    init(url: String, headers: [String:String]? = nil) {
        self.url = url
        self.headers = headers
    }    
}

@objc public class NestEggHttpResponse: NSObject {
    public var data: NSData? = nil
    public var error: NSError? = nil
    
    init(data: NSData) {
        self.data = data
    }
    
    init(error: NSError) {
        self.error = error
    }
}

@objc public protocol NestEggHttpClient {
    func execute(request: NestEggHttpRequest, response: @escaping(NestEggHttpResponse) -> ())
}
