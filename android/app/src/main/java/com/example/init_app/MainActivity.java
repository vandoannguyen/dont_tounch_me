package com.example.init_app;

import android.Manifest;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.example.init_app.common.Common;
import com.example.init_app.utils.SharedPrefsUtils;
import com.example.ratedialog.RatingDialog;

import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements RatingDialog.RatingDialogInterFace {
    private static final String CHANNEL = "com.example.init_app";
    private static final int READ_STOGARE_CODE = 1;
    private static final int CAM_PERMISSION_CODE = 2;
    private static Intent intent;
    private static MyService myService;
    private static BatteryRecerver recerver;
    private static IntentFilter ifilter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        recerver = new BatteryRecerver(this);
        ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);

        myService = MyService.getInstance();
        intent = new Intent(MainActivity.this, myService.getClass());

        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                switch (methodCall.method) {
                    case "rateManual": {
                        rateManual();
                        break;
                    }
                    case "rateAuto": {
                        rateAuto();
                        break;
                    }
                    case "setNotifi": {
                        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            if (checkFlashPermission())
                            {
                                startService(intent);
                            }
                            else requestFlashPermission();
                        }
                        break;
                    }
                    case "setOffNotifi": {
                        stopService(intent);
                        break;
                    }
                    case "toast": {
                        Toast.makeText(MainActivity.this, methodCall.argument("mess"), Toast.LENGTH_SHORT).show();
                        break;
                    }
                    case "chargeSate": {
                        if (methodCall.argument("isSet")) {
                            registerReceiver(recerver, ifilter);
                        } else unregisterReceiver(recerver);
                        break;
                    }
                    case "openMucis": {
                        if (checkReadStogarePermission()) {
                            intentToGallery();
                        } else requestReadStogarePermission();
                        break;
                    }
                }
            }
        });

    }

    private void requestFlashPermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, CAM_PERMISSION_CODE);
    }

    private boolean checkFlashPermission() {
        return ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED;
    }

    private void intentToGallery() {
        final Intent intent2 = new Intent(Intent.ACTION_GET_CONTENT);
        intent2.setType("audio/*");
        startActivityForResult(intent2, 1);
    }

    private void requestReadStogarePermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, READ_STOGARE_CODE);
    }

    private boolean checkReadStogarePermission() {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
                ==
                PackageManager.PERMISSION_GRANTED;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == READ_STOGARE_CODE) {
            if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                intentToGallery();
            } else {
                requestReadStogarePermission();
            }
        }
        if (requestCode == CAM_PERMISSION_CODE) {
            if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startService(intent);
            } else {
                requestFlashPermission();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1) {
            if (resultCode == RESULT_OK) {
                SharedPrefsUtils.getInstance(getApplicationContext()).putString(Common.SEF_RING_TONE, data.getData().toString());
                Log.e("onActivityResult: ", data.getData().toString());
            }
        }
    }

    public static void rateApp(Context context) {
        Intent intent = new Intent(new Intent(Intent.ACTION_VIEW,
                Uri.parse("http://play.google.com/store/apps/details?id=" + context.getPackageName())));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    //Rate
    private void rateAuto() {
        int rate = SharedPrefsUtils.getInstance(this).getInt("rate");
        if (rate < 1) {
            RatingDialog ratingDialog = new RatingDialog(this);
            ratingDialog.setRatingDialogListener(this);
            ratingDialog.showDialog();
        }
    }

    private void rateManual() {
        RatingDialog ratingDialog = new RatingDialog(this);
        ratingDialog.setRatingDialogListener(this);
        ratingDialog.showDialog();
    }

    @Override
    public void onDismiss() {

    }

    @Override
    public void onSubmit(float rating) {
        if (rating > 3) {
            rateApp(this);
            SharedPrefsUtils.getInstance(this).putInt("rate", 5);
        }
    }

    @Override
    public void onRatingChanged(float rating) {
    }

    public boolean isServiceRunning(String serviceClassName) {
        final ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        final List<ActivityManager.RunningServiceInfo> services = activityManager.getRunningServices(Integer.MAX_VALUE);

        for (ActivityManager.RunningServiceInfo runningServiceInfo : services) {
            if (runningServiceInfo.service.getClassName().equals(serviceClassName)) {
                return true;
            }
        }
        return false;
    }
//    private boolean isMyServiceRunning(Class<?> serviceClass) {
//        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
//        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
//            if (serviceClass.getName().equals(service.service.getClassName())) {
//                return true;
//            }
//        }
//        return false;
//    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
//        unregisterReceiver(recerver);
    }
}
