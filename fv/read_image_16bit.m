X = imread('onion_16bit.tif');
R = X(:,:,1);
G = X(:,:,2);
B = X(:,:,3);
Y = zeros(size(X,1), 3, size(X,2), 'uint16');
Y(:,1,:) = R;
Y(:,2,:) = G;
Y(:,3,:) = B;
dlmwrite('x.txt', Y, 'delimiter', ' ' , 'newline', 'pc', 'precision', '%3.4X');

