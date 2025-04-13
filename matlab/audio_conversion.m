% Convert audio to binary so it can be used for pulse modulation on signal
% generator and received by SDR %
[y,Fs] = audioread('audio_recording.wav');
audio_normalized = int16(y * 32767);
audio_binary = dec2bin(typecast(audio_normalized(:),'uint16'),16);
writematrix(audio_binary)