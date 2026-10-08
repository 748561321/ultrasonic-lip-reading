package com.example.zii;

import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;

import com.example.zii.utils.ChirpGenerator;

public class ChirpPlayer implements Runnable {

//    private MonoRecorder recorder = null;
    private StereoRecorder recorder = null;
    public boolean playing = false;
    public int sampleRate = 48000; // 48000
    public int sessionID = 0;
    public String wavBasePath = "/storage/0/emulated/Zii";

    AudioTrack track = new AudioTrack.Builder()
            .setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build())
            .setAudioFormat(new AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(this.sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build())
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build();

//    ChirpPlayer(MonoRecorder recorder) {
//        this.recorder = recorder;
//    }
    ChirpPlayer(StereoRecorder recorder) {
        this.recorder = recorder;
    }

    @Override
    public void run() {

        track.setStereoVolume(0, 1);

        byte[] chirpFrame = ChirpGenerator.genPCM16MonoToneBytes(
                this.sampleRate,
                14000, 23000, 0.005, 0.005, // 14000, 23000, 0.005, 0.005
                1,
                true);

        // wait until recorder start recording
        while (!recorder.getRecording()) { Thread.yield(); }

        track.play();
        setPlaying(true);
        while (getPlaying()) {
            track.write(chirpFrame, 0, chirpFrame.length);
        }
        track.pause();
        track.flush();

        // stop recorder from player
        recorder.setRecording(false);

    }

    public int getSessionID() {
        return this.sessionID;
    }
    public void setSessionID(int id) {
        this.sessionID = id;
    }

    synchronized public boolean getPlaying() {
        return playing;
    }
    synchronized public void setPlaying(boolean v) {
        playing = v;
    }

}
