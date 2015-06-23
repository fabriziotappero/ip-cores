#	Lowpass FIR filter design.
#
# Authors:
#    Daniel C.K. Kho <daniel.kho@gmail.com>
#    Tan Hooi Jing <hooijingtan@gmail.com>
#
# Copyright(c) 2012 Daniel C.K. Kho and Tan Hooi Jing. All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.
#
#	@dependencies:
#	@revision history: See Mercurial log.
#	@info:
#
# This notice and disclaimer must be retained as part of this text at all times.
#
# Note:
#    For an equivalent Matlab model, contact Tan Hooi Jing (hooijingtan@gmail.com).

#reset();
from scipy import *;
from scipy.signal import freqz;
from scipy.fftpack import fftshift, fftfreq;
from scipy import signal;


# Filter specifications
# Here, we specify the ideal filter response
# Window method: Hamming
# N = filter order = number of unit delays
# M = filter length = number of taps = number of coefficients
# wp = passband frequency
# ws = sampling frequency
# wm = mainlobe width, transition edge
# wc = cutoff frequency
N=30; M=N+1;
ws=10;
wm=3.3/N;    #ws-wp;
wp=0.5;    #in kHz
wc=2*pi*(wp+wm/2)/ws;    #    (wp+ws)/2;


# Specify the ideal impulse response (filter coefficients) for cutoff frequency at w_c = 20kHz:
j=complex(0,1);
n01=r_[0:M-1:j*M];

print(n01);

# Infinite-duration impulse response. This impulse response will later be truncated using
# a discrete-time window function (here we use the Hamming window).
h_n=sin(n01*wc)/(n01*pi);

print(h_n);

# Hamming window
w_n=0.54-0.46*cos(2*pi*n01/N);
# Hann window
#w_n=0.5*(1+cos(2*pi*n/(M)));

print(w_n);

# Impulse response of ideal filter in time domain:
## FIR filter design using the window method.
#    Usage:
#    scipy.signal.firwin(numtaps,cutoff,width=None,window='hamming',pass_zero=True,scale=True,nyq=1.0)
b_n01=signal.firwin(M,wc,width=None,window='hamming',pass_zero=True,scale=True,nyq=10*wc);

# Impulse response data in time domain.
#
# Time-domain impulse response data, simulated with ModelSim and measured with Altera's on-chip
# SignalTap II embedded logic analyser.
# The DSP computations operate on up-scaled values, which is then down-scaled with the same scaling factor
# to produce the results below. This is for fixed-point conversion.
#
# Digital simulation and hardware measurements yield exactly the same results (in Volts):
b_n02=[-0.0017,
    -0.0019,
    -0.0024,
    -0.0026,
    -0.0021,
    0,
    0.0044,
    0.0117,
    0.022,
    0.0351,
    0.05,
    0.0654,
    0.0799,
    0.0916,
    0.0993,
    0.102,
    0.0993,
    0.0916,
    0.0799,
    0.0654,
    0.05,
    0.0351,
    0.022,
    0.0117,
    0.0044,
    0,
    -0.0021,
    -0.0026,
    -0.0024,
    -0.0019,
    -0.0017];

n=r_[0:len(b_n02)-1:j*len(b_n02)];



# Calculate the z-domain frequency responses:
w_n01,h_n01 = signal.freqz(b_n01,1);
w_n02,h_n02 = signal.freqz(b_n02,1);



print("Theoretical computation of the time-domain impulse response,\nb_n01: "); print(b_n01);
print("Digital simulation and hardware measurements of the time-domain impulse response,\nb_n02: "); print(b_n02);


## Graphing methods. ##

import pylab as plt0;
graph0=plt0.figure();

#html("Theoretical response curves to a unit impulse excitation:");
plt0.title("Theoretical response curves to a unit impulse excitation:");
#
# Filter response curves simulated from impulse response equation (Sage's firwin() method).
# The time-domain impulse response is used to specify the FIR filter coefficients.
#
graph0.add_subplot(2,1,1);    # #rows, #columns, plot#
plt0.plot(n01,b_n01);

#
# Frequency response of the impulse excitation, or I'd just say,
# frequency-domain (z-domain) impulse response.
#
graph0.add_subplot(2,1,2);
plt0.plot(w_n01,20*log10(abs(h_n01)));

# TODO: Frequency response plot based on wc calculation:

plt0.show();


import pylab as plt1;
graph1=plt1.figure();

plt1.title("Measured vs. theoretical response curves");
#
# Filter response curves digitally simulated using ModelSim, and measured using Altera's
# SignalTap II embedded logic analyser. Digital simulation and hardware measurements yield
# exactly the same data, i.e. they have exactly the same curves, hence we only plot them once.
#
# Impulse response in time domain.
graph1.add_subplot(2,1,1);
simulated_t=plt1.plot(n01,b_n01,'r');
measured_t=plt1.plot(n,b_n02,'b');

# Impulse response in frequency domain (z domain).
graph1.add_subplot(2,1,2);

simulated_w=plt1.plot(w_n01,20*log10(abs(h_n01)),'r');
measured_w=plt1.plot(w_n02,20*log10(abs(h_n02)),'b');

plt1.savefig('plt1.png');
plt1.show();
