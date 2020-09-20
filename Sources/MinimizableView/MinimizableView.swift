//
//  MinimizableView.swift

//
//  Created by Dominik Butz on 7/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//Version 0.3.2

import SwiftUI
import Combine

/**
Handler for MinimizableView. Must be attached as Environment Object to Minimizable View, to your content view parameter and to your compact view parameter.
*/
public class MinimizableViewHandler: ObservableObject {
 
    /**
    Handler Initializer. Although it is empty, it is necessary to set it with the public keyword, otherwise the compiler will throw an error.
    */
    public init(settings: MiniSettings? = nil) {
        if let settings = settings {
            self.settings = settings
        }
    }
    /// settings
    @Published public var settings =  MiniSettings()
    
    ///onPresentation closure
    public var onPresentation: (()->Void)?
      ///onDismissal closure
    public var onDismissal:(()->Void)?
      ///onExpansion closure
    public  var onExpansion: (()->Void)?
      ///onMinimization closure
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
            if self.isMinimized == true {
                self.isMinimized = false
            }
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
       self.isMinimized = self.isMinimized == true ? false : true
  
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
                if self.isPresented == true {
                    self.onExpansion?()
                }
            }
        }
    }
}


public struct MiniSettings {

    public init() {}
    
    /// height of the view in minimized state.
    public var minimizedHeight: CGFloat = 44.0
    
    public var bottomMargin: CGFloat = 48
    
    /// leading and trailing margin of the view.
    public var lateralMargin: CGFloat = 0
    
    /// the top margin of the view in expanded state.
    public var expandedTopMargin: CGFloat = 0
    
    /// the background color of the view.
    public var backgroundColor: Color = Color(.systemBackground)
    
    /// the corner radius of the view. only the top two corners are visible.
    public var cornerRadius: CGFloat  = 10.0
    
    /// the shadow color of the view.
    public var shadowColor: Color = Color(.systemGray2)
    
    /// the shadow radius of the view.
    public var shadowRadius: CGFloat = 5.0
}

/**
MinimizableView.
*/
public struct MinimizableView<MainContent: View, CompactContent: View>: View {
    
    /**
    MinimizableView Handler. must be attached to the MinimizableView.
    */
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler

    var geometry: GeometryProxy
    var contentView:  MainContent
    var compactView: CompactContent?
    

    var offsetY: CGFloat {
         
        if self.minimizableViewHandler.isPresented == false {
            return UIScreen.main.bounds.height + self.minimizableViewHandler.settings.shadowRadius   // without the saftey margin the shadow will be visible at the bottom of the screen. for iphone 10 upwards, top part of mini view would even be visible...
         } else {
             // is presenting
            if self.minimizableViewHandler.isMinimized {
                return self.minimizableViewHandler.draggedOffset.height < 0 ? self.minimizableViewHandler.draggedOffset.height / 2: 0
            } else {
                // in expanded state, only return offset > 0 if dragging down
                 return self.minimizableViewHandler.draggedOffset.height > 0 ? self.minimizableViewHandler.draggedOffset.height  : 0
            }
           

         }

     }
     
    var frameHeight: CGFloat {
         
        if self.minimizableViewHandler.isMinimized {
            
            let draggedOffset: CGFloat = self.minimizableViewHandler.draggedOffset.height < 0 ? self.minimizableViewHandler.draggedOffset.height * (-1) : 0
            return self.minimizableViewHandler.settings.minimizedHeight + draggedOffset
         } else {
            return geometry.size.height - self.minimizableViewHandler.settings.expandedTopMargin
         }
     }
    
