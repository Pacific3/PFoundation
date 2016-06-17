//
//  P3ErrorSpecification.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public struct P3ErrorSpecification<CodeType, DescriptionType, DomainType>: ErrorConvertible {
    var _code: CodeType
    var _desc: DescriptionType
    var _domain: DomainType
    
    public var code: CodeType {
        return _code
    }
    
    public var errorDescription: DescriptionType {
        return _desc
    }
    
    public var domain: DomainType {
        return _domain
    }
    
    public init<E: ErrorConvertible where E.Code == CodeType, E.Description == DescriptionType, E.Domain == DomainType>(ec: E) {
        _code = ec.code
        _desc = ec.errorDescription
        _domain = ec.domain
    }
}

