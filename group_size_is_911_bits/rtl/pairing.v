/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

module pairing(clk, reset, sel, addr, w, update, ready, i, o, done);
   input clk;
   input reset; // for the arithmethic core
   input sel;
   input [5:0] addr;
   input w;
   input update; // update reg_in & reg_out
   input ready;  // shift reg_in & reg_out
   input i;
   output o;
   output done;
   
   reg [`WIDTH_D0:0] reg_in, reg_out;
   wire [`WIDTH_D0:0] out;
   
   assign o = reg_out[0];
   
   tiny
      tiny0 (clk, reset, sel, addr, w, reg_in, out, done);
   
   always @ (posedge clk) // write LSB firstly
      if (update) reg_in <= 0;
      else if (ready) reg_in <= {i,reg_in[`WIDTH_D0:1]};
   
   always @ (posedge clk) // read LSB firstly
      if (update) reg_out <= out;
      else if (ready) reg_out <= reg_out>>1;
endmodule
