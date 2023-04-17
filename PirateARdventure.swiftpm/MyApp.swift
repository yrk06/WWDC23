import SwiftUI
import AVFoundation

@main
struct MyApp: App {
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
    }
    
    
    
    init() {
        var cfURL = Bundle.main.url(forResource: "NanumPenScript-Regular", withExtension: "ttf")! as CFURL
        CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.process, nil)
        
        cfURL = Bundle.main.url(forResource: "Sketchbones-RpeE", withExtension: "ttf")! as CFURL
        CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.process, nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("There has been an error")
        }
    }
}
