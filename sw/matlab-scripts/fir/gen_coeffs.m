%Header file generation for Wishbone compliant FIR Core test


%Cleans work environment
clc;
clear all;
close all;



%Low-pass filter design
%Cut-off frequencies
fs=8000;
fc1=1500;
fc2=2000;

%Length of impulse response
Nh=50;
order=Nh-1;


%Designs filter          
hn = firpm(order,[0 fc1 fc2 fs/2]/(fs/2),[1 1 0 0]);

%Bits to use for each coefficient
Nbits=16;

%Fractional part
Q=floor(Nbits-1-log2(max(abs(hn))))-1;

%Quantized impulse response
hn_Q=(round(hn*2^Q));

%Header file generation
handle = fopen('../../FIR50/coefs.h', 'wt');
fprintf(handle, '/*Impulse response for FIR filter automatically generated header file*/\n');
fprintf(handle, '/*M.Eng. Alexander López Parrado*/\n\n');
fprintf(handle, '#include <stdint.h>\n');
fprintf(handle, '/*Number of coeffcients*/\n');
fprintf(handle, '#define Nh %d\n\n',Nh);
fprintf(handle, '/*Number of bits in fractional part of coeffcients*/\n');
fprintf(handle, '/*Fixed point format with %d bits ([%d].[%d])*/\n',Nbits,Nbits-Q,Q);
fprintf(handle, '#define Q %d\n\n',Q);

fprintf(handle, '/*Filter Coefficients */');
fprintf(handle, '\nconst int16_t hn[Nh] = {\n');

hn_printf= [hn_Q; hn];

fprintf(handle, '%d, //%f\n',hn_printf);   

fprintf(handle, '};\n');
fclose(handle);





