import 'package:paypal_native_checkout/models/approval/approval_data.dart';
import 'package:paypal_native_checkout/models/custom/error_info.dart';
import 'package:paypal_native_checkout/models/shipping_change/shipping_info.dart';

class FPayPalOrderCallback {
  void Function(FPayPalApprovalData success) onSuccess;
  void Function(FPayPalErrorInfo error)? onError;
  void Function()? onCancel;
  void Function(FPayPalShippingChangeInfo shipping)? onShippingChange;

  String onSuccessMessage;
  String onErrorMessage;
  String onCancelMessage;
  String onShippingChangeMessage;

  FPayPalOrderCallback({
    required this.onSuccess,
    this.onError,
    this.onCancel,
    this.onShippingChange,
    this.onSuccessMessage = "Order approved",
    this.onErrorMessage = "Error creating order",
    this.onCancelMessage = "Order cancelled",
    this.onShippingChangeMessage = "Shipping change",
  });
}
