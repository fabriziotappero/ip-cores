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

module ram_2k (clk, rst, cs, we, addr, rdata, wdata);
  // IO Ports
  input clk;
  input rst;
  input cs;
  input we;
  input [10:0] addr;
  output [7:0] rdata;
  input [7:0] wdata;

  // Net declarations
  wire dp;

  // Module instantiations
  RAMB16_S9 ram (.DO(rdata),
                 .DOP (dp),
                 .ADDR (addr),
                 .CLK (clk),
                 .DI (wdata),
                 .DIP (dp),
                 .EN (cs),
                 .SSR (rst),
                 .WE (we));

    defparam ram.INIT_00 = 256'h554456_2043504F53_20302E3176_20726F737365636F7270_2074655A;
/*
    defparam ram.INIT_00 = 256'h31303938373635343332313039383736_35343332313039383736353433323130;
    defparam ram.INIT_01 = 256'h33323130393837363534333231303938_37363534333231303938373635343332;
    defparam ram.INIT_02 = 256'h3139383736353433323130393837363534;
    defparam ram.INIT_03 = 256'h43000000;
    defparam ram.INIT_05 = 256'h32;
    defparam ram.INIT_07 = 256'h3300000000000000000000000000000000;
    defparam ram.INIT_0A = 256'h34;
    defparam ram.INIT_0C = 256'h3500000000000000000000000000000000;
    defparam ram.INIT_0F = 256'h36;
    defparam ram.INIT_11 = 256'h3700000000000000000000000000000000;
    defparam ram.INIT_14 = 256'h38;
    defparam ram.INIT_16 = 256'h3900000000000000000000000000000000;
    defparam ram.INIT_19 = 256'h30;
    defparam ram.INIT_1B = 256'h3100000000000000000000000000000000;
    defparam ram.INIT_1E = 256'h32;
    defparam ram.INIT_20 = 256'h3300000000000000000000000000000000;
    defparam ram.INIT_23 = 256'h34;
    defparam ram.INIT_25 = 256'h3500000000000000000000000000000000;
    defparam ram.INIT_28 = 256'h36;
    defparam ram.INIT_2A = 256'h3700000000000000000000000000000000;
    defparam ram.INIT_2D = 256'h38;
    defparam ram.INIT_2F = 256'h3900000000000000000000000000000000;
    defparam ram.INIT_32 = 256'h30;
    defparam ram.INIT_34 = 256'h3100000000000000000000000000000000;
    defparam ram.INIT_37 = 256'h32;
    defparam ram.INIT_39 = 256'h3300000000000000000000000000000000;
    defparam ram.INIT_3C = 256'h31303938373635343332313039383736_35343332313039383736353433323134;
    defparam ram.INIT_3D = 256'h33323130393837363534333231303938_37363534333231303938373635343332;
    defparam ram.INIT_3E = 256'h35343332313039383736353433323130_39383736353433323130393837363534;
    defparam ram.INIT_3F = 256'h37363534333231303938373635343332_31303938373635343332313039383736;
*/
endmodule