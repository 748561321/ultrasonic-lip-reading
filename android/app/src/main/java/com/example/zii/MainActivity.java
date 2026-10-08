package com.example.zii;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.example.zii.utils.Common;

public class MainActivity extends AppCompatActivity {

//    MonoRecorder monoRecorder = new MonoRecorder();
    StereoRecorder stereoRecorder = new StereoRecorder();
    ChirpPlayer chirpPlayer = new ChirpPlayer(stereoRecorder);
    Thread recorderThread = new Thread(stereoRecorder);
    Thread chirpPlayerThread = new Thread(chirpPlayer);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Common.requestPermissons(this);

        Button ctrlBtn = (Button) findViewById(R.id.button_ctrl);
        TextView logView = (TextView) findViewById(R.id.text_log);

        ctrlBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    if (((String)v.getTag()).equals("0")) {
                        chirpPlayerThread.join();
                        recorderThread.join();

                        stereoRecorder.setRecFileName(
                                "Zii-" + Long.toString(System.currentTimeMillis() / 1000L));
                        recorderThread = new Thread(stereoRecorder);
                        chirpPlayerThread = new Thread(chirpPlayer);
                        recorderThread.start();
                        chirpPlayerThread.start();

                        v.setTag("1");
                        ctrlBtn.setText("END");
                    } else {
                        // recorder is stopped from player
                        chirpPlayer.setPlaying(false);
                        while (stereoRecorder.getRecording()) {Thread.yield();}
                        v.setTag("0");
                        ctrlBtn.setText("START 14k-23k");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

}