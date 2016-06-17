//
//  P3Error.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public enum P3Error: ErrorConvertible {
    case Error(Int, String)
    case None
    
    public var code: Int {
        return getCode()
    }
    
    public var errorDescription: String {
        return getErrorDescription()
    }
    
    public var domain: String {
        return kP3ErrorDomain
    }
    
    func getCode() -> Int {
        switch self {
        case let .Error(c, _):
            return c
            
        case .None:
            return -1001
        }
    }
    
    func getErrorDescription() -> String {
        switch self {
        case let .Error(_, d):
            return d
            
        case .None:
            return "Malformed error."
        }
    }
}
