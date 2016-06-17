//
//  P3OperationQueue.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

/**
 Objects conforming to this protocol can respond to events on a `OperationQueue` instance.
 */
@objc protocol P3OperationQueueDelegate: NSObjectProtocol {
    /**
     This method is called when the `OperationQueue` instance is about to add
     a new operation it itself.
     - Parameter operationQueue: the `OperationQueue` instance that called this
     method.
     - Parameter operation: the `Operation` or `Operation` that is about to
     be added to the queue.
     */
    @objc optional func operationQueue(operationQueue: OperationQueue, willAddOperation operation: Operation)
    
    /**
     This method is called when a `Operation` or `Operation` object finishes
     its execution within the `OperationQueue` instance.
     - Parameter operationQueue: the `OperationQueue` instance that called this
     method.
     - Parameter operation: The `Operation` or `Operation` that finished
     its execution within the `OperationQueue` instance.
     - Parameter errors: `NSError` array containing the errors (if any) that happened
     during the execution of the `Operation` or `Operation` instance that
     just finished its execution.
     */
    @objc optional func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: Operation, withErrors errors: [NSError])
}

/**
 `OperationQueue` is a generalization of `OperationQueue` that works with
 instances of `Operation`.
 
 To use `OperationQueue` you just need to call its designated initializer.
 
 ```swift
 let queue = OperationQueue()
 ```
 
 Then, you can add instances of `Operation` or `Operation` to it using the `addOperation(_:)` method.
 
 ```swift
 let op = Operation()
 queue.addOperation(op)
 ```
 
 - Attention:
 
 `OperationQueue` can also be used as a singleton.
 
 ```swift
 OperationQueue.sharedQueue.addOperation(op)
 ```
 */
public class P3OperationQueue: OperationQueue {
    /// Singleton object for `OperationQueue`. **Use carefully**.
    public static let sharedQueue = OperationQueue()
    
    /// The `OperationQueue`'s instance delegate.
    /// - SeeAlso: `protocol OperationQueueDelegate`
    weak var delegate: P3OperationQueueDelegate?
    

    override public func addOperation(_ operation: Operation) {
        if let op = operation as? P3Operation {
            
            let delegate = P3OperationBlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: {[weak self] in
                    if let q = self {
                        q.delegate?.operationQueue?(operationQueue: q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            op.addObserver(observer: delegate)
            
            let dependencies = op.conditions.flatMap {
                $0.dependencyForOperation(operation: op)
            }
            
            for dependency in dependencies {
                op.addDependency(dependency)
                addOperation(dependency)
            }
            
            let concurrencyCategories: [String] = op.conditions.flatMap { condition in
                if !condition.dynamicType.isMutuallyExclusive { return nil }
                
                return "\(condition.dynamicType)"
            }
            
            if !concurrencyCategories.isEmpty {
                let exclusivityController = P3OperationExclusivityController.sharedInstance
                
                exclusivityController.addOperation(operation: op, categories: concurrencyCategories)
                op.addObserver(observer:
                    P3OperationBlockObserver(
                        produceHandler: { operation, _ in
                            exclusivityController.removeOperation(operation: operation, categories: concurrencyCategories)
                        }
                    )
                )
            }
        } else {
            operation.addCompletion { [weak self, weak operation] in
                guard let queue = self, let operation = operation else { return }
                queue.delegate?.operationQueue?(operationQueue: queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue?(operationQueue: self, willAddOperation: operation)
        super.addOperation(operation)
        
        if let op = operation as? P3Operation {
            op.didEnqueue()
        }
    }
    
    override public func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        for operation in operations {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
                operation.waitUntilFinished()
            }
        }
    }
    
    public override init() { }
}

