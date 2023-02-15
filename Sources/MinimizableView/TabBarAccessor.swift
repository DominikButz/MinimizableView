//
//  TabBarAccessor.swift
//  
//
//  Created by Asperi on StackOverflow https://stackoverflow.com/questions/59969911/programmatically-detect-tab-bar-or-tabview-height-in-swiftui
//

#if os(iOS)
import Foundation
import SwiftUI

// Helper bridge to UIViewController to access enclosing UITabBarController
// and thus its UITabBar
public struct TabBarAccessor: UIViewControllerRepresentable {
    public var callback: (UITabBar) -> Void
    private let proxyController = ViewController()
    
    public init(callback: @escaping (UITabBar) -> Void) {
        self.callback = callback
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }
    
    public typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}
#endif
