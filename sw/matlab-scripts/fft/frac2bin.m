function [output]=frac2bin(a,ibits,fbits); 
%  [output]=frac2bin(a,ibits, fbits); 
%           a= number to be converted 
%           ibits=integer part bits, must be an integer >0 
%           fbits=number of  fractional bits, must be an integer>=0 
%       This returns an array [output] that is the input number
%       in twos  complement form 
%        [output] is ibits+fbits long 
%    **NOTE**   This is not  idiot proof, and will cause problems if the number is too big  
%               for the nu mber of bits specified-1. 
 
if   (a>=0) 
      bitsign=1; 
    number=a; 
else 
    bitsign=-1; 
    number=(a*-1); 
end 
ipart=number-rem(number,1); 
fpart=rem(number,1); 
unout (ibits+fbits)=0; 
signedzero=1 ; 
 
if ibits~=1 
    for k=(ibits-1):-1:1, 
        if ipart>=2^(k-1) 
            unout(k+fbits)=1; 
            ipart=ipart-2^(k-1); 
            signedzero=0;  
        end 
    end 
end 
 
for k=fbits:-1:1, 
    fpart=fpart*2; 
    if fpart>=1 
         unout(k)=1; 
        fpart=fpart-1; 
        signedzero=0; 
    end 
end 
 
if (bitsign==-1) & (signedzero==0)      
    testbit=1; 
    for k=1:(ibits+fbits-1), 
        if ((testbit==1) & (unout(k)==      1)) 
            testbit=0; 
        elseif ((testbit==0) & (unout(k)==0)) 
            unout(k)=1; 
        elseif ((testbit==0) & (unout(k)==1)) 
            unout(k)=0; 


  

        end 
    end 
    unout(ibits+fbits)=1; 
end 
output=unout; 
