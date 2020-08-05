# MinimizableView (iOS 13 / iPadOS)

[![Version](https://img.shields.io/cocoapods/v/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)
[![License](https://img.shields.io/cocoapods/l/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)
[![Platform](https://img.shields.io/cocoapods/p/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)


 MinimizableView is a simple SwiftUI view for iOS and iPadOS that can minimize like the mini-player in the Spotify or Apple Music app. Currently, it seems that SwiftUI does not support custom modals (with different animations / states than sheet, actionSheet, alert, popover etc.), so this simple view can be considered as a workaround.
It can only be used from iOS 13.0 because SwiftUI is not supported in earlier iOS versions.

## Example project

This repo only contains the Swift package, no example code. Please download the example project [here](https://github.com/DominikButz/MinimizableViewExample.git).
You need to add the MinimizableView package either through cocoapods or the Swift Package Manager (see below - Installation). 

## Features

* Create your own content and compact view. The compact view is optional - in case you set it in the initializer, it will appear in the minimized state. 
* By changing the setting properties of the MinimizableViewHandler, you can customize the following properties:
	- minimizedHeight
	- lateralMargin
    - bottomMargin
	- expandedTopMargin
	- backgroundColor
	- cornerRadius
	- shadowColor
	- shadowRadius
	
	Check out the examples for details. 


## Installation


Installation through the Swift Package Manager (SPM) or cocoapods is recommended. 

SPM:
Select your project (not the target) and then select the Swift Packages tab. Click + and type MinimizableView - SPM should find the package on github. 

Cocoapods:

platform :ios, '13.0'

target '[project name]' do
 	pod 'MinimizableView'
end


Check out the version history below for the current version.


Make sure to import MinimizableView in every file where you use the MinimizableView or MinimizableViewHandler

```Swift
import MinimizableView
```

## Usage

Check out the following example. This repo only contains the Swift package, no example code. Please download the example project [here](https://github.com/DominikButz/MinimizableViewExample.git).


![MinimizableView example](gitResources/example01.gif) 


### Code example: Content View (your main view)

Make sure to add an overlay view modifier to the view over which the Minimizable View shall appear. Alternatively, you can add it as the last view in a ZStack. 
To trigger presentation, dismissal, minimization and expansion, you need to call the respective functions of the minimizableViewHandler: present(), dismiss(), minimize() and expand(). It is advisable to call toggleExpansionState() on the minimizableViewHandler whenever you use a tapGesture to toggle the expansion state. 

 The compact view parameter is optional. if there is no compact view, the top of your content will be shown at the bottom of the screen in minimized state. 

You also need to attach the minimizableViewHandler as environment object to the MinimizableView. 

```Swift
	import SwiftUI
	import MinimizableView
	import Combine

	struct ContentView: View {
		
	    var minimizableViewHandler: MinimizableViewHandler = MinimizableViewHandler()
	    @State var selectedTabIndex: Int = 0
	    
	    init() {
	        
	        self.minimizableViewHandler.settings.backgroundColor = Color(.secondarySystemBackground)
	        self.minimizableViewHandler.settings.lateralMargin = 10
	        // change other settings if deemed necessary.
	    }
	    
	    var body: some View {
	        GeometryReader { proxy in

	                TabView(selection: self.$selectedTabIndex) {
	                    
	                    Button(action: {
	                        
	                        self.minimizableViewHandler.present()
	                        
	                    }) { TranslucentTextButtonView(title: "Launch Minimizable View", foregroundColor: .green, backgroundColor: .green)}
	                        .tabItem {
	                            Image(systemName: "chevron.up.square.fill")
	                            Text("Main View")
	                    }.tag(0)
	                    
	                    Text("More stuff").tabItem {
	                        Image(systemName: "dot.square.fill")
	                        Text("2nd View")
	                    }.tag(1)
	                    
	                    Text("Even more stuff").tabItem {
	                        Image(systemName: "square.split.2x1.fill")
	                        Text("3rd View")
	                    }.tag(2)
	                    
	                    
	                }.minimizableView(content: {ContentExample()}, compactView: {CompactViewExample()}, geometry: proxy).environmentObject(self.minimizableViewHandler)
                    .verticalDragGesture(translationHeightTriggerValue: 30)), bottomMargin: 50.0, geometry: proxy)
	               
		// VerticalDragGesture is a modifier provided in the package. You can use this one or create your own.
	                            
	                
	        }
	    
	        //
	    }
}
   

```


### Code Example: TopDelimiterAreaView in your MinimizableView content

If you want a gray capsule shaped delimiter view at the top of your content (which can act as button to change the expansion state ), you can add a TopDelimiterAreaView. Attach a tap gesture recognizer to toggle the expansion state. 

```Swift
		VStack {
    			TopDelimiterAreaView(areaWidth: proxy.size.width).onTapGesture {
                  self.minimizableViewHandler.toggleExpansionState()
                   // other views    
            }
                    
                
   }
```
### Code Example: VerticalDragGesture Recognizer

Add a VerticalDragGesture as modifier to your compact view. If the user swipes upwards, the minimizableView will expand. You can do the same in your main content that is embedded in the minimizableView to allow triggering minimization when the user swipes down.

```Swift
		struct CompactViewExample: View {
	    
	    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
	    
	    var body: some View {
	        GeometryReader { proxy in
	             HStack {
	                Text("Compact View")
	             }.frame(width: proxy.size.width, height: proxy.size.height).onTapGesture {
	                    self.minimizableViewHandler.expand()
	             }.background(Color(.secondarySystemBackground)).verticalDragGesture(translationHeightTriggerValue: 40))
	        }
	    }
	}
```

## Change log

#### [Version 1.0](https://github.com/DominikButz/MinimizableView/releases/tag/1.0)
Breaking change of initializer: Content view and compact view now need to be inserted into closures, no more casting to AnyView! Bug fix: top of mini view does not show any more when in hidden state in case the UI device is without home button (e.g. iPhone 11 max). Bonus: convenience modifier (see example).

#### [Version 0.3.2](https://github.com/DominikButz/MinimizableView/releases/tag/0.3.2)
Bug fixes: onMinimization is now called as expected. onExpansion is only called when isPresented is true. 

#### [Version 0.3.1](https://github.com/DominikButz/MinimizableView/releases/tag/0.3.1)
Adding safety margin to offsetY when minimizable view presentation state is false - this fixes the shadow visibility bug at the bottom of the screen.

#### [Version 0.3](https://github.com/DominikButz/MinimizableView/releases/tag/0.3)
Expansion / minimization through the VerticalDragGesture modifier is now triggered only after the drag gesture ended. The VerticalDragGesture view modifier is now internal to the framework - instead *use the modifier function verticalDragGesture(translationHeightTriggerValue: CGFloat)*. Bug fixes. 

#### [Version 0.2.1](https://github.com/DominikButz/MinimizableView/releases/tag/0.2.1)
Updated frame height and offsetY functions to allow expanding the minimized frame when dragging upwards.

#### [Version 0.2](https://github.com/DominikButz/MinimizableView/releases/tag/0.2)
Initial public release. 


## Author

dominikbutz@gmail.com

## License

MinimizableView is available under the MIT license. See the LICENSE file for more info.


