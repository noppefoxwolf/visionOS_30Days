import SwiftUI

struct ContentView: View {
    
    @Environment(\.openImmersiveSpace)
    var openImmersiveSpace
    
    var body: some View {
        Button {
            Task {
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
        } label: {
            Text("Start")
        }

    }
}

