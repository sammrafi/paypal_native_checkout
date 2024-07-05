package com.sammrafi.paypal_native_checkout.models;

import com.paypal.checkout.createorder.UserAction;

import java.util.HashMap;
import java.util.Map;

public class UserActionHelper {
    Map<String, UserAction> data =new HashMap<String, UserAction>();

    public UserActionHelper(){
        data.put("continuePayment",UserAction.CONTINUE);
        data.put("payNow",UserAction.PAY_NOW);
    }

    public UserAction getEnumFromString( String which){
        if(data.get(which)!=null){
            return data.get(which);
        }
        return UserAction.CONTINUE;
    }

}
