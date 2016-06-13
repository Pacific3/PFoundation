
extension Array {
    public mutating func remove<U: Equatable>(item itemToRemove: U) {
        var index: Int?
        for (idx, item) in self.enumerated() {
            if let item = item as? U
                where item == itemToRemove {
                    index = idx
            }
        }
        
        if let index = index {
            self.remove(at: index)
        }
    }
}
