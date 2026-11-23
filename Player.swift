import Foundation

/// A person in the game. The player's avatar is `character`, a dynamic block
/// that the physics engine moves around the workspace.
public final class Player: Instance {
    public let character: BasePart

    /// Set this each frame, e.g. from keyboard or touch input. Only x and z are used.
    /// Length 1 means full speed.
    public var moveDirection: Vector3 = .zero
    public var walkSpeed: Double = 16
    public var jumpPower: Double = 50

    public internal(set) var isGrounded: Bool = false
    public private(set) var deaths: Int = 0

    internal var jumpQueued = false
    internal var touching = Set<UUID>()

    public override var className: String { "Player" }

    public init(name: String) {
        character = BasePart(
            name: name,
            position: .zero,
            size: Vector3(2, 5, 1),
            color: .blue,
            anchored: false,
            canCollide: true
        )
        super.init(name: name)
    }

    /// Request a jump. It takes effect on the next step if the player is grounded.
    public func jump() {
        jumpQueued = true
    }

    /// Kills the character and moves it back to the spawn.
    public func respawn(at spawn: SpawnLocation?) {
        deaths += 1
        place(at: spawn)
    }

    /// Moves the character to the spawn without counting it as a death.
    internal func place(at spawn: SpawnLocation?) {
        if let spawn {
            character.position = spawn.topCenter + Vector3(0, character.size.y * 0.5, 0)
        }
        character.velocity = .zero
        jumpQueued = false
        touching.removeAll()
    }
}
