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
    
    var isTutorial : Bool = false
    
    @State var instructions : [PlayerAction] = [
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            HStack(alignment: .center) {
                
                VStack {
                    BoardPreviewView(level: level, showTutorial: isTutorial )
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                ).ignoresSafeArea()
                
                Divider()
                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Treasure Map")
                                .foregroundColor(.white)
                                .font(Font.custom("Nanum Pen", size: 48))
                            
                        }.frame(
                            maxWidth: .infinity
                        )
                        
                        
                        HStack {
                            Button(action: {
                                instructions.append(PlayerAction(distance: 0, rotate: -1))
                            },label: {
                                VStack {
                                    HStack {
                                        Image(systemName: "arrow.turn.up.left")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(maxWidth: 24,maxHeight:24)
                                    }.padding()
                                        .background(Image("EmeraldButton")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill))
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.black)
                                    
                                    Text("Turn left")
                                    .font(Font.custom("Nanum Pen", size: 24))
                                    .foregroundColor(.white)
                                    .padding(0)
                                    
                                }.frame(maxWidth: .infinity)
                                
                                
                                
                            }).padding(.trailing,16)
                            Button(action: {
                                instructions.append(PlayerAction(distance: 1, rotate: 0))
                            },label: {
                               VStack {
                                HStack {
                                    Image(systemName: "arrow.up")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .frame(maxWidth: 24,maxHeight:24)
                                        
                                }.padding()
                                    .background(Image("GemButton")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill))
                                    .aspectRatio(contentMode: .fit)
                                   
                                   Text("Go Forward")
                                   .font(Font.custom("Nanum Pen", size: 24))
                                   .foregroundColor(.white)
                                   .padding(0)
                                   
                            }.frame(maxWidth: .infinity)
                                
                            })
                            .padding(.leading,16)
                            .padding(.trailing,16)
                            Button(action: {
                                instructions.append(PlayerAction(distance: 0, rotate: 1))
                            },label: {
                                VStack {
                                 HStack {
                                     Image(systemName: "arrow.turn.up.right")
                                         .resizable()
                                         .foregroundColor(.black)
                                         .frame(maxWidth: 24,maxHeight:24)
                                         
                                 }.padding()
                                     .background(Image("SaphireButton")
                                         .resizable()
                                         .aspectRatio(contentMode: .fill))
                                     .aspectRatio(contentMode: .fit)
                                    
                                    Text("Turn right")
                                    .font(Font.custom("Nanum Pen", size: 24))
                                    .foregroundColor(.white)
                                    .padding(0)
                                    
                             }.frame(maxWidth: .infinity)
                                
                            }).padding(.leading,16)
                            
                            
                        }
                    }
                    .padding()
                    .background(Color(red: 61/255, green: 49/255, blue: 49/255))
                    
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
                            .foregroundColor(Color(red:1,green:0x58/0xFF,blue:0x58/0xFF))
                        Text("Run")
                            .font(Font.custom("Nanum Pen", size: 32))
                            .foregroundColor(Color(red:1,green:0x58/0xFF,blue:0x58/0xFF))
                            
                        
                        
                    }).padding()
                        
                    }
                    
                    
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .top
                ).background(Color(red: 80/255, green: 60/255, blue: 60/255))
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
                    
                    Text("\(instruction.getMagnitude())")
                        .font(Font.custom("Nanum Pen", size: 64))
                        .foregroundColor(.black)
                    
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
            Image(["sign-gem", "sign-saphire","sign-emerald"][instruction.getColor()])
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
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Editor()
    }
}
