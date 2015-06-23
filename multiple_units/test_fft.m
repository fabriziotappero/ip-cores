% Modify the length of the FFT in the line below
log2fftlen = 4;
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
fprintf(fo,"constant FFT_LEN      : integer := 2 ** LOG2_FFT_LEN;\n");
fprintf(fo,"constant ICPX_WIDTH : integer := %d;\n",icpx_width);
fprintf(fo,"end fft_len;\n");
fclose(fo)
fftlen=2 ** log2fftlen;
%Generate the data. Now it is only a noise, but you
%can generate something with periodic components
%It is important, that values fit in range of representation
%(-2,2) for standard implementation.
%May be changed if you redefine our icpx_number format
%To check that calculation of spectrum for overlapping windows 
%works correctly, we generate a longer data stream...
len_of_data=fftlen*5
re=3*rand(1,len_of_data)-1.5;
im=3*rand(1,len_of_data)-1.5;
fo=fopen("data_in.txt","w");
for i=1:len_of_data
   fprintf(fo,"%g %g\n",re(i),im(i));
end
fclose(fo)
%Create the Hann window.
%Remember, that you must use the same window function
%in your VHDL code!
x=0:(fftlen-1);
hann=0.5*(1-cos(2*pi*x/(fftlen-1)));
%Now we calculate the FFT in octave
scale = 2 ** (icpx_width-2);
fo=fopen("data_oct.txt","w");
for i=1:(fftlen/2):(len_of_data-fftlen)
   x=i:(i+fftlen-1);
   di = (re(x)+j*im(x))*scale/fftlen;
   fr = fft(di.*hann);
%   fr = fft(di);
   fprintf(fo,"FFT RESULT BEGIN\n")
   for k=1:fftlen
     fprintf(fo,"%d %d\n",floor(real(fr(k))),floor(imag(fr(k))));
   end
   fprintf(fo,"FFT RESULT END\n")
end
fclose(fo)
%Run the simulation
system("make clean; make")
%Compare results calculated in octave and in our IP core
system("vim -d data_oct.txt data_out.txt")
 
