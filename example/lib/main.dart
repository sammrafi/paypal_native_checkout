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
      home: const MyHomePage(title: 'Paypal Native Checkout'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