    var positionY: CGFloat {

        if self.minimizableViewHandler.isMinimized {
            return geometry.size.height - self.minimizableViewHandler.settings.bottomMargin - self.minimizableViewHandler.settings.minimizedHeight / 2
         
        } else {

            return (geometry.size.height + self.minimizableViewHandler.settings.expandedTopMargin) / 2
   
        }
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
    public init(@ViewBuilder content: ()->MainContent, compactView: ( ()->CompactContent)?, geometry: GeometryProxy) {
        
        self.contentView = content()
        self.compactView = compactView?()
        self.geometry = geometry

    }
    
//    public init<V>(content: ()->some View, compactView: V?, geometry: GeometryProxy) where V: View {
//
//        self.contentView = AnyView(content)
//        self.compactView = AnyView(compactView)
//        self.geometry = geometry
//
//    }
    
    /**
       Body of the MinimizableView.
    */
    public var body: some View {
  
            ZStack(alignment: .top) {
                if self.minimizableViewHandler.isPresented == true {
                    self.contentView.transition(AnyTransition.move(edge: .bottom))
      
                    if self.minimizableViewHandler.isMinimized && self.compactView != nil {
                        self.compactView!.transition(AnyTransition.opacity).animation(.easeInOut)
                    }
               }
            }
            .frame(width: geometry.size.width - self.minimizableViewHandler.settings.lateralMargin * 2 ,
                  height: self.frameHeight)
            .clipShape(RoundedRectangle(cornerRadius: self.minimizableViewHandler.settings.cornerRadius))
            .background(RoundedRectangle(cornerRadius: self.minimizableViewHandler.settings.cornerRadius)
                            .foregroundColor(self.minimizableViewHandler.settings.backgroundColor)
                            .shadow(color:  self.minimizableViewHandler.settings.shadowColor, radius: self.minimizableViewHandler.settings.shadowRadius, x: 0, y: -5))
            .position(CGPoint(x: geometry.size.width / 2, y: self.positionY))
            .offset(y: self.offsetY)
            .animation(.spring())
  
    }
    
}

struct MinimizableViewModifier<MainContent: View, CompactContent:View>: ViewModifier {
     @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
        
      var contentView:  ()-> MainContent
      var compactView: (()-> CompactContent)?
      var geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        content
            .overlay(MinimizableView(content: contentView, compactView: compactView, geometry: geometry).environmentObject(self.minimizableViewHandler))
    }
}

public extension View {
    
    func minimizableView<MainContent: View, CompactContent: View>(@ViewBuilder content: @escaping ()->MainContent, compactView: (()->CompactContent)?, geometry: GeometryProxy)->some View  {
        self.modifier(MinimizableViewModifier(contentView: content, compactView: compactView, geometry: geometry))
    }
    
}


/**
 VerticalDragGesture - a view modifier you can add to your content or compact view.
*/
internal struct VerticalDragGesture: ViewModifier {
    
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

                    }
                } else {// minimized state
                    
                    if value.translation.height < 0 {
                        self.minimizableViewHandler.draggedOffset = value.translation

                    }
                }
                
            }).onEnded({ (value) in
                
                if self.minimizableViewHandler.isMinimized == false  {
                    if value.translation.height > self.translationHeightTriggerValue {
                          self.minimizableViewHandler.minimize()
                   
                    }
                    
                } else {
                    if value.translation.height < -self.translationHeightTriggerValue {
                          self.minimizableViewHandler.expand()
            
                      }
                    
                }
                
                self.minimizableViewHandler.draggedOffset = CGSize.zero

            }))

    }
}

/// wrapper for the Vertical Drag Gesture View Modifier. Add it to the header view of your MinimizableView content view and/ or to your compact view.
public extension View {
    /**
     - Description: a vertical drag gesture view modifier
     - Parameter translationHeightTriggerValue: the vertical distance the user needs to drag in order to trigger expansion / minimization of the MinimizableView
     - Returns: a vertial drag gesture modifier.
    */
    func verticalDragGesture(translationHeightTriggerValue: CGFloat)-> some View {
        
       self.modifier(VerticalDragGesture(translationHeightTriggerValue: translationHeightTriggerValue))
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




