/*
    Copyright 2011, City University of Hong Kong
    Author is Homer (Dongsheng) Hsing.

    This file is part of Tate Bilinear Pairing Core.

    Tate Bilinear Pairing Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Tate Bilinear Pairing Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Tate Bilinear Pairing Core.  If not, see http://www.gnu.org/licenses/lgpl.txt
*/

// f3_add: C == A+B (mod 3)
module f3_add(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    wire a0, a1, b0, b1, c0, c1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C = {c1, c0};
    assign c0 = ( a0 & ~a1 & ~b0 & ~b1) |
                (~a0 & ~a1 &  b0 & ~b1) |
                (~a0 &  a1 & ~b0 &  b1) ;
    assign c1 = (~a0 &  a1 & ~b0 & ~b1) |
                ( a0 & ~a1 &  b0 & ~b1) |
                (~a0 & ~a1 & ~b0 &  b1) ;
endmodule

// f3_sub: C == A-B (mod 3)
module f3_sub(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    f3_add m1(A, {B[0], B[1]}, C);
endmodule

// f3_mult: C = A*B (mod 3)
module f3_mult(A, B, C); 
    input [1:0] A;
    input [1:0] B; 
    output [1:0] C;
    wire a0, a1, b0, b1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C[0] = (~a1 & a0 & ~b1 & b0) | (a1 & ~a0 & b1 & ~b0);
    assign C[1] = (~a1 & a0 & b1 & ~b0) | (a1 & ~a0 & ~b1 & b0);
endmodule

// c == a+1 (mod 3)
module f3_add1(a, c);
    input [1:0] a;
    output [1:0] c;
    assign c[0] = (~a[0]) & (~a[1]);
    assign c[1] = a[0] & (~a[1]);
endmodule

// c == a-1 (mod 3)
module f3_sub1(a, c);
    input [1:0] a;
    output [1:0] c;
    assign c[0] = (~a[0]) & a[1];
    assign c[1] = (~a[0]) & (~a[1]);
endmodule
