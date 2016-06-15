//
//  Lock.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

extension Lock {
    public func withCriticalScope<T>( block: @noescape(Void) -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

extension RecursiveLock {
    public func withCriticalScope<T>( block: @noescape(Void) -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
