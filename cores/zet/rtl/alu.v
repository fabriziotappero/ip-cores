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

module alu (
    input  [31:0] x,
    input  [15:0] y,
    output [31:0] out,
    input  [ 2:0] t,
    input  [ 2:0] func,
    input  [15:0] iflags,
    output [ 8:0] oflags,
    input         word_op,
    input  [15:0] seg,
    input  [15:0] off,
    input         clk,
    output        div_exc
  );

  // Net declarations
  wire [15:0] add, log, shi, rot;
  wire  [8:0] othflags;
  wire [19:0] oth;
  wire [31:0] cnv, mul;
  wire af_add, af_cnv;
  wire cf_cnv, cf_add, cf_mul, cf_log, cf_shi, cf_rot;
  wire of_cnv, of_add, of_mul, of_log, of_shi, of_rot;
  wire ofi, sfi, zfi, afi, pfi, cfi;
  wire ofo, sfo, zfo, afo, pfo, cfo;
  wire flags_unchanged;
  wire dexc;

  // Module instances
  addsub add1 (x[15:0], y, add, func, word_op, cfi, cf_add, af_add, of_add);

  conv cnv2 (
    .x      (x[15:0]),
    .func   (func),
    .out    (cnv),
    .iflags ({afi, cfi}),
    .oflags ({af_cnv, of_cnv, cf_cnv})
  );

  muldiv mul3 (
    .x       (x),
    .y       (y),
    .o       (mul),
    .f       (func),
    .word_op (word_op),
    .cfo     (cf_mul),
    .ofo     (of_mul),
    .clk     (clk),
    .exc     (dexc)
  );

  bitlog log4 (x[15:0], y, log, func, cf_log, of_log);
  shifts shi5 (x[15:0], y[4:0], shi, func[1:0], word_op, cfi, ofi, cf_shi, of_shi);
  rotate rot6 (x[15:0], y[4:0], func[1:0], cfi, word_op, rot, cf_rot, ofi, of_rot);
  othop  oth7 (x[15:0], y, seg, off, iflags, func, word_op, oth, othflags);

  mux8_16 m0(t, {8'd0, y[7:0]}, add, cnv[15:0],
             mul[15:0], log, shi, rot, oth[15:0], out[15:0]);
  mux8_16 m1(t, 16'd0, 16'd0, cnv[31:16], mul[31:16],
             16'd0, 16'd0, 16'd0, {12'b0,oth[19:16]}, out[31:16]);
  mux8_1  a1(t, 1'b0, cf_add, cf_cnv, cf_mul, cf_log, cf_shi, cf_rot, 1'b0, cfo);
  mux8_1  a2(t, 1'b0, af_add, af_cnv, 1'b0, 1'b0, 1'b0, afi, 1'b0, afo);
  mux8_1  a3(t, 1'b0, of_add, of_cnv, of_mul, of_log, of_shi, of_rot, 1'b0, ofo);

  // Flags
  assign pfo = flags_unchanged ? pfi : ^~ out[7:0];
  assign zfo = flags_unchanged ? zfi
             : ((word_op && (t!=3'd2)) ? ~|out[15:0] : ~|out[7:0]);
  assign sfo = flags_unchanged ? sfi
             : ((word_op && (t!=3'd2)) ? out[15] : out[7]);

  assign oflags = (t == 3'd7) ? othflags 
                 : { ofo, iflags[10:8], sfo, zfo, afo, pfo, cfo };

  assign ofi = iflags[11];
  assign sfi = iflags[7];
  assign zfi = iflags[6];
  assign afi = iflags[4];
  assign pfi = iflags[2];
  assign cfi = iflags[0];

  assign flags_unchanged = (t == 3'd4 && func == 3'd2
                         || t == 3'd5 && y[4:0] == 5'h0
                         || t == 3'd6);

  assign div_exc = func[1] && (t==3'd3) && dexc;

endmodule

module addsub (
    input  [15:0] x,
    input  [15:0] y,
    output [15:0] out,
    input  [ 2:0] f,
    input         word_op,
    input         cfi,
    output        cfo,
    output        afo,
    output        ofo
  );

  // Net declarations
  wire [15:0] op2;

  wire ci;
  wire cfoadd;
  wire xs, ys, os;

  // Module instances
  fulladd16 fa0 ( // We instantiate only one adder
    .x  (x),      //  to have less hardware
    .y  (op2),
    .ci (ci),
    .co (cfoadd),
    .z  (out),
    .s  (f[2])
  );

  // Assignments
  assign op2 = f[2] ? ~y
             : ((f[1:0]==2'b11) ? { 8'b0, y[7:0] } : y);
  assign ci  = f[2] & f[1] | f[2] & ~f[0] & ~cfi
             | f[2] & f[0] | (f==3'b0) & cfi;
  assign afo = f[1] ? (f[2] ? &out[3:0] : ~|out[3:0] )
                    : (x[4] ^ y[4] ^ out[4]);
  assign cfo = f[1] ? cfi /* inc, dec */
             : (word_op ? cfoadd : (x[8]^y[8]^out[8]));

  assign xs  = word_op ? x[15] : x[7];
  assign ys  = word_op ? y[15] : y[7];
  assign os  = word_op ? out[15] : out[7];
  assign ofo = f[2] ? (~xs & ys & os | xs & ~ys & ~os)
                    : (~xs & ~ys & os | xs & ys & ~os);
endmodule

module conv (
    input  [15:0] x,
    input  [ 2:0] func,
    output [31:0] out,
    input  [ 1:0] iflags, // afi, cfi
    output [ 2:0] oflags  // afo, ofo, cfo
  );

  // Net declarations
  wire        afi, cfi;
  wire        ofo, afo, cfo;
  wire [15:0] aaa, aas;
  wire [ 7:0] daa, tmpdaa, das, tmpdas;
  wire [15:0] cbw, cwd;

  wire        acond, dcond;
  wire        tmpcf;

  // Module instances
  mux8_16 m0(func, cbw, aaa, aas, 16'd0,
                   cwd, {x[15:8], daa}, {x[15:8], das}, 16'd0, out[15:0]);

  // Assignments
  assign aaa = (acond ? (x + 16'h0106) : x) & 16'hff0f;
  assign aas = (acond ? (x - 16'h0106) : x) & 16'hff0f;

  assign tmpdaa = acond ? (x[7:0] + 8'h06) : x[7:0];
  assign daa    = dcond ? (tmpdaa + 8'h60) : tmpdaa;
  assign tmpdas = acond ? (x[7:0] - 8'h06) : x[7:0];
  assign das    = dcond ? (tmpdas - 8'h60) : tmpdas;

  assign               cbw   = { { 8{x[ 7]}}, x[7:0] };
  assign { out[31:16], cwd } = { {16{x[15]}}, x      };

  assign acond = ((x[7:0] & 8'h0f) > 8'h09) | afi;
  assign dcond = (x[7:0] > 8'h99) | cfi;

  assign afi = iflags[1];
  assign cfi = iflags[0];

  assign afo = acond;
  assign ofo = 1'b0;
  assign tmpcf = (x[7:0] < 8'h06) | cfi;
  assign cfo = func[2] ? (dcond ? 1'b1 : (acond & tmpcf))
             : acond;

  assign oflags = { afo, ofo, cfo };
endmodule


module muldiv (
    input  [31:0] x,  // 16 MSb for division
    input  [15:0] y,
    output [31:0] o,
    input  [ 2:0] f,
    input         word_op,
    output        cfo,
    output        ofo,
    input         clk,
    output        exc
  );

  // Net declarations
  wire as, bs, cfs, cfu;
  wire [16:0] a, b;
  wire [33:0] p;
  wire div0, over, ovf, mint;

  wire [33:0] zi;
  wire [16:0] di;
  wire [17:0] q;
  wire [17:0] s;

  // Module instantiations
  mult signmul17 (
    .clk (clk),
    .a   (a),
    .b   (b),
    .p   (p)
  );

  div_su #(34) dut (
    .clk  (clk),
    .ena  (1'b1),
    .z    (zi),
    .d    (di),
    .q    (q),
    .s    (s),
    .ovf  (ovf),
    .div0 (div0)
  );

  // Sign ext. for imul
  assign as  = f[0] & (word_op ? x[15] : x[7]);
  assign bs  = f[0] & (word_op ? y[15] : y[7]);
  assign a   = word_op ? { as, x[15:0] }
                       : { {9{as}}, x[7:0] };
  assign b   = word_op ? { bs, y } : { {9{bs}}, y[7:0] };

  assign zi  = f[2] ? { 26'h0, x[7:0] }
               : (word_op ? (f[0] ? { {2{x[31]}}, x }
                               : { 2'b0, x })
                       : (f[0] ? { {18{x[15]}}, x[15:0] }
                               : { 18'b0, x[15:0] }));

  assign di  = word_op ? (f[0] ? { y[15], y } : { 1'b0, y })
                       : (f[0] ? { {9{y[7]}}, y[7:0] }
                               : { 9'h000, y[7:0] });

  assign o   = f[2] ? { 16'h0, q[7:0], s[7:0] }
               : (f[1] ? ( word_op ? {s[15:0], q[15:0]}
                                : {16'h0, s[7:0], q[7:0]})
                    : p[31:0]);

  assign ofo = f[1] ? 1'b0 : cfo;
  assign cfo = f[1] ? 1'b0 : !(f[0] ? cfs : cfu);
  assign cfu = word_op ? (o[31:16] == 16'h0)
                       : (o[15:8] == 8'h0);
  assign cfs = word_op ? (o[31:16] == {16{o[15]}})
                       : (o[15:8] == {8{o[7]}});

  // Exceptions
  assign over = f[2] ? 1'b0
              : (word_op ? (f[0] ? (q[17:16]!={2{q[15]}})
                                : (q[17:16]!=2'b0) )
                        : (f[0] ? (q[17:8]!={10{q[7]}})
                                : (q[17:8]!=10'h000)));
  assign mint = f[0] & (word_op ? (x==32'h80000000)
                                : (x==16'h8000));
  assign exc  = div0 | (!f[2] & ovf) | over | mint;
endmodule

module bitlog(x, y, out, func, cfo, ofo);
  // IO ports
  input  [15:0] x, y;
  input  [2:0]  func;
  output [15:0] out;
  output        cfo, ofo;

  // Net declarations
  wire [15:0] and_n, or_n, not_n, xor_n;

  // Module instantiations
  mux8_16 m0(func, and_n, or_n, not_n, xor_n, 16'd0, 16'd0, 16'd0, 16'd0, out);

  // Assignments
  assign and_n  = x & y;
  assign or_n   = x | y;
  assign not_n  = ~x;
  assign xor_n  = x ^ y;

  assign cfo = 1'b0;
  assign ofo = 1'b0;
endmodule

//
// This module implements the instructions shl/sal, sar, shr
//

module shifts(x, y, out, func, word_op, cfi, ofi, cfo, ofo);
  // IO ports
  input  [15:0] x;
  input  [ 4:0] y;
  input   [1:0] func;
  input         word_op;
  output [15:0] out;
  output        cfo, ofo;
  input         cfi, ofi;

  // Net declarations
  wire [15:0] sal, sar, shr, sal16, sar16, shr16;
  wire [7:0]  sal8, sar8, shr8;
  wire ofo_shl, ofo_sar, ofo_shr;
  wire cfo_sal8, cfo_sal16, cfo_sar8, cfo_sar16, cfo_shr8, cfo_shr16;
  wire cfo16, cfo8;
  wire unchanged;

  // Module instantiations
  mux4_16 m0(func, sal, sar, shr, 16'd0, out);

  // Assignments
  assign { cfo_sal16, sal16 } = x << y;
  assign { sar16, cfo_sar16 } = (y > 5'd16) ? 17'h1ffff
    : (({x,1'b0} >> y) | (x[15] ? (17'h1ffff << (17 - y))
                                     : 17'h0));
  assign { shr16, cfo_shr16 } = ({x,1'b0} >> y);

  assign { cfo_sal8, sal8 } = x[7:0] << y;
  assign { sar8, cfo_sar8 } = (y > 5'd8) ? 9'h1ff
    : (({x[7:0],1'b0} >> y) | (x[7] ? (9'h1ff << (9 - y))
                                         : 9'h0));
  assign { shr8, cfo_shr8 } = ({x[7:0],1'b0} >> y);

  assign sal     = word_op ? sal16 : { 8'd0, sal8 };
  assign shr     = word_op ? shr16 : { 8'd0, shr8 };
  assign sar     = word_op ? sar16 : { {8{sar8[7]}}, sar8 };

  assign ofo = unchanged ? ofi
             : (func[1] ? ofo_shr : (func[0] ? ofo_sar : ofo_shl));
  assign cfo16 = func[1] ? cfo_shr16
               : (func[0] ? cfo_sar16 : cfo_sal16);
  assign cfo8  = func[1] ? cfo_shr8
               : (func[0] ? cfo_sar8 : cfo_sal8);
  assign cfo = unchanged ? cfi : (word_op ? cfo16 : cfo8);
  assign ofo_shl = word_op ? (out[15] != cfo) : (out[7] != cfo);
  assign ofo_sar = 1'b0;
  assign ofo_shr = word_op ? x[15] : x[7];

  assign unchanged = word_op ? (y==5'b0) : (y[3:0]==4'b0);
endmodule

module othop (x, y, seg, off, iflags, func, word_op, out, oflags);
  // IO ports
  input [15:0] x, y, off, seg, iflags;
  input [2:0] func;
  input word_op;
  output [19:0] out;
  output [8:0] oflags;

  // Net declarations
  wire [15:0] deff, deff2, outf, clcm, setf, intf, strf;
  wire [19:0] dcmp, dcmp2; 
  wire dfi;

  // Module instantiations
  mux8_16 m0(func, dcmp[15:0], dcmp2[15:0], deff, outf, clcm, setf, 
                   intf, strf, out[15:0]);
  assign out[19:16] = func ? dcmp2[19:16] : dcmp[19:16];

  // Assignments
  assign dcmp  = (seg << 4) + deff;
  assign dcmp2 = (seg << 4) + deff2;
  assign deff  = x + y + off;
  assign deff2 = x + y + off + 16'd2;
  assign outf  = y;
  assign clcm  = y[2] ? (y[1] ? /* -1: clc */ {iflags[15:1], 1'b0} 
                         : /* 4: cld */ {iflags[15:11], 1'b0, iflags[9:0]})
                     : (y[1] ? /* 2: cli */ {iflags[15:10], 1'b0, iflags[8:0]}
                       : /* 0: cmc */ {iflags[15:1], ~iflags[0]});
  assign setf  = y[2] ? (y[1] ? /* -1: stc */ {iflags[15:1], 1'b1} 
                         : /* 4: std */ {iflags[15:11], 1'b1, iflags[9:0]})
                     : (y[1] ? /* 2: sti */ {iflags[15:10], 1'b1, iflags[8:0]}
                       : /* 0: outf */ iflags);

  assign intf = {iflags[15:10], 2'b0, iflags[7:0]};
  assign dfi  = iflags[10];
  assign strf = dfi ? (x - y) : (x + y);

  assign oflags = word_op ? { out[11:6], out[4], out[2], out[0] }
                           : { iflags[11:8], out[7:6], out[4], out[2], out[0] };
endmodule
