clc,clear

n=100;
data=randint(n,188,[0 255]);

%reed-solomom encoding
K = 188;
N = 204;
field = gf(data,8);
coded_bytes = rsenc(field,N,K);
code = double(coded_bytes.x);
code_e=code;
%%%%%%%%% put errors %%%%%%%%%%
e_num=randint(1,n,[0 8]);
for k=1:n
   d=randperm(204);
   e_loc=d(1:e_num(k));
   code_e(k,e_loc)=255-code_e(k,e_loc);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data=reshape(data',1,[]);
code_e=reshape(code_e',1,[]);

fdi = fopen('input_RS_blocks','w');
fdo = fopen('output_RS_blocks','w');


for k =1:length(code_e)
    fprintf(fdi,'%s\n',dec2bin(code_e(k),8));
end

for k =1: length(data)
    fprintf(fdo,'%s\n',dec2bin(data(k),8));
end
fclose('all')
save Rs_test_data
