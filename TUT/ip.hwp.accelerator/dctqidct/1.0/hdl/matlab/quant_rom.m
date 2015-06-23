%Quantizer
%Quantizer constants (1/QP, 1/DC_scaler, DC_scaler)
%Timo Alho, timo.a.alho@tut.fi
%10.6.2004

%generates percalculated values for quantizer block
coeffw=16;
mul = 2^coeffw;

fout=fopen('ROM_INV_QP', 'w');
fprintf(fout, 'TYPE Rom32x%i IS ARRAY (0 TO 31) OF unsigned(%i-1 downto 0);\n' , coeffw, coeffw);
fprintf(fout, 'CONSTANT ROM_INV_QP : Rom32x%i := (\n', coeffw);

q=0;
CTAB=[q];
fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);

for i=1:30
    q=round(1/(i)*mul);
    if (q==mul)
        q=mul-1;
    end
    CTAB=[CTAB q];
    fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);
end
q=round(1/(31)*mul);
CTAB=[CTAB q];
fprintf(fout, 'conv_unsigned(%.0f, %i));\n', q, coeffw);
fclose(fout);

type1=[];
type2=[];
%generate dc_scaler values
for i=1:4
    type1=[type1 8];
    type2=[type2 8];
end
for i=5:8
    type1=[type1 2*i];
    type2=[type2 fix((i+13)/2)];
end
for i=9:24
    type1=[type1 i+8];
    type2=[type2 fix((i+13)/2)];
end
for i=25:31
    type1=[type1 2*i-16];
    type2=[type2 i-6];
end

fout=fopen('ROM_INV_DCSCALER', 'w');
fprintf(fout, 'TYPE Rom64x%i IS ARRAY (0 TO 63) OF unsigned(%i-1 downto 0);\n' , coeffw, coeffw);
fprintf(fout, 'CONSTANT ROM_INV_DCSCALER : Rom64x%i := (\n', coeffw);

q=0;
fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);

for i=1:31
    q=2*round(1/type1(i)*mul);
    fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);
end

q=0;
fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);

for i=1:30
    q=2*round(1/type2(i)*mul);
    fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);
end

q=2*round(1/type2(31)*mul);
fprintf(fout, 'conv_unsigned(%.0f, %i));\n', q, coeffw);

fclose(fout);

coeffw=6;

fout=fopen('ROM_DCSCALER', 'w');
fprintf(fout, 'TYPE Rom64x%i IS ARRAY (0 TO 63) OF unsigned(%i-1 downto 0);\n' , coeffw, coeffw);
fprintf(fout, 'CONSTANT ROM_DCSCALER : Rom64x%i := (\n', coeffw);

q=0;
fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);

for i=1:31
    q=round(type1(i));
    fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);
end

q=0;
fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);

for i=1:30
    q=round(type2(i));
    fprintf(fout, 'conv_unsigned(%.0f, %i),\n', q, coeffw);
end

q=round(type2(31));
fprintf(fout, 'conv_unsigned(%.0f, %i));\n', q, coeffw);

fclose(fout);