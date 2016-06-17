//
//  P3Operation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public class P3Operation: Operation {
    //MARK: - KVO
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state", "cancelledState"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsCancelled() -> Set<NSObject> {
        return ["cancelledState"]
    }
    
    // MARK: - State management
    
    private enum State: Int, Comparable {
        case Initialized
        case Pending
        case EvaluatingConditions
        case Ready
        case Executing
        case Finishing
        case Finished
        
        func canTransitionToState(target: State, operationIsCancelled cancelled: Bool) -> Bool {
            switch (self, target) {
            case (.Initialized, .Pending):
                return true
            case (.Pending, .EvaluatingConditions):
                return true
            case (.Pending, .Finishing) where cancelled:
                return true
            case (.Pending, .Ready) where cancelled:
                return true
            case (.EvaluatingConditions, .Ready):
                return true
            case (.Ready, .Executing):
                return true
            case (.Ready, .Finishing):
                return true
            case (.Executing, .Finishing):
                return true
            case (.Finishing, .Finished):
                return true
            default:
                return false
            }
        }
    }
    private var _state = State.Initialized
    private let stateLock = Lock()
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope {
                guard _state != .Finished else {
                    return
                }
                
                assert(_state.canTransitionToState(target: newState, operationIsCancelled: isCancelled), "invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    // MARK: - Operation "readiness"
    private let readyLock = RecursiveLock()
    
    override public var isReady: Bool {
        var _ready = false
        
        readyLock.withCriticalScope {
            switch state {
                
            case .Initialized:
                _ready = isCancelled
                
            case .Pending:
                guard !isCancelled else {
                    state = .Ready
                    _ready = true
                    return
                }
                
                if super.isReady {
                    evaluateConditions()
                }
                
                _ready = false
                
            case .Ready:
                _ready = super.isReady || isCancelled
                
            default:
                _ready = false
            }
            
        }
        
        return _ready
    }
    
    private var _cancelled = false {
        willSet {
            willChangeValue(forKey: "cancelledState")
        }
        
        didSet {
            didChangeValue(forKey: "cancelledState")
            
            if _cancelled != oldValue && _cancelled == true {
                for observer in observers {
                    observer.operationDidCancel(operation: self)
                }
            }
        }
    }
    
    override public var isCancelled: Bool {
        return _cancelled
    }
    
    public var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        
        set {
            assert(state < .Executing, "Can't modify the state after user execution has begun.")
            
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    override public var isExecuting: Bool {
        return state == .Executing
    }
    
    override public var isFinished: Bool {
        return state == .Finished
    }
    
    
    private var _internalErrors = [NSError]()
    func cancelWithError(error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    func didEnqueue() {
        state = .Pending
    }
    
    
    // MARK: - Observers, conditions, dependencies
    private(set) var observers = [P3OperationObserver]()
    public func addObserver(observer: P3OperationObserver) {
        assert(state < .Executing, "Can't modify observes after execution has begun.")
        
        observers.append(observer)
    }
    
    private(set) var conditions = [P3OperationCondition]()
    public func addCondition(condition: P3OperationCondition) {
        assert(state < .EvaluatingConditions, "Can't add conditions once execution has begun.")
        
        conditions.append(condition)
    }
    
    override public func addDependency(_ operation: Operation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    func evaluateConditions() {
        assert(state == .Pending && !isCancelled, "evaluating conditions out of order!")
        
        state = .EvaluatingConditions
        
        guard conditions.count > 0 else {
            state = .Ready
            return
        }
        
        OperationConditionEvaluator.evaluate(conditions: conditions, operation: self) { failures in
            if !failures.isEmpty {
                self.cancelWithErrors(errors: failures)
            }
            
            
            self.state = .Ready
        }
    }
    
    
    // MARK: - Execution
    override final public func start() {
        super.start()
        
        if isCancelled {
            finish()
        }
    }
    
    override final public func main() {
        assert(state == .Ready, "This operation must be performed by an operation queue.")
        
        if _internalErrors.isEmpty && !isCancelled {
            state = .Executing
            
            for observer in observers {
                observer.operationDidStart(operation: self)
            }
            
            execute()
        } else {
            finish()
        }
    }
    
    public func execute() {
        print("\(self.dynamicType) must override `execute()`.")
        finish()
    }
    
    public final func produceOperation(operation: Operation) {
        for observer in observers {
            observer.operation(operation: self, didProduceOperation: operation)
        }
    }
    
    override public func cancel() {
        if isFinished {
            return
        }
        
        _cancelled = true
        
        if state > .Ready {
            finish()
        }
    }
    
    
    // MARK: - Finishing
    public final func finishWithError(error: NSError?) {
        if let error = error {
            finish(errors: [error])
        } else {
            finish()
        }
    }
    
    public func cancelWithErrors(errors: [NSError]) {
        _internalErrors += errors
        cancel()
    }
    
    private var hasFinished = false
    public func finish(errors: [NSError] = []) {
        if !hasFinished {
            hasFinished = true
            state = .Finishing
            
            let combinedErrors = _internalErrors + errors
            finished(errors: combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(operation: self, errors: combinedErrors)
            }
            
            state = .Finished
        }
    }
    
    func finished(errors: [NSError]) {
        // Optional
    }
    
    override final public func waitUntilFinished() {
        fatalError("Nope!")
    }
}

// MARK: - Operators
private func <(lhs: P3Operation.State, rhs: P3Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: P3Operation.State, rhs: P3Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
