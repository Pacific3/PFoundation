//
//  P3OperationExclusivityController.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

private let P3OperationExclusivityControllerSerialQueueLabel = "net.Pacific3.P3OperationExclusivityControllerSerialQueueLabel"

class P3OperationExclusivityController {
    static let sharedInstance = P3OperationExclusivityController()
    
    
    private let serialQueue = DispatchQueue(label: P3OperationExclusivityControllerSerialQueueLabel)
    
    private var operations: [String: [Operation]] = [:]
    
    private init() {}
    
    func addOperation(operation: Operation, categories: [String]) {
        serialQueue.sync {
            for category in categories {
                self.noqueue_addOperation(operation: operation, category: category)
            }
        }
    }
    
    func removeOperation(operation: Operation, categories: [String]) {
        serialQueue.sync {
            for category in categories {
                self.noqueue_removeOperation(operation: operation, category: category)
            }
        }
    }
    
    private func noqueue_addOperation(operation: Operation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)
        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_removeOperation(operation: Operation, category: String) {
        let matchingOperations = operations[category]
        
        if  var operationsWithThisCategory = matchingOperations,
            let index = operationsWithThisCategory.index(of: operation)
        {
            
            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }
}

