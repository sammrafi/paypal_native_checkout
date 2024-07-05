import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paypal_native_checkout_platform_interface.dart';

/// An implementation of [FlutterPaypalPlatform] that uses method channels.
class MethodChannelPaypalNativeCheckout extends PaypalNativeCheckoutPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paypal_native_checkout');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
