//
//  P3Foundation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

// MARK: - Constants
public let kP3ApplicationHasAlreadyRunOnce = "net.Pacific3.kP3ApplicationHasAlreadyRunOnce"
public let kP3ErrorDomain = "net.Pacific3.ErrorDomainSpecification"



// MARK: - Public Functions
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

public func p3_executeOnFirstLaunch(handler: ((Void) -> Void)?) {
    let hasRunOnce = UserDefaults.p3_getBool(key: kP3ApplicationHasAlreadyRunOnce)
    
    guard let handler = handler where !hasRunOnce else {
        return
    }
    
    handler()
    UserDefaults.p3_setBool(key: kP3ApplicationHasAlreadyRunOnce, value: true)
}


// MARK: - Internal
func encode(_ o: Any) -> String? {
    guard let string = o as? NSString else {
        return nil
    }
    
    return string.removingPercentEncoding
}
