import matplotlib.pyplot
import numpy
import math
out_file_samp = open("IQ_chirp_signal.txt", "w")
out_file_ping = open("IQ_chirp_ping.txt", "w")
#mod_list = array('b', [1, 1, -1, 1, -1, 1, -1])
#mod_length = 100
samp_rate = 50000
data_leng = 0.080
pulse_freq_carry = 250000
pulse_freq_sweep =   5000
pulse_leng = 0.001
pulse_amp = 32.0
noise_amp = 4.0
sig_offs = 0.003
sig_amp = 16.0
leak_amp = 4.0
samp_per = 1.0 / samp_rate
print "samp_per: ", samp_per
adc_rate = pulse_freq_carry * 4.0
adc_per = 1.0 / adc_rate
print "adc_per: ", adc_per
samp_div = round(1.0 / (samp_rate * adc_per))
print "samp_div: ", samp_div
samp_per = adc_per * samp_div
time_var = 0
carr_phase_delta      = 2.0 * math.pi * (pulse_freq_carry) * adc_per
carr_phase_curr       = 0
pulse_phase_mod_start = 2.0 * math.pi * pulse_freq_sweep * ( - pulse_leng)
pulse_phase_mod_step_const  = 2.0 * math.pi * pulse_freq_sweep / pulse_leng * adc_per**2
pulse_phase_mod_step_var_c  = 4.0 * math.pi * pulse_freq_sweep / pulse_leng * adc_per

#print "pulse_phase_delta: ", pulse_phase_delta
pulse_delta_freq = pulse_freq_sweep / pulse_leng / samp_rate
pulse_freq_carry_curr = pulse_freq_carry - pulse_freq_sweep / 2
print "samp_per: ", samp_per
samps_t = []
samps_phi = []
samps_I = []
samps_Q = []
samps_freq = []
adc_I = []
adc_Q = []
adc_t = []
iteration = 0
samp_counter = 0
time_start_mod = 0
while time_var < data_leng and iteration < 100000 or samp_counter % 2 == 1:
	iteration += 1
	samp_I = 0
	samp_Q = 0
	if samp_counter == samp_div :
		samp_counter = 0
	if time_var < pulse_leng :
		if time_var == 0 :
			time_start_mod = time_var
		if samp_counter == 0 :
			samp_I = pulse_amp * math.sin(carr_phase_curr)
		if samp_counter == 1 :
			samp_Q = pulse_amp * math.sin(carr_phase_curr)
		carr_phase_curr += pulse_phase_mod_step_const + pulse_phase_mod_step_var_c * (time_var - time_start_mod)
	elif time_var >= sig_offs and time_var < sig_offs + pulse_leng :
		if samp_counter == 0 :
			samp_I = sig_amp * math.sin(carr_phase_curr)
		if samp_counter == 1 :
			samp_Q = sig_amp * math.sin(carr_phase_curr)
		carr_phase_curr += pulse_phase_mod_step_const + pulse_phase_mod_step_var_c * (time_var - time_start_mod)
	else :
		#pulse_freq_carry_curr = pulse_freq_carry - pulse_freq_sweep / 2
		time_start_mod = time_var
		if samp_counter == 0 :
			samp_I = leak_amp * math.sin(carr_phase_curr)
		if samp_counter == 1 :
			samp_Q = leak_amp * math.sin(carr_phase_curr)
	#carr_phase_curr += carr_phase_delta
	adc_I.append(pulse_amp * math.sin(carr_phase_curr))
	adc_t.append(time_var);
	if samp_counter == 0 :
		samps_I.append(samp_I);
	if samp_counter == 1 :
		samps_Q.append(samp_Q);
		samps_t.append(time_var);
		samps_phi.append(carr_phase_curr);
	carr_phase_curr += carr_phase_delta
	time_var += adc_per
	samp_counter += 1
samps_I
samps_Q
samps_t
print "len(samps_I) ", len(samps_I)
for i1 in range(len(samps_I)) :
	#out_file_samp.write("{0:04x}_{1:04x} {2} {3}\r\n".format(int(samps_I[i]) & 0xFFFF, int(samps_Q[i]) & 0xFFFF, int(samps_I[i]), int(samps_Q[i])))
	#print "i1: ", i1, " ", samps_I[i1], " ", samps_Q[i1]
	out_file_samp.write("{0:04x}\r\n{1:04x}\r\n".format(int(samps_I[i1]) & 0xFFFF, int(samps_Q[i1]) & 0xFFFF))
for i1 in range(int(pulse_leng/samp_per)) :
	#out_file_samp.write("{0:04x}_{1:04x} {2} {3}\r\n".format(int(samps_I[i]) & 0xFFFF, int(samps_Q[i]) & 0xFFFF, int(samps_I[i]), int(samps_Q[i])))
	#print "i1: ", i1, " ", samps_I[i1], " ", samps_Q[i1]
	out_file_ping.write("{0:04x}\r\n{1:04x}\r\n".format(int(samps_I[i1]) & 0xFFFF, int(samps_Q[i1]) & 0xFFFF))
out_file_samp.close()
matplotlib.pyplot.figure(1)
matplotlib.pyplot.subplot(3,1,1)
matplotlib.pyplot.plot(samps_t, samps_I)
matplotlib.pyplot.plot(samps_t, samps_Q)
#matplotlib.pyplot.figure(2)
matplotlib.pyplot.subplot(3,1,2)
#matplotlib.pyplot.plot(samps_t, samps_freq)
matplotlib.pyplot.plot(samps_t, samps_phi)
matplotlib.pyplot.subplot(3,1,3)
matplotlib.pyplot.plot(adc_t, adc_I)
matplotlib.pyplot.show()
