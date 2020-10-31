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
 
    /**
    Handler Initializer.
      - Parameter settings: See MiniSettings for details. can be nil - if nil, the default values will be set.
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

/**
 Settings to pass in as parameter into the initializer of the mini handler
*/
public struct MiniSettings {

    /**
    Initializer
     - Parameter minimizedHeight:  height of the view in minimized state.
     - Parameter bottomMargin: distance of the miniView from the bottom edge in minimized state.
     - Parameter lateralMargin: leading and trailing margin of the view.
     - Parameter  expandedTopMargin: the top margin of the  mini view in expanded state.
     - Parameter backgroundColor:the background color of the mini view.
     - Parameter cornerRadius: the corner radius of the mini view. only the two top corners are visible in expanded state.
    - Parameter shadowColor: the background shadow color of the  mini view.
    - Parameter shadowRadius: the shadow radius of the mini view background shadow.
    */
    public init(minimizedHeight: CGFloat = 44.0, bottomMargin:CGFloat = 48, lateralMargin: CGFloat = 0, expandedTopMargin: CGFloat = 0, backgroundColor: Color = Color(.systemBackground), cornerRadius: CGFloat = 10, shadowColor: Color =  Color(.systemGray2), shadowRadius: CGFloat = 5) {
        self.minimizedHeight = minimizedHeight
        self.bottomMargin = bottomMargin
        self.lateralMargin = lateralMargin
        self.expandedTopMargin = expandedTopMargin
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        
    }
    
    /// height of the view in minimized state.
    public var minimizedHeight: CGFloat
    
    /// distance of the miniView from the bottom edge in minimized state.
    public var bottomMargin: CGFloat
    
    /// leading and trailing margin of the view.
    public var lateralMargin: CGFloat
    
    /// the top margin of the view in expanded state.
    public var expandedTopMargin: CGFloat
    
    /// the background color of the view.
    public var backgroundColor: Color
    
    /// the corner radius of the view. only the top two corners are visible.
    public var cornerRadius: CGFloat
    
    /// the shadow color of the view.
    public var shadowColor: Color
    
    /// the shadow radius of the view.
    public var shadowRadius: CGFloat
}
