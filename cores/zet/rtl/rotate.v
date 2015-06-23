/*
 *  Copyright (c) 2008  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`timescale 1ns/10ps

module rotate (
    input  [15:0] x,
    input  [ 4:0] y,
    input  [ 1:0] func,  // 00: ror, 01: rol, 10: rcr, 11: rcl
    input         cfi,
    input         word_op,
    output [15:0] out,
    output        cfo,
    input         ofi,
    output        ofo
  );

  // Net declarations
  wire [4:0] ror16, rol16, rcr16, rcl16, rot16;
  wire [3:0] ror8, rol8, rcr8, rcl8, rot8;
  wire [7:0] out8;
  wire [15:0] out16;
  wire co8, co16;
  wire unchanged;

  // Module instantiation
  rxr8 rxr8_0 (
    .x  (x[7:0]),
    .ci (cfi),
    .y  (rot8),
    .e  (func[1]),
    .w  (out8),
    .co (co8)
  );

  rxr16 rxr16_0 (
    .x  (x),
    .ci (cfi),
    .y  (rot16),
    .e  (func[1]),
    .w  (out16),
    .co (co16)
  );

  // Continuous assignments
  assign unchanged = word_op ? (y==5'b0) : (y[3:0]==4'b0);
  assign ror16 = { 1'b0, y[3:0] };
  assign rol16 = { 1'b0, -y[3:0] };
  assign ror8  = { 1'b0, y[2:0] };
  assign rol8  = { 1'b0, -y[2:0] };

  assign rcr16 = (y <= 5'd16) ? y : { 1'b0, y[3:0] - 4'b1 };
  assign rcl16 = (y <= 5'd17) ? 5'd17 - y : 6'd34 - y;
  assign rcr8  = y[3:0] <= 4'd8 ? y[3:0] : { 1'b0, y[2:0] - 3'b1 };
  assign rcl8  = y[3:0] <= 4'd9 ? 4'd9 - y[3:0] : 5'd18 - y[3:0];

  assign rot8 = func[1] ? (func[0] ? rcl8 : rcr8 )
                        : (func[0] ? rol8 : ror8 );
  assign rot16 = func[1] ? (func[0] ? rcl16 : rcr16 )
                         : (func[0] ? rol16 : ror16 );

  assign out = word_op ? out16 : { x[15:8], out8 };
  assign cfo = unchanged ? cfi : (func[1] ? (word_op ? co16 : co8)
                                          : (func[0] ? out[0]
                                            : (word_op ? out[15] : out[7])));
  // Overflow
  assign ofo = unchanged ? ofi : (func[0] ? // left
                         (word_op ? cfo^out[15] : cfo^out[7])
                       : // right
                         (word_op ? out[15]^out[14] : out[7]^out[6]));
endmodule

module rxr16 (
    input      [15:0] x,
    input             ci,
    input      [ 4:0] y,
    input             e,
    output reg [15:0] w,
    output reg        co
  );

  always @(x or ci or y or e)
    case (y)
      default: {co,w} <= {ci,x};
      5'd01: {co,w} <= e ? {x[0], ci, x[15:1]} : {ci, x[0], x[15:1]};
      5'd02: {co,w} <= e ? {x[ 1:0], ci, x[15: 2]} : {ci, x[ 1:0], x[15: 2]};
      5'd03: {co,w} <= e ? {x[ 2:0], ci, x[15: 3]} : {ci, x[ 2:0], x[15: 3]};
      5'd04: {co,w} <= e ? {x[ 3:0], ci, x[15: 4]} : {ci, x[ 3:0], x[15: 4]};
      5'd05: {co,w} <= e ? {x[ 4:0], ci, x[15: 5]} : {ci, x[ 4:0], x[15: 5]};
      5'd06: {co,w} <= e ? {x[ 5:0], ci, x[15: 6]} : {ci, x[ 5:0], x[15: 6]};
      5'd07: {co,w} <= e ? {x[ 6:0], ci, x[15: 7]} : {ci, x[ 6:0], x[15: 7]};
      5'd08: {co,w} <= e ? {x[ 7:0], ci, x[15: 8]} : {ci, x[ 7:0], x[15: 8]};
      5'd09: {co,w} <= e ? {x[ 8:0], ci, x[15: 9]} : {ci, x[ 8:0], x[15: 9]};
      5'd10: {co,w} <= e ? {x[ 9:0], ci, x[15:10]} : {ci, x[ 9:0], x[15:10]};
      5'd11: {co,w} <= e ? {x[10:0], ci, x[15:11]} : {ci, x[10:0], x[15:11]};
      5'd12: {co,w} <= e ? {x[11:0], ci, x[15:12]} : {ci, x[11:0], x[15:12]};
      5'd13: {co,w} <= e ? {x[12:0], ci, x[15:13]} : {ci, x[12:0], x[15:13]};
      5'd14: {co,w} <= e ? {x[13:0], ci, x[15:14]} : {ci, x[13:0], x[15:14]};
      5'd15: {co,w} <= e ? {x[14:0], ci, x[15]} : {ci, x[14:0], x[15]};
      5'd16: {co,w} <= {x,ci};
    endcase
endmodule

module rxr8 (
    input      [7:0] x,
    input            ci,
    input      [3:0] y,
    input            e,
    output reg [7:0] w,
    output reg       co
  );

  always @(x or ci or y or e)
    case (y)
      default: {co,w} <= {ci,x};
      5'd01: {co,w} <= e ? {x[0], ci, x[7:1]} : {ci, x[0], x[7:1]};
      5'd02: {co,w} <= e ? {x[1:0], ci, x[7:2]} : {ci, x[1:0], x[7:2]};
      5'd03: {co,w} <= e ? {x[2:0], ci, x[7:3]} : {ci, x[2:0], x[7:3]};
      5'd04: {co,w} <= e ? {x[3:0], ci, x[7:4]} : {ci, x[3:0], x[7:4]};
      5'd05: {co,w} <= e ? {x[4:0], ci, x[7:5]} : {ci, x[4:0], x[7:5]};
      5'd06: {co,w} <= e ? {x[5:0], ci, x[7:6]} : {ci, x[5:0], x[7:6]};
      5'd07: {co,w} <= e ? {x[6:0], ci, x[7]} : {ci, x[6:0], x[7]};
      5'd08: {co,w} <= {x,ci};
    endcase
endmodule
