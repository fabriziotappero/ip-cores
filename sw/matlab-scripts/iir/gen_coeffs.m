%Header file generation for Wishbone compliant IIR core test


%Cleans workspace
clc;
clear all;
close all;

%Low-pass filter
%Cut-off frequencies
fs=8000;
fp1=425;
fp2=475;
fs1=410;
fs2=490;

%Ripples
Rp=3;
Rs=20;

%Normalized cut-off frequencies
Omp1=2*fp1/fs;
Omp2=2*fp2/fs;
Oms1=2*fs1/fs;
Oms2=2*fs2/fs;


%Filter order estimation
[N Omc]=buttord([Omp1 Omp2],[Oms1 Oms2],Rp,Rs);

%Filter design
[b_d a_d]=butter(N,Omc);


%Bits to use for each coefficient
Nbits=16;


%SOS structure
[SOS g] = tf2sos(b_d,a_d);


%Number of sections
Nsect=size(SOS,1);

%Gain for each section
gk=g^(1/Nsect);


%Fractional part
Q=floor(Nbits-1-log2(max([gk max(abs(SOS))])));

%Quantized coefficients
SOS_Q=round(SOS*2^Q);

%Quantized gain
gk_Q=round(gk*2^Q);

%Auxiliary variable
SOS_orig=SOS_Q;


%Header file generation
SOS=reshape(fliplr(SOS)',Nsect*3*2,1);
SOS_Q=reshape(fliplr(SOS_Q)',Nsect*3*2,1);
SOS_fprintf=[SOS_Q'; SOS'];
handle = fopen('../../IIR6/coefs_sos.h', 'wt');
fprintf(handle, '/*Second Order Sections (SOS) automatically generated header file*/\n');
fprintf(handle, '/*M.Eng. Alexander López Parrado*/\n\n');
fprintf(handle, '#include <stdint.h>\n');
fprintf(handle, '/*The number of sections*/\n');
fprintf(handle, '#define NSECT %d\n\n',Nsect);
fprintf(handle, '/*Number of bits in fractional part of coeffcients*/\n');
fprintf(handle, '/*Fixed point format with %d bits ([%d].[%d])*/\n',Nbits,Nbits-Q,Q);
fprintf(handle, '#define Q %d\n\n',Q);

fprintf(handle, '/*Gain on each stage*/');
fprintf(handle, '\nconst int16_t gk = %d;\n\n',gk_Q);
fprintf(handle, '/*Filter Coefficients ,b10,b11,b12,a10,a11,a12,b00,b01,b02,a00,a01,a02*/');
fprintf(handle, '\nconst int16_t SOS[NSECT*3*2] = {\n');

fprintf(handle, '%d, //%f\n', SOS_fprintf);   

fprintf(handle, '};\n');
fclose(handle);





