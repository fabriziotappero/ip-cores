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

`include "inc.v"

// out = (v0 & l0) | (v1 & l1) | (v2 & l2) | ... | (v5 & l5)
module f32m_mux6(v0, v1, v2, v3, v4, v5, l0, l1, l2, l3, l4, l5, out);
    input l0, l1, l2, l3, l4, l5;
    input [`W2:0] v0, v1, v2, v3, v4, v5;
    output [`W2:0] out;
    f3m_mux6
        ins1 (v0[`WIDTH:0], v1[`WIDTH:0], v2[`WIDTH:0], 
              v3[`WIDTH:0], v4[`WIDTH:0], v5[`WIDTH:0], 
              l0, l1, l2, l3, l4, l5,
              out[`WIDTH:0]),
        ins2 (v0[`W2:`WIDTH+1], v1[`W2:`WIDTH+1], v2[`W2:`WIDTH+1], 
              v3[`W2:`WIDTH+1], v4[`W2:`WIDTH+1], v5[`W2:`WIDTH+1], 
              l0, l1, l2, l3, l4, l5,
              out[`W2:`WIDTH+1]);
endmodule

// C == A+B in GF(3^{2M})
module f32m_add(a, b, c);
    input [`W2:0] a, b;
    output [`W2:0] c;
    f3m_add 
        a1 (a[`W2:`WIDTH+1], b[`W2:`WIDTH+1], c[`W2:`WIDTH+1]),
        a2 (a[`WIDTH:0], b[`WIDTH:0], c[`WIDTH:0]);
endmodule

// C = a0 + a1 + a2 in GF(3^{2M})
module f32m_add3(a0, a1, a2, c);
    input [`W2:0] a0, a1, a2;
    output [`W2:0] c;
    wire [`W2:0] t;
    f32m_add
        ins1 (a0, a1, t), // t == a0+a1
        ins2 (t, a2, c);  // c == t+a2 == a0+a1+a2
endmodule

// C = a0 + a1 + a2 + a3 in GF(3^{2M})
module f32m_add4(a0, a1, a2, a3, c);
    input [`W2:0] a0, a1, a2, a3;
    output [`W2:0] c;
    wire [`W2:0] t1, t2;
    f32m_add
        ins1 (a0, a1, t1), // t1 == a0+a1
        ins2 (a2, a3, t2), // t2 == a2+a3
        ins3 (t1, t2, c);  // c == t1+t2 == a0+a1+a2+a3
endmodule

// c == -a in GF(3^{2M})
module f32m_neg(a, c);
    input [`W2:0] a;
    output [`W2:0] c;
    f3m_neg
        n1 (a[`W2:`WIDTH+1], c[`W2:`WIDTH+1]),
        n2 (a[`WIDTH:0], c[`WIDTH:0]);
endmodule

// C == A-B in GF(3^{2M})
module f32m_sub(a, b, c);
    input [`W2:0] a, b;
    output [`W2:0] c;
    f3m_sub 
        s1 (a[`W2:`WIDTH+1], b[`W2:`WIDTH+1], c[`W2:`WIDTH+1]),
        s2 (a[`WIDTH:0], b[`WIDTH:0], c[`WIDTH:0]);
endmodule

// C == A*B in GF(3^{2M})
module f32m_mult(clk, reset, a, b, c, done);
    input reset, clk;
    input [`W2:0] a, b;
    output reg [`W2:0] c;
    output reg done;
    wire [`WIDTH:0] a0,a1,b0,b1,c0,c1,
                    v1,v2,v3,v4,v5,v6;
    reg mult_reset;
    wire mult_done, p;
    
    assign {a1,a0} = a;
    assign {b1,b0} = b;

    f3m_add
        ins1 (a0, a1, v1), // v1 == a0 + a1
        ins2 (b0, b1, v2), // v2 == b0 + b1
        ins3 (v3, v4, v6); // v6 == v3 + v4 = a0*b0 + a1*b1
    f3m_sub
        ins7 (v5, v6, c1), // c1 == v5 - v6 = (a0+a1) * (b0+b1) - (a0*b0 + a1*b1)
        ins8 (v3, v4, c0); // c0 == a0*b0 - a1*b1
    // v3 == a0 * b0
    // v4 == a1 * b1
    // v5 == v1 * v2 = (a0+a1) * (b0+b1)
    f3m_mult3 
        ins9 (clk, mult_reset, a0, b0, v3, a1, b1, v4, v1, v2, v5, mult_done);
    func6
        ins10 (clk, reset, mult_done, p);
    
    always @ (posedge clk)
        mult_reset <= reset;

    always @ (posedge clk)
        if (reset)
            done <= 0;
        else if (p)
          begin
            done <= 1; c <= {c1, c0};
          end
endmodule

// C == A^3 in GF(3^{2m})
module f32m_cubic(clk, a, c);
    input clk;
    input [`W2:0] a;
    output reg [`W2:0] c;
    wire [`WIDTH:0] a0,a1,c0,c1,v;
    assign {a1,a0} = a;
    f3m_cubic
        ins1 (a0, c0), // c0 == a0^3
        ins2 (a1, v);  // v == a1^3
    f3m_neg
        ins3 (v, c1);  // c1 == -v == - a1^3
    always @ (posedge clk)
        c <= {c1,c0};
endmodule
