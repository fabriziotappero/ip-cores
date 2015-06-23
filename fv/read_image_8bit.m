
X = imread('onion_8bit.png');
R = X(:,:,1);
G = X(:,:,2);
B = X(:,:,3);
Y = zeros(135, 3, 198, 'uint8');
Y(:,1,:) = R;
Y(:,2,:) = G;
Y(:,3,:) = B;
dlmwrite('X.txt', Y, 'delimiter', ' ' , 'newline', 'pc', 'precision', '%2.3X');

