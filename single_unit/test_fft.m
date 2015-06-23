% Modify the length of the FFT in the line below
log2fftlen = 10;
% If you modify the number of bits used to represent
% real and imaginary part of the complex number,
% you should also modify the ICPX_WIDTH constant
% in the icpx_pkg.vhd file
icpx_width = 16;
% Do not modify below
% Write the package defining length of the FFT
fo=fopen("src/fft_len.vhd","w");
fprintf(fo,"package fft_len is\n");
fprintf(fo,"constant LOG2_FFT_LEN : integer := %d;\n",log2fftlen);
fprintf(fo,"end fft_len;\n");
fclose(fo)
fftlen=2 ** log2fftlen;
%Generate the data. Now it is only a noise, but you
%can generate something with periodic components
%It is important, that values fit in range of representation
%(-2,2) for standard implementation.
%May be changed if you redefine our icpx_number format
re=3*rand(1,fftlen)-1.5;
im=3*rand(1,fftlen)-1.5;
fo=fopen("data_in.txt","w");
for i=1:fftlen
   fprintf(fo,"%g %g\n",re(i),im(i));
end
fclose(fo)
scale = 2 ** (icpx_width-2);
di = (re+j*im)*scale/fftlen;
fr = fft(di);
fo=fopen("data_oct.txt","w");
for i=1:fftlen
   fprintf(fo,"%d %d\n",floor(real(fr(i))),floor(imag(fr(i))));
end
fclose(fo)
%Run the simulation
system("make clean; make")
%Compare results calculated in octave and in our IP core
system("vim -d data_oct.txt data_out.txt")
