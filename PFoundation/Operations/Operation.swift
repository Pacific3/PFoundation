public class Operation: NSOperation {
    
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
    private let stateLock = NSLock()
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            willChangeValueForKey("state")
            
            stateLock.withCriticalScope {
                guard _state != .Finished else {
                    return
                }
                
                assert(_state.canTransitionToState(newState, operationIsCancelled: cancelled), "invalid state transition.")
                _state = newState
            }
            
            didChangeValueForKey("state")
        }
    }
    
    
    // MARK: - Operation "readiness"
    private let readyLock = NSRecursiveLock()
    
    override public var ready: Bool {
        var _ready = false
        
        readyLock.withCriticalScope {
            switch state {
                
            case .Initialized:
                _ready = cancelled
                
            case .Pending:
                guard !cancelled else {
                    state = .Ready
                    _ready = true
                    return
                }
                
                if super.ready {
                    evaluateConditions()
                }
                
                _ready = false
                
            case .Ready:
                _ready = super.ready || cancelled
                
            default:
                _ready = false
            }
            
        }
        
        return _ready
    }
    
    private var _cancelled = false {
        willSet {
            willChangeValueForKey("cancelledState")
        }
        
        didSet {
            didChangeValueForKey("cancelledState")
            
            if _cancelled != oldValue && _cancelled == true {
                for observer in observers {
                    observer.operationDidCancel(self)
                }
            }
        }
    }
    
    override public var cancelled: Bool {
        return _cancelled
    }
    
    public var userInitiated: Bool {
        get {
            return qualityOfService == .UserInitiated
        }
        
        set {
            assert(state < .Executing, "Can't modify the state after user execution has begun.")
            
            qualityOfService = newValue ? .UserInitiated : .Default
        }
    }
    
    override public var executing: Bool {
        return state == .Executing
    }
    
    override public var finished: Bool {
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
    
    private(set) var observers = [OperationObserver]()
    public func addObserver(observer: OperationObserver) {
        assert(state < .Executing, "Can't modify observes after execution has begun.")
        
        observers.append(observer)
    }
    
    private(set) var conditions = [OperationCondition]()
    public func addCondition(condition: OperationCondition) {
        assert(state < .EvaluatingConditions, "Can't add conditions once execution has begun.")
        
        conditions.append(condition)
    }
    
    override public func addDependency(operation: NSOperation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    func evaluateConditions() {
        assert(state == .Pending && !cancelled, "evaluating conditions out of order!")
        
        state = .EvaluatingConditions
        
        guard conditions.count > 0 else {
            state = .Ready
            return
        }
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            if !failures.isEmpty {
                self.cancelWithErrors(failures)
            }
        
            
            self.state = .Ready
        }
        
    }
    
    // MARK: - Execution
    
    override final public func start() {
        super.start()
        
        if cancelled {
            finish()
        }
    }
    
    override final public func main() {
        assert(state == .Ready, "This operation must be performed by an operation queue.")
        
        if _internalErrors.isEmpty && !cancelled {
            state = .Executing
            
            for observer in observers {
                observer.operationDidStart(self)
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
    
    public final func produceOperation(operation: NSOperation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    
    override public func cancel() {
        if finished {
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
            finish([error])
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
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, errors: combinedErrors)
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
private func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
