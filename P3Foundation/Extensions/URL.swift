//
//  URL.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

extension URL {
    public func URLWithParams(params: [String:String])-> URL? {
        return URL(string: "\(self)?\(params.p3_URLEncodedString())")
    }
}
