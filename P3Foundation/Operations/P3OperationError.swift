//
//  P3OperationError.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//


internal let kP3OperationErrorDomain = "net.Pacific3.Foundation.OperationErrorDomain"

public enum P3OperationError: Int, ErrorConvertible {
    case ConditionFailed = 100
    case ExecutionFailed = 101
    
    public var code: Int {
        return self.rawValue
    }
    
    public var errorDescription: String {
        return self.description
    }
    
    public var domain: String {
        return kP3OperationErrorDomain
    }
}

extension P3OperationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ConditionFailed: return "Operation condition failed."
        case .ExecutionFailed: return "Operation execution failed."
        }
    }
}

public func ==(lhs: Int, rhs: P3OperationError) -> Bool {
    return lhs == rhs.rawValue
}

public func ==(lhs: P3OperationError, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}
