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

/* PE: processing element */
module PE(clk, reset, ctrl, d0, d1, d2, out);
    input clk;
    input reset;
    input [10:0] ctrl;
    input [`WIDTH_D0:0] d0;
    input [`WIDTH:0] d1, d2;
    output [`WIDTH:0] out;
    
    reg [`WIDTH_D0:0] R0;
    reg [`WIDTH:0] R1, R2, R3;
    wire [1:0] e0, e1, e2; /* part of R0 */
    wire [`WIDTH:0] ppg0, ppg1, ppg2, /* output of PPG */
                    mx0, mx1, mx2, mx3, mx4, mx5, mx6, /* output of MUX */
                    ad0, ad1, ad2, /* output of GF(3^m) adder */
                    cu0, cu1, cu2, /* output of cubic */
                    mo0, mo1, mo2, /* output of mod_p */
                    t0, t1, t2;
    wire c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
    
    assign {c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10} = ctrl;
    assign mx0 = c0 ? d1 : ad2;
    assign mx1 = c2 ? d2 : ad2;
    always @ (posedge clk)
        if(reset) R1 <= 0;
        else if (c1) R1 <= mx0;
    always @ (posedge clk)
        if(reset) R2 <= 0;
        else if (c3) R2 <= mx1;
    always @ (posedge clk)
        if(reset) R0 <= 0;
        else if (c4) R0 <= d0;
        else if (c5) R0 <= R0 << 6;
    assign {e2,e1,e0} = R0[`WIDTH_D0:(`WIDTH_D0-5)];
    PPG
        ppg_0 (e0, R1, ppg0),
        ppg_1 (e1, R2, ppg1),
        ppg_2 (e2, R1, ppg2);
    v0  v0_ (ppg0, cu0);
    v1  v1_ (ppg1, cu1);
    v2  v2_ (ppg2, cu2);
    assign mx2 = c6 ? ppg0 : cu0;
    assign mx3 = c6 ? ppg1 : cu1;
    assign mx4 = c6 ? mo1 : cu2;
    assign mx5 = c7 ? mo2 : R3;
    mod_p
        mod_p_0 (mx3, mo0),
        mod_p_1 (ppg2, t0),
        mod_p_2 (t0, mo1),
        mod_p_3 (R3, t1),
        mod_p_4 (t1, t2),
        mod_p_5 (t2, mo2);
    assign mx6 = c9 ? mo0 : mx3;
    f3m_add
        f3m_add_0 (mx2, mx6, ad0),
        f3m_add_1 (mx4, c8 ? mx5 : 0, ad1),
        f3m_add_2 (ad0, ad1, ad2);
    always @ (posedge clk)
        if (reset) R3 <= 0;
        else if (c10) R3 <= ad2;
        else R3 <= 0; /* change */
    assign out = R3;
endmodule

// C = (x*B mod p(x))
module mod_p(B, C);
    input [`WIDTH:0] B;
    output [`WIDTH:0] C;
    wire [`WIDTH+2:0] A;
    assign A = {B[`WIDTH:0], 2'd0}; // A == B*x
    wire [1:0] w0;
    f3_mult m0 (A[1187:1186], 2'd2, w0);
    f3_sub s0 (A[1:0], w0, C[1:0]);
    assign C[223:2] = A[223:2];
    wire [1:0] w112;
    f3_mult m112 (A[1187:1186], 2'd1, w112);
    f3_sub s112 (A[225:224], w112, C[225:224]);
    assign C[1185:226] = A[1185:226];
endmodule

// PPG: partial product generator, C == A*d in GF(3^m)
module PPG(d, A, C);
    input [1:0] d;
    input [`WIDTH:0] A;
    output [`WIDTH:0] C;
    genvar i;
    generate
        for (i=0; i < `M; i=i+1) 
        begin: ppg0
            f3_mult f3_mult_0 (d, A[2*i+1:2*i], C[2*i+1:2*i]);
        end
    endgenerate
endmodule

// f3m_add: C = A + B, in field F_{3^M}
module f3m_add(A, B, C);
    input [`WIDTH : 0] A, B;
    output [`WIDTH : 0] C;
    genvar i;
    generate
        for(i=0; i<`M; i=i+1) begin: aa
            f3_add aa(A[(2*i+1) : 2*i], B[(2*i+1) : 2*i], C[(2*i+1) : 2*i]);
        end
    endgenerate
endmodule

// f3_add: C == A+B (mod 3)
module f3_add(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    wire a0, a1, b0, b1, c0, c1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C = {c1, c0};
    assign c0 = ( a0 & ~a1 & ~b0 & ~b1) |
                (~a0 & ~a1 &  b0 & ~b1) |
                (~a0 &  a1 & ~b0 &  b1) ;
    assign c1 = (~a0 &  a1 & ~b0 & ~b1) |
                ( a0 & ~a1 &  b0 & ~b1) |
                (~a0 & ~a1 & ~b0 &  b1) ;
endmodule

// f3_sub: C == A-B (mod 3)
module f3_sub(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    f3_add a0(A, {B[0],B[1]}, C);
endmodule

// f3_mult: C = A*B (mod 3)
module f3_mult(A, B, C); 
    input [1:0] A;
    input [1:0] B; 
    output [1:0] C;
    wire a0, a1, b0, b1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C[0] = (~a1 & a0 & ~b1 & b0) | (a1 & ~a0 & b1 & ~b0);
    assign C[1] = (~a1 & a0 & b1 & ~b0) | (a1 & ~a0 & ~b1 & b0);
endmodule
