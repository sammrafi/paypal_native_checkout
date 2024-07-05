#import "PaypalNativeCheckoutPlugin.h"
#if __has_include(<paypal_native_checkout/paypal_native_checkout-Swift.h>)
#import <paypal_native_checkout/paypal_native_checkout-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "paypal_native_checkout-Swift.h"
#endif

@implementation PaypalNativeCheckoutPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaypalNativeCheckoutPlugin registerWithRegistrar:registrar];
}
@end
