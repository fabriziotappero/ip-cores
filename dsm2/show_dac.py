import pylab
#w=load("dac_tb.dat")
import numpy
w=numpy.loadtxt("dac_tb.dat")
t1=[i[1] for i in w]; t1=t1-pylab.mean(t1)
f1=20.0*pylab.log(0.0001+abs(pylab.fft(t1)))
pylab.plot(f1)
pylab.title("Whole spectra of output signal")
pylab.grid()
pylab.show()
pylab.plot(f1[0:1000])
pylab.title("First 1000 samples of spectra")
pylab.grid()
pylab.show()
