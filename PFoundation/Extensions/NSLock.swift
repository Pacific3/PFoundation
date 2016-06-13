
extension Lock {
    public func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

extension RecursiveLock {
    public func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
