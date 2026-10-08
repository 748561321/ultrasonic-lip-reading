package com.example.zii;

import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.media.MediaSyncEvent;

import com.example.zii.utils.Common;

import java.io.RandomAccessFile;

public class MonoRecorder implements Runnable {

    public boolean recording = false;
    public int sampleRate = 96000;
    public int frameSize = 2048;
    public int bytesPerFrame = 2;

    public String recBasePath = "/storage/emulated/0/Music";
    public String recDirName = "Zii";
    public String recFileName = null;


    private int channelMask = AudioFormat.CHANNEL_IN_MONO;
    AudioRecord aRec = new AudioRecord.Builder()
            .setAudioSource(MediaRecorder.AudioSource.MIC)
            .setAudioFormat(new AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(channelMask)
                    .build())
            .build();

    @Override
    public void run() {

        try{
            RandomAccessFile raf = new RandomAccessFile(
                    recBasePath + '/' + getRecFileName() + ".wav",
                    "rw");
            raf.seek(44);

            byte[] data = new byte[frameSize * bytesPerFrame];

            aRec.startRecording();
            setRecording(true);

            while (getRecording()) {
                int readSize = aRec.read(data, 0, data.length);
                raf.write(data, 0, readSize);
                System.out.println("readSize = " + readSize);
            }

            aRec.stop();
            //aRec.release();

            int channelCnt = Common.getChannelNumFromConfig(channelMask);
            int sampleBits = 16;
            Common.writeWavFileHeader(
                    raf, raf.length(), sampleRate,
                    channelCnt,
                    sampleRate * sampleBits * channelCnt / 8);
            raf.close();

            setRecording(false);
            System.err.println("Finish recording");

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    synchronized public boolean getRecording() {
        return this.recording;
    }
    synchronized public void setRecording(boolean recording) {
        this.recording = recording;
    }

    synchronized public void setRecFileName(String recFileName) {
        this.recFileName = recFileName;
    }
    synchronized public String getRecFileName() {
        return this.recFileName;
    }
}
