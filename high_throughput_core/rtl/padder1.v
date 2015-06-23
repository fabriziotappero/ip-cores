/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
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

module padder1(in, byte_num, out);
    input      [63:0] in;
    input      [2:0]  byte_num;
    output reg [63:0] out;
    
    always @ (*)
      case (byte_num)
        0: out =             64'h0100000000000000;
        1: out = {in[63:56], 56'h01000000000000};
        2: out = {in[63:48], 48'h010000000000};
        3: out = {in[63:40], 40'h0100000000};
        4: out = {in[63:32], 32'h01000000};
        5: out = {in[63:24], 24'h010000};
        6: out = {in[63:16], 16'h0100};
        7: out = {in[63:8],   8'h01};
      endcase
endmodule
