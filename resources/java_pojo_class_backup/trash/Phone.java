package com.sammrafi.paypal_native_checkout.models.approvaldata.trash;


import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;


public class Phone {

@SerializedName("number")
@Expose
private String number;

public String getNumber() {
return number;
}

public void setNumber(String number) {
this.number = number;
}

}