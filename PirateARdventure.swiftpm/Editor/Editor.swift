//
//  SwiftUIView.swift
//  
//
//  Created by Yerik Koslowski on 11/04/23.
//

import SwiftUI
import SceneKit


// The instruction editor view
struct Editor: View {
    
    var run : (([PlayerAction])->Void) = {pa in}
    
    @State var text = "Banana"
    
    var level : GameLevel = GameLevel(elements: [], objective: BoardElement(boardPosition: SIMD2<Int>(4,4), boardSize: .one, meshName: "chest"))
    
    @State var instructions : [PlayerAction] = [
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            HStack(alignment: .center) {
                
                VStack {
                    BoardPreviewView(level: level)
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                ).ignoresSafeArea()
                
                Divider()
                VStack {
                    HStack {
                        Text("Editor")
                            .foregroundColor(.black)
                            .font(Font.custom("Nanum Pen", size: 48))
                            .padding(.bottom,16)
                        
                    }.frame(
                        maxWidth: .infinity
                    )
                    .background(Color(red:1,green:0x58/0xFF,blue:0x58/0xFF))
                    
                    HStack {
                        Button(action: {
                            instructions.append(PlayerAction(distance: 0, rotate: -1))
                        },label: {
                            Text("Add Turn Left")
                                .font(Font.custom("Nanum Pen", size: 32))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(Image("GemButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill))
                                .aspectRatio(contentMode: .fit)
                                
                                
                            
                        })
                        Button(action: {
                            instructions.append(PlayerAction(distance: 1, rotate: 0))
                        },label: {
                            Text("Add Forward")
                                .font(Font.custom("Nanum Pen", size: 32))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(Image("GemButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill))
                                .aspectRatio(contentMode: .fit)
                                
                                
                            
                        })
                        Button(action: {
                            instructions.append(PlayerAction(distance: 0, rotate: 1))
                        },label: {
                            Text("Add Turn Right")
                                .font(Font.custom("Nanum Pen", size: 32))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(Image("GemButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill))
                                .aspectRatio(contentMode: .fit)
                                
                                
                            
                        })
                        
                        
                    }
                    .padding()
                    .padding(.top,16)
                    
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
                            },
                                            up: {
                                if index < 1 {
                                    return
                                }
                                let tmp = instructions[index-1]
                                instructions[index-1] = instructions[index]
                                instructions[index] = tmp
                            },
                                            down: {
                                if index >= instructions.count - 1 {
                                    return
                                }
                                let tmp = instructions[index+1]
                                instructions[index+1] = instructions[index]
                                instructions[index] = tmp
                            }
                            )
                        }
                    }
                    .background(.clear)
                    
                    if instructions.count > 0 {
                        Button(action: {run(instructions)}, label: {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(maxWidth: 48,maxHeight:48)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.black)
                        Text("Run")
                            .font(Font.custom("Nanum Pen", size: 32))
                            .foregroundColor(Color(red:1,green:0x58/0xFF,blue:0x58/0xFF))
                            .padding()
                        
                        
                    })
                        
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
        .aspectRatio(CGSize(width: 2732, height: 2048), contentMode: .fit)
        
    }
}

struct InstructionCard: View {
    var instruction: PlayerAction
    var index: Int = 0
    var removeInstruction : (()->Void) = {}
    var increase : (()->Void) = {}
    var decrease : (()->Void) = {}
    var up : (()->Void) = {}
    var down : (()->Void) = {}
    
    var body: some View {
        HStack {
            VStack {
                Button(action: up, label: {
                    Image(systemName: "chevron.up.circle.fill")
                        .resizable()
                        .aspectRatio(1,contentMode: .fit)
                        .frame(maxWidth: 32)
                        .foregroundColor(Color(red: 0xDE/0xFF,green:0xB9/0xFF,blue:0x86/0xFF) )
                })
                Button(action: down, label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .aspectRatio(1,contentMode: .fit)
                        .frame(maxWidth: 32)
                        .foregroundColor(Color(red: 0xDE/0xFF,green:0xB9/0xFF,blue:0x86/0xFF) )
                })
            }
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
                .foregroundColor(Color(red:1,green:0x58/0xFF,blue:0x58/0xFF))
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
        Editor()
    }
}
