import Foundation

/// A 3D vector used for positions, sizes and velocities. Units are "studs".
public struct Vector3: Equatable {
    public var x: Double
    public var y: Double
    public var z: Double

    public static let zero = Vector3(0, 0, 0)
    public static let up = Vector3(0, 1, 0)

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    public static func * (vector: Vector3, scalar: Double) -> Vector3 {
        Vector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

    public static func * (scalar: Double, vector: Vector3) -> Vector3 {
        vector * scalar
    }

    public static prefix func - (vector: Vector3) -> Vector3 {
        Vector3(-vector.x, -vector.y, -vector.z)
    }

    public var magnitude: Double {
        (x * x + y * y + z * z).squareRoot()
    }

    public var unit: Vector3 {
        let length = magnitude
        return length > 0 ? self * (1 / length) : .zero
    }

    public func dot(_ other: Vector3) -> Double {
        x * other.x + y * other.y + z * other.z
    }
}

extension Vector3: CustomStringConvertible {
    public var description: String {
        String(format: "(%.2f, %.2f, %.2f)", x, y, z)
    }
}
