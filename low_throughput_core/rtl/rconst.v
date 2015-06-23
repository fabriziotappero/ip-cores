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

/* round constant */
module rconst(i, rc);
    input      [23:0] i;
    output reg [63:0] rc;
    
    always @ (i)
      begin
        rc = 0;
        rc[0] = i[0] | i[4] | i[5] | i[6] | i[7] | i[10] | i[12] | i[13] | i[14] | i[15] | i[20] | i[22];
        rc[1] = i[1] | i[2] | i[4] | i[8] | i[11] | i[12] | i[13] | i[15] | i[16] | i[18] | i[19];
        rc[3] = i[2] | i[4] | i[7] | i[8] | i[9] | i[10] | i[11] | i[12] | i[13] | i[14] | i[18] | i[19] | i[23];
        rc[7] = i[1] | i[2] | i[4] | i[6] | i[8] | i[9] | i[12] | i[13] | i[14] | i[17] | i[20] | i[21];
        rc[15] = i[1] | i[2] | i[3] | i[4] | i[6] | i[7] | i[10] | i[12] | i[14] | i[15] | i[16] | i[18] | i[20] | i[21] | i[23];
        rc[31] = i[3] | i[5] | i[6] | i[10] | i[11] | i[12] | i[19] | i[20] | i[22] | i[23];
        rc[63] = i[2] | i[3] | i[6] | i[7] | i[13] | i[14] | i[15] | i[16] | i[17] | i[19] | i[20] | i[21] | i[23];
      end
endmodule

