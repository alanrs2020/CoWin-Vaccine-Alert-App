package com.cowinappalert.cowinapp;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {


    private static final String CHANNEL = "native_java";
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);



        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "Save":
                                    String path = this.getFilesDir().getAbsolutePath();
                                    result.success(path);
                                default:
                                    Log.e("f","Error");
                                    break;
                            }});

    }
}
