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

// c == a*b in GF(3^{6M})
module f36m_mult(clk, reset, a, b, c, done);
    input clk, reset;
    input [`W6:0] a, b;
    output reg [`W6:0] c;
    output reg done;

    reg [`W2:0] x0, x1, x2, x3, x4, x5;
    wire [`W2:0] a0, a1, a2,
                 b0, b1, b2,
                 c0, c1, c2,
                 v1, v2, v3, v4, v5, v6,
                 nx0, nx2, nx5,
                 d0, d1, d2, d3, d4;
    reg [6:0] K;
    wire e0, e1, e2, 
         e3, e4, e5,
         mult_done, p, rst;
    wire [`W2:0] in0, in1;
    wire [`W2:0] o;
    reg mult_reset, delay1, delay2;
    reg [`W2:0] in0d,in1d;

    assign {e0,e1,e2,e3,e4,e5} = K[6:1];
    assign {a2,a1,a0} = a;
    assign {b2,b1,b0} = b;
    assign d4 = x0;
    assign d0 = x5;
    assign rst = delay2;

    f32m_mux6
        ins1 (a2,v1,a1,v3,v5,a0,e0,e1,e2,e3,e4,e5,in0), // $in0$ is the first input
        ins2 (b2,v2,b1,v4,v6,b0,e0,e1,e2,e3,e4,e5,in1); // $in1$ is the second input
    f32m_mult
        ins3 (clk, mult_reset, in0d, in1d, o, mult_done); // o == in0 * in1
    func6
        ins4 (clk, reset, mult_done, p);
    f32m_add
        ins5 (a1, a2, v1), // v1 == a1+a2
        ins6 (b1, b2, v2), // v2 == b1+b2
        ins7 (a0, a2, v3), // v3 == a0+a2
        ins8 (b0, b2, v4), // v4 == b0+b2
        ins9 (a0, a1, v5), // v5 == a0+a1
        ins10 (b0, b1, v6), // v6 == b0+b1
        ins11 (d0, d3, c0), // c0 == d0+d3
        ins12 (d2, d4, c2); // c2 == d2+d4
    f32m_neg
        ins13 (x0, nx0), // nx0 == -x0
        ins14 (x2, nx2), // nx2 == -x2
        ins15 (x5, nx5); // nx5 == -x5
    f32m_add3
        ins16 (x1, nx0, nx2, d3), // d3 == x1-x0-x2
        ins17 (x4, nx2, nx5, d1), // d1 == x4-x2-x5
        ins18 (d1, d3, d4, c1); // c1 == d1+d3+d4
    f32m_add4
        ins19 (x3, x2, nx0, nx5, d2); // d2 == x3+x2-x0-x5

    always @ (posedge clk)
      begin
        in0d <= in0; in1d <= in1;
      end

    always @ (posedge clk)
      begin
        if (reset) K <= 7'b1000000;
        else if (p | K[0]) K <= {1'b0,K[6:1]};
      end
    
    always @ (posedge clk)
      begin
        if (e0) x0 <= o; // x0 == a2*b2
        if (e1) x1 <= o; // x1 == (a2+a1)*(b2+b1)
        if (e2) x2 <= o; // x2 == a1*b1
        if (e3) x3 <= o; // x3 == (a2+a0)*(b2+b0)
        if (e4) x4 <= o; // x4 == (a1+a0)*(b1+b0)
        if (e5) x5 <= o; // x5 == a0*b0
      end
    
    always @ (posedge clk)
      begin
        if (reset) done <= 0;
        else if (K[0]) 
          begin
            done <= 1; c <= {c2,c1,c0};
          end
      end
    
    always @ (posedge clk)
      begin
        if (rst) mult_reset <= 1;
        else if (mult_done) mult_reset <= 1;
        else mult_reset <= 0;
      end
    
    always @ (posedge clk)
      begin
        delay2 <= delay1; delay1 <= reset;
      end
endmodule

// c == a^3 in GF(3^{6M})
module f36m_cubic(clk, a, c);
    input clk;
    input [`W6:0] a;
    output reg [`W6:0] c;
    wire [`W2:0] a0,a1,a2,v0,v1,v2,v3,c0,c1,c2;
    
    assign {a2,a1,a0} = a;
    assign c2 = v2; // c2 == a2^3
    
    f32m_cubic
        ins1 (clk, a0, v0), // v0 == a0^3
        ins2 (clk, a1, v1), // v0 == a1^3
        ins3 (clk, a2, v2); // v0 == a2^3
    f32m_add
        ins4 (v0, v1, v3), // v3 == v0+v1 = a0^3 + a1^3
        ins5 (v2, v3, c0); // c0 == a0^3 + a1^3 + a2^3
    f32m_sub
        ins6 (v1, v2, c1); // c1 == a1^3 - a2^3
    
    always @ (posedge clk)
        c <= {c2,c1,c0};
endmodule

// c == a ^ { 3^{3*M} - 1 } in GF(3^{6M})
module second_part(clk, reset, a, c, done);
    input clk, reset;
    input [`W6:0] a;
    output reg [`W6:0] c;
    output reg done;
    
    reg [3:0] K;
    wire [`WIDTH:0] d0,d1,d2,d3,d4,d5,
                    c0,c1,c2,c3,c4,c5;
    wire [`W3:0] a0,a1,b0,b1,
                 v1,v2,v3,v4,v5,v6,v7,v8,nv6;
    wire [1:0] v9,v10;
    wire rst1, rst2, rst3, done1, done2, done3;
    
    assign {d5,d4,d3,d2,d1,d0} = a;
    assign {a1,a0} = {d5,d3,d1,d4,d2,d0}; // change basis
    assign {b1,b0} = {{v8[`W3:2],v10}, {v7[`W3:2],v9}};
    assign {c5,c3,c1,c4,c2,c0} = {b1,b0}; // change basis back
    assign rst1 = reset;

    f33m_mult2
        ins1 (clk, rst1, 
              a0, a0, v1, // v1 == a0^2
              a1, a1, v2, // v2 == a1^2
              done1);
    f33m_add
        ins2 (v1, v2, v3), // v3 == v1+v2 == a0^2+a1^2
        ins3 (a0, a1, v5); // v5 == a0+a1
    f33m_inv
        ins4 (clk, rst2, v3, v4, done2); // v4 == v3^{-1} == (a0^2+a1^2)^{-1}
    f33m_neg
        ins5 (v6, nv6); // nv6 == -v6 == -(a0+a1)^2
    f33m_mult3 // ****** $v8$ depends on $v6$ ******
        ins6 (clk, rst3,
              v5, v5, v6, // v6 == v5^2 == (a0+a1)^2
              v2, v4, v7, // v7 == v2*v4 == (a1^2)*{(a0^2+a1^2)^{-1}}
              nv6, v4, v8, // v8 == -v6*v4
              done3);
    f3_add1
        ins7 (v7[1:0], v9), // v9 == v7[1:0]+1
        ins8 (v8[1:0], v10); // v10 == v8[1:0]+1
    func6
        ins9  (clk, reset, done1, rst2),
        ins10 (clk, reset, done2, rst3);

    always @ (posedge clk)
        if (reset) K <= 4'b1000;
        else if ((K[3]&rst2)|(K[2]&rst3)|(K[1]&done3)|K[0])
            K <= K >> 1;
    
    always @ (posedge clk)
        if (reset) done <= 0;
        else if (K[0])
          begin
            done <= 1; c <= {c5,c4,c3,c2,c1,c0};
          end
endmodule
