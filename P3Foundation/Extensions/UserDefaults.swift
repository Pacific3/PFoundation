//
//  UserDefaults.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

private let userDefaults = UserDefaults.standard()

extension UserDefaults {
    // MARK: - Get Values
    static func p3_getString(key: String) -> String {
        let s = userDefaults.object(forKey: key) as? String
        if let s = s {
            return s
        }
        
        return ""
    }
    
    static func p3_getBool(key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    static func p3_getInt(key: String) -> Int {
        return userDefaults.integer(forKey: key)
    }
    
    
    // MARK: - Set Values
    @discardableResult
    static func p3_setString(key: String, value: String) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.synchronize()
    }
    
    @discardableResult
    static func p3_setBool(key: String, value: Bool) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.synchronize()
    }
    
    @discardableResult
    static func p3_setInt(key: String, value: Int) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.synchronize()
    }
}
