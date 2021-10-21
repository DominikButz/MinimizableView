//
//  File.swift
//  
//
//  Created by Dominik Butz on 31/10/2020.
//

import Foundation
import SwiftUI

/**
Handler for MinimizableView. Must be attached as Environment Object to Minimizable View, to your content view parameter and to your compact view parameter.
*/
public class MinimizableViewHandler: ObservableObject {
 
    var keyboardResponder: KeyboardNotifier?
    /**
    Handler Initializer.
      - Parameter settings: See MiniSettings for details. can be nil - if nil, the default values will be set.
    */
    public init() {

        self.keyboardResponder = KeyboardNotifier(keyboardWillShow: {
            if self.isMinimized {
                self.isVisible = false
            }
        }, keyboardWillHide: {
            self.isVisible = true
        })
        
    }
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
    @Published public var draggedOffsetY: CGFloat = 0
    
    
    @Published internal var isVisible = true
    /**
    Call this function to present the minimizable view instead of setting isPresented to true directly.
    */
    public func present() {
        
        if self.isPresented == false {
            withAnimation {
                self.isPresented = true
            }
        }
  
    }
    
    /**
    Call this function to dismiss the minimizable view instead of setting isPresented to false directly.
    */
    public func dismiss() {
        
        if self.isPresented == true {
            withAnimation {
                self.isPresented = false
            }
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
        if self.isMinimized {
            self.expand()
        } else {
            self.minimize()
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
                if self.isPresented == true {
                    self.onExpansion?()
                }
            }
        }
    }
}

/**
 Settings to pass in as parameter into the initializer of mini view
*/
public struct MiniSettings {

    /**
    Initializer
     - Parameter minimizedHeight:  height of the view in minimized state.
     - Parameter overrideHeight: The height  of the miniView in expanded state.If you prefer to set a custom height, you can set this value. Default value is nil, which means it will be set automatically to fill the available vertical space.
     - Parameter lateralMargin: leading and trailing margin of the view.
     - Parameter edgesIgnoringSafeArea: Array of Edge.Sets. Default is bottom and top - this means that if you don't override the height of the mini view, it will cover the top and bottom safe areas, if they exist for the device.
     - Parameter animation: for exansion and compression. default value is an interactive spring animation.
    */
    public init(minimizedHeight: CGFloat = 60, overrideHeight: CGFloat? = nil, lateralMargin: CGFloat = 0, edgesIgnoringSafeArea: Edge.Set = [.bottom, .top],  animation: Animation = Animation.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)) {
        self.minimizedHeight = minimizedHeight
        self.overrideHeight = overrideHeight
        self.lateralMargin = lateralMargin
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
        self.animation = animation
 
    }

    var minimizedHeight: CGFloat

    var overrideHeight: CGFloat?

    var lateralMargin: CGFloat
    
    var edgesIgnoringSafeArea: Edge.Set
    
    var animation: Animation
    

}



internal class KeyboardNotifier: ObservableObject {
   
    private var notificationCentre: NotificationCenter
    
    var keyboardWillShow: (()->Void)?
    var keyboardWillHide:(()->Void)?
    
    @Published var keyboardIsShowing: Bool = false
    
    init(keyboardWillShow:  (()->Void)?, keyboardWillHide: (()->Void)?) {
        self.notificationCentre =  NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    //    notificationCentre.addObserver(self, selector: #(keyBoardDid), name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
        self.keyboardWillShow = keyboardWillShow
        self.keyboardWillHide = keyboardWillHide
    }

    deinit {
        notificationCentre.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        self.keyboardWillShow?()
        self.keyboardIsShowing = true
    }

    @objc func keyBoardWillHide(notification: Notification) {
        self.keyboardWillHide?()
        self.keyboardIsShowing = false
    }
}
