/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

Components for aligning colored pixels to memory and the inverse

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

module color_to_memory(color_depth_i, color_i, x_lsb_i,
                       mem_o, sel_o);

input  [1:0]  color_depth_i;
input  [31:0] color_i;
input  [1:0]  x_lsb_i;
output [31:0] mem_o;
output [3:0]  sel_o;

assign sel_o = (color_depth_i == 2'b00) && (x_lsb_i == 2'b00) ? 4'b1000 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b01) ? 4'b0100 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b10) ? 4'b0010 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b11) ? 4'b0001 : // 8-bit
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b0)  ? 4'b1100  : // 16-bit, high word
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b1)  ? 4'b0011  : // 16-bit, low word
               4'b1111; // 32-bit

assign mem_o = (color_depth_i == 2'b00) && (x_lsb_i == 2'b00) ? {color_i[7:0], 24'h000000} : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b01) ? {color_i[7:0], 16'h0000}   : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b10) ? {color_i[7:0], 8'h00}      : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b11) ? {color_i[7:0]}             : // 8-bit
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b0)  ? {color_i[15:0], 16'h0000}   : // 16-bit, high word
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b1)  ? {color_i[15:0]}             : // 16-bit, low word
               color_i; // 32-bit

endmodule

module memory_to_color(color_depth_i, mem_i, mem_lsb_i,
                       color_o, sel_o);

input  [1:0]  color_depth_i;
input  [31:0] mem_i;
input  [1:0]  mem_lsb_i;
output [31:0] color_o;
output [3:0]  sel_o;

assign sel_o = color_depth_i == 2'b00 ? 4'b0001 : // 8-bit
               color_depth_i == 2'b01 ? 4'b0011 : // 16-bit, low word
               4'b1111; // 32-bit

assign color_o = (color_depth_i == 2'b00) && (mem_lsb_i == 2'b00) ? {mem_i[31:24]} : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b01) ? {mem_i[23:16]} : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b10) ? {mem_i[15:8]}  : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b11) ? {mem_i[7:0]}   : // 8-bit
                 (color_depth_i == 2'b01) && (mem_lsb_i[0] == 1'b0)  ? {mem_i[31:16]} : // 16-bit, high word
                 (color_depth_i == 2'b01) && (mem_lsb_i[0] == 1'b1)  ? {mem_i[15:0]}  : // 16-bit, low word
                 mem_i; // 32-bit

endmodule

