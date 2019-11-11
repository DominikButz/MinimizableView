
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MinimizableView'
  s.version          = '0.2'
  s.summary          = 'SwiftUI view that minimises to the bottom of the screen similar to the mini-player in Apple Music or Spotify.'
  s.swift_version = '5.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    MinimizableView is a simple SwiftUI view for iOS and iPadOS that can minimise like the mini-player in the Spotify or Apple Music app. 
It can only be used from iOS 13.0 or iPadOS because SwiftUI is not supported in earlier iOS versions.
                       DESC

  s.homepage         = 'https://github.com/DominikButz/MinimizableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dominikbutz' => 'dominikbutz@gmail.com' }
  s.source           = { :git => 'https://github.com/DominikButz/MinimizableView.git', :tag => s.version.to_s }


  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*'
  #s.exclude_files = 'MinimizableView /**/*.plist'


  # s.public_header_files = 'DYModalNavigationController/**/*.h'

end