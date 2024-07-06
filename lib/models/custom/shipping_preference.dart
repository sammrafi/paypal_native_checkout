enum FPayPalShippingPreference {
  getFromFile,
  noShipping,
  setProvidedAddress
}

class FPayPalShippingPreferenceHelper {
  static const Map<FPayPalShippingPreference, String> codes = {
    FPayPalShippingPreference.getFromFile: "GET_FROM_FILE",
    FPayPalShippingPreference.noShipping: "NO_SHIPPING",
    FPayPalShippingPreference.setProvidedAddress: "SET_PROVIDED_ADDRESS"
  };

  //convert enum to string
  static String convertFromEnumToString(FPayPalShippingPreference envv) {
    if (codes[envv] != null) {
      return codes[envv]!;
    }
    return codes[FPayPalShippingPreference.getFromFile]!;
  }
}
