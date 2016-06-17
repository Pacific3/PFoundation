//
//  P3OperationObserver.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public protocol P3OperationObserver {
    func operationDidStart(operation: Operation)
    func operation(operation: Operation, didProduceOperation newOperation: Operation)
    func operationDidFinish(operation: Operation, errors: [NSError])
    func operationDidCancel(operation: Operation)
}

