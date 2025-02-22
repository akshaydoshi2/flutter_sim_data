package com.example.sim_data;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.telephony.SmsManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresPermission;
import androidx.core.app.ActivityCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/** SimDataPlugin */
public class SimDataPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {

  private static final int MY_PERMISSIONS_REQUEST_READ_PHONE_STATE = 123;
  private static final int MY_PERMISSIONS_REQUEST_SEND_SMS_STATE = 101;
  private MethodChannel channel;
  private Activity activity;
  private Result result;
  private  Context context;
  private MethodCall call;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sim_data");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
    activityPluginBinding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    this.result = result;
    this.call = call;
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + Build.VERSION.RELEASE);
    } else if(call.method.equals("get_sim_data")){
      if(hasPermissions()){
        getSimData();
      }else{
        requestPermission();
      }
    }else if(call.method.equals("send_sms")){
      if(hasSMSPermissions()){
        sendSMS();
      }else{
        requestSMSPermission();
      }
    }else{
      result.notImplemented();
    }
  }

  void getSimData(){
    SubscriptionManager subscriptionManager = null;
    JSONArray array = new JSONArray();
      subscriptionManager = (SubscriptionManager) activity.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
      List<SubscriptionInfo> infoList = subscriptionManager != null ? subscriptionManager.getActiveSubscriptionInfoList() : null;
      for(int i = 0; i < Objects.requireNonNull(infoList).size(); i++){
        JSONObject map = new JSONObject();
        try{
          map.put("COUNTRY_CODE", infoList.get(i).getCountryIso());
//          Log.i("COUNTRY_CODE", infoList.get(i).getCountryIso());

//        Log.i("ICC_ID", infoList.get(i).getIccId());
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//          Log.i("MCC_STRING", Objects.requireNonNull(infoList.get(i).getMccString()));
//        }
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//          Log.i("MNC_STRING", Objects.requireNonNull(infoList.get(i).getMncString()));
//        }

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//            Log.i("GET_PHONE_NUMBER", subscriptionManager.getPhoneNumber(infoList.get(i).getSubscriptionId()));
            map.put("PHONE_NUMBER", subscriptionManager.getPhoneNumber(infoList.get(i).getSubscriptionId()));
          }else{
//            Log.i("GET_NUMBER", infoList.get(i).getNumber());
            map.put("PHONE_NUMBER", infoList.get(i).getNumber());
          }

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            Log.i("CARD_ID", String.valueOf(infoList.get(i).getCardId()));
            map.put("CARD_ID", infoList.get(i).getCardId());
          }else{
            map.put("CARD_ID", null);
          }

//          Log.i("CARRIER_NAME", (String) infoList.get(i).getCarrierName());
          map.put("CARRIER_NAME", infoList.get(i).getCarrierName());

//          Log.i("DISPLAY_NAME", (String) infoList.get(i).getDisplayName());
          map.put("DISPLAY_NAME", infoList.get(i).getDisplayName());

//          Log.i("SIM_SLOT_INDEX", String.valueOf(infoList.get(i).getSimSlotIndex()));
          map.put("SIM_SLOT_INDEX", infoList.get(i).getSimSlotIndex());

//          Log.i("SUBSCRIPTION_ID", String.valueOf(infoList.get(i).getSubscriptionId()));
          map.put("SUBSCRIPTION_ID", infoList.get(i).getSubscriptionId());

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            Log.i("IS_EMBEDDED", String.valueOf(infoList.get(i).isEmbedded()));
            map.put("IS_EMBEDDED", infoList.get(i).isEmbedded());
          }else{
            map.put("IS_EMBEDDED", false);
          }
//          Log.i("SIM_DATA", "------------------------------------------------------");
        }catch(JSONException e){
//          e.printStackTrace();
          result.error("Error","Something went wrong!", "");
        }
        array.put(map);
      }
      result.success(array.toString());
  }

//  @SuppressLint("UnspecifiedRegisterReceiverFlag")
  void sendSMS(){
    String number = call.argument("phone");
    String message = call.argument("msg");
    Integer subId = call.argument("subId");

    String sent = "SMS_SENT";
    String delivered = "SMS_DELIVERED";
    PendingIntent sendPendingIntent;
    PendingIntent deliveryPendingIntent;

      SmsManager smsManager = SmsManager.getSmsManagerForSubscriptionId(subId);

      sendPendingIntent = PendingIntent.getBroadcast(
        context,
        1,
        new Intent(sent),
        PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
      );
      deliveryPendingIntent = PendingIntent.getBroadcast(
        context,
        2,
        new Intent(delivered),
        PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
      );

    BroadcastReceiver sentReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            int res = getResultCode();
            if (res == Activity.RESULT_OK) {
                Toast.makeText(context, "SMS Sent", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(context, "SMS not sent. Something went wrong!", Toast.LENGTH_SHORT).show();
            }
        }
    };

    BroadcastReceiver deliveredReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            int res = getResultCode();
            if (res == Activity.RESULT_OK) {
                Toast.makeText(context, "SMS delivered", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(context, "SMS not delivered", Toast.LENGTH_SHORT).show();
            }
        }
    };

    IntentFilter sentFilter = new IntentFilter(sent);
    IntentFilter deliveredFilter = new IntentFilter(delivered);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        context.registerReceiver(sentReceiver, sentFilter, Context.RECEIVER_EXPORTED);
        context.registerReceiver(deliveredReceiver, deliveredFilter, Context.RECEIVER_EXPORTED);
    } else {
        context.registerReceiver(sentReceiver, sentFilter);
        context.registerReceiver(deliveredReceiver, deliveredFilter);
    }

      smsManager.sendTextMessage(number, null, message, sendPendingIntent, deliveryPendingIntent);
  }

  private void requestPermission(){
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
      activity.requestPermissions(
        new String[]{
          Manifest.permission.READ_PHONE_NUMBERS,
          Manifest.permission.READ_PHONE_STATE,
        },
        MY_PERMISSIONS_REQUEST_READ_PHONE_STATE
      );
    } else {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        activity.requestPermissions(
          new String[]{
            Manifest.permission.READ_PHONE_STATE,
          },
          MY_PERMISSIONS_REQUEST_READ_PHONE_STATE
        );
      }else{
        ActivityCompat.requestPermissions(
          activity,
          new String[]{
            Manifest.permission.READ_PHONE_STATE,
          },
          MY_PERMISSIONS_REQUEST_READ_PHONE_STATE
        );
      }
    }
  }

  private boolean hasPermissions() {
    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      return ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_PHONE_NUMBERS) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED;
    } else {
      return ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED;
    }
  }

  private boolean hasSMSPermissions() {
    return ActivityCompat.checkSelfPermission(activity, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED;
  }

  void requestSMSPermission(){
    ActivityCompat.requestPermissions(
      activity,
      new String[]{
        Manifest.permission.SEND_SMS
      },
      MY_PERMISSIONS_REQUEST_SEND_SMS_STATE
    );
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == MY_PERMISSIONS_REQUEST_READ_PHONE_STATE) {
      if (grantResults.length > 0 && isGranted(grantResults)) {
        getSimData();
        return true;
      }
    }
    if (requestCode == MY_PERMISSIONS_REQUEST_SEND_SMS_STATE){
      if (grantResults.length > 0 && isGranted(grantResults)) {
        sendSMS();
        return true;
      }
    }
//    result.error("PERMISSION", "onRequestPermissionsResult is not granted", null);
    return false;
  }

  boolean isGranted(int[] arr) {
    for (int num : arr) {
      if (num != PackageManager.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }
}
