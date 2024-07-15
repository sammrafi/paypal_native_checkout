
# Native Paypal integration with Flutter
[![pub package](https://img.shields.io/pub/v/paypal_native_checkout.svg)](https://pub.dev/packages/paypal_native_checkout)

Introducing a Flutter plugin for seamless PayPal payments with native support for both Android and iOS. This package eliminates the need for WebView, offering a streamlined and efficient checkout experience.

**(No WebView required)**

### Improvements
- Fixed endless loading issue.
- Added support for passing shipping address from Flutter.
- Shipping Preference Feature to add address or not 

  
## Requirements

| Platform    | Supported Versions  |
| ----------- | ------------------- |
| **Android** | API level 21 and above |
| **iOS**     | Version 13.0 and above |

For detailed setup instructions, visit the [PayPal Mobile Checkout documentation](https://developer.paypal.com/limited-release/paypal-mobile-checkout/initialize-sdk/).

### GitHub Repositories

- [Android SDK](https://github.com/paypal/android-checkout-sdk)
- [iOS SDK](https://github.com/paypal/paypalcheckout-ios)

## Demo
<img src="https://github.com/sammrafi/paypal_native_checkout/raw/main/resources/media/flutter_paypal.gif?raw=true" alt="Android Demo" height="400" />

<img src="https://github.com/sammrafi/paypal_native_checkout/raw/main/resources/media/flutter_paypal_ios.gif?raw=true" alt="iOS Demo" height="400" />


## Usage

Add `paypal_native_checkout` as a dependency in your `pubspec.yaml` file. For Android setup, ensure you have the necessary permissions and configurations in your `AndroidManifest.xml` and `build.gradle`.

## Android Platform Views
Paypal requires that you make changes to your AndroidManifest.xml

#### Prepare your app

Define the `android.permission.INTERNET` permission in the `AndroidManifest.xml` file of your application as follows:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

      <uses-permission android:name="android.permission.INTERNET" />
      ...

</manifest>
```

add this to your `android/app/build.config`

```groovy
android {
    ...

    defaultConfig {

        minSdkVersion 23
        ...
    }
}

```


#### Enable the SDK

To enable the PayPal Mobile Checkout SDK:

- Navigate to your app on the My Apps & Credentials page of the Developer Dashboard.
- Go to Features > Other features and select the Log in with PayPal checkbox.
- Click on Advanced Settings, where you'll find the Return URL field.
  
You have two options for setting the Return URL:

1. Use an Android App Link registered within the Developer Console to handle SDK redirects.
2. Alternatively, use your application ID (typically referenced via BuildConfig.APPLICATION_ID) and append `://paypalpay` as the suffix to register your return URL. For example, if your application ID is `com.paypal.app`, enter `com.paypal.app://paypalpay`.

Ensure that the return URL in the Developer Dashboard exactly matches the one used in your SDK setup.

Additional notes:
- The application ID and return URL must use lowercase letters.
- If you change the return URL in the Developer Dashboard, PayPal will require a review of your app.
- Select the Full Name and Email checkboxes under Advanced Settings; these are scopes of the Identity API.

The SDK is now enabled for use in your application.



### How to use the library

- Check out the example in `/example/lib/main.dart`

```dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paypal_native_checkout/paypal_native_checkout.dart';
import 'package:paypal_native_checkout/models/custom/currency_code.dart';
import 'package:paypal_native_checkout/models/custom/environment.dart';
import 'package:paypal_native_checkout/models/custom/order_callback.dart';
import 'package:paypal_native_checkout/models/custom/purchase_unit.dart';
import 'package:paypal_native_checkout/models/custom/user_action.dart';
import 'package:paypal_native_checkout/str_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _paypalNativeCheckoutPlugin = PaypalNativeCheckout.instance;
  // log queue
  List<String> logQueue = [];

  @override
  void initState() {
    super.initState();
    initPayPal();
  }

  void initPayPal() async {
    //set debugMode for error logging
    PaypalNativeCheckout.isDebugMode = true;

    //initiate payPal plugin
    await _paypalNativeCheckoutPlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: "com.example.example://paypalpay",
      //client id from developer dashboard
      clientID: "ATeY...",
      //sandbox, staging, live etc
      payPalEnvironment: FPayPalEnvironment.sandbox,
      //what currency do you plan to use? default is US dollars
      currencyCode: FPayPalCurrencyCode.usd,
      //action paynow?
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _paypalNativeCheckoutPlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          showResult("cancel");
        },
        onSuccess: (data) {
          debugPrint("Paypal Success: $data");
          //successfully paid
          //remove all items from queue
          _paypalNativeCheckoutPlugin.removeAllPurchaseItems();
          String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
          String address =
              data.cart?.shippingAddress?.line1 ?? 'Unknown Address';
          showResult(
            "Order successful ${data.payerId ?? ""} - ${data.orderId ?? ""} - $visitor -$address",
          );
        },
        onError: (data) {
          debugPrint("Paypal Error: ${data.reason}");
          //an error occured
          showResult("error: ${data.reason}");
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          showResult(
            "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}",
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Paypal Native Checkout"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (String t in logQueue) Text(t),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 16, 30, 227),
                  foregroundColor: Colors.white),
              child: const Text("Pay Now"),
              onPressed: () {
                //add 1 item to cart. Max is 4!
                if (_paypalNativeCheckoutPlugin.canAddMorePurchaseUnit) {
                  _paypalNativeCheckoutPlugin.addPurchaseUnit(
                    FPayPalPurchaseUnit(
                      // random prices
                      amount: Random().nextDouble() * 100,

                      ///please use your own algorithm for referenceId. Maybe ProductID?
                      referenceId: FPayPalStrHelper.getRandomString(16),
                    ),
                  );
                }
                Map<String, dynamic>? getAddress = {
                  'line1': '456 Main Dt',
                  'line2': 'Apt 4B',
                  'city': 'San Jose',
                  'state': 'CA',
                  'postalCode': '95131',
                  'countryCode': 'US',
                };

                _paypalNativeCheckoutPlugin.makeOrder(
                    action: FPayPalUserAction.payNow, address: getAddress);
              },
            ),
          ],
        ),
      ),
    );
  }

  // all to log queue
  showResult(String text) {
    logQueue.add(text);
    setState(() {});
  }
}

```


#### Troubleshooting Tips
if you have trouble using this library, read these:
- if you have a problem with the `android:label` after using the package, add these to the application tag of your `Androidmanifest.xml`

```xml

   <application
        tools:replace="android:label" 
        xmlns:tools="http://schemas.android.com/tools"
```

- The following should be activated in the developer console of Paypal for your account


* Login with paypal
* native checkout sdk
* Email and Fullname
* Vault
* Fullname & email

![Screenshot](https://github.com/sammrafi/paypal_native_checkout/raw/main/resources/media/screenshots/screenshot_2.png?raw=true "Screenshot")
![Screenshot](https://github.com/sammrafi/paypal_native_checkout/raw/main/resources/media/screenshots/screenshot_1.png?raw=true "Screenshot")
![Screenshot](https://github.com/sammrafi/paypal_native_checkout/raw/main/resources/media/screenshots/screenshot_3.png?raw=true "Screenshot")



## Updates by Sammrafi
This package is based on [flutter_paypal_native](https://github.com/harrowmykel/flutter_paypal_native) by [harrowmykel](https://github.com/harrowmykel).

---

Original package credits and link to the original GitHub repository can be found [here](https://github.com/harrowmykel/flutter_paypal_native).
