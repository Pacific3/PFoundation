
public typealias ValidCompletion = (Bool -> Void)

public protocol DataValidatable {
    var dataValidator: DataValidator? { get set }
    var dependency: DataValidatable? { get set }
    var dependent: DataValidatable? { get set }
    var hasValidData: Bool { get }
    var validationHandler: ValidCompletion? { get set }
    var feed: AnyObject { get }
    
    func refresh()
}

public extension DataValidatable {
    var hasValidData: Bool {
        guard let validator = dataValidator else {
            return false
        }
        
        guard let dependency = dependency else {
            return validator.validate(feed)
        }
        
        return dependency.hasValidData && validator.validate(feed)
    }
}

public protocol DataValidator {
    func validate(feed: Any) -> Bool
}

public enum DefaultValidator: DataValidator {
    case Positive
    case Negative
    
    public func validate(feed: Any) -> Bool {
        return self == .Positive
    }
}

public struct BetweenLengthString: DataValidator {
    public let max: Int
    public let min: Int
    
    public init(max: Int, min: Int) {
        self.max = max
        self.min = min
    }
    
    public func validate(feed: Any) -> Bool {
        guard let feed = feed as? String else {
            return false
        }
        
        return feed.characters.count >= min && feed.characters.count <= max
    }
}

public struct MaximumLengthString: DataValidator {
    public let length: Int
    
    public init(length: Int) {
        self.length = length
    }
    
    public func validate(feed: Any) -> Bool {
        guard let feed = feed as? String else {
            return false
        }
        
        return feed.characters.count <= length
    }
}

public struct MinimumLengthString: DataValidator {
    public let length: Int
    
    public init(length: Int) {
        self.length = length
    }
    
    public func validate(feed: Any) -> Bool {
        guard let feed = feed as? String else {
            return false
        }
        
        return feed.characters.count >= length
    }
}

public enum Match: String, DataValidator {
    case Email             = "^[_]*([a-z0-9]+(\\.|_*)?)+@([a-z][a-z0-9-]+(\\.|-*\\.))+[a-z]{2,6}$"
    case SixSymbolPassword = "^.{6,}$"
    case Domain            = "^([a-z][a-z0-9-]+(\\.|-*\\.))+[a-z]{2,6}$"
    case OneWord           = "^\\w+$"
    case TwoWords          = "^\\w+\\s\\w+$"
    case PositiveInteger   = "^\\d+$"
    case NegativeInteger   = "^-\\d+$"
    case Integer           = "^-?\\d+$"
    case PhoneNumber       = "^\\+?[\\d\\s]{3,}$"
    case PoneWithCode      = "^\\+?[\\d\\s]+\\(?[\\d\\s]{10,}$"
    case Year              = "^(19|20)\\d{2}$"
    case ZipCode           = "^\\d{5}(?:[-\\s]\\d{4})?$"
    
    public func validate(feed: Any) -> Bool {
        guard let feed = feed as? String,
            let _ = feed.rangeOfString(self.rawValue, options: .RegularExpressionSearch) else {
                return false
        }
        
        return true
    }
}

public enum Equal: DataValidator {
    case ToString(String)
    case ToInt(Int)
    case ToFloat(Float)
    case ToBool(Bool)
    
    public func validate(feed: Any) -> Bool {
        switch self {
        case .ToString(let x):
            guard let feed = feed as? String else {
                return false
            }
            
            return feed == x
            
        case .ToInt(let i):
            guard let feed = feed as? Int else {
                return false
            }
            
            return feed == i
            
        case .ToFloat(let f):
            guard let feed = feed as? Float else {
                return false
            }
            
            return feed == f
            
        case .ToBool(let b):
            guard let feed = feed as? Bool else {
                return false
            }
            
            return feed == b
        }
    }
}