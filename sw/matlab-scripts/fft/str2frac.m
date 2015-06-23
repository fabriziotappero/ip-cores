function [output]=str2frac(a,ibits,fbits); 
%  [outp ut]=str2frac(a,ibits, fbits); 
%            a= string of 1's and 0's to be converted to real numbers 
%           ibits=integer  part bits, must be an integer >0 
%           fbit s=number  of fractional bits, must be an integer>=0 
%       This re tu rns a real number in [output] 
%    **NOTE**   This is not  idiot proof, and will cause problems if the number is bigger  
%               than bi  ts specified.  It a lso assumes 2's complement form 
 
%code to convert back from signed to sign/magn       itude 
bitsign=1; 
if a(1)=='1'   
    bits ign=- 1; 
     testb it=1; 
    for k =(ibits+fbits):-1:1, 
        if ((testbit==1)  & (a(k)=='1')) 
            testbit=0; 
            unin(k)=1; 
        elseif ((testbit==1) & (a (k)=='0')) 
             unin(k)=0; 
        elseif ((testbit==0) & (a(k)=='0')) 
             unin(k)=1;  
         elseif ((testbit==0) & (a(k)=='1')) 
             unin(k)=0; 
        end 
    end 
else 
    for k=1:(ibits+fbits), 
        if a(k)=='1' 
            unin(k)=1; 
        end 
        if a(k)=='0' 
             unin(k)=0; 

  

        end 
    end 
end 
temp=0; 
bitvalue=pow2(0-fbits); 
for k=(ibits+fbits):-1:1, 
    temp=temp+unin(k)*bitvalue; 
     bitvalue=bitvalue*2; 
end 
output=temp*bitsign; 
