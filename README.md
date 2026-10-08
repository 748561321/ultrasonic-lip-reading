# Ultrasonic Lip-Reading Prototype

An ultrasonic sensing prototype that emits 14-23 kHz linear-frequency-modulated
chirps from an Android device, records lip-reflected echoes and converts the
signals into representations for lip-motion and phoneme recognition.

## Pipeline

1. Generate and play ultrasonic chirps on Android.
2. Record the reflected signal through the device microphone.
3. Apply band-pass filtering, cross-correlation and frame differencing.
4. Generate distance/time-frequency feature maps.
5. Feed the feature maps into a downstream classifier such as ResNet-18.

The associated student innovation project evaluated 48 phoneme classes and
reported 96.36% accuracy. Training data and participant recordings are not
included in this public repository.

## Repository structure

- `android`: Android signal emission and acquisition client
- `signal_processing`: MATLAB/Python signal-processing functions

## Privacy and reproducibility

Raw participant audio, trained weights, local paths, Android build outputs and
generated datasets have been excluded. Reproduction requires a compatible
Android device, a 48 kHz sampling configuration and separately collected data
with appropriate participant consent.

## License

Released for academic and educational reference. No participant data is
licensed or distributed with this repository.
