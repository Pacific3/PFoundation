//
//  P3OperationBlockObserver.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//


public typealias StartHandler = (Operation) -> Void
public typealias ProduceHandler = (Operation, Operation) -> Void
public typealias FinishHandler = (Operation, [NSError]) -> Void
public typealias CancelHandler = StartHandler

public struct P3OperationBlockObserver: P3OperationObserver {
    private let startHandler: StartHandler?
    private let produceHandler: ProduceHandler?
    private let finishHandler: FinishHandler?
    private let cancelHandler: CancelHandler?
    
    public init(startHandler: StartHandler? = nil, produceHandler: ProduceHandler? = nil, finishHandler: FinishHandler? = nil, cancelHandler: CancelHandler? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
        self.cancelHandler = cancelHandler
    }
    
    public func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
    
    public func operationDidCancel(operation: Operation) {
        cancelHandler?(operation)
    }
}

