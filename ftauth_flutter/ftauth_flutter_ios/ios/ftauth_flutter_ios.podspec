#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ftauth_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ftauth_flutter'
  s.version          = '0.0.1'
  s.summary          = 'FTAuth bindings for iOS.'
  s.description      = <<-DESC
FTAuth bindings for iOS.
                       DESC
  s.homepage         = 'https://github.com/ftauth/sdk-dart'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FTAuth' => 'hello@ftauth.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FTAuth/Common'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
