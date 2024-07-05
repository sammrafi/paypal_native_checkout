#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint paypal_native_checkout.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'paypal_native_checkout'
  s.version          = '1.0.0'
  s.summary          = 'Flutter SDK Lib for Paypal.'
  s.description      = <<-DESC
  A Flutter package for integrating PayPal native checkout.
                       DESC
  s.homepage         = 'https://github.com/sammrafi/paypal_native_checkout'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sammrafi' => 'developer@sammrafi.com' }
  s.source = { :http => "https://github.com/paypal/paypalcheckout-ios/releases/download/1.3.0/PayPalCheckout.xcframework.zip" }
  # s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PayPalCheckout'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
