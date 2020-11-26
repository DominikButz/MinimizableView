# MinimizableView (iOS 13+ / iPadOS)

[![Version](https://img.shields.io/cocoapods/v/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)
[![License](https://img.shields.io/cocoapods/l/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)
[![Platform](https://img.shields.io/cocoapods/p/MinimizableView.svg?style=flat)](https://cocoapods.org/pods/MinimizableView)


 MinimizableView is a simple SwiftUI view for iOS and iPadOS that can minimize like the mini-player in the Spotify or Apple Music app. Currently, it seems that SwiftUI does not support custom modals (with different animations / states than sheet, actionSheet, alert, popover etc.), so this simple view can be considered as a workaround.
It can only be used from iOS 13.0 because SwiftUI is not supported in earlier iOS versions.

**Breaking changes in version 2.0. See details below in the version history**

*Special thanks to Kavsoft ([see here](https://kavsoft.dev/SwiftUI_2.0/Apple_Music/)) - I used parts of their MiniPlayer content in the example. The framework is my own creation though.*

## Example project

This repo only contains the Swift package, no example code. Please download the example project [here](https://github.com/DominikButz/MinimizableViewExample.git).
You need to add the MinimizableView package either through cocoapods or the Swift Package Manager (see below - Installation). 

## Features

* Create your own content, background and compact view. The compact view is optional - in case you set it in the initializer, it will appear in the minimized state. 
* By changing the setting properties of the MinimizableViewHandler, you can customize the following properties:
	- minimizedHeight
    - overrideHeight (in case you want to set a height different from the geometry size height)
	- lateralMargin
    - animation

	Check out the examples for details. 


## Installation


Installation through the Swift Package Manager (SPM) or cocoapods is recommended. 

SPM:
Select your project (not the target) and then select the Swift Packages tab. Click + and type MinimizableView - SPM should find the package on github. 

Cocoapods:

platform :ios, '14.0'

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

 If you don't want a compact view, just pass in an EmptyView. The code in the body of MinimizableView checks if compactView is an EmptyView and then does not display it.  if there is no compact view, the top of your content will be shown at the bottom of the screen in minimized state. Use the minimizableViewHandler as EnvironmentObject in your content view - e.g. to remove and insert certain subviews once the minimized property changes. 

You also need to attach the minimizableViewHandler as environment object to the MinimizableView. 

```Swift

struct RootView: View {

    @ObservedObject var miniHandler: MinimizableViewHandler = MinimizableViewHandler()
    @State var selectedTabIndex: Int = 0
    
    @Namespace var namespace

    
    var body: some View {
        GeometryReader { proxy in

                TabView(selection: self.$selectedTabIndex) {
                    
                    Button(action: {
                        print(proxy.safeAreaInsets.bottom)
                        self.miniHandler.present()
                        
                    }) { TranslucentTextButtonView(title: "Launch Minimizable View", foregroundColor: .green, backgroundColor: .green)}.disabled(self.miniHandler.isPresented)
                        
                        .tabItem {
                            Image(systemName: "chevron.up.square.fill")
                            Text("Main View")
                    }.tag(0)
                    
                    Text("More stuff").tabItem {
                        Image(systemName: "dot.square.fill")
                        Text("2nd View")
                    }.tag(1)
                    
                    ListView(availableWidth: proxy.size.width)
                        .tabItem {
                        Image(systemName: "square.split.2x1.fill")
                        Text("List View")
                    }.tag(2)
                    
                    
                }.background(Color(.secondarySystemFill))
                .statusBar(hidden: self.miniHandler.isPresented && self.miniHandler.isMinimized == false)
                // if you want a separate compactView, replace EmptyView() by some custom view. It will appear above the top part of your contentView, so make sure the compact view has a background colour. 
                .minimizableView(content: {ContentExample(animationNamespaceId: self.namespace)}, compactView: {EmptyView()}, backgroundView: {
                    VStack(spacing: 0){
                        
                        BlurView(style: .systemChromeMaterial)
                        if self.miniHandler.isMinimized {
                            Divider()
                        }
                    }.cornerRadius(self.miniHandler.isMinimized ? 0 : 20)
                    .onTapGesture(perform: {
                        if self.miniHandler.isMinimized {
                        withAnimation(.spring()){self.miniHandler.isMinimized = false}
                        }
                    })
                }, dragOnChanged: { (value) in
                    self.dragOnChanged(value: value)
                }, dragOnEnded: { (value) in
                    self.dragOnEnded(value: value)
                }, geometry: proxy, settings: MiniSettings(minimizedHeight: 80))
                .environmentObject(self.miniHandler)
     
        }
    
        //
    }
    
    
    func dragOnChanged(value: DragGesture.Value) {
        if self.miniHandler.isMinimized == false  { // expanded state
            if value.translation.height > 0 {
                self.miniHandler.draggedOffsetY = value.translation.height

            }
        } else {// minimized state
            
            if value.translation.height < 0 {
                self.miniHandler.draggedOffsetY = value.translation.height

            }
        }
    }
    
    func dragOnEnded(value: DragGesture.Value) {
        if self.miniHandler.isMinimized == false  {
            if value.translation.height > 60 {
                  self.miniHandler.minimize()
           
            }
            
        } else {
            if value.translation.height < -60 {
                  self.miniHandler.expand()
    
              }
            
        }
       withAnimation(.spring()) {
            self.miniHandler.draggedOffsetY = 0
       }

    }
}

   

```

## Change log

#### [Version 2.0.1](https://github.com/DominikButz/MinimizableView/releases/tag/2.0.1)
Moved minimizedBottomMargin to the miniView initializer. This is useful e.g. in case of a changing distance to the bottom edge according to the screen orientation. 

#### [Version 2.0](https://github.com/DominikButz/MinimizableView/releases/tag/2.0)
Breaking Changes. the following parameters need to be set in the initialiser: 
- backgroundView
- onDragChanged and onDragEnded  
- settings (optional)

#### [Version 1.2.1](https://github.com/DominikButz/MinimizableView/releases/tag/1.2.1)
Bug fix: when in minimized state, the mini view will disappear if the keyboard shows (instead of floating above the keyboard).

#### [Version 1.2](https://github.com/DominikButz/MinimizableView/releases/tag/1.2)
The compactView parameter cannot be nil. If you don't want a separate compactView, pass in an EmptyView. 
Removed transitions from minimizableView body (contentView and compactView). Instead, attach the transition modifier to your implementation of conentView and compactView. Check out the example repository for details.
Parameters of the MiniSettings struct can now be set directly in the initializer.

#### [Version 1.1.1](https://github.com/DominikButz/MinimizableView/releases/tag/1.1.1)
Slight animation improvement.

#### [Version 1.1](https://github.com/DominikButz/MinimizableView/releases/tag/1.1)
Content view now only appears if the mini view is presented. Other minor improvements.

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


