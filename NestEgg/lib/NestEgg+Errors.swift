//
//  NestEgg+Errors.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/6/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation

extension NestEgg {
    public static func releasedError() -> NSError {
        return NSError(domain: "NestEgg", code: 0, userInfo: nil)
    }
    
    public static func notImageError() -> NSError {
        return NSError(domain: "NestEgg", code: 0, userInfo: nil)
    }
}
