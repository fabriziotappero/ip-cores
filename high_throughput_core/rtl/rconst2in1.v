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

/* round constant (2 in 1 ~ ~) */
module rconst2in1(i, rc1, rc2);
    input  [11:0] i;
    output [63:0] rc1, rc2;
    reg    [63:0] rc1, rc2;
    
    always @ (i)
      begin
        rc1 = 0;
        rc1[0] = i[0] | i[2] | i[3] | i[5] | i[6] | i[7] | i[10] | i[11];
        rc1[1] = i[1] | i[2] | i[4] | i[6] | i[8] | i[9];
        rc1[3] = i[1] | i[2] | i[4] | i[5] | i[6] | i[7] | i[9];
        rc1[7] = i[1] | i[2] | i[3] | i[4] | i[6] | i[7] | i[10];
        rc1[15] = i[1] | i[2] | i[3] | i[5] | i[6] | i[7] | i[8] | i[9] | i[10];
        rc1[31] = i[3] | i[5] | i[6] | i[10] | i[11];
        rc1[63] = i[1] | i[3] | i[7] | i[8] | i[10];
      end
    
    always @ (i)
      begin
        rc2 = 0;
        rc2[0] = i[2] | i[3] | i[6] | i[7];
        rc2[1] = i[0] | i[5] | i[6] | i[7] | i[9];
        rc2[3] = i[3] | i[4] | i[5] | i[6] | i[9] | i[11];
        rc2[7] = i[0] | i[4] | i[6] | i[8] | i[10];
        rc2[15] = i[0] | i[1] | i[3] | i[7] | i[10] | i[11];
        rc2[31] = i[1] | i[2] | i[5] | i[9] | i[11];
        rc2[63] = i[1] | i[3] | i[6] | i[7] | i[8] | i[9] | i[10] | i[11];
      end
endmodule
