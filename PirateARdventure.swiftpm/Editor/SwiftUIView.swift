//
//  SwiftUIView.swift
//  
//
//  Created by Yerik Koslowski on 11/04/23.
//

import SwiftUI
import SceneKit

struct SwiftUIView: View {
    
    @State var instructions : [PlayerAction] = [
        PlayerAction(distance: 1, rotate: 0),
        PlayerAction(distance: 0, rotate: 1),
        PlayerAction(distance: 0, rotate: -1),
        PlayerAction(distance: 8, rotate: 0)
    ]
    
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
                        ForEach(Array(instructions.enumerated()), id: \.offset) { index, action in
                            InstructionCard(instruction: action, index: index,
                                            removeInstruction: {
                                instructions.remove(at: index)
                            },
                                            increase: {
                                instructions[index].increaseMagnitude()
                            },
                                            decrease: {
                                if instructions[index].decreaseMagnitude() {
                                    instructions.remove(at: index)
                                }
                            }
                            )
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
    var removeInstruction : (()->Void) = {}
    var increase : (()->Void) = {}
    var decrease : (()->Void) = {}
    
    var body: some View {
        HStack {
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(index+1).")
                        .font(Font.custom("Nanum Pen", size: 32))
                    Text(instruction.getLabel())
                        .font(Font.custom("Nanum Pen", size: 32))
                    Text(instruction.getMagnitude() == 1 ? "Once":"\(instruction.getMagnitude()) Times")
                        .font(Font.custom("Nanum Pen", size: 37))
                        .fontWeight(.bold)
                }
                Spacer()
                HStack {
                    Button(action: decrease, label: {
                        Image(systemName:"minus.circle.fill")
                            .resizable()
                            .aspectRatio(1,contentMode: .fit)
                            .frame(maxWidth: 32)
                            .foregroundColor(.black)
                        
                        
                    })
                    
                    Text("\(instruction.getMagnitude())").font(Font.custom("Nanum Pen", size: 64))
                    
                    Button(action: increase, label: {
                        Image(systemName:"plus.circle.fill")
                            .resizable()
                            .aspectRatio(1,contentMode: .fit)
                            .frame(maxWidth: 32)
                            .foregroundColor(.black)
                        
                        
                    })
                }
            }.padding(.leading, 32)
                .padding(.trailing, 48)
            
        }
        .frame(maxWidth: 400,maxHeight: 200)
        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
        .background(
            Image("sign")
                .resizable()
        )
        Button(action: removeInstruction, label: {
            Image(systemName: "x.circle.fill")
                .resizable()
                .aspectRatio(1,contentMode: .fit)
                .frame(maxWidth: 32)
                .foregroundColor(.red)
        })
    }
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
