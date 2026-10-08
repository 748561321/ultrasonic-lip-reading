package com.example.zii.utils;

public class ChirpGenerator {

    static public byte[] genPCM16MonoToneBytes(
            int sampleRate,
            double fStart,
            double fEnd,
            double tSweep,
            double tFrame,
            int times,
            boolean applyHamming)
    {

        int chirpSampleCnt = (int) Math.round(tSweep * sampleRate);
        int frameSampleCnt = (int) Math.round(tFrame * sampleRate);

        // generate Window
        int windowSize = chirpSampleCnt;
        double[] sample = new double[frameSampleCnt * times];
        double[] factors = new double[windowSize];
        for(int i = 0; i < windowSize; i++) {
            if (applyHamming) {
                // Hamming
//                factors[i] = 0.54d - 0.46d * Math.cos((2 * Math.PI * i) / (windowSize-1));
                factors[i] = 0.5 * (1 - Math.cos((2 * Math.PI * i) / (windowSize-1)));
            } else {
                factors[i] = 1.0d;
            }
        }

        int t = 0;
        while (t < times) {
            double instfreq, numerator;
            for (int i = 0; i < chirpSampleCnt; i++)
            {
                numerator = (double)(i) / (double) chirpSampleCnt;
                instfreq = fStart + (0.5 * numerator * (fEnd - fStart));
                // apply window
                sample[i + t * frameSampleCnt] = factors[i] * Math.cos(2.0 * Math.PI * i / (sampleRate / instfreq));
            }
            for (int i = chirpSampleCnt; i < frameSampleCnt; i++) {
                sample[i + t * frameSampleCnt] = 0.0;
            }
            t++;
        }

        int idx = 0;
        byte[] data = new byte[2 * frameSampleCnt * times];
        for (final double dVal : sample) {
            // scale to maximum amplitude
            final short val = (short) ((dVal * 32767)); // max positive sample for signed 16 bit integers is 32767
            // in 16 bit wave PCM, first byte is the low order byte (pcm: pulse control modulation)
            data[idx++] = (byte) (val & 0x00ff);
            data[idx++] = (byte) ((val & 0xff00) >>> 8);
        }

        return data;
    }

}
