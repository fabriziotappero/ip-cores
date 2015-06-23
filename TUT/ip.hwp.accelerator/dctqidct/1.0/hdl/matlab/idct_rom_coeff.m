%IDCT
%IDCT constant coefficient generator for odd and even terms.
%Timo Alho, timo.a.alho@tut.fi
%10.6.2004

coeff_width=15;

%all coefficients are scaled by 1/sqrt(2)
mult=2^(coeff_width-1) /sqrt(2);


N=8;
A=zeros(N, N);
j=[0:1:N-1];
A(1, :) = sqrt(1/N) * cos(0);
for i = 1:N-1
    A(i+1, :) = sqrt(2/N) * cos((2.*j+1)*i*pi/(2*N));
end
A=A'; %transpose DCT -> IDCT

Aodd=A(1:4, 1:2:8);
Aeven=A(1:4, 2:2:8);

fout=fopen('ROM_IDCT_ODD', 'w');
fprintf(fout, 'TYPE Rom16x4x%i IS ARRAY (0 TO 15) OF signed(%i*4-1 downto 0);\n' , coeff_width, (coeff_width));
fprintf(fout, 'CONSTANT ROM_IDCT_ODD : Rom16x4x%i := (\n', coeff_width);
for a3=0:1
    for a2=0:1
        for a1=0:1
            for a0=0:1
                Y0 = Aodd(1,1)*a0 + Aodd(1,2)*a1 + Aodd(1,3)*a2 + Aodd(1,4)*a3;
                Y1 = Aodd(2,1)*a0 + Aodd(2,2)*a1 + Aodd(2,3)*a2 + Aodd(2,4)*a3;
                Y2 = Aodd(3,1)*a0 + Aodd(3,2)*a1 + Aodd(3,3)*a2 + Aodd(3,4)*a3;
                Y3 = Aodd(4,1)*a0 + Aodd(4,2)*a1 + Aodd(4,3)*a2 + Aodd(4,4)*a3;
                Y0=round(mult*Y0);
                Y1=round(mult*Y1);
                Y2=round(mult*Y2);
                Y3=round(mult*Y3);
                fprintf(fout, 'conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i),\n', Y0, coeff_width, Y1, coeff_width, Y2, coeff_width, Y3, coeff_width);
            end
        end
    end
end
fprintf(fout, 'REMOVE THIS, AND LAST dot\n);\n');
fclose(fout);

fout=fopen('ROM_IDCT_EVEN', 'w');
fprintf(fout, 'TYPE Rom16x4x%i IS ARRAY (0 TO 15) OF signed(%i*4-1 downto 0);\n' , coeff_width, (coeff_width));
fprintf(fout, 'CONSTANT ROM_IDCT_EVEN : Rom16x4x%i := (\n', coeff_width);
for a3=0:1
    for a2=0:1
        for a1=0:1
            for a0=0:1
                Y0 = Aeven(1,1)*a0 + Aeven(1,2)*a1 + Aeven(1,3)*a2 + Aeven(1,4)*a3;
                Y1 = Aeven(2,1)*a0 + Aeven(2,2)*a1 + Aeven(2,3)*a2 + Aeven(2,4)*a3;
                Y2 = Aeven(3,1)*a0 + Aeven(3,2)*a1 + Aeven(3,3)*a2 + Aeven(3,4)*a3;
                Y3 = Aeven(4,1)*a0 + Aeven(4,2)*a1 + Aeven(4,3)*a2 + Aeven(4,4)*a3;
                Y0=round(mult*Y0);
                Y1=round(mult*Y1);
                Y2=round(mult*Y2);
                Y3=round(mult*Y3);
                fprintf(fout, 'conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i),\n', Y0, coeff_width, Y1, coeff_width, Y2, coeff_width, Y3, coeff_width);
            end
        end
    end
end
fprintf(fout, 'REMOVE THIS, AND LAST dot\n);\n');
fclose(fout);