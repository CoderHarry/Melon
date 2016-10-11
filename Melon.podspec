#
#  Be sure to run `pod spec lint Melon.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "Melon"
  s.version      = "1.0.0"
  s.summary      = "Swift http request"
  s.description  = <<-DESC
  				   Melon is a Swift HTTP / HTTPS networking library for people
                   DESC

  s.homepage     = "https://github.com/CoderHarry/Melon"
  s.license      = "MIT"
  s.author       = { "Caiyanzhi" => "yanzhi_cai@163.com" }
  s.source       = { :git => "https://github.com/CoderHarry/Melon.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/u/3201454077'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Melon/*'

  # s.public_header_files = 'Melon/*.h'

end
