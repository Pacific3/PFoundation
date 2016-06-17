//
//  ErrorConvertible.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public protocol ErrorConvertible {
    associatedtype Code
    associatedtype Description
    associatedtype Domain
    
    var code: Code { get }
    var errorDescription: Description { get }
    var domain: Domain { get }
}
