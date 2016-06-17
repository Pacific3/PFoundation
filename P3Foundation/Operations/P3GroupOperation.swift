//
//  P3GroupOperation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/17/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//


/**
 `GroupOperation` is a subclass of `Operation` that represents a group of
 `Operations` that together repesent a whole operation.
 */
public class P3GroupOperation: P3Operation {
    public let internalQueue = P3OperationQueue()
    private let startingOperation = BlockOperation(block: {})
    private let finishingOperation = BlockOperation(block: {})
    
    private var aggregatedErrors = [NSError]()
    
    convenience public init(operations: Operation...) {
        self.init(operations: operations)
    }
    
    /**
     Designated initializer that takes an array of `Operation`s and adds them
     to an internal `OperationQueue` instance that is in a "suspended" state.
     
     The `Operation`s in the internal queue won't start executing until the
     `GroupOperation` instance is added to an instance of `OperationQueue`
     itself.
     */
    public init(operations: [Operation]? = nil) {
        super.init()
        
        prepare()
        if let ops = operations {
            addOperations(operations: ops)
        }
    }
    
    private func prepare() {
        internalQueue.isSuspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)
    }
    
    /// Cancels all the operations on the internal queue.
    override public func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override public func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    public func addOperation(operation: Operation) {
        internalQueue.addOperation(operation)
    }
    
    public final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    public func operationDidFinish(operation: Operation, withErrors errors: [NSError]) {
        // Subclassing!
    }
    
    public func addOperations(operations: [Operation]) {
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
}

extension P3GroupOperation: P3OperationQueueDelegate {
    final func operationQueue(operationQueue: OperationQueue, willAddOperation operation: Operation) {
        assert(!finishingOperation.isFinished && !finishingOperation.isExecuting, "Cannot add new operations to a group after the group hasc completed!")
        
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    
    final func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: Operation, withErrors errors: [NSError]) {
        aggregatedErrors.append(contentsOf: errors)
        
        if operation === finishingOperation {
            internalQueue.isSuspended = true
            finish(errors: aggregatedErrors)
        } else if operation !== startingOperation {
            operationDidFinish(operation: operation, withErrors: errors)
        }
    }
}

