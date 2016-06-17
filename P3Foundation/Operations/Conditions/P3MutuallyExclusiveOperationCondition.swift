//
//  P3MutuallyExclusiveOperationCondition.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/17/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public struct MutuallyExclusive<T>: P3OperationCondition {
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> Operation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: (P3OperationCompletionResult) -> Void) {
        completion(.Satisfied)
    }
}

