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
                let tag = attachments.entity(for: "add-button")!
                tag.position = [0, -0.1, -0.5]
                anchor.addChild(tag)
                content.add(anchor)
                
                let sphere = makeSphere()
                sphere.name = "sphere"
                sphere.position = [0, 2.0, -2.0]
                sphere.scale = [0.5, 0.5, 0.5]
                content.add(sphere)
                self.sphere = sphere
            },
            attachments: {
                Attachment(id: "add-button") {
                    Toggle(isOn: $isIdentity, label: {
                        Text("Scale")
                    })
                    .frame(width: 200)
                    .padding()
                    .glassBackgroundEffect()
                }
            }
        ).onChange(of: isIdentity) { oldValue, newValue in
            let sphere = self.sphere!
            
            let from = sphere.transform
            var zero = from
            zero.scale = .zero
            var one = from
            one.scale = .one
            
            let fromTo = FromToByAnimation<Transform>(
                name: "scale",
                from: newValue ? zero : one,
                to: newValue ? one : zero,
                duration: 0.2,
                timing: .easeOut,
                bindTarget: .transform
            )
            let animation = try! AnimationResource
                .generate(with: fromTo)
            sphere.playAnimation(
                animation,
                transitionDuration: 0.5,
                startsPaused: false
            )
        }
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
