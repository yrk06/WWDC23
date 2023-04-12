import SwiftUI
import ARKit

struct ContentView: View {
    var body: some View {
        //MainVCView()
        SwiftUIView()
    }
}


struct MainVCView : UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ARController();
    }
    
}

