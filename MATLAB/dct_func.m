function output = dct_func(input)

N = 8;

input_s = input./2;

A = round(cos(pi/4)*(2^11))
B = round(cos(pi/8)*(2^11))
C = round(sin(pi/8)*(2^11))
D = round(cos(pi/16)*(2^11))
E = round(cos(3*pi/16)*(2^11))
F = round(sin(3*pi/16)*(2^11))
G = round(sin(pi/16)*(2^11))
Ce = [
   A,  A,  A,  A;
   B,  C, -C, -B;
   A, -A, -A,  A;
   C, -B,  B, -C;
];

Co = [
   D,  E,  F,  G;
   E, -G, -D, -F;
   F, -D,  G,  E;
   G, -F,  E, -D;
];
for i=1:N

   fXe = [
      input_s(i,1);
      input_s(i,2);
      input_s(i,3);
      input_s(i,4);
   ];
   
   fXo = [
      input_s(i,8);
      input_s(i,7);
      input_s(i,6);
      input_s(i,5);
   ];
   fXs = fXe+fXo;
   fXm = fXe-fXo;
   
   fYe = (Ce*fXs);
   fYo = (Co*fXm);  
   % transpose output
   output(1,i) = fYe(1,1)/2^11;
   output(2,i) = fYo(1,1)/2^11;
   output(3,i) = fYe(2,1)/2^11;
   output(4,i) = fYo(2,1)/2^11;
   output(5,i) = fYe(3,1)/2^11;
   output(6,i) = fYo(3,1)/2^11;
   output(7,i) = fYe(4,1)/2^11;
   output(8,i) = fYo(4,1)/2^11;  
end

return


   
   