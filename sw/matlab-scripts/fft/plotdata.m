function plotdata(infile,outfile,ibin,fbin,add_g,mult_g,N) 
%  plotdata(infile,outfile,ibin,fbin,add_g,mult_g,N) 
%   Reads in from infile (test vectors sent into fft_f         iled_tb  
%   and outfile (output of fft_filed_tb, usually data.out) 
% 
%   ibin is integer b its in the input. 
%   fbin is fractio na l bits in the input. 
%   add_g is the add er growth. 
%    mult_g is the mu ltiplier growth. 
%    N  is the number of points in the FFT. 
% 
%   This prog  ram us es: 
%       str2fr ac.m 
% 
clf 
fout=fopen(outfile); 
ibout=ibin+add_g*log2(  N); 
if mult_g >0 
    ibout=ibout+floor((  log2(N)-1)/2); 
end; 
fbout =fbi n+(floor((log2(N)-1)/2)*(mult_g-1)); 
dp =ibo ut+fbout; 
dp2=2*dp; 
A=(fscanf(fout,'%  s',[dp2,inf]))'; 
[nr ,nc]=size(A); 
hold on; 
offset=N+2  ; 
%getting fi rst outputs 
if (N+offset)<=nr 
    for k=offset+1:offset+N 
        out1r(k-offset)= str2frac  (A(k,1:dp),ibout,fbout); 
        out1i(k-offset)=str2frac(A(k,     dp+1:dp2),ibout,fbout); 
    end 
 out1r=out1r'; 
 out1i=out1i'; 
  %Bit reversing and r        ecombining outputs 
 for k=0:(N-1) 
        bitorder=dec2bin(k,log2(N)); 
        for m=1:(size(bi torder,2)/2) 
             temp=bitorder (m); 


             bitorder(m)=bitorder(size(bitorder,2)+1-m); 
            bitorder(size (bitorder,2)+1-m)=temp; 
        end 
        bitrevpos=bin2dec(bitorder); 
        adata(bitrevpos+1)=out1r(k+1)+i*out1i(k       +1); 
    end 
    subplot(2,2,1),plot(fftshift(abs(adata)),'k'),axis tight, 
    title( 'Magnitude of FFT of Sinc Wave Input'),hold on; 
    subplot (2,2,2),plot(fftshift(angle(adata)),'k'),axis tight, 
    title('Angle of FFT of  Sinc Wave Input'),hold on; 
end 
%getting second outputs 
offset=offset+N; 
if (N +offset)<=nr 
     for k=offset+1:offset+N 
        out1r(k- offset)=str2frac(A(k,1:dp),ibout,fbout); 
         out1i(k-offset)=str2frac(A(k,dp+1:dp2),ibout,fbout); 
    end 
    out1r=out1r'; 
 out1i=out1i'; 
  %Bit reversing and recombining outputs 
 for k=0:(N-1) 
        bitorder=dec2bin(k,log2(N)); 
        for m=1:(size(bitorder,2)/2) 
            temp=bitorder(m); 
            bitorder(m)=bitorder(size(bitorder,2)+1-m); 
            bitorder(size(bitorder,2)+1-m)=temp; 
        end 
          bitrevpos=bin2dec(bitorder); 
        bdata(bitrevpos+1)=out1r(k+1)+i*out1i(k+1); 
 end 
 subplot( 2,2,3),plot(fftshift(real(bdata)),'k'),axis tight, 
    title('Real p art of FFT of Square wave input'),hold on; 
 subplot(2 ,2 ,4),plot(fftshift(imag(bdata)),'k'),axis tight, 
    title('Imaginary part of FF    T of Square wave input'),hold on; 
end 
 
 
%getting input waves from testvec and outputt       ing them on same plots 
fin=fopen(infile); 
dp=ibin+fbin; 
dp2=2*dp+2; 
dp=dp+2; 
A=(fscanf(fin,'%s',[dp2  ,inf]))'; 
[nr,nc]=size (A); 
 
offset=2;  
%getting first inputs 
if (N+offset)<=nr 
    for k=offset+1:offse  t+N 
        outd ata(k-offset )=str2frac(A(k,3:dp),ibin,fbin) + 
i*str2frac(A(k,dp+1:dp 2),ibin,fbin); 
    end 
    afftdata=fft(outdata ); 


    subplot(2,2,1),plot(fftshift(abs(afftdata))); 
    subpl ot(2,2,2),plot(fftshift(angle(afftdata))); 
end 
 
%getting second inputs 
offset=offset+N; 
if (N+offset)<=nr 
    for k=offset+1:offset+ N 
         outdata(k-offset)=str2frac(A(k,3:dp),ibin,fbin) + 
i*str2frac(A(k,dp+1:dp 2),ibin,fbin); 
     end 
    bfftda  ta=fft(outdata); 
    subplo t(2,2,3),plot(fftshift(real(bfftdata))); 
    subplot(2,2,4),plot(fftshift(imag(bfftdata))); 
end 
 
 
fclose('all'); 
