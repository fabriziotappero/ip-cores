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
`define ZERO {(2*`M){1'b0}}
`define TWO {(2*`M-2){1'b0}},2'b10

// The Modified Duursma-Lee Algorithm
// out == e_({xp,yp}, {xr,yr})
module duursma_lee_algo(clk, reset, xp, yp, xr, yr, done, out);
    input clk, reset;
    input [`WIDTH:0] xp, yp, xr, yr;
    output reg done;
    output reg [`W6:0] out;
    
    reg [`W6:0] t;
    reg [`WIDTH:0] a, b, y;
    reg [1:0] d;
    reg [`M:0] i;
    reg f3m_reset, delay1, delay2;
    wire [`W6:0] g,v7,v8;
    wire [`WIDTH:0] mu /* my name is "mew" */,nmu,ny,
                    x,v2,v3,v4,v5,v6;
    wire [1:0] v9;
    wire f36m_reset, dummy, f3m_done, f36m_done, finish, change;
    
    assign g = {`ZERO,`TWO,`ZERO,nmu,v6,v5};
    assign finish = i[0];
    
    f3m_cubic
        ins1 (xr, x), // x == {x_r}^3
        ins2 (yr, v2); // v2 == {y_r}^3
    f3m_nine
        ins3 (clk, a, v3), // v3 == a^9
        ins4 (clk, b, v4); // v4 == b^9
    f3m_add3
        ins5 (v3, x, {{(2*`M-2){1'b0}},d}, mu); // mu == a^9+x+d
    f3m_neg
        ins6 (mu, nmu), // nmu == -mu
        ins7 (y,  ny);  // ny  == -y
    f3m_mult
        ins8 (clk, delay2, mu, nmu, v5, f3m_done), // v5 == - mu^2
        ins9 (clk, delay2, v4, ny,  v6, dummy); // v6 == - (b^9)*y
    f36m_cubic
        ins10 (clk, t, v7); // v7 == t^3
    f36m_mult
        ins11 (clk, f36m_reset, v7, g, v8, f36m_done); // v8 == v7*g = (t^3)*g
    func6
        ins12 (clk, reset, f36m_done, change),
        ins13 (clk, reset, f3m_done, f36m_reset);
    f3_sub1
        ins14 (d, v9); // v9 == d-1
    
    always @ (posedge clk)
        if (reset)
            i <= {1'b1, {`M{1'b0}}};
        else if (change | i[0])
            i <= i >> 1;
      
    always @ (posedge clk)
      begin
        if (reset)
          begin
            a <= xp; b <= yp; t <= 1; 
            y <= v2; d <= 1;
          end
        else if (change)
          begin
            a <= v3; b <= v4; t <= v8;
            y <= ny; d <= v9;
          end
      end

    always @ (posedge clk)
        if (reset) 
          begin done <= 0; end
        else if (finish) 
          begin done <= 1; out <= v8; end
    
    always @ (posedge clk)
        if (reset)
          begin delay1 <= 1; delay2 <= 1; end
        else
          begin delay2 <= delay1; delay1 <= f3m_reset; end
    
    always @ (posedge clk)
        if (reset) f3m_reset <= 1;
        else if (change) f3m_reset <= 1;
        else f3m_reset <= 0;
endmodule

// do Tate pairing, hahahaha
module tate_pairing(clk, reset, x1, y1, x2, y2, done, out);
    input clk, reset;
    input [`WIDTH:0] x1, y1, x2, y2;
    output reg done;
    output reg [`W6:0] out;
    
    reg delay1, rst1;
    wire done1, rst2, done2;
    wire [`W6:0] out1, out2;
    reg [2:0] K;
    
    duursma_lee_algo 
        ins1 (clk, rst1, x1, y1, x2, y2, done1, out1);
    second_part
        ins2 (clk, rst2, out1, out2, done2);
    func6
        ins3 (clk, reset, done1, rst2);
    
    always @ (posedge clk)
        if (reset)
          begin
            rst1 <= 1; delay1 <= 1;
          end
        else
          begin
            rst1 <= delay1; delay1 <= reset;
          end
    
    always @ (posedge clk)
        if (reset) K <= 3'b100;
        else if ((K[2]&rst2)|(K[1]&done2)|K[0])
            K <= K >> 1;

    always @ (posedge clk)
        if (reset) done <= 0;
        else if (K[0]) begin done <= 1; out <= out2; end
endmodule

