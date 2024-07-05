import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paypal_native_checkout_method_channel.dart';

abstract class PaypalNativeCheckoutPlatform extends PlatformInterface {
  /// Constructs a FlutterPaypalPlatform.
  PaypalNativeCheckoutPlatform() : super(token: _token);

  static final Object _token = Object();

  static MethodChannelPaypalNativeCheckout _instance =
      MethodChannelPaypalNativeCheckout();

  /// The default instance of [FlutterPaypalPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPaypal].
  static MethodChannelPaypalNativeCheckout get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPaypalPlatform] when
  /// they register themselves.
  static set instance(MethodChannelPaypalNativeCheckout instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
