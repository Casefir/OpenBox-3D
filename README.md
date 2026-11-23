# OpenBox

A Roblox-style game engine written in Swift. Build worlds from parts, walk players
around them, and attach scripts written in Swift instead of Lua.

OpenBox is an independent learning project. It is not affiliated with Roblox Corporation.

## Requirements

- Swift 5.9+ (macOS 13+ or iOS 16+ for the library; Linux also works with the toolchain)

## Quick start

```bash
swift run OpenBoxDemo
```

## Concepts

OpenBox mirrors the Roblox object model in a small, readable form.

| OpenBox            | Roblox equivalent     | Purpose                                          |
|--------------------|-----------------------|--------------------------------------------------|
| `Instance`         | `Instance`            | Base of the tree: name, parent, children         |
| `Workspace`        | `Workspace`           | Root of the world; runs the simulation           |
| `Part`             | `Part`                | Static or physical box                           |
| `SpawnLocation`    | `SpawnLocation`       | Where players appear                             |
| `KillBrick`        | `KillBrick`           | Touching it respawns the player                  |
| `Player`           | `Player`              | A person in the game, controlled by a character  |
| `Script`           | `Script`              | Swift closures run on start and every frame      |
| `Signal<Payload>`  | `RBXScriptSignal`     | Event connections with `connect` and `disconnect`|

### Example

```swift
let world = Workspace()
world.addChild(Part(name: "Floor", position: Vector3(0, -0.5, 0), size: Vector3(100, 1, 100)))
world.addChild(SpawnLocation(name: "Spawn", position: Vector3(0, 0.5, 0)))

let player = Player(name: "Alex")
world.addPlayer(player)

player.moveDirection = Vector3(1, 0, 0)  // walk along +x
player.jump()

while true {
    world.step(1.0 / 60.0)
}
```

### Physics

- Gravity applies to every unanchored part.
- Players collide with anchored parts that have `canCollide`.
- Collisions resolve along the axis of least penetration, so walking onto a floor
  stops you and jumping onto a ledge works.
- Overlaps with parts that have `canTouch` fire `playerTouched` once on entry.

### Scripting

Scripts are plain Swift closures:

```swift
let spinner = Script(name: "Spinner")
spinner.onUpdate = { dt in
    // move something each frame
}
world.addChild(spinner)
```

## Project layout

```
OpenBox/
├── Package.swift
├── Sources/
│   ├── OpenBoxCore/          # the engine library
│   │   ├── Vector3.swift     # math
│   │   ├── Signal.swift      # events
│   │   ├── Instance.swift    # object tree
│   │   ├── Part.swift        # parts, colors, special bricks
│   │   ├── Player.swift      # players and characters
│   │   ├── Physics.swift     # collision and resolution
│   │   └── Workspace.swift   # world, scripts, simulation loop
│   └── OpenBoxDemo/
│       └── main.swift        # runnable sample
└── README.md
```

## Roadmap

- Body-to-body collisions and friction
- Input abstraction for keyboard, touch and gamepad
- Mesh parts and a simple renderer (SceneKit or RealityKit)
- Networking for multiplayer
- A visual place editor
- Asset and model loading
