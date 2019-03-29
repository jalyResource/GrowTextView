#
# Be sure to run `pod lib lint GrowTextView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowTextView'
  s.version          = '1.0'
  s.summary          = 'iOS 一个比较完美 Growing TextView（高度自适应输入框）'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS 一个比较完美 Growing TextView（高度自适应输入框）。
                       DESC

  s.homepage         = 'https://github.com/jalyResource/GrowTextView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wuzhenli' => 'zhenli@6.cn' }
  s.source           = { :git => 'https://github.com/jalyResource/GrowTextView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GrowTextView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GrowTextView' => ['GrowTextView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
end
