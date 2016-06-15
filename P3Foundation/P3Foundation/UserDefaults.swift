//
//  UserDefaults.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

private let userDefaults = UserDefaults.standard()

// MARK: - User Defaults Get

public func user_defaults_get_string(key: String) -> String {
    let s = userDefaults.object(forKey: key) as? String
    if let s = s {
        return s
    }
    
    return ""
}

public func user_defaults_get_bool(key: String) -> Bool {
    return userDefaults.bool(forKey: key)
}

public func user_defaults_get_integer(key: String) -> Int {
    return userDefaults.integer(forKey: key)
}


// MARK: - User Defaults Set

public func user_defaults_set_string(key: String, val: String?) -> Bool {
    userDefaults.set(val, forKey: key)
    return userDefaults.synchronize()
}

public func user_defaults_set_bool(key: String, val: Bool) -> Bool {
    userDefaults.set(val, forKey: key)
    return userDefaults.synchronize()
}

public func user_defaults_set_integer(key: String, val: Int) -> Bool {
    userDefaults.set(val, forKey: key)
    return userDefaults.synchronize()
}
