//
//  NestEgg+Errors.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/6/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation

extension NestEgg {
    
    private static func errorDomain() -> String {
        return "com.idomizrachi.nestegg"
    }
    
    public static func releasedError() -> NSError {
        return NSError(domain: self.errorDomain(), code: 1, userInfo: nil)
    }
    
    public static func notImageError() -> NSError {
        return NSError(domain: self.errorDomain(), code: 2, userInfo: nil)
    }
}
