function [output]=bin2frac(a,ibits,fbits); 
%  [output]=frac2bin(a,ibits, fbits); 
%           a=array to be converted to real numbers 
%           ibits=integer part bits     , must be an integer >0 
%           fbits=number of  fractio nal bits, must be an integer>=0 
%       This returns a real number in [output] 
%    **NOTE**   This is not idiot proof, and will cause problem           s if th  e number is bigger  
%                tha n bits specified.  It also assumes 2's complement form 
 
%code to convert back from signed to sign/magnitude 
unin=a; 
bitsign=1; 
if unin(ibits+fbits)==1 
    bitsign=-1; 
    testbit=1; 
    for k=1:(ibits+fbits), 
        if ((testbit==1) & (unin(k)==1)) 
            testbit=0; 
        elseif ((testbit==0) & (unin(k     )==0)) 
            unin(k)=1; 
        elseif ((testbit==0) & (unin(k)==1)      ) 
            unin(k)=0; 
         end 
     end 
end 
temp=0; 
bitvalue=pow2(ibits-2); 
for k=(ibits+fbits-1):-1:1, 
    temp=temp+unin(k)*bitvalue; 
    bitvalue=bitvalue/2; 
end 
output=temp*bitsign; 
