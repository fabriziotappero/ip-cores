/////////////////////////////////////////////////////////////////////
////                                                             ////
////  SHA-512/384                                                ////
////  Secure Hash Algorithm (SHA-512 SHA-384)                    ////
////                                                             ////
////  Author: marsgod                                            ////
////          marsgod@opencores.org                              ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/sha_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 marsgod                             ////
////                         marsgod@opencores.org               ////
////                                                             ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`define SHA512_H0 64'h6a09e667_f3bcc908
`define SHA512_H1 64'hbb67ae85_84caa73b
`define SHA512_H2 64'h3c6ef372_fe94f82b
`define SHA512_H3 64'ha54ff53a_5f1d36f1
`define SHA512_H4 64'h510e527f_ade682d1
`define SHA512_H5 64'h9b05688c_2b3e6c1f
`define SHA512_H6 64'h1f83d9ab_fb41bd6b
`define SHA512_H7 64'h5be0cd19_137e2179

`define SHA384_H0 64'hcbbb9d5d_c1059ed8
`define SHA384_H1 64'h629a292a_367cd507
`define SHA384_H2 64'h9159015a_3070dd17
`define SHA384_H3 64'h152fecd8_f70e5939
`define SHA384_H4 64'h67332667_ffc00b31
`define SHA384_H5 64'h8eb44a87_68581511
`define SHA384_H6 64'hdb0c2e0d_64f98fa7
`define SHA384_H7 64'h47b5481d_befa4fa4

`define K00 64'h428a2f98_d728ae22
`define K01 64'h71374491_23ef65cd
`define K02 64'hb5c0fbcf_ec4d3b2f
`define K03 64'he9b5dba5_8189dbbc
`define K04 64'h3956c25b_f348b538
`define K05 64'h59f111f1_b605d019
`define K06 64'h923f82a4_af194f9b
`define K07 64'hab1c5ed5_da6d8118
`define K08 64'hd807aa98_a3030242
`define K09 64'h12835b01_45706fbe
`define K10 64'h243185be_4ee4b28c
`define K11 64'h550c7dc3_d5ffb4e2
`define K12 64'h72be5d74_f27b896f
`define K13 64'h80deb1fe_3b1696b1
`define K14 64'h9bdc06a7_25c71235
`define K15 64'hc19bf174_cf692694
`define K16 64'he49b69c1_9ef14ad2
`define K17 64'hefbe4786_384f25e3
`define K18 64'h0fc19dc6_8b8cd5b5
`define K19 64'h240ca1cc_77ac9c65
`define K20 64'h2de92c6f_592b0275
`define K21 64'h4a7484aa_6ea6e483
`define K22 64'h5cb0a9dc_bd41fbd4
`define K23 64'h76f988da_831153b5
`define K24 64'h983e5152_ee66dfab
`define K25 64'ha831c66d_2db43210
`define K26 64'hb00327c8_98fb213f
`define K27 64'hbf597fc7_beef0ee4
`define K28 64'hc6e00bf3_3da88fc2
`define K29 64'hd5a79147_930aa725
`define K30 64'h06ca6351_e003826f
`define K31 64'h14292967_0a0e6e70
`define K32 64'h27b70a85_46d22ffc
`define K33 64'h2e1b2138_5c26c926
`define K34 64'h4d2c6dfc_5ac42aed
`define K35 64'h53380d13_9d95b3df
`define K36 64'h650a7354_8baf63de
`define K37 64'h766a0abb_3c77b2a8
`define K38 64'h81c2c92e_47edaee6
`define K39 64'h92722c85_1482353b
`define K40 64'ha2bfe8a1_4cf10364
`define K41 64'ha81a664b_bc423001
`define K42 64'hc24b8b70_d0f89791
`define K43 64'hc76c51a3_0654be30
`define K44 64'hd192e819_d6ef5218
`define K45 64'hd6990624_5565a910
`define K46 64'hf40e3585_5771202a
`define K47 64'h106aa070_32bbd1b8
`define K48 64'h19a4c116_b8d2d0c8
`define K49 64'h1e376c08_5141ab53
`define K50 64'h2748774c_df8eeb99
`define K51 64'h34b0bcb5_e19b48a8
`define K52 64'h391c0cb3_c5c95a63
`define K53 64'h4ed8aa4a_e3418acb
`define K54 64'h5b9cca4f_7763e373
`define K55 64'h682e6ff3_d6b2b8a3
`define K56 64'h748f82ee_5defb2fc
`define K57 64'h78a5636f_43172f60
`define K58 64'h84c87814_a1f0ab72
`define K59 64'h8cc70208_1a6439ec
`define K60 64'h90befffa_23631e28
`define K61 64'ha4506ceb_de82bde9
`define K62 64'hbef9a3f7_b2c67915
`define K63 64'hc67178f2_e372532b
`define K64 64'hca273ece_ea26619c
`define K65 64'hd186b8c7_21c0c207
`define K66 64'heada7dd6_cde0eb1e
`define K67 64'hf57d4f7f_ee6ed178
`define K68 64'h06f067aa_72176fba
`define K69 64'h0a637dc5_a2c898a6
`define K70 64'h113f9804_bef90dae
`define K71 64'h1b710b35_131c471b
`define K72 64'h28db77f5_23047d84
`define K73 64'h32caab7b_40c72493
`define K74 64'h3c9ebe0a_15c9bebc
`define K75 64'h431d67c4_9c100d4c
`define K76 64'h4cc5d4be_cb3e42b6
`define K77 64'h597f299c_fc657e2a
`define K78 64'h5fcb6fab_3ad6faec
`define K79 64'h6c44198c_4a475817

module sha512 (clk_i, rst_i, text_i, text_o, cmd_i, cmd_w_i, cmd_o);

        input           clk_i;  // global clock input
        input           rst_i;  // global reset input , active high
        
        input   [31:0]  text_i; // text input 32bit
        output  [31:0]  text_o; // text output 32bit
        
        input   [3:0]   cmd_i;  // command input
        input           cmd_w_i;// command input write enable
        output  [4:0]   cmd_o;  // command output(status)

        /*
                cmd
                Busy S1 S0 Round W R

                bit4 bit3 bit2  bit1 bit0
                Busy S    Round W    R
                
                Busy:
                0       idle
                1       busy
                
                S:
                0       sha-384
                1       sha-512
                
                Round:
                0       first round
                1       internal round
                
                W:
                0       No-op
                1       write data
                
                R:
                0       No-op
                1       read data
                        
        */
        

        reg     [4:0]   cmd;
        wire    [4:0]   cmd_o;
        
        reg     [31:0]  text_o;
        
        reg     [6:0]   round;
        wire    [6:0]   round_plus_1;
        
        reg     [4:0]   read_counter;
        
        reg     [63:0]  H0,H1,H2,H3,H4,H5,H6,H7;
        reg     [63:0]  W0,W1,W2,W3,W4,W5,W6,W7,W8,W9,W10,W11,W12,W13,W14;
        reg     [63:0]  Wt,Kt;
        reg     [63:0]  A,B,C,D,E,F,G,H;

        reg             busy;
        
        assign cmd_o = cmd;
        always @ (posedge clk_i)
        begin
                if (rst_i)
                        cmd <= 'b0;
                else
                if (cmd_w_i)
                        cmd[3:0] <= cmd_i[3:0];         // busy bit can't write
                else
                begin
                        cmd[4] <= busy;                 // update busy bit
                        if (~busy)
                                cmd[1:0] <= 2'b00;      // hardware auto clean R/W bits
                end
        end
        
        wire [63:0] f1_EFG_64,f2_ABC_64,f3_A_64,f4_E_64,f5_W1_64,f6_W14_64,T1_64,T2_64;
        wire [63:0] W1_swap,W14_swap,Wt_64_swap;
        wire [63:0] next_Wt,next_E,next_A;
        wire [383:0] SHA384_result;
        wire [511:0] SHA512_result;
        
        assign f1_EFG_64 = (E & F) ^ (~E & G);

        assign f2_ABC_64 = (A & B) ^ (B & C) ^ (A & C);
        
        assign f3_A_64 = {A[27:0],A[63:28]} ^ {A[33:0],A[63:34]} ^ {A[38:0],A[63:39]};
        
        assign f4_E_64 = {E[13:0],E[63:14]} ^ {E[17:0],E[63:18]} ^ {E[40:0],E[63:41]};
        
        assign W1_swap = {W1[31:0],W1[63:32]};
        assign f5_W1_64 = {W1_swap[0],W1_swap[63:1]} ^ {W1_swap[7:0],W1_swap[63:8]} ^ {7'b000_0000,W1_swap[63:7]};
        
        assign W14_swap = {W14[31:0],W14[63:32]};
        assign f6_W14_64 = {W14_swap[18:0],W14_swap[63:19]} ^ {W14_swap[60:0],W14_swap[63:61]} ^ {6'b00_0000,W14_swap[63:6]};
        
        assign Wt_64_swap = f6_W14_64 + {W9[31:0],W9[63:32]} + f5_W1_64 + {W0[31:0],W0[63:32]};
        
        assign T1_64 = H[63:0] + f4_E_64 + f1_EFG_64 + Kt[63:0] + {Wt[31:0],Wt[63:32]};
        
        assign T2_64 = f3_A_64 + f2_ABC_64;
        
        assign next_Wt = {Wt_64_swap[31:0],Wt_64_swap[63:32]};
        assign next_E = D[63:0] + T1_64;
        assign next_A = T1_64 + T2_64;
        
        
        assign SHA384_result = {A,B,C,D,E,F};
        assign SHA512_result = {A,B,C,D,E,F,G,H};
        
        assign round_plus_1 = round + 1;
        
        //------------------------------------------------------------------    
        // SHA round
        //------------------------------------------------------------------
        always @(posedge clk_i)
        begin
                if (rst_i)
                begin
                        round <= 'd0;
                        busy <= 'b0;

                        W0  <= 'b0;
                        W1  <= 'b0;
                        W2  <= 'b0;
                        W3  <= 'b0;
                        W4  <= 'b0;
                        W5  <= 'b0;
                        W6  <= 'b0;
                        W7  <= 'b0;
                        W8  <= 'b0;
                        W9  <= 'b0;
                        W10 <= 'b0;
                        W11 <= 'b0;
                        W12 <= 'b0;
                        W13 <= 'b0;
                        W14 <= 'b0;
                        Wt  <= 'b0;
                        
                        A <= 'b0;
                        B <= 'b0;
                        C <= 'b0;
                        D <= 'b0;
                        E <= 'b0;
                        F <= 'b0;
                        G <= 'b0;
                        H <= 'b0;

                        H0 <= 'b0;
                        H1 <= 'b0;
                        H2 <= 'b0;
                        H3 <= 'b0;
                        H4 <= 'b0;
                        H5 <= 'b0;
                        H6 <= 'b0;
                        H7 <= 'b0;
                end
                else
                begin
                        case (round)
                        
                        'd0:
                                begin
                                        if (cmd[1])
                                        begin
                                                W0[31:0] <= text_i;
                                                Wt[31:0] <= text_i;
                                                busy <= 'b1;
                                                round <= round_plus_1;
                                                
                                                case (cmd[3:2])
                                                        2'b00:  // sha-384 first message
                                                                begin
                                                                        A <= `SHA384_H0;
                                                                        B <= `SHA384_H1;
                                                                        C <= `SHA384_H2;
                                                                        D <= `SHA384_H3;
                                                                        E <= `SHA384_H4;
                                                                        F <= `SHA384_H5;
                                                                        G <= `SHA384_H6;
                                                                        H <= `SHA384_H7;

                                                                        H0 <= `SHA384_H0;
                                                                        H1 <= `SHA384_H1;
                                                                        H2 <= `SHA384_H2;
                                                                        H3 <= `SHA384_H3;
                                                                        H4 <= `SHA384_H4;
                                                                        H5 <= `SHA384_H5;
                                                                        H6 <= `SHA384_H6;
                                                                        H7 <= `SHA384_H7;
                                                                end
                                                        2'b01:  // sha-384 internal message
                                                                begin
                                                                        H0 <= A;
                                                                        H1 <= B;
                                                                        H2 <= C;
                                                                        H3 <= D;
                                                                        H4 <= E;
                                                                        H5 <= F;
                                                                        H6 <= G;
                                                                        H7 <= H;
                                                                end
                                                        2'b10:  // sha-512 first message
                                                                begin
                                                                        A <= `SHA512_H0;
                                                                        B <= `SHA512_H1;
                                                                        C <= `SHA512_H2;
                                                                        D <= `SHA512_H3;
                                                                        E <= `SHA512_H4;
                                                                        F <= `SHA512_H5;
                                                                        G <= `SHA512_H6;
                                                                        H <= `SHA512_H7;

                                                                        H0 <= `SHA512_H0;
                                                                        H1 <= `SHA512_H1;
                                                                        H2 <= `SHA512_H2;
                                                                        H3 <= `SHA512_H3;
                                                                        H4 <= `SHA512_H4;
                                                                        H5 <= `SHA512_H5;
                                                                        H6 <= `SHA512_H6;
                                                                        H7 <= `SHA512_H7;
                                                                end
                                                        2'b11:  // sha-512 internal message
                                                                begin
                                                                        H0 <= A;
                                                                        H1 <= B;
                                                                        H2 <= C;
                                                                        H3 <= D;
                                                                        H4 <= E;
                                                                        H5 <= F;
                                                                        H6 <= G;
                                                                        H7 <= H;
                                                                end
                                                endcase
                                        end
                                        else
                                        begin   // IDLE
                                                round <= 'd0;
                                        end
                                end
                        'd1:
                                begin
                                        W0[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd2:
                                begin
                                        W1[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd3:
                                begin
                                        W1[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd4:
                                begin
                                        W2[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd5:
                                begin
                                        W2[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd6:
                                begin
                                        W3[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd7:
                                begin
                                        W3[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd8:
                                begin
                                        W4[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd9:
                                begin
                                        W4[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd10:
                                begin
                                        W5[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd11:
                                begin
                                        W5[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd12:
                                begin
                                        W6[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd13:
                                begin
                                        W6[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd14:
                                begin
                                        W7[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd15:
                                begin
                                        W7[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd16:
                                begin
                                        W8[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd17:
                                begin
                                        W8[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd18:
                                begin
                                        W9[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd19:
                                begin
                                        W9[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd20:
                                begin
                                        W10[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd21:
                                begin
                                        W10[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd22:
                                begin
                                        W11[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd23:
                                begin
                                        W11[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd24:
                                begin
                                        W12[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd25:
                                begin
                                        W12[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd26:
                                begin
                                        W13[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd27:
                                begin
                                        W13[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd28:
                                begin
                                        W14[31:0] <= text_i;
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd29:
                                begin
                                        W14[63:32] <= text_i;
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd30:
                                begin
                                        Wt[31:0] <= text_i;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;

                                        round <= round_plus_1;
                                end
                        'd31:
                                begin
                                        Wt[63:32] <= text_i;
                                        round <= round_plus_1;
                                end
                        'd32,
                        'd33,
                        'd34,
                        'd35,
                        'd36,
                        'd37,
                        'd38,
                        'd39,
                        'd40,
                        'd41,
                        'd42,
                        'd43,
                        'd44,
                        'd45,
                        'd46,
                        'd47,
                        'd48,
                        'd49,
                        'd50,
                        'd51,
                        'd52,
                        'd53,
                        'd54,
                        'd55,
                        'd56,
                        'd57,
                        'd58,
                        'd59,
                        'd60,
                        'd61,
                        'd62,
                        'd63,
                        'd64,
                        'd65,
                        'd66,
                        'd67,
                        'd68,
                        'd69,
                        'd70,
                        'd71,
                        'd72,
                        'd73,
                        'd74,
                        'd75,
                        'd76,
                        'd77,
                        'd78,
                        'd79,
                        'd80,
                        'd81,
                        'd82,
                        'd83,
                        'd84,
                        'd85,
                        'd86,
                        'd87,
                        'd88,
                        'd89,
                        'd90,
                        'd91,
                        'd92,
                        'd93,
                        'd94,
                        'd95:
                                begin
                                        W0  <= W1;
                                        W1  <= W2;
                                        W2  <= W3;
                                        W3  <= W4;
                                        W4  <= W5;
                                        W5  <= W6;
                                        W6  <= W7;
                                        W7  <= W8;
                                        W8  <= W9;
                                        W9  <= W10;
                                        W10 <= W11;
                                        W11 <= W12;
                                        W12 <= W13;
                                        W13 <= W14;
                                        W14 <= Wt;
                                        Wt  <= next_Wt;
                                        
                                        H <= G;
                                        G <= F;
                                        F <= E;
                                        E <= next_E;
                                        D <= C;
                                        C <= B;
                                        B <= A;
                                        A <= next_A;
                                                
                                        round <= round_plus_1;
                                end
                        'd96:
                                begin
                                        A <= next_A + H0;
                                        B <= A + H1;
                                        C <= B + H2;
                                        D <= C + H3;
                                        E <= next_E + H4;
                                        F <= E + H5;
                                        G <= F + H6;
                                        H <= G + H7;
                                        round <= 'd0;
                                        busy <= 'b0;
                                end
                        default:
                                begin
                                        round <= 'd0;
                                        busy <= 'b0;
                                end
                        endcase
                end     
        end 
        
        
        //------------------------------------------------------------------    
        // Kt generator
        //------------------------------------------------------------------    
        always @ (posedge clk_i)
        begin
                if (rst_i)
                begin
                        Kt <= 'b0;
                end
                else
                begin
                        case (round)
                                'd00:   Kt <= `K00;
                                'd01:   Kt <= `K00;
                                'd02:   Kt <= `K01;
                                'd03:   Kt <= `K01;
                                'd04:   Kt <= `K02;
                                'd05:   Kt <= `K02;
                                'd06:   Kt <= `K03;
                                'd07:   Kt <= `K03;
                                'd08:   Kt <= `K04;
                                'd09:   Kt <= `K04;
                                'd10:   Kt <= `K05;
                                'd11:   Kt <= `K05;
                                'd12:   Kt <= `K06;
                                'd13:   Kt <= `K06;
                                'd14:   Kt <= `K07;
                                'd15:   Kt <= `K07;
                                'd16:   Kt <= `K08;
                                'd17:   Kt <= `K08;
                                'd18:   Kt <= `K09;
                                'd19:   Kt <= `K09;
                                'd20:   Kt <= `K10;
                                'd21:   Kt <= `K10;
                                'd22:   Kt <= `K11;
                                'd23:   Kt <= `K11;
                                'd24:   Kt <= `K12;
                                'd25:   Kt <= `K12;
                                'd26:   Kt <= `K13;
                                'd27:   Kt <= `K13;
                                'd28:   Kt <= `K14;
                                'd29:   Kt <= `K14;
                                'd30:   Kt <= `K15;
                                'd31:   Kt <= `K15;
                                'd32:   Kt <= `K16;
                                'd33:   Kt <= `K17;
                                'd34:   Kt <= `K18;
                                'd35:   Kt <= `K19;
                                'd36:   Kt <= `K20;
                                'd37:   Kt <= `K21;
                                'd38:   Kt <= `K22;
                                'd39:   Kt <= `K23;
                                'd40:   Kt <= `K24;
                                'd41:   Kt <= `K25;
                                'd42:   Kt <= `K26;
                                'd43:   Kt <= `K27;
                                'd44:   Kt <= `K28;
                                'd45:   Kt <= `K29;
                                'd46:   Kt <= `K30;
                                'd47:   Kt <= `K31;
                                'd48:   Kt <= `K32;
                                'd49:   Kt <= `K33;
                                'd50:   Kt <= `K34;
                                'd51:   Kt <= `K35;
                                'd52:   Kt <= `K36;
                                'd53:   Kt <= `K37;
                                'd54:   Kt <= `K38;
                                'd55:   Kt <= `K39;
                                'd56:   Kt <= `K40;
                                'd57:   Kt <= `K41;
                                'd58:   Kt <= `K42;
                                'd59:   Kt <= `K43;
                                'd60:   Kt <= `K44;
                                'd61:   Kt <= `K45;
                                'd62:   Kt <= `K46;
                                'd63:   Kt <= `K47;
                                'd64:   Kt <= `K48;
                                'd65:   Kt <= `K49;
                                'd66:   Kt <= `K50;
                                'd67:   Kt <= `K51;
                                'd68:   Kt <= `K52;
                                'd69:   Kt <= `K53;
                                'd70:   Kt <= `K54;
                                'd71:   Kt <= `K55;
                                'd72:   Kt <= `K56;
                                'd73:   Kt <= `K57;
                                'd74:   Kt <= `K58;
                                'd75:   Kt <= `K59;
                                'd76:   Kt <= `K60;
                                'd77:   Kt <= `K61;
                                'd78:   Kt <= `K62;
                                'd79:   Kt <= `K63;
                                'd80:   Kt <= `K64;
                                'd81:   Kt <= `K65;
                                'd82:   Kt <= `K66;
                                'd83:   Kt <= `K67;
                                'd84:   Kt <= `K68;
                                'd85:   Kt <= `K69;
                                'd86:   Kt <= `K70;
                                'd87:   Kt <= `K71;
                                'd88:   Kt <= `K72;
                                'd89:   Kt <= `K73;
                                'd90:   Kt <= `K74;
                                'd91:   Kt <= `K75;
                                'd92:   Kt <= `K76;
                                'd93:   Kt <= `K77;
                                'd94:   Kt <= `K78;
                                'd95:   Kt <= `K79;
                                default:Kt <= 'd0;
                        endcase
                end
        end

        //------------------------------------------------------------------    
        // read result 
        //------------------------------------------------------------------    
        always @ (posedge clk_i)
        begin
                if (rst_i)
                begin
                        text_o <= 'b0;
                        read_counter <= 'b0;
                end
                else
                begin
                        if (cmd[0])
                        begin
                                case (cmd[3])
                                        1'b0:   read_counter <= 'd11;   // sha-384      384/32=12
                                        1'b1:   read_counter <= 'd15;   // sha-512      512/32=16
                                endcase
                        end
                        else
                        begin
                        if (~busy)
                        begin
                                case (cmd[3])
                                        1'b0:
                                                begin
                                                        case (read_counter)
                                                                'd11:   text_o <= SHA384_result[12*32-1:11*32];
                                                                'd10:   text_o <= SHA384_result[11*32-1:10*32];
                                                                'd09:   text_o <= SHA384_result[10*32-1:09*32];
                                                                'd08:   text_o <= SHA384_result[09*32-1:08*32];
                                                                'd07:   text_o <= SHA384_result[08*32-1:07*32];
                                                                'd06:   text_o <= SHA384_result[07*32-1:06*32];
                                                                'd05:   text_o <= SHA384_result[06*32-1:05*32];
                                                                'd04:   text_o <= SHA384_result[05*32-1:04*32];
                                                                'd03:   text_o <= SHA384_result[04*32-1:03*32];
                                                                'd02:   text_o <= SHA384_result[03*32-1:02*32];
                                                                'd01:   text_o <= SHA384_result[02*32-1:01*32];
                                                                'd00:   text_o <= SHA384_result[01*32-1:00*32];
                                                                default:text_o <= 'b0;
                                                        endcase
                                                end
                                        1'b1:
                                                begin
                                                        case (read_counter)
                                                                'd15:   text_o <= SHA512_result[16*32-1:15*32];
                                                                'd14:   text_o <= SHA512_result[15*32-1:14*32];
                                                                'd13:   text_o <= SHA512_result[14*32-1:13*32];
                                                                'd12:   text_o <= SHA512_result[13*32-1:12*32];
                                                                'd11:   text_o <= SHA512_result[12*32-1:11*32];
                                                                'd10:   text_o <= SHA512_result[11*32-1:10*32];
                                                                'd09:   text_o <= SHA512_result[10*32-1:09*32];
                                                                'd08:   text_o <= SHA512_result[09*32-1:08*32];
                                                                'd07:   text_o <= SHA512_result[08*32-1:07*32];
                                                                'd06:   text_o <= SHA512_result[07*32-1:06*32];
                                                                'd05:   text_o <= SHA512_result[06*32-1:05*32];
                                                                'd04:   text_o <= SHA512_result[05*32-1:04*32];
                                                                'd03:   text_o <= SHA512_result[04*32-1:03*32];
                                                                'd02:   text_o <= SHA512_result[03*32-1:02*32];
                                                                'd01:   text_o <= SHA512_result[02*32-1:01*32];
                                                                'd00:   text_o <= SHA512_result[01*32-1:00*32];
                                                                default:text_o <= 'b0;
                                                        endcase
                                                end
                                endcase
                                if (|read_counter)
                                        read_counter <= read_counter - 'd1;
                        end
                        else
                        begin
                                text_o <= 'b0;
                        end
                        end
                end
        end
        
endmodule
 
