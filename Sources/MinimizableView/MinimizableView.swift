//
//  MinimizableView.swift

//
//  Created by Dominik Butz on 7/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//Version 0.2

import SwiftUI
import Combine

/**
Handler for MinimizableView. Must be attached as Environment Object to Minimizable View, to your content view parameter and to your compact view parameter.
*/
public class MinimizableViewHandler: ObservableObject {
 
    /**
    Handler Initializer. Although it is empty, it is necessary to set it with the public keyword, otherwise the compiler will throw an error.
    */
    public init() {}
    
    public var settings =  Settings()
    
    public var onPresentation: (()->Void)?
    public var onDismissal:(()->Void)?
    public  var onExpansion: (()->Void)?
    public var onMinimization: (()->Void)?
    
    /**draggedOffset: The offset of the minimizable view's position. You can attach your own gesture recognizers to your content view or its subviews, e.g. to dismiss the minimizable view on swiping down.
 */
    @Published public var draggedOffset = CGSize.zero
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
            
            self.isMinimized = false
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
    Call this function to expand or minimize the MinimizableView. Useful in an onTapGesture-closure because you don't need to check the expansion state.
    */
    public func toggleExpansionState() {
        
        self.isMinimized.toggle()
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


public struct Settings {
    /// height of the view in minimized state.
    public var minimizedHeight: CGFloat = 44.0
    
    /// leading and trailing margin of the view.
    public var lateralMargin: CGFloat = 0
    
    /// the top margin of the view in expanded state.
    public var expandedTopMargin: CGFloat = 10.0
    
    /// the background color of the view.
    public var backgroundColor: Color = Color(.systemBackground)
    
    /// the corner radius of the view. only the top two corners are visible.
    public var cornerRadius: CGFloat  = 8.0
    
    /// the shadow color of the view.
    public var shadowColor: Color = Color(.systemGray2)
    
    /// the shadow radius of the view.
    public var shadowRadius: CGFloat = 5.0
}

/**
MinimizableView.
*/
public struct MinimizableView: View {
    
    /**
    MinimizableView Handler. must be attached to the MinimizableView.
    */
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler

    let bottomMargin: CGFloat

    var geometry: GeometryProxy
    
    var contentView:  AnyView
    var compactView: AnyView?
   

     func offsetY()->CGFloat {
         
        if self.minimizableViewHandler.isPresented == false {
            return geometry.size.height
         } else {
             // is presenting
            return self.minimizableViewHandler.draggedOffset.height

         }

     }
     
     func frameHeight()->CGFloat {
         
        if self.minimizableViewHandler.isMinimized {
            return self.minimizableViewHandler.settings.minimizedHeight
         } else {
            return geometry.size.height - self.minimizableViewHandler.settings.expandedTopMargin
         }
     }
    
    func positionY()->CGFloat {

        if self.minimizableViewHandler.isMinimized {
          return geometry.size.height - self.bottomMargin - self.minimizableViewHandler.settings.minimizedHeight / 2
         
        } else {

            return (geometry.size.height + self.minimizableViewHandler.settings.expandedTopMargin) / 2
   
        }
    }
//       var positionY = self.minimizableViewHandler.isMinimized ? geometry.size.height  -  self.bottomMargin - (self.minimizableViewHandler.settings.minimizedHeight / 2) :  (geometry.size.height + self.minimizableViewHandler.settings.expandedTopMargin) / 2
//        return positionY + self.minimizableViewHandler.draggedOffset.height
//    }

    /**
    MinimizableView Initializer.

    - Parameter content: the view that should be embedded inside the MinimizableView. Important: cast the view to: AnyView(yourView).
     
    - Parameter compactView: the view that will be shown at the top of the MinimizableView in minimized state. Important: cast the view to: AnyView(yourCompactView).
     
    - Parameter minimizedHeight: The  total height  (CGFloat value) of the MinimizedView in minimized state. Should be about 15.0 larger than your compact view height.
     
    - Parameter bottomMargin:The margin in minimized state to the bottom of the view in which the minimzed view is embedded in.
     
    - Parameter expandedTopMargin: The margin to the top (usually the status bar) in expanded state.
     
    - Parameter geometry: Embed the ZStack, in which the MinimizableView resides, in a geometry reader.  This will allow the MinimizableView to adapt to a changing screen orientation.
    */
    public init<V>(content: V, compactView: V?, bottomMargin: CGFloat, geometry: GeometryProxy) where V: View {
        
        self.contentView = AnyView(content)
        self.compactView = AnyView(compactView)
        self.geometry = geometry
        self.bottomMargin = bottomMargin

   
    }
    
    /**
       Body of the MinimizableView.
    */
    public var body: some View {

            
            ZStack(alignment: .top) {

                self.contentView
                
                if self.minimizableViewHandler.isMinimized && self.compactView != nil {
                    self.compactView!

                }
            }.background( RoundedRectangle(cornerRadius: 8)
                .foregroundColor(self.minimizableViewHandler.settings.backgroundColor).shadow(color:  self.minimizableViewHandler.settings.shadowColor, radius: self.minimizableViewHandler.settings.shadowRadius, x: 0, y: -5))
            
            .frame(
                width: geometry.size.width - self.minimizableViewHandler.settings.lateralMargin * 2 ,
                height: self.frameHeight())
            .position(CGPoint(x: geometry.size.width / 2, y: self.positionY()))
            .offset(y: self.offsetY())
            .clipped()
            .animation(.spring())
       
        
    }
    
}

/**
 VerticalDragGesture - a view modifier you can add to your content or compact view.
*/
public struct VerticalDragGesture: ViewModifier {
    
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
    var translationHeightTriggerValue: CGFloat
    
    /**
    VerticalDragGesture initializer.

    - Parameter translationHeightTriggerValue: the minimum CGFloat value of your swipe movment length that should trigger minimization and expansion of the MinimizableView. In minimized state, only an upward swipe can trigger expansion. Vice versa, only a downward swipe can trigger minimization.
    */
    public init(translationHeightTriggerValue: CGFloat) {
        self.translationHeightTriggerValue = translationHeightTriggerValue
    }
    
    /// body of the VerticalDragGesture modifier.
    public func body(content: Content) -> some View {
        content
            .gesture(DragGesture().onChanged({ (value) in
                
                if self.minimizableViewHandler.isMinimized == false  { // expanded state
                    if value.translation.height > 0 {
                        self.minimizableViewHandler.draggedOffset = value.translation
                        
                        if value.translation.height > self.translationHeightTriggerValue {
                            self.minimizableViewHandler.minimize()
                            self.minimizableViewHandler.draggedOffset = CGSize.zero
                        }
                    }
                } else {// minimized state
                    
                    if value.translation.height < 0 {
                        self.minimizableViewHandler.draggedOffset = value.translation
                        if value.translation.height < -self.translationHeightTriggerValue {
                            self.minimizableViewHandler.expand()
                             self.minimizableViewHandler.draggedOffset = CGSize.zero
                        }
                    }
                }
                
            }).onEnded({ (value) in
                self.minimizableViewHandler.draggedOffset = CGSize.zero

            }))

    }
}

/// An HStack view that shows a capsule shape delimiter. The whole view area is supposed to be larger than the capsule.
public struct TopDelimiterAreaView: View {
    
    var areaHeight: CGFloat
    var areaWidth: CGFloat

    /**
    TopDelimiterAreaView initializer..

    - Parameter areaHeight:height of the HStack view that contains the capsule shape delimiter. Default value is 15.0.
    - Parameter areaWidth:width of the HStack view that contains the capsule shape delimiter. It is recommended to use
    */
    public init(areaHeight: CGFloat = 15, areaWidth: CGFloat) {
        self.areaHeight = areaHeight
        self.areaWidth = areaWidth
    }
    /// body of the TopDelimiterAreaView
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Capsule().fill(Color.gray).frame(width: 40, height: 5, alignment: .top)
        }.frame(width: areaWidth, height: areaHeight, alignment: .top)
        
    }
}




