import Flutter
import UIKit
import PayPalCheckout

public class SwiftPaypalNativeCheckoutPlugin: NSObject, FlutterPlugin {
    private static let METHOD_CHANNEL_NAME = "paypal_native_checkout"

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

    func createShipping(from addressDetails: [String: Any], name fullNameStr: String?) -> PurchaseUnit.Shipping? {
        guard let line1 = addressDetails["line1"] as? String,
              let city = addressDetails["city"] as? String,
              let state = addressDetails["state"] as? String,
              let postalCode = addressDetails["postalCode"] as? String,
              let countryCode = addressDetails["countryCode"] as? String else {
            return nil
        }

    
        let line2 = addressDetails["line2"] as? String ?? ""
        let fullName = fullNameStr ?? ""
        let shippingName = fullName.isEmpty ? nil : PurchaseUnit.ShippingName.init(fullName: fullName)
        let address = OrderAddress(
        countryCode: countryCode,
        addressLine1: line1,
        addressLine2: line2,
        adminArea1: state,
        adminArea2: city,
        postalCode: postalCode
    )
        return PurchaseUnit.Shipping(shippingName: shippingName, address: address)
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
        let fullNameStr = args["fullName"] as? String
        let userActionStr = args["userAction"] as! String
        let shippingPreferenceStr = args["shippingPreference"] as! String
        let userAction = userActionFromString(userActionStr)
        
        //shipping prefersence
        var shippingPreference: PayPalCheckout.OrderApplicationContext.ShippingPreference = .noShipping
            switch shippingPreferenceStr {
            case "NO_SHIPPING":
                shippingPreference = .noShipping
            case "SET_PROVIDED_ADDRESS":
                shippingPreference = .setProvidedAddress
            case "GET_FROM_FILE":
                shippingPreference = .getFromFile
            default:
                shippingPreference = .noShipping
            }

        let listCustomUnit = try! JSONDecoder().decode([CustomUnit].self, from: purchaseUnitsStr.data(using: .utf8)!)
        
        // Address check and serializer
        var shipping: PurchaseUnit.Shipping? = nil
        if let addressJson = args["address"] as? String {
            if let addressData = addressJson.data(using: .utf8) {
                do {
                    if let addressDetails = try JSONSerialization.jsonObject(with: addressData, options: []) as? [String: Any] {
                        shipping = createShipping(from: addressDetails, name: fullNameStr)
                    }
                } catch {
                    result(FlutterError(
                            code: "JSON_PARSE_ERROR",
                            message: "Error parsing address JSON",
                            details: error.localizedDescription
                    ))
                    return
                }
            }
        }

        

        var purchaseUnits: [PurchaseUnit] = []
        for customUnit in listCustomUnit {
            let amount = PayPalCheckout.PurchaseUnit.Amount(
                    currencyCode: CurrencyCode.withLabel(rawValue: customUnit.currency),
                    value: customUnit.price
            )

            let purchaseUnit = PayPalCheckout.PurchaseUnit(
                    amount: amount,
                    referenceId: customUnit.referenceId,
                    shipping: shipping         
            )

            purchaseUnits.append(purchaseUnit)
        }

        
        Checkout.start(
                createOrder: { action in
                    let order = OrderRequest(
                            intent: .authorize,
                            purchaseUnits: purchaseUnits,
                            applicationContext: OrderApplicationContext(shippingPreference: shippingPreference, userAction: userAction)
                    )
                    action.create(order: order)
                    print("Order created: \(order)")
                },
                onError: { error in
                    print("Error creating order: \(error)")
                }
        )

        result(nil)

    }
}
