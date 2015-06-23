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

module jmp_cond (
    input [4:0]  logic_flags,
    input [3:0]  cond,
    input        is_cx,
    input [15:0] cx,
    output reg   jmp
  );

  // Net declarations
  wire of, sf, zf, pf, cf;
  wire cx_zero;

  // Assignments
  assign of = logic_flags[4];
  assign sf = logic_flags[3];
  assign zf = logic_flags[2];
  assign pf = logic_flags[1];
  assign cf = logic_flags[0];
  assign cx_zero = ~(|cx);

  // Behaviour
  always @(cond or is_cx or cx_zero or zf or of or cf or sf or pf)
    if (is_cx) case (cond)
        4'b0000: jmp <= cx_zero;         /* jcxz   */
        4'b0001: jmp <= ~cx_zero;        /* loop   */
        4'b0010: jmp <= zf & ~cx_zero;   /* loopz  */
        default: jmp <= ~zf & ~cx_zero; /* loopnz */
      endcase
    else case (cond)
      4'b0000: jmp <= of;
      4'b0001: jmp <= ~of;
      4'b0010: jmp <= cf;
      4'b0011: jmp <= ~cf;
      4'b0100: jmp <= zf;
      4'b0101: jmp <= ~zf;
      4'b0110: jmp <= cf | zf;
      4'b0111: jmp <= ~cf & ~zf;

      4'b1000: jmp <= sf;
      4'b1001: jmp <= ~sf;
      4'b1010: jmp <= pf;
      4'b1011: jmp <= ~pf;
      4'b1100: jmp <= (sf ^ of);
      4'b1101: jmp <= (sf ^~ of);
      4'b1110: jmp <= zf | (sf ^ of);
      4'b1111: jmp <= ~zf & (sf ^~ of);
    endcase
endmodule
