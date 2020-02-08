package com.example.init_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import android.os.Vibrator;
import android.util.Log;
import android.widget.Toast;

import com.example.init_app.common.Common;
import com.example.init_app.utils.SharedPrefsUtils;

import static android.app.Notification.PRIORITY_MIN;

public class MyService extends Service {
    private static MyService myService;
    private static final int ID_SERVICE = 101;
    private static SensorManager sensorManager;
    private static Sensor sensor;
    private static boolean isMoving = false;
    private static Vibrator vib;
    private static Camera cam;
    private static Handler handler;
    private static Runnable runnable;
    private Integer log, ollog;
    private SharedPrefsUtils prefsUtils;
    Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
    Ringtone r;

    public static MyService getInstance() {
        return myService != null ? myService : (myService = new MyService());
    }

    public MyService() {
    }

    @Override
    public void onCreate() {
        prefsUtils = SharedPrefsUtils.getInstance(getApplicationContext());
        Log.e("TAG", "onCreate: ");
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        Log.e("onCreate: ", sensor.getName());
        super.onCreate();
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        String channelId = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? createNotificationChannel(notificationManager) : "";
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, channelId);
        Notification notification = notificationBuilder.setOngoing(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Bật chế độ cảnh báo")
                .setPriority(PRIORITY_MIN)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .build();

        startForeground(ID_SERVICE, notification);
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private String createNotificationChannel(NotificationManager notificationManager) {
        String channelId = "my_service_channelid";
        String channelName = "My Foreground Service";
        NotificationChannel channel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH);
        // omitted the LED color
        channel.setImportance(NotificationManager.IMPORTANCE_NONE);
        channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        notificationManager.createNotificationChannel(channel);
        return channelId;
    }

    public static void stop() {
        if (myService != null) {
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.e("TAG", "onStartCommand: ");
        if (sensor != null && SharedPrefsUtils.getInstance(getApplicationContext()).getBoolean(Common.SEF_IS_CHECK_TOUNCH)) {
            sensorManager.registerListener(mySensorEventListener, sensor,
                    SensorManager.SENSOR_DELAY_NORMAL);
            Log.e("Compass MainActivity", "Registerered for ORIENTATION Sensor");
        } else {
            Log.e("Compass MainActivity", "Registerered for ORIENTATION Sensor");
            Toast.makeText(this, "ORIENTATION Sensor not found",
                    Toast.LENGTH_LONG).show();
        }

        if (SharedPrefsUtils.getInstance(getApplicationContext()).getBoolean(Common.SEF_CHECK_IS_PIN)
                && intent.getStringExtra("key") != null
        )
            setNotify();
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onStart(Intent intent, int startId) {
        super.onStart(intent, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onDestroy() {
        Log.e("TAG", "onDestroy: ");
        if (sensor != null) {
            sensorManager.unregisterListener(mySensorEventListener);
        }
        if (r != null) r.stop();
        if (vib != null) vib.cancel();
        if (handler != null) handler.removeCallbacks(runnable);
        if (cam != null) {
//            cam.getParameters().setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
            cam.stopPreview();
        }
        super.onDestroy();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    private SensorEventListener mySensorEventListener = new SensorEventListener() {

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
            Log.e("onAccuracyChanged: ", accuracy + "");
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            if (log != null && Math.abs((log - (int) (event.values[0] + event.values[1] + event.values[2]))) >= 3) {
                Log.e("onSensorChanged: ", "" + Math.abs((log - (int) (event.values[0] + event.values[1] + event.values[2]))));
                isMoving = true;
                Log.e("TAG", "onSensorChanged: ismoving");
            } else {
                isMoving = false;
                Log.e("TAG", "onSensorChanged: not move");
            }
            log = (int) (event.values[0] + event.values[1] + event.values[2]);
            if (r == null && isMoving) {
                setNotify();
            }
        }
    };

    private void setNotify() {
        intentToActivity();
        setRingTone();
        boolean isVibration = prefsUtils.getBoolean(Common.SEF_CHECK_IS_VIBRATION);
        if (isVibration)
            setVibration();
        if (prefsUtils.getBoolean(Common.SEF_CHECK_IS_FLASH))
            setFlash();


    }

    private void setFlash() {
        if (getPackageManager().hasSystemFeature(
                PackageManager.FEATURE_CAMERA_FLASH)) {
            cam = Camera.open();
            Camera.Parameters p = cam.getParameters();
            handler = new Handler();
            handler.postDelayed(runnable = new Runnable() {
                @Override
                public void run() {
                    p.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
                    cam.setParameters(p);
                    cam.startPreview();
                    try {
                        Thread.sleep(300);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    p.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
                    cam.setParameters(p);
                    handler.postDelayed(this, 300);
                }

            }, 300);
        }
    }

    private void setVibration() {
        if (vib == null || vib.hasVibrator()) {
            vib = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
            int dot = 200; // Length of a Morse Code "dot" in milliseconds
            int dash = 500; // Length of a Morse Code "dash" in milliseconds
            int short_gap = 200; // Length of Gap Between dots/dashes
            int medium_gap = 500; // Length of Gap Between Letters
            int long_gap = 1000; // Length of Gap Between Words
            long[] pattern = {0, // Start immediately
                    dot, short_gap, dot, short_gap, dot, // s
                    medium_gap, dash, short_gap, dash, short_gap, dash, // o
                    medium_gap, dot, short_gap, dot, short_gap, dot, // s
                    long_gap};
            vib.vibrate(pattern, 1);
        }
    }

    private void setRingTone() {
        if (r == null || !r.isPlaying()) {
            String uriString = prefsUtils.getString(Common.SEF_RING_TONE);
            Log.e("onSensorChanged:123 ", uriString);
            Uri uri;
            if (uriString.equals("") || uriString.equals("default"))
                uri = Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.bao_dong);
            else uri = Uri.parse(uriString);
            Log.e("onSensorChanged: ", uri.toString());
            r = RingtoneManager.getRingtone(getApplicationContext(), uri);
            r.setLooping(true);
            r.play();
        }
    }

    private void intentToActivity() {
        Intent intent = new Intent(MyService.this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }
}

