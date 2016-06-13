
extension Operation {
    public func addCompletionBlock(block: Void -> Void) {
        if let existing = completionBlock {
            completionBlock = {
                existing()
                block()
            }
        } else {
            completionBlock = block
        }
    }
    
    public func addDependencies(dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
