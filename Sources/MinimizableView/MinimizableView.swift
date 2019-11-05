//
//  MinimizableView.swift

//
//  Created by Dominik Butz on 7/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//Version 0.1

import SwiftUI
import Combine

public class MinimizableViewState: ObservableObject {
    public init() {
        // necessary, otherwise compiler will complain that the initializer is internal...
    }
    @Published public var isPresented: Bool = false
    @Published public var isMinimized: Bool = false
}


public struct MinimizableView: View {
    
    @EnvironmentObject public var minimizableViewState: MinimizableViewState
    
     @State var draggedOffset = CGSize.zero
    
    let minimizedHeight: CGFloat
    let bottomMargin: CGFloat
    var expandedTopMargin: CGFloat
    var geometry: GeometryProxy
    
    var contentView:  AnyView
    var compactView: AnyView
   
    
     
     func offsetY()->CGFloat {
         
        if self.minimizableViewState.isPresented == false {
             return UIScreen.main.bounds.height
         } else {
             // is presenting
             return self.draggedOffset.height

         }

     }
     
     func frameHeight()->CGFloat {
         
        if self.minimizableViewState.isMinimized {
            return self.minimizedHeight
         } else {
            return geometry.size.height - self.expandedTopMargin
         }
     }
    
    func positionY()->CGFloat {
        self.minimizableViewState.isMinimized ? geometry.size.height  -  self.bottomMargin - (self.minimizedHeight / 2) :  (geometry.size.height + self.expandedTopMargin) / 2
    }

    public init<V>(content: V, compactView: V, minimizedHeight: CGFloat, bottomMargin: CGFloat, expandedTopMargin: CGFloat, geometry: GeometryProxy) where V: View {
        
        self.contentView = AnyView(content)
        self.compactView = AnyView(compactView)
        self.minimizedHeight = minimizedHeight
        self.geometry = geometry
        self.bottomMargin = bottomMargin
        self.expandedTopMargin = expandedTopMargin
   
    }
    
    public var body: some View {
        VStack {
            
          
            Capsule().fill(Color.gray).frame(width: 40, height: 5, alignment: .top).onTapGesture {
                self.minimizableViewState.isMinimized.toggle()
            }
            
            ZStack(alignment: .top) {

                self.contentView
                if self.minimizableViewState.isMinimized {
                    self.compactView.environmentObject(self.minimizableViewState)
                }
            }
        }.background( RoundedRectangle(cornerRadius: 8)
            .foregroundColor(Color(UIColor.systemBackground)).shadow(color:  Color(.systemGray3), radius: 5, x: 0, y: -5))
        
        .frame(
            width: geometry.size.width ,
            height: self.frameHeight())
        .position(CGPoint(x: geometry.size.width / 2, y: self.positionY()))
        .offset(y: self.offsetY())
        .animation(.spring())
        .gesture(DragGesture().onChanged({ (value) in
            
            if self.minimizableViewState.isMinimized == false  {
                if value.translation.height > 0 {
                    self.draggedOffset = value.translation
                    
                    if value.translation.height > 80 {
                        self.minimizableViewState.isMinimized = true
                    }
                }
            } else {
                
                if value.translation.height < 0 {
                    self.draggedOffset = value.translation
                    if value.translation.height < -100 {
                        self.minimizableViewState.isMinimized = false
                    }
                }
            }
            
        }).onEnded({ (value) in
            self.draggedOffset = CGSize.zero

        }))
        
    }
}



