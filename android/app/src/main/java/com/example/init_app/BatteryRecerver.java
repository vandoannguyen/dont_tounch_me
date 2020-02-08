package com.example.init_app;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.BatteryManager;
import android.os.PowerManager;
import android.util.Log;
import android.widget.Toast;

import androidx.core.content.ContextCompat;

import com.example.init_app.common.Common;
import com.example.init_app.utils.SharedPrefsUtils;

import java.util.List;

public class BatteryRecerver extends BroadcastReceiver {
    boolean isInsertPlugged = false;
    Activity activity;
    public BatteryRecerver(Activity activity) {
        this.activity = activity;
        isInsertPlugged = false;
    }

    public BatteryRecerver() {
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        int plugged = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);

        if (plugged == BatteryManager.BATTERY_PLUGGED_AC || plugged == BatteryManager.BATTERY_PLUGGED_USB) {
            Log.e("Tag", "onReceive: Device charging ");
            isInsertPlugged = true;
        } else {
            if(SharedPrefsUtils.getInstance(context).getBoolean(Common.SEF_CHECK_IS_PIN)&&isInsertPlugged ) {
                MyService myService = MyService.getInstance();
                Log.e("tag", "onReceive: Device not charging");
                Intent intent1 = new Intent(context,myService.getClass());
                intent1.putExtra("key", "10000");
                context.startService(intent1);
                SharedPrefsUtils.getInstance(context).putBoolean(Common.SERVICE_IS_RUNNING, true);
                activity.recreate();
            }
            isInsertPlugged = false;
        }
    } public boolean isServiceRunning(Context context, String serviceClassName) {
        final ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        final List<ActivityManager.RunningServiceInfo> services = activityManager.getRunningServices(Integer.MAX_VALUE);

        for (ActivityManager.RunningServiceInfo runningServiceInfo : services) {
            if (runningServiceInfo.service.getClassName().equals(serviceClassName)) {
                return true;
            }
        }
        return false;
    }
}
