import Foundation

/// Simple axis-aligned box physics. Good enough for platformers; not a full
/// rigid-body solver (no rotation, no friction, no body-to-body collision).
enum Physics {
    static func overlaps(_ a: BasePart, _ b: BasePart) -> Bool {
        let aMin = a.minCorner, aMax = a.maxCorner
        let bMin = b.minCorner, bMax = b.maxCorner
        return aMin.x < bMax.x && aMax.x > bMin.x
            && aMin.y < bMax.y && aMax.y > bMin.y
            && aMin.z < bMax.z && aMax.z > bMin.z
    }

    /// Pushes `body` out of `solid` along the axis of least penetration.
    /// Returns the push direction, or nil if the two boxes do not overlap.
    static func resolve(body: BasePart, against solid: BasePart) -> Vector3? {
        guard overlaps(body, solid) else { return nil }

        let bMin = body.minCorner, bMax = body.maxCorner
        let sMin = solid.minCorner, sMax = solid.maxCorner

        let overlapX = min(bMax.x, sMax.x) - max(bMin.x, sMin.x)
        let overlapY = min(bMax.y, sMax.y) - max(bMin.y, sMin.y)
        let overlapZ = min(bMax.z, sMax.z) - max(bMin.z, sMin.z)

        if overlapY <= overlapX && overlapY <= overlapZ {
            let direction: Double = body.position.y >= solid.position.y ? 1 : -1
            body.position.y += direction * overlapY
            if body.velocity.y * direction < 0 { body.velocity.y = 0 }
            return direction > 0 ? Vector3.up : -Vector3.up
        }

        if overlapX <= overlapZ {
            let direction: Double = body.position.x >= solid.position.x ? 1 : -1
            body.position.x += direction * overlapX
            if body.velocity.x * direction < 0 { body.velocity.x = 0 }
            return Vector3(direction, 0, 0)
        }

        let direction: Double = body.position.z >= solid.position.z ? 1 : -1
        body.position.z += direction * overlapZ
        if body.velocity.z * direction < 0 { body.velocity.z = 0 }
        return Vector3(0, 0, direction)
    }
}
