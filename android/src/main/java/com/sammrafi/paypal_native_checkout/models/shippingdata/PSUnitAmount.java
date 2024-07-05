package com.sammrafi.paypal_native_checkout.models.shippingdata;


import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.paypal.checkout.order.UnitAmount;
import com.sammrafi.paypal_native_checkout.models.CurrencyCodeHelper;
import com.sammrafi.paypal_native_checkout.models.approvaldata.PPAmount;


public class PSUnitAmount {
    @SerializedName("currencyCode")
    @Expose
    private String currencyCode;
    @SerializedName("currencyValue")
    @Expose
    private String currencyValue;


    public String getCurrencyCode() {
        return currencyCode;
    }

    public void setCurrencyCode(String currencyCode) {
        this.currencyCode = currencyCode;
    }

    public String getCurrencyValue() {
        return currencyValue;
    }

    public void setCurrencyValue(String currencyValue) {
        this.currencyValue = currencyValue;
    }

    public static PSUnitAmount fromPayPalObject(UnitAmount amount) {
        PSUnitAmount app = new PSUnitAmount();
        CurrencyCodeHelper c = new CurrencyCodeHelper();
        app.setCurrencyCode(c.getStringFromEnum(amount.getCurrencyCode()));
        app.setCurrencyValue(amount.getValue());
        return app;
    }


}