import Flutter
import UIKit
import PayPalCheckout

public class SwiftPaypalNativeCheckoutPlugin: NSObject, FlutterPlugin {
    private static let METHOD_CHANNEL_NAME = "flutter_paypal_native"

    static var channel: FlutterMethodChannel?
    static var paypalCallBackHelper: PayPalCallBackHelper?

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        paypalCallBackHelper = PayPalCallBackHelper(flutterChannel: channel!)
        let instance = SwiftPaypalNativeCheckoutPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "FlutterPaypal#initiate":
            initiatePackage(call, result)
            result("successfully initiated")
            break
        case "FlutterPaypal#makeOrder":
            makeOrder(call, result)
            result("makeOrder")
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func userActionFromString(_ rawValueString: String) -> OrderApplicationContext.UserAction {
        switch rawValueString {
        case "payNow":
            return .payNow
        case "continuePayment":
            return .continue
        default:
            return .payNow
        }
    }

    func initiatePackage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
//        let returnURL = args["returnUrl"] as! String // Outdated
        let clientID = args["clientId"] as! String
        let payPalEnvironmentStr = args["payPalEnvironment"] as! String
        let currencyStr = args["currency"] as! String

        let payPalEnvironment = Environment.init(rawValueString: payPalEnvironmentStr)
        let currency = CurrencyCode.withLabel(rawValue: currencyStr)


        Checkout.set(config: CheckoutConfig(
                clientID: clientID,
                onApprove: { approval in
                    do {
                    try SwiftPaypalNativeCheckoutPlugin.paypalCallBackHelper?.onApprove(approval)
                        print("Payment approved: \(approval)")
                    } catch {
                        print("Error in onApprove: \(error)")
                    }
                },
                onShippingChange: { change, action in
                  action.approve()
                },
                onCancel: SwiftPaypalNativeCheckoutPlugin
                        .paypalCallBackHelper?
                        .onCancel,
                onError: SwiftPaypalNativeCheckoutPlugin
                        .paypalCallBackHelper?
                        .onError,
                
                environment: payPalEnvironment
        ))
    }

    func makeOrder(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments",
                    details: nil
            ))
            return
        }
        let purchaseUnitsStr = args["purchaseUnits"] as! String
        let userActionStr = args["userAction"] as! String
        let userAction = userActionFromString(userActionStr)

        let listCustomUnit = try! JSONDecoder().decode([CustomUnit].self, from: purchaseUnitsStr.data(using: .utf8)!)
        var purchaseUnits: [PurchaseUnit] = []
        for customUnit in listCustomUnit {
            let amount = PayPalCheckout.PurchaseUnit.Amount(
                    currencyCode: CurrencyCode.withLabel(rawValue: customUnit.currency),
                    value: customUnit.price
            )

            let purchaseUnit = PayPalCheckout.PurchaseUnit(
                    amount: amount,
                    referenceId: customUnit.referenceId
            )

            purchaseUnits.append(purchaseUnit)
        }
        Checkout.start(
                createOrder: { action in
                    let order = OrderRequest(
                            intent: .capture,
                            purchaseUnits: purchaseUnits,
                            applicationContext: OrderApplicationContext(userAction: userAction)
                    )
                    action.create(order: order)
                    print("Order created: \(order)")
                },
                onError: { error in
                    print("Error creating order: \(error)")
                }
        )

    }
}
