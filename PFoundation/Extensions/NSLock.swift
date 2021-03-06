
extension NSLock {
    public func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

extension NSRecursiveLock {
    public func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}