import Foundation

/// An RGB color with components in 0...1.
public struct Color3: Equatable {
    public var r: Double
    public var g: Double
    public var b: Double

    public init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    public static let white = Color3(0.98, 0.98, 0.98)
    public static let gray = Color3(0.63, 0.64, 0.66)
    public static let red = Color3(0.89, 0.22, 0.22)
    public static let green = Color3(0.30, 0.72, 0.36)
    public static let blue = Color3(0.20, 0.45, 0.92)
    public static let orange = Color3(0.98, 0.56, 0.16)
}

/// A physical box in the world. `position` is the center of the box.
public class BasePart: Instance {
    public var position: Vector3
    public var size: Vector3
    public var color: Color3
    public var velocity: Vector3 = .zero
    /// Anchored parts never move. Unanchored parts are affected by gravity.
    public var anchored: Bool
    /// Whether the part blocks movement.
    public var canCollide: Bool
    /// Whether the part fires `touched` when something overlaps it.
    public var canTouch: Bool = true
    public var transparency: Double = 0

    /// Fires once when a body starts overlapping this part. Payload is the toucher.
    public let touched = Signal<BasePart>()

    public override var className: String { "BasePart" }

    public init(
        name: String,
        position: Vector3 = .zero,
        size: Vector3 = Vector3(4, 1, 2),
        color: Color3 = .gray,
        anchored: Bool = true,
        canCollide: Bool = true
    ) {
        self.position = position
        self.size = size
        self.color = color
        self.anchored = anchored
        self.canCollide = canCollide
        super.init(name: name)
    }

    public var minCorner: Vector3 { position - size * 0.5 }
    public var maxCorner: Vector3 { position + size * 0.5 }

    /// The point on the top face, centered. Useful for placing things on this part.
    public var topCenter: Vector3 {
        Vector3(position.x, position.y + size.y * 0.5, position.z)
    }
}

/// A standard static block.
public class Part: BasePart {
    public override var className: String { "Part" }
}

/// Where players appear when they join or respawn.
public final class SpawnLocation: BasePart {
    public override var className: String { "SpawnLocation" }
}

/// Touching a KillBrick respawns the player. Players walk straight through it.
public final class KillBrick: Part {
    public override var className: String { "KillBrick" }

    public init(name: String, position: Vector3, size: Vector3 = Vector3(4, 1, 4)) {
        super.init(
            name: name,
            position: position,
            size: size,
            color: .red,
            anchored: true,
            canCollide: false
        )
    }
}
