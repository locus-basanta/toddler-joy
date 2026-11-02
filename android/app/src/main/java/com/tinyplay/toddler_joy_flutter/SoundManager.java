package com.tinyplay.toddler_joy_flutter;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.speech.tts.TextToSpeech;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SoundManager implements TextToSpeech.OnInitListener {
    private static final int SAMPLE_RATE = 44100;
    private final Context context;
    private final Vibrator vibrator;
    private TextToSpeech tts;
    private boolean ttsReady = false;
    private final ExecutorService audioExecutor = Executors.newFixedThreadPool(4);

    private final Map<String, short[]> soundBuffers = new HashMap<>();

    public SoundManager(Context context) {
        this.context = context.getApplicationContext();
        this.vibrator = (Vibrator) this.context.getSystemService(Context.VIBRATOR_SERVICE);
        try {
            this.tts = new TextToSpeech(this.context, this);
        } catch (Exception ignored) {}

        audioExecutor.execute(this::preGenerateSounds);
    }

    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS && tts != null) {
            int result = tts.setLanguage(Locale.US);
            if (result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED) {
                ttsReady = true;
                tts.setPitch(1.25f);
                tts.setSpeechRate(0.95f);
            }
        }
    }

    public void speak(String text) {
        if (ttsReady && tts != null) {
            tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tts_" + System.currentTimeMillis());
        }
    }

    public void vibrateShort() {
        if (vibrator == null || !vibrator.hasVibrator()) return;
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(25, VibrationEffect.DEFAULT_AMPLITUDE));
            } else {
                vibrator.vibrate(25);
            }
        } catch (Exception ignored) {}
    }

    public void playSound(String soundKey) {
        vibrateShort();
        audioExecutor.execute(() -> {
            short[] pcm = soundBuffers.get(soundKey);
            if (pcm != null) {
                playPcm(pcm);
            }
        });
    }

    private void playPcm(short[] pcm) {
        try {
            AudioTrack track;
            int bufferSize = pcm.length * 2;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                track = new AudioTrack(
                    new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_GAME)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                    new AudioFormat.Builder()
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(SAMPLE_RATE)
                        .build(),
                    bufferSize,
                    AudioTrack.MODE_STATIC,
                    AudioManager.AUDIO_SESSION_ID_GENERATE
                );
            } else {
                track = new AudioTrack(
                    AudioManager.STREAM_MUSIC,
                    SAMPLE_RATE,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    bufferSize,
                    AudioTrack.MODE_STATIC
                );
            }
            track.write(pcm, 0, pcm.length);
            track.play();
            audioExecutor.execute(() -> {
                try {
                    Thread.sleep((pcm.length * 1000L / SAMPLE_RATE) + 150);
                    track.stop();
                    track.release();
                } catch (Exception ignored) {}
            });
        } catch (Exception ignored) {}
    }

    private void preGenerateSounds() {
        double[] freqs = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25};
        String[] noteNames = {"note_c4", "note_d4", "note_e4", "note_f4", "note_g4", "note_a4", "note_b4", "note_c5"};
        for (int i = 0; i < freqs.length; i++) {
            soundBuffers.put(noteNames[i], generateChime(freqs[i], 0.7));
        }

        soundBuffers.put("pop", generateBubblePop());
        soundBuffers.put("dog", generateDogBark());
        soundBuffers.put("cat", generateCatMeow());
        soundBuffers.put("lion", generateLionRoar());
        soundBuffers.put("cow", generateCowMoo());
        soundBuffers.put("duck", generateDuckQuack());
        soundBuffers.put("frog", generateFrogRibbit());
        soundBuffers.put("sheep", generateSheepBaa());
        soundBuffers.put("elephant", generateElephantTrumpet());
        soundBuffers.put("sparkle", generateSparkleChord());
    }

    private short[] generateChime(double freq, double durationSec) {
        int samples = (int) (SAMPLE_RATE * durationSec);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / SAMPLE_RATE;
            double wave = Math.sin(2 * Math.PI * freq * t)
                        + 0.35 * Math.sin(2 * Math.PI * freq * 2 * t)
                        + 0.15 * Math.sin(2 * Math.PI * freq * 3 * t)
                        + 0.08 * Math.sin(2 * Math.PI * freq * 4 * t);
            double envelope = Math.exp(-t * 5.5);
            double sample = wave * envelope * 0.7;
            sample = Math.max(-1.0, Math.min(1.0, sample));
            buffer[i] = (short) (sample * 32767);
        }
        return buffer;
    }

    private short[] generateBubblePop() {
        double durationSec = 0.06;
        int samples = (int) (SAMPLE_RATE * durationSec);
        short[] buffer = new short[samples];
        double fStart = 850.0;
        double fEnd = 160.0;
        double phase = 0.0;
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = fStart + (fEnd - fStart) * (t * t);
            phase += 2 * Math.PI * f / SAMPLE_RATE;
            double envelope = (1.0 - t) * Math.sin(Math.PI * Math.min(1.0, t * 10));
            double sample = Math.sin(phase) * envelope;
            buffer[i] = (short) (sample * 30000);
        }
        return buffer;
    }

    private short[] generateDogBark() {
        int samples = (int) (SAMPLE_RATE * 0.22);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / SAMPLE_RATE;
            double f = (t < 0.1) ? (320 - t * 1200) : (280 - (t - 0.1) * 1100);
            f = Math.max(120, f);
            double envelope = Math.exp(-t * 12.0) * (0.8 + 0.2 * Math.sin(2 * Math.PI * 40 * t));
            double sample = Math.sin(2 * Math.PI * f * t) * envelope;
            buffer[i] = (short) (sample * 28000);
        }
        return buffer;
    }

    private short[] generateCatMeow() {
        int samples = (int) (SAMPLE_RATE * 0.45);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 450 + 280 * Math.sin(Math.PI * t);
            double envelope = Math.sin(Math.PI * t) * (1.0 - 0.2 * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE))
                        + 0.3 * Math.sin(2 * Math.PI * (f * 2) * ((double) i / SAMPLE_RATE));
            buffer[i] = (short) (wave * envelope * 22000);
        }
        return buffer;
    }

    private short[] generateLionRoar() {
        int samples = (int) (SAMPLE_RATE * 0.4);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 90 + 35 * Math.sin(2 * Math.PI * 18 * t);
            double noise = (Math.random() * 2.0 - 1.0) * 0.4;
            double envelope = Math.sin(Math.PI * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE)) + noise;
            buffer[i] = (short) (wave * envelope * 24000);
        }
        return buffer;
    }

    private short[] generateCowMoo() {
        int samples = (int) (SAMPLE_RATE * 0.55);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 145 + 15 * Math.sin(2 * Math.PI * 4 * t);
            double envelope = Math.sin(Math.PI * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE))
                        + 0.4 * Math.sin(2 * Math.PI * (f * 2) * ((double) i / SAMPLE_RATE));
            buffer[i] = (short) (wave * envelope * 25000);
        }
        return buffer;
    }

    private short[] generateDuckQuack() {
        int samples = (int) (SAMPLE_RATE * 0.28);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 340 + 80 * Math.sin(2 * Math.PI * 25 * t);
            double envelope = Math.sin(Math.PI * t) * (1.0 - t * 0.5);
            double wave = (Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE)) > 0 ? 0.7 : -0.7);
            buffer[i] = (short) (wave * envelope * 22000);
        }
        return buffer;
    }

    private short[] generateFrogRibbit() {
        int samples = (int) (SAMPLE_RATE * 0.25);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 160 + 50 * Math.sin(2 * Math.PI * 35 * t);
            double envelope = Math.sin(Math.PI * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE));
            buffer[i] = (short) (wave * envelope * 26000);
        }
        return buffer;
    }

    private short[] generateSheepBaa() {
        int samples = (int) (SAMPLE_RATE * 0.45);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 260 + 40 * Math.sin(2 * Math.PI * 14 * t);
            double envelope = Math.sin(Math.PI * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE))
                        + 0.25 * Math.sin(2 * Math.PI * f * 2 * ((double) i / SAMPLE_RATE));
            buffer[i] = (short) (wave * envelope * 24000);
        }
        return buffer;
    }

    private short[] generateElephantTrumpet() {
        int samples = (int) (SAMPLE_RATE * 0.4);
        short[] buffer = new short[samples];
        for (int i = 0; i < samples; i++) {
            double t = (double) i / samples;
            double f = 400 + 400 * t;
            double envelope = Math.sin(Math.PI * t);
            double wave = Math.sin(2 * Math.PI * f * ((double) i / SAMPLE_RATE))
                        + 0.5 * Math.sin(2 * Math.PI * f * 1.5 * ((double) i / SAMPLE_RATE));
            buffer[i] = (short) (wave * envelope * 25000);
        }
        return buffer;
    }

    private short[] generateSparkleChord() {
        int samples = (int) (SAMPLE_RATE * 0.6);
        short[] buffer = new short[samples];
        double[] chord = {523.25, 659.25, 783.99, 1046.50};
        for (int i = 0; i < samples; i++) {
            double t = (double) i / SAMPLE_RATE;
            int noteIdx = Math.min(3, (int) (t / 0.12));
            double f = chord[noteIdx];
            double envelope = Math.exp(-(t % 0.12) * 8.0);
            double wave = Math.sin(2 * Math.PI * f * t) + 0.3 * Math.sin(2 * Math.PI * f * 2 * t);
            buffer[i] = (short) (wave * envelope * 24000);
        }
        return buffer;
    }

    public void release() {
        try {
            if (tts != null) {
                tts.stop();
                tts.shutdown();
            }
            audioExecutor.shutdownNow();
        } catch (Exception ignored) {}
    }
}
