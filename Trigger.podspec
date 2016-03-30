#
# Be sure to run `pod lib lint Trigger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Trigger"
  s.version          = "0.1.0"
  s.summary          = "Simple Dependency Injection container for Swift. Use protocols to resolve dependencies with precise syntax!"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  			Trigger is a simple Dependency Injection framework written in 			Swift. 
			
			It provides simple, easy to use syntax for injecting 				dependencies using protocol resolution. 
			
			Define a protocol corresponding to your API and then let 				Trigger resolve this protocol to its corresponding instance 				dynamically at runtime. This allows creation of separate 				configurations for the App and the tests to resolve the same 			protocol to different instances dynamically improving 				testability.
                       DESC

  s.homepage         = "https://github.com/sabirvirtuoso/Trigger"
  s.license          = 'MIT'
  s.author           = { "Syed Sabir Salman-Al-Musawi" => "sabirvirtuoso@gmail.com" }
  s.source           = { :git => "https://github.com/sabirvirtuoso/Trigger.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/syed.musawi'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Trigger' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
