import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State
    var scale: Float = 1
    
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
                var physicsBody = PhysicsBodyComponent()
                
                entity.components.set(physicsBody)
                entity.components.set(GravityComponent())
                
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
        .onAppear {
            GravitySystem.registerSystem()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}

import RealityFoundation

final class GravitySystem: System {
    static let query = EntityQuery(where: .has(GravityComponent.self))
    static let defaultGravity: Float = 9.81
    let gravity: Float
    let mass: Float
    
    required init(scene: RealityFoundation.Scene) {
        self.gravity = 9.81 / 10
        self.mass = 1.0
    }
    
    func update(context: SceneUpdateContext) {
        guard gravity != Self.defaultGravity else { return }
        
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard let physicsBody = entity as? HasPhysicsBody else { return }
            let newG: Float = Self.defaultGravity - gravity
            
            let impulse = mass * newG * Float(context.deltaTime)
            physicsBody.applyLinearImpulse([0.0, impulse, 0.0], relativeTo: nil)
        }
    }
}

struct GravityComponent: Component {}
