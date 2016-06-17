//
//  NSError.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

extension NSError {
    convenience public init(error: P3ErrorSpecification<Int, String, String>) {
        self.init(domain: error.domain, code: error.code, userInfo: [NSLocalizedDescriptionKey:error.errorDescription])
    }
    
    convenience public init(error: P3ErrorSpecification<Int, String, String>, userInfo: [NSString:AnyObject]) {
        self.init(domain: error.domain, code: error.code, userInfo: userInfo)
    }
}

