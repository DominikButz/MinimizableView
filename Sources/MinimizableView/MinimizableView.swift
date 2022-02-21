//
//  MinimizableView.swift

//
//  Created by Dominik Butz on 7/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//Version 0.3.2

import SwiftUI
import Combine
/**
MinimizableView.
*/
public struct MinimizableView<MainContent: View, CompactContent: View, BackgroundView: View>: View {
    
    /**
    MinimizableView Handler. must be attached to the MinimizableView.
    */
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler

    var geometry: GeometryProxy
    var contentView:  MainContent
    var compactView: CompactContent
    var backgroundView: BackgroundView
    var minimizedBottomMargin: CGFloat
    var settings: MiniSettings
    
    var offsetY: CGFloat {
         
        if self.minimizableViewHandler.isPresented == false {
            return UIScreen.main.bounds.height + 30  // safety margin for shadow etc.
         } else {
             // is presenting
            if self.minimizableViewHandler.isMinimized {
                return self.minimizableViewHandler.draggedOffsetY < 0 ? self.minimizableViewHandler.draggedOffsetY / 2: 0
            } else {
       // expanded
                return self.minimizableViewHandler.draggedOffsetY

            }
           
         }

     }
     
    var frameHeight: CGFloat? {
         
        if self.minimizableViewHandler.isMinimized {
            
            let draggedOffset: CGFloat = self.minimizableViewHandler.draggedOffsetY < 0 ? self.minimizableViewHandler.draggedOffsetY * (-1) : 0
            return self.settings.minimizedHeight + draggedOffset

         } else {
            return self.settings.overrideHeight
            //return geometry.size.height - self.minimizableViewHandler.settings.expandedTopMargin
         }
     }
    
    var minimizedOffsetY: CGFloat {
        return self.minimizableViewHandler.isMinimized ? -self.minimizedBottomMargin - geometry.safeAreaInsets.bottom  - self.minimizableViewHandler.draggedOffsetY / 2 : 0
    }
    
    /**
    MinimizableView Initializer.

    - Parameter content: the view that should be embedded inside the MinimizableView. Important: cast the view to: AnyView(yourView).
     
    - Parameter compactView: a view that will be shown at the top of the MinimizableView in minimized state. Pass in EmptyView() if you prefer changing the top part of your content view instead.
     
    - Parameter backgroundView: Pass in a background view. Don't set its frame.
     
    - Parameter geometry: Embed the ZStack, in which the MinimizableView resides, in a geometry reader.  This will allow the MinimizableView to adapt to a changing screen orientation.
    - Parameter minimizedBottomMargin: The vertical offset from the bottom edge in minimized state. e.g. useful if the mini view shall sit on a tab view.
    - Parameter settings: Minimizable View settings.
    */
    public init(@ViewBuilder content: ()->MainContent, compactView: ()->CompactContent, backgroundView: ()->BackgroundView, geometry: GeometryProxy, minimizedBottomMargin: CGFloat, settings: MiniSettings) {
        
        self.contentView = content()
        self.compactView = compactView()
        self.backgroundView = backgroundView()
        self.geometry = geometry
        self.minimizedBottomMargin = minimizedBottomMargin
        self.settings = settings

    }
    
    /**
       Body of MinimizableView.
    */
    public var body: some View {
  
            ZStack(alignment: .top) {
                if self.minimizableViewHandler.isPresented == true {
                    self.contentView.clipped()
                  
                    if self.minimizableViewHandler.isMinimized && (self.compactView is EmptyView) == false {
                        self.compactView.clipped()
                       
                    }
               }
            }
            .frame(width: geometry.size.width - self.settings.lateralMargin * 2 ,
                  height: self.frameHeight)
            .background(self.backgroundView)
            .offset(y: self.offsetY)
            .offset(y: self.minimizedOffsetY)
    
    }
    
}

struct MinimizableViewModifier<MainContent: View, CompactContent:View, BackgroundView: View>: ViewModifier {
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
    @ObservedObject var keyboardNotifier = KeyboardNotifier(keyboardWillShow: nil, keyboardWillHide: nil)
    
      var contentView:  ()-> MainContent
      var compactView: ()-> CompactContent
      var backgroundView: ()->BackgroundView
    
      var dragOnChanged: (DragGesture.Value)->()
     var dragOnEnded: (DragGesture.Value)->()
      var geometry: GeometryProxy
       var minimizedBottomMargin: CGFloat
        var settings: MiniSettings
    
    func body(content: Content) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
       
            content
 
            MinimizableView(content: contentView, compactView: compactView, backgroundView: backgroundView, geometry: geometry, minimizedBottomMargin: minimizedBottomMargin, settings: settings)
                .gesture(DragGesture(coordinateSpace: .global).onChanged(self.dragOnChanged).onEnded(self.dragOnEnded)).environmentObject(self.minimizableViewHandler).opacity(self.minimizableViewHandler.isVisible ? 1 : 0)
            
        }
        .edgesIgnoringSafeArea(settings.edgesIgnoringSafeArea)
    }
}

public extension View {
    
    /**
    MinimizableView Initializer.

    - Parameter content: the view that should be embedded inside the MinimizableView. Important: cast the view to: AnyView(yourView).
     
    - Parameter compactView: a view that will be shown at the top of the MinimizableView in minimized state. Pass in EmptyView() if you prefer changing the top part of your content view instead.
     
    - Parameter backgroundView: Pass in a background view. Don't set its frame.
     
    - Parameter dragOnChanged: Determine what happens when the user vertically drags the miniView.
     
    - Parameter dragOnEnded: Determine what should happen when the user released the miniView after dragging.
     
    - Parameter geometry: Embed the ZStack, in which the MinimizableView resides, in a geometry reader.  This will allow the MinimizableView to adapt to a changing screen orientation.
    - Parameter minimizedBottomMargin: The vertical offset from the bottom edge in minimized state. e.g. useful if the mini view shall sit on a tab view.
    - Parameter settings: Minimizable View Settings.
    */
    func minimizableView<MainContent: View, CompactContent: View, BackgroundView: View>(@ViewBuilder content: @escaping ()->MainContent, compactView: @escaping ()->CompactContent, backgroundView: @escaping ()->BackgroundView, dragOnChanged: @escaping (DragGesture.Value)->(), dragOnEnded: @escaping (DragGesture.Value)->(), geometry: GeometryProxy, minimizedBottomMargin: CGFloat = 48,  settings: MiniSettings = MiniSettings())->some View  {
        self.modifier(MinimizableViewModifier(contentView: content, compactView: compactView, backgroundView: backgroundView, dragOnChanged: dragOnChanged, dragOnEnded: dragOnEnded, geometry: geometry, minimizedBottomMargin: minimizedBottomMargin, settings: settings))
    }
    
}





