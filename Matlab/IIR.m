close all
clear
clc

f = [0 0.25 0.35 1.0];      % Corner frequencies
m = [1 1 0 0];              % Filter magnitudes        
n = 3;                      % Filter order

[b,a] = yulewalk(n, f, m);  % Design IIR Filter

[h,w] = freqz(b,a,128);     % FFT

figure
plot(f,m,w/pi,abs(h))       % Plot frequency response

figure
step(filt(b,a))             % Plot step response

figure
impulse(filt(b,a))          % Plot impuse response

figure
zplane(b,a)                 % Plot poles/zeros

[sos, g] = tf2sos(b, a);    % Second Order Sections

afx = num2fixpt(a, sfix(8), 2^-6);
bfx = num2fixpt(b, sfix(8), 2^-6);
fvtool(bfx, afx)
fvtool(b, a)