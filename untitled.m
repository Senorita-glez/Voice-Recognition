[s, fs] = audioread('data/test/Karate_A_T6.wav');
v = mfcc(s, fs);
disp(size(v));
disp(any(isnan(v(:))));
