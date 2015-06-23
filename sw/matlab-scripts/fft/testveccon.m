function testveccon(N,bw,vecfile) 
%testveccon(N,bw,vecfile) 
%   This function generates a concaten      ated single line input for the FFT. 
%   It creates a single line input of the following format 
%   resetn  load_enable  xin_r  xin_i 
%   
%   N is the number of points in the fft 
%   bw is the bit width of the input 
%   vecfile is the v ector file name 
% 
%    Vectors will be some initial set up, then a sinc wave input, 
%   followe d by two square wave inputs.  This file does not generate the  
%   MATLAB calc ulated results, only the input waves. 
%   In put waves are 1 bit of integer, bw-1 bits of fraction 
% 
%   This file uses: 
%        frac2bin.m 
%       writebin.m 
%   
 
 dutycycle=0.12 5; 
 d atara=1:N; 
 datarb=1:N; 
datara=sinc((datara-N/2)/2)  ; 
for k=1:N 
    if k>(N*dutycycle)   %squar     e wave input 
         datarb(k)=0; 
    else 
         data rb(k)=1; 
    end 
end; 
 
%dataia=datarb; 
%dataib=datara; 
%  
%datara=(sin(2*pi*dat ara*12/64)+cos(2*pi*datara*2/64))/2; 
dataia=0; 
dataib=0; 
datara=da tara*(2^bw-1) /(2^bw); 
datar b=datarb*(2^bw-1)/(2^bw); 
fi n=fopen(vecfile,'w'); 
writebin(fin,frac2bin(0,1,bw*2+1)); 
fprintf(fin,'\n1'); 
writebin(fin,frac2bin(0,1,bw*2     )); 
for k=1:N 
    fprintf(fin,'\n11');  
    writebin(fin,frac2bin(datara(k),1,bw-1)); 
    writebin(fin,frac2bin (dataia(1),1,bw-1)); 
%    fprintf(fin,'\n'); 
end 

 101 
  

 
for k=1:N 
    fprintf(fin,'\n11'); 
    w datarb(k),1,bw-1));  ritebin(fin,frac2bin(
    writebin(fi n,frac2bin(dataib(1),1,bw-1)); 
%     fprintf(fin,'\n'); 
end 
 
for k=1:N 
    fprintf(fin,'\n11'); 
    writebin(fin,frac2bin(datarb(k),1,bw-1)); 
    writebin(fin,frac2bin(dataib(1),1,bw-1)); 
%   fprintf(fin,'\n'); 
end 
 
fclose('all'); 
