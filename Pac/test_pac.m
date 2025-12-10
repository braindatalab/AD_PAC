%test

% Parameters
fs = 1000;         % Sampling frequency (Hz)
t = 0:1/fs:10-1/fs; % Time vector (2 seconds duration)
f_low = 10;        % Frequency of low-frequency signal (Hz)
f_high = 60;       % Frequency of high-frequency signal (Hz)

% Low-frequency signal (10 Hz)
low_freq_signal = 3*sin(2*pi*f_low*t);

% Create an amplitude envelope that is phase-coupled with the low-freq signal
amplitude_envelope = 1 + 0.5*sin(2*pi*f_low*t); % Varies with low-freq phase

% High-frequency signal (60 Hz) modulated by the low-frequency envelope
high_freq_signal = amplitude_envelope .* sin(2*pi*f_high*t);

% Add 20% noise to both signals
noise_level_low = 0.06 * max(abs(low_freq_signal)); % 20% of the low-freq signal's amplitude
noise_level_high = 0.19* max(abs(high_freq_signal)); % 20% of the high-freq signal's amplitude

low_freq_signal = low_freq_signal + noise_level_low * randn(size(t));
high_freq_signal = high_freq_signal + noise_level_high * randn(size(t));

% Plot the signals
figure;
subplot(3,1,1);
plot(t, low_freq_signal);
title('Low-Frequency Signal (10 Hz)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, amplitude_envelope);
title('Amplitude Envelope (Phase Coupled to 10 Hz)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, high_freq_signal);
title('High-Frequency Signal (60 Hz, Amplitude Modulated)');
xlabel('Time (s)');
ylabel('Amplitude');

% Combine both signals (optional visualization)
figure;
plot(t, low_freq_signal, 'b', 'LineWidth', 1.2);
hold on;
plot(t, high_freq_signal, 'r', 'LineWidth', 1.2);
legend('Low-Frequency Signal (10 Hz)', 'High-Frequency Signal (60 Hz)');
title('Phase-Amplitude Coupled Signals');
xlabel('Time (s)');
ylabel('Amplitude');

filt.low = f_low;
filt.high = f_high;
data=[ low_freq_signal;high_freq_signal ];

[b_orig, b_anti, b_orig_norm,b_anti_norm] = er_pac(data,fs,2*fs,2*fs,2*fs,filt);