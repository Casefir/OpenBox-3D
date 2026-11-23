import Foundation

/// A lightweight event channel, similar in spirit to Roblox's RBXScriptSignal.
///
///     let touched = Signal<String>()
///     let connection = touched.connect { print("Touched by \($0)") }
///     touched.fire("Builder")
///     connection.disconnect()
public final class Signal<Payload> {
    private var handlers: [UUID: (Payload) -> Void] = [:]

    public init() {}

    @discardableResult
    public func connect(_ handler: @escaping (Payload) -> Void) -> Connection {
        let key = UUID()
        handlers[key] = handler
        return Connection { [weak self] in
            self?.handlers[key] = nil
        }
    }

    public func fire(_ payload: Payload) {
        // Copy first so handlers may safely connect/disconnect while firing.
        let current = Array(handlers.values)
        for handler in current {
            handler(payload)
        }
    }
}

/// Handle returned by `Signal.connect` that lets you stop listening.
public final class Connection {
    private var onDisconnect: (() -> Void)?

    init(_ onDisconnect: @escaping () -> Void) {
        self.onDisconnect = onDisconnect
    }

    public func disconnect() {
        onDisconnect?()
        onDisconnect = nil
    }
}
