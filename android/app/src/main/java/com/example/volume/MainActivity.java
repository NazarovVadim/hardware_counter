package com.example.volume;



import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;
import android.view.KeyEvent;




public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.volume/counter";

    int c = 0;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            result.success(c);

                        }
                );
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event){
        if(keyCode == KeyEvent.KEYCODE_VOLUME_DOWN){
            c = c - 1;

            //System.out.println(c);
            return true;
        } else if(keyCode == KeyEvent.KEYCODE_VOLUME_UP){
            c = c + 1;

            //System.out.println(c);
            return true;
        }
        return false;
    }


    private int changeCount(  ){

        return 1;
    }

}
