import Foundation

/// Base of the object tree. Everything in an OpenBox game (parts, players,
/// scripts, the workspace itself) is an `Instance` with a parent and children.
open class Instance {
    public let id = UUID()
    public var name: String
    public private(set) weak var parent: Instance?
    public private(set) var children: [Instance] = []

    open var className: String { "Instance" }

    public init(name: String) {
        self.name = name
    }

    public func addChild(_ child: Instance) {
        child.parent?.removeChild(child)
        child.parent = self
        children.append(child)
    }

    public func removeChild(_ child: Instance) {
        guard let index = children.firstIndex(where: { $0 === child }) else { return }
        children.remove(at: index)
        child.parent = nil
    }

    /// Removes this instance and everything beneath it from the tree.
    public func destroy() {
        parent?.removeChild(self)
        for child in children {
            child.destroy()
        }
    }

    public func findFirstChild(named name: String) -> Instance? {
        children.first { $0.name == name }
    }

    public func descendants() -> [Instance] {
        children.flatMap { [$0] + $0.descendants() }
    }

    public func firstDescendant<T: Instance>(ofType type: T.Type) -> T? {
        descendants().compactMap { $0 as? T }.first
    }
}
