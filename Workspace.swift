import Foundation

/// A block of code attached to the tree. `onStart` runs once, `onUpdate` runs every step.
public final class Script: Instance {
    public var onStart: (() -> Void)?
    public var onUpdate: ((_ dt: Double) -> Void)?

    public override var className: String { "Script" }
}

/// The root of a game: owns the object tree, the players, and runs the simulation.
///
///     let world = Workspace()
///     world.addChild(Part(name: "Baseplate", position: .zero, size: Vector3(200, 1, 200)))
///     world.addChild(SpawnLocation(name: "Spawn", position: Vector3(0, 0.5, 0)))
///     let player = Player(name: "Builder")
///     world.addPlayer(player)
///     while running { world.step(1.0 / 60.0) }
public final class Workspace: Instance {
    public var gravity: Double = 196.2
    public private(set) var time: Double = 0
    public private(set) var players: [Player] = []

    /// Fires when a player first begins touching a part with `canTouch == true`.
    public let playerTouched = Signal<(player: Player, part: BasePart)>()

    private var startedScripts = Set<UUID>()

    public override var className: String { "Workspace" }

    public var parts: [BasePart] {
        descendants().compactMap { $0 as? BasePart }
    }

    public var spawnLocation: SpawnLocation? {
        firstDescendant(ofType: SpawnLocation.self)
    }

    public init() {
        super.init(name: "Workspace")

        // Built-in rule: touching a KillBrick respawns the player.
        playerTouched.connect { [weak self] event in
            guard event.part is KillBrick else { return }
            event.player.respawn(at: self?.spawnLocation)
        }
    }

    public func addPlayer(_ player: Player) {
        players.append(player)
        addChild(player.character)
        player.place(at: spawnLocation)
    }

    public func removePlayer(_ player: Player) {
        players.removeAll { $0 === player }
        player.character.destroy()
    }

    /// Advances the simulation by `dt` seconds.
    public func step(_ dt: Double) {
        time += dt

        // 1. Scripts
        for script in descendants().compactMap({ $0 as? Script }) {
            if startedScripts.insert(script.id).inserted {
                script.onStart?()
            }
            script.onUpdate?(dt)
        }

        let allParts = parts
        let dynamicBodies = allParts.filter { !$0.anchored }
        let solids = allParts.filter { $0.anchored && $0.canCollide }

        // 2. Player input: horizontal control and jumping
        for player in players {
            let body = player.character
            body.velocity.x = player.moveDirection.x * player.walkSpeed
            body.velocity.z = player.moveDirection.z * player.walkSpeed
            if player.isGrounded && player.jumpQueued {
                body.velocity.y = player.jumpPower
            }
            player.jumpQueued = false
            player.isGrounded = false
        }

        // 3. Gravity and integration
        for body in dynamicBodies {
            body.velocity.y -= gravity * dt
            body.position = body.position + body.velocity * dt
        }

        // 4. Collisions against static geometry
        for body in dynamicBodies where body.canCollide {
            let owner = players.first { $0.character === body }
            for solid in solids {
                if let normal = Physics.resolve(body: body, against: solid), normal.y > 0.5 {
                    owner?.isGrounded = true
                }
            }
        }

        // 5. Touch detection (fires on enter, not every frame)
        for player in players {
            let body = player.character
            var currentlyTouching = Set<UUID>()
            for part in allParts where part !== body && part.canTouch {
                guard Physics.overlaps(body, part) else { continue }
                currentlyTouching.insert(part.id)
                if !player.touching.contains(part.id) {
                    part.touched.fire(body)
                    playerTouched.fire((player: player, part: part))
                }
            }
            player.touching = currentlyTouching
        }
    }
}
