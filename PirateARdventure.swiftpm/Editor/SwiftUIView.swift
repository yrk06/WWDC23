//
//  SwiftUIView.swift
//  
//
//  Created by Yerik Koslowski on 11/04/23.
//

import SwiftUI
import SceneKit

struct SwiftUIView: View {
    
    @State var instructions : [PlayerAction] = []
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            HStack(alignment: .center) {
                
                VStack {
                    BoardPreviewView()
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                ).ignoresSafeArea()
                
                Divider()
                VStack {
                    Text("Editor")
                        .font(.title)
                        .frame(
                            maxWidth: .infinity
                        )
                        .background(Color.red)
                    ScrollView() {
                        ForEach(instructions) { action in
                            InstructionCard(instruction: action)
                        }
                    }
                    .background(.clear)
                    
                    HStack {
                        Button("Is this real life", action: {
                            instructions.append(PlayerAction(distance: 1, rotate: 0))
                        })
                        Button("Is this just fantasy?", action: {})
                    }
                    
                    
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .top
                ).background(Color(red: 61/255, green: 49/255, blue: 49/255))
            }
        }
    }
}

struct InstructionCard: View {
    var instruction: PlayerAction
    var index: Int = 0
    
    var body: some View {
        HStack {
            HStack {
                Label().font(Font.custom("Nanum Pen", size: 48))
                Spacer()
                HStack {
                    Button(action: {}, label: {
                        Image(systemName:"minus.circle.fill")
                            .resizable()
                            .aspectRatio(1,contentMode: .fit)
                            .frame(maxWidth: 48)
                            .foregroundColor(.black)
                            
                        
                    })
                    
                    Text("\(Count())").font(Font.custom("Nanum Pen", size: 48))
                    
                    Button(action: {}, label: {
                        Image(systemName:"plus.circle.fill")
                            .resizable()
                            .aspectRatio(1,contentMode: .fit)
                            .frame(maxWidth: 48)
                            .foregroundColor(.black)
                        
                        
                    })
                }
            }.padding(.leading, 64)
                .padding(.trailing, 64)
            
        }
        .frame(maxWidth: 512,maxHeight: 256)
        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
        .background(
            Image("sign")
                .resizable()
        )
    }
    
    func Label() -> some View {
        for name in UIFont.familyNames {
            print(name)
            print(UIFont.fontNames(forFamilyName: name))
        }
        if instruction.rotate != 0 {
            return Text("\(index+1). Rotate \(instruction.rotate > 0 ? "right": "left") \(abs(instruction.rotate) == 1 ? "once" : "\(abs(instruction.rotate)) times")")
        } else {
            return Text("\(index+1). Forward \(abs(instruction.distance) == 1 ? "once" : "\(abs(instruction.distance)) times")")
        }
    }
    
    func Count() -> Int {
        if instruction.rotate != 0 {
            return abs(instruction.rotate)
        } else {
            return abs(instruction.distance)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
