
public struct MutuallyExclusive<T>: OperationCondition {
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    public init() { }
    
    public func dependencyForOperation(operation: Operation) -> Operation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void) {
        completion(.Satisfied)
    }
}
