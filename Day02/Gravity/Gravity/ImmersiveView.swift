import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView(
            make: { content in
                let mesh = MeshResource.generateSphere(radius: 0.5)
                let material = SimpleMaterial(color: .red, isMetallic: true)
                let collisionShape = ShapeResource.generateSphere(radius: 0.5)
                let entity = ModelEntity(
                    mesh: mesh,
                    materials: [material]
                )
                let physicsBody = PhysicsBodyComponent()
                entity.components.set(physicsBody)
                
                var physicsSimulation = PhysicsSimulationComponent()
                physicsSimulation.gravity = SIMD3(x: 0, y: -0.05, z: 0)
                entity.components.set(physicsSimulation)
                
                entity.components.set(
                    CollisionComponent(shapes: [collisionShape])
                )
                entity.components.set(
                    InputTargetComponent()
                )
                
                entity.position = SIMD3(x: 0, y: 2, z: -2)
                
                content.add(entity)
            }
        )
        .gesture(TapGesture().targetedToEntity(where: .has(PhysicsBodyComponent.self)).onEnded({ event in
            let physicsBodyEntity = event.entity as? HasPhysicsBody
            if let physicsBodyEntity {
                let force = SIMD3<Float>(x: 0, y: 100, z: 0)
                physicsBodyEntity.addForce(force, relativeTo: nil)
            }
        }))
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
