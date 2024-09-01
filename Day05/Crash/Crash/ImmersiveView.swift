import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State
    var sphere: ModelEntity? = nil
    
    @State
    var isIdentity: Bool = true
    
    var body: some View {
        RealityView(
            make: { content, attachments in
                let anchor = AnchorEntity(.head)
                let tag = attachments.entity(for: "button")!
                tag.position = [0, -0.1, -0.5]
                anchor.addChild(tag)
                content.add(anchor)
                
                let sphere = makeSphere()
                sphere.name = "sphere"
                sphere.position = [-0.5, 2.0, -2.0]
                content.add(sphere)
                self.sphere = sphere
                
                let box = makeBox()
                box.name = "sphere"
                box.position = [0.5, 2.0, -2.0]
                box.physicsBody?.mode = .static
                content.add(box)
                
                _ = content.subscribe(
                    to: CollisionEvents.Began.self,
                    on: sphere,
                    { event in
                        event.entityA.removeFromParent()
                    }
                )
            },
            attachments: {
                Attachment(id: "button") {
                    Button(action: {
                        sphere?.addForce(
                            [100, 0, 0],
                            relativeTo: nil
                        )
                    }, label: {
                        Text("Strike")
                    })
                }
            }
        )
    }
    
    func makeSphere(radius: Float = 0.25, color: UIColor = .red) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let collisionShape = ShapeResource.generateSphere(radius: radius)
        let entity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        entity.components.set(CollisionComponent(shapes: [collisionShape]))
        var physicsBody = PhysicsBodyComponent()
        physicsBody.isAffectedByGravity = false
        entity.components.set(physicsBody)
        entity.components.set(PhysicsMotionComponent())
        entity.components.set(
            CollisionComponent(shapes: [collisionShape])
        )
        entity.components.set(
            InputTargetComponent()
        )
        
        return entity
    }
    
    func makeBox(size: Float = 0.25, color: UIColor = .green) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: size)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let collisionShape = ShapeResource.generateBox(size: [size, size, size])
        let entity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        entity.components.set(CollisionComponent(shapes: [collisionShape]))
        var physicsBody = PhysicsBodyComponent()
        physicsBody.isAffectedByGravity = false
        entity.components.set(physicsBody)
        entity.components.set(PhysicsMotionComponent())
        entity.components.set(
            CollisionComponent(shapes: [collisionShape])
        )
        entity.components.set(
            InputTargetComponent()
        )
        
        return entity
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
