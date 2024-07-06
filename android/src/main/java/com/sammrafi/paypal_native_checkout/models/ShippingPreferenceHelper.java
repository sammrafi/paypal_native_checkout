package com.sammrafi.paypal_native_checkout.models;

import com.paypal.checkout.createorder.ShippingPreference;

import java.util.HashMap;
import java.util.Map;

public class ShippingPreferenceHelper {
    Map<String, ShippingPreference> data =new HashMap<String, ShippingPreference>();

    public ShippingPreferenceHelper(){
        data.put("GET_FROM_FILE",ShippingPreference.GET_FROM_FILE);
        data.put("NO_SHIPPING",ShippingPreference.NO_SHIPPING);
        data.put("SET_PROVIDED_ADDRESS",ShippingPreference.SET_PROVIDED_ADDRESS);
    }

    public ShippingPreference getEnumFromString( String which){
        if(data.get(which)!=null){
            return data.get(which);
        }
        return ShippingPreference.GET_FROM_FILE;
    }

}
