//
//  P3OperationCondition.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//


public let P3OperationConditionKey = "OperationCondition"

public protocol P3OperationCondition {
    static var name: String { get }
    static var isMutuallyExclusive: Bool { get }
    
    func dependencyForOperation(operation: Operation) -> Operation?
    func evaluateForOperation(operation: Operation, completion: (P3OperationCompletionResult) -> Void)
}

public enum P3OperationCompletionResult: Equatable {
    case Satisfied
    case Failed(NSError)
    
    var error: NSError? {
        if case .Failed(let error) = self {
            return error
        }
        
        return nil
    }
}

public func ==(lhs: P3OperationCompletionResult, rhs: P3OperationCompletionResult) -> Bool {
    switch (lhs, rhs) {
    case (.Satisfied, .Satisfied):
        return true
    case (.Failed(let lError), .Failed(let rError)) where lError == rError:
        return true
    default:
        return false
    }
}

struct OperationConditionEvaluator {
    static func evaluate(conditions: [P3OperationCondition], operation: Operation, completion: ([NSError]) -> Void) {
        let conditionGroup = DispatchGroup()
        
        var results = [P3OperationCompletionResult?]()
        
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluateForOperation(operation: operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        conditionGroup.notify(queue: DispatchQueue.global(attributes: .qosDefault)) {
            var failures = results.flatMap { $0?.error }
            
            if operation.isCancelled {
                failures.append(NSError(error: P3ErrorSpecification(ec: P3OperationError.ConditionFailed)))
            }
            
            completion(failures)
        }
    }
}

