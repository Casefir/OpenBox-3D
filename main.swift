import OpenBoxCore

// Build a tiny world.
let world = Workspace()

world.addChild(Part(
    name: "Baseplate",
    position: Vector3(0, -0.5, 0),
    size: Vector3(200, 1, 200),
    color: .green
))

world.addChild(SpawnLocation(
    name: "SpawnLocation",
    position: Vector3(0, 0.5, 0),
    size: Vector3(6, 1, 6),
    color: .white
))

world.addChild(Part(
    name: "Wall",
    position: Vector3(30, 3, 0),
    size: Vector3(2, 6, 20),
    color: .gray
))

world.addChild(KillBrick(
    name: "Lava",
    position: Vector3(20, 0.5, 0),
    size: Vector3(10, 1, 10)
))

// Count lava touches with an event listener.
var lavaTouches = 0
world.playerTouched.connect { event in
    if event.part.name == "Lava" {
        lavaTouches += 1
    }
}

// A script that runs every frame.
let logger = Script(name: "Logger")
var elapsed = 0.0
logger.onStart = { print("[Logger] world started") }
logger.onUpdate = { dt in elapsed += dt }
world.addChild(logger)

// Spawn a player and walk them toward the lava.
let player = Player(name: "Builder")
world.addPlayer(player)

let fps = 60.0
for frame in 0..<240 {
    player.moveDirection = frame < 120 ? Vector3(1, 0, 0) : .zero
    if frame == 60 {
        player.jump()
    }
    world.step(1.0 / fps)
}

print("[Logger] simulated \(String(format: "%.2f", elapsed))s")
print("Player position: \(player.character.position)")
print("Lava touches: \(lavaTouches), deaths: \(player.deaths)")
