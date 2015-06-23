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

/*
 * the module of constants
 *
 * addr  out  effective
 *    1   0     1
 *    2   1     1
 *    4   +     1
 *    8   -     1
 *   16 cubic   1
 * other  0     0
 */
module const_ (clk, addr, out, effective);
    input clk;
    input [5:0] addr;
    output reg [`WIDTH_D0:0] out;
    output reg effective; // active high if out is effective
    
    always @ (posedge clk)
      begin
         effective <= 1;
         case (addr)
            1:  out <= 0;
            2:  out <= 1;
            4:  out <= {6'b000101, 1182'd0};
            8:  out <= {6'b001001, 1182'd0};
            16: out <= {6'b010101, 1182'd0};
            default: 
               begin out <= 0; effective <= 0; end
         endcase
      end
endmodule
