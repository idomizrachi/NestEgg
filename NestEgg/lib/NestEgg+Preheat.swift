//
//  NestEgg+Preheat.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/11/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation

extension NestEgg {
    
    public func preheat(url: String) {
        self.fetch(url: url, completion: nil)
    }
    
    public func preheat(urls: [String]) {
        for url in urls {
            self.preheat(url: url)
        }
    }
}
