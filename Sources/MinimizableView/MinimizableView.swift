//
//  MinimizableView.swift

//
//  Created by Dominik Butz on 7/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//Version 0.1.2

import SwiftUI
import Combine

/**
Handler for MinimizableView. Must be attached as Environment Object to Minimizable View, to your content view parameter and to your compact view parameter.
*/
public class MinimizableViewHandler: ObservableObject {
    
    
    /**
    Handler Initializer. Although it is empty, it is necessary to set it with the public keyword, otherwise the compiler will throw an error.

    - Parameter recipient: The person being greeted.

    - Throws: `MyError.invalidRecipient`
              if `recipient` is "Derek"
              (he knows what he did).

    - Returns: A new string saying hello to `recipient`.
    */
    
    /**
    Handler Initializer. Although it is empty, it is necessary to set it with the public keyword, otherwise the compiler will throw an error.
    */
    public init() {}
    
    public var onPresentation: (()->Void)?
    public var onDismissal:(()->Void)?
    public  var onExpansion: (()->Void)?
    public var onMinimization: (()->Void)?
    
    /**
    Call this function to present the minimizable view instead of setting isPresented to true directly.
    */
    public func present() {
        
        if self.isPresented == false {
            self.isPresented = true
            
        }
  
    }
    
    /**
    Call this function to dismiss the minimizable view instead of setting isPresented to false directly.
    */
    public func dismiss() {
        
        if self.isPresented == true {
            self.isPresented = false
           
        }
    }
    
    /**
    Call this function to minimize the minimizable view instead of setting  isMinimized to true directly.
    */
    public func minimize() {
        
        if self.isMinimized == false  {
            self.isMinimized = true
            
        }
    }
    
    /**
    Call this function to expand the minimizable view instead of setting i  isMinimized to false directly.
    */
    public func expand() {
        if self.isMinimized == true  {
            self.isMinimized = false
           
        }
    }
    

    /**
    Published variable  get the presentation state of the minimizable view.
    */
    @Published public var isPresented: Bool = false {
        didSet {
            if isPresented {
                self.onPresentation?()
            } else {
                self.onDismissal?()
            }
        }
    }
    
    /**
    Published variable get the expansion state of the minimizable view.
    */
    @Published  public var isMinimized: Bool = false {
        didSet {
            if isMinimized {
                self.onMinimization?()
            } else {
                self.onExpansion?()
            }
        }
    }
}

/**
MinimizableView.
*/
public struct MinimizableView: View {
    
    /**
    MinimizableView Handler. must be attached to the MinimizableView.
    */
    @EnvironmentObject public var minimizableViewHandler: MinimizableViewHandler
    
     @State var draggedOffset = CGSize.zero
    
    let minimizedHeight: CGFloat
    let bottomMargin: CGFloat
    var expandedTopMargin: CGFloat
    var geometry: GeometryProxy
    
    var contentView:  AnyView
    var compactView: AnyView
   

     func offsetY()->CGFloat {
         
        if self.minimizableViewHandler.isPresented == false {
             return UIScreen.main.bounds.height
         } else {
             // is presenting
             return self.draggedOffset.height

         }

     }
     
     func frameHeight()->CGFloat {
         
        if self.minimizableViewHandler.isMinimized {
            return self.minimizedHeight
         } else {
            return geometry.size.height - self.expandedTopMargin
         }
     }
    
    func positionY()->CGFloat {
        self.minimizableViewHandler.isMinimized ? geometry.size.height  -  self.bottomMargin - (self.minimizedHeight / 2) :  (geometry.size.height + self.expandedTopMargin) / 2
    }

    /**
    MinimizableView Initializer.

    - Parameter content: the view that should be embedded inside the MinimizableView. Important: cast the view to: AnyView(yourView).
     
    - Parameter compactView: the view that will be shown at the top of the MinimizableView in minimized state. Important: cast the view to: AnyView(yourCompactView).
     
    - Parameter minimizedHeight: The  total height  (CGFloat value) of the MinimizedView in minimized state. Should be about 15.0 larger than your compact view height.
     
    - Parameter bottomMargin:The margin in minimized state to the bottom of the view in which the minimzed view is embedded in.
     
    - Parameter expandedTopMargin: The margin to the top (usually the status bar) in expanded state.
     
    - Parameter geometry: Embed the ZStack, in which the MinimizableView resides, in a geometry reader.  This will allow the MinimizableView to adapt to a changing screen orientation.
    */
    public init<V>(content: V, compactView: V, minimizedHeight: CGFloat, bottomMargin: CGFloat, expandedTopMargin: CGFloat, geometry: GeometryProxy) where V: View {
        
        self.contentView = AnyView(content)
        self.compactView = AnyView(compactView)
        self.minimizedHeight = minimizedHeight
        self.geometry = geometry
        self.bottomMargin = bottomMargin
        self.expandedTopMargin = expandedTopMargin
   
    }
    
    /**
       Body of the MinimizableView.
    */
    public var body: some View {
        VStack {

            Capsule().fill(Color.gray).frame(width: 40, height: 5, alignment: .top).onTapGesture {
                self.minimizableViewHandler.isMinimized.toggle()
            }
            
            ZStack(alignment: .top) {

                self.contentView
                
                if self.minimizableViewHandler.isMinimized {
                    self.compactView.environmentObject(self.minimizableViewHandler).gesture(DragGesture().onChanged({ (value) in
                        
                        if self.minimizableViewHandler.isMinimized == false  {
                            if value.translation.height > 0 {
                                self.draggedOffset = value.translation
                                
                                if value.translation.height > 80 {
                                    self.minimizableViewHandler.isMinimized = true
                                }
                            }
                        } else {
                            
                            if value.translation.height < 0 {
                                self.draggedOffset = value.translation
                                if value.translation.height < -80 {
                                    self.minimizableViewHandler.isMinimized = false
                                }
                            }
                        }
                        
                    }).onEnded({ (value) in
                        self.draggedOffset = CGSize.zero

                    }))
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
       
        
    }
    
}




