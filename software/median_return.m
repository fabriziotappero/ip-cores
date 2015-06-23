clc
clear

id = fopen('image.hex', 'r');
image_c = fscanf(id, '%d');

%image = vec2mat(image_c, 866);
%image = reshape(image_c,598,866);
% image = reshape(image_c.',598,[]);

image = zeros(227,227);
k = 1;
for i = 1 : 227
    z = 0;
    for j = 1 : 227
        image(i,j) = hex2dec(image_c(k));        
        k = k + 1;
    end
end

% for i = 1 : 510
%     for j = 1 : 510
%         if(image(i,j) == 255)
%             image(i,j) = 0;
%         else
%             image(i,j) = 1;
%         end
%     end
% end

imshow(image);
% imwrite(image, 'return.jpg', 'jpg');