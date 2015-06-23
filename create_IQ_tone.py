import matplotlib.pyplot
import numpy
import math
out_file_samp = open("IQ_tone_signal.txt", "w")
out_file_ping = open("IQ_tone_ping.txt", "w")
samp_rate = 50000		# Hz
data_duration = 0.05	# s
tone_freq = 5000		# Hz
ping_duration = 0.002	# s
ping_amplitude = 15
echo_position = 0.025	# s
echo_amplitude = 10

time_acc = 0
time_delta = 1.0 / samp_rate
tone_omega = 2.0 * math.pi * 5000
ping_length = 0
data_length = 0

samps_t = []
samps_I = []
samps_Q = []

pings_t = []
pings_I = []
pings_Q = []

samp_I = 0
samp_Q = 0

while time_acc < data_duration :
	if time_acc < ping_duration :
		samp_I = ping_amplitude * math.cos(tone_omega * time_acc)
		samp_Q = ping_amplitude * math.sin(tone_omega * time_acc)
		pings_t.append(time_acc);
		pings_I.append(samp_I);
		pings_Q.append(samp_Q);
		out_file_ping.write("{0:04x}\r\n{1:04x}\r\n".format(int(samp_I) & 0xFFFF, int(samp_Q) & 0xFFFF))
		ping_length += 1
	else :
		if (time_acc >= echo_position) and (time_acc < echo_position + ping_duration) :
			samp_I = echo_amplitude * math.cos(tone_omega * time_acc)
			samp_Q = echo_amplitude * math.sin(tone_omega * time_acc)
		else :
			samp_I = 0
			samp_Q = 0
	samps_t.append(time_acc);
	samps_I.append(samp_I);
	samps_Q.append(samp_Q);
	out_file_samp.write("{0:04x}\r\n{1:04x}\r\n".format(int(samp_I) & 0xFFFF, int(samp_Q) & 0xFFFF))
	data_length += 1
	time_acc += time_delta
out_file_ping.close()
out_file_samp.close()
print "ping length = ", ping_length
print "data length = ", data_length
matplotlib.pyplot.figure(1)
matplotlib.pyplot.subplot(3,1,1)
matplotlib.pyplot.plot(samps_t, samps_I)
matplotlib.pyplot.plot(samps_t, samps_Q)
#matplotlib.pyplot.figure(2)
matplotlib.pyplot.subplot(3,1,2)
matplotlib.pyplot.plot(pings_t, pings_I)
matplotlib.pyplot.plot(pings_t, pings_Q)
matplotlib.pyplot.show()
