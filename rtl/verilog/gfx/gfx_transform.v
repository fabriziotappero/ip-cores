/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

TRANSFORMATION PROCESSING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*

Input matrix M:
    | aa ab ac tx |
M = | ba bb bc ty |
    | ca cb cc tz |

Input point X:
    | x |
X = | y |
    | z |
    | 1 |

Output point X':
     | x' |        | aa*x + ab*y + ac*z + tx |
X' = | y' | = MX = | ba*x + bb*y + bc*z + ty |
     | z' |        | ca*x + cb*y + cc*z + tz |

*/

/* Transforms points with a 4x3 matrix */
module gfx_transform(clk_i, rst_i,
// Input point
x_i, y_i, z_i, point_id_i,
// Matrix
aa, ab, ac, tx, ba, bb, bc, ty, ca, cb, cc, tz, // TODO: Make signed
// Output points
p0_x_o, p0_y_o, p0_z_o, p1_x_o, p1_y_o, p1_z_o, p2_x_o, p2_y_o, p2_z_o,
transform_i, forward_i,
ack_o
);

input clk_i;
input rst_i;

parameter point_width = 16;
parameter subpixel_width = 16;

input signed [point_width-1:-subpixel_width] x_i;
input signed [point_width-1:-subpixel_width] y_i;
input signed [point_width-1:-subpixel_width] z_i;
input                                  [1:0] point_id_i; // point 0,1,2

input signed [point_width-1:-subpixel_width] aa;
input signed [point_width-1:-subpixel_width] ab;
input signed [point_width-1:-subpixel_width] ac;
input signed [point_width-1:-subpixel_width] tx;
input signed [point_width-1:-subpixel_width] ba;
input signed [point_width-1:-subpixel_width] bb;
input signed [point_width-1:-subpixel_width] bc;
input signed [point_width-1:-subpixel_width] ty;
input signed [point_width-1:-subpixel_width] ca;
input signed [point_width-1:-subpixel_width] cb;
input signed [point_width-1:-subpixel_width] cc;
input signed [point_width-1:-subpixel_width] tz;

output reg signed [point_width-1:-subpixel_width] p0_x_o;
output reg signed [point_width-1:-subpixel_width] p0_y_o;
output reg signed               [point_width-1:0] p0_z_o;
output reg signed [point_width-1:-subpixel_width] p1_x_o;
output reg signed [point_width-1:-subpixel_width] p1_y_o;
output reg signed               [point_width-1:0] p1_z_o;
output reg signed [point_width-1:-subpixel_width] p2_x_o;
output reg signed [point_width-1:-subpixel_width] p2_y_o;
output reg signed               [point_width-1:0] p2_z_o;

input transform_i, forward_i;

output reg ack_o;

reg [1:0] state;
parameter wait_state = 2'b00, forward_state = 2'b01, transform_state = 2'b10;

reg signed [2*point_width-1:-subpixel_width*2] aax;
reg signed [2*point_width-1:-subpixel_width*2] aby;
reg signed [2*point_width-1:-subpixel_width*2] acz;
reg signed [2*point_width-1:-subpixel_width*2] bax;
reg signed [2*point_width-1:-subpixel_width*2] bby;
reg signed [2*point_width-1:-subpixel_width*2] bcz;
reg signed [2*point_width-1:-subpixel_width*2] cax;
reg signed [2*point_width-1:-subpixel_width*2] cby;
reg signed [2*point_width-1:-subpixel_width*2] ccz;

always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  // Initialize registers
  ack_o             <= 1'b0;
  p0_x_o            <= 1'b0;
  p0_y_o            <= 1'b0;
  p0_z_o            <= 1'b0;
  p1_x_o            <= 1'b0;
  p1_y_o            <= 1'b0;
  p1_z_o            <= 1'b0;
  p2_x_o            <= 1'b0;
  p2_y_o            <= 1'b0;
  p2_z_o            <= 1'b0;

  aax               <= 1'b0;
  aby               <= 1'b0;
  acz               <= 1'b0;
  bax               <= 1'b0;
  bby               <= 1'b0;
  bcz               <= 1'b0;
  cax               <= 1'b0;
  cby               <= 1'b0;
  ccz               <= 1'b0;
end
else
  case(state)
    wait_state:
    begin
      ack_o <= 1'b0;

      // Begin transformation
      if(transform_i)
      begin
        aax <= aa * x_i;
        aby <= ab * y_i;
        acz <= ac * z_i;
        bax <= ba * x_i;
        bby <= bb * y_i;
        bcz <= bc * z_i;
        cax <= ca * x_i;
        cby <= cb * y_i;
        ccz <= cc * z_i;
      end
      // Forward the point
      else if(forward_i)
      begin
        if(point_id_i == 2'b00)
        begin
          p0_x_o <= x_i;
          p0_y_o <= y_i;
          p0_z_o <= z_i[point_width-1:0];
        end
        else if(point_id_i == 2'b01)
        begin
          p1_x_o <= x_i;
          p1_y_o <= y_i;
          p1_z_o <= z_i[point_width-1:0];
        end
        else if(point_id_i == 2'b10)
        begin
          p2_x_o <= x_i;
          p2_y_o <= y_i;
          p2_z_o <= z_i[point_width-1:0];
        end
      end
    end

    forward_state:
      ack_o <= 1'b1;

    transform_state:
    begin
      ack_o <= 1'b1;

      if(point_id_i == 2'b00)
        begin
          p0_x_o <= x_prime_trunc;
          p0_y_o <= y_prime_trunc;
          p0_z_o <= z_prime_trunc[point_width-1:0];
        end
        else if(point_id_i == 2'b01)
        begin
          p1_x_o <= x_prime_trunc;
          p1_y_o <= y_prime_trunc;
          p1_z_o <= z_prime_trunc[point_width-1:0];
        end
        else if(point_id_i == 2'b10)
        begin
          p2_x_o <= x_prime_trunc;
          p2_y_o <= y_prime_trunc;
          p2_z_o <= z_prime_trunc[point_width-1:0];
        end
    end
  endcase

wire [subpixel_width-1:0] zeroes = 1'b0;

wire signed [2*point_width-1:-subpixel_width*2] x_prime = aax + aby + acz + {tx,zeroes};
wire signed [2*point_width-1:-subpixel_width*2] y_prime = bax + bby + bcz + {ty,zeroes};
wire signed [2*point_width-1:-subpixel_width*2] z_prime = cax + cby + ccz + {tz,zeroes};

wire signed [point_width-1:-subpixel_width] x_prime_trunc = x_prime[point_width-1:-subpixel_width];
wire signed [point_width-1:-subpixel_width] y_prime_trunc = y_prime[point_width-1:-subpixel_width];
wire signed [point_width-1:-subpixel_width] z_prime_trunc = z_prime[point_width-1:-subpixel_width];

// State machine
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case(state)
    wait_state:
      if(transform_i)
        state <= transform_state;
      else if(forward_i)
        state <= forward_state;

    forward_state:
      state <= wait_state;
    
    transform_state:
      state <= wait_state;
  endcase

endmodule

