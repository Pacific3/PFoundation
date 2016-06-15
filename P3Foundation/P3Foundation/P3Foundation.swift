//
//  P3Foundation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public func p3_documentsDirectory() -> String? {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
}

public func p3_executeOnMainThread(handler: ((Void) -> Void)?) {
    if let block = handler {
        if Thread.isMainThread() {
            block()
        } else {
            DispatchQueue.main.sync(execute: block)
        }
    }
}

public func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}

public func p3_executeOnMainThread<A>(x: A?, handler: ((A) -> Void)?) {
    if Thread.isMainThread() {
        handler <*> x
    } else {
        DispatchQueue.main.async(execute: {
            handler <*> x
            }
        )
    }
}

public func p3_executeAfter(time: TimeInterval, handler: (Void) -> Void) {
    let when = DispatchTime.now() + (Double(NSEC_PER_SEC) * time)
    
    DispatchQueue.main.after(when: when, execute: handler)
}
