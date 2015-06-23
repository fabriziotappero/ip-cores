% CTG_GEN    Generate Combined Tausworthe number
%
% The calling syntax is:
%     x = ctg_gen(z, n)
%     [x, zf] = ctg_gen(z, n)
%
% Input:
%     z: initial internal state, 3 x 1 vector of unsigned 64-bit integer
%     n: length of pseudorandom numbers
%
% Output:
%     x: pseudorandom values, n x 1 vector of unsigned 64-bit integer
%     zf: final internal state after output n numbers
