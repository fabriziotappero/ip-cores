%DCT
%DCT constant coefficient generator for sum and subtraction terms.
%Timo Alho, timo.a.alho@tut.fi
%10.6.2004


coeff_width=15; %coefficient datawidth

%all coefficients are scaled by 1/sqrt(2)
mult=2^(coeff_width-1) /sqrt(2);


%generate original coefficient matrix
N=8;
A=zeros(N, N);
j=[0:1:N-1];
A(1, :) = sqrt(1/N) * cos(0);
for i = 1:N-1
    A(i+1, :) = sqrt(2/N) * cos((2.*j+1)*i*pi/(2*N));
end

%sumterms
Asum=A(1:2:8, :);
Asum=Asum(:, 1:4);

%subterms
Asub=A(2:2:8, :);
Asub=Asub(:, 1:4);




fout=fopen('ROM_SUM', 'w');
fprintf(fout, 'TYPE Rom16x4x%i IS ARRAY (0 TO 15) OF signed(%i*4-1 downto 0);\n' , coeff_width, (coeff_width));
fprintf(fout, 'CONSTANT ROM_SUM : Rom16x4x%i := (\n', coeff_width);
for a3=0:1
    for a2=0:1
        for a1=0:1
            for a0=0:1
                Y0 = Asum(1,1)*a0 + Asum(1,2)*a1 + Asum(1,3)*a2 + Asum(1,4)*a3;
                Y1 = Asum(2,1)*a0 + Asum(2,2)*a1 + Asum(2,3)*a2 + Asum(2,4)*a3;
                Y2 = Asum(3,1)*a0 + Asum(3,2)*a1 + Asum(3,3)*a2 + Asum(3,4)*a3;
                Y3 = Asum(4,1)*a0 + Asum(4,2)*a1 + Asum(4,3)*a2 + Asum(4,4)*a3;
                Y0=round(mult*Y0);
                Y1=round(mult*Y1);
                Y2=round(mult*Y2);
                Y3=round(mult*Y3);
                if (Y0 == 2^(coeff_width-1))
                    Y0 = Y0 - 1;
                end
                if (Y1 == 2^(coeff_width-1))
                    Y1 = Y1 - 1;
                end
                if (Y2 == 2^(coeff_width-1))
                    Y2 = Y2 - 1;
                end
                
                if (Y3 == 2^(coeff_width-1))
                    Y3 = Y3 - 1;
                end

                fprintf(fout, 'conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i),\n', Y0, coeff_width, Y1, coeff_width, Y2, coeff_width, Y3, coeff_width);
            end
        end
    end
end
fprintf(fout, 'REMOVE THIS, AND LAST dot\n);\n');
fclose(fout);

fout=fopen('ROM_SUB', 'w');
fprintf(fout, 'TYPE Rom16x4x%i IS ARRAY (0 TO 15) OF signed(%i*4-1 downto 0);\n' , coeff_width, (coeff_width));
fprintf(fout, 'CONSTANT ROM_SUB : Rom16x4x%i := (\n', coeff_width);
for a3=0:1
    for a2=0:1
        for a1=0:1
            for a0=0:1
                Y0 = Asub(1,1)*a0 + Asub(1,2)*a1 + Asub(1,3)*a2 + Asub(1,4)*a3;
                Y1 = Asub(2,1)*a0 + Asub(2,2)*a1 + Asub(2,3)*a2 + Asub(2,4)*a3;
                Y2 = Asub(3,1)*a0 + Asub(3,2)*a1 + Asub(3,3)*a2 + Asub(3,4)*a3;
                Y3 = Asub(4,1)*a0 + Asub(4,2)*a1 + Asub(4,3)*a2 + Asub(4,4)*a3;
                Y0=round(mult*Y0);
                Y1=round(mult*Y1);
                Y2=round(mult*Y2);
                Y3=round(mult*Y3);
                if (Y0 == 2^(coeff_width-1))
                    Y0 = Y0 - 1;
                end
                if (Y1 == 2^(coeff_width-1))
                    Y1 = Y1 - 1;
                end
                if (Y2 == 2^(coeff_width-1))
                    Y2 = Y2 - 1;
                end
                
                if (Y3 == 2^(coeff_width-1))
                    Y3 = Y3 - 1;
                end

                fprintf(fout, 'conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i) & conv_signed(%i, %i),\n', Y0, coeff_width, Y1, coeff_width, Y2, coeff_width, Y3, coeff_width);
            end
        end
    end
end
fprintf(fout, 'REMOVE THIS, AND LAST dot\n);\n');
fclose(fout);