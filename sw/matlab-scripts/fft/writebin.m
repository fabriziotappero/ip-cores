function writebin(fid,a) ; 
%    w ritebin(fid,a) 
%       fid - file id obtained from fopen 
%       a - array to be written to to the file 
%       No return arguements 
for k=(size(a,2)):-1:1 
    fprintf(fid,'%1.1d',a(k)); 
end
