import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State
    var addSphere: Bool = false
    
    var body: some View {
        RealityView(
            make: { content, attachments in
                let anchor = AnchorEntity(.head)
                let tag = attachments.entity(for: "add-button")!
                tag.position = [0, -0.1, -0.5]
                anchor.addChild(tag)
                content.add(anchor)
            },
            update: { content, _ in
                if addSphere {
                    let sphere = makeSphere()
                    sphere.addForce([0, 10, 0], relativeTo: nil)
                    sphere.position = [0, 2, -2]
                    content.add(sphere)
                    addSphere = false
                }
            },
            attachments: {
                Attachment(id: "add-button") {
                    Button(action: {
                        addSphere.toggle()
                    }, label: {
                        Label {
                            Text("Add")
                        } icon: {
                            Image(systemName: "plus")
                        }

                    })
                    .glassBackgroundEffect()
                }
            }
        )
    }
    
    func makeSphere() -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.25)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let collisionShape = ShapeResource.generateSphere(radius: 0.25)
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
