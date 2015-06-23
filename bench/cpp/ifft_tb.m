% Read the file
fid = fopen('ifft_tb.dbl','r');
raw = fread(fid, [2 inf], 'double');
fclose(fid);

% Convert the raw doubles into complex values
datc = raw(1,:)+j*raw(2,:);
% Reshape the matrix into one line per FFT
% Assume an FFT length of 2048
ftlen = 2048;
ndat = reshape(datc, ftlen, length(datc)/ftlen);

% Create a time axis, for use in plotting if desired
tm = 0:(ftlen-1);

% Now, the data from the test is ready for inspection

