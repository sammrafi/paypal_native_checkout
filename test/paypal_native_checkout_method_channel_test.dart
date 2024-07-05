import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paypal_native_checkout/paypal_native_checkout_method_channel.dart';

void main() {
  MethodChannelPaypalNativeCheckout platform =
      MethodChannelPaypalNativeCheckout();
  const MethodChannel channel = MethodChannel('flutter_paypal_native');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
