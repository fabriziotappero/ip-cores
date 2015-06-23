// Workview VERILOG Netlister - V6.2
// Wednesday February 5, 2003 - 12:28 pm
// Design name: 1
// Options    : -b -locAll -upcAll -n -v2 -oprocessor.v -mixedcase
// Levels     : xilinx

module REG5 (CLK, EN, I, O, RES);
  FDRE X1I1 (.C(CLK), .CE(EN), .D(I[4]), .Q(O[4]), .R(RES));
  FDRE X1I2 (.C(CLK), .CE(EN), .D(I[3]), .Q(O[3]), .R(RES));
  FDRE X1I3 (.C(CLK), .CE(EN), .D(I[2]), .Q(O[2]), .R(RES));
  FDRE X1I4 (.C(CLK), .CE(EN), .D(I[1]), .Q(O[1]), .R(RES));
  FDRE X1I5 (.C(CLK), .CE(EN), .D(I[0]), .Q(O[0]), .R(RES));

endmodule  // REG5

module M2_1 (.D0(D[0]), .D1(D[1]), O, S0);
  output O;
  input S0;
  input [1:0] D;
  wire [15:0] O, I, Q, D;
  wire [7:0] DPO, SPO;
  wire M0, M1;
  AND2B1 X1I7 (.I0(S0), .I1(D[0]), .O(M0));
  OR2 X1I8 (.I0(M1), .I1(M0), .O(O));
  AND2 X1I9 (.I0(D[1]), .I1(S0), .O(M1));

endmodule  // M2_1

module M2_1X5 (A, B, O, SB);
  M2_1 X1I60 (.D0(A[4]), .D1(B[4]), .O(O[4]), .S0(SB));
  M2_1 X1I61 (.D0(A[3]), .D1(B[3]), .O(O[3]), .S0(SB));
  M2_1 X1I62 (.D0(A[2]), .D1(B[2]), .O(O[2]), .S0(SB));
  M2_1 X1I63 (.D0(A[1]), .D1(B[1]), .O(O[1]), .S0(SB));
  M2_1 X1I64 (.D0(A[0]), .D1(B[0]), .O(O[0]), .S0(SB));

endmodule  // M2_1X5

module XOR32_32_32 (A, B, O);
  XNOR2 X1I107 (.I0(B[16]), .I1(A[16]), .O(O[16]));
  XNOR2 X1I108 (.I0(B[17]), .I1(A[17]), .O(O[17]));
  XNOR2 X1I109 (.I0(B[19]), .I1(A[19]), .O(O[19]));
  XNOR2 X1I110 (.I0(B[18]), .I1(A[18]), .O(O[18]));
  XNOR2 X1I111 (.I0(B[22]), .I1(A[22]), .O(O[22]));
  XNOR2 X1I112 (.I0(B[23]), .I1(A[23]), .O(O[23]));
  XNOR2 X1I113 (.I0(B[21]), .I1(A[21]), .O(O[21]));
  XNOR2 X1I114 (.I0(B[20]), .I1(A[20]), .O(O[20]));
  XNOR2 X1I123 (.I0(B[8]), .I1(A[8]), .O(O[8]));
  XNOR2 X1I124 (.I0(B[9]), .I1(A[9]), .O(O[9]));
  XNOR2 X1I125 (.I0(B[11]), .I1(A[11]), .O(O[11]));
  XNOR2 X1I126 (.I0(B[10]), .I1(A[10]), .O(O[10]));
  XNOR2 X1I127 (.I0(B[14]), .I1(A[14]), .O(O[14]));
  XNOR2 X1I128 (.I0(B[15]), .I1(A[15]), .O(O[15]));
  XNOR2 X1I129 (.I0(B[13]), .I1(A[13]), .O(O[13]));
  XNOR2 X1I130 (.I0(B[12]), .I1(A[12]), .O(O[12]));
  XNOR2 X1I139 (.I0(B[0]), .I1(A[0]), .O(O[0]));
  XNOR2 X1I140 (.I0(B[1]), .I1(A[1]), .O(O[1]));
  XNOR2 X1I141 (.I0(B[3]), .I1(A[3]), .O(O[3]));
  XNOR2 X1I142 (.I0(B[2]), .I1(A[2]), .O(O[2]));
  XNOR2 X1I143 (.I0(B[6]), .I1(A[6]), .O(O[6]));
  XNOR2 X1I144 (.I0(B[7]), .I1(A[7]), .O(O[7]));
  XNOR2 X1I145 (.I0(B[5]), .I1(A[5]), .O(O[5]));
  XNOR2 X1I146 (.I0(B[4]), .I1(A[4]), .O(O[4]));
  XNOR2 X1I91 (.I0(B[24]), .I1(A[24]), .O(O[24]));
  XNOR2 X1I92 (.I0(B[25]), .I1(A[25]), .O(O[25]));
  XNOR2 X1I93 (.I0(B[27]), .I1(A[27]), .O(O[27]));
  XNOR2 X1I94 (.I0(B[26]), .I1(A[26]), .O(O[26]));
  XNOR2 X1I95 (.I0(B[30]), .I1(A[30]), .O(O[30]));
  XNOR2 X1I96 (.I0(B[31]), .I1(A[31]), .O(O[31]));
  XNOR2 X1I97 (.I0(B[29]), .I1(A[29]), .O(O[29]));
  XNOR2 X1I98 (.I0(B[28]), .I1(A[28]), .O(O[28]));

endmodule  // XOR32_32_32

module AND16 (I0, I1, I10, I11, I12, I13, I14, I15, I2, I3, I4, I5, I6, I7, 
    I8, I9, O);
  output O;
  input I9, I8, I7, I6, I5, I4, I3, I2, I15, I14, I13, I12, I11, I10, I1, I0
    ;
  wire S0, S1, S2, S3;
  AND4 X1I110 (.I0(I0), .I1(I1), .I2(I2), .I3(I3), .O(S0));
  AND4 X1I127 (.I0(I4), .I1(I5), .I2(I6), .I3(I7), .O(S1));
  AND4 X1I151 (.I0(I8), .I1(I9), .I2(I10), .I3(I11), .O(S2));
  AND4 X1I161 (.I0(I12), .I1(I13), .I2(I14), .I3(I15), .O(S3));
  AND4 X1I178 (.I0(S0), .I1(S1), .I2(S2), .I3(S3), .O(O));

endmodule  // AND16

module AND32 (I, O);
  wire X1N4, X1N5;
  AND16 X1I1 (.I0(I[16]), .I1(I[17]), .I10(I[26]), .I11(I[27]), .I12(I[28])
    , .I13(I[29]), .I14(I[30]), .I15(I[31]), .I2(I[18]), .I3(I[19]), .I4
    (I[20]), .I5(I[21]), .I6(I[22]), .I7(I[23]), .I8(I[24]), .I9(I[25]), .O
    (X1N4));
  AND16 X1I2 (.I0(I[15]), .I1(I[14]), .I10(I[5]), .I11(I[4]), .I12(I[3]), 
    .I13(I[2]), .I14(I[1]), .I15(I[0]), .I2(I[13]), .I3(I[12]), .I4(I[11]), 
    .I5(I[10]), .I6(I[9]), .I7(I[8]), .I8(I[7]), .I9(I[6]), .O(X1N5));
  AND2 X1I3 (.I0(X1N5), .I1(X1N4), .O(O));

endmodule  // AND32

module MUX2_1X32 (A, B, SB, S);
  output [31:0] S;
  input [31:0] B;
  input [31:0] A;
  M2_1 X1I100 (.D0(A[17]), .D1(B[17]), .O(S[17]), .S0(SB));
  M2_1 X1I101 (.D0(A[21]), .D1(B[21]), .O(S[21]), .S0(SB));
  M2_1 X1I102 (.D0(A[20]), .D1(B[20]), .O(S[20]), .S0(SB));
  M2_1 X1I103 (.D0(A[22]), .D1(B[22]), .O(S[22]), .S0(SB));
  M2_1 X1I104 (.D0(A[23]), .D1(B[23]), .O(S[23]), .S0(SB));
  M2_1 X1I105 (.D0(A[15]), .D1(B[15]), .O(S[15]), .S0(SB));
  M2_1 X1I106 (.D0(A[14]), .D1(B[14]), .O(S[14]), .S0(SB));
  M2_1 X1I107 (.D0(A[12]), .D1(B[12]), .O(S[12]), .S0(SB));
  M2_1 X1I108 (.D0(A[13]), .D1(B[13]), .O(S[13]), .S0(SB));
  M2_1 X1I109 (.D0(A[9]), .D1(B[9]), .O(S[9]), .S0(SB));
  M2_1 X1I110 (.D0(A[8]), .D1(B[8]), .O(S[8]), .S0(SB));
  M2_1 X1I111 (.D0(A[10]), .D1(B[10]), .O(S[10]), .S0(SB));
  M2_1 X1I112 (.D0(A[11]), .D1(B[11]), .O(S[11]), .S0(SB));
  M2_1 X1I117 (.D0(A[7]), .D1(B[7]), .O(S[7]), .S0(SB));
  M2_1 X1I118 (.D0(A[6]), .D1(B[6]), .O(S[6]), .S0(SB));
  M2_1 X1I119 (.D0(A[4]), .D1(B[4]), .O(S[4]), .S0(SB));
  M2_1 X1I12 (.D0(A[31]), .D1(B[31]), .O(S[31]), .S0(SB));
  M2_1 X1I120 (.D0(A[5]), .D1(B[5]), .O(S[5]), .S0(SB));
  M2_1 X1I121 (.D0(A[1]), .D1(B[1]), .O(S[1]), .S0(SB));
  M2_1 X1I122 (.D0(A[0]), .D1(B[0]), .O(S[0]), .S0(SB));
  M2_1 X1I123 (.D0(A[2]), .D1(B[2]), .O(S[2]), .S0(SB));
  M2_1 X1I124 (.D0(A[3]), .D1(B[3]), .O(S[3]), .S0(SB));
  M2_1 X1I13 (.D0(A[30]), .D1(B[30]), .O(S[30]), .S0(SB));
  M2_1 X1I14 (.D0(A[28]), .D1(B[28]), .O(S[28]), .S0(SB));
  M2_1 X1I15 (.D0(A[29]), .D1(B[29]), .O(S[29]), .S0(SB));
  M2_1 X1I16 (.D0(A[25]), .D1(B[25]), .O(S[25]), .S0(SB));
  M2_1 X1I17 (.D0(A[24]), .D1(B[24]), .O(S[24]), .S0(SB));
  M2_1 X1I18 (.D0(A[26]), .D1(B[26]), .O(S[26]), .S0(SB));
  M2_1 X1I19 (.D0(A[27]), .D1(B[27]), .O(S[27]), .S0(SB));
  M2_1 X1I97 (.D0(A[19]), .D1(B[19]), .O(S[19]), .S0(SB));
  M2_1 X1I98 (.D0(A[18]), .D1(B[18]), .O(S[18]), .S0(SB));
  M2_1 X1I99 (.D0(A[16]), .D1(B[16]), .O(S[16]), .S0(SB));

endmodule  // MUX2_1X32

module MU_TITLE;

endmodule  // MU_TITLE

module CLOCK (CLOCK);
  wire X1N5;
  IPAD X1I3 (.IPAD(X1N5));
  BUFG X1I4 (.I(X1N5), .O(CLOCK));
  MU_TITLE X1I9 ();

endmodule  // CLOCK

module CLOCK (CLK1, CLK2, CLK_50MHZ);
  wire X1N5;
  STARTUP_VIRTEX X1I11 (.CLK(CLK1));
  BUFG X1I53 (.I(X1N5), .O(CLK_50MHZ));
  CLOCK X1I71 (.CLOCK(X1N5));
  BUF X1I72 (.I(X1N5), .O(CLK1));
  MU_TITLE X1I9 ();

// WARNING - Component X1I11 has unconnected pins: 2 input, 0 output, 0 inout.
endmodule  // CLOCK

module STARTUPRAM (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), D
    , O, WCLK, WE);
  output [31:0] O;
  input WE, WCLK;
  input [4:0] A;
  input [31:0] D;
  wire [4:0] A;
  RAM32X1S X1I100 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[25]), .O(O[25]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I101 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[27]), .O(O[27]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I102 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[31]), .O(O[31]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I103 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[30]), .O(O[30]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I104 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[29]), .O(O[29]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I105 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[28]), .O(O[28]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I106 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[26]), .O(O[26]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I17 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[0]), .O(O[0]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I18 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[1]), .O(O[1]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I19 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[3]), .O(O[3]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I20 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[7]), .O(O[7]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I21 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[6]), .O(O[6]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I22 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[5]), .O(O[5]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I23 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[4]), .O(O[4]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I27 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[2]), .O(O[2]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I37 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[10]), .O(O[10]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I38 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[12]), .O(O[12]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I39 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[13]), .O(O[13]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I40 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[14]), .O(O[14]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I41 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[15]), .O(O[15]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I42 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[11]), .O(O[11]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I43 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[9]), .O(O[9]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I44 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[8]), .O(O[8]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I91 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[18]), .O(O[18]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I92 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[20]), .O(O[20]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I93 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[21]), .O(O[21]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I94 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[22]), .O(O[22]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I95 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[23]), .O(O[23]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I96 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[19]), .O(O[19]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I97 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[17]), .O(O[17]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I98 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[16]), .O(O[16]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I99 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D
    (D[24]), .O(O[24]), .WCLK(WCLK), .WE(WE));

endmodule  // STARTUPRAM

module FPGA_FLASHDISP (AIN, A, BAR0, BAR1, BAR2, BAR3, BAR4, BAR5, BAR6, 
    BAR7, BAR8, DIN, .DIP1(DIP[1]), .DIP2(DIP[2]), .DIP3(DIP[3]), .DIP4
    (DIP[4]), .DIP5(DIP[5]), .DIP6(DIP[6]), .DIP7(DIP[7]), .DIP8(DIP[8]), 
    DISPNFLASH, DOE, DOUT, FLASHRDY, 
    \LEDLA,LEDLB,LEDLC,LEDLD,LEDLE,LEDLF,LEDLG , 
    .LEDLA,LEDLB,LEDLC,LEDLD,LEDLE,LEDLF,LEDLG
    (\LEDLA,LEDLB,LEDLC,LEDLD,LEDLE,LEDLF,LEDLG ), 
    \LEDRA,LEDRB,LEDRC,LEDRD,LEDRE,LEDRF,LEDRG , 
    .LEDRA,LEDRB,LEDRC,LEDRD,LEDRE,LEDRF,LEDRG
    (\LEDRA,LEDRB,LEDRC,LEDRD,LEDRE,LEDRF,LEDRG ), NFLASHCE, NFLASHCEIN, 
    NFLASHOE, NFLASHOEIN, NFLASHWE, NFLASHWEIN, NFPGAOE);
  wire [8:1] DIP;
  wire X1N420, X1N114, X1N403, X1N106, X1N404, X1N107, X1N270, X1N126, 
    X1N108, X1N271, X1N244, X1N127, X1N118, X1N272, X1N119, X1N408, X1N273, 
    X1N427, X1N409, X1N274, X1N247, X1N275, X1N266, X1N276, X1N277, X1N268, 
    X1N278, X1N269, X1N279, LEDLA, LEDLB, LEDLC, LEDLD, LEDLE, LEDLF, LEDRA
    , LEDLG, LEDRB, LEDRC, LEDRD, X1N21, LEDRE, LEDRF, X1N50, LEDRG, X1N61, 
    X1N43, X1N16, X1N62, X1N44, X1N35, X1N36, X1N18, X1N55, X1N28, X1N56, 
    X1N29, X1N76, X1N67, X1N49, X1N86, X1N77, X1N68, X1N96, X1N87, X1N78, 
    X1N69, X1N97, X1N88, X1N79, X1N98, X1N89, X1N99;
  M2_1 X1I100 (.D0(DOUT[1]), .D1(LEDLC), .O(X1N99), .S0(DISPNFLASH));
  OBUFT X1I101 (.I(X1N99), .O(X1N98), .T(X1N247));
  IBUF X1I102 (.I(X1N98), .O(DIN[1]));
  IBUF X1I103 (.I(X1N107), .O(DIN[0]));
  OBUFT X1I104 (.I(X1N106), .O(X1N107), .T(X1N247));
  M2_1 X1I105 (.D0(DOUT[0]), .D1(LEDLD), .O(X1N106), .S0(DISPNFLASH));
  M2_1 X1I113 (.D0(A[4]), .D1(LEDRF), .O(X1N114), .S0(DISPNFLASH));
  M2_1 X1I117 (.D0(A[2]), .D1(LEDRG), .O(X1N118), .S0(DISPNFLASH));
  M2_1 X1I120 (.D0(A[3]), .D1(LEDRB), .O(X1N119), .S0(DISPNFLASH));
  M2_1 X1I125 (.D0(A[1]), .D1(LEDRE), .O(X1N126), .S0(DISPNFLASH));
  M2_1 X1I128 (.D0(A[0]), .D1(LEDRC), .O(X1N127), .S0(DISPNFLASH));
  M2_1 X1I143 (.D0(A[5]), .D1(LEDRA), .O(X1N108), .S0(DISPNFLASH));
  IOPAD X1I167 (.IOPAD(X1N279));
  IOPAD X1I168 (.IOPAD(X1N278));
  IOPAD X1I169 (.IOPAD(X1N276));
  IBUF X1I17 (.I(X1N16), .O(FLASHRDY));
  IOPAD X1I170 (.IOPAD(X1N277));
  IOPAD X1I171 (.IOPAD(X1N275));
  IOPAD X1I172 (.IOPAD(X1N274));
  IOPAD X1I173 (.IOPAD(X1N107));
  IOPAD X1I174 (.IOPAD(X1N98));
  IOPAD X1I175 (.IOPAD(X1N88));
  IOPAD X1I176 (.IOPAD(X1N97));
  IOPAD X1I177 (.IOPAD(X1N68));
  IOPAD X1I178 (.IOPAD(X1N77));
  IOPAD X1I179 (.IOPAD(X1N87));
  IOPAD X1I180 (.IOPAD(X1N78));
  IOPAD X1I195 (.IOPAD(X1N50));
  IOPAD X1I196 (.IOPAD(X1N55));
  IOPAD X1I197 (.IOPAD(X1N49));
  IOPAD X1I198 (.IOPAD(X1N44));
  IOPAD X1I199 (.IOPAD(X1N61));
  IOPAD X1I200 (.IOPAD(X1N56));
  IOPAD X1I201 (.IOPAD(X1N62));
  IOPAD X1I202 (.IOPAD(X1N67));
  M2_1 X1I203 (.D0(A[11]), .D1(BAR5), .O(X1N35), .S0(DISPNFLASH));
  IOPAD X1I216 (.IOPAD(X1N273));
  IOPAD X1I217 (.IOPAD(X1N272));
  IOPAD X1I218 (.IOPAD(X1N271));
  IOPAD X1I219 (.IOPAD(X1N270));
  M2_1 X1I22 (.D0(A[7]), .D1(BAR1), .O(X1N21), .S0(DISPNFLASH));
  IOPAD X1I220 (.IOPAD(X1N269));
  IOPAD X1I221 (.IOPAD(X1N268));
  IOPAD X1I222 (.IOPAD(X1N266));
  IPAD X1I223 (.IPAD(X1N16));
  M2_1 X1I226 (.D0(A[12]), .D1(BAR6), .O(X1N18), .S0(DISPNFLASH));
  AND2B1 X1I243 (.I0(DISPNFLASH), .I1(DOE), .O(X1N427));
  OBUFT X1I248 (.I(X1N18), .O(X1N266), .T(NFPGAOE));
  OBUFT X1I249 (.I(X1N35), .O(X1N268), .T(NFPGAOE));
  OBUFT X1I250 (.I(X1N29), .O(X1N269), .T(NFPGAOE));
  OBUFT X1I251 (.I(X1N36), .O(X1N270), .T(NFPGAOE));
  OBUFT X1I252 (.I(X1N43), .O(X1N271), .T(NFPGAOE));
  OBUFT X1I253 (.I(X1N21), .O(X1N272), .T(NFPGAOE));
  OBUFT X1I254 (.I(X1N28), .O(X1N273), .T(NFPGAOE));
  M2_1 X1I27 (.D0(A[6]), .D1(BAR0), .O(X1N28), .S0(DISPNFLASH));
  IBUF X1I297 (.I(X1N266), .O(AIN[12]));
  M2_1 X1I30 (.D0(A[10]), .D1(BAR4), .O(X1N29), .S0(DISPNFLASH));
  IBUF X1I303 (.I(X1N268), .O(AIN[11]));
  IBUF X1I306 (.I(X1N269), .O(AIN[10]));
  IBUF X1I310 (.I(X1N270), .O(AIN[9]));
  IBUF X1I313 (.I(X1N271), .O(AIN[8]));
  IBUF X1I316 (.I(X1N272), .O(AIN[7]));
  IBUF X1I319 (.I(X1N273), .O(AIN[6]));
  OR2 X1I331 (.I0(NFPGAOE), .I1(DISPNFLASH), .O(X1N244));
  OBUFT X1I343 (.I(X1N108), .O(X1N274), .T(NFPGAOE));
  OBUFT X1I344 (.I(X1N114), .O(X1N275), .T(NFPGAOE));
  OBUFT X1I345 (.I(X1N119), .O(X1N277), .T(NFPGAOE));
  OBUFT X1I346 (.I(X1N118), .O(X1N276), .T(NFPGAOE));
  OBUFT X1I347 (.I(X1N126), .O(X1N279), .T(NFPGAOE));
  OBUFT X1I348 (.I(X1N127), .O(X1N278), .T(NFPGAOE));
  IBUF X1I354 (.I(X1N275), .O(AIN[4]));
  IBUF X1I357 (.I(X1N274), .O(AIN[5]));
  IBUF X1I360 (.I(X1N277), .O(AIN[3]));
  IBUF X1I363 (.I(X1N276), .O(AIN[2]));
  IBUF X1I366 (.I(X1N279), .O(AIN[1]));
  IBUF X1I369 (.I(X1N278), .O(AIN[0]));
  M2_1 X1I37 (.D0(A[9]), .D1(BAR3), .O(X1N36), .S0(DISPNFLASH));
  IOPAD X1I394 (.IOPAD(X1N404));
  IBUF X1I395 (.I(X1N404), .O(NFLASHOEIN));
  OBUFT X1I396 (.I(X1N403), .O(X1N404), .T(NFPGAOE));
  M2_1 X1I397 (.D0(NFLASHOE), .D1(BAR7), .O(X1N403), .S0(DISPNFLASH));
  M2_1 X1I412 (.D0(NFLASHWE), .D1(BAR8), .O(X1N409), .S0(DISPNFLASH));
  OBUFT X1I413 (.I(X1N409), .O(X1N408), .T(NFPGAOE));
  IBUF X1I414 (.I(X1N408), .O(NFLASHWEIN));
  IOPAD X1I415 (.IOPAD(X1N408));
  IOPAD X1I417 (.IOPAD(X1N420));
  IBUF X1I418 (.I(X1N420), .O(NFLASHCEIN));
  OBUFT X1I419 (.I(NFLASHCE), .O(X1N420), .T(NFPGAOE));
  M2_1 X1I42 (.D0(A[8]), .D1(BAR2), .O(X1N43), .S0(DISPNFLASH));
  OR2 X1I426 (.I0(NFPGAOE), .I1(X1N427), .O(X1N247));
  BUF X1I431 (.I(DIP[8]), .O(AIN[20]));
  BUF X1I434 (.I(DIP[7]), .O(AIN[19]));
  BUF X1I437 (.I(DIP[6]), .O(AIN[18]));
  BUF X1I440 (.I(DIP[5]), .O(AIN[17]));
  BUF X1I443 (.I(DIP[4]), .O(AIN[16]));
  BUF X1I446 (.I(DIP[3]), .O(AIN[15]));
  BUF X1I449 (.I(DIP[2]), .O(AIN[14]));
  OBUFT X1I45 (.I(A[16]), .O(X1N44), .T(X1N244));
  BUF X1I454 (.I(DIP[1]), .O(AIN[13]));
  IBUF X1I46 (.I(X1N44), .O(DIP[4]));
  IBUF X1I47 (.I(X1N49), .O(DIP[3]));
  OBUFT X1I48 (.I(A[15]), .O(X1N49), .T(X1N244));
  OBUFT X1I51 (.I(A[13]), .O(X1N50), .T(X1N244));
  IBUF X1I52 (.I(X1N50), .O(DIP[1]));
  IBUF X1I53 (.I(X1N55), .O(DIP[2]));
  OBUFT X1I54 (.I(A[14]), .O(X1N55), .T(X1N244));
  OBUFT X1I57 (.I(A[18]), .O(X1N56), .T(X1N244));
  IBUF X1I58 (.I(X1N56), .O(DIP[6]));
  IBUF X1I59 (.I(X1N61), .O(DIP[5]));
  OBUFT X1I60 (.I(A[17]), .O(X1N61), .T(X1N244));
  OBUFT X1I63 (.I(A[19]), .O(X1N62), .T(X1N244));
  IBUF X1I64 (.I(X1N62), .O(DIP[7]));
  IBUF X1I65 (.I(X1N67), .O(DIP[8]));
  OBUFT X1I66 (.I(A[20]), .O(X1N67), .T(X1N244));
  M2_1 X1I70 (.D0(DOUT[4]), .D1(LEDLB), .O(X1N69), .S0(DISPNFLASH));
  OBUFT X1I71 (.I(X1N69), .O(X1N68), .T(X1N247));
  IBUF X1I72 (.I(X1N68), .O(DIN[4]));
  IBUF X1I73 (.I(X1N77), .O(DIN[5]));
  OBUFT X1I74 (.I(X1N76), .O(X1N77), .T(X1N247));
  M2_1 X1I75 (.D0(DOUT[5]), .D1(LEDLF), .O(X1N76), .S0(DISPNFLASH));
  M2_1 X1I80 (.D0(DOUT[7]), .D1(LEDRD), .O(X1N79), .S0(DISPNFLASH));
  OBUFT X1I81 (.I(X1N79), .O(X1N78), .T(X1N247));
  IBUF X1I82 (.I(X1N78), .O(DIN[7]));
  IBUF X1I83 (.I(X1N87), .O(DIN[6]));
  OBUFT X1I84 (.I(X1N86), .O(X1N87), .T(X1N247));
  M2_1 X1I85 (.D0(DOUT[6]), .D1(LEDLA), .O(X1N86), .S0(DISPNFLASH));
  M2_1 X1I90 (.D0(DOUT[2]), .D1(LEDLE), .O(X1N89), .S0(DISPNFLASH));
  OBUFT X1I91 (.I(X1N89), .O(X1N88), .T(X1N247));
  IBUF X1I92 (.I(X1N88), .O(DIN[2]));
  IBUF X1I93 (.I(X1N97), .O(DIN[3]));
  OBUFT X1I94 (.I(X1N96), .O(X1N97), .T(X1N247));
  M2_1 X1I95 (.D0(DOUT[3]), .D1(LEDLG), .O(X1N96), .S0(DISPNFLASH));

endmodule  // FPGA_FLASHDISP

module FD16RE (C, CE, D, Q, R);
  output [15:0] Q;
  input R, CE, C;
  input [15:0] D;
  wire [15:0] O, I, IO;
  wire [7:0] DPO, SPO;
  FDRE Q0 (.C(C), .CE(CE), .D(D[0]), .Q(Q[0]), .R(R));
  FDRE Q1 (.C(C), .CE(CE), .D(D[1]), .Q(Q[1]), .R(R));
  FDRE Q2 (.C(C), .CE(CE), .D(D[2]), .Q(Q[2]), .R(R));
  FDRE Q3 (.C(C), .CE(CE), .D(D[3]), .Q(Q[3]), .R(R));
  FDRE Q4 (.C(C), .CE(CE), .D(D[4]), .Q(Q[4]), .R(R));
  FDRE Q5 (.C(C), .CE(CE), .D(D[5]), .Q(Q[5]), .R(R));
  FDRE Q6 (.C(C), .CE(CE), .D(D[6]), .Q(Q[6]), .R(R));
  FDRE Q7 (.C(C), .CE(CE), .D(D[7]), .Q(Q[7]), .R(R));
  FDRE Q8 (.C(C), .CE(CE), .D(D[8]), .Q(Q[8]), .R(R));
  FDRE Q9 (.C(C), .CE(CE), .D(D[9]), .Q(Q[9]), .R(R));
  FDRE Q10 (.C(C), .CE(CE), .D(D[10]), .Q(Q[10]), .R(R));
  FDRE Q11 (.C(C), .CE(CE), .D(D[11]), .Q(Q[11]), .R(R));
  FDRE Q12 (.C(C), .CE(CE), .D(D[12]), .Q(Q[12]), .R(R));
  FDRE Q13 (.C(C), .CE(CE), .D(D[13]), .Q(Q[13]), .R(R));
  FDRE Q14 (.C(C), .CE(CE), .D(D[14]), .Q(Q[14]), .R(R));
  FDRE Q15 (.C(C), .CE(CE), .D(D[15]), .Q(Q[15]), .R(R));

endmodule  // FD16RE

module REG32R (CLK, EN, I, O, RESET);
  FD16RE X1I55 (.C(CLK), .CE(EN), .D({I[15], I[14], I[13], I[12], I[11], 
    I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], I[2], I[1], I[0]}), .Q(
    {O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5]
    , O[4], O[3], O[2], O[1], O[0]}), .R(RESET));
  FD16RE X1I56 (.C(CLK), .CE(EN), .D({I[31], I[30], I[29], I[28], I[27], 
    I[26], I[25], I[24], I[23], I[22], I[21], I[20], I[19], I[18], I[17], 
    I[16]}), .Q({O[31], O[30], O[29], O[28], O[27], O[26], O[25], O[24], 
    O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}), .R(RESET));

endmodule  // REG32R

module BUFE16 (E, I, O);
  output [15:0] O;
  input E;
  input [15:0] I;
  wire [63:0] A;
  wire [15:0] Q, D, B, IO;
  wire [7:0] DPO, SPO;
  BUFE X1I30 (.E(E), .I(I[8]), .O(O[8]));
  BUFE X1I31 (.E(E), .I(I[9]), .O(O[9]));
  BUFE X1I32 (.E(E), .I(I[10]), .O(O[10]));
  BUFE X1I33 (.E(E), .I(I[11]), .O(O[11]));
  BUFE X1I34 (.E(E), .I(I[15]), .O(O[15]));
  BUFE X1I35 (.E(E), .I(I[14]), .O(O[14]));
  BUFE X1I36 (.E(E), .I(I[13]), .O(O[13]));
  BUFE X1I37 (.E(E), .I(I[12]), .O(O[12]));
  BUFE X1I38 (.E(E), .I(I[6]), .O(O[6]));
  BUFE X1I39 (.E(E), .I(I[7]), .O(O[7]));
  BUFE X1I40 (.E(E), .I(I[0]), .O(O[0]));
  BUFE X1I41 (.E(E), .I(I[1]), .O(O[1]));
  BUFE X1I42 (.E(E), .I(I[2]), .O(O[2]));
  BUFE X1I43 (.E(E), .I(I[3]), .O(O[3]));
  BUFE X1I44 (.E(E), .I(I[4]), .O(O[4]));
  BUFE X1I45 (.E(E), .I(I[5]), .O(O[5]));

endmodule  // BUFE16

module BUFE32 (E, I, O);
  output [31:0] O;
  input E;
  input [31:0] I;
  BUFE16 X1I2 (.E(E), .I({I[15], I[14], I[13], I[12], I[11], I[10], I[9], 
    I[8], I[7], I[6], I[5], I[4], I[3], I[2], I[1], I[0]}), .O({O[15], O[14]
    , O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5], O[4], O[3], 
    O[2], O[1], O[0]}));
  BUFE16 X1I3 (.E(E), .I({I[31], I[30], I[29], I[28], I[27], I[26], I[25], 
    I[24], I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16]}), .O({
    O[31], O[30], O[29], O[28], O[27], O[26], O[25], O[24], O[23], O[22], 
    O[21], O[20], O[19], O[18], O[17], O[16]}));

endmodule  // BUFE32

module D4_16E (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .D0(D[0]), .D1
    (D[1]), .D10(D[10]), .D11(D[11]), .D12(D[12]), .D13(D[13]), .D14(D[14])
    , .D15(D[15]), .D2(D[2]), .D3(D[3]), .D4(D[4]), .D5(D[5]), .D6(D[6]), 
    .D7(D[7]), .D8(D[8]), .D9(D[9]), E);
  output [15:0] D;
  input E;
  input [3:0] A;
  wire [63:0] A;
  wire [15:0] Q, D, O, I, IO;
  wire [7:0] DPO, SPO;
  AND5B3 X1I53 (.I0(A[0]), .I1(A[1]), .I2(A[2]), .I3(A[3]), .I4(E), .O(D[8])
    );
  AND5B2 X1I54 (.I0(A[1]), .I1(A[2]), .I2(E), .I3(A[3]), .I4(A[0]), .O
    (D[9]));
  AND5B2 X1I55 (.I0(A[0]), .I1(A[2]), .I2(E), .I3(A[3]), .I4(A[1]), .O
    (D[10]));
  AND5B1 X1I56 (.I0(A[2]), .I1(A[0]), .I2(A[1]), .I3(A[3]), .I4(E), .O
    (D[11]));
  AND5B2 X1I57 (.I0(A[0]), .I1(A[1]), .I2(E), .I3(A[3]), .I4(A[2]), .O
    (D[12]));
  AND5B1 X1I58 (.I0(A[1]), .I1(A[0]), .I2(A[2]), .I3(A[3]), .I4(E), .O
    (D[13]));
  AND5B1 X1I59 (.I0(A[0]), .I1(A[1]), .I2(A[2]), .I3(A[3]), .I4(E), .O
    (D[14]));
  AND5 X1I60 (.I0(A[3]), .I1(A[2]), .I2(A[1]), .I3(A[0]), .I4(E), .O(D[15])
    );
  AND5B2 X1I61 (.I0(A[3]), .I1(A[0]), .I2(E), .I3(A[2]), .I4(A[1]), .O
    (D[6]));
  AND5B1 X1I62 (.I0(A[3]), .I1(A[2]), .I2(A[1]), .I3(A[0]), .I4(E), .O(D[7])
    );
  AND5B2 X1I63 (.I0(A[3]), .I1(A[1]), .I2(E), .I3(A[2]), .I4(A[0]), .O
    (D[5]));
  AND5B3 X1I64 (.I0(A[0]), .I1(A[1]), .I2(A[3]), .I3(A[2]), .I4(E), .O(D[4])
    );
  AND5B2 X1I65 (.I0(A[2]), .I1(A[3]), .I2(E), .I3(A[0]), .I4(A[1]), .O
    (D[3]));
  AND5B3 X1I66 (.I0(A[0]), .I1(A[3]), .I2(A[2]), .I3(A[1]), .I4(E), .O(D[2])
    );
  AND5B3 X1I67 (.I0(A[1]), .I1(A[2]), .I2(A[3]), .I3(A[0]), .I4(E), .O
    (D[1]));
  AND5B4 X1I68 (.I0(A[3]), .I1(A[2]), .I2(A[1]), .I3(A[0]), .I4(E), .O(D[0])
    );

endmodule  // D4_16E

module BUFE8 (E, I, O);
  output [7:0] O;
  input E;
  input [7:0] I;
  wire [63:0] A;
  wire [15:0] I, O, Q, D, B, IO;
  wire [7:0] DPO, SPO;
  BUFE X1I30 (.E(E), .I(I[0]), .O(O[0]));
  BUFE X1I31 (.E(E), .I(I[1]), .O(O[1]));
  BUFE X1I32 (.E(E), .I(I[2]), .O(O[2]));
  BUFE X1I33 (.E(E), .I(I[3]), .O(O[3]));
  BUFE X1I34 (.E(E), .I(I[7]), .O(O[7]));
  BUFE X1I35 (.E(E), .I(I[6]), .O(O[6]));
  BUFE X1I36 (.E(E), .I(I[5]), .O(O[5]));
  BUFE X1I37 (.E(E), .I(I[4]), .O(O[4]));

endmodule  // BUFE8

module RAM32X32S (A0, A1, A2, A3, A4, D, O, WCLK, WE);
  output [31:0] O;
  input WE, WCLK, A4, A3, A2, A1, A0;
  input [31:0] D;
  RAM32X1S X1I100 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[25]), 
    .O(O[25]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I101 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[27]), 
    .O(O[27]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I102 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[31]), 
    .O(O[31]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I103 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[30]), 
    .O(O[30]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I104 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[29]), 
    .O(O[29]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I105 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[28]), 
    .O(O[28]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I106 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[26]), 
    .O(O[26]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I17 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[0]), .O
    (O[0]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I18 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[1]), .O
    (O[1]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I19 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[3]), .O
    (O[3]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I20 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[7]), .O
    (O[7]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I21 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[6]), .O
    (O[6]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I22 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[5]), .O
    (O[5]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I23 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[4]), .O
    (O[4]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I27 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[2]), .O
    (O[2]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I37 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[10]), .O
    (O[10]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I38 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[12]), .O
    (O[12]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I39 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[13]), .O
    (O[13]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I40 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[14]), .O
    (O[14]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I41 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[15]), .O
    (O[15]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I42 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[11]), .O
    (O[11]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I43 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[9]), .O
    (O[9]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I44 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[8]), .O
    (O[8]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I91 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[18]), .O
    (O[18]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I92 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[20]), .O
    (O[20]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I93 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[21]), .O
    (O[21]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I94 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[22]), .O
    (O[22]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I95 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[23]), .O
    (O[23]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I96 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[19]), .O
    (O[19]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I97 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[17]), .O
    (O[17]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I98 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[16]), .O
    (O[16]), .WCLK(WCLK), .WE(WE));
  RAM32X1S X1I99 (.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .D(D[24]), .O
    (O[24]), .WCLK(WCLK), .WE(WE));

endmodule  // RAM32X32S

module REGBANK1 (D, OA, OB, RA, RB, WCLK, WE, WSEL, W);
  output [31:0] OB;
  output [31:0] OA;
  input WSEL, WE, WCLK;
  input [4:0] W;
  input [4:0] RB;
  input [4:0] RA;
  input [31:0] D;
  wire [4:0] A, B, RB, W, RA;
  wire X1N111, X1N36, X1N38;
  RAM32X32S X1I1 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .D(
    {D[31], D[30], D[29], D[28], D[27], D[26], D[25], D[24], D[23], D[22], 
    D[21], D[20], D[19], D[18], D[17], D[16], D[15], D[14], D[13], D[12], 
    D[11], D[10], D[9], D[8], D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]
    }), .O({OA[31], OA[30], OA[29], OA[28], OA[27], OA[26], OA[25], OA[24], 
    OA[23], OA[22], OA[21], OA[20], OA[19], OA[18], OA[17], OA[16], OA[15], 
    OA[14], OA[13], OA[12], OA[11], OA[10], OA[9], OA[8], OA[7], OA[6], 
    OA[5], OA[4], OA[3], OA[2], OA[1], OA[0]}), .WCLK(WCLK), .WE(X1N36));
  AND2 X1I110 (.I0(X1N111), .I1(WE), .O(X1N36));
  OR5 X1I112 (.I0(W[0]), .I1(W[1]), .I2(W[2]), .I3(W[3]), .I4(W[4]), .O
    (X1N111));
  INV X1I121 (.I(WSEL), .O(X1N38));
  RAM32X32S X1I2 (.A0(B[0]), .A1(B[1]), .A2(B[2]), .A3(B[3]), .A4(B[4]), .D(
    {D[31], D[30], D[29], D[28], D[27], D[26], D[25], D[24], D[23], D[22], 
    D[21], D[20], D[19], D[18], D[17], D[16], D[15], D[14], D[13], D[12], 
    D[11], D[10], D[9], D[8], D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]
    }), .O({OB[31], OB[30], OB[29], OB[28], OB[27], OB[26], OB[25], OB[24], 
    OB[23], OB[22], OB[21], OB[20], OB[19], OB[18], OB[17], OB[16], OB[15], 
    OB[14], OB[13], OB[12], OB[11], OB[10], OB[9], OB[8], OB[7], OB[6], 
    OB[5], OB[4], OB[3], OB[2], OB[1], OB[0]}), .WCLK(WCLK), .WE(X1N36));
  M2_1X5 X1I65 (.A({RA[4], RA[3], RA[2], RA[1], RA[0]}), .B({W[4], W[3], 
    W[2], W[1], W[0]}), .O({A[4], A[3], A[2], A[1], A[0]}), .SB(X1N38));
  M2_1X5 X1I66 (.A({RB[4], RB[3], RB[2], RB[1], RB[0]}), .B({W[4], W[3], 
    W[2], W[1], W[0]}), .O({B[4], B[3], B[2], B[1], B[0]}), .SB(X1N38));

endmodule  // REGBANK1

module FTRSE (C, CE, Q, R, S, T);
  output Q;
  input T, S, R, CE, C;
  wire CE_S, D_S, TQ;
  XOR2 X1I32 (.I0(T), .I1(Q), .O(TQ));
  FDRE X1I35 (.C(C), .CE(CE_S), .D(D_S), .Q(Q), .R(R));
  OR2 X1I73 (.I0(S), .I1(TQ), .O(D_S));
  OR2 X1I77 (.I0(CE), .I1(S), .O(CE_S));

endmodule  // FTRSE

module CB8RE (C, CE, CEO, Q, R, TC);
  output TC, CEO;
  output [7:0] Q;
  input R, CE, C;
  wire X1N5, T2, T3, T4, T5, T6, T7, X1N10;
  VCC X1I13 (.P(X1N10));
  FTRSE Q6 (.C(C), .CE(CE), .Q(Q[6]), .R(R), .S(X1N5), .T(T6));
  FTRSE Q5 (.C(C), .CE(CE), .Q(Q[5]), .R(R), .S(X1N5), .T(T5));
  FTRSE Q4 (.C(C), .CE(CE), .Q(Q[4]), .R(R), .S(X1N5), .T(T4));
  FTRSE Q3 (.C(C), .CE(CE), .Q(Q[3]), .R(R), .S(X1N5), .T(T3));
  FTRSE Q2 (.C(C), .CE(CE), .Q(Q[2]), .R(R), .S(X1N5), .T(T2));
  FTRSE Q1 (.C(C), .CE(CE), .Q(Q[1]), .R(R), .S(X1N5), .T(Q[0]));
  FTRSE Q0 (.C(C), .CE(CE), .Q(Q[0]), .R(R), .S(X1N5), .T(X1N10));
  AND2 X1I21 (.I0(Q[1]), .I1(Q[0]), .O(T2));
  AND3 X1I22 (.I0(Q[2]), .I1(Q[1]), .I2(Q[0]), .O(T3));
  AND4 X1I23 (.I0(Q[3]), .I1(Q[2]), .I2(Q[1]), .I3(Q[0]), .O(T4));
  AND2 X1I25 (.I0(Q[4]), .I1(T4), .O(T5));
  AND3 X1I26 (.I0(Q[5]), .I1(Q[4]), .I2(T4), .O(T6));
  AND4 X1I28 (.I0(Q[6]), .I1(Q[5]), .I2(Q[4]), .I3(T4), .O(T7));
  AND5 X1I29 (.I0(Q[7]), .I1(Q[6]), .I2(Q[5]), .I3(Q[4]), .I4(T4), .O(TC));
  AND2 X1I32 (.I0(CE), .I1(TC), .O(CEO));
  FTRSE Q7 (.C(C), .CE(CE), .Q(Q[7]), .R(R), .S(X1N5), .T(T7));
  GND X1I7 (.G(X1N5));

endmodule  // CB8RE

module CB2RE (C, CE, CEO, Q0, Q1, R, TC);
  output TC, Q1, Q0, CEO;
  input R, CE, C;
  wire X1N50, X1N33;
  FTRSE Q1 (.C(C), .CE(CE), .Q(Q1), .R(R), .S(X1N50), .T(Q0));
  FTRSE Q0 (.C(C), .CE(CE), .Q(Q0), .R(R), .S(X1N50), .T(X1N33));
  AND2 X1I37 (.I0(Q1), .I1(Q0), .O(TC));
  VCC X1I47 (.P(X1N33));
  GND X1I54 (.G(X1N50));
  AND2 X1I55 (.I0(CE), .I1(TC), .O(CEO));

endmodule  // CB2RE

module CB4RE (C, CE, CEO, Q0, Q1, Q2, Q3, R, TC);
  output TC, Q3, Q2, Q1, Q0, CEO;
  input R, CE, C;
  wire T2, T3, X1N62, X1N55;
  AND4 X1I31 (.I0(Q3), .I1(Q2), .I2(Q1), .I3(Q0), .O(TC));
  AND3 X1I32 (.I0(Q2), .I1(Q1), .I2(Q0), .O(T3));
  AND2 X1I33 (.I0(Q1), .I1(Q0), .O(T2));
  FTRSE Q0 (.C(C), .CE(CE), .Q(Q0), .R(R), .S(X1N62), .T(X1N55));
  FTRSE Q1 (.C(C), .CE(CE), .Q(Q1), .R(R), .S(X1N62), .T(Q0));
  FTRSE Q2 (.C(C), .CE(CE), .Q(Q2), .R(R), .S(X1N62), .T(T2));
  FTRSE Q3 (.C(C), .CE(CE), .Q(Q3), .R(R), .S(X1N62), .T(T3));
  VCC X1I58 (.P(X1N55));
  GND X1I64 (.G(X1N62));
  AND2 X1I69 (.I0(CE), .I1(TC), .O(CEO));

endmodule  // CB4RE

module M2_1E (.D0(D[0]), .D1(D[1]), E, O, S0);
  output O;
  input S0, E;
  input [1:0] D;
  wire [15:0] O, I, Q, D;
  wire [7:0] DPO, SPO;
  wire M0, M1;
  AND3 X1I30 (.I0(D[1]), .I1(E), .I2(S0), .O(M1));
  AND3B1 X1I31 (.I0(S0), .I1(E), .I2(D[0]), .O(M0));
  OR2 X1I38 (.I0(M1), .I1(M0), .O(O));

endmodule  // M2_1E

module M8_1E (.D0(D[0]), .D1(D[1]), .D2(D[2]), .D3(D[3]), .D4(D[4]), .D5
    (D[5]), .D6(D[6]), .D7(D[7]), E, O, S0, S1, S2);
  output O;
  input S2, S1, S0, E;
  input [7:0] D;
  wire [15:0] O, I, Q, D;
  wire [7:0] DPO, SPO;
  wire M01, M03, M23, M45, M47, M67;
  MUXF5_L M03 (.I0(M01), .I1(M23), .LO(M03), .S(S1));
  M2_1E M45 (.D0(D[4]), .D1(D[5]), .E(E), .O(M45), .S0(S0));
  M2_1E M67 (.D0(D[6]), .D1(D[7]), .E(E), .O(M67), .S0(S0));
  MUXF5_L M47 (.I0(M45), .I1(M67), .LO(M47), .S(S1));
  M2_1E M23 (.D0(D[2]), .D1(D[3]), .E(E), .O(M23), .S0(S0));
  M2_1E M01 (.D0(D[0]), .D1(D[1]), .E(E), .O(M01), .S0(S0));
  MUXF6 O (.I0(M03), .I1(M47), .O(O), .S(S2));

endmodule  // M8_1E

module SR8CE (C, CE, CLR, Q, SLI);
  output [0:7] Q;
  input SLI, CLR, CE, C;
  FDCE Q7 (.C(C), .CE(CE), .CLR(CLR), .D(Q[6]), .Q(Q[7]));
  FDCE Q3 (.C(C), .CE(CE), .CLR(CLR), .D(Q[2]), .Q(Q[3]));
  FDCE Q5 (.C(C), .CE(CE), .CLR(CLR), .D(Q[4]), .Q(Q[5]));
  FDCE Q4 (.C(C), .CE(CE), .CLR(CLR), .D(Q[3]), .Q(Q[4]));
  FDCE Q1 (.C(C), .CE(CE), .CLR(CLR), .D(Q[0]), .Q(Q[1]));
  FDCE Q0 (.C(C), .CE(CE), .CLR(CLR), .D(SLI), .Q(Q[0]));
  FDCE Q2 (.C(C), .CE(CE), .CLR(CLR), .D(Q[1]), .Q(Q[2]));
  FDCE Q6 (.C(C), .CE(CE), .CLR(CLR), .D(Q[5]), .Q(Q[6]));

endmodule  // SR8CE

module FD8CE (C, CE, CLR, D, Q);
  output [7:0] Q;
  input CLR, CE, C;
  input [7:0] D;
  wire [15:0] O, I, Q, D, IO;
  wire [7:0] DPO, SPO;
  FDCE Q7 (.C(C), .CE(CE), .CLR(CLR), .D(D[7]), .Q(Q[7]));
  FDCE Q6 (.C(C), .CE(CE), .CLR(CLR), .D(D[6]), .Q(Q[6]));
  FDCE Q5 (.C(C), .CE(CE), .CLR(CLR), .D(D[5]), .Q(Q[5]));
  FDCE Q4 (.C(C), .CE(CE), .CLR(CLR), .D(D[4]), .Q(Q[4]));
  FDCE Q1 (.C(C), .CE(CE), .CLR(CLR), .D(D[1]), .Q(Q[1]));
  FDCE Q0 (.C(C), .CE(CE), .CLR(CLR), .D(D[0]), .Q(Q[0]));
  FDCE Q2 (.C(C), .CE(CE), .CLR(CLR), .D(D[2]), .Q(Q[2]));
  FDCE Q3 (.C(C), .CE(CE), .CLR(CLR), .D(D[3]), .Q(Q[3]));

endmodule  // FD8CE

module SERIAL (CLK, GOT_BYTE, IN, OUT, READY, REQ);
  wire [7:0] CLKDIV, IN, OUT, SERIN;
  wire X1N122, X1N123, X1N124, X1N164, EOF, X1N7, X1N174, X1N175, X1N139, 
    X1N9, X1N185, DATA_OUT, X1N186, STOP, RCV, RXD, SER_CLK, SHIFT_R, NRCV, 
    X1N13, X1N41, X1N33, X1N70, X1N35, X1N81, X1N63, X1N46, X1N48, X1N58, 
    X1N78, SHIFT, TRANS, START;
  CB8RE X1I1 (.C(CLK), .CE(X1N13), .Q({CLKDIV[7], CLKDIV[6], CLKDIV[5], 
    CLKDIV[4], CLKDIV[3], CLKDIV[2], CLKDIV[1], CLKDIV[0]}), .R(X1N9));
  CB2RE X1I119 (.C(SER_CLK), .CE(TRANS), .CEO(SHIFT), .R(READY));
  VCC X1I12 (.P(X1N13));
  CB4RE X1I120 (.C(SER_CLK), .CE(SHIFT), .Q0(X1N122), .Q1(X1N123), .Q2
    (X1N124), .Q3(X1N139), .R(READY));
  M8_1E X1I121 (.D0(IN[7]), .D1(IN[0]), .D2(IN[1]), .D3(IN[2]), .D4(IN[3]), 
    .D5(IN[4]), .D6(IN[5]), .D7(IN[6]), .E(X1N164), .O(DATA_OUT), .S0
    (X1N122), .S1(X1N123), .S2(X1N124));
  FDE X1I130 (.C(SER_CLK), .CE(X1N185), .D(REQ), .Q(TRANS));
  AND4B4 X1I138 (.I0(X1N139), .I1(X1N124), .I2(X1N123), .I3(X1N122), .O
    (START));
  AND2 X1I146 (.I0(X1N139), .I1(X1N122), .O(STOP));
  AND4 X1I16 (.I0(CLKDIV[0]), .I1(CLKDIV[2]), .I2(CLKDIV[4]), .I3(CLKDIV[5])
    , .O(X1N9));
  OR3 X1I162 (.I0(READY), .I1(DATA_OUT), .I2(STOP), .O(X1N175));
  INV X1I163 (.I(START), .O(X1N164));
  OBUF X1I172 (.I(X1N175), .O(X1N174));
  OPAD X1I173 (.OPAD(X1N174));
  INV X1I177 (.I(TRANS), .O(READY));
  AND2 X1I180 (.I0(SHIFT), .I1(STOP), .O(X1N186));
  OR2 X1I184 (.I0(X1N186), .I1(REQ), .O(X1N185));
  FDE X1I2 (.C(CLK), .CE(X1N9), .D(X1N7), .Q(SER_CLK));
  CB4RE X1I20 (.C(SER_CLK), .CE(X1N41), .Q0(X1N48), .Q3(X1N46), .R(NRCV));
  CB2RE X1I22 (.C(SER_CLK), .CE(RCV), .CEO(X1N41), .Q0(X1N33), .Q1(X1N35), 
    .R(NRCV));
  FDE X1I23 (.C(SER_CLK), .CE(X1N58), .D(X1N70), .Q(RCV));
  INV X1I25 (.I(RCV), .O(NRCV));
  AND3 X1I28 (.I0(X1N48), .I1(X1N46), .I2(X1N33), .O(GOT_BYTE));
  AND3 X1I29 (.I0(RCV), .I1(X1N46), .I2(X1N48), .O(EOF));
  INV X1I3 (.I(SER_CLK), .O(X1N7));
  AND2B1 X1I30 (.I0(X1N35), .I1(X1N33), .O(SHIFT_R));
  OR2B1 X1I57 (.I0(RXD), .I1(EOF), .O(X1N58));
  IPAD X1I62 (.IPAD(X1N63));
  IBUF X1I64 (.I(X1N63), .O(RXD));
  INV X1I69 (.I(EOF), .O(X1N70));
  SR8CE X1I71 (.C(SER_CLK), .CE(SHIFT_R), .CLR(X1N78), .Q({SERIN[7], 
    SERIN[6], SERIN[5], SERIN[4], SERIN[3], SERIN[2], SERIN[1], SERIN[0]}), 
    .SLI(RXD));
  FD8CE X1I72 (.C(SER_CLK), .CE(EOF), .CLR(X1N81), .D({SERIN[7], SERIN[6], 
    SERIN[5], SERIN[4], SERIN[3], SERIN[2], SERIN[1], SERIN[0]}), .Q({OUT[7]
    , OUT[6], OUT[5], OUT[4], OUT[3], OUT[2], OUT[1], OUT[0]}));
  GND X1I77 (.G(X1N78));
  GND X1I80 (.G(X1N81));

// WARNING - Component X1I22 has unconnected pins: 0 input, 1 output, 0 inout.
// WARNING - Component X1I119 has unconnected pins: 0 input, 3 output, 0 inout.
// WARNING - Component X1I120 has unconnected pins: 0 input, 2 output, 0 inout.
// WARNING - Component X1I1 has unconnected pins: 0 input, 2 output, 0 inout.
// WARNING - Component X1I20 has unconnected pins: 0 input, 4 output, 0 inout.
endmodule  // SERIAL

module X16_FIFO (ACK_IN, ACK_OUT, CLK, IN, OUT, REQ_IN, REQ_OUT);
  wire [7:0] A, B, C, D, E, F, G, H, I;
  wire X1N100, X1N101, X1N102, X1N121, X1N131, X1N122, X1N104, X1N132, 
    X1N123, X1N133, X1N107, X1N108, X1N30, X1N23, X1N43, X1N44, X1N35, X1N90
    , X1N54, X1N45, X1N91, X1N55, X1N37, X1N28, X1N92, X1N56, X1N76, X1N77;
  FD8CE X1I1 (.C(CLK), .CE(X1N30), .CLR(X1N35), .D({H[7], H[6], H[5], H[4], 
    H[3], H[2], H[1], H[0]}), .Q({I[7], I[6], I[5], I[4], I[3], I[2], I[1], 
    I[0]}));
  GND X1I109 (.G(X1N108));
  OR2B1 X1I110 (.I0(X1N107), .I1(X1N104), .O(X1N123));
  FDE X1I111 (.C(CLK), .CE(X1N123), .D(X1N122), .Q(X1N107));
  FD8CE X1I113 (.C(CLK), .CE(X1N123), .CLR(X1N108), .D({B[7], B[6], B[5], 
    B[4], B[3], B[2], B[1], B[0]}), .Q({C[7], C[6], C[5], C[4], C[3], C[2], 
    C[1], C[0]}));
  FD8CE X1I116 (.C(CLK), .CE(X1N133), .CLR(X1N121), .D({A[7], A[6], A[5], 
    A[4], A[3], A[2], A[1], A[0]}), .Q({B[7], B[6], B[5], B[4], B[3], B[2], 
    B[1], B[0]}));
  FDE X1I118 (.C(CLK), .CE(X1N133), .D(X1N132), .Q(X1N122));
  OR2B1 X1I119 (.I0(X1N122), .I1(X1N123), .O(X1N133));
  GND X1I120 (.G(X1N121));
  FD8CE X1I126 (.C(CLK), .CE(ACK_IN), .CLR(X1N131), .D({IN[7], IN[6], IN[5]
    , IN[4], IN[3], IN[2], IN[1], IN[0]}), .Q({A[7], A[6], A[5], A[4], A[3]
    , A[2], A[1], A[0]}));
  FDE X1I128 (.C(CLK), .CE(ACK_IN), .D(REQ_IN), .Q(X1N132));
  OR2B1 X1I129 (.I0(X1N132), .I1(X1N133), .O(ACK_IN));
  GND X1I130 (.G(X1N131));
  FDE X1I14 (.C(CLK), .CE(X1N23), .D(X1N28), .Q(REQ_OUT));
  OR2B1 X1I18 (.I0(REQ_OUT), .I1(ACK_OUT), .O(X1N23));
  OR2B1 X1I27 (.I0(X1N28), .I1(X1N23), .O(X1N30));
  GND X1I34 (.G(X1N35));
  GND X1I38 (.G(X1N37));
  GND X1I46 (.G(X1N45));
  OR2B1 X1I47 (.I0(X1N43), .I1(X1N30), .O(X1N44));
  FDE X1I48 (.C(CLK), .CE(X1N44), .D(X1N54), .Q(X1N43));
  FD8CE X1I50 (.C(CLK), .CE(X1N44), .CLR(X1N45), .D({G[7], G[6], G[5], G[4]
    , G[3], G[2], G[1], G[0]}), .Q({H[7], H[6], H[5], H[4], H[3], H[2], H[1]
    , H[0]}));
  GND X1I57 (.G(X1N56));
  OR2B1 X1I58 (.I0(X1N54), .I1(X1N44), .O(X1N55));
  FDE X1I59 (.C(CLK), .CE(X1N55), .D(X1N76), .Q(X1N54));
  FD8CE X1I61 (.C(CLK), .CE(X1N55), .CLR(X1N56), .D({F[7], F[6], F[5], F[4]
    , F[3], F[2], F[1], F[0]}), .Q({G[7], G[6], G[5], G[4], G[3], G[2], G[1]
    , G[0]}));
  FD8CE X1I7 (.C(CLK), .CE(X1N23), .CLR(X1N37), .D({I[7], I[6], I[5], I[4], 
    I[3], I[2], I[1], I[0]}), .Q({OUT[7], OUT[6], OUT[5], OUT[4], OUT[3], 
    OUT[2], OUT[1], OUT[0]}));
  GND X1I78 (.G(X1N77));
  OR2B1 X1I79 (.I0(X1N76), .I1(X1N55), .O(X1N92));
  FDE X1I80 (.C(CLK), .CE(X1N92), .D(X1N91), .Q(X1N76));
  FD8CE X1I82 (.C(CLK), .CE(X1N92), .CLR(X1N77), .D({E[7], E[6], E[5], E[4]
    , E[3], E[2], E[1], E[0]}), .Q({F[7], F[6], F[5], F[4], F[3], F[2], F[1]
    , F[0]}));
  FD8CE X1I85 (.C(CLK), .CE(X1N102), .CLR(X1N90), .D({D[7], D[6], D[5], D[4]
    , D[3], D[2], D[1], D[0]}), .Q({E[7], E[6], E[5], E[4], E[3], E[2], E[1]
    , E[0]}));
  FDE X1I87 (.C(CLK), .CE(X1N102), .D(X1N101), .Q(X1N91));
  OR2B1 X1I88 (.I0(X1N91), .I1(X1N92), .O(X1N102));
  GND X1I89 (.G(X1N90));
  FDE X1I9 (.C(CLK), .CE(X1N30), .D(X1N43), .Q(X1N28));
  FD8CE X1I95 (.C(CLK), .CE(X1N104), .CLR(X1N100), .D({C[7], C[6], C[5], 
    C[4], C[3], C[2], C[1], C[0]}), .Q({D[7], D[6], D[5], D[4], D[3], D[2], 
    D[1], D[0]}));
  FDE X1I97 (.C(CLK), .CE(X1N104), .D(X1N107), .Q(X1N101));
  OR2B1 X1I98 (.I0(X1N101), .I1(X1N102), .O(X1N104));
  GND X1I99 (.G(X1N100));

endmodule  // X16_FIFO

module SERIAL_FIFO (ACK_IN, ACK_OUT, CLK, CLK_50MHZ, IN, OUTPUT, REQ_IN, 
    REQ_OUT);
  wire [7:0] A, B, OUTPUT;
  wire X1N1, X1N2, X1N3, X1N7, X1N9, X1N11, X1N12, X1N18;
  AND2B1 X1I10 (.I0(X1N11), .I1(X1N1), .O(X1N9));
  AND2 X1I13 (.I0(X1N11), .I1(X1N12), .O(X1N2));
  SERIAL SERIAL_LINK (.CLK(CLK_50MHZ), .GOT_BYTE(X1N7), .IN({A[7], A[6], 
    A[5], A[4], A[3], A[2], A[1], A[0]}), .OUT({B[7], B[6], B[5], B[4], B[3]
    , B[2], B[1], B[0]}), .READY(X1N1), .REQ(X1N2));
  X16_FIFO X1I15 (.ACK_IN(ACK_IN), .ACK_OUT(X1N9), .CLK(CLK), .IN({IN[7], 
    IN[6], IN[5], IN[4], IN[3], IN[2], IN[1], IN[0]}), .OUT({A[7], A[6], 
    A[5], A[4], A[3], A[2], A[1], A[0]}), .REQ_IN(REQ_IN), .REQ_OUT(X1N12));
  FD X1I16 (.C(CLK), .D(X1N7), .Q(X1N3));
  AND2B1 X1I17 (.I0(X1N3), .I1(X1N7), .O(X1N18));
  X16_FIFO X1I6 (.ACK_OUT(ACK_OUT), .CLK(CLK), .IN({B[7], B[6], B[5], B[4], 
    B[3], B[2], B[1], B[0]}), .OUT({OUTPUT[7], OUTPUT[6], OUTPUT[5], 
    OUTPUT[4], OUTPUT[3], OUTPUT[2], OUTPUT[1], OUTPUT[0]}), .REQ_IN(X1N18)
    , .REQ_OUT(REQ_OUT));
  FD X1I8 (.C(CLK), .D(X1N1), .Q(X1N11));

endmodule  // SERIAL_FIFO

module LOGIC1 (A, B, O0, O1, S);
  wire X1N20, X1N21, X1N31, X1N22, X1N61, X1N25, X1N63, X1N46, X1N37, X1N57
    , X1N39, X1N58;
  OR4 X1I1 (.I0(X1N46), .I1(X1N37), .I2(X1N25), .I3(X1N22), .O(S));
  INV X1I17 (.I(O1), .O(X1N21));
  INV X1I18 (.I(O0), .O(X1N20));
  AND4 X1I19 (.I0(B), .I1(A), .I2(X1N21), .I3(X1N20), .O(X1N22));
  AND3 X1I24 (.I0(X1N31), .I1(O0), .I2(X1N21), .O(X1N25));
  OR2 X1I30 (.I0(B), .I1(A), .O(X1N31));
  AND3 X1I36 (.I0(X1N39), .I1(X1N20), .I2(O1), .O(X1N37));
  AND4 X1I54 (.I0(X1N58), .I1(X1N57), .I2(O1), .I3(O0), .O(X1N46));
  INV X1I55 (.I(A), .O(X1N57));
  INV X1I56 (.I(B), .O(X1N58));
  OR2 X1I59 (.I0(X1N63), .I1(X1N61), .O(X1N39));
  AND2 X1I60 (.I0(X1N57), .I1(B), .O(X1N61));
  AND2 X1I62 (.I0(A), .I1(X1N58), .O(X1N63));

endmodule  // LOGIC1

module ADD1 (A, B, CI, CO, S, SUB);
  wire X1N12, X1N13, X1N33, X1N34, X1N35;
  XOR2 X1I10 (.I0(CI), .I1(A), .O(X1N13));
  AND2 X1I20 (.I0(X1N12), .I1(CI), .O(X1N33));
  AND2 X1I21 (.I0(X1N12), .I1(A), .O(X1N34));
  AND2 X1I22 (.I0(CI), .I1(A), .O(X1N35));
  XOR2 X1I24 (.I0(X1N12), .I1(X1N13), .O(S));
  OR3 X1I31 (.I0(X1N33), .I1(X1N34), .I2(X1N35), .O(CO));
  XOR2 X1I9 (.I0(SUB), .I1(B), .O(X1N12));

endmodule  // ADD1

module ALU2 (A, B, OP, OVERFLOW, S);
  wire X1N401, X1N311, X1N221, X1N203, X1N600, X1N510, X1N420, X1N402, 
    X1N330, X1N312, X1N240, X1N222, X1N204, X1N601, X1N511, X1N421, X1N403, 
    X1N331, X1N313, X1N241, X1N223, X1N205, X1N160, X1N602, X1N512, X1N440, 
    X1N422, X1N404, X1N350, X1N332, X1N314, X1N242, X1N224, X1N206, X1N161, 
    X1N630, X1N603, X1N540, X1N513, X1N712, X1N631, X1N613, X1N541, X1N523, 
    X1N442, X1N424, X1N406, X1N370, X1N352, X1N334, X1N316, X1N280, X1N262, 
    X1N226, X1N208, X1N190, X1N731, X1N632, X1N542, X1N164, X1N155, X1N750, 
    X1N660, X1N633, X1N615, X1N570, X1N543, X1N525, X1N480, X1N156, X1N706, 
    X1N661, X1N643, X1N616, X1N571, X1N553, X1N526, X1N508, X1N490, X1N481, 
    X1N472, X1N662, X1N617, X1N572, X1N527, X1N491, X1N464, X1N455, X1N437, 
    X1N419, X1N383, X1N365, X1N347, X1N329, X1N293, X1N275, X1N239, X1N690, 
    X1N663, X1N645, X1N618, X1N573, X1N555, X1N528, X1N492, X1N456, X1N438, 
    X1N384, X1N366, X1N348, X1N294, X1N276, X1N691, X1N673, X1N646, X1N628, 
    X1N583, X1N556, X1N538, X1N475, X1N457, X1N439, X1N385, X1N367, X1N349, 
    X1N295, X1N277, X1N692, X1N647, X1N557, X1N476, X1N458, X1N386, X1N368, 
    X1N296, X1N278, X1N693, X1N675, X1N648, X1N585, X1N558, X1N495, X1N757, 
    X1N748, X1N676, X1N658, X1N586, X1N568, X1N496, X1N388, X1N298, X1N677, 
    X1N587, X1N497, X1N678, X1N588, X1N498, X1N489, X1N688, X1N598, CO, 
    X1N20, X1N24, X1N27, X1N28, X1N19;
  OR2 X1I157 (.I0(X1N155), .I1(X1N156), .O(S[1]));
  AND2 X1I158 (.I0(OP[2]), .I1(X1N161), .O(X1N155));
  AND2 X1I159 (.I0(X1N24), .I1(X1N160), .O(X1N156));
  LOGIC1 X1I167 (.A(A[1]), .B(B[1]), .O0(OP[0]), .O1(OP[1]), .S(X1N161));
  ADD1 X1I168 (.A(A[1]), .B(B[1]), .CI(X1N164), .CO(X1N190), .S(X1N160), 
    .SUB(OP[1]));
  ADD1 X1I193 (.A(A[2]), .B(B[2]), .CI(X1N190), .CO(X1N208), .S(X1N204), 
    .SUB(OP[1]));
  LOGIC1 X1I197 (.A(A[2]), .B(B[2]), .O0(OP[0]), .O1(OP[1]), .S(X1N203));
  AND2 X1I198 (.I0(X1N24), .I1(X1N204), .O(X1N205));
  AND2 X1I199 (.I0(OP[2]), .I1(X1N203), .O(X1N206));
  OR2 X1I200 (.I0(X1N206), .I1(X1N205), .O(S[2]));
  ADD1 X1I211 (.A(A[3]), .B(B[3]), .CI(X1N208), .CO(X1N226), .S(X1N222), 
    .SUB(OP[1]));
  LOGIC1 X1I215 (.A(A[3]), .B(B[3]), .O0(OP[0]), .O1(OP[1]), .S(X1N221));
  AND2 X1I216 (.I0(X1N24), .I1(X1N222), .O(X1N223));
  AND2 X1I217 (.I0(OP[2]), .I1(X1N221), .O(X1N224));
  OR2 X1I218 (.I0(X1N224), .I1(X1N223), .O(S[3]));
  AND2 X1I22 (.I0(X1N24), .I1(X1N20), .O(X1N27));
  ADD1 X1I229 (.A(A[4]), .B(B[4]), .CI(X1N226), .CO(X1N262), .S(X1N240), 
    .SUB(OP[1]));
  AND2 X1I23 (.I0(OP[2]), .I1(X1N19), .O(X1N28));
  LOGIC1 X1I233 (.A(A[4]), .B(B[4]), .O0(OP[0]), .O1(OP[1]), .S(X1N239));
  AND2 X1I234 (.I0(X1N24), .I1(X1N240), .O(X1N241));
  AND2 X1I235 (.I0(OP[2]), .I1(X1N239), .O(X1N242));
  OR2 X1I236 (.I0(X1N242), .I1(X1N241), .O(S[4]));
  ADD1 X1I265 (.A(A[5]), .B(B[5]), .CI(X1N262), .CO(X1N280), .S(X1N276), 
    .SUB(OP[1]));
  LOGIC1 X1I269 (.A(A[5]), .B(B[5]), .O0(OP[0]), .O1(OP[1]), .S(X1N275));
  AND2 X1I270 (.I0(X1N24), .I1(X1N276), .O(X1N277));
  AND2 X1I271 (.I0(OP[2]), .I1(X1N275), .O(X1N278));
  OR2 X1I272 (.I0(X1N278), .I1(X1N277), .O(S[5]));
  ADD1 X1I283 (.A(A[6]), .B(B[6]), .CI(X1N280), .CO(X1N298), .S(X1N294), 
    .SUB(OP[1]));
  LOGIC1 X1I287 (.A(A[6]), .B(B[6]), .O0(OP[0]), .O1(OP[1]), .S(X1N293));
  AND2 X1I288 (.I0(X1N24), .I1(X1N294), .O(X1N295));
  AND2 X1I289 (.I0(OP[2]), .I1(X1N293), .O(X1N296));
  OR2 X1I290 (.I0(X1N296), .I1(X1N295), .O(S[6]));
  ADD1 X1I301 (.A(A[7]), .B(B[7]), .CI(X1N298), .CO(X1N316), .S(X1N312), 
    .SUB(OP[1]));
  LOGIC1 X1I305 (.A(A[7]), .B(B[7]), .O0(OP[0]), .O1(OP[1]), .S(X1N311));
  AND2 X1I306 (.I0(X1N24), .I1(X1N312), .O(X1N313));
  AND2 X1I307 (.I0(OP[2]), .I1(X1N311), .O(X1N314));
  OR2 X1I308 (.I0(X1N314), .I1(X1N313), .O(S[7]));
  ADD1 X1I319 (.A(A[8]), .B(B[8]), .CI(X1N316), .CO(X1N334), .S(X1N330), 
    .SUB(OP[1]));
  LOGIC1 X1I323 (.A(A[8]), .B(B[8]), .O0(OP[0]), .O1(OP[1]), .S(X1N329));
  AND2 X1I324 (.I0(X1N24), .I1(X1N330), .O(X1N331));
  AND2 X1I325 (.I0(OP[2]), .I1(X1N329), .O(X1N332));
  OR2 X1I326 (.I0(X1N332), .I1(X1N331), .O(S[8]));
  ADD1 X1I337 (.A(A[9]), .B(B[9]), .CI(X1N334), .CO(X1N352), .S(X1N348), 
    .SUB(OP[1]));
  LOGIC1 X1I341 (.A(A[9]), .B(B[9]), .O0(OP[0]), .O1(OP[1]), .S(X1N347));
  AND2 X1I342 (.I0(X1N24), .I1(X1N348), .O(X1N349));
  AND2 X1I343 (.I0(OP[2]), .I1(X1N347), .O(X1N350));
  OR2 X1I344 (.I0(X1N350), .I1(X1N349), .O(S[9]));
  ADD1 X1I355 (.A(A[10]), .B(B[10]), .CI(X1N352), .CO(X1N370), .S(X1N366), 
    .SUB(OP[1]));
  LOGIC1 X1I359 (.A(A[10]), .B(B[10]), .O0(OP[0]), .O1(OP[1]), .S(X1N365));
  AND2 X1I360 (.I0(X1N24), .I1(X1N366), .O(X1N367));
  AND2 X1I361 (.I0(OP[2]), .I1(X1N365), .O(X1N368));
  OR2 X1I362 (.I0(X1N368), .I1(X1N367), .O(S[10]));
  ADD1 X1I373 (.A(A[11]), .B(B[11]), .CI(X1N370), .CO(X1N388), .S(X1N384), 
    .SUB(OP[1]));
  LOGIC1 X1I377 (.A(A[11]), .B(B[11]), .O0(OP[0]), .O1(OP[1]), .S(X1N383));
  AND2 X1I378 (.I0(X1N24), .I1(X1N384), .O(X1N385));
  AND2 X1I379 (.I0(OP[2]), .I1(X1N383), .O(X1N386));
  OR2 X1I380 (.I0(X1N386), .I1(X1N385), .O(S[11]));
  ADD1 X1I391 (.A(A[12]), .B(B[12]), .CI(X1N388), .CO(X1N406), .S(X1N402), 
    .SUB(OP[1]));
  LOGIC1 X1I395 (.A(A[12]), .B(B[12]), .O0(OP[0]), .O1(OP[1]), .S(X1N401));
  AND2 X1I396 (.I0(X1N24), .I1(X1N402), .O(X1N403));
  AND2 X1I397 (.I0(OP[2]), .I1(X1N401), .O(X1N404));
  OR2 X1I398 (.I0(X1N404), .I1(X1N403), .O(S[12]));
  LOGIC1 X1I4 (.A(A[0]), .B(B[0]), .O0(OP[0]), .O1(OP[1]), .S(X1N19));
  ADD1 X1I409 (.A(A[13]), .B(B[13]), .CI(X1N406), .CO(X1N424), .S(X1N420), 
    .SUB(OP[1]));
  LOGIC1 X1I413 (.A(A[13]), .B(B[13]), .O0(OP[0]), .O1(OP[1]), .S(X1N419));
  AND2 X1I414 (.I0(X1N24), .I1(X1N420), .O(X1N421));
  AND2 X1I415 (.I0(OP[2]), .I1(X1N419), .O(X1N422));
  OR2 X1I416 (.I0(X1N422), .I1(X1N421), .O(S[13]));
  ADD1 X1I427 (.A(A[14]), .B(B[14]), .CI(X1N424), .CO(X1N442), .S(X1N438), 
    .SUB(OP[1]));
  LOGIC1 X1I431 (.A(A[14]), .B(B[14]), .O0(OP[0]), .O1(OP[1]), .S(X1N437));
  AND2 X1I432 (.I0(X1N24), .I1(X1N438), .O(X1N439));
  AND2 X1I433 (.I0(OP[2]), .I1(X1N437), .O(X1N440));
  OR2 X1I434 (.I0(X1N440), .I1(X1N439), .O(S[14]));
  ADD1 X1I445 (.A(A[15]), .B(B[15]), .CI(X1N442), .CO(X1N472), .S(X1N456), 
    .SUB(OP[1]));
  LOGIC1 X1I449 (.A(A[15]), .B(B[15]), .O0(OP[0]), .O1(OP[1]), .S(X1N455));
  AND2 X1I450 (.I0(X1N24), .I1(X1N456), .O(X1N457));
  AND2 X1I451 (.I0(OP[2]), .I1(X1N455), .O(X1N458));
  OR2 X1I452 (.I0(X1N458), .I1(X1N457), .O(S[15]));
  ADD1 X1I467 (.A(A[17]), .B(B[17]), .CI(X1N464), .CO(X1N508), .S(X1N490), 
    .SUB(OP[1]));
  ADD1 X1I468 (.A(A[16]), .B(B[16]), .CI(X1N472), .CO(X1N464), .S(X1N476), 
    .SUB(OP[1]));
  LOGIC1 X1I469 (.A(A[16]), .B(B[16]), .O0(OP[0]), .O1(OP[1]), .S(X1N475));
  AND2 X1I477 (.I0(X1N24), .I1(X1N476), .O(X1N480));
  AND2 X1I478 (.I0(OP[2]), .I1(X1N475), .O(X1N481));
  OR2 X1I479 (.I0(X1N481), .I1(X1N480), .O(S[16]));
  LOGIC1 X1I483 (.A(A[17]), .B(B[17]), .O0(OP[0]), .O1(OP[1]), .S(X1N489));
  AND2 X1I484 (.I0(X1N24), .I1(X1N490), .O(X1N491));
  AND2 X1I485 (.I0(OP[2]), .I1(X1N489), .O(X1N492));
  OR2 X1I486 (.I0(X1N492), .I1(X1N491), .O(S[17]));
  OR2 X1I501 (.I0(X1N495), .I1(X1N496), .O(S[18]));
  AND2 X1I502 (.I0(OP[2]), .I1(X1N498), .O(X1N495));
  AND2 X1I503 (.I0(X1N24), .I1(X1N497), .O(X1N496));
  LOGIC1 X1I504 (.A(A[18]), .B(B[18]), .O0(OP[0]), .O1(OP[1]), .S(X1N498));
  ADD1 X1I505 (.A(A[18]), .B(B[18]), .CI(X1N508), .CO(X1N523), .S(X1N497), 
    .SUB(OP[1]));
  OR2 X1I516 (.I0(X1N510), .I1(X1N511), .O(S[19]));
  AND2 X1I517 (.I0(OP[2]), .I1(X1N513), .O(X1N510));
  AND2 X1I518 (.I0(X1N24), .I1(X1N512), .O(X1N511));
  LOGIC1 X1I519 (.A(A[19]), .B(B[19]), .O0(OP[0]), .O1(OP[1]), .S(X1N513));
  ADD1 X1I520 (.A(A[19]), .B(B[19]), .CI(X1N523), .CO(X1N538), .S(X1N512), 
    .SUB(OP[1]));
  OR2 X1I531 (.I0(X1N525), .I1(X1N526), .O(S[20]));
  AND2 X1I532 (.I0(OP[2]), .I1(X1N528), .O(X1N525));
  AND2 X1I533 (.I0(X1N24), .I1(X1N527), .O(X1N526));
  LOGIC1 X1I534 (.A(A[20]), .B(B[20]), .O0(OP[0]), .O1(OP[1]), .S(X1N528));
  ADD1 X1I535 (.A(A[20]), .B(B[20]), .CI(X1N538), .CO(X1N553), .S(X1N527), 
    .SUB(OP[1]));
  OR2 X1I546 (.I0(X1N540), .I1(X1N541), .O(S[21]));
  AND2 X1I547 (.I0(OP[2]), .I1(X1N543), .O(X1N540));
  AND2 X1I548 (.I0(X1N24), .I1(X1N542), .O(X1N541));
  LOGIC1 X1I549 (.A(A[21]), .B(B[21]), .O0(OP[0]), .O1(OP[1]), .S(X1N543));
  ADD1 X1I550 (.A(A[21]), .B(B[21]), .CI(X1N553), .CO(X1N568), .S(X1N542), 
    .SUB(OP[1]));
  OR2 X1I561 (.I0(X1N555), .I1(X1N556), .O(S[22]));
  AND2 X1I562 (.I0(OP[2]), .I1(X1N558), .O(X1N555));
  AND2 X1I563 (.I0(X1N24), .I1(X1N557), .O(X1N556));
  LOGIC1 X1I564 (.A(A[22]), .B(B[22]), .O0(OP[0]), .O1(OP[1]), .S(X1N558));
  ADD1 X1I565 (.A(A[22]), .B(B[22]), .CI(X1N568), .CO(X1N583), .S(X1N557), 
    .SUB(OP[1]));
  OR2 X1I576 (.I0(X1N570), .I1(X1N571), .O(S[23]));
  AND2 X1I577 (.I0(OP[2]), .I1(X1N573), .O(X1N570));
  AND2 X1I578 (.I0(X1N24), .I1(X1N572), .O(X1N571));
  LOGIC1 X1I579 (.A(A[23]), .B(B[23]), .O0(OP[0]), .O1(OP[1]), .S(X1N573));
  ADD1 X1I580 (.A(A[23]), .B(B[23]), .CI(X1N583), .CO(X1N598), .S(X1N572), 
    .SUB(OP[1]));
  OR2 X1I591 (.I0(X1N585), .I1(X1N586), .O(S[24]));
  AND2 X1I592 (.I0(OP[2]), .I1(X1N588), .O(X1N585));
  AND2 X1I593 (.I0(X1N24), .I1(X1N587), .O(X1N586));
  LOGIC1 X1I594 (.A(A[24]), .B(B[24]), .O0(OP[0]), .O1(OP[1]), .S(X1N588));
  ADD1 X1I595 (.A(A[24]), .B(B[24]), .CI(X1N598), .CO(X1N613), .S(X1N587), 
    .SUB(OP[1]));
  OR2 X1I606 (.I0(X1N600), .I1(X1N601), .O(S[25]));
  AND2 X1I607 (.I0(OP[2]), .I1(X1N603), .O(X1N600));
  AND2 X1I608 (.I0(X1N24), .I1(X1N602), .O(X1N601));
  LOGIC1 X1I609 (.A(A[25]), .B(B[25]), .O0(OP[0]), .O1(OP[1]), .S(X1N603));
  ADD1 X1I610 (.A(A[25]), .B(B[25]), .CI(X1N613), .CO(X1N628), .S(X1N602), 
    .SUB(OP[1]));
  OR2 X1I621 (.I0(X1N615), .I1(X1N616), .O(S[26]));
  AND2 X1I622 (.I0(OP[2]), .I1(X1N618), .O(X1N615));
  AND2 X1I623 (.I0(X1N24), .I1(X1N617), .O(X1N616));
  LOGIC1 X1I624 (.A(A[26]), .B(B[26]), .O0(OP[0]), .O1(OP[1]), .S(X1N618));
  ADD1 X1I625 (.A(A[26]), .B(B[26]), .CI(X1N628), .CO(X1N643), .S(X1N617), 
    .SUB(OP[1]));
  OR2 X1I636 (.I0(X1N630), .I1(X1N631), .O(S[27]));
  AND2 X1I637 (.I0(OP[2]), .I1(X1N633), .O(X1N630));
  AND2 X1I638 (.I0(X1N24), .I1(X1N632), .O(X1N631));
  LOGIC1 X1I639 (.A(A[27]), .B(B[27]), .O0(OP[0]), .O1(OP[1]), .S(X1N633));
  ADD1 X1I640 (.A(A[27]), .B(B[27]), .CI(X1N643), .CO(X1N658), .S(X1N632), 
    .SUB(OP[1]));
  OR2 X1I651 (.I0(X1N645), .I1(X1N646), .O(S[28]));
  AND2 X1I652 (.I0(OP[2]), .I1(X1N648), .O(X1N645));
  AND2 X1I653 (.I0(X1N24), .I1(X1N647), .O(X1N646));
  LOGIC1 X1I654 (.A(A[28]), .B(B[28]), .O0(OP[0]), .O1(OP[1]), .S(X1N648));
  ADD1 X1I655 (.A(A[28]), .B(B[28]), .CI(X1N658), .CO(X1N673), .S(X1N647), 
    .SUB(OP[1]));
  OR2 X1I666 (.I0(X1N660), .I1(X1N661), .O(S[29]));
  AND2 X1I667 (.I0(OP[2]), .I1(X1N663), .O(X1N660));
  AND2 X1I668 (.I0(X1N24), .I1(X1N662), .O(X1N661));
  LOGIC1 X1I669 (.A(A[29]), .B(B[29]), .O0(OP[0]), .O1(OP[1]), .S(X1N663));
  ADD1 X1I670 (.A(A[29]), .B(B[29]), .CI(X1N673), .CO(X1N688), .S(X1N662), 
    .SUB(OP[1]));
  OR2 X1I681 (.I0(X1N675), .I1(X1N676), .O(S[30]));
  AND2 X1I682 (.I0(OP[2]), .I1(X1N678), .O(X1N675));
  AND2 X1I683 (.I0(X1N24), .I1(X1N677), .O(X1N676));
  LOGIC1 X1I684 (.A(A[30]), .B(B[30]), .O0(OP[0]), .O1(OP[1]), .S(X1N678));
  ADD1 X1I685 (.A(A[30]), .B(B[30]), .CI(X1N688), .CO(X1N706), .S(X1N677), 
    .SUB(OP[1]));
  OR2 X1I696 (.I0(X1N690), .I1(X1N691), .O(S[31]));
  AND2 X1I697 (.I0(OP[2]), .I1(X1N693), .O(X1N690));
  AND2 X1I698 (.I0(X1N24), .I1(X1N692), .O(X1N691));
  LOGIC1 X1I699 (.A(A[31]), .B(B[31]), .O0(OP[0]), .O1(OP[1]), .S(X1N693));
  ADD1 X1I703 (.A(A[31]), .B(B[31]), .CI(X1N706), .CO(CO), .S(X1N692), .SUB
    (OP[1]));
  AND2 X1I714 (.I0(X1N712), .I1(A[0]), .O(X1N164));
  XOR2 X1I719 (.I0(OP[1]), .I1(B[0]), .O(X1N712));
  XOR2 X1I721 (.I0(X1N712), .I1(A[0]), .O(X1N20));
  AND2 X1I729 (.I0(OP[3]), .I1(CO), .O(X1N731));
  OR3 X1I730 (.I0(X1N731), .I1(X1N28), .I2(X1N27), .O(S[0]));
  AND2 X1I746 (.I0(X1N750), .I1(X1N748), .O(X1N24));
  INV X1I747 (.I(OP[3]), .O(X1N748));
  INV X1I749 (.I(OP[2]), .O(X1N750));
  XOR2 X1I753 (.I0(X1N706), .I1(CO), .O(X1N757));
  AND2 X1I756 (.I0(X1N24), .I1(X1N757), .O(OVERFLOW));

endmodule  // ALU2

module FD16CE (C, CE, CLR, D, Q);
  output [15:0] Q;
  input CLR, CE, C;
  input [15:0] D;
  wire [15:0] O, I, IO;
  wire [7:0] DPO, SPO;
  FDCE Q5 (.C(C), .CE(CE), .CLR(CLR), .D(D[5]), .Q(Q[5]));
  FDCE Q1 (.C(C), .CE(CE), .CLR(CLR), .D(D[1]), .Q(Q[1]));
  FDCE Q0 (.C(C), .CE(CE), .CLR(CLR), .D(D[0]), .Q(Q[0]));
  FDCE Q2 (.C(C), .CE(CE), .CLR(CLR), .D(D[2]), .Q(Q[2]));
  FDCE Q3 (.C(C), .CE(CE), .CLR(CLR), .D(D[3]), .Q(Q[3]));
  FDCE Q4 (.C(C), .CE(CE), .CLR(CLR), .D(D[4]), .Q(Q[4]));
  FDCE Q6 (.C(C), .CE(CE), .CLR(CLR), .D(D[6]), .Q(Q[6]));
  FDCE Q7 (.C(C), .CE(CE), .CLR(CLR), .D(D[7]), .Q(Q[7]));
  FDCE Q8 (.C(C), .CE(CE), .CLR(CLR), .D(D[8]), .Q(Q[8]));
  FDCE Q9 (.C(C), .CE(CE), .CLR(CLR), .D(D[9]), .Q(Q[9]));
  FDCE Q10 (.C(C), .CE(CE), .CLR(CLR), .D(D[10]), .Q(Q[10]));
  FDCE Q11 (.C(C), .CE(CE), .CLR(CLR), .D(D[11]), .Q(Q[11]));
  FDCE Q12 (.C(C), .CE(CE), .CLR(CLR), .D(D[12]), .Q(Q[12]));
  FDCE Q13 (.C(C), .CE(CE), .CLR(CLR), .D(D[13]), .Q(Q[13]));
  FDCE Q14 (.C(C), .CE(CE), .CLR(CLR), .D(D[14]), .Q(Q[14]));
  FDCE Q15 (.C(C), .CE(CE), .CLR(CLR), .D(D[15]), .Q(Q[15]));

endmodule  // FD16CE

module REG32 (CLK, EN, I, O);
  wire X1N57;
  FD16CE X1I55 (.C(CLK), .CE(EN), .CLR(X1N57), .D({I[15], I[14], I[13], 
    I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], I[2], 
    I[1], I[0]}), .Q({O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], 
    O[7], O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  FD16CE X1I56 (.C(CLK), .CE(EN), .CLR(X1N57), .D({I[31], I[30], I[29], 
    I[28], I[27], I[26], I[25], I[24], I[23], I[22], I[21], I[20], I[19], 
    I[18], I[17], I[16]}), .Q({O[31], O[30], O[29], O[28], O[27], O[26], 
    O[25], O[24], O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}));
  GND X1I59 (.G(X1N57));

endmodule  // REG32

module INTERRUPT_VECTOR (OUT, PLUS_100, PLUS_80, VECTOR_8000);
  wire [31:0] P, O;
  wire X1N142, X1N97;
  BUF X1I1 (.I(X1N97), .O(O[9]));
  INV X1I10 (.I(X1N97), .O(O[25]));
  INV X1I11 (.I(X1N97), .O(O[22]));
  INV X1I12 (.I(X1N97), .O(O[23]));
  INV X1I13 (.I(X1N97), .O(O[31]));
  GND X1I135 (.G(X1N97));
  MUX2_1X32 X1I139 (.A({O[31], O[30], O[29], O[28], O[27], O[26], O[25], 
    O[24], O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16], O[15], 
    O[14], O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5], O[4], 
    O[3], O[2], O[1], O[0]}), .B({P[31], P[30], P[29], P[28], P[27], P[26], 
    P[25], P[24], P[23], P[22], P[21], P[20], P[19], P[18], P[17], P[16], 
    P[15], P[14], P[13], P[12], P[11], P[10], P[9], P[8], P[7], P[6], P[5], 
    P[4], P[3], P[2], P[1], P[0]}), .SB(VECTOR_8000), .S({OUT[31], OUT[30], 
    OUT[29], OUT[28], OUT[27], OUT[26], OUT[25], OUT[24], OUT[23], OUT[22], 
    OUT[21], OUT[20], OUT[19], OUT[18], OUT[17], OUT[16], OUT[15], OUT[14], 
    OUT[13], OUT[12], OUT[11], OUT[10], OUT[9], OUT[8], OUT[7], OUT[6], 
    OUT[5], OUT[4], OUT[3], OUT[2], OUT[1], OUT[0]}));
  GND X1I143 (.G(X1N142));
  BUF X1I144 (.I(X1N142), .O(P[11]));
  BUF X1I145 (.I(X1N142), .O(P[14]));
  BUF X1I146 (.I(X1N142), .O(P[1]));
  BUF X1I147 (.I(X1N142), .O(P[0]));
  BUF X1I148 (.I(X1N142), .O(P[3]));
  BUF X1I149 (.I(X1N142), .O(P[2]));
  BUF X1I150 (.I(X1N142), .O(P[17]));
  BUF X1I151 (.I(X1N142), .O(P[16]));
  BUF X1I152 (.I(X1N142), .O(P[15]));
  BUF X1I153 (.I(X1N142), .O(P[12]));
  BUF X1I154 (.I(X1N142), .O(P[13]));
  BUF X1I155 (.I(PLUS_100), .O(P[8]));
  BUF X1I156 (.I(X1N142), .O(P[6]));
  BUF X1I157 (.I(PLUS_80), .O(P[7]));
  BUF X1I158 (.I(X1N142), .O(P[4]));
  BUF X1I159 (.I(X1N142), .O(P[5]));
  BUF X1I160 (.I(X1N142), .O(P[19]));
  BUF X1I161 (.I(X1N142), .O(P[18]));
  BUF X1I162 (.I(X1N142), .O(P[21]));
  BUF X1I163 (.I(X1N142), .O(P[20]));
  BUF X1I164 (.I(X1N142), .O(P[30]));
  INV X1I165 (.I(X1N142), .O(P[31]));
  BUF X1I166 (.I(X1N142), .O(P[23]));
  BUF X1I167 (.I(X1N142), .O(P[22]));
  BUF X1I168 (.I(X1N142), .O(P[25]));
  BUF X1I169 (.I(X1N142), .O(P[24]));
  BUF X1I170 (.I(X1N142), .O(P[27]));
  BUF X1I171 (.I(X1N142), .O(P[26]));
  BUF X1I172 (.I(X1N142), .O(P[29]));
  BUF X1I173 (.I(X1N142), .O(P[28]));
  BUF X1I174 (.I(X1N142), .O(P[10]));
  BUF X1I175 (.I(X1N142), .O(P[9]));
  BUF X1I2 (.I(X1N97), .O(O[10]));
  BUF X1I38 (.I(X1N97), .O(O[30]));
  BUF X1I39 (.I(X1N97), .O(O[20]));
  BUF X1I40 (.I(X1N97), .O(O[21]));
  BUF X1I41 (.I(X1N97), .O(O[18]));
  BUF X1I42 (.I(X1N97), .O(O[19]));
  BUF X1I43 (.I(X1N97), .O(O[5]));
  BUF X1I44 (.I(X1N97), .O(O[4]));
  BUF X1I45 (.I(PLUS_80), .O(O[7]));
  BUF X1I46 (.I(X1N97), .O(O[6]));
  BUF X1I47 (.I(PLUS_100), .O(O[8]));
  BUF X1I48 (.I(X1N97), .O(O[13]));
  BUF X1I49 (.I(X1N97), .O(O[12]));
  INV X1I5 (.I(X1N97), .O(O[28]));
  BUF X1I50 (.I(X1N97), .O(O[15]));
  BUF X1I51 (.I(X1N97), .O(O[16]));
  BUF X1I52 (.I(X1N97), .O(O[17]));
  BUF X1I53 (.I(X1N97), .O(O[2]));
  BUF X1I54 (.I(X1N97), .O(O[3]));
  BUF X1I55 (.I(X1N97), .O(O[0]));
  BUF X1I56 (.I(X1N97), .O(O[1]));
  INV X1I6 (.I(X1N97), .O(O[29]));
  INV X1I7 (.I(X1N97), .O(O[26]));
  BUF X1I72 (.I(X1N97), .O(O[14]));
  INV X1I8 (.I(X1N97), .O(O[27]));
  INV X1I9 (.I(X1N97), .O(O[24]));
  BUF X1I96 (.I(X1N97), .O(O[11]));

endmodule  // INTERRUPT_VECTOR

module MUX3_1X32 (A, B, C, S);
  output [31:0] S;
  input [31:0] A;
  wire [31:0] TEMP, C;
  MUX2_1X32 X1I1 (.A({TEMP[31], TEMP[30], TEMP[29], TEMP[28], TEMP[27], 
    TEMP[26], TEMP[25], TEMP[24], TEMP[23], TEMP[22], TEMP[21], TEMP[20], 
    TEMP[19], TEMP[18], TEMP[17], TEMP[16], TEMP[15], TEMP[14], TEMP[13], 
    TEMP[12], TEMP[11], TEMP[10], TEMP[9], TEMP[8], TEMP[7], TEMP[6], 
    TEMP[5], TEMP[4], TEMP[3], TEMP[2], TEMP[1], TEMP[0]}), .B({C[31], C[30]
    , C[29], C[28], C[27], C[26], C[25], C[24], C[23], C[22], C[21], C[20], 
    C[19], C[18], C[17], C[16], C[15], C[14], C[13], C[12], C[11], C[10], 
    C[9], C[8], C[7], C[6], C[5], C[4], C[3], C[2], C[1], C[0]}), .SB(C), 
    .S({S[31], S[30], S[29], S[28], S[27], S[26], S[25], S[24], S[23], S[22]
    , S[21], S[20], S[19], S[18], S[17], S[16], S[15], S[14], S[13], S[12], 
    S[11], S[10], S[9], S[8], S[7], S[6], S[5], S[4], S[3], S[2], S[1], S[0]
    }));
  MUX2_1X32 X1I2 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25], A[24]
    , A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16], A[15], A[14], 
    A[13], A[12], A[11], A[10], A[9], A[8], A[7], A[6], A[5], A[4], A[3], 
    A[2], A[1], A[0]}), .B({B[31], B[30], B[29], B[28], B[27], B[26], B[25]
    , B[24], B[23], B[22], B[21], B[20], B[19], B[18], B[17], B[16], B[15], 
    B[14], B[13], B[12], B[11], B[10], B[9], B[8], B[7], B[6], B[5], B[4], 
    B[3], B[2], B[1], B[0]}), .SB(B), .S({TEMP[31], TEMP[30], TEMP[29], 
    TEMP[28], TEMP[27], TEMP[26], TEMP[25], TEMP[24], TEMP[23], TEMP[22], 
    TEMP[21], TEMP[20], TEMP[19], TEMP[18], TEMP[17], TEMP[16], TEMP[15], 
    TEMP[14], TEMP[13], TEMP[12], TEMP[11], TEMP[10], TEMP[9], TEMP[8], 
    TEMP[7], TEMP[6], TEMP[5], TEMP[4], TEMP[3], TEMP[2], TEMP[1], TEMP[0]})
    );

endmodule  // MUX3_1X32

module RANDOM (CLK, P);
  wire X1N130, X1N121, X1N141, X1N124, X1N115, X1N134, X1N127, X1N118, 
    X1N137, X1N92, RESET;
  INV X1I114 (.I(P[9]), .O(X1N115));
  INV X1I117 (.I(P[10]), .O(X1N118));
  INV X1I123 (.I(P[12]), .O(X1N124));
  INV X1I126 (.I(P[13]), .O(X1N127));
  AND2 X1I129 (.I0(P[9]), .I1(P[8]), .O(X1N130));
  AND2 X1I139 (.I0(P[11]), .I1(X1N134), .O(X1N137));
  AND2 X1I143 (.I0(P[12]), .I1(X1N137), .O(X1N141));
  AND2 X1I168 (.I0(P[10]), .I1(X1N130), .O(X1N134));
  OR2B1 X1I169 (.I0(P[11]), .I1(RESET), .O(X1N121));
  AND2 X1I182 (.I0(P[13]), .I1(X1N141), .O(RESET));
  FDE X1I78 (.C(CLK), .CE(X1N134), .D(X1N121), .Q(P[11]));
  FDE X1I79 (.C(CLK), .CE(X1N130), .D(X1N118), .Q(P[10]));
  FDE X1I80 (.C(CLK), .CE(X1N141), .D(X1N127), .Q(P[13]));
  FDE X1I81 (.C(CLK), .CE(X1N137), .D(X1N124), .Q(P[12]));
  FDE X1I82 (.C(CLK), .CE(P[8]), .D(X1N115), .Q(P[9]));
  FDE X1I83 (.C(CLK), .D(X1N92), .Q(P[8]));
  INV X1I90 (.I(P[8]), .O(X1N92));

// WARNING - Component X1I83 has unconnected pins: 1 input, 0 output, 0 inout.
endmodule  // RANDOM

module X7SEG (\D,C,B,A , .D,C,B,A(\D,C,B,A ), \SA,SB,SC,SD,SE,SF,SG , 
    .SA,SB,SC,SD,SE,SF,SG(\SA,SB,SC,SD,SE,SF,SG ));
  wire X1N131, X1N105, X1N142, X1N133, X1N106, X1N161, X1N171, X1N144, 
    X1N135, X1N108, X1N190, X1N163, X1N191, X1N173, X1N146, X1N129, X1N175, 
    X1N157, X1N148, X1N168, X1N159, X1N188, SA, SB, SC, SD, SE, SF, SG, 
    X1N60, A, X1N62, B, C, D, X1N59;
  AND4B3 X1I1 (.I0(B), .I1(C), .I2(D), .I3(A), .O(X1N148));
  NOR3 X1I104 (.I0(X1N106), .I1(X1N105), .I2(X1N108), .O(SE));
  AND3B2 X1I110 (.I0(C), .I1(D), .I2(A), .O(X1N157));
  AND3B2 X1I111 (.I0(C), .I1(D), .I2(B), .O(X1N159));
  AND3B1 X1I112 (.I0(D), .I1(A), .I2(B), .O(X1N161));
  AND4B1 X1I113 (.I0(B), .I1(A), .I2(C), .I3(D), .O(X1N163));
  NOR4 X1I128 (.I0(X1N129), .I1(X1N131), .I2(X1N133), .I3(X1N135), .O(SB));
  NOR4 X1I139 (.I0(X1N144), .I1(X1N146), .I2(X1N142), .I3(X1N148), .O(SA));
  NOR4 X1I150 (.I0(X1N168), .I1(X1N171), .I2(X1N173), .I3(X1N175), .O(SD));
  NOR4 X1I153 (.I0(X1N163), .I1(X1N161), .I2(X1N159), .I3(X1N157), .O(SF));
  AND3B3 X1I177 (.I0(B), .I1(C), .I2(D), .O(X1N188));
  AND4B1 X1I179 (.I0(D), .I1(A), .I2(B), .I3(C), .O(X1N190));
  AND4B2 X1I180 (.I0(A), .I1(B), .I2(C), .I3(D), .O(X1N191));
  NOR3 X1I189 (.I0(X1N191), .I1(X1N190), .I2(X1N188), .O(SG));
  AND4B3 X1I2 (.I0(A), .I1(B), .I2(D), .I3(C), .O(X1N142));
  MU_TITLE X1I201 ();
  AND4B2 X1I24 (.I0(B), .I1(D), .I2(C), .I3(A), .O(X1N135));
  AND4B2 X1I25 (.I0(A), .I1(D), .I2(C), .I3(B), .O(X1N133));
  AND3 X1I26 (.I0(A), .I1(B), .I2(D), .O(X1N131));
  AND3B1 X1I27 (.I0(A), .I1(C), .I2(D), .O(X1N129));
  AND4B1 X1I3 (.I0(C), .I1(A), .I2(B), .I3(D), .O(X1N146));
  AND4B1 X1I4 (.I0(B), .I1(A), .I2(C), .I3(D), .O(X1N144));
  AND3B1 X1I43 (.I0(A), .I1(C), .I2(D), .O(X1N59));
  AND3 X1I44 (.I0(B), .I1(C), .I2(D), .O(X1N62));
  AND4B3 X1I46 (.I0(A), .I1(C), .I2(D), .I3(B), .O(X1N60));
  NOR3 X1I58 (.I0(X1N62), .I1(X1N59), .I2(X1N60), .O(SC));
  AND4B3 X1I67 (.I0(B), .I1(C), .I2(D), .I3(A), .O(X1N175));
  AND4B3 X1I76 (.I0(A), .I1(B), .I2(D), .I3(C), .O(X1N173));
  AND3 X1I77 (.I0(A), .I1(B), .I2(C), .O(X1N171));
  AND4B2 X1I81 (.I0(A), .I1(C), .I2(B), .I3(D), .O(X1N168));
  AND3B2 X1I87 (.I0(B), .I1(D), .I2(C), .O(X1N105));
  AND3B2 X1I89 (.I0(B), .I1(C), .I2(A), .O(X1N106));
  AND2B1 X1I98 (.I0(D), .I1(A), .O(X1N108));

endmodule  // X7SEG

module X14SEG (IN, LEFT, RIGHT);
  X7SEG X1I1 (.D,C,B,A({IN[3], IN[2], IN[1], IN[0]}), .SA,SB,SC,SD,SE,SF,SG(
    {RIGHT[6], RIGHT[5], RIGHT[4], RIGHT[3], RIGHT[2], RIGHT[1], RIGHT[0]})
    );
  X7SEG X1I2 (.D,C,B,A({IN[7], IN[6], IN[5], IN[4]}), 
    .SA,SB,SC,SD,SE,SF,SG({LEFT[6], LEFT[5], LEFT[4], LEFT[3], LEFT[2], 
    LEFT[1], LEFT[0]}));

endmodule  // X14SEG

module PC32 (CLK, EN, I, O);
  wire [31:0] OA, IA, I, O;
  wire X1N57;
  INV X1I141 (.I(I[31]), .O(IA[31]));
  BUF X1I168 (.I(I[30]), .O(IA[30]));
  INV X1I169 (.I(I[29]), .O(IA[29]));
  INV X1I170 (.I(I[28]), .O(IA[28]));
  INV X1I171 (.I(I[27]), .O(IA[27]));
  INV X1I172 (.I(I[26]), .O(IA[26]));
  INV X1I173 (.I(I[25]), .O(IA[25]));
  INV X1I174 (.I(I[24]), .O(IA[24]));
  INV X1I175 (.I(I[23]), .O(IA[23]));
  INV X1I176 (.I(I[22]), .O(IA[22]));
  BUF X1I177 (.I(I[21]), .O(IA[21]));
  BUF X1I178 (.I(I[20]), .O(IA[20]));
  BUF X1I179 (.I(I[19]), .O(IA[19]));
  BUF X1I180 (.I(I[18]), .O(IA[18]));
  BUF X1I198 (.I(I[17]), .O(IA[17]));
  BUF X1I199 (.I(I[16]), .O(IA[16]));
  BUF X1I200 (.I(I[14]), .O(IA[14]));
  BUF X1I201 (.I(I[15]), .O(IA[15]));
  BUF X1I202 (.I(I[12]), .O(IA[12]));
  BUF X1I203 (.I(I[13]), .O(IA[13]));
  BUF X1I204 (.I(I[10]), .O(IA[10]));
  BUF X1I205 (.I(I[11]), .O(IA[11]));
  BUF X1I206 (.I(I[8]), .O(IA[8]));
  BUF X1I207 (.I(I[9]), .O(IA[9]));
  BUF X1I208 (.I(I[6]), .O(IA[6]));
  BUF X1I209 (.I(I[7]), .O(IA[7]));
  BUF X1I210 (.I(I[4]), .O(IA[4]));
  BUF X1I211 (.I(I[5]), .O(IA[5]));
  BUF X1I212 (.I(I[1]), .O(IA[1]));
  BUF X1I213 (.I(I[0]), .O(IA[0]));
  BUF X1I214 (.I(I[3]), .O(IA[3]));
  BUF X1I215 (.I(I[2]), .O(IA[2]));
  INV X1I402 (.I(OA[31]), .O(O[31]));
  BUF X1I407 (.I(OA[30]), .O(O[30]));
  INV X1I408 (.I(OA[28]), .O(O[28]));
  INV X1I409 (.I(OA[29]), .O(O[29]));
  INV X1I410 (.I(OA[26]), .O(O[26]));
  INV X1I411 (.I(OA[27]), .O(O[27]));
  INV X1I412 (.I(OA[24]), .O(O[24]));
  INV X1I413 (.I(OA[25]), .O(O[25]));
  INV X1I414 (.I(OA[22]), .O(O[22]));
  INV X1I415 (.I(OA[23]), .O(O[23]));
  BUF X1I416 (.I(OA[20]), .O(O[20]));
  BUF X1I417 (.I(OA[21]), .O(O[21]));
  BUF X1I418 (.I(OA[18]), .O(O[18]));
  BUF X1I419 (.I(OA[19]), .O(O[19]));
  BUF X1I437 (.I(OA[5]), .O(O[5]));
  BUF X1I438 (.I(OA[4]), .O(O[4]));
  BUF X1I439 (.I(OA[7]), .O(O[7]));
  BUF X1I440 (.I(OA[6]), .O(O[6]));
  BUF X1I441 (.I(OA[9]), .O(O[9]));
  BUF X1I442 (.I(OA[8]), .O(O[8]));
  BUF X1I443 (.I(OA[11]), .O(O[11]));
  BUF X1I444 (.I(OA[10]), .O(O[10]));
  BUF X1I445 (.I(OA[13]), .O(O[13]));
  BUF X1I446 (.I(OA[12]), .O(O[12]));
  BUF X1I447 (.I(OA[15]), .O(O[15]));
  BUF X1I448 (.I(OA[14]), .O(O[14]));
  BUF X1I449 (.I(OA[16]), .O(O[16]));
  BUF X1I450 (.I(OA[17]), .O(O[17]));
  BUF X1I451 (.I(OA[2]), .O(O[2]));
  BUF X1I452 (.I(OA[3]), .O(O[3]));
  BUF X1I453 (.I(OA[0]), .O(O[0]));
  BUF X1I454 (.I(OA[1]), .O(O[1]));
  FD16CE X1I55 (.C(CLK), .CE(EN), .CLR(X1N57), .D({IA[15], IA[14], IA[13], 
    IA[12], IA[11], IA[10], IA[9], IA[8], IA[7], IA[6], IA[5], IA[4], IA[3]
    , IA[2], IA[1], IA[0]}), .Q({OA[15], OA[14], OA[13], OA[12], OA[11], 
    OA[10], OA[9], OA[8], OA[7], OA[6], OA[5], OA[4], OA[3], OA[2], OA[1], 
    OA[0]}));
  FD16CE X1I56 (.C(CLK), .CE(EN), .CLR(X1N57), .D({IA[31], IA[30], IA[29], 
    IA[28], IA[27], IA[26], IA[25], IA[24], IA[23], IA[22], IA[21], IA[20], 
    IA[19], IA[18], IA[17], IA[16]}), .Q({OA[31], OA[30], OA[29], OA[28], 
    OA[27], OA[26], OA[25], OA[24], OA[23], OA[22], OA[21], OA[20], OA[19], 
    OA[18], OA[17], OA[16]}));
  GND X1I59 (.G(X1N57));

endmodule  // PC32

module REG6 (CLK, EN, I, O, RES);
  FDRE X1I1 (.C(CLK), .CE(EN), .D(I[4]), .Q(O[4]), .R(RES));
  FDRE X1I2 (.C(CLK), .CE(EN), .D(I[3]), .Q(O[3]), .R(RES));
  FDRE X1I3 (.C(CLK), .CE(EN), .D(I[2]), .Q(O[2]), .R(RES));
  FDRE X1I39 (.C(CLK), .CE(EN), .D(I[5]), .Q(O[5]), .R(RES));
  FDRE X1I4 (.C(CLK), .CE(EN), .D(I[1]), .Q(O[1]), .R(RES));
  FDRE X1I5 (.C(CLK), .CE(EN), .D(I[0]), .Q(O[0]), .R(RES));

endmodule  // REG6

module CACHE (ADDRESS, CLK, DATAIN, DATA, HIT, PFNIN, WRITE);
  wire [19:0] PFN;
  wire [9:0] ADDRESS;
  wire VCC;
  VCC X1I437 (.P(VCC));
  GND X1I447 (.G(HIT));

endmodule  // CACHE

module SOP3 (I0, I1, I2, O);
  output O;
  input I2, I1, I0;
  wire [15:0] Q, D;
  wire I01;
  AND2 X1I31 (.I0(I0), .I1(I1), .O(I01));
  OR2 X1I32 (.I0(I01), .I1(I2), .O(O));

endmodule  // SOP3

module M2_1X20 (A, B, SB, S);
  output [19:0] S;
  input [19:0] B;
  input [19:0] A;
  M2_1 X1I100 (.D0(A[17]), .D1(B[17]), .O(S[17]), .S0(SB));
  M2_1 X1I105 (.D0(A[15]), .D1(B[15]), .O(S[15]), .S0(SB));
  M2_1 X1I106 (.D0(A[14]), .D1(B[14]), .O(S[14]), .S0(SB));
  M2_1 X1I107 (.D0(A[12]), .D1(B[12]), .O(S[12]), .S0(SB));
  M2_1 X1I108 (.D0(A[13]), .D1(B[13]), .O(S[13]), .S0(SB));
  M2_1 X1I109 (.D0(A[9]), .D1(B[9]), .O(S[9]), .S0(SB));
  M2_1 X1I110 (.D0(A[8]), .D1(B[8]), .O(S[8]), .S0(SB));
  M2_1 X1I111 (.D0(A[10]), .D1(B[10]), .O(S[10]), .S0(SB));
  M2_1 X1I112 (.D0(A[11]), .D1(B[11]), .O(S[11]), .S0(SB));
  M2_1 X1I117 (.D0(A[7]), .D1(B[7]), .O(S[7]), .S0(SB));
  M2_1 X1I118 (.D0(A[6]), .D1(B[6]), .O(S[6]), .S0(SB));
  M2_1 X1I119 (.D0(A[4]), .D1(B[4]), .O(S[4]), .S0(SB));
  M2_1 X1I120 (.D0(A[5]), .D1(B[5]), .O(S[5]), .S0(SB));
  M2_1 X1I121 (.D0(A[1]), .D1(B[1]), .O(S[1]), .S0(SB));
  M2_1 X1I122 (.D0(A[0]), .D1(B[0]), .O(S[0]), .S0(SB));
  M2_1 X1I123 (.D0(A[2]), .D1(B[2]), .O(S[2]), .S0(SB));
  M2_1 X1I124 (.D0(A[3]), .D1(B[3]), .O(S[3]), .S0(SB));
  M2_1 X1I97 (.D0(A[19]), .D1(B[19]), .O(S[19]), .S0(SB));
  M2_1 X1I98 (.D0(A[18]), .D1(B[18]), .O(S[18]), .S0(SB));
  M2_1 X1I99 (.D0(A[16]), .D1(B[16]), .O(S[16]), .S0(SB));

endmodule  // M2_1X20

module AND6 (I0, I1, I2, I3, I4, I5, O);
  output O;
  input I5, I4, I3, I2, I1, I0;
  wire I35;
  AND3 X1I69 (.I0(I3), .I1(I4), .I2(I5), .O(I35));
  AND4 X1I85 (.I0(I0), .I1(I1), .I2(I2), .I3(I35), .O(O));

endmodule  // AND6

module FD4CE (C, CE, CLR, .D0(D[0]), .D1(D[1]), .D2(D[2]), .D3(D[3]), .Q0
    (Q[0]), .Q1(Q[1]), .Q2(Q[2]), .Q3(Q[3]));
  output [3:0] Q;
  input CLR, CE, C;
  input [3:0] D;
  wire [15:0] O, I, Q, D, IO;
  wire [7:0] DPO, SPO;
  FDCE Q2 (.C(C), .CE(CE), .CLR(CLR), .D(D[2]), .Q(Q[2]));
  FDCE Q0 (.C(C), .CE(CE), .CLR(CLR), .D(D[0]), .Q(Q[0]));
  FDCE Q1 (.C(C), .CE(CE), .CLR(CLR), .D(D[1]), .Q(Q[1]));
  FDCE Q3 (.C(C), .CE(CE), .CLR(CLR), .D(D[3]), .Q(Q[3]));

endmodule  // FD4CE

module MMUSEG (CLK, HIT_X, HIT_Y, \VPN[19:0],ASID[5:0],GLOB , 
    .VPN,ASID[5:0],GLOB[19:0](\VPN,ASID[5:0],GLOB[19:0] ), WRITE_X, WRITE_Y)
    ;
  wire [19:0] VPN;
  wire [5:0] ASID;
  wire X1N110, X1N101, X1N111, X1N112, X1N103, X1N114, X1N431, X1N360, 
    X1N108, X1N370, X1N280, X1N118, X1N109, X1N371, X1N290, X1N281, X1N272, 
    X1N263, X1N119, X1N372, X1N282, X1N273, X1N481, X1N373, X1N364, X1N283, 
    X1N274, X1N374, X1N365, X1N284, X1N275, X1N483, X1N375, X1N366, X1N285, 
    X1N276, X1N466, X1N367, X1N286, X1N277, X1N485, X1N368, X1N287, X1N278, 
    X1N477, X1N369, X1N288, X1N279, X1N487, X1N289, X1N479, X1N489, HIT, 
    ASID_MATCH, X1N24, X1N19, X1N74, X1N75, X1N96, X1N99, GLOB, WRITE;
  XNOR2 X1I100 (.I0(ASID[3]), .I1(X1N101), .O(X1N109));
  XNOR2 X1I102 (.I0(ASID[2]), .I1(X1N103), .O(X1N108));
  XNOR2 X1I104 (.I0(ASID[1]), .I1(X1N74), .O(X1N112));
  XNOR2 X1I105 (.I0(ASID[0]), .I1(X1N75), .O(X1N114));
  AND6 X1I107 (.I0(X1N114), .I1(X1N112), .I2(X1N108), .I3(X1N109), .I4
    (X1N110), .I5(X1N111), .O(X1N118));
  FD4CE X1I11 (.C(CLK), .CE(WRITE), .CLR(X1N19), .D0(VPN[11]), .D1(VPN[10])
    , .D2(VPN[9]), .D3(VPN[8]), .Q0(X1N279), .Q1(X1N280), .Q2(X1N281), .Q3
    (X1N282));
  OR2 X1I117 (.I0(X1N119), .I1(X1N118), .O(ASID_MATCH));
  FD4CE X1I12 (.C(CLK), .CE(WRITE), .CLR(X1N19), .D0(VPN[7]), .D1(VPN[6]), 
    .D2(VPN[5]), .D3(VPN[4]), .Q0(X1N283), .Q1(X1N284), .Q2(X1N285), .Q3
    (X1N286));
  FD4CE X1I13 (.C(CLK), .CE(WRITE), .CLR(X1N24), .D0(ASID[5]), .D1(ASID[4])
    , .D2(ASID[3]), .D3(ASID[2]), .Q0(X1N96), .Q1(X1N99), .Q2(X1N101), .Q3
    (X1N103));
  FD4CE X1I14 (.C(CLK), .CE(WRITE), .CLR(X1N19), .D0(VPN[3]), .D1(VPN[2]), 
    .D2(VPN[1]), .D3(VPN[0]), .Q0(X1N287), .Q1(X1N288), .Q2(X1N289), .Q3
    (X1N290));
  FDCE X1I16 (.C(CLK), .CE(WRITE), .CLR(X1N24), .D(ASID[1]), .Q(X1N74));
  FDCE X1I17 (.C(CLK), .CE(WRITE), .CLR(X1N24), .D(ASID[0]), .Q(X1N75));
  FDCE X1I18 (.C(CLK), .CE(WRITE), .CLR(X1N24), .D(GLOB), .Q(X1N119));
  XNOR2 X1I255 (.I0(VPN[4]), .I1(X1N286), .O(X1N371));
  XNOR2 X1I256 (.I0(VPN[5]), .I1(X1N285), .O(X1N370));
  XNOR2 X1I257 (.I0(VPN[6]), .I1(X1N284), .O(X1N369));
  XNOR2 X1I258 (.I0(VPN[7]), .I1(X1N283), .O(X1N368));
  XNOR2 X1I259 (.I0(VPN[8]), .I1(X1N282), .O(X1N367));
  XNOR2 X1I260 (.I0(VPN[9]), .I1(X1N281), .O(X1N375));
  XNOR2 X1I261 (.I0(VPN[10]), .I1(X1N280), .O(X1N366));
  XNOR2 X1I262 (.I0(VPN[11]), .I1(X1N279), .O(X1N365));
  XNOR2 X1I264 (.I0(VPN[15]), .I1(X1N275), .O(X1N479));
  XNOR2 X1I265 (.I0(VPN[14]), .I1(X1N276), .O(X1N477));
  XNOR2 X1I266 (.I0(VPN[12]), .I1(X1N278), .O(X1N364));
  XNOR2 X1I267 (.I0(VPN[13]), .I1(X1N277), .O(X1N466));
  XNOR2 X1I268 (.I0(VPN[17]), .I1(X1N273), .O(X1N483));
  XNOR2 X1I269 (.I0(VPN[16]), .I1(X1N274), .O(X1N481));
  XNOR2 X1I270 (.I0(VPN[18]), .I1(X1N272), .O(X1N485));
  XNOR2 X1I271 (.I0(VPN[19]), .I1(X1N263), .O(X1N487));
  GND X1I28 (.G(X1N24));
  XNOR2 X1I291 (.I0(VPN[3]), .I1(X1N287), .O(X1N372));
  XNOR2 X1I292 (.I0(VPN[2]), .I1(X1N288), .O(X1N373));
  XNOR2 X1I293 (.I0(VPN[1]), .I1(X1N289), .O(X1N374));
  XNOR2 X1I294 (.I0(VPN[0]), .I1(X1N290), .O(X1N360));
  GND X1I31 (.G(X1N19));
  FD4CE X1I4 (.C(CLK), .CE(WRITE), .CLR(X1N19), .D0(VPN[15]), .D1(VPN[14]), 
    .D2(VPN[13]), .D3(VPN[12]), .Q0(X1N275), .Q1(X1N276), .Q2(X1N277), .Q3
    (X1N278));
  AND16 X1I400 (.I0(X1N360), .I1(X1N374), .I10(X1N366), .I11(X1N365), .I12
    (X1N364), .I13(X1N466), .I14(X1N489), .I15(ASID_MATCH), .I2(X1N373), .I3
    (X1N372), .I4(X1N371), .I5(X1N370), .I6(X1N369), .I7(X1N368), .I8
    (X1N367), .I9(X1N375), .O(HIT));
  AND2 X1I411 (.I0(WRITE_Y), .I1(WRITE_X), .O(WRITE));
  BUFE X1I417 (.E(HIT), .I(X1N431), .O(HIT_X));
  BUFE X1I427 (.E(HIT), .I(X1N431), .O(HIT_Y));
  GND X1I430 (.G(X1N431));
  AND6 X1I476 (.I0(X1N477), .I1(X1N479), .I2(X1N481), .I3(X1N483), .I4
    (X1N485), .I5(X1N487), .O(X1N489));
  XNOR2 X1I76 (.I0(ASID[5]), .I1(X1N96), .O(X1N111));
  FD4CE X1I8 (.C(CLK), .CE(WRITE), .CLR(X1N19), .D0(VPN[19]), .D1(VPN[18]), 
    .D2(VPN[17]), .D3(VPN[16]), .Q0(X1N263), .Q1(X1N272), .Q2(X1N273), .Q3
    (X1N274));
  XNOR2 X1I98 (.I0(ASID[4]), .I1(X1N99), .O(X1N110));

ERROR - Ports should not have increments other than 1
endmodule  // MMUSEG

module D3_8E (.A0(A[0]), .A1(A[1]), .A2(A[2]), .D0(D[0]), .D1(D[1]), .D2
    (D[2]), .D3(D[3]), .D4(D[4]), .D5(D[5]), .D6(D[6]), .D7(D[7]), E);
  output [7:0] D;
  input E;
  input [2:0] A;
  wire [63:0] A;
  wire [15:0] Q, D, O, I, IO;
  wire [7:0] DPO, SPO;
  AND4 X1I30 (.I0(A[2]), .I1(A[1]), .I2(A[0]), .I3(E), .O(D[7]));
  AND4B1 X1I31 (.I0(A[0]), .I1(A[2]), .I2(A[1]), .I3(E), .O(D[6]));
  AND4B1 X1I32 (.I0(A[1]), .I1(A[2]), .I2(A[0]), .I3(E), .O(D[5]));
  AND4B2 X1I33 (.I0(A[1]), .I1(A[0]), .I2(A[2]), .I3(E), .O(D[4]));
  AND4B1 X1I34 (.I0(A[2]), .I1(A[0]), .I2(A[1]), .I3(E), .O(D[3]));
  AND4B2 X1I35 (.I0(A[2]), .I1(A[0]), .I2(A[1]), .I3(E), .O(D[2]));
  AND4B2 X1I36 (.I0(A[2]), .I1(A[1]), .I2(A[0]), .I3(E), .O(D[1]));
  AND4B3 X1I37 (.I0(A[2]), .I1(A[1]), .I2(A[0]), .I3(E), .O(D[0]));

endmodule  // D3_8E

module MMU (CLK, DIRTY, ENTRY_HI, ENTRY_HI_OUT, ENTRY_LO, ENTRY_LO_OUT, HIT
    , HIT_BUT_NOT_VALID, INDEX_IN, INDEX_OUT, LOOK_UP, NO_CACHE, PFN, READ, 
    VPN_INTO, WRITE_IN);
  wire [31:0] ENTRY_HI_A, ENTRY_LO_B, ENTRY_LO_A, ENTRY_HI_B, ENTRY_LO_OUT;
  wire [19:0] LOOKUP_VPN, PFN;
  wire [5:0] INDEX_IN;
  wire X1N610, X1N611, X1N612, X1N613, X1N614, X1N560, X1N660, X1N615, 
    X1N616, X1N932, X1N347, X1N960, X1N870, X1N726, X1N627, X1N609, X1N871, 
    X1N953, X1N872, X1N782, X1N584, X1N981, X1N873, X1N693, X1N946, X1N874, 
    X1N974, X1N875, X1N939, X1N759, X1N967, X1N868, X1N869, X1N1240, X1N1080
    , X1N1315, X1N1226, X1N1082, X1N1283, X1N1185, X1N1249, X1N1096, X1N1087
    , X1N1078, X1N1088, X1N1089, WRITE;
  supply0 GND;
  PULLUP X1I1000 (.O(X1N872));
  PULLUP X1I1002 (.O(X1N869));
  PULLUP X1I1004 (.O(X1N870));
  PULLUP X1I1005 (.O(X1N932));
  PULLUP X1I1009 (.O(X1N939));
  PULLUP X1I1011 (.O(X1N946));
  PULLUP X1I1013 (.O(X1N953));
  PULLUP X1I1015 (.O(X1N960));
  PULLUP X1I1017 (.O(X1N967));
  PULLUP X1I1019 (.O(X1N974));
  PULLUP X1I1021 (.O(X1N981));
  NAND4 X1I1023 (.I0(X1N875), .I1(X1N871), .I2(X1N872), .I3(X1N870), .O
    (X1N1078));
  NAND4 X1I1032 (.I0(X1N874), .I1(X1N871), .I2(X1N869), .I3(X1N870), .O
    (X1N1080));
  NAND4 X1I1040 (.I0(X1N873), .I1(X1N872), .I2(X1N869), .I3(X1N870), .O
    (X1N1082));
  NAND4 X1I1046 (.I0(X1N981), .I1(X1N974), .I2(X1N953), .I3(X1N946), .O
    (X1N1088));
  NAND4 X1I1047 (.I0(X1N981), .I1(X1N967), .I2(X1N953), .I3(X1N939), .O
    (X1N1089));
  NAND4 X1I1048 (.I0(X1N981), .I1(X1N974), .I2(X1N967), .I3(X1N960), .O
    (X1N1087));
  AND2 X1I1189 (.I0(INDEX_OUT[5]), .I1(WRITE), .O(X1N347));
  RAM32X32S X1I119 (.A0(INDEX_OUT[0]), .A1(INDEX_OUT[1]), .A2(INDEX_OUT[2])
    , .A3(INDEX_OUT[3]), .A4(INDEX_OUT[4]), .D({ENTRY_HI[31], ENTRY_HI[30], 
    ENTRY_HI[29], ENTRY_HI[28], ENTRY_HI[27], ENTRY_HI[26], ENTRY_HI[25], 
    ENTRY_HI[24], ENTRY_HI[23], ENTRY_HI[22], ENTRY_HI[21], ENTRY_HI[20], 
    ENTRY_HI[19], ENTRY_HI[18], ENTRY_HI[17], ENTRY_HI[16], ENTRY_HI[15], 
    ENTRY_HI[14], ENTRY_HI[13], ENTRY_HI[12], ENTRY_HI[11], ENTRY_HI[10], 
    ENTRY_HI[9], ENTRY_HI[8], ENTRY_HI[7], ENTRY_HI[6], ENTRY_HI[5], 
    ENTRY_HI[4], ENTRY_HI[3], ENTRY_HI[2], ENTRY_HI[1], ENTRY_HI[0]}), .O({
    ENTRY_HI_B[31], ENTRY_HI_B[30], ENTRY_HI_B[29], ENTRY_HI_B[28], 
    ENTRY_HI_B[27], ENTRY_HI_B[26], ENTRY_HI_B[25], ENTRY_HI_B[24], 
    ENTRY_HI_B[23], ENTRY_HI_B[22], ENTRY_HI_B[21], ENTRY_HI_B[20], 
    ENTRY_HI_B[19], ENTRY_HI_B[18], ENTRY_HI_B[17], ENTRY_HI_B[16], 
    ENTRY_HI_B[15], ENTRY_HI_B[14], ENTRY_HI_B[13], ENTRY_HI_B[12], 
    ENTRY_HI_B[11], ENTRY_HI_B[10], ENTRY_HI_B[9], ENTRY_HI_B[8], 
    ENTRY_HI_B[7], ENTRY_HI_B[6], ENTRY_HI_B[5], ENTRY_HI_B[4], 
    ENTRY_HI_B[3], ENTRY_HI_B[2], ENTRY_HI_B[1], ENTRY_HI_B[0]}), .WCLK(CLK)
    , .WE(X1N347));
  AND2B1 X1I1190 (.I0(INDEX_OUT[5]), .I1(WRITE), .O(X1N1185));
  RAM32X32S X1I120 (.A0(INDEX_OUT[0]), .A1(INDEX_OUT[1]), .A2(INDEX_OUT[2])
    , .A3(INDEX_OUT[3]), .A4(INDEX_OUT[4]), .D({ENTRY_HI[31], ENTRY_HI[30], 
    ENTRY_HI[29], ENTRY_HI[28], ENTRY_HI[27], ENTRY_HI[26], ENTRY_HI[25], 
    ENTRY_HI[24], ENTRY_HI[23], ENTRY_HI[22], ENTRY_HI[21], ENTRY_HI[20], 
    ENTRY_HI[19], ENTRY_HI[18], ENTRY_HI[17], ENTRY_HI[16], ENTRY_HI[15], 
    ENTRY_HI[14], ENTRY_HI[13], ENTRY_HI[12], ENTRY_HI[11], ENTRY_HI[10], 
    ENTRY_HI[9], ENTRY_HI[8], ENTRY_HI[7], ENTRY_HI[6], ENTRY_HI[5], 
    ENTRY_HI[4], ENTRY_HI[3], ENTRY_HI[2], ENTRY_HI[1], ENTRY_HI[0]}), .O({
    ENTRY_HI_A[31], ENTRY_HI_A[30], ENTRY_HI_A[29], ENTRY_HI_A[28], 
    ENTRY_HI_A[27], ENTRY_HI_A[26], ENTRY_HI_A[25], ENTRY_HI_A[24], 
    ENTRY_HI_A[23], ENTRY_HI_A[22], ENTRY_HI_A[21], ENTRY_HI_A[20], 
    ENTRY_HI_A[19], ENTRY_HI_A[18], ENTRY_HI_A[17], ENTRY_HI_A[16], 
    ENTRY_HI_A[15], ENTRY_HI_A[14], ENTRY_HI_A[13], ENTRY_HI_A[12], 
    ENTRY_HI_A[11], ENTRY_HI_A[10], ENTRY_HI_A[9], ENTRY_HI_A[8], 
    ENTRY_HI_A[7], ENTRY_HI_A[6], ENTRY_HI_A[5], ENTRY_HI_A[4], 
    ENTRY_HI_A[3], ENTRY_HI_A[2], ENTRY_HI_A[1], ENTRY_HI_A[0]}), .WCLK(CLK)
    , .WE(X1N1185));
  M2_1 X1I1205 (.D0(X1N1089), .D1(INDEX_IN[3]), .O(INDEX_OUT[3]), .S0
    (X1N1249));
  M2_1 X1I1206 (.D0(X1N1088), .D1(INDEX_IN[4]), .O(INDEX_OUT[4]), .S0
    (X1N1249));
  M2_1 X1I1207 (.D0(X1N1087), .D1(INDEX_IN[5]), .O(INDEX_OUT[5]), .S0
    (X1N1249));
  M2_1 X1I1208 (.D0(X1N1078), .D1(INDEX_IN[0]), .O(INDEX_OUT[0]), .S0
    (X1N1249));
  M2_1 X1I1209 (.D0(X1N1080), .D1(INDEX_IN[1]), .O(INDEX_OUT[1]), .S0
    (X1N1249));
  M2_1 X1I1210 (.D0(X1N1082), .D1(INDEX_IN[2]), .O(INDEX_OUT[2]), .S0
    (X1N1249));
  M2_1X20 X1I1222 (.A({ENTRY_LO_OUT[31], ENTRY_LO_OUT[30], ENTRY_LO_OUT[29]
    , ENTRY_LO_OUT[28], ENTRY_LO_OUT[27], ENTRY_LO_OUT[26], ENTRY_LO_OUT[25]
    , ENTRY_LO_OUT[24], ENTRY_LO_OUT[23], ENTRY_LO_OUT[22], ENTRY_LO_OUT[21]
    , ENTRY_LO_OUT[20], ENTRY_LO_OUT[19], ENTRY_LO_OUT[18], ENTRY_LO_OUT[17]
    , ENTRY_LO_OUT[16], ENTRY_LO_OUT[15], ENTRY_LO_OUT[14], ENTRY_LO_OUT[13]
    , ENTRY_LO_OUT[12]}), .B({GND, GND, GND, VPN_INTO[16], VPN_INTO[15], 
    VPN_INTO[14], VPN_INTO[13], VPN_INTO[12], VPN_INTO[11], VPN_INTO[10], 
    VPN_INTO[9], VPN_INTO[8], VPN_INTO[7], VPN_INTO[6], VPN_INTO[5], 
    VPN_INTO[4], VPN_INTO[3], VPN_INTO[2], VPN_INTO[1], VPN_INTO[0]}), .SB
    (X1N1226), .S({PFN[19], PFN[18], PFN[17], PFN[16], PFN[15], PFN[14], 
    PFN[13], PFN[12], PFN[11], PFN[10], PFN[9], PFN[8], PFN[7], PFN[6], 
    PFN[5], PFN[4], PFN[3], PFN[2], PFN[1], PFN[0]}));
  AND2B1 X1I1227 (.I0(LOOKUP_VPN[18]), .I1(LOOKUP_VPN[19]), .O(X1N1226));
  AND2B1 X1I1234 (.I0(LOOKUP_VPN[18]), .I1(LOOKUP_VPN[19]), .O(X1N1240));
  OR2 X1I1255 (.I0(READ), .I1(WRITE), .O(X1N1249));
  M2_1 X1I1261 (.D0(ENTRY_LO_OUT[11]), .D1(LOOKUP_VPN[17]), .O(NO_CACHE), 
    .S0(X1N1226));
  OR2 X1I1278 (.I0(X1N1226), .I1(ENTRY_LO_OUT[10]), .O(DIRTY));
  MUX2_1X32 X1I128 (.A({ENTRY_HI_A[31], ENTRY_HI_A[30], ENTRY_HI_A[29], 
    ENTRY_HI_A[28], ENTRY_HI_A[27], ENTRY_HI_A[26], ENTRY_HI_A[25], 
    ENTRY_HI_A[24], ENTRY_HI_A[23], ENTRY_HI_A[22], ENTRY_HI_A[21], 
    ENTRY_HI_A[20], ENTRY_HI_A[19], ENTRY_HI_A[18], ENTRY_HI_A[17], 
    ENTRY_HI_A[16], ENTRY_HI_A[15], ENTRY_HI_A[14], ENTRY_HI_A[13], 
    ENTRY_HI_A[12], ENTRY_HI_A[11], ENTRY_HI_A[10], ENTRY_HI_A[9], 
    ENTRY_HI_A[8], ENTRY_HI_A[7], ENTRY_HI_A[6], ENTRY_HI_A[5], 
    ENTRY_HI_A[4], ENTRY_HI_A[3], ENTRY_HI_A[2], ENTRY_HI_A[1], 
    ENTRY_HI_A[0]}), .B({ENTRY_HI_B[31], ENTRY_HI_B[30], ENTRY_HI_B[29], 
    ENTRY_HI_B[28], ENTRY_HI_B[27], ENTRY_HI_B[26], ENTRY_HI_B[25], 
    ENTRY_HI_B[24], ENTRY_HI_B[23], ENTRY_HI_B[22], ENTRY_HI_B[21], 
    ENTRY_HI_B[20], ENTRY_HI_B[19], ENTRY_HI_B[18], ENTRY_HI_B[17], 
    ENTRY_HI_B[16], ENTRY_HI_B[15], ENTRY_HI_B[14], ENTRY_HI_B[13], 
    ENTRY_HI_B[12], ENTRY_HI_B[11], ENTRY_HI_B[10], ENTRY_HI_B[9], 
    ENTRY_HI_B[8], ENTRY_HI_B[7], ENTRY_HI_B[6], ENTRY_HI_B[5], 
    ENTRY_HI_B[4], ENTRY_HI_B[3], ENTRY_HI_B[2], ENTRY_HI_B[1], 
    ENTRY_HI_B[0]}), .SB(INDEX_OUT[5]), .S({ENTRY_HI_OUT[31], 
    ENTRY_HI_OUT[30], ENTRY_HI_OUT[29], ENTRY_HI_OUT[28], ENTRY_HI_OUT[27], 
    ENTRY_HI_OUT[26], ENTRY_HI_OUT[25], ENTRY_HI_OUT[24], ENTRY_HI_OUT[23], 
    ENTRY_HI_OUT[22], ENTRY_HI_OUT[21], ENTRY_HI_OUT[20], ENTRY_HI_OUT[19], 
    ENTRY_HI_OUT[18], ENTRY_HI_OUT[17], ENTRY_HI_OUT[16], ENTRY_HI_OUT[15], 
    ENTRY_HI_OUT[14], ENTRY_HI_OUT[13], ENTRY_HI_OUT[12], ENTRY_HI_OUT[11], 
    ENTRY_HI_OUT[10], ENTRY_HI_OUT[9], ENTRY_HI_OUT[8], ENTRY_HI_OUT[7], 
    ENTRY_HI_OUT[6], ENTRY_HI_OUT[5], ENTRY_HI_OUT[4], ENTRY_HI_OUT[3], 
    ENTRY_HI_OUT[2], ENTRY_HI_OUT[1], ENTRY_HI_OUT[0]}));
  M2_1X20 X1I1280 (.A({VPN_INTO[19], VPN_INTO[18], VPN_INTO[17], 
    VPN_INTO[16], VPN_INTO[15], VPN_INTO[14], VPN_INTO[13], VPN_INTO[12], 
    VPN_INTO[11], VPN_INTO[10], VPN_INTO[9], VPN_INTO[8], VPN_INTO[7], 
    VPN_INTO[6], VPN_INTO[5], VPN_INTO[4], VPN_INTO[3], VPN_INTO[2], 
    VPN_INTO[1], VPN_INTO[0]}), .B({ENTRY_HI[31], ENTRY_HI[30], ENTRY_HI[29]
    , ENTRY_HI[28], ENTRY_HI[27], ENTRY_HI[26], ENTRY_HI[25], ENTRY_HI[24], 
    ENTRY_HI[23], ENTRY_HI[22], ENTRY_HI[21], ENTRY_HI[20], ENTRY_HI[19], 
    ENTRY_HI[18], ENTRY_HI[17], ENTRY_HI[16], ENTRY_HI[15], ENTRY_HI[14], 
    ENTRY_HI[13], ENTRY_HI[12]}), .SB(X1N1283), .S({LOOKUP_VPN[19], 
    LOOKUP_VPN[18], LOOKUP_VPN[17], LOOKUP_VPN[16], LOOKUP_VPN[15], 
    LOOKUP_VPN[14], LOOKUP_VPN[13], LOOKUP_VPN[12], LOOKUP_VPN[11], 
    LOOKUP_VPN[10], LOOKUP_VPN[9], LOOKUP_VPN[8], LOOKUP_VPN[7], 
    LOOKUP_VPN[6], LOOKUP_VPN[5], LOOKUP_VPN[4], LOOKUP_VPN[3], 
    LOOKUP_VPN[2], LOOKUP_VPN[1], LOOKUP_VPN[0]}));
  OR2 X1I1285 (.I0(LOOK_UP), .I1(WRITE), .O(X1N1283));
  MUX2_1X32 X1I129 (.A({ENTRY_LO_A[31], ENTRY_LO_A[30], ENTRY_LO_A[29], 
    ENTRY_LO_A[28], ENTRY_LO_A[27], ENTRY_LO_A[26], ENTRY_LO_A[25], 
    ENTRY_LO_A[24], ENTRY_LO_A[23], ENTRY_LO_A[22], ENTRY_LO_A[21], 
    ENTRY_LO_A[20], ENTRY_LO_A[19], ENTRY_LO_A[18], ENTRY_LO_A[17], 
    ENTRY_LO_A[16], ENTRY_LO_A[15], ENTRY_LO_A[14], ENTRY_LO_A[13], 
    ENTRY_LO_A[12], ENTRY_LO_A[11], ENTRY_LO_A[10], ENTRY_LO_A[9], 
    ENTRY_LO_A[8], ENTRY_LO_A[7], ENTRY_LO_A[6], ENTRY_LO_A[5], 
    ENTRY_LO_A[4], ENTRY_LO_A[3], ENTRY_LO_A[2], ENTRY_LO_A[1], 
    ENTRY_LO_A[0]}), .B({ENTRY_LO_B[31], ENTRY_LO_B[30], ENTRY_LO_B[29], 
    ENTRY_LO_B[28], ENTRY_LO_B[27], ENTRY_LO_B[26], ENTRY_LO_B[25], 
    ENTRY_LO_B[24], ENTRY_LO_B[23], ENTRY_LO_B[22], ENTRY_LO_B[21], 
    ENTRY_LO_B[20], ENTRY_LO_B[19], ENTRY_LO_B[18], ENTRY_LO_B[17], 
    ENTRY_LO_B[16], ENTRY_LO_B[15], ENTRY_LO_B[14], ENTRY_LO_B[13], 
    ENTRY_LO_B[12], ENTRY_LO_B[11], ENTRY_LO_B[10], ENTRY_LO_B[9], 
    ENTRY_LO_B[8], ENTRY_LO_B[7], ENTRY_LO_B[6], ENTRY_LO_B[5], 
    ENTRY_LO_B[4], ENTRY_LO_B[3], ENTRY_LO_B[2], ENTRY_LO_B[1], 
    ENTRY_LO_B[0]}), .SB(INDEX_OUT[5]), .S({ENTRY_LO_OUT[31], 
    ENTRY_LO_OUT[30], ENTRY_LO_OUT[29], ENTRY_LO_OUT[28], ENTRY_LO_OUT[27], 
    ENTRY_LO_OUT[26], ENTRY_LO_OUT[25], ENTRY_LO_OUT[24], ENTRY_LO_OUT[23], 
    ENTRY_LO_OUT[22], ENTRY_LO_OUT[21], ENTRY_LO_OUT[20], ENTRY_LO_OUT[19], 
    ENTRY_LO_OUT[18], ENTRY_LO_OUT[17], ENTRY_LO_OUT[16], ENTRY_LO_OUT[15], 
    ENTRY_LO_OUT[14], ENTRY_LO_OUT[13], ENTRY_LO_OUT[12], ENTRY_LO_OUT[11], 
    ENTRY_LO_OUT[10], ENTRY_LO_OUT[9], ENTRY_LO_OUT[8], ENTRY_LO_OUT[7], 
    ENTRY_LO_OUT[6], ENTRY_LO_OUT[5], ENTRY_LO_OUT[4], ENTRY_LO_OUT[3], 
    ENTRY_LO_OUT[2], ENTRY_LO_OUT[1], ENTRY_LO_OUT[0]}));
  AND2B1 X1I1292 (.I0(HIT), .I1(WRITE_IN), .O(WRITE));
  RAM32X32S X1I130 (.A0(INDEX_OUT[0]), .A1(INDEX_OUT[1]), .A2(INDEX_OUT[2])
    , .A3(INDEX_OUT[3]), .A4(INDEX_OUT[4]), .D({ENTRY_LO[31], ENTRY_LO[30], 
    ENTRY_LO[29], ENTRY_LO[28], ENTRY_LO[27], ENTRY_LO[26], ENTRY_LO[25], 
    ENTRY_LO[24], ENTRY_LO[23], ENTRY_LO[22], ENTRY_LO[21], ENTRY_LO[20], 
    ENTRY_LO[19], ENTRY_LO[18], ENTRY_LO[17], ENTRY_LO[16], ENTRY_LO[15], 
    ENTRY_LO[14], ENTRY_LO[13], ENTRY_LO[12], ENTRY_LO[11], ENTRY_LO[10], 
    ENTRY_LO[9], ENTRY_LO[8], ENTRY_LO[7], ENTRY_LO[6], ENTRY_LO[5], 
    ENTRY_LO[4], ENTRY_LO[3], ENTRY_LO[2], ENTRY_LO[1], ENTRY_LO[0]}), .O({
    ENTRY_LO_B[31], ENTRY_LO_B[30], ENTRY_LO_B[29], ENTRY_LO_B[28], 
    ENTRY_LO_B[27], ENTRY_LO_B[26], ENTRY_LO_B[25], ENTRY_LO_B[24], 
    ENTRY_LO_B[23], ENTRY_LO_B[22], ENTRY_LO_B[21], ENTRY_LO_B[20], 
    ENTRY_LO_B[19], ENTRY_LO_B[18], ENTRY_LO_B[17], ENTRY_LO_B[16], 
    ENTRY_LO_B[15], ENTRY_LO_B[14], ENTRY_LO_B[13], ENTRY_LO_B[12], 
    ENTRY_LO_B[11], ENTRY_LO_B[10], ENTRY_LO_B[9], ENTRY_LO_B[8], 
    ENTRY_LO_B[7], ENTRY_LO_B[6], ENTRY_LO_B[5], ENTRY_LO_B[4], 
    ENTRY_LO_B[3], ENTRY_LO_B[2], ENTRY_LO_B[1], ENTRY_LO_B[0]}), .WCLK(CLK)
    , .WE(X1N347));
  OR4B1 X1I1304 (.I0(X1N932), .I1(X1N1087), .I2(X1N1088), .I3(X1N1089), .O
    (X1N1096));
  OR2 X1I1309 (.I0(X1N1240), .I1(X1N1315), .O(HIT));
  RAM32X32S X1I131 (.A0(INDEX_OUT[0]), .A1(INDEX_OUT[1]), .A2(INDEX_OUT[2])
    , .A3(INDEX_OUT[3]), .A4(INDEX_OUT[4]), .D({ENTRY_LO[31], ENTRY_LO[30], 
    ENTRY_LO[29], ENTRY_LO[28], ENTRY_LO[27], ENTRY_LO[26], ENTRY_LO[25], 
    ENTRY_LO[24], ENTRY_LO[23], ENTRY_LO[22], ENTRY_LO[21], ENTRY_LO[20], 
    ENTRY_LO[19], ENTRY_LO[18], ENTRY_LO[17], ENTRY_LO[16], ENTRY_LO[15], 
    ENTRY_LO[14], ENTRY_LO[13], ENTRY_LO[12], ENTRY_LO[11], ENTRY_LO[10], 
    ENTRY_LO[9], ENTRY_LO[8], ENTRY_LO[7], ENTRY_LO[6], ENTRY_LO[5], 
    ENTRY_LO[4], ENTRY_LO[3], ENTRY_LO[2], ENTRY_LO[1], ENTRY_LO[0]}), .O({
    ENTRY_LO_A[31], ENTRY_LO_A[30], ENTRY_LO_A[29], ENTRY_LO_A[28], 
    ENTRY_LO_A[27], ENTRY_LO_A[26], ENTRY_LO_A[25], ENTRY_LO_A[24], 
    ENTRY_LO_A[23], ENTRY_LO_A[22], ENTRY_LO_A[21], ENTRY_LO_A[20], 
    ENTRY_LO_A[19], ENTRY_LO_A[18], ENTRY_LO_A[17], ENTRY_LO_A[16], 
    ENTRY_LO_A[15], ENTRY_LO_A[14], ENTRY_LO_A[13], ENTRY_LO_A[12], 
    ENTRY_LO_A[11], ENTRY_LO_A[10], ENTRY_LO_A[9], ENTRY_LO_A[8], 
    ENTRY_LO_A[7], ENTRY_LO_A[6], ENTRY_LO_A[5], ENTRY_LO_A[4], 
    ENTRY_LO_A[3], ENTRY_LO_A[2], ENTRY_LO_A[1], ENTRY_LO_A[0]}), .WCLK(CLK)
    , .WE(X1N1185));
  AND2 X1I1313 (.I0(X1N1096), .I1(ENTRY_LO_OUT[9]), .O(X1N1315));
  AND3B2 X1I1316 (.I0(X1N1240), .I1(ENTRY_LO_OUT[9]), .I2(X1N1096), .O
    (HIT_BUT_NOT_VALID));
  MMUSEG X1I553 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N611));
  MMUSEG X1I559 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N610));
  MMUSEG X1I563 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N614));
  MMUSEG X1I567 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N613));
  MMUSEG X1I569 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N612));
  MMUSEG X1I573 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N616));
  MMUSEG X1I577 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N615));
  MMUSEG X1I579 (.CLK(CLK), .HIT_X(X1N932), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N560), .WRITE_Y
    (X1N609));
  MMUSEG X1I586 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N609));
  MMUSEG X1I589 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N610));
  MMUSEG X1I591 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N611));
  MMUSEG X1I594 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N612));
  MMUSEG X1I596 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N613));
  MMUSEG X1I600 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N614));
  MMUSEG X1I604 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N615));
  MMUSEG X1I608 (.CLK(CLK), .HIT_X(X1N939), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N584), .WRITE_Y
    (X1N616));
  MMUSEG X1I625 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N616));
  MMUSEG X1I629 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N615));
  MMUSEG X1I633 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N614));
  MMUSEG X1I637 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N613));
  MMUSEG X1I639 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N612));
  MMUSEG X1I642 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N611));
  MMUSEG X1I644 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N610));
  MMUSEG X1I647 (.CLK(CLK), .HIT_X(X1N946), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N627), .WRITE_Y
    (X1N609));
  MMUSEG X1I658 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N616));
  MMUSEG X1I662 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N615));
  MMUSEG X1I666 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N614));
  MMUSEG X1I670 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N613));
  MMUSEG X1I672 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N612));
  MMUSEG X1I675 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N611));
  MMUSEG X1I677 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N610));
  MMUSEG X1I680 (.CLK(CLK), .HIT_X(X1N953), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N660), .WRITE_Y
    (X1N609));
  MMUSEG X1I691 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N616));
  MMUSEG X1I695 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N615));
  MMUSEG X1I699 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N614));
  MMUSEG X1I703 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N613));
  MMUSEG X1I705 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N612));
  MMUSEG X1I708 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N611));
  MMUSEG X1I710 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N610));
  MMUSEG X1I713 (.CLK(CLK), .HIT_X(X1N960), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N693), .WRITE_Y
    (X1N609));
  MMUSEG X1I724 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N616));
  MMUSEG X1I728 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N615));
  MMUSEG X1I732 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N614));
  MMUSEG X1I736 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N613));
  MMUSEG X1I738 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N612));
  MMUSEG X1I741 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N611));
  MMUSEG X1I743 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N610));
  MMUSEG X1I746 (.CLK(CLK), .HIT_X(X1N967), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N726), .WRITE_Y
    (X1N609));
  MMUSEG X1I757 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N616));
  MMUSEG X1I761 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N615));
  MMUSEG X1I765 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N614));
  MMUSEG X1I769 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N613));
  MMUSEG X1I771 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N612));
  MMUSEG X1I774 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N611));
  MMUSEG X1I776 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N610));
  MMUSEG X1I779 (.CLK(CLK), .HIT_X(X1N974), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N759), .WRITE_Y
    (X1N609));
  MMUSEG X1I784 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N868), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N609));
  MMUSEG X1I787 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N869), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N610));
  MMUSEG X1I789 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N870), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N611));
  MMUSEG X1I792 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N871), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N612));
  MMUSEG X1I794 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N872), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N613));
  MMUSEG X1I798 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N873), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N614));
  MMUSEG X1I802 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N874), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N615));
  MMUSEG X1I806 (.CLK(CLK), .HIT_X(X1N981), .HIT_Y(X1N875), 
    .VPN,ASID[5:0],GLOB({LOOKUP_VPN[19], LOOKUP_VPN[18], LOOKUP_VPN[17], 
    LOOKUP_VPN[16], LOOKUP_VPN[15], LOOKUP_VPN[14], LOOKUP_VPN[13], 
    LOOKUP_VPN[12], LOOKUP_VPN[11], LOOKUP_VPN[10], LOOKUP_VPN[9], 
    LOOKUP_VPN[8], LOOKUP_VPN[7], LOOKUP_VPN[6], LOOKUP_VPN[5], 
    LOOKUP_VPN[4], LOOKUP_VPN[3], LOOKUP_VPN[2], LOOKUP_VPN[1], 
    LOOKUP_VPN[0], ENTRY_HI[11], ENTRY_HI[10], ENTRY_HI[9], ENTRY_HI[8], 
    ENTRY_HI[7], ENTRY_HI[6], ENTRY_LO[8]}), .WRITE_X(X1N782), .WRITE_Y
    (X1N616));
  D3_8E X1I824 (.A0(INDEX_IN[3]), .A1(INDEX_IN[4]), .A2(INDEX_IN[5]), .D0
    (X1N560), .D1(X1N584), .D2(X1N627), .D3(X1N660), .D4(X1N693), .D5
    (X1N726), .D6(X1N759), .D7(X1N782), .E(WRITE));
  D3_8E X1I848 (.A0(INDEX_IN[0]), .A1(INDEX_IN[1]), .A2(INDEX_IN[2]), .D0
    (X1N609), .D1(X1N616), .D2(X1N615), .D3(X1N612), .D4(X1N614), .D5
    (X1N613), .D6(X1N610), .D7(X1N611), .E(WRITE));
  PULLUP X1I988 (.O(X1N868));
  PULLUP X1I992 (.O(X1N875));
  PULLUP X1I994 (.O(X1N874));
  PULLUP X1I996 (.O(X1N871));
  PULLUP X1I998 (.O(X1N873));

endmodule  // MMU

module BUFT16 (I, O, T);
  output [15:0] O;
  input T;
  input [15:0] I;
  wire [63:0] A;
  wire [15:0] Q, D, B, IO;
  wire [7:0] DPO, SPO;
  BUFT X1I30 (.I(I[8]), .O(O[8]), .T(T));
  BUFT X1I31 (.I(I[9]), .O(O[9]), .T(T));
  BUFT X1I32 (.I(I[10]), .O(O[10]), .T(T));
  BUFT X1I33 (.I(I[11]), .O(O[11]), .T(T));
  BUFT X1I34 (.I(I[15]), .O(O[15]), .T(T));
  BUFT X1I35 (.I(I[14]), .O(O[14]), .T(T));
  BUFT X1I36 (.I(I[13]), .O(O[13]), .T(T));
  BUFT X1I37 (.I(I[12]), .O(O[12]), .T(T));
  BUFT X1I38 (.I(I[6]), .O(O[6]), .T(T));
  BUFT X1I39 (.I(I[7]), .O(O[7]), .T(T));
  BUFT X1I40 (.I(I[0]), .O(O[0]), .T(T));
  BUFT X1I41 (.I(I[1]), .O(O[1]), .T(T));
  BUFT X1I42 (.I(I[2]), .O(O[2]), .T(T));
  BUFT X1I43 (.I(I[3]), .O(O[3]), .T(T));
  BUFT X1I44 (.I(I[4]), .O(O[4]), .T(T));
  BUFT X1I45 (.I(I[5]), .O(O[5]), .T(T));

endmodule  // BUFT16

module BUFT32 (I, O, T);
  output [31:0] O;
  input T;
  input [31:0] I;
  BUFT16 X1I2 (.I({I[15], I[14], I[13], I[12], I[11], I[10], I[9], I[8], 
    I[7], I[6], I[5], I[4], I[3], I[2], I[1], I[0]}), .O({O[15], O[14], 
    O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5], O[4], O[3], 
    O[2], O[1], O[0]}), .T(T));
  BUFT16 X1I3 (.I({I[31], I[30], I[29], I[28], I[27], I[26], I[25], I[24], 
    I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16]}), .O({O[31], 
    O[30], O[29], O[28], O[27], O[26], O[25], O[24], O[23], O[22], O[21], 
    O[20], O[19], O[18], O[17], O[16]}), .T(T));

endmodule  // BUFT32

module M2_1X6 (A, B, O, SB);
  M2_1 X1I60 (.D0(A[4]), .D1(B[4]), .O(O[4]), .S0(SB));
  M2_1 X1I61 (.D0(A[3]), .D1(B[3]), .O(O[3]), .S0(SB));
  M2_1 X1I62 (.D0(A[2]), .D1(B[2]), .O(O[2]), .S0(SB));
  M2_1 X1I63 (.D0(A[1]), .D1(B[1]), .O(O[1]), .S0(SB));
  M2_1 X1I64 (.D0(A[0]), .D1(B[0]), .O(O[0]), .S0(SB));
  M2_1 X1I82 (.D0(A[5]), .D1(B[5]), .O(O[5]), .S0(SB));

endmodule  // M2_1X6

module REG20 (CLK, EN, I, O);
  wire X1N57;
  FD16CE X1I55 (.C(CLK), .CE(EN), .CLR(X1N57), .D({I[15], I[14], I[13], 
    I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], I[2], 
    I[1], I[0]}), .Q({O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], 
    O[7], O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  FD4CE X1I56 (.C(CLK), .CE(EN), .CLR(X1N57), .D0(I[16]), .D1(I[17]), .D2
    (I[18]), .D3(I[19]), .Q0(O[16]), .Q1(O[17]), .Q2(O[18]), .Q3(O[19]));
  GND X1I59 (.G(X1N57));

endmodule  // REG20

module ADD16 (A, B, CI, CO, OFL, S);
  output OFL, CO;
  output [15:0] S;
  input CI;
  input [15:0] B;
  input [15:0] A;
  wire C0, C1, C2, C3, C4, C5, I0, C6, I1, C7, I2, C8, I3, C9, I4, I5, I6, 
    I7, I8, I9, C14O, C10, C11, C12, C13, C14, I10, I11, I12, I13, I14, I15;
  MUXCY_D X1I107 (.CI(C13), .DI(A[14]), .LO(C14), .O(C14O), .S(I14));
  MUXCY_L X1I110 (.CI(C12), .DI(A[13]), .LO(C13), .S(I13));
  MUXCY_L X1I111 (.CI(C7), .DI(A[8]), .LO(C8), .S(I8));
  FMAP X1I16 (.I1(A[8]), .I2(B[8]), .O(I8));
  FMAP X1I17 (.I1(A[9]), .I2(B[9]), .O(I9));
  FMAP X1I18 (.I1(A[10]), .I2(B[10]), .O(I10));
  FMAP X1I19 (.I1(A[11]), .I2(B[11]), .O(I11));
  FMAP X1I20 (.I1(A[12]), .I2(B[12]), .O(I12));
  FMAP X1I21 (.I1(A[13]), .I2(B[13]), .O(I13));
  FMAP X1I22 (.I1(A[14]), .I2(B[14]), .O(I14));
  XORCY X1I226 (.CI(CI), .LI(I0), .O(S[0]));
  XORCY X1I227 (.CI(C0), .LI(I1), .O(S[1]));
  XORCY X1I228 (.CI(C2), .LI(I3), .O(S[3]));
  XORCY X1I229 (.CI(C1), .LI(I2), .O(S[2]));
  FMAP X1I23 (.I1(A[15]), .I2(B[15]), .O(I15));
  XORCY X1I230 (.CI(C4), .LI(I5), .O(S[5]));
  XORCY X1I231 (.CI(C3), .LI(I4), .O(S[4]));
  XORCY X1I233 (.CI(C6), .LI(I7), .O(S[7]));
  XORCY X1I234 (.CI(C5), .LI(I6), .O(S[6]));
  MUXCY_L X1I248 (.CI(C6), .DI(A[7]), .LO(C7), .S(I7));
  MUXCY_L X1I249 (.CI(C5), .DI(A[6]), .LO(C6), .S(I6));
  MUXCY_L X1I250 (.CI(C4), .DI(A[5]), .LO(C5), .S(I5));
  MUXCY_L X1I251 (.CI(C3), .DI(A[4]), .LO(C4), .S(I4));
  MUXCY_L X1I252 (.CI(C2), .DI(A[3]), .LO(C3), .S(I3));
  MUXCY_L X1I253 (.CI(C1), .DI(A[2]), .LO(C2), .S(I2));
  MUXCY_L X1I254 (.CI(C0), .DI(A[1]), .LO(C1), .S(I1));
  MUXCY_L X1I255 (.CI(CI), .DI(A[0]), .LO(C0), .S(I0));
  FMAP X1I272 (.I1(A[1]), .I2(B[1]), .O(I1));
  FMAP X1I275 (.I1(A[0]), .I2(B[0]), .O(I0));
  FMAP X1I279 (.I1(A[2]), .I2(B[2]), .O(I2));
  FMAP X1I283 (.I1(A[3]), .I2(B[3]), .O(I3));
  FMAP X1I287 (.I1(A[4]), .I2(B[4]), .O(I4));
  FMAP X1I291 (.I1(A[5]), .I2(B[5]), .O(I5));
  FMAP X1I295 (.I1(A[6]), .I2(B[6]), .O(I6));
  FMAP X1I299 (.I1(A[7]), .I2(B[7]), .O(I7));
  XOR2 X1I354 (.I0(A[0]), .I1(B[0]), .O(I0));
  XOR2 X1I355 (.I0(A[1]), .I1(B[1]), .O(I1));
  XOR2 X1I356 (.I0(A[2]), .I1(B[2]), .O(I2));
  XOR2 X1I357 (.I0(A[3]), .I1(B[3]), .O(I3));
  XOR2 X1I358 (.I0(A[4]), .I1(B[4]), .O(I4));
  XOR2 X1I359 (.I0(A[5]), .I1(B[5]), .O(I5));
  XOR2 X1I360 (.I0(A[6]), .I1(B[6]), .O(I6));
  XOR2 X1I361 (.I0(A[7]), .I1(B[7]), .O(I7));
  XOR2 X1I362 (.I0(A[8]), .I1(B[8]), .O(I8));
  XOR2 X1I363 (.I0(A[9]), .I1(B[9]), .O(I9));
  XOR2 X1I364 (.I0(A[10]), .I1(B[10]), .O(I10));
  XOR2 X1I365 (.I0(A[11]), .I1(B[11]), .O(I11));
  XOR2 X1I366 (.I0(A[12]), .I1(B[12]), .O(I12));
  XOR2 X1I367 (.I0(A[13]), .I1(B[13]), .O(I13));
  XOR2 X1I368 (.I0(A[14]), .I1(B[14]), .O(I14));
  XOR2 X1I369 (.I0(A[15]), .I1(B[15]), .O(I15));
  XOR2 X1I375 (.I0(C14O), .I1(CO), .O(OFL));
  MUXCY_L X1I55 (.CI(C8), .DI(A[9]), .LO(C9), .S(I9));
  MUXCY_L X1I58 (.CI(C10), .DI(A[11]), .LO(C11), .S(I11));
  MUXCY_L X1I62 (.CI(C9), .DI(A[10]), .LO(C10), .S(I10));
  MUXCY_L X1I63 (.CI(C11), .DI(A[12]), .LO(C12), .S(I12));
  MUXCY X1I64 (.CI(C14), .DI(A[15]), .O(CO), .S(I15));
  XORCY X1I73 (.CI(C7), .LI(I8), .O(S[8]));
  XORCY X1I74 (.CI(C8), .LI(I9), .O(S[9]));
  XORCY X1I75 (.CI(C10), .LI(I11), .O(S[11]));
  XORCY X1I76 (.CI(C9), .LI(I10), .O(S[10]));
  XORCY X1I77 (.CI(C12), .LI(I13), .O(S[13]));
  XORCY X1I78 (.CI(C11), .LI(I12), .O(S[12]));
  XORCY X1I80 (.CI(C14), .LI(I15), .O(S[15]));
  XORCY X1I81 (.CI(C13), .LI(I14), .O(S[14]));

// WARNING - Component X1I299 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I295 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I291 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I287 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I283 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I279 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I275 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I272 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I23 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I22 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I21 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I20 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I19 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I18 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I17 has unconnected pins: 2 input, 0 output, 0 inout.
// WARNING - Component X1I16 has unconnected pins: 2 input, 0 output, 0 inout.
endmodule  // ADD16

module INC32 (A, S);
  output [31:0] S;
  input [31:0] A;
  wire [15:0] GB, G;
  wire X1N44, X1N81, X1N29, X1N85;
  ADD16 IGNORE_NO_LOAD4 (.A({A[15], A[14], A[13], A[12], A[11], A[10], A[9]
    , A[8], A[7], A[6], A[5], A[4], A[3], A[2], A[1], A[0]}), .B({G[15], 
    G[14], G[13], G[12], G[11], G[10], G[9], G[8], G[7], G[6], G[5], G[4], 
    G[3], G[2], G[1], G[0]}), .CI(X1N85), .CO(X1N29), .S({S[15], S[14], 
    S[13], S[12], S[11], S[10], S[9], S[8], S[7], S[6], S[5], S[4], S[3], 
    S[2], S[1], S[0]}));
  ADD16 IGNORE_NO_LOAD5 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25]
    , A[24], A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16]}), .B({
    GB[15], GB[14], GB[13], GB[12], GB[11], GB[10], GB[9], GB[8], GB[7], 
    GB[6], GB[5], GB[4], GB[3], GB[2], GB[1], GB[0]}), .CI(X1N29), .S({S[31]
    , S[30], S[29], S[28], S[27], S[26], S[25], S[24], S[23], S[22], S[21], 
    S[20], S[19], S[18], S[17], S[16]}));
  GND X1I45 (.G(X1N44));
  BUF X1I46 (.I(X1N44), .O(G[12]));
  BUF X1I47 (.I(X1N44), .O(G[13]));
  BUF X1I48 (.I(X1N44), .O(G[15]));
  BUF X1I49 (.I(X1N44), .O(G[14]));
  BUF X1I50 (.I(X1N44), .O(G[8]));
  BUF X1I51 (.I(X1N44), .O(G[9]));
  BUF X1I52 (.I(X1N44), .O(G[11]));
  BUF X1I53 (.I(X1N44), .O(G[10]));
  BUF X1I54 (.I(X1N44), .O(G[4]));
  BUF X1I55 (.I(X1N44), .O(G[5]));
  BUF X1I56 (.I(X1N44), .O(G[7]));
  BUF X1I57 (.I(X1N44), .O(G[6]));
  BUF X1I59 (.I(X1N44), .O(G[3]));
  BUF X1I60 (.I(X1N44), .O(G[1]));
  BUF X1I62 (.I(X1N44), .O(G[0]));
  BUF X1I64 (.I(X1N81), .O(GB[0]));
  BUF X1I65 (.I(X1N81), .O(GB[1]));
  BUF X1I66 (.I(X1N81), .O(GB[3]));
  BUF X1I67 (.I(X1N81), .O(GB[2]));
  BUF X1I68 (.I(X1N81), .O(GB[6]));
  BUF X1I69 (.I(X1N81), .O(GB[7]));
  BUF X1I70 (.I(X1N81), .O(GB[5]));
  BUF X1I71 (.I(X1N81), .O(GB[4]));
  BUF X1I72 (.I(X1N81), .O(GB[10]));
  BUF X1I73 (.I(X1N81), .O(GB[11]));
  BUF X1I74 (.I(X1N81), .O(GB[9]));
  BUF X1I75 (.I(X1N81), .O(GB[8]));
  BUF X1I76 (.I(X1N81), .O(GB[14]));
  BUF X1I77 (.I(X1N81), .O(GB[15]));
  BUF X1I78 (.I(X1N81), .O(GB[13]));
  BUF X1I79 (.I(X1N81), .O(GB[12]));
  GND X1I80 (.G(X1N81));
  BUF X1I83 (.I(X1N44), .O(X1N85));
  VCC X1I91 (.P(G[2]));

// WARNING - Component IGNORE_NO_LOAD4 has unconnected pins: 0 input, 1 output, 0 inout.
// WARNING - Component IGNORE_NO_LOAD5 has unconnected pins: 0 input, 2 output, 0 inout.
endmodule  // INC32

module MEM_DELAY (C, D, Q, R);
  wire X1N3, X1N16, X1N19;
  FDR X1I1 (.C(C), .D(D), .Q(X1N3), .R(R));
  FDR X1I15 (.C(C), .D(X1N16), .Q(X1N19), .R(R));
  FDR X1I2 (.C(C), .D(X1N3), .Q(X1N16), .R(R));
  FDR X1I20 (.C(C), .D(X1N19), .Q(Q), .R(R));

endmodule  // MEM_DELAY

module BUTTONS (CLK, SW1, SW2, SW3);
  wire X1N9, X1N11, X1N30, X1N31, X1N13, X1N17, X1N27, X1N18, X1N19;
  IPAD X1I1 (.IPAD(X1N9));
  IPAD X1I2 (.IPAD(X1N11));
  INV X1I25 (.I(X1N17), .O(X1N27));
  FD X1I26 (.C(CLK), .D(X1N27), .Q(SW1));
  FD X1I28 (.C(CLK), .D(X1N30), .Q(SW2));
  INV X1I29 (.I(X1N18), .O(X1N30));
  IPAD X1I3 (.IPAD(X1N13));
  INV X1I32 (.I(X1N19), .O(X1N31));
  FD X1I33 (.C(CLK), .D(X1N31), .Q(SW3));
  IBUF X1I5 (.I(X1N9), .O(X1N17));
  IBUF X1I6 (.I(X1N11), .O(X1N18));
  IBUF X1I7 (.I(X1N13), .O(X1N19));

endmodule  // BUTTONS

module GND16 (G);
  wire X1N65;
  BUF X1I41 (.I(X1N65), .O(G[15]));
  BUF X1I42 (.I(X1N65), .O(G[14]));
  BUF X1I43 (.I(X1N65), .O(G[13]));
  BUF X1I44 (.I(X1N65), .O(G[12]));
  BUF X1I45 (.I(X1N65), .O(G[11]));
  BUF X1I46 (.I(X1N65), .O(G[10]));
  BUF X1I47 (.I(X1N65), .O(G[8]));
  BUF X1I48 (.I(X1N65), .O(G[9]));
  BUF X1I49 (.I(X1N65), .O(G[7]));
  BUF X1I50 (.I(X1N65), .O(G[6]));
  BUF X1I51 (.I(X1N65), .O(G[4]));
  BUF X1I52 (.I(X1N65), .O(G[5]));
  BUF X1I53 (.I(X1N65), .O(G[3]));
  BUF X1I54 (.I(X1N65), .O(G[2]));
  BUF X1I55 (.I(X1N65), .O(G[0]));
  BUF X1I56 (.I(X1N65), .O(G[1]));
  GND X1I66 (.G(X1N65));

endmodule  // GND16

module INT_VAL (D0, D1, D2, D3, D4, I0, I1, I2, I3, I4, INT, Q0, Q1, Q2, Q3
    , Q4, VALID_IN, VALID_OUT);
  wire X1N13;
  AND2B1 X1I1 (.I0(VALID_IN), .I1(INT), .O(X1N13));
  M2_1 X1I10 (.D0(D1), .D1(I1), .O(Q1), .S0(X1N13));
  M2_1 X1I11 (.D0(D2), .D1(I2), .O(Q2), .S0(X1N13));
  M2_1 X1I12 (.D0(D0), .D1(I0), .O(Q0), .S0(X1N13));
  OR2 X1I2 (.I0(INT), .I1(VALID_IN), .O(VALID_OUT));
  M2_1 X1I8 (.D0(D3), .D1(I3), .O(Q3), .S0(X1N13));
  M2_1 X1I9 (.D0(D4), .D1(I4), .O(Q4), .S0(X1N13));

endmodule  // INT_VAL

module REG16 (CLK, EN, I, O);
  wire X1N57;
  FD16CE X1I55 (.C(CLK), .CE(EN), .CLR(X1N57), .D({I[15], I[14], I[13], 
    I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], I[2], 
    I[1], I[0]}), .Q({O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], 
    O[7], O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  GND X1I59 (.G(X1N57));

endmodule  // REG16

module BUF16 (I, O);
  output [15:0] O;
  input [15:0] I;
  BUF X1I10 (.I(I[8]), .O(O[8]));
  BUF X1I11 (.I(I[9]), .O(O[9]));
  BUF X1I12 (.I(I[7]), .O(O[7]));
  BUF X1I13 (.I(I[6]), .O(O[6]));
  BUF X1I14 (.I(I[4]), .O(O[4]));
  BUF X1I15 (.I(I[5]), .O(O[5]));
  BUF X1I16 (.I(I[1]), .O(O[1]));
  BUF X1I17 (.I(I[0]), .O(O[0]));
  BUF X1I18 (.I(I[2]), .O(O[2]));
  BUF X1I19 (.I(I[3]), .O(O[3]));
  BUF X1I4 (.I(I[15]), .O(O[15]));
  BUF X1I5 (.I(I[14]), .O(O[14]));
  BUF X1I6 (.I(I[13]), .O(O[13]));
  BUF X1I7 (.I(I[12]), .O(O[12]));
  BUF X1I8 (.I(I[11]), .O(O[11]));
  BUF X1I9 (.I(I[10]), .O(O[10]));

endmodule  // BUF16

module SIGN_EX (D, EX_ZERO, O);
  wire X1N1;
  BUF16 X1I18 (.I({D[15], D[14], D[13], D[12], D[11], D[10], D[9], D[8], 
    D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]}), .O({O[15], O[14], 
    O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5], O[4], O[3], 
    O[2], O[1], O[0]}));
  BUF X1I21 (.I(X1N1), .O(O[16]));
  BUF X1I22 (.I(X1N1), .O(O[17]));
  BUF X1I23 (.I(X1N1), .O(O[18]));
  BUF X1I24 (.I(X1N1), .O(O[19]));
  BUF X1I25 (.I(X1N1), .O(O[20]));
  BUF X1I26 (.I(X1N1), .O(O[21]));
  BUF X1I27 (.I(X1N1), .O(O[23]));
  BUF X1I28 (.I(X1N1), .O(O[22]));
  BUF X1I29 (.I(X1N1), .O(O[24]));
  BUF X1I30 (.I(X1N1), .O(O[25]));
  BUF X1I31 (.I(X1N1), .O(O[27]));
  BUF X1I32 (.I(X1N1), .O(O[26]));
  BUF X1I33 (.I(X1N1), .O(O[30]));
  BUF X1I34 (.I(X1N1), .O(O[31]));
  BUF X1I35 (.I(X1N1), .O(O[29]));
  BUF X1I36 (.I(X1N1), .O(O[28]));
  AND2B1 X1I71 (.I0(EX_ZERO), .I1(D[15]), .O(X1N1));

endmodule  // SIGN_EX

module SIGN_EX_SHIFT2 (D, JL, O);
  wire X1N141, X1N74;
  M2_1 X1I103 (.D0(D[15]), .D1(D[20]), .O(O[22]), .S0(JL));
  M2_1 X1I107 (.D0(D[15]), .D1(D[21]), .O(O[23]), .S0(JL));
  M2_1 X1I111 (.D0(D[15]), .D1(D[22]), .O(O[24]), .S0(JL));
  M2_1 X1I121 (.D0(D[15]), .D1(D[23]), .O(O[25]), .S0(JL));
  M2_1 X1I124 (.D0(D[15]), .D1(D[24]), .O(O[26]), .S0(JL));
  M2_1 X1I127 (.D0(D[15]), .D1(D[25]), .O(O[27]), .S0(JL));
  M2_1 X1I130 (.D0(D[15]), .D1(X1N141), .O(O[28]), .S0(JL));
  M2_1 X1I133 (.D0(D[15]), .D1(X1N141), .O(O[29]), .S0(JL));
  M2_1 X1I136 (.D0(D[15]), .D1(X1N141), .O(O[30]), .S0(JL));
  M2_1 X1I148 (.D0(D[15]), .D1(X1N141), .O(O[31]), .S0(JL));
  GND X1I149 (.G(X1N141));
  BUF16 X1I18 (.I({D[15], D[14], D[13], D[12], D[11], D[10], D[9], D[8], 
    D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]}), .O({O[17], O[16], 
    O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], O[7], O[6], O[5], 
    O[4], O[3], O[2]}));
  BUF X1I75 (.I(X1N74), .O(O[1]));
  BUF X1I76 (.I(X1N74), .O(O[0]));
  GND X1I80 (.G(X1N74));
  M2_1 X1I83 (.D0(D[15]), .D1(D[16]), .O(O[18]), .S0(JL));
  M2_1 X1I87 (.D0(D[15]), .D1(D[17]), .O(O[19]), .S0(JL));
  M2_1 X1I95 (.D0(D[15]), .D1(D[18]), .O(O[20]), .S0(JL));
  M2_1 X1I99 (.D0(D[15]), .D1(D[19]), .O(O[21]), .S0(JL));

endmodule  // SIGN_EX_SHIFT2

module FD4RE (C, CE, .D0(D[0]), .D1(D[1]), .D2(D[2]), .D3(D[3]), .Q0(Q[0]), 
    .Q1(Q[1]), .Q2(Q[2]), .Q3(Q[3]), R);
  output [3:0] Q;
  input R, CE, C;
  input [3:0] D;
  wire [15:0] O, I, Q, D, IO;
  wire [7:0] DPO, SPO;
  FDRE Q0 (.C(C), .CE(CE), .D(D[0]), .Q(Q[0]), .R(R));
  FDRE Q1 (.C(C), .CE(CE), .D(D[1]), .Q(Q[1]), .R(R));
  FDRE Q2 (.C(C), .CE(CE), .D(D[2]), .Q(Q[2]), .R(R));
  FDRE Q3 (.C(C), .CE(CE), .D(D[3]), .Q(Q[3]), .R(R));

endmodule  // FD4RE

module M4_1E (.D0(D[0]), .D1(D[1]), .D2(D[2]), .D3(D[3]), E, O, S0, S1);
  output O;
  input S1, S0, E;
  input [3:0] D;
  wire [15:0] O, I, Q, D;
  wire [7:0] DPO, SPO;
  wire M01, M23;
  M2_1E M01 (.D0(D[0]), .D1(D[1]), .E(E), .O(M01), .S0(S0));
  M2_1E M23 (.D0(D[2]), .D1(D[3]), .E(E), .O(M23), .S0(S0));
  MUXF5 O (.I0(M01), .I1(M23), .O(O), .S(S1));

endmodule  // M4_1E

module LD16 (D, G, Q);
  output [15:0] Q;
  input G;
  input [15:0] D;
  wire [15:0] O, I;
  wire [7:0] DPO, SPO;
  LD Q5 (.D(D[5]), .G(G), .Q(Q[5]));
  LD Q1 (.D(D[1]), .G(G), .Q(Q[1]));
  LD Q0 (.D(D[0]), .G(G), .Q(Q[0]));
  LD Q2 (.D(D[2]), .G(G), .Q(Q[2]));
  LD Q3 (.D(D[3]), .G(G), .Q(Q[3]));
  LD Q4 (.D(D[4]), .G(G), .Q(Q[4]));
  LD Q6 (.D(D[6]), .G(G), .Q(Q[6]));
  LD Q7 (.D(D[7]), .G(G), .Q(Q[7]));
  LD Q8 (.D(D[8]), .G(G), .Q(Q[8]));
  LD Q9 (.D(D[9]), .G(G), .Q(Q[9]));
  LD Q10 (.D(D[10]), .G(G), .Q(Q[10]));
  LD Q11 (.D(D[11]), .G(G), .Q(Q[11]));
  LD Q12 (.D(D[12]), .G(G), .Q(Q[12]));
  LD Q13 (.D(D[13]), .G(G), .Q(Q[13]));
  LD Q14 (.D(D[14]), .G(G), .Q(Q[14]));
  LD Q15 (.D(D[15]), .G(G), .Q(Q[15]));

endmodule  // LD16

module NOR6 (I0, I1, I2, I3, I4, I5, O);
  output O;
  input I5, I4, I3, I2, I1, I0;
  wire I35;
  NOR4 X1I100 (.I0(I0), .I1(I1), .I2(I2), .I3(I35), .O(O));
  OR3 X1I93 (.I0(I3), .I1(I4), .I2(I5), .O(I35));

endmodule  // NOR6

module ROTEIGHT2 (I, O, S0, S1);
  wire [31:0] T, I, O;
  MUX2_1X32 X1I1 (.A({T[31], T[30], T[29], T[28], T[27], T[26], T[25], T[24]
    , T[23], T[22], T[21], T[20], T[19], T[18], T[17], T[16], T[15], T[14], 
    T[13], T[12], T[11], T[10], T[9], T[8], T[7], T[6], T[5], T[4], T[3], 
    T[2], T[1], T[0]}), .B({T[7], T[6], T[5], T[4], T[3], T[2], T[1], T[0], 
    T[31], T[30], T[29], T[28], T[27], T[26], T[25], T[24], T[23], T[22], 
    T[21], T[20], T[19], T[18], T[17], T[16], T[15], T[14], T[13], T[12], 
    T[11], T[10], T[9], T[8]}), .SB(S0), .S({O[31], O[30], O[29], O[28], 
    O[27], O[26], O[25], O[24], O[23], O[22], O[21], O[20], O[19], O[18], 
    O[17], O[16], O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], O[7]
    , O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  MUX2_1X32 X1I2 (.A({I[31], I[30], I[29], I[28], I[27], I[26], I[25], I[24]
    , I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16], I[15], I[14], 
    I[13], I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], 
    I[2], I[1], I[0]}), .B({I[15], I[14], I[13], I[12], I[11], I[10], I[9], 
    I[8], I[7], I[6], I[5], I[4], I[3], I[2], I[1], I[0], I[31], I[30], 
    I[29], I[28], I[27], I[26], I[25], I[24], I[23], I[22], I[21], I[20], 
    I[19], I[18], I[17], I[16]}), .SB(S1), .S({T[31], T[30], T[29], T[28], 
    T[27], T[26], T[25], T[24], T[23], T[22], T[21], T[20], T[19], T[18], 
    T[17], T[16], T[15], T[14], T[13], T[12], T[11], T[10], T[9], T[8], T[7]
    , T[6], T[5], T[4], T[3], T[2], T[1], T[0]}));

endmodule  // ROTEIGHT2

module M2_1X8_SR (A, B, NUL, O, SB, SET);
  wire X1N4, X1N6, X1N31, X1N32, X1N51, X1N42, X1N52, X1N43, X1N25, X1N26, 
    X1N46, X1N37, X1N92, X1N56, X1N47, X1N38, X1N57, X1N85;
  AND2B1 X1I112 (.I0(NUL), .I1(SB), .O(X1N92));
  AND2B2 X1I113 (.I0(NUL), .I1(SB), .O(X1N85));
  AND2 X1I13 (.I0(X1N85), .I1(A[7]), .O(X1N4));
  AND2 X1I14 (.I0(X1N92), .I1(B[7]), .O(X1N6));
  AND2 X1I23 (.I0(X1N92), .I1(B[6]), .O(X1N26));
  OR3 X1I24 (.I0(SET), .I1(X1N26), .I2(X1N25), .O(O[6]));
  AND2 X1I27 (.I0(X1N85), .I1(A[6]), .O(X1N25));
  AND2 X1I29 (.I0(X1N92), .I1(B[5]), .O(X1N32));
  OR3 X1I3 (.I0(SET), .I1(X1N6), .I2(X1N4), .O(O[7]));
  OR3 X1I30 (.I0(SET), .I1(X1N32), .I2(X1N31), .O(O[5]));
  AND2 X1I33 (.I0(X1N85), .I1(A[5]), .O(X1N31));
  AND2 X1I35 (.I0(X1N92), .I1(B[4]), .O(X1N38));
  OR3 X1I36 (.I0(SET), .I1(X1N38), .I2(X1N37), .O(O[4]));
  AND2 X1I39 (.I0(X1N85), .I1(A[4]), .O(X1N37));
  AND2 X1I40 (.I0(X1N92), .I1(B[3]), .O(X1N43));
  OR3 X1I41 (.I0(SET), .I1(X1N43), .I2(X1N42), .O(O[3]));
  AND2 X1I44 (.I0(X1N85), .I1(A[3]), .O(X1N42));
  AND2 X1I45 (.I0(X1N85), .I1(A[2]), .O(X1N47));
  OR3 X1I48 (.I0(SET), .I1(X1N46), .I2(X1N47), .O(O[2]));
  AND2 X1I49 (.I0(X1N92), .I1(B[2]), .O(X1N46));
  AND2 X1I50 (.I0(X1N85), .I1(A[1]), .O(X1N52));
  OR3 X1I53 (.I0(SET), .I1(X1N51), .I2(X1N52), .O(O[1]));
  AND2 X1I54 (.I0(X1N92), .I1(B[1]), .O(X1N51));
  AND2 X1I55 (.I0(X1N85), .I1(A[0]), .O(X1N57));
  OR3 X1I58 (.I0(SET), .I1(X1N56), .I2(X1N57), .O(O[0]));
  AND2 X1I59 (.I0(X1N92), .I1(B[0]), .O(X1N56));

endmodule  // M2_1X8_SR

module BYTEMASK (A, B, MASK, NULL0, NULL1, NULL2, NULL3, O, SB0, SB1, SB2, 
    SB3);
  wire X1N40, X1N50, X1N51, X1N42, X1N44, X1N35, X1N45, X1N28;
  M2_1X8_SR X1I1 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25], A[24]
    }), .B({B[31], B[30], B[29], B[28], B[27], B[26], B[25], B[24]}), .NUL
    (X1N28), .O({O[31], O[30], O[29], O[28], O[27], O[26], O[25], O[24]}), 
    .SB(SB3), .SET(X1N35));
  M2_1X8_SR X1I12 (.A({A[15], A[14], A[13], A[12], A[11], A[10], A[9], A[8]}
    ), .B({B[15], B[14], B[13], B[12], B[11], B[10], B[9], B[8]}), .NUL
    (X1N45), .O({O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8]}), .SB
    (SB1), .SET(X1N44));
  M2_1X8_SR X1I15 (.A({A[7], A[6], A[5], A[4], A[3], A[2], A[1], A[0]}), .B(
    {B[7], B[6], B[5], B[4], B[3], B[2], B[1], B[0]}), .NUL(X1N51), .O({O[7]
    , O[6], O[5], O[4], O[3], O[2], O[1], O[0]}), .SB(SB0), .SET(X1N50));
  M2_1X8_SR X1I2 (.A({A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16]
    }), .B({B[23], B[22], B[21], B[20], B[19], B[18], B[17], B[16]}), .NUL
    (X1N40), .O({O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}), 
    .SB(SB2), .SET(X1N42));
  AND2B1 X1I29 (.I0(MASK), .I1(NULL3), .O(X1N28));
  AND2 X1I30 (.I0(MASK), .I1(NULL3), .O(X1N35));
  AND2 X1I38 (.I0(MASK), .I1(NULL2), .O(X1N42));
  AND2B1 X1I39 (.I0(MASK), .I1(NULL2), .O(X1N40));
  AND2B1 X1I46 (.I0(MASK), .I1(NULL1), .O(X1N45));
  AND2 X1I47 (.I0(MASK), .I1(NULL1), .O(X1N44));
  AND2B1 X1I52 (.I0(MASK), .I1(NULL0), .O(X1N51));
  AND2 X1I53 (.I0(MASK), .I1(NULL0), .O(X1N50));

endmodule  // BYTEMASK

module ROTEIGHT (I, O, S0, S1);
  wire [31:0] T, I, O;
  MUX2_1X32 X1I1 (.A({T[31], T[30], T[29], T[28], T[27], T[26], T[25], T[24]
    , T[23], T[22], T[21], T[20], T[19], T[18], T[17], T[16], T[15], T[14], 
    T[13], T[12], T[11], T[10], T[9], T[8], T[7], T[6], T[5], T[4], T[3], 
    T[2], T[1], T[0]}), .B({T[23], T[22], T[21], T[20], T[19], T[18], T[17]
    , T[16], T[15], T[14], T[13], T[12], T[11], T[10], T[9], T[8], T[7], 
    T[6], T[5], T[4], T[3], T[2], T[1], T[0], T[31], T[30], T[29], T[28], 
    T[27], T[26], T[25], T[24]}), .SB(S0), .S({O[31], O[30], O[29], O[28], 
    O[27], O[26], O[25], O[24], O[23], O[22], O[21], O[20], O[19], O[18], 
    O[17], O[16], O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], O[7]
    , O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  MUX2_1X32 X1I2 (.A({I[31], I[30], I[29], I[28], I[27], I[26], I[25], I[24]
    , I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16], I[15], I[14], 
    I[13], I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], 
    I[2], I[1], I[0]}), .B({I[15], I[14], I[13], I[12], I[11], I[10], I[9], 
    I[8], I[7], I[6], I[5], I[4], I[3], I[2], I[1], I[0], I[31], I[30], 
    I[29], I[28], I[27], I[26], I[25], I[24], I[23], I[22], I[21], I[20], 
    I[19], I[18], I[17], I[16]}), .SB(S1), .S({T[31], T[30], T[29], T[28], 
    T[27], T[26], T[25], T[24], T[23], T[22], T[21], T[20], T[19], T[18], 
    T[17], T[16], T[15], T[14], T[13], T[12], T[11], T[10], T[9], T[8], T[7]
    , T[6], T[5], T[4], T[3], T[2], T[1], T[0]}));

endmodule  // ROTEIGHT

module M2_1X8 (A, B, O, SB);
  wire X1N4, X1N6, X1N31, X1N32, X1N51, X1N42, X1N52, X1N43, X1N25, X1N26, 
    X1N46, X1N37, X1N56, X1N47, X1N38, X1N57, X1N85;
  OR2 X1I115 (.I0(X1N56), .I1(X1N57), .O(O[0]));
  OR2 X1I116 (.I0(X1N6), .I1(X1N4), .O(O[7]));
  OR2 X1I117 (.I0(X1N26), .I1(X1N25), .O(O[6]));
  OR2 X1I118 (.I0(X1N32), .I1(X1N31), .O(O[5]));
  OR2 X1I119 (.I0(X1N38), .I1(X1N37), .O(O[4]));
  OR2 X1I120 (.I0(X1N51), .I1(X1N52), .O(O[1]));
  OR2 X1I121 (.I0(X1N46), .I1(X1N47), .O(O[2]));
  OR2 X1I122 (.I0(X1N43), .I1(X1N42), .O(O[3]));
  INV X1I126 (.I(SB), .O(X1N85));
  AND2 X1I13 (.I0(X1N85), .I1(A[7]), .O(X1N4));
  AND2 X1I14 (.I0(SB), .I1(B[7]), .O(X1N6));
  AND2 X1I23 (.I0(SB), .I1(B[6]), .O(X1N26));
  AND2 X1I27 (.I0(X1N85), .I1(A[6]), .O(X1N25));
  AND2 X1I29 (.I0(SB), .I1(B[5]), .O(X1N32));
  AND2 X1I33 (.I0(X1N85), .I1(A[5]), .O(X1N31));
  AND2 X1I35 (.I0(SB), .I1(B[4]), .O(X1N38));
  AND2 X1I39 (.I0(X1N85), .I1(A[4]), .O(X1N37));
  AND2 X1I40 (.I0(SB), .I1(B[3]), .O(X1N43));
  AND2 X1I44 (.I0(X1N85), .I1(A[3]), .O(X1N42));
  AND2 X1I45 (.I0(X1N85), .I1(A[2]), .O(X1N47));
  AND2 X1I49 (.I0(SB), .I1(B[2]), .O(X1N46));
  AND2 X1I50 (.I0(X1N85), .I1(A[1]), .O(X1N52));
  AND2 X1I54 (.I0(SB), .I1(B[1]), .O(X1N51));
  AND2 X1I55 (.I0(X1N85), .I1(A[0]), .O(X1N57));
  AND2 X1I59 (.I0(SB), .I1(B[0]), .O(X1N56));

endmodule  // M2_1X8

module BYTE_MUX (A, B, O, SB0, SB1, SB2, SB3);
  M2_1X8 X1I1 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25], A[24]})
    , .B({B[31], B[30], B[29], B[28], B[27], B[26], B[25], B[24]}), .O({
    O[31], O[30], O[29], O[28], O[27], O[26], O[25], O[24]}), .SB(SB3));
  M2_1X8 X1I12 (.A({A[15], A[14], A[13], A[12], A[11], A[10], A[9], A[8]}), 
    .B({B[15], B[14], B[13], B[12], B[11], B[10], B[9], B[8]}), .O({O[15], 
    O[14], O[13], O[12], O[11], O[10], O[9], O[8]}), .SB(SB1));
  M2_1X8 X1I15 (.A({A[7], A[6], A[5], A[4], A[3], A[2], A[1], A[0]}), .B({
    B[7], B[6], B[5], B[4], B[3], B[2], B[1], B[0]}), .O({O[7], O[6], O[5], 
    O[4], O[3], O[2], O[1], O[0]}), .SB(SB0));
  M2_1X8 X1I2 (.A({A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16]})
    , .B({B[23], B[22], B[21], B[20], B[19], B[18], B[17], B[16]}), .O({
    O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}), .SB(SB2));

endmodule  // BYTE_MUX

module SOP4 (I0, I1, I2, I3, O);
  output O;
  input I3, I2, I1, I0;
  wire [15:0] Q, D;
  wire I01, I23;
  AND2 X1I7 (.I0(I2), .I1(I3), .O(I23));
  OR2 X1I8 (.I0(I01), .I1(I23), .O(O));
  AND2 X1I9 (.I0(I0), .I1(I1), .O(I01));

endmodule  // SOP4

module SOP4B1 (I0, I1, I2, I3, O);
  output O;
  input I3, I2, I1, I0;
  wire [15:0] Q, D;
  wire I0B1, I23;
  AND2 X1I7 (.I0(I2), .I1(I3), .O(I23));
  OR2 X1I8 (.I0(I0B1), .I1(I23), .O(O));
  AND2B1 X1I9 (.I0(I0), .I1(I1), .O(I0B1));

endmodule  // SOP4B1

module D2_4E (.A0(A[0]), .A1(A[1]), .D0(D[0]), .D1(D[1]), .D2(D[2]), .D3
    (D[3]), E);
  output [3:0] D;
  input E;
  input [1:0] A;
  wire [63:0] A;
  wire [15:0] Q, D, O, I, IO;
  wire [7:0] DPO, SPO;
  AND3 X1I30 (.I0(A[1]), .I1(A[0]), .I2(E), .O(D[3]));
  AND3B1 X1I31 (.I0(A[0]), .I1(A[1]), .I2(E), .O(D[2]));
  AND3B1 X1I32 (.I0(A[1]), .I1(A[0]), .I2(E), .O(D[1]));
  AND3B2 X1I33 (.I0(A[0]), .I1(A[1]), .I2(E), .O(D[0]));

endmodule  // D2_4E

module LSRAMANDCON (LA, LCE, LD, LOE, LRD, LWD, LWE);
  wire X1N4, X1N154, X1N9, X1N267, X1N258, X1N249, X1N21, X1N13, X1N41, 
    X1N33, X1N61, X1N25, X1N53, X1N17, X1N45, X1N73, X1N37, X1N65, X1N29, 
    X1N57, X1N49, X1N77, X1N69;
  MU_TITLE X1I1 ();
  OBUF X1I11 (.I(LA[2]), .O(X1N13));
  IOBUF X1I112 (.I(LWD[8]), .IO(LD[8]), .O(LRD[8]), .T(X1N154));
  IOPAD X1I113 (.IOPAD(LD[8]));
  IOBUF X1I119 (.I(LWD[9]), .IO(LD[9]), .O(LRD[9]), .T(X1N154));
  OPAD X1I12 (.OPAD(X1N13));
  IOPAD X1I120 (.IOPAD(LD[9]));
  IOBUF X1I124 (.I(LWD[10]), .IO(LD[10]), .O(LRD[10]), .T(X1N154));
  IOPAD X1I125 (.IOPAD(LD[10]));
  IOBUF X1I129 (.I(LWD[11]), .IO(LD[11]), .O(LRD[11]), .T(X1N154));
  IOPAD X1I130 (.IOPAD(LD[11]));
  IOPAD X1I135 (.IOPAD(LD[12]));
  IOBUF X1I136 (.I(LWD[12]), .IO(LD[12]), .O(LRD[12]), .T(X1N154));
  IOPAD X1I140 (.IOPAD(LD[13]));
  IOBUF X1I141 (.I(LWD[13]), .IO(LD[13]), .O(LRD[13]), .T(X1N154));
  IOBUF X1I144 (.I(LWD[14]), .IO(LD[14]), .O(LRD[14]), .T(X1N154));
  IOPAD X1I145 (.IOPAD(LD[14]));
  IOBUF X1I149 (.I(LWD[15]), .IO(LD[15]), .O(LRD[15]), .T(X1N154));
  OBUF X1I15 (.I(LA[3]), .O(X1N17));
  IOPAD X1I150 (.IOPAD(LD[15]));
  OPAD X1I16 (.OPAD(X1N17));
  OBUF X1I19 (.I(LA[4]), .O(X1N21));
  OBUF X1I2 (.I(LA[0]), .O(X1N4));
  OPAD X1I20 (.OPAD(X1N21));
  IOBUF X1I206 (.I(LWD[7]), .IO(LD[7]), .O(LRD[7]), .T(X1N154));
  IOBUF X1I207 (.I(LWD[6]), .IO(LD[6]), .O(LRD[6]), .T(X1N154));
  IOBUF X1I208 (.I(LWD[5]), .IO(LD[5]), .O(LRD[5]), .T(X1N154));
  IOBUF X1I209 (.I(LWD[4]), .IO(LD[4]), .O(LRD[4]), .T(X1N154));
  IOBUF X1I210 (.I(LWD[3]), .IO(LD[3]), .O(LRD[3]), .T(X1N154));
  IOBUF X1I211 (.I(LWD[2]), .IO(LD[2]), .O(LRD[2]), .T(X1N154));
  IOBUF X1I212 (.I(LWD[1]), .IO(LD[1]), .O(LRD[1]), .T(X1N154));
  IOBUF X1I213 (.I(LWD[0]), .IO(LD[0]), .O(LRD[0]), .T(X1N154));
  IOPAD X1I214 (.IOPAD(LD[7]));
  IOPAD X1I215 (.IOPAD(LD[6]));
  IOPAD X1I216 (.IOPAD(LD[5]));
  IOPAD X1I217 (.IOPAD(LD[4]));
  IOPAD X1I218 (.IOPAD(LD[3]));
  IOPAD X1I219 (.IOPAD(LD[2]));
  IOPAD X1I220 (.IOPAD(LD[1]));
  IOPAD X1I221 (.IOPAD(LD[0]));
  OBUF X1I23 (.I(LA[5]), .O(X1N25));
  OPAD X1I24 (.OPAD(X1N25));
  OPAD X1I248 (.OPAD(X1N249));
  OBUF X1I250 (.I(LOE), .O(X1N249));
  IBUF X1I253 (.I(X1N258), .O(X1N154));
  OBUF X1I257 (.I(LWE), .O(X1N258));
  OPAD X1I259 (.OPAD(X1N258));
  OBUF X1I266 (.I(LCE), .O(X1N267));
  OPAD X1I268 (.OPAD(X1N267));
  OBUF X1I27 (.I(LA[6]), .O(X1N29));
  OPAD X1I28 (.OPAD(X1N29));
  OPAD X1I3 (.OPAD(X1N4));
  OBUF X1I31 (.I(LA[7]), .O(X1N33));
  OPAD X1I32 (.OPAD(X1N33));
  OBUF X1I35 (.I(LA[8]), .O(X1N37));
  OPAD X1I36 (.OPAD(X1N37));
  OBUF X1I39 (.I(LA[9]), .O(X1N41));
  OPAD X1I40 (.OPAD(X1N41));
  OBUF X1I43 (.I(LA[10]), .O(X1N45));
  OPAD X1I44 (.OPAD(X1N45));
  OBUF X1I47 (.I(LA[11]), .O(X1N49));
  OPAD X1I48 (.OPAD(X1N49));
  OBUF X1I51 (.I(LA[12]), .O(X1N53));
  OPAD X1I52 (.OPAD(X1N53));
  OBUF X1I55 (.I(LA[13]), .O(X1N57));
  OPAD X1I56 (.OPAD(X1N57));
  OBUF X1I59 (.I(LA[14]), .O(X1N61));
  OPAD X1I60 (.OPAD(X1N61));
  OBUF X1I63 (.I(LA[15]), .O(X1N65));
  OPAD X1I64 (.OPAD(X1N65));
  OBUF X1I67 (.I(LA[16]), .O(X1N69));
  OPAD X1I68 (.OPAD(X1N69));
  OBUF X1I7 (.I(LA[1]), .O(X1N9));
  OBUF X1I71 (.I(LA[17]), .O(X1N73));
  OPAD X1I72 (.OPAD(X1N73));
  OBUF X1I75 (.I(LA[18]), .O(X1N77));
  OPAD X1I76 (.OPAD(X1N77));
  OPAD X1I8 (.OPAD(X1N9));

endmodule  // LSRAMANDCON

module RSRAMANDCON (RA, RCE, RD, ROE, RRD, RWD, RWE);
  wire X1N4, X1N270, X1N154, X1N9, X1N267, X1N249, X1N21, X1N13, X1N41, 
    X1N33, X1N61, X1N25, X1N53, X1N17, X1N45, X1N73, X1N37, X1N65, X1N29, 
    X1N57, X1N49, X1N77, X1N69;
  MU_TITLE X1I1 ();
  OBUF X1I11 (.I(RA[2]), .O(X1N13));
  IOBUF X1I112 (.I(RWD[8]), .IO(RD[8]), .O(RRD[8]), .T(X1N270));
  IOPAD X1I113 (.IOPAD(RD[8]));
  IOBUF X1I119 (.I(RWD[9]), .IO(RD[9]), .O(RRD[9]), .T(X1N270));
  OPAD X1I12 (.OPAD(X1N13));
  IOPAD X1I120 (.IOPAD(RD[9]));
  IOBUF X1I124 (.I(RWD[10]), .IO(RD[10]), .O(RRD[10]), .T(X1N270));
  IOPAD X1I125 (.IOPAD(RD[10]));
  IOBUF X1I129 (.I(RWD[11]), .IO(RD[11]), .O(RRD[11]), .T(X1N270));
  IOPAD X1I130 (.IOPAD(RD[11]));
  IOPAD X1I135 (.IOPAD(RD[12]));
  IOBUF X1I136 (.I(RWD[12]), .IO(RD[12]), .O(RRD[12]), .T(X1N270));
  IOPAD X1I140 (.IOPAD(RD[13]));
  IOBUF X1I141 (.I(RWD[13]), .IO(RD[13]), .O(RRD[13]), .T(X1N270));
  IOBUF X1I144 (.I(RWD[14]), .IO(RD[14]), .O(RRD[14]), .T(X1N270));
  IOPAD X1I145 (.IOPAD(RD[14]));
  IOBUF X1I149 (.I(RWD[15]), .IO(RD[15]), .O(RRD[15]), .T(X1N270));
  OBUF X1I15 (.I(RA[3]), .O(X1N17));
  IOPAD X1I150 (.IOPAD(RD[15]));
  OPAD X1I16 (.OPAD(X1N17));
  OBUF X1I19 (.I(RA[4]), .O(X1N21));
  OBUF X1I2 (.I(RA[0]), .O(X1N4));
  OPAD X1I20 (.OPAD(X1N21));
  IOBUF X1I206 (.I(RWD[7]), .IO(RD[7]), .O(RRD[7]), .T(X1N270));
  IOBUF X1I207 (.I(RWD[6]), .IO(RD[6]), .O(RRD[6]), .T(X1N270));
  IOBUF X1I208 (.I(RWD[5]), .IO(RD[5]), .O(RRD[5]), .T(X1N270));
  IOBUF X1I209 (.I(RWD[4]), .IO(RD[4]), .O(RRD[4]), .T(X1N270));
  IOBUF X1I210 (.I(RWD[3]), .IO(RD[3]), .O(RRD[3]), .T(X1N270));
  IOBUF X1I211 (.I(RWD[2]), .IO(RD[2]), .O(RRD[2]), .T(X1N270));
  IOBUF X1I212 (.I(RWD[1]), .IO(RD[1]), .O(RRD[1]), .T(X1N270));
  IOBUF X1I213 (.I(RWD[0]), .IO(RD[0]), .O(RRD[0]), .T(X1N270));
  IOPAD X1I214 (.IOPAD(RD[7]));
  IOPAD X1I215 (.IOPAD(RD[6]));
  IOPAD X1I216 (.IOPAD(RD[5]));
  IOPAD X1I217 (.IOPAD(RD[4]));
  IOPAD X1I218 (.IOPAD(RD[3]));
  IOPAD X1I219 (.IOPAD(RD[2]));
  IOPAD X1I220 (.IOPAD(RD[1]));
  IOPAD X1I221 (.IOPAD(RD[0]));
  OBUF X1I23 (.I(RA[5]), .O(X1N25));
  OPAD X1I24 (.OPAD(X1N25));
  OPAD X1I248 (.OPAD(X1N249));
  OBUF X1I250 (.I(ROE), .O(X1N249));
  OBUF X1I257 (.I(RWE), .O(X1N154));
  OPAD X1I259 (.OPAD(X1N154));
  OBUF X1I266 (.I(RCE), .O(X1N267));
  OPAD X1I268 (.OPAD(X1N267));
  OBUF X1I27 (.I(RA[6]), .O(X1N29));
  IBUF X1I271 (.I(X1N154), .O(X1N270));
  OPAD X1I28 (.OPAD(X1N29));
  OPAD X1I3 (.OPAD(X1N4));
  OBUF X1I31 (.I(RA[7]), .O(X1N33));
  OPAD X1I32 (.OPAD(X1N33));
  OBUF X1I35 (.I(RA[8]), .O(X1N37));
  OPAD X1I36 (.OPAD(X1N37));
  OBUF X1I39 (.I(RA[9]), .O(X1N41));
  OPAD X1I40 (.OPAD(X1N41));
  OBUF X1I43 (.I(RA[10]), .O(X1N45));
  OPAD X1I44 (.OPAD(X1N45));
  OBUF X1I47 (.I(RA[11]), .O(X1N49));
  OPAD X1I48 (.OPAD(X1N49));
  OBUF X1I51 (.I(RA[12]), .O(X1N53));
  OPAD X1I52 (.OPAD(X1N53));
  OBUF X1I55 (.I(RA[13]), .O(X1N57));
  OPAD X1I56 (.OPAD(X1N57));
  OBUF X1I59 (.I(RA[14]), .O(X1N61));
  OPAD X1I60 (.OPAD(X1N61));
  OBUF X1I63 (.I(RA[15]), .O(X1N65));
  OPAD X1I64 (.OPAD(X1N65));
  OBUF X1I67 (.I(RA[16]), .O(X1N69));
  OPAD X1I68 (.OPAD(X1N69));
  OBUF X1I7 (.I(RA[1]), .O(X1N9));
  OBUF X1I71 (.I(RA[17]), .O(X1N73));
  OPAD X1I72 (.OPAD(X1N73));
  OBUF X1I75 (.I(RA[18]), .O(X1N77));
  OPAD X1I76 (.OPAD(X1N77));
  OPAD X1I8 (.OPAD(X1N9));

endmodule  // RSRAMANDCON

module MEM (ADDRESS, CE, MEM_READ_DATA, OE, WR, WRITE_DATA);
  wire NCE, X1N13, X1N19;
  LSRAMANDCON X1I1 (.LA({ADDRESS[20], ADDRESS[19], ADDRESS[18], ADDRESS[17]
    , ADDRESS[16], ADDRESS[15], ADDRESS[14], ADDRESS[13], ADDRESS[12], 
    ADDRESS[11], ADDRESS[10], ADDRESS[9], ADDRESS[8], ADDRESS[7], ADDRESS[6]
    , ADDRESS[5], ADDRESS[4], ADDRESS[3], ADDRESS[2]}), .LCE(NCE), .LOE
    (X1N13), .LRD({MEM_READ_DATA[15], MEM_READ_DATA[14], MEM_READ_DATA[13], 
    MEM_READ_DATA[12], MEM_READ_DATA[11], MEM_READ_DATA[10], 
    MEM_READ_DATA[9], MEM_READ_DATA[8], MEM_READ_DATA[7], MEM_READ_DATA[6], 
    MEM_READ_DATA[5], MEM_READ_DATA[4], MEM_READ_DATA[3], MEM_READ_DATA[2], 
    MEM_READ_DATA[1], MEM_READ_DATA[0]}), .LWD({WRITE_DATA[15], 
    WRITE_DATA[14], WRITE_DATA[13], WRITE_DATA[12], WRITE_DATA[11], 
    WRITE_DATA[10], WRITE_DATA[9], WRITE_DATA[8], WRITE_DATA[7], 
    WRITE_DATA[6], WRITE_DATA[5], WRITE_DATA[4], WRITE_DATA[3], 
    WRITE_DATA[2], WRITE_DATA[1], WRITE_DATA[0]}), .LWE(X1N19));
  INV X1I17 (.I(WR), .O(X1N19));
  RSRAMANDCON X1I2 (.RA({ADDRESS[20], ADDRESS[19], ADDRESS[18], ADDRESS[17]
    , ADDRESS[16], ADDRESS[15], ADDRESS[14], ADDRESS[13], ADDRESS[12], 
    ADDRESS[11], ADDRESS[10], ADDRESS[9], ADDRESS[8], ADDRESS[7], ADDRESS[6]
    , ADDRESS[5], ADDRESS[4], ADDRESS[3], ADDRESS[2]}), .RCE(NCE), .ROE
    (X1N13), .RRD({MEM_READ_DATA[31], MEM_READ_DATA[30], MEM_READ_DATA[29], 
    MEM_READ_DATA[28], MEM_READ_DATA[27], MEM_READ_DATA[26], 
    MEM_READ_DATA[25], MEM_READ_DATA[24], MEM_READ_DATA[23], 
    MEM_READ_DATA[22], MEM_READ_DATA[21], MEM_READ_DATA[20], 
    MEM_READ_DATA[19], MEM_READ_DATA[18], MEM_READ_DATA[17], 
    MEM_READ_DATA[16]}), .RWD({WRITE_DATA[31], WRITE_DATA[30], 
    WRITE_DATA[29], WRITE_DATA[28], WRITE_DATA[27], WRITE_DATA[26], 
    WRITE_DATA[25], WRITE_DATA[24], WRITE_DATA[23], WRITE_DATA[22], 
    WRITE_DATA[21], WRITE_DATA[20], WRITE_DATA[19], WRITE_DATA[18], 
    WRITE_DATA[17], WRITE_DATA[16]}), .RWE(X1N19));
  INV X1I257 (.I(CE), .O(NCE));
  INV X1I263 (.I(OE), .O(X1N13));

endmodule  // MEM

module DCOUNT (CLK, EN, IN, LOAD, O, ZERO);
  wire [31:0] S, O, I, A, IN;
  wire [15:0] GB, G;
  wire X1N131, X1N115, X1N107, X1N71, X1N62, X1N57, X1N88;
  BUF X1I100 (.I(X1N115), .O(G[7]));
  BUF X1I101 (.I(X1N115), .O(G[6]));
  BUF X1I102 (.I(X1N115), .O(G[3]));
  BUF X1I103 (.I(X1N115), .O(G[1]));
  BUF X1I104 (.I(X1N115), .O(G[0]));
  INV X1I114 (.I(X1N115), .O(X1N71));
  ADD16 IGNORE_NO_LOAD8 (.A({O[15], O[14], O[13], O[12], O[11], O[10], O[9]
    , O[8], O[7], O[6], O[5], O[4], O[3], O[2], O[1], O[0]}), .B({G[15], 
    G[14], G[13], G[12], G[11], G[10], G[9], G[8], G[7], G[6], G[5], G[4], 
    G[3], G[2], G[1], G[0]}), .CI(X1N71), .CO(X1N107), .S({S[15], S[14], 
    S[13], S[12], S[11], S[10], S[9], S[8], S[7], S[6], S[5], S[4], S[3], 
    S[2], S[1], S[0]}));
  ADD16 IGNORE_NO_LOAD9 (.A({O[31], O[30], O[29], O[28], O[27], O[26], O[25]
    , O[24], O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}), .B({
    GB[15], GB[14], GB[13], GB[12], GB[11], GB[10], GB[9], GB[8], GB[7], 
    GB[6], GB[5], GB[4], GB[3], GB[2], GB[1], GB[0]}), .CI(X1N107), .CO
    (X1N131), .S({S[31], S[30], S[29], S[28], S[27], S[26], S[25], S[24], 
    S[23], S[22], S[21], S[20], S[19], S[18], S[17], S[16]}));
  BUF X1I120 (.I(X1N115), .O(G[2]));
  VCC X1I122 (.P(X1N88));
  VCC X1I125 (.P(X1N115));
  MUX2_1X32 X1I126 (.A({S[31], S[30], S[29], S[28], S[27], S[26], S[25], 
    S[24], S[23], S[22], S[21], S[20], S[19], S[18], S[17], S[16], S[15], 
    S[14], S[13], S[12], S[11], S[10], S[9], S[8], S[7], S[6], S[5], S[4], 
    S[3], S[2], S[1], S[0]}), .B({IN[31], IN[30], IN[29], IN[28], IN[27], 
    IN[26], IN[25], IN[24], IN[23], IN[22], IN[21], IN[20], IN[19], IN[18], 
    IN[17], IN[16], IN[15], IN[14], IN[13], IN[12], IN[11], IN[10], IN[9], 
    IN[8], IN[7], IN[6], IN[5], IN[4], IN[3], IN[2], IN[1], IN[0]}), .SB
    (LOAD), .S({I[31], I[30], I[29], I[28], I[27], I[26], I[25], I[24], 
    I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16], I[15], I[14], 
    I[13], I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], 
    I[2], I[1], I[0]}));
  OR2 X1I135 (.I0(LOAD), .I1(EN), .O(X1N62));
  INV X1I138 (.I(X1N131), .O(ZERO));
  FD16CE X1I55 (.C(CLK), .CE(X1N62), .CLR(X1N57), .D({I[15], I[14], I[13], 
    I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], I[2], 
    I[1], I[0]}), .Q({O[15], O[14], O[13], O[12], O[11], O[10], O[9], O[8], 
    O[7], O[6], O[5], O[4], O[3], O[2], O[1], O[0]}));
  FD16CE X1I56 (.C(CLK), .CE(X1N62), .CLR(X1N57), .D({I[31], I[30], I[29], 
    I[28], I[27], I[26], I[25], I[24], I[23], I[22], I[21], I[20], I[19], 
    I[18], I[17], I[16]}), .Q({O[31], O[30], O[29], O[28], O[27], O[26], 
    O[25], O[24], O[23], O[22], O[21], O[20], O[19], O[18], O[17], O[16]}));
  GND X1I59 (.G(X1N57));
  BUF X1I72 (.I(X1N88), .O(GB[0]));
  BUF X1I73 (.I(X1N88), .O(GB[1]));
  BUF X1I74 (.I(X1N88), .O(GB[3]));
  BUF X1I75 (.I(X1N88), .O(GB[2]));
  BUF X1I76 (.I(X1N88), .O(GB[6]));
  BUF X1I77 (.I(X1N88), .O(GB[7]));
  BUF X1I78 (.I(X1N88), .O(GB[5]));
  BUF X1I79 (.I(X1N88), .O(GB[4]));
  BUF X1I80 (.I(X1N88), .O(GB[10]));
  BUF X1I81 (.I(X1N88), .O(GB[11]));
  BUF X1I82 (.I(X1N88), .O(GB[9]));
  BUF X1I83 (.I(X1N88), .O(GB[8]));
  BUF X1I84 (.I(X1N88), .O(GB[14]));
  BUF X1I85 (.I(X1N88), .O(GB[15]));
  BUF X1I86 (.I(X1N88), .O(GB[13]));
  BUF X1I87 (.I(X1N88), .O(GB[12]));
  BUF X1I90 (.I(X1N115), .O(G[12]));
  BUF X1I91 (.I(X1N115), .O(G[13]));
  BUF X1I92 (.I(X1N115), .O(G[15]));
  BUF X1I93 (.I(X1N115), .O(G[14]));
  BUF X1I94 (.I(X1N115), .O(G[8]));
  BUF X1I95 (.I(X1N115), .O(G[9]));
  BUF X1I96 (.I(X1N115), .O(G[11]));
  BUF X1I97 (.I(X1N115), .O(G[10]));
  BUF X1I98 (.I(X1N115), .O(G[4]));
  BUF X1I99 (.I(X1N115), .O(G[5]));

// WARNING - Component IGNORE_NO_LOAD9 has unconnected pins: 0 input, 1 output, 0 inout.
// WARNING - Component IGNORE_NO_LOAD8 has unconnected pins: 0 input, 1 output, 0 inout.
endmodule  // DCOUNT

module CMP_EQ_5 (A, B, O);
  wire X1N51, X1N53, X1N73, X1N55, X1N57, X1N49, X1N68;
  XOR2 X1I33 (.I0(A[4]), .I1(B[4]), .O(X1N49));
  XOR2 X1I34 (.I0(A[3]), .I1(B[3]), .O(X1N51));
  XOR2 X1I35 (.I0(A[2]), .I1(B[2]), .O(X1N53));
  XOR2 X1I36 (.I0(A[1]), .I1(B[1]), .O(X1N55));
  XOR2 X1I37 (.I0(A[0]), .I1(B[0]), .O(X1N57));
  NOR5 X1I60 (.I0(B[0]), .I1(B[1]), .I2(B[2]), .I3(B[3]), .I4(B[4]), .O
    (X1N68));
  OR4 X1I71 (.I0(X1N57), .I1(X1N55), .I2(X1N53), .I3(X1N51), .O(X1N73));
  NOR3 X1I72 (.I0(X1N73), .I1(X1N49), .I2(X1N68), .O(O));

endmodule  // CMP_EQ_5

module ADD32 (A, B, S);
  output [31:0] S;
  input [31:0] B;
  input [31:0] A;
  wire X1N34, X1N28, X1N38;
  ADD16 IGNORE_NO_LOAD8 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25]
    , A[24], A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16]}), .B({
    B[31], B[30], B[29], B[28], B[27], B[26], B[25], B[24], B[23], B[22], 
    B[21], B[20], B[19], B[18], B[17], B[16]}), .CI(X1N28), .S({S[31], S[30]
    , S[29], S[28], S[27], S[26], S[25], S[24], S[23], S[22], S[21], S[20], 
    S[19], S[18], S[17], S[16]}));
  ADD16 IGNORE_NO_LOAD7 (.A({A[15], A[14], A[13], A[12], A[11], A[10], A[9]
    , A[8], A[7], A[6], A[5], A[4], A[3], A[2], A[1], A[0]}), .B({B[15], 
    B[14], B[13], B[12], B[11], B[10], B[9], B[8], B[7], B[6], B[5], B[4], 
    B[3], B[2], B[1], B[0]}), .CI(X1N38), .CO(X1N34), .S({S[15], S[14], 
    S[13], S[12], S[11], S[10], S[9], S[8], S[7], S[6], S[5], S[4], S[3], 
    S[2], S[1], S[0]}));
  BUF X1I33 (.I(X1N34), .O(X1N28));
  GND X1I42 (.G(X1N38));

// WARNING - Component IGNORE_NO_LOAD7 has unconnected pins: 0 input, 1 output, 0 inout.
// WARNING - Component IGNORE_NO_LOAD8 has unconnected pins: 0 input, 2 output, 0 inout.
endmodule  // ADD32

module NULL25TO0 (I, NULL, O);
  AND2B1 X1I13 (.I0(NULL), .I1(I[17]), .O(O[17]));
  BUF X1I134 (.I(I[29]), .O(O[29]));
  BUF X1I135 (.I(I[28]), .O(O[28]));
  AND2B1 X1I14 (.I0(NULL), .I1(I[18]), .O(O[18]));
  AND2B1 X1I141 (.I0(NULL), .I1(I[26]), .O(O[26]));
  AND2B1 X1I145 (.I0(NULL), .I1(I[27]), .O(O[27]));
  AND2B1 X1I17 (.I0(NULL), .I1(I[19]), .O(O[19]));
  AND2B1 X1I18 (.I0(NULL), .I1(I[21]), .O(O[21]));
  AND2B1 X1I22 (.I0(NULL), .I1(I[20]), .O(O[20]));
  AND2B1 X1I23 (.I0(NULL), .I1(I[22]), .O(O[22]));
  AND2B1 X1I26 (.I0(NULL), .I1(I[23]), .O(O[23]));
  AND2B1 X1I27 (.I0(NULL), .I1(I[25]), .O(O[25]));
  AND2B1 X1I3 (.I0(NULL), .I1(I[14]), .O(O[14]));
  AND2B1 X1I31 (.I0(NULL), .I1(I[24]), .O(O[24]));
  AND2B1 X1I46 (.I0(NULL), .I1(I[11]), .O(O[11]));
  AND2B1 X1I48 (.I0(NULL), .I1(I[12]), .O(O[12]));
  AND2B1 X1I50 (.I0(NULL), .I1(I[13]), .O(O[13]));
  AND2B1 X1I6 (.I0(NULL), .I1(I[15]), .O(O[15]));
  AND2B1 X1I63 (.I0(NULL), .I1(I[5]), .O(O[5]));
  AND2B1 X1I64 (.I0(NULL), .I1(I[6]), .O(O[6]));
  AND2B1 X1I65 (.I0(NULL), .I1(I[8]), .O(O[8]));
  AND2B1 X1I66 (.I0(NULL), .I1(I[7]), .O(O[7]));
  AND2B1 X1I67 (.I0(NULL), .I1(I[9]), .O(O[9]));
  AND2B1 X1I77 (.I0(NULL), .I1(I[4]), .O(O[4]));
  AND2B1 X1I78 (.I0(NULL), .I1(I[3]), .O(O[3]));
  AND2B1 X1I79 (.I0(NULL), .I1(I[2]), .O(O[2]));
  AND2B1 X1I81 (.I0(NULL), .I1(I[10]), .O(O[10]));
  AND2B1 X1I83 (.I0(NULL), .I1(I[1]), .O(O[1]));
  AND2B1 X1I87 (.I0(NULL), .I1(I[0]), .O(O[0]));
  AND2B1 X1I9 (.I0(NULL), .I1(I[16]), .O(O[16]));
  BUF X1I90 (.I(I[31]), .O(O[31]));
  BUF X1I91 (.I(I[30]), .O(O[30]));

endmodule  // NULL25TO0

module SHIFTER (ARITH, I, O, RIGHT, SHIFT);
  wire [31:0] A, B, C, D, E, O, G, MASK, MASKXNORRIGHT;
  wire [4:0] SHIFT;
  wire X1N100, X1N130, X1N122, X1N113, X1N132, X1N114, X1N160, X1N151, 
    X1N115, X1N106, X1N134, X1N4, X1N153, X1N163, X1N154, X1N145, X1N127, 
    X1N118, X1N146, X1N137, X1N903, X1N147, X1N922, X1N148, X1N932, X1N923, 
    X1N167, X1N654, X1N907, X1N926, X1N927, X1N964, X1N919, X1N965, X1N966, 
    X1N894, X1N949, X1N70, X1N91, X1N73, X1N93, X1N76, X1N86, X1N68, X1N97, 
    X1N88, X1N89;
  MUX2_1X32 X1I1 (.A({I[31], I[30], I[29], I[28], I[27], I[26], I[25], I[24]
    , I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16], I[15], I[14], 
    I[13], I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], 
    I[2], I[1], I[0]}), .B({I[30], I[29], I[28], I[27], I[26], I[25], I[24]
    , I[23], I[22], I[21], I[20], I[19], I[18], I[17], I[16], I[15], I[14], 
    I[13], I[12], I[11], I[10], I[9], I[8], I[7], I[6], I[5], I[4], I[3], 
    I[2], I[1], I[0], I[31]}), .SB(X1N949), .S({A[31], A[30], A[29], A[28], 
    A[27], A[26], A[25], A[24], A[23], A[22], A[21], A[20], A[19], A[18], 
    A[17], A[16], A[15], A[14], A[13], A[12], A[11], A[10], A[9], A[8], A[7]
    , A[6], A[5], A[4], A[3], A[2], A[1], A[0]}));
  OR2 X1I104 (.I0(X1N106), .I1(MASK[10]), .O(MASK[11]));
  OR2 X1I109 (.I0(X1N113), .I1(MASK[11]), .O(MASK[12]));
  MUX2_1X32 X1I11 (.A({B[31], B[30], B[29], B[28], B[27], B[26], B[25], 
    B[24], B[23], B[22], B[21], B[20], B[19], B[18], B[17], B[16], B[15], 
    B[14], B[13], B[12], B[11], B[10], B[9], B[8], B[7], B[6], B[5], B[4], 
    B[3], B[2], B[1], B[0]}), .B({B[27], B[26], B[25], B[24], B[23], B[22], 
    B[21], B[20], B[19], B[18], B[17], B[16], B[15], B[14], B[13], B[12], 
    B[11], B[10], B[9], B[8], B[7], B[6], B[5], B[4], B[3], B[2], B[1], B[0]
    , B[31], B[30], B[29], B[28]}), .SB(X1N965), .S({C[31], C[30], C[29], 
    C[28], C[27], C[26], C[25], C[24], C[23], C[22], C[21], C[20], C[19], 
    C[18], C[17], C[16], C[15], C[14], C[13], C[12], C[11], C[10], C[9], 
    C[8], C[7], C[6], C[5], C[4], C[3], C[2], C[1], C[0]}));
  OR2 X1I111 (.I0(X1N115), .I1(MASK[12]), .O(MASK[13]));
  OR2 X1I116 (.I0(X1N114), .I1(MASK[13]), .O(MASK[14]));
  OR2 X1I117 (.I0(X1N118), .I1(MASK[14]), .O(MASK[15]));
  OR2 X1I120 (.I0(X1N146), .I1(MASK[22]), .O(MASK[23]));
  OR2 X1I121 (.I0(X1N154), .I1(MASK[29]), .O(MASK[30]));
  OR2 X1I123 (.I0(X1N153), .I1(MASK[28]), .O(MASK[29]));
  OR2 X1I124 (.I0(X1N130), .I1(MASK[19]), .O(MASK[20]));
  OR2 X1I125 (.I0(X1N148), .I1(MASK[24]), .O(MASK[25]));
  OR2 X1I126 (.I0(X1N127), .I1(MASK[23]), .O(MASK[24]));
  OR2 X1I128 (.I0(X1N134), .I1(MASK[17]), .O(MASK[18]));
  OR2 X1I131 (.I0(X1N132), .I1(MASK[16]), .O(MASK[17]));
  OR2 X1I136 (.I0(X1N137), .I1(MASK[18]), .O(MASK[19]));
  OR2 X1I141 (.I0(X1N145), .I1(MASK[20]), .O(MASK[21]));
  OR2 X1I143 (.I0(X1N147), .I1(MASK[21]), .O(MASK[22]));
  OR2 X1I150 (.I0(X1N151), .I1(MASK[25]), .O(MASK[26]));
  OR2 X1I157 (.I0(X1N122), .I1(MASK[27]), .O(MASK[28]));
  MUX2_1X32 X1I16 (.A({C[31], C[30], C[29], C[28], C[27], C[26], C[25], 
    C[24], C[23], C[22], C[21], C[20], C[19], C[18], C[17], C[16], C[15], 
    C[14], C[13], C[12], C[11], C[10], C[9], C[8], C[7], C[6], C[5], C[4], 
    C[3], C[2], C[1], C[0]}), .B({C[23], C[22], C[21], C[20], C[19], C[18], 
    C[17], C[16], C[15], C[14], C[13], C[12], C[11], C[10], C[9], C[8], C[7]
    , C[6], C[5], C[4], C[3], C[2], C[1], C[0], C[31], C[30], C[29], C[28], 
    C[27], C[26], C[25], C[24]}), .SB(X1N966), .S({D[31], D[30], D[29], 
    D[28], D[27], D[26], D[25], D[24], D[23], D[22], D[21], D[20], D[19], 
    D[18], D[17], D[16], D[15], D[14], D[13], D[12], D[11], D[10], D[9], 
    D[8], D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]}));
  OR2 X1I161 (.I0(X1N160), .I1(MASK[26]), .O(MASK[27]));
  OR2 X1I162 (.I0(X1N163), .I1(MASK[30]), .O(MASK[31]));
  OR2 X1I165 (.I0(X1N167), .I1(MASK[15]), .O(MASK[16]));
  MUX2_1X32 X1I19 (.A({D[31], D[30], D[29], D[28], D[27], D[26], D[25], 
    D[24], D[23], D[22], D[21], D[20], D[19], D[18], D[17], D[16], D[15], 
    D[14], D[13], D[12], D[11], D[10], D[9], D[8], D[7], D[6], D[5], D[4], 
    D[3], D[2], D[1], D[0]}), .B({D[15], D[14], D[13], D[12], D[11], D[10], 
    D[9], D[8], D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0], D[31], D[30]
    , D[29], D[28], D[27], D[26], D[25], D[24], D[23], D[22], D[21], D[20], 
    D[19], D[18], D[17], D[16]}), .SB(X1N4), .S({E[31], E[30], E[29], E[28]
    , E[27], E[26], E[25], E[24], E[23], E[22], E[21], E[20], E[19], E[18], 
    E[17], E[16], E[15], E[14], E[13], E[12], E[11], E[10], E[9], E[8], E[7]
    , E[6], E[5], E[4], E[3], E[2], E[1], E[0]}));
  BUF X1I206 (.I(RIGHT), .O(G[12]));
  BUF X1I207 (.I(RIGHT), .O(G[13]));
  BUF X1I208 (.I(RIGHT), .O(G[15]));
  BUF X1I209 (.I(RIGHT), .O(G[14]));
  BUF X1I210 (.I(RIGHT), .O(G[8]));
  BUF X1I211 (.I(RIGHT), .O(G[9]));
  BUF X1I212 (.I(RIGHT), .O(G[11]));
  BUF X1I213 (.I(RIGHT), .O(G[10]));
  BUF X1I214 (.I(RIGHT), .O(G[4]));
  BUF X1I215 (.I(RIGHT), .O(G[5]));
  BUF X1I216 (.I(RIGHT), .O(G[7]));
  BUF X1I217 (.I(RIGHT), .O(G[6]));
  BUF X1I218 (.I(RIGHT), .O(G[2]));
  BUF X1I219 (.I(RIGHT), .O(G[3]));
  BUF X1I220 (.I(RIGHT), .O(G[1]));
  BUF X1I221 (.I(RIGHT), .O(G[0]));
  XOR32_32_32 X1I223 (.A({MASK[31], MASK[30], MASK[29], MASK[28], MASK[27], 
    MASK[26], MASK[25], MASK[24], MASK[23], MASK[22], MASK[21], MASK[20], 
    MASK[19], MASK[18], MASK[17], MASK[16], MASK[15], MASK[14], MASK[13], 
    MASK[12], MASK[11], MASK[10], MASK[9], MASK[8], MASK[7], MASK[6], 
    MASK[5], MASK[4], MASK[3], MASK[2], MASK[1], MASK[0]}), .B({G[31], G[30]
    , G[29], G[28], G[27], G[26], G[25], G[24], G[23], G[22], G[21], G[20], 
    G[19], G[18], G[17], G[16], G[15], G[14], G[13], G[12], G[11], G[10], 
    G[9], G[8], G[7], G[6], G[5], G[4], G[3], G[2], G[1], G[0]}), .O({
    MASKXNORRIGHT[31], MASKXNORRIGHT[30], MASKXNORRIGHT[29], 
    MASKXNORRIGHT[28], MASKXNORRIGHT[27], MASKXNORRIGHT[26], 
    MASKXNORRIGHT[25], MASKXNORRIGHT[24], MASKXNORRIGHT[23], 
    MASKXNORRIGHT[22], MASKXNORRIGHT[21], MASKXNORRIGHT[20], 
    MASKXNORRIGHT[19], MASKXNORRIGHT[18], MASKXNORRIGHT[17], 
    MASKXNORRIGHT[16], MASKXNORRIGHT[15], MASKXNORRIGHT[14], 
    MASKXNORRIGHT[13], MASKXNORRIGHT[12], MASKXNORRIGHT[11], 
    MASKXNORRIGHT[10], MASKXNORRIGHT[9], MASKXNORRIGHT[8], MASKXNORRIGHT[7]
    , MASKXNORRIGHT[6], MASKXNORRIGHT[5], MASKXNORRIGHT[4], MASKXNORRIGHT[3]
    , MASKXNORRIGHT[2], MASKXNORRIGHT[1], MASKXNORRIGHT[0]}));
  BUF X1I226 (.I(RIGHT), .O(G[31]));
  BUF X1I227 (.I(RIGHT), .O(G[16]));
  BUF X1I228 (.I(RIGHT), .O(G[18]));
  BUF X1I229 (.I(RIGHT), .O(G[17]));
  BUF X1I230 (.I(RIGHT), .O(G[21]));
  BUF X1I231 (.I(RIGHT), .O(G[22]));
  BUF X1I232 (.I(RIGHT), .O(G[20]));
  BUF X1I233 (.I(RIGHT), .O(G[19]));
  BUF X1I234 (.I(RIGHT), .O(G[25]));
  BUF X1I235 (.I(RIGHT), .O(G[26]));
  BUF X1I236 (.I(RIGHT), .O(G[24]));
  BUF X1I237 (.I(RIGHT), .O(G[23]));
  BUF X1I238 (.I(RIGHT), .O(G[29]));
  BUF X1I239 (.I(RIGHT), .O(G[30]));
  BUF X1I240 (.I(RIGHT), .O(G[28]));
  BUF X1I241 (.I(RIGHT), .O(G[27]));
  M2_1 X1I260 (.D0(E[16]), .D1(X1N654), .O(O[16]), .S0(MASKXNORRIGHT[16]));
  M2_1 X1I261 (.D0(E[17]), .D1(X1N654), .O(O[17]), .S0(MASKXNORRIGHT[17]));
  M2_1 X1I262 (.D0(E[18]), .D1(X1N654), .O(O[18]), .S0(MASKXNORRIGHT[18]));
  M2_1 X1I263 (.D0(E[19]), .D1(X1N654), .O(O[19]), .S0(MASKXNORRIGHT[19]));
  M2_1 X1I264 (.D0(E[20]), .D1(X1N654), .O(O[20]), .S0(MASKXNORRIGHT[20]));
  M2_1 X1I265 (.D0(E[21]), .D1(X1N654), .O(O[21]), .S0(MASKXNORRIGHT[21]));
  M2_1 X1I266 (.D0(E[23]), .D1(X1N654), .O(O[23]), .S0(MASKXNORRIGHT[23]));
  M2_1 X1I267 (.D0(E[22]), .D1(X1N654), .O(O[22]), .S0(MASKXNORRIGHT[22]));
  M2_1 X1I276 (.D0(E[24]), .D1(X1N654), .O(O[24]), .S0(MASKXNORRIGHT[24]));
  M2_1 X1I277 (.D0(E[25]), .D1(X1N654), .O(O[25]), .S0(MASKXNORRIGHT[25]));
  M2_1 X1I278 (.D0(E[27]), .D1(X1N654), .O(O[27]), .S0(MASKXNORRIGHT[27]));
  M2_1 X1I279 (.D0(E[26]), .D1(X1N654), .O(O[26]), .S0(MASKXNORRIGHT[26]));
  M2_1 X1I280 (.D0(E[30]), .D1(X1N654), .O(O[30]), .S0(MASKXNORRIGHT[30]));
  M2_1 X1I281 (.D0(E[31]), .D1(X1N654), .O(O[31]), .S0(MASKXNORRIGHT[31]));
  M2_1 X1I282 (.D0(E[29]), .D1(X1N654), .O(O[29]), .S0(MASKXNORRIGHT[29]));
  M2_1 X1I283 (.D0(E[28]), .D1(X1N654), .O(O[28]), .S0(MASKXNORRIGHT[28]));
  M2_1 X1I506 (.D0(E[3]), .D1(X1N654), .O(O[3]), .S0(MASKXNORRIGHT[3]));
  M2_1 X1I507 (.D0(E[1]), .D1(X1N654), .O(O[1]), .S0(MASKXNORRIGHT[1]));
  M2_1 X1I508 (.D0(E[0]), .D1(X1N654), .O(O[0]), .S0(MASKXNORRIGHT[0]));
  M2_1 X1I509 (.D0(E[2]), .D1(X1N654), .O(O[2]), .S0(MASKXNORRIGHT[2]));
  M2_1 X1I510 (.D0(E[6]), .D1(X1N654), .O(O[6]), .S0(MASKXNORRIGHT[6]));
  M2_1 X1I511 (.D0(E[7]), .D1(X1N654), .O(O[7]), .S0(MASKXNORRIGHT[7]));
  M2_1 X1I512 (.D0(E[5]), .D1(X1N654), .O(O[5]), .S0(MASKXNORRIGHT[5]));
  M2_1 X1I513 (.D0(E[4]), .D1(X1N654), .O(O[4]), .S0(MASKXNORRIGHT[4]));
  M2_1 X1I514 (.D0(E[12]), .D1(X1N654), .O(O[12]), .S0(MASKXNORRIGHT[15]));
  M2_1 X1I515 (.D0(E[13]), .D1(X1N654), .O(O[13]), .S0(MASKXNORRIGHT[14]));
  M2_1 X1I516 (.D0(E[15]), .D1(X1N654), .O(O[15]), .S0(MASKXNORRIGHT[12]));
  M2_1 X1I517 (.D0(E[14]), .D1(X1N654), .O(O[14]), .S0(MASKXNORRIGHT[13]));
  M2_1 X1I518 (.D0(E[10]), .D1(X1N654), .O(O[10]), .S0(MASKXNORRIGHT[10]));
  M2_1 X1I519 (.D0(E[11]), .D1(X1N654), .O(O[11]), .S0(MASKXNORRIGHT[11]));
  M2_1 X1I520 (.D0(E[9]), .D1(X1N654), .O(O[9]), .S0(MASKXNORRIGHT[9]));
  M2_1 X1I521 (.D0(E[8]), .D1(X1N654), .O(O[8]), .S0(MASKXNORRIGHT[8]));
  D4_16E X1I53 (.A0(X1N949), .A1(X1N964), .A2(X1N965), .A3(X1N966), .D0
    (MASK[0]), .D1(X1N70), .D10(X1N100), .D11(X1N106), .D12(X1N113), .D13
    (X1N115), .D14(X1N114), .D15(X1N118), .D2(X1N73), .D3(X1N76), .D4(X1N86)
    , .D5(X1N88), .D6(X1N91), .D7(X1N89), .D8(X1N93), .D9(X1N97), .E(X1N68)
    );
  D4_16E X1I60 (.A0(X1N949), .A1(X1N964), .A2(X1N965), .A3(X1N966), .D0
    (X1N167), .D1(X1N132), .D10(X1N151), .D11(X1N160), .D12(X1N122), .D13
    (X1N153), .D14(X1N154), .D15(X1N163), .D2(X1N134), .D3(X1N137), .D4
    (X1N130), .D5(X1N145), .D6(X1N147), .D7(X1N146), .D8(X1N127), .D9
    (X1N148), .E(X1N4));
  INV X1I67 (.I(X1N4), .O(X1N68));
  OR2 X1I69 (.I0(X1N70), .I1(MASK[0]), .O(MASK[1]));
  OR2 X1I72 (.I0(X1N73), .I1(MASK[1]), .O(MASK[2]));
  OR2 X1I75 (.I0(X1N76), .I1(MASK[2]), .O(MASK[3]));
  OR2 X1I78 (.I0(X1N86), .I1(MASK[3]), .O(MASK[4]));
  MUX2_1X32 X1I8 (.A({A[31], A[30], A[29], A[28], A[27], A[26], A[25], A[24]
    , A[23], A[22], A[21], A[20], A[19], A[18], A[17], A[16], A[15], A[14], 
    A[13], A[12], A[11], A[10], A[9], A[8], A[7], A[6], A[5], A[4], A[3], 
    A[2], A[1], A[0]}), .B({A[29], A[28], A[27], A[26], A[25], A[24], A[23]
    , A[22], A[21], A[20], A[19], A[18], A[17], A[16], A[15], A[14], A[13], 
    A[12], A[11], A[10], A[9], A[8], A[7], A[6], A[5], A[4], A[3], A[2], 
    A[1], A[0], A[31], A[30]}), .SB(X1N964), .S({B[31], B[30], B[29], B[28]
    , B[27], B[26], B[25], B[24], B[23], B[22], B[21], B[20], B[19], B[18], 
    B[17], B[16], B[15], B[14], B[13], B[12], B[11], B[10], B[9], B[8], B[7]
    , B[6], B[5], B[4], B[3], B[2], B[1], B[0]}));
  OR2 X1I80 (.I0(X1N88), .I1(MASK[4]), .O(MASK[5]));
  OR2 X1I82 (.I0(X1N91), .I1(MASK[5]), .O(MASK[6]));
  AND2 X1I822 (.I0(ARITH), .I1(I[31]), .O(X1N654));
  OR2 X1I84 (.I0(X1N89), .I1(MASK[6]), .O(MASK[7]));
  XOR2 X1I881 (.I0(RIGHT), .I1(SHIFT[0]), .O(X1N894));
  XOR2 X1I884 (.I0(RIGHT), .I1(SHIFT[1]), .O(X1N907));
  XOR2 X1I885 (.I0(RIGHT), .I1(SHIFT[3]), .O(X1N926));
  XOR2 X1I888 (.I0(RIGHT), .I1(SHIFT[2]), .O(X1N922));
  XOR2 X1I890 (.I0(RIGHT), .I1(SHIFT[4]), .O(X1N932));
  XOR2 X1I891 (.I0(RIGHT), .I1(X1N894), .O(X1N949));
  AND2 X1I897 (.I0(RIGHT), .I1(X1N894), .O(X1N903));
  XOR2 X1I901 (.I0(X1N903), .I1(X1N907), .O(X1N964));
  AND2 X1I905 (.I0(X1N903), .I1(X1N907), .O(X1N919));
  OR2 X1I92 (.I0(X1N93), .I1(MASK[7]), .O(MASK[8]));
  XOR2 X1I920 (.I0(X1N919), .I1(X1N922), .O(X1N965));
  AND2 X1I921 (.I0(X1N919), .I1(X1N922), .O(X1N923));
  XOR2 X1I924 (.I0(X1N923), .I1(X1N926), .O(X1N966));
  AND2 X1I925 (.I0(X1N923), .I1(X1N926), .O(X1N927));
  XOR2 X1I928 (.I0(X1N927), .I1(X1N932), .O(X1N4));
  OR2 X1I96 (.I0(X1N97), .I1(MASK[8]), .O(MASK[9]));
  OR2 X1I99 (.I0(X1N100), .I1(MASK[9]), .O(MASK[10]));

endmodule  // SHIFTER

module X1;
  parameter
    viewdraw_design_name = "1",
    verilnet_use_refdes = 0,
    verilnet_use_escaped_ids = 0,
    verilnet_retain_busses = 1,
    verilnet_illegal_name_prefix = "x",
    verilnet_case_flag_comp = -1,
    verilnet_case_flag_pin = -1,
    verilnet_case_flag_io_net = -1,
    verilnet_case_flag_wire = -1,
    verilnet_case_flag_param = -1,
    verilnet_case_flag_symbol = -1,
    verilnet_case_flag_module = -1,
    verilnet_case_flag_any = 1,
    verilnet_replace_string_0 = "~n",
    verilnet_replace_string_1 = "$x";
  wire [31:0] GND, MEMORY_BEFRE_WRITE, RAM_READ, ADDRESS, MEM_PC, 
    MMU_ENTRY_LO, EPC, CP0_ENTRY_HI_NEXT, LAST_PC_NULLED, PC_BR_IMM, ROM_DAT
    , CACHE_INST_DAT, MMU_ENTRY_HI, CP0_ENTRY_HI, CP0_ENTRY_LO_NEXT, 
    RESETVECTOR, CP0_ENTRY_LO, NOTSYSCALLPC, MEM_RES, REGA_XNOR_REGB, REG_PC
    , IMM, ALU_PC, NEXT_STORED_PC, PC_PLUS_FOUR, SHIFT_RES, CP0_HI_REGS, 
    RAM2_READ, REG_A_EXE, EXE_RES, REG_A, REG_B_MEM, REG_B_MEM_SHIFTED, 
    REG_B_MEM_SHIFTED_MASKED, REG_B, B_EXE_INPUT, REG_B_EXE_FF, MEM_FF, 
    NEXT_PC, BRANCH, LOAD_ROTATED_MASKED, MEM_ACCESS_ADDRESS, 
    CACHE_INSTRUCTION_PRE_DAT, PC_TO_PIPELINE, REG_B_EXE, REG_A_EXE_FF, 
    CACHE_OUT, MEM_DAT, CACHE_DAT, EXE_FF, CPO_BADVADDR, COUNTER, PC, 
    LOAD_ROTATED, ALU_RES, INSTRUCTION;
  wire [19:0] DATA_PFN, INST_PFN, MMU_PFN, MMU_VPN;
  wire [15:0] EXE_IMM, DISPLAY;
  wire [15:2] CPO_CAUSE;
  wire [31:21] CPO_CONTEXT;
  wire [15:8] STATUS ;
  wire [7:0] SERIAL_DATA;
  wire [6:0] DISP_RIGHT, DISP_LEFT;
  wire [5:0] MMU_INDEX_OUT, CP0_INDEX_NEXT, MMU_INDEX ;
  wire [13:8] RANDOM, INDEX ;
  wire [5:0] INT_DEC, INT_EXE, INT_EXE_OUT, INT_MEM_IN;
  wire [4:0] CP0_INSTRUCTION, CPO_ALU_DEST, CPO_REG_SELECT, CPO_REG_DEST, 
    FETCH_SHIFT, SHIFT, REG_DEST_RT_RD, SIXTEEN, CPO_INSTRUCTION_EX, 
    RANDON_STATS, EXC_CODE, REG_DEST_MEM, REG_DEST_EXE, REG_DEST_WB, 
    REG_DEST_FETCH, IMM_SHIFT;
  wire [3:0] OP;
  wire MMU_NOT_VALID_DATA, MEM_FULL_WRITE, SHIFT_SET, REGA_EQ_REGB, 
    MEM_WRITE, INT_UNALIGNED_ACCESS, CPO_READ_EPC, SPECIAL, SET_R31, 
    CPO_WRITE, INTERRUPT, CPO_OUTPUT, BR_GEZ_LTZ, X1N600, MMU_TLB_LOOK_UP, 
    JUMPLONG, SEL_PORT_A_MEM, X1N740, X1N623, TAKEBRANCH, SEL_PORT_B_MEM, 
    MEM_WRITE_SOON, CLK, SW1, X1N616, SEL_PORT_A_ALU, VCC, SW2, 
    DATA_MEM_ACCESS, SEL_PORT_B_ALU, X1N637, OVERFLOW, INT_DEC_TLBL, 
    MMU_DIRTY, X1N739, X1N595, INTERRUPT_MEM, SPECIAL_EXE, SET_R31_EXE, 
    INT_INST_ERROR, BRANCH, STATUS0, RESET_IN, STATUS1, LDST_SHIFT0, 
    CP0_READ_CAUSE, STATUS2, LDST_SHIFT1, CPO_READ_ENTRY_HI, STATUS3, 
    MMU_TLB_READ, LDST_SHIFT2, STATUS4, MMU_HIT_DATA, DISPLAY16, 
    DATA_CACHE_HIT, STATUS5, LUI, ENABLE_RAM, CP0_RETURN_FROM_EXCEPTION, 
    CPO_READ_CONTEXT, CACHE, CPO_READ_RANDOM, CP0_WRITE_CAUSE, 
    CPO_WRITE_ENTRY_HI, CPO_READ_ENTRY_LO, MMU_TLB_WRITE, 
    MMU_DONT_CACHE_DATA, MEM_BRANCH, HALT0, ENABLE_DISPLAY, CP0_READ_STATUS
    , SERIAL_ACK, HALT1, EXT_INTERRUPT, HALT2, HALT3, CPO_WRITE_CONTEXT, 
    CLK_50MHZ, MMU_HIT_INSTR, ENABLE_ROM, CPO_WRITE_ENTRY_LO, COUNTER_ZERO, 
    GLB_EN, ENABLE_COUNTER, CP0_WRITE_STATUS, INST_MEM_ACCESS, 
    INT_FETCH_ADEL, CLK1_NBUF, CPO_READ_BADVADDR, CLK2_NBUF, X1N2020, 
    X1N1120, SET_R0, ENABLE_SERIAL, MMU_HIT, MEM_CP_NO0, EXTERNAL_INTERRUPT1
    , X1N1050, MEM_CP_NO1, CPO_WRITTE_INDEX, X1N6001, X1N4112, X1N6030, 
    X1N6012, X1N3213, X1N1224, X1N1044, SELECT_CPO, X1N5230, X1N5212, 
    X1N4042, X1N3160, X1N1306, X1N1117, X1N1054, X1N5600, X1N5303, X1N5060, 
    X1N4142, X1N3422, X1N3161, X1N3071, X1N2612, X1N1307, X1N1046, 
    INT_COPROCESSOR_UNUSABLE, X1N6510, X1N5520, X1N4431, X1N4422, X1N3126, 
    X1N3090, X1N2280, X1N1821, X1N1092, X1N1083, CLK1, X1N6421, X1N6160, 
    X1N6151, X1N6025, X1N5620, X1N5521, X1N4810, X1N4234, X1N4072, X1N3730, 
    X1N3028, X1N1309, X1N1066, CPO_READ_INDEX, CLK2, X1N6323, X1N6161, 
    X1N6062, X1N5423, X1N5414, X1N5234, X1N4910, X1N4820, X1N4811, X1N3641, 
    X1N3272, X1N3245, X1N3164, X1N2282, X1N1058, INST_CACHE_HIT, X1N6171, 
    X1N6144, X1N5811, X1N5550, X1N5460, X1N5253, X1N5235, X1N5208, X1N4830, 
    X1N4821, X1N4812, X1N3741, X1N3255, X1N3246, X1N3075, X1N3057, X1N2760, 
    X1N2274, X1N1068, X1N1059, MMU_DONT_CACHE, X1N6631, X1N6613, X1N6460, 
    X1N6433, X1N6127, X1N6037, X1N5524, X1N5425, X1N5407, X1N5254, X1N4903, 
    X1N4831, X1N4822, X1N4813, X1N3715, X1N1870, X1N1069, MEMORY, X1N6830, 
    X1N6461, X1N6434, X1N6218, X1N6173, X1N5732, X1N5723, X1N5651, X1N5624, 
    X1N5561, X1N5552, X1N5516, X1N5507, X1N5381, X1N5327, X1N5273, X1N5147, 
    X1N4832, X1N4148, X1N4067, X1N3266, X1N3194, X1N2276, X1N1187, X1N1079, 
    X1N6831, X1N6705, X1N6462, X1N6156, X1N5706, X1N5670, X1N5625, X1N5616, 
    X1N5418, X1N5382, X1N5229, X1N5076, X1N4833, X1N4770, X1N4176, X1N3834, 
    X1N3744, X1N3267, X1N1296, X1N1089, X1N6832, X1N6634, X1N6409, X1N6337, 
    X1N6175, X1N6067, X1N5932, X1N5734, X1N5671, X1N5383, X1N5248, X1N4771, 
    X1N4672, X1N4177, X1N3817, X1N3655, X1N3367, X1N3295, X1N1297, INDEX31, 
    X1N6833, X1N6590, X1N6527, X1N6365, X1N6158, X1N5951, X1N5726, X1N5618, 
    X1N5519, X1N5249, X1N4853, X1N4808, X1N4772, X1N3683, X1N3557, X1N6933, 
    X1N6663, X1N6609, X1N6519, X1N6456, X1N6177, X1N5754, X1N5736, X1N5628, 
    X1N5619, X1N5547, X1N5268, X1N4935, X1N4908, X1N4863, X1N4818, X1N4809, 
    X1N3837, X1N3738, X1N2874, X1N1596, INST_ADDR_ERROR, X1N6826, X1N6709, 
    X1N6457, X1N6439, X1N6169, X1N5764, X1N5746, X1N5728, X1N5287, X1N4990, 
    X1N4909, X1N4891, X1N4864, X1N4819, X1N3766, X1N3757, X1N6944, X1N6836, 
    X1N6656, X1N6395, X1N5684, X1N5666, X1N5567, X1N5459, X1N4865, X1N4856, 
    X1N4829, X1N3299, MMU_DONT_CACHE_INTR, X1N6846, X1N6837, X1N6396, 
    X1N5748, X1N5559, X1N4992, X1N4884, X1N4866, X1N4767, V_ADDRESS_ERROR, 
    X1N6667, X1N5947, X1N5686, X1N5668, X1N5596, X1N4867, X1N4777, X1N4768, 
    STATUS30, INSTRUCTION_LOADING_IN_MEM_STAGE, X1N6938, X1N6659, X1N5975, 
    X1N5696, X1N4895, X1N4868, X1N4769, X1N1799, STATUS31, STATUS22, 
    MMU_TLB_WRITE_RANDOM, INT_FETCH_TLBL, X1N5688, X1N5598, X1N4986, X1N3798
    , MOV_CP, X1N6697, X1N5788, X1N4988, FLUSH, CPO_CAUSE31, X1N6889, RESET
    , TLB_REFIL, STATUS28, MEM_CP_ACCESS, END_READ_B4_WRITE, ENABLE_RAM2, 
    STATUS29, LOAD, I_TYPE, SERIAL_REQUEST, 
    ILL_DAMN_WELL_CONNECT_IT_TO_THE_CLOCK, END_READ, CPO_CAUSE28, 
    CPO_CAUSE29, OUTPUT, CPO_READ_PRID, MMU_DIRTY_DATA, JMP2REG, 
    INT_DEC_ADEL, END_WRITE, BR_INSTRUCTION;
  supply0 GND;
  FDE X1I1017 (.C(CLK1), .CE(GLB_EN), .D(X1N1054), .Q(OP[2]));
  FDE X1I1018 (.C(CLK1), .CE(GLB_EN), .D(X1N1044), .Q(OP[3]));
  FDE X1I1019 (.C(CLK1), .CE(GLB_EN), .D(X1N1066), .Q(OP[1]));
  FDSE X1I1020 (.C(CLK1), .CE(GLB_EN), .D(X1N1079), .Q(OP[0]), .S(FLUSH));
  REG5 X1I1037 (.CLK(CLK1), .EN(GLB_EN), .I({FETCH_SHIFT[4], FETCH_SHIFT[3]
    , FETCH_SHIFT[2], FETCH_SHIFT[1], FETCH_SHIFT[0]}), .O({IMM_SHIFT[4], 
    IMM_SHIFT[3], IMM_SHIFT[2], IMM_SHIFT[1], IMM_SHIFT[0]}), .RES(FLUSH));
  AND3B2 X1I1038 (.I0(INSTRUCTION[30]), .I1(INSTRUCTION[31]), .I2
    (INSTRUCTION[29]), .O(I_TYPE));
  OR2 X1I1043 (.I0(X1N1050), .I1(X1N1046), .O(X1N1044));
  AND2 X1I1045 (.I0(INSTRUCTION[3]), .I1(SPECIAL), .O(X1N1046));
  AND3B1 X1I1049 (.I0(INSTRUCTION[28]), .I1(INSTRUCTION[27]), .I2(I_TYPE), 
    .O(X1N1050));
  AND2 X1I1055 (.I0(INSTRUCTION[2]), .I1(SPECIAL), .O(X1N1058));
  OR2 X1I1057 (.I0(X1N1059), .I1(X1N1058), .O(X1N1054));
  AND2 X1I1063 (.I0(INSTRUCTION[28]), .I1(I_TYPE), .O(X1N1059));
  AND2 X1I1067 (.I0(INSTRUCTION[1]), .I1(SPECIAL), .O(X1N1069));
  OR2 X1I1070 (.I0(X1N1068), .I1(X1N1069), .O(X1N1066));
  OR3 X1I1078 (.I0(X1N1092), .I1(X1N1089), .I2(X1N1083), .O(X1N1079));
  AND2 X1I1080 (.I0(INSTRUCTION[0]), .I1(SPECIAL), .O(X1N1083));
  NOR2 X1I1091 (.I0(SPECIAL), .I1(I_TYPE), .O(X1N1092));
  FDE X1I1106 (.C(CLK1), .CE(GLB_EN), .D(X1N1117), .Q(SHIFT_SET));
  OR2 X1I1118 (.I0(LUI), .I1(X1N1120), .O(X1N1117));
  AND2B1 X1I1119 (.I0(INSTRUCTION[5]), .I1(SPECIAL), .O(X1N1120));
  AND4 X1I1124 (.I0(INSTRUCTION[26]), .I1(INSTRUCTION[27]), .I2
    (INSTRUCTION[28]), .I3(I_TYPE), .O(LUI));
  M2_1X5 X1I1131 (.A({INSTRUCTION[10], INSTRUCTION[9], INSTRUCTION[8], 
    INSTRUCTION[7], INSTRUCTION[6]}), .B({SIXTEEN[4], SIXTEEN[3], SIXTEEN[2]
    , SIXTEEN[1], SIXTEEN[0]}), .O({FETCH_SHIFT[4], FETCH_SHIFT[3], 
    FETCH_SHIFT[2], FETCH_SHIFT[1], FETCH_SHIFT[0]}), .SB(LUI));
  GND X1I1148 (.G(SIXTEEN[3]));
  GND X1I1150 (.G(SIXTEEN[2]));
  GND X1I1152 (.G(SIXTEEN[1]));
  GND X1I1154 (.G(SIXTEEN[0]));
  VCC X1I1157 (.P(SIXTEEN[4]));
  AND3B1 X1I1163 (.I0(LUI), .I1(INSTRUCTION[27]), .I2(I_TYPE), .O(X1N1068));
  AND3B1 X1I1164 (.I0(LUI), .I1(INSTRUCTION[26]), .I2(I_TYPE), .O(X1N1089));
  XOR32_32_32 X1I1168 (.A({REG_B_EXE_FF[31], REG_B_EXE_FF[30], 
    REG_B_EXE_FF[29], REG_B_EXE_FF[28], REG_B_EXE_FF[27], REG_B_EXE_FF[26], 
    REG_B_EXE_FF[25], REG_B_EXE_FF[24], REG_B_EXE_FF[23], REG_B_EXE_FF[22], 
    REG_B_EXE_FF[21], REG_B_EXE_FF[20], REG_B_EXE_FF[19], REG_B_EXE_FF[18], 
    REG_B_EXE_FF[17], REG_B_EXE_FF[16], REG_B_EXE_FF[15], REG_B_EXE_FF[14], 
    REG_B_EXE_FF[13], REG_B_EXE_FF[12], REG_B_EXE_FF[11], REG_B_EXE_FF[10], 
    REG_B_EXE_FF[9], REG_B_EXE_FF[8], REG_B_EXE_FF[7], REG_B_EXE_FF[6], 
    REG_B_EXE_FF[5], REG_B_EXE_FF[4], REG_B_EXE_FF[3], REG_B_EXE_FF[2], 
    REG_B_EXE_FF[1], REG_B_EXE_FF[0]}), .B({REG_A_EXE_FF[31], 
    REG_A_EXE_FF[30], REG_A_EXE_FF[29], REG_A_EXE_FF[28], REG_A_EXE_FF[27], 
    REG_A_EXE_FF[26], REG_A_EXE_FF[25], REG_A_EXE_FF[24], REG_A_EXE_FF[23], 
    REG_A_EXE_FF[22], REG_A_EXE_FF[21], REG_A_EXE_FF[20], REG_A_EXE_FF[19], 
    REG_A_EXE_FF[18], REG_A_EXE_FF[17], REG_A_EXE_FF[16], REG_A_EXE_FF[15], 
    REG_A_EXE_FF[14], REG_A_EXE_FF[13], REG_A_EXE_FF[12], REG_A_EXE_FF[11], 
    REG_A_EXE_FF[10], REG_A_EXE_FF[9], REG_A_EXE_FF[8], REG_A_EXE_FF[7], 
    REG_A_EXE_FF[6], REG_A_EXE_FF[5], REG_A_EXE_FF[4], REG_A_EXE_FF[3], 
    REG_A_EXE_FF[2], REG_A_EXE_FF[1], REG_A_EXE_FF[0]}), .O({
    REGA_XNOR_REGB[31], REGA_XNOR_REGB[30], REGA_XNOR_REGB[29], 
    REGA_XNOR_REGB[28], REGA_XNOR_REGB[27], REGA_XNOR_REGB[26], 
    REGA_XNOR_REGB[25], REGA_XNOR_REGB[24], REGA_XNOR_REGB[23], 
    REGA_XNOR_REGB[22], REGA_XNOR_REGB[21], REGA_XNOR_REGB[20], 
    REGA_XNOR_REGB[19], REGA_XNOR_REGB[18], REGA_XNOR_REGB[17], 
    REGA_XNOR_REGB[16], REGA_XNOR_REGB[15], REGA_XNOR_REGB[14], 
    REGA_XNOR_REGB[13], REGA_XNOR_REGB[12], REGA_XNOR_REGB[11], 
    REGA_XNOR_REGB[10], REGA_XNOR_REGB[9], REGA_XNOR_REGB[8], 
    REGA_XNOR_REGB[7], REGA_XNOR_REGB[6], REGA_XNOR_REGB[5], 
    REGA_XNOR_REGB[4], REGA_XNOR_REGB[3], REGA_XNOR_REGB[2], 
    REGA_XNOR_REGB[1], REGA_XNOR_REGB[0]}));
  AND32 X1I1172 (.I({REGA_XNOR_REGB[31], REGA_XNOR_REGB[30], 
    REGA_XNOR_REGB[29], REGA_XNOR_REGB[28], REGA_XNOR_REGB[27], 
    REGA_XNOR_REGB[26], REGA_XNOR_REGB[25], REGA_XNOR_REGB[24], 
    REGA_XNOR_REGB[23], REGA_XNOR_REGB[22], REGA_XNOR_REGB[21], 
    REGA_XNOR_REGB[20], REGA_XNOR_REGB[19], REGA_XNOR_REGB[18], 
    REGA_XNOR_REGB[17], REGA_XNOR_REGB[16], REGA_XNOR_REGB[15], 
    REGA_XNOR_REGB[14], REGA_XNOR_REGB[13], REGA_XNOR_REGB[12], 
    REGA_XNOR_REGB[11], REGA_XNOR_REGB[10], REGA_XNOR_REGB[9], 
    REGA_XNOR_REGB[8], REGA_XNOR_REGB[7], REGA_XNOR_REGB[6], 
    REGA_XNOR_REGB[5], REGA_XNOR_REGB[4], REGA_XNOR_REGB[3], 
    REGA_XNOR_REGB[2], REGA_XNOR_REGB[1], REGA_XNOR_REGB[0]}), .O
    (REGA_EQ_REGB));
  NOR4 X1I1177 (.I0(X1N3075), .I1(X1N3071), .I2(SPECIAL), .I3(I_TYPE), .O
    (SET_R0));
  M2_1X5 X1I1188 (.A({IMM_SHIFT[4], IMM_SHIFT[3], IMM_SHIFT[2], IMM_SHIFT[1]
    , IMM_SHIFT[0]}), .B({REG_A_EXE_FF[4], REG_A_EXE_FF[3], REG_A_EXE_FF[2]
    , REG_A_EXE_FF[1], REG_A_EXE_FF[0]}), .O({SHIFT[4], SHIFT[3], SHIFT[2], 
    SHIFT[1], SHIFT[0]}), .SB(X1N1187));
  AND4B3 X1I1199 (.I0(INSTRUCTION[29]), .I1(INSTRUCTION[30]), .I2
    (INSTRUCTION[31]), .I3(X1N1224), .O(BR_INSTRUCTION));
  OR3 X1I1223 (.I0(INSTRUCTION[27]), .I1(INSTRUCTION[28]), .I2
    (INSTRUCTION[26]), .O(X1N1224));
  XOR2 X1I1260 (.I0(X1N1307), .I1(X1N1306), .O(X1N1309));
  AND2 X1I1269 (.I0(INSTRUCTION[28]), .I1(REGA_EQ_REGB), .O(X1N1296));
  AND2 X1I1270 (.I0(X1N6127), .I1(REG_A_EXE_FF[31]), .O(X1N1297));
  OR2 X1I1295 (.I0(X1N1297), .I1(X1N1296), .O(X1N1306));
  M2_1 X1I1299 (.D0(INSTRUCTION[26]), .D1(INSTRUCTION[16]), .O(X1N1307), .S0
    (BR_GEZ_LTZ));
  MUX2_1X32 X1I1314 (.A({EXE_FF[31], EXE_FF[30], EXE_FF[29], EXE_FF[28], 
    EXE_FF[27], EXE_FF[26], EXE_FF[25], EXE_FF[24], EXE_FF[23], EXE_FF[22], 
    EXE_FF[21], EXE_FF[20], EXE_FF[19], EXE_FF[18], EXE_FF[17], EXE_FF[16], 
    EXE_FF[15], EXE_FF[14], EXE_FF[13], EXE_FF[12], EXE_FF[11], EXE_FF[10], 
    EXE_FF[9], EXE_FF[8], EXE_FF[7], EXE_FF[6], EXE_FF[5], EXE_FF[4], 
    EXE_FF[3], EXE_FF[2], EXE_FF[1], EXE_FF[0]}), .B({
    LOAD_ROTATED_MASKED[31], LOAD_ROTATED_MASKED[30], 
    LOAD_ROTATED_MASKED[29], LOAD_ROTATED_MASKED[28], 
    LOAD_ROTATED_MASKED[27], LOAD_ROTATED_MASKED[26], 
    LOAD_ROTATED_MASKED[25], LOAD_ROTATED_MASKED[24], 
    LOAD_ROTATED_MASKED[23], LOAD_ROTATED_MASKED[22], 
    LOAD_ROTATED_MASKED[21], LOAD_ROTATED_MASKED[20], 
    LOAD_ROTATED_MASKED[19], LOAD_ROTATED_MASKED[18], 
    LOAD_ROTATED_MASKED[17], LOAD_ROTATED_MASKED[16], 
    LOAD_ROTATED_MASKED[15], LOAD_ROTATED_MASKED[14], 
    LOAD_ROTATED_MASKED[13], LOAD_ROTATED_MASKED[12], 
    LOAD_ROTATED_MASKED[11], LOAD_ROTATED_MASKED[10], LOAD_ROTATED_MASKED[9]
    , LOAD_ROTATED_MASKED[8], LOAD_ROTATED_MASKED[7], LOAD_ROTATED_MASKED[6]
    , LOAD_ROTATED_MASKED[5], LOAD_ROTATED_MASKED[4], LOAD_ROTATED_MASKED[3]
    , LOAD_ROTATED_MASKED[2], LOAD_ROTATED_MASKED[1], LOAD_ROTATED_MASKED[0]
    }), .SB(LOAD), .S({MEM_RES[31], MEM_RES[30], MEM_RES[29], MEM_RES[28], 
    MEM_RES[27], MEM_RES[26], MEM_RES[25], MEM_RES[24], MEM_RES[23], 
    MEM_RES[22], MEM_RES[21], MEM_RES[20], MEM_RES[19], MEM_RES[18], 
    MEM_RES[17], MEM_RES[16], MEM_RES[15], MEM_RES[14], MEM_RES[13], 
    MEM_RES[12], MEM_RES[11], MEM_RES[10], MEM_RES[9], MEM_RES[8], 
    MEM_RES[7], MEM_RES[6], MEM_RES[5], MEM_RES[4], MEM_RES[3], MEM_RES[2], 
    MEM_RES[1], MEM_RES[0]}));
  CLOCK X1I1496 (.CLK1(X1N6462), .CLK_50MHZ(CLK_50MHZ));
  STARTUPRAM STARTUP_ROM (.A0(ADDRESS[2]), .A1(ADDRESS[3]), .A2(ADDRESS[4])
    , .A3(ADDRESS[5]), .A4(ADDRESS[6]), .D({MEM_DAT[31], MEM_DAT[30], 
    MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], 
    MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], 
    MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], 
    MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], 
    MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], 
    MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .O({ROM_DAT[31], 
    ROM_DAT[30], ROM_DAT[29], ROM_DAT[28], ROM_DAT[27], ROM_DAT[26], 
    ROM_DAT[25], ROM_DAT[24], ROM_DAT[23], ROM_DAT[22], ROM_DAT[21], 
    ROM_DAT[20], ROM_DAT[19], ROM_DAT[18], ROM_DAT[17], ROM_DAT[16], 
    ROM_DAT[15], ROM_DAT[14], ROM_DAT[13], ROM_DAT[12], ROM_DAT[11], 
    ROM_DAT[10], ROM_DAT[9], ROM_DAT[8], ROM_DAT[7], ROM_DAT[6], ROM_DAT[5]
    , ROM_DAT[4], ROM_DAT[3], ROM_DAT[2], ROM_DAT[1], ROM_DAT[0]}), .WCLK
    (CLK1), .WE(X1N6933));
  FPGA_FLASHDISP I_O_BLOCK (.A({PC[20], PC[19], PC[18], PC[17], PC[16], 
    PC[15], PC[14], PC[13], PC[12], PC[11], PC[10], PC[9], PC[8], PC[7], 
    PC[6], PC[5], PC[4], PC[3], PC[2], PC[1], PC[0]}), .BAR0(PC[0]), .BAR1
    (PC[1]), .BAR2(PC[2]), .BAR3(PC[3]), .BAR4(PC[4]), .BAR5(PC[5]), .BAR6
    (PC[6]), .BAR7(PC[7]), .BAR8(PC[8]), .DISPNFLASH(X1N1596), .DOE(X1N1596)
    , .LEDLA,LEDLB,LEDLC,LEDLD,LEDLE,LEDLF,LEDLG({DISP_LEFT[6], DISP_LEFT[5]
    , DISP_LEFT[4], DISP_LEFT[3], DISP_LEFT[2], DISP_LEFT[1], DISP_LEFT[0]})
    , .LEDRA,LEDRB,LEDRC,LEDRD,LEDRE,LEDRF,LEDRG({DISP_RIGHT[6], 
    DISP_RIGHT[5], DISP_RIGHT[4], DISP_RIGHT[3], DISP_RIGHT[2], 
    DISP_RIGHT[1], DISP_RIGHT[0]}), .NFLASHCE(X1N1596), .NFLASHOE(X1N1596), 
    .NFLASHWE(X1N1596), .NFPGAOE(X1N2612));
  VCC X1I1595 (.P(X1N1596));
  REG32R X1I1721 (.CLK(CLK2), .EN(GLB_EN), .I({CACHE_INST_DAT[31], 
    CACHE_INST_DAT[30], CACHE_INST_DAT[29], CACHE_INST_DAT[28], 
    CACHE_INST_DAT[27], CACHE_INST_DAT[26], CACHE_INST_DAT[25], 
    CACHE_INST_DAT[24], CACHE_INST_DAT[23], CACHE_INST_DAT[22], 
    CACHE_INST_DAT[21], CACHE_INST_DAT[20], CACHE_INST_DAT[19], 
    CACHE_INST_DAT[18], CACHE_INST_DAT[17], CACHE_INST_DAT[16], 
    CACHE_INST_DAT[15], CACHE_INST_DAT[14], CACHE_INST_DAT[13], 
    CACHE_INST_DAT[12], CACHE_INST_DAT[11], CACHE_INST_DAT[10], 
    CACHE_INST_DAT[9], CACHE_INST_DAT[8], CACHE_INST_DAT[7], 
    CACHE_INST_DAT[6], CACHE_INST_DAT[5], CACHE_INST_DAT[4], 
    CACHE_INST_DAT[3], CACHE_INST_DAT[2], CACHE_INST_DAT[1], 
    CACHE_INST_DAT[0]}), .O({INSTRUCTION[31], INSTRUCTION[30], 
    INSTRUCTION[29], INSTRUCTION[28], INSTRUCTION[27], INSTRUCTION[26], 
    INSTRUCTION[25], INSTRUCTION[24], INSTRUCTION[23], INSTRUCTION[22], 
    INSTRUCTION[21], INSTRUCTION[20], INSTRUCTION[19], INSTRUCTION[18], 
    INSTRUCTION[17], INSTRUCTION[16], INSTRUCTION[15], INSTRUCTION[14], 
    INSTRUCTION[13], INSTRUCTION[12], INSTRUCTION[11], INSTRUCTION[10], 
    INSTRUCTION[9], INSTRUCTION[8], INSTRUCTION[7], INSTRUCTION[6], 
    INSTRUCTION[5], INSTRUCTION[4], INSTRUCTION[3], INSTRUCTION[2], 
    INSTRUCTION[1], INSTRUCTION[0]}), .RESET(FLUSH));
  BUFE32 X1I1784 (.E(X1N3367), .I({ROM_DAT[31], ROM_DAT[30], ROM_DAT[29], 
    ROM_DAT[28], ROM_DAT[27], ROM_DAT[26], ROM_DAT[25], ROM_DAT[24], 
    ROM_DAT[23], ROM_DAT[22], ROM_DAT[21], ROM_DAT[20], ROM_DAT[19], 
    ROM_DAT[18], ROM_DAT[17], ROM_DAT[16], ROM_DAT[15], ROM_DAT[14], 
    ROM_DAT[13], ROM_DAT[12], ROM_DAT[11], ROM_DAT[10], ROM_DAT[9], 
    ROM_DAT[8], ROM_DAT[7], ROM_DAT[6], ROM_DAT[5], ROM_DAT[4], ROM_DAT[3], 
    ROM_DAT[2], ROM_DAT[1], ROM_DAT[0]}), .O({MEM_DAT[31], MEM_DAT[30], 
    MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], 
    MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], 
    MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], 
    MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], 
    MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], 
    MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  FDRE X1I1791 (.C(CLK1), .CE(GLB_EN), .D(X1N1799), .Q(X1N1821), .R(FLUSH));
  FDRE X1I1794 (.C(CLK1), .CE(GLB_EN), .D(X1N3126), .Q
    (INSTRUCTION_LOADING_IN_MEM_STAGE), .R(FLUSH));
  AND2 X1I1798 (.I0(INSTRUCTION[31]), .I1(INSTRUCTION[29]), .O(X1N1799));
  FDRE X1I1814 (.C(CLK1), .CE(GLB_EN), .D(INSTRUCTION_LOADING_IN_MEM_STAGE)
    , .Q(LOAD), .R(FLUSH));
  FDRE X1I1817 (.C(CLK1), .CE(GLB_EN), .D(X1N1821), .Q(MEM_WRITE_SOON), .R
    (FLUSH));
  AND3 X1I1867 (.I0(ADDRESS[26]), .I1(ADDRESS[27]), .I2(ADDRESS[28]), .O
    (X1N1870));
  D4_16E IGNORE_NO_LOAD1 (.A0(ADDRESS[8]), .A1(ADDRESS[9]), .A2(ADDRESS[10])
    , .A3(ADDRESS[11]), .D0(X1N6395), .D1(X1N6396), .D13(ENABLE_COUNTER), 
    .D14(ENABLE_SERIAL), .D15(ENABLE_DISPLAY), .E(X1N5951));
  INV X1I2015 (.I(CLK), .O(X1N2020));
  BUFG X1I2017 (.I(CLK), .O(CLK1));
  BUFG X1I2018 (.I(X1N2020), .O(CLK2));
  AND2 X1I2248 (.I0(BR_INSTRUCTION), .I1(X1N1309), .O(X1N6144));
  AND2 X1I2255 (.I0(OP[2]), .I1(SPECIAL_EXE), .O(X1N1187));
  BUF X1I2257 (.I(CLK1), .O(CLK1_NBUF));
  FD X1I2275 (.C(X1N2282), .D(X1N2276), .Q(CLK));
  INV X1I2277 (.I(CLK), .O(X1N2276));
  FD X1I2279 (.C(X1N6457), .D(X1N2280), .Q(X1N2282));
  INV X1I2281 (.I(X1N2282), .O(X1N2280));
  GND X1I2611 (.G(X1N2612));
  AND2 X1I2698 (.I0(END_WRITE), .I1(ENABLE_SERIAL), .O(X1N5932));
  BUFE8 X1I2710 (.E(X1N2760), .I({SERIAL_DATA[7], SERIAL_DATA[6], 
    SERIAL_DATA[5], SERIAL_DATA[4], SERIAL_DATA[3], SERIAL_DATA[2], 
    SERIAL_DATA[1], SERIAL_DATA[0]}), .O({MEM_DAT[7], MEM_DAT[6], MEM_DAT[5]
    , MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  BUFE X1I2713 (.E(X1N2760), .I(SERIAL_REQUEST), .O(MEM_DAT[8]));
  REGBANK1 REG_BANK (.D({MEM_FF[31], MEM_FF[30], MEM_FF[29], MEM_FF[28], 
    MEM_FF[27], MEM_FF[26], MEM_FF[25], MEM_FF[24], MEM_FF[23], MEM_FF[22], 
    MEM_FF[21], MEM_FF[20], MEM_FF[19], MEM_FF[18], MEM_FF[17], MEM_FF[16], 
    MEM_FF[15], MEM_FF[14], MEM_FF[13], MEM_FF[12], MEM_FF[11], MEM_FF[10], 
    MEM_FF[9], MEM_FF[8], MEM_FF[7], MEM_FF[6], MEM_FF[5], MEM_FF[4], 
    MEM_FF[3], MEM_FF[2], MEM_FF[1], MEM_FF[0]}), .OA({REG_A[31], REG_A[30]
    , REG_A[29], REG_A[28], REG_A[27], REG_A[26], REG_A[25], REG_A[24], 
    REG_A[23], REG_A[22], REG_A[21], REG_A[20], REG_A[19], REG_A[18], 
    REG_A[17], REG_A[16], REG_A[15], REG_A[14], REG_A[13], REG_A[12], 
    REG_A[11], REG_A[10], REG_A[9], REG_A[8], REG_A[7], REG_A[6], REG_A[5], 
    REG_A[4], REG_A[3], REG_A[2], REG_A[1], REG_A[0]}), .OB({REG_B[31], 
    REG_B[30], REG_B[29], REG_B[28], REG_B[27], REG_B[26], REG_B[25], 
    REG_B[24], REG_B[23], REG_B[22], REG_B[21], REG_B[20], REG_B[19], 
    REG_B[18], REG_B[17], REG_B[16], REG_B[15], REG_B[14], REG_B[13], 
    REG_B[12], REG_B[11], REG_B[10], REG_B[9], REG_B[8], REG_B[7], REG_B[6]
    , REG_B[5], REG_B[4], REG_B[3], REG_B[2], REG_B[1], REG_B[0]}), .RA({
    INSTRUCTION[25], INSTRUCTION[24], INSTRUCTION[23], INSTRUCTION[22], 
    INSTRUCTION[21]}), .RB({INSTRUCTION[20], INSTRUCTION[19], 
    INSTRUCTION[18], INSTRUCTION[17], INSTRUCTION[16]}), .WCLK(CLK2), .WE
    (X1N3028), .WSEL(CLK2_NBUF), .W({REG_DEST_WB[4], REG_DEST_WB[3], 
    REG_DEST_WB[2], REG_DEST_WB[1], REG_DEST_WB[0]}));
  SERIAL_FIFO X1I2754 (.ACK_IN(SERIAL_ACK), .ACK_OUT(X1N2874), .CLK(CLK1), 
    .CLK_50MHZ(CLK_50MHZ), .IN({MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], 
    MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .OUTPUT({
    SERIAL_DATA[7], SERIAL_DATA[6], SERIAL_DATA[5], SERIAL_DATA[4], 
    SERIAL_DATA[3], SERIAL_DATA[2], SERIAL_DATA[1], SERIAL_DATA[0]}), 
    .REQ_IN(X1N5932), .REQ_OUT(SERIAL_REQUEST));
  BUF X1I2862 (.I(CLK2), .O(CLK2_NBUF));
  ALU2 X1I295 (.A({REG_A_EXE_FF[31], REG_A_EXE_FF[30], REG_A_EXE_FF[29], 
    REG_A_EXE_FF[28], REG_A_EXE_FF[27], REG_A_EXE_FF[26], REG_A_EXE_FF[25], 
    REG_A_EXE_FF[24], REG_A_EXE_FF[23], REG_A_EXE_FF[22], REG_A_EXE_FF[21], 
    REG_A_EXE_FF[20], REG_A_EXE_FF[19], REG_A_EXE_FF[18], REG_A_EXE_FF[17], 
    REG_A_EXE_FF[16], REG_A_EXE_FF[15], REG_A_EXE_FF[14], REG_A_EXE_FF[13], 
    REG_A_EXE_FF[12], REG_A_EXE_FF[11], REG_A_EXE_FF[10], REG_A_EXE_FF[9], 
    REG_A_EXE_FF[8], REG_A_EXE_FF[7], REG_A_EXE_FF[6], REG_A_EXE_FF[5], 
    REG_A_EXE_FF[4], REG_A_EXE_FF[3], REG_A_EXE_FF[2], REG_A_EXE_FF[1], 
    REG_A_EXE_FF[0]}), .B({B_EXE_INPUT[31], B_EXE_INPUT[30], B_EXE_INPUT[29]
    , B_EXE_INPUT[28], B_EXE_INPUT[27], B_EXE_INPUT[26], B_EXE_INPUT[25], 
    B_EXE_INPUT[24], B_EXE_INPUT[23], B_EXE_INPUT[22], B_EXE_INPUT[21], 
    B_EXE_INPUT[20], B_EXE_INPUT[19], B_EXE_INPUT[18], B_EXE_INPUT[17], 
    B_EXE_INPUT[16], B_EXE_INPUT[15], B_EXE_INPUT[14], B_EXE_INPUT[13], 
    B_EXE_INPUT[12], B_EXE_INPUT[11], B_EXE_INPUT[10], B_EXE_INPUT[9], 
    B_EXE_INPUT[8], B_EXE_INPUT[7], B_EXE_INPUT[6], B_EXE_INPUT[5], 
    B_EXE_INPUT[4], B_EXE_INPUT[3], B_EXE_INPUT[2], B_EXE_INPUT[1], 
    B_EXE_INPUT[0]}), .OP({OP[3], OP[2], OP[1], OP[0]}), .OVERFLOW(X1N6634)
    , .S({ALU_RES[31], ALU_RES[30], ALU_RES[29], ALU_RES[28], ALU_RES[27], 
    ALU_RES[26], ALU_RES[25], ALU_RES[24], ALU_RES[23], ALU_RES[22], 
    ALU_RES[21], ALU_RES[20], ALU_RES[19], ALU_RES[18], ALU_RES[17], 
    ALU_RES[16], ALU_RES[15], ALU_RES[14], ALU_RES[13], ALU_RES[12], 
    ALU_RES[11], ALU_RES[10], ALU_RES[9], ALU_RES[8], ALU_RES[7], ALU_RES[6]
    , ALU_RES[5], ALU_RES[4], ALU_RES[3], ALU_RES[2], ALU_RES[1], ALU_RES[0]
    }));
  REG32 X1I2984 (.CLK(CLK1), .EN(GLB_EN), .I({REG_PC[31], REG_PC[30], 
    REG_PC[29], REG_PC[28], REG_PC[27], REG_PC[26], REG_PC[25], REG_PC[24], 
    REG_PC[23], REG_PC[22], REG_PC[21], REG_PC[20], REG_PC[19], REG_PC[18], 
    REG_PC[17], REG_PC[16], REG_PC[15], REG_PC[14], REG_PC[13], REG_PC[12], 
    REG_PC[11], REG_PC[10], REG_PC[9], REG_PC[8], REG_PC[7], REG_PC[6], 
    REG_PC[5], REG_PC[4], REG_PC[3], REG_PC[2], REG_PC[1], REG_PC[0]}), .O({
    ALU_PC[31], ALU_PC[30], ALU_PC[29], ALU_PC[28], ALU_PC[27], ALU_PC[26], 
    ALU_PC[25], ALU_PC[24], ALU_PC[23], ALU_PC[22], ALU_PC[21], ALU_PC[20], 
    ALU_PC[19], ALU_PC[18], ALU_PC[17], ALU_PC[16], ALU_PC[15], ALU_PC[14], 
    ALU_PC[13], ALU_PC[12], ALU_PC[11], ALU_PC[10], ALU_PC[9], ALU_PC[8], 
    ALU_PC[7], ALU_PC[6], ALU_PC[5], ALU_PC[4], ALU_PC[3], ALU_PC[2], 
    ALU_PC[1], ALU_PC[0]}));
  REG32 X1I2985 (.CLK(CLK2), .EN(X1N6218), .I({PC[31], PC[30], PC[29], 
    PC[28], PC[27], PC[26], PC[25], PC[24], PC[23], PC[22], PC[21], PC[20], 
    PC[19], PC[18], PC[17], PC[16], PC[15], PC[14], PC[13], PC[12], PC[11], 
    PC[10], PC[9], PC[8], PC[7], PC[6], PC[5], PC[4], PC[3], PC[2], PC[1], 
    PC[0]}), .O({REG_PC[31], REG_PC[30], REG_PC[29], REG_PC[28], REG_PC[27]
    , REG_PC[26], REG_PC[25], REG_PC[24], REG_PC[23], REG_PC[22], REG_PC[21]
    , REG_PC[20], REG_PC[19], REG_PC[18], REG_PC[17], REG_PC[16], REG_PC[15]
    , REG_PC[14], REG_PC[13], REG_PC[12], REG_PC[11], REG_PC[10], REG_PC[9]
    , REG_PC[8], REG_PC[7], REG_PC[6], REG_PC[5], REG_PC[4], REG_PC[3], 
    REG_PC[2], REG_PC[1], REG_PC[0]}));
  REG32 X1I2992 (.CLK(CLK1), .EN(GLB_EN), .I({ALU_PC[31], ALU_PC[30], 
    ALU_PC[29], ALU_PC[28], ALU_PC[27], ALU_PC[26], ALU_PC[25], ALU_PC[24], 
    ALU_PC[23], ALU_PC[22], ALU_PC[21], ALU_PC[20], ALU_PC[19], ALU_PC[18], 
    ALU_PC[17], ALU_PC[16], ALU_PC[15], ALU_PC[14], ALU_PC[13], ALU_PC[12], 
    ALU_PC[11], ALU_PC[10], ALU_PC[9], ALU_PC[8], ALU_PC[7], ALU_PC[6], 
    ALU_PC[5], ALU_PC[4], ALU_PC[3], ALU_PC[2], ALU_PC[1], ALU_PC[0]}), .O({
    MEM_PC[31], MEM_PC[30], MEM_PC[29], MEM_PC[28], MEM_PC[27], MEM_PC[26], 
    MEM_PC[25], MEM_PC[24], MEM_PC[23], MEM_PC[22], MEM_PC[21], MEM_PC[20], 
    MEM_PC[19], MEM_PC[18], MEM_PC[17], MEM_PC[16], MEM_PC[15], MEM_PC[14], 
    MEM_PC[13], MEM_PC[12], MEM_PC[11], MEM_PC[10], MEM_PC[9], MEM_PC[8], 
    MEM_PC[7], MEM_PC[6], MEM_PC[5], MEM_PC[4], MEM_PC[3], MEM_PC[2], 
    MEM_PC[1], MEM_PC[0]}));
  AND2B1 X1I3027 (.I0(INTERRUPT), .I1(GLB_EN), .O(X1N3028));
  FDRE X1I3039 (.C(CLK1), .CE(GLB_EN), .D(X1N3057), .Q(OUTPUT), .R(FLUSH));
  INTERRUPT_VECTOR X1I3046 (.OUT({RESETVECTOR[31], RESETVECTOR[30], 
    RESETVECTOR[29], RESETVECTOR[28], RESETVECTOR[27], RESETVECTOR[26], 
    RESETVECTOR[25], RESETVECTOR[24], RESETVECTOR[23], RESETVECTOR[22], 
    RESETVECTOR[21], RESETVECTOR[20], RESETVECTOR[19], RESETVECTOR[18], 
    RESETVECTOR[17], RESETVECTOR[16], RESETVECTOR[15], RESETVECTOR[14], 
    RESETVECTOR[13], RESETVECTOR[12], RESETVECTOR[11], RESETVECTOR[10], 
    RESETVECTOR[9], RESETVECTOR[8], RESETVECTOR[7], RESETVECTOR[6], 
    RESETVECTOR[5], RESETVECTOR[4], RESETVECTOR[3], RESETVECTOR[2], 
    RESETVECTOR[1], RESETVECTOR[0]}), .PLUS_100(X1N5811), .PLUS_80(X1N6667)
    , .VECTOR_8000(X1N6062));
  MUX2_1X32 X1I3051 (.A({NEXT_PC[31], NEXT_PC[30], NEXT_PC[29], NEXT_PC[28]
    , NEXT_PC[27], NEXT_PC[26], NEXT_PC[25], NEXT_PC[24], NEXT_PC[23], 
    NEXT_PC[22], NEXT_PC[21], NEXT_PC[20], NEXT_PC[19], NEXT_PC[18], 
    NEXT_PC[17], NEXT_PC[16], NEXT_PC[15], NEXT_PC[14], NEXT_PC[13], 
    NEXT_PC[12], NEXT_PC[11], NEXT_PC[10], NEXT_PC[9], NEXT_PC[8], 
    NEXT_PC[7], NEXT_PC[6], NEXT_PC[5], NEXT_PC[4], NEXT_PC[3], NEXT_PC[2], 
    NEXT_PC[1], NEXT_PC[0]}), .B({RESETVECTOR[31], RESETVECTOR[30], 
    RESETVECTOR[29], RESETVECTOR[28], RESETVECTOR[27], RESETVECTOR[26], 
    RESETVECTOR[25], RESETVECTOR[24], RESETVECTOR[23], RESETVECTOR[22], 
    RESETVECTOR[21], RESETVECTOR[20], RESETVECTOR[19], RESETVECTOR[18], 
    RESETVECTOR[17], RESETVECTOR[16], RESETVECTOR[15], RESETVECTOR[14], 
    RESETVECTOR[13], RESETVECTOR[12], RESETVECTOR[11], RESETVECTOR[10], 
    RESETVECTOR[9], RESETVECTOR[8], RESETVECTOR[7], RESETVECTOR[6], 
    RESETVECTOR[5], RESETVECTOR[4], RESETVECTOR[3], RESETVECTOR[2], 
    RESETVECTOR[1], RESETVECTOR[0]}), .SB(INTERRUPT), .S({NOTSYSCALLPC[31], 
    NOTSYSCALLPC[30], NOTSYSCALLPC[29], NOTSYSCALLPC[28], NOTSYSCALLPC[27], 
    NOTSYSCALLPC[26], NOTSYSCALLPC[25], NOTSYSCALLPC[24], NOTSYSCALLPC[23], 
    NOTSYSCALLPC[22], NOTSYSCALLPC[21], NOTSYSCALLPC[20], NOTSYSCALLPC[19], 
    NOTSYSCALLPC[18], NOTSYSCALLPC[17], NOTSYSCALLPC[16], NOTSYSCALLPC[15], 
    NOTSYSCALLPC[14], NOTSYSCALLPC[13], NOTSYSCALLPC[12], NOTSYSCALLPC[11], 
    NOTSYSCALLPC[10], NOTSYSCALLPC[9], NOTSYSCALLPC[8], NOTSYSCALLPC[7], 
    NOTSYSCALLPC[6], NOTSYSCALLPC[5], NOTSYSCALLPC[4], NOTSYSCALLPC[3], 
    NOTSYSCALLPC[2], NOTSYSCALLPC[1], NOTSYSCALLPC[0]}));
  FDRE X1I3056 (.C(CLK1), .CE(GLB_EN), .D(X1N3160), .Q(X1N3057), .R(FLUSH));
  AND3B2 X1I3067 (.I0(INSTRUCTION[29]), .I1(INSTRUCTION[30]), .I2
    (INSTRUCTION[31]), .O(X1N3071));
  REG32 REG_A (.CLK(CLK1), .EN(GLB_EN), .I({REG_A[31], REG_A[30], REG_A[29]
    , REG_A[28], REG_A[27], REG_A[26], REG_A[25], REG_A[24], REG_A[23], 
    REG_A[22], REG_A[21], REG_A[20], REG_A[19], REG_A[18], REG_A[17], 
    REG_A[16], REG_A[15], REG_A[14], REG_A[13], REG_A[12], REG_A[11], 
    REG_A[10], REG_A[9], REG_A[8], REG_A[7], REG_A[6], REG_A[5], REG_A[4], 
    REG_A[3], REG_A[2], REG_A[1], REG_A[0]}), .O({REG_A_EXE[31], 
    REG_A_EXE[30], REG_A_EXE[29], REG_A_EXE[28], REG_A_EXE[27], 
    REG_A_EXE[26], REG_A_EXE[25], REG_A_EXE[24], REG_A_EXE[23], 
    REG_A_EXE[22], REG_A_EXE[21], REG_A_EXE[20], REG_A_EXE[19], 
    REG_A_EXE[18], REG_A_EXE[17], REG_A_EXE[16], REG_A_EXE[15], 
    REG_A_EXE[14], REG_A_EXE[13], REG_A_EXE[12], REG_A_EXE[11], 
    REG_A_EXE[10], REG_A_EXE[9], REG_A_EXE[8], REG_A_EXE[7], REG_A_EXE[6], 
    REG_A_EXE[5], REG_A_EXE[4], REG_A_EXE[3], REG_A_EXE[2], REG_A_EXE[1], 
    REG_A_EXE[0]}));
  AND5B4 X1I3074 (.I0(INSTRUCTION[24]), .I1(INSTRUCTION[25]), .I2
    (INSTRUCTION[29]), .I3(INSTRUCTION[31]), .I4(INSTRUCTION[30]), .O
    (MOV_CP));
  OR3 X1I3086 (.I0(X1N3090), .I1(X1N5327), .I2(INST_ADDR_ERROR), .O(SET_R31)
    );
  AND2 X1I3089 (.I0(JUMPLONG), .I1(INSTRUCTION[26]), .O(X1N3090));
  OR3 X1I3098 (.I0(INTERRUPT), .I1(INTERRUPT_MEM), .I2(RESET), .O(FLUSH));
  OR2 X1I3125 (.I0(INSTRUCTION[30]), .I1(INSTRUCTION[31]), .O(X1N3126));
  AND3B1 X1I3129 (.I0(INSTRUCTION[30]), .I1(INSTRUCTION[29]), .I2
    (INSTRUCTION[31]), .O(X1N3161));
  MUX3_1X32 X1I314 (.A({REG_B_EXE[31], REG_B_EXE[30], REG_B_EXE[29], 
    REG_B_EXE[28], REG_B_EXE[27], REG_B_EXE[26], REG_B_EXE[25], 
    REG_B_EXE[24], REG_B_EXE[23], REG_B_EXE[22], REG_B_EXE[21], 
    REG_B_EXE[20], REG_B_EXE[19], REG_B_EXE[18], REG_B_EXE[17], 
    REG_B_EXE[16], REG_B_EXE[15], REG_B_EXE[14], REG_B_EXE[13], 
    REG_B_EXE[12], REG_B_EXE[11], REG_B_EXE[10], REG_B_EXE[9], REG_B_EXE[8]
    , REG_B_EXE[7], REG_B_EXE[6], REG_B_EXE[5], REG_B_EXE[4], REG_B_EXE[3], 
    REG_B_EXE[2], REG_B_EXE[1], REG_B_EXE[0]}), .B({SEL_PORT_B_MEM, 
    MEM_FF[31], MEM_FF[30], MEM_FF[29], MEM_FF[28], MEM_FF[27], MEM_FF[26], 
    MEM_FF[25], MEM_FF[24], MEM_FF[23], MEM_FF[22], MEM_FF[21], MEM_FF[20], 
    MEM_FF[19], MEM_FF[18], MEM_FF[17], MEM_FF[16], MEM_FF[15], MEM_FF[14], 
    MEM_FF[13], MEM_FF[12], MEM_FF[11], MEM_FF[10], MEM_FF[9], MEM_FF[8], 
    MEM_FF[7], MEM_FF[6], MEM_FF[5], MEM_FF[4], MEM_FF[3], MEM_FF[2], 
    MEM_FF[1], MEM_FF[0]}), .C({SEL_PORT_B_ALU, EXE_FF[31], EXE_FF[30], 
    EXE_FF[29], EXE_FF[28], EXE_FF[27], EXE_FF[26], EXE_FF[25], EXE_FF[24], 
    EXE_FF[23], EXE_FF[22], EXE_FF[21], EXE_FF[20], EXE_FF[19], EXE_FF[18], 
    EXE_FF[17], EXE_FF[16], EXE_FF[15], EXE_FF[14], EXE_FF[13], EXE_FF[12], 
    EXE_FF[11], EXE_FF[10], EXE_FF[9], EXE_FF[8], EXE_FF[7], EXE_FF[6], 
    EXE_FF[5], EXE_FF[4], EXE_FF[3], EXE_FF[2], EXE_FF[1], EXE_FF[0]}), .S({
    REG_B_EXE_FF[31], REG_B_EXE_FF[30], REG_B_EXE_FF[29], REG_B_EXE_FF[28], 
    REG_B_EXE_FF[27], REG_B_EXE_FF[26], REG_B_EXE_FF[25], REG_B_EXE_FF[24], 
    REG_B_EXE_FF[23], REG_B_EXE_FF[22], REG_B_EXE_FF[21], REG_B_EXE_FF[20], 
    REG_B_EXE_FF[19], REG_B_EXE_FF[18], REG_B_EXE_FF[17], REG_B_EXE_FF[16], 
    REG_B_EXE_FF[15], REG_B_EXE_FF[14], REG_B_EXE_FF[13], REG_B_EXE_FF[12], 
    REG_B_EXE_FF[11], REG_B_EXE_FF[10], REG_B_EXE_FF[9], REG_B_EXE_FF[8], 
    REG_B_EXE_FF[7], REG_B_EXE_FF[6], REG_B_EXE_FF[5], REG_B_EXE_FF[4], 
    REG_B_EXE_FF[3], REG_B_EXE_FF[2], REG_B_EXE_FF[1], REG_B_EXE_FF[0]}));
  AND2B1 X1I3151 (.I0(INSTRUCTION[23]), .I1(MOV_CP), .O(X1N3075));
  OR2 X1I3159 (.I0(X1N3161), .I1(X1N3164), .O(X1N3160));
  AND2 X1I3163 (.I0(MOV_CP), .I1(INSTRUCTION[23]), .O(X1N3164));
  REG5 X1I3171 (.CLK(CLK1), .EN(GLB_EN), .I({CPO_REG_DEST[4], 
    CPO_REG_DEST[3], CPO_REG_DEST[2], CPO_REG_DEST[1], CPO_REG_DEST[0]}), 
    .O({CPO_ALU_DEST[4], CPO_ALU_DEST[3], CPO_ALU_DEST[2], CPO_ALU_DEST[1], 
    CPO_ALU_DEST[0]}), .RES(FLUSH));
  REG5 X1I3178 (.CLK(CLK1), .EN(GLB_EN), .I({CPO_ALU_DEST[4], 
    CPO_ALU_DEST[3], CPO_ALU_DEST[2], CPO_ALU_DEST[1], CPO_ALU_DEST[0]}), 
    .O({CPO_REG_SELECT[4], CPO_REG_SELECT[3], CPO_REG_SELECT[2], 
    CPO_REG_SELECT[1], CPO_REG_SELECT[0]}), .RES(FLUSH));
  FDRE X1I3189 (.C(CLK1), .CE(GLB_EN), .D(X1N3255), .Q(X1N3194), .R(FLUSH));
  FDRE X1I3190 (.C(CLK1), .CE(GLB_EN), .D(X1N3194), .Q(CPO_WRITE), .R(FLUSH)
    );
  M2_1X5 X1I3200 (.A({INSTRUCTION[15], INSTRUCTION[14], INSTRUCTION[13]
    , INSTRUCTION[12], INSTRUCTION[11]}), .B({INSTRUCTION[20], 
    INSTRUCTION[19], INSTRUCTION[18], INSTRUCTION[17], INSTRUCTION[16]}), 
    .O({CPO_REG_DEST[4], CPO_REG_DEST[3], CPO_REG_DEST[2], CPO_REG_DEST[1], 
    CPO_REG_DEST[0]}), .SB(INSTRUCTION[31]));
  FDRE X1I3216 (.C(CLK1), .CE(GLB_EN), .D(X1N3213), .Q(CPO_OUTPUT), .R
    (FLUSH));
  FDRE X1I3217 (.C(CLK1), .CE(GLB_EN), .D(X1N3272), .Q(X1N3213), .R(FLUSH));
  AND3B2 X1I3237 (.I0(INSTRUCTION[26]), .I1(INSTRUCTION[27]), .I2
    (INSTRUCTION[30]), .O(SELECT_CPO));
  AND5B3 X1I3242 (.I0(INSTRUCTION[31]), .I1(INSTRUCTION[25]), .I2
    (INSTRUCTION[24]), .I3(INSTRUCTION[23]), .I4(SELECT_CPO), .O(X1N3245));
  AND3B1 X1I3243 (.I0(INSTRUCTION[29]), .I1(INSTRUCTION[31]), .I2
    (SELECT_CPO), .O(X1N3246));
  OR2 X1I3244 (.I0(X1N3246), .I1(X1N3245), .O(X1N3255));
  AND5B4 X1I3261 (.I0(INSTRUCTION[31]), .I1(INSTRUCTION[25]), .I2
    (INSTRUCTION[24]), .I3(INSTRUCTION[23]), .I4(SELECT_CPO), .O(X1N3266));
  OR2 X1I3262 (.I0(X1N3267), .I1(X1N3266), .O(X1N3272));
  AND3 X1I3271 (.I0(INSTRUCTION[29]), .I1(INSTRUCTION[31]), .I2(SELECT_CPO)
    , .O(X1N3267));
  D4_16E IGNORE_NO_LOAD2 (.A0(CPO_REG_SELECT[0]), .A1(CPO_REG_SELECT[1]), 
    .A2(CPO_REG_SELECT[2]), .A3(CPO_REG_SELECT[3]), .D0(CPO_WRITTE_INDEX), 
    .D10(CPO_WRITE_ENTRY_HI), .D12(CP0_WRITE_STATUS), .D13(CP0_WRITE_CAUSE)
    , .D2(CPO_WRITE_ENTRY_LO), .D4(CPO_WRITE_CONTEXT), .E(X1N3295));
  BUFE32 X1I3284 (.E(CPO_READ_EPC), .I({EPC[31], EPC[30], EPC[29], EPC[28], 
    EPC[27], EPC[26], EPC[25], EPC[24], EPC[23], EPC[22], EPC[21], EPC[20], 
    EPC[19], EPC[18], EPC[17], EPC[16], EPC[15], EPC[14], EPC[13], EPC[12], 
    EPC[11], EPC[10], EPC[9], EPC[8], EPC[7], EPC[6], EPC[5], EPC[4], EPC[3]
    , EPC[2], EPC[1], EPC[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  D4_16E IGNORE_NO_LOAD3 (.A0(CPO_REG_SELECT[0]), .A1(CPO_REG_SELECT[1]), 
    .A2(CPO_REG_SELECT[2]), .A3(CPO_REG_SELECT[3]), .D0(CPO_READ_INDEX), .D1
    (CPO_READ_RANDOM), .D10(CPO_READ_ENTRY_HI), .D12(CP0_READ_STATUS), .D13
    (CP0_READ_CAUSE), .D14(CPO_READ_EPC), .D15(CPO_READ_PRID), .D2
    (CPO_READ_ENTRY_LO), .D4(CPO_READ_CONTEXT), .D8(CPO_READ_BADVADDR), .E
    (X1N3299));
  AND5B2 X1I3294 (.I0(CPO_REG_SELECT[4]), .I1(CLK1_NBUF), .I2(CPO_WRITE), 
    .I3(GLB_EN), .I4(X1N5418), .O(X1N3295));
  AND4B2 X1I3297 (.I0(CPO_REG_SELECT[4]), .I1(CLK1_NBUF), .I2(CPO_OUTPUT), 
    .I3(GLB_EN), .O(X1N3299));
  REG32 X1I331 (.CLK(CLK1), .EN(GLB_EN), .I({REG_B[31], REG_B[30], REG_B[29]
    , REG_B[28], REG_B[27], REG_B[26], REG_B[25], REG_B[24], REG_B[23], 
    REG_B[22], REG_B[21], REG_B[20], REG_B[19], REG_B[18], REG_B[17], 
    REG_B[16], REG_B[15], REG_B[14], REG_B[13], REG_B[12], REG_B[11], 
    REG_B[10], REG_B[9], REG_B[8], REG_B[7], REG_B[6], REG_B[5], REG_B[4], 
    REG_B[3], REG_B[2], REG_B[1], REG_B[0]}), .O({REG_B_EXE[31], 
    REG_B_EXE[30], REG_B_EXE[29], REG_B_EXE[28], REG_B_EXE[27], 
    REG_B_EXE[26], REG_B_EXE[25], REG_B_EXE[24], REG_B_EXE[23], 
    REG_B_EXE[22], REG_B_EXE[21], REG_B_EXE[20], REG_B_EXE[19], 
    REG_B_EXE[18], REG_B_EXE[17], REG_B_EXE[16], REG_B_EXE[15], 
    REG_B_EXE[14], REG_B_EXE[13], REG_B_EXE[12], REG_B_EXE[11], 
    REG_B_EXE[10], REG_B_EXE[9], REG_B_EXE[8], REG_B_EXE[7], REG_B_EXE[6], 
    REG_B_EXE[5], REG_B_EXE[4], REG_B_EXE[3], REG_B_EXE[2], REG_B_EXE[1], 
    REG_B_EXE[0]}));
  REG5 X1I3316 (.CLK(CLK1), .EN(GLB_EN), .I({INSTRUCTION[4], INSTRUCTION[3]
    , INSTRUCTION[2], INSTRUCTION[1], INSTRUCTION[0]}), .O({
    CPO_INSTRUCTION_EX[4], CPO_INSTRUCTION_EX[3], CPO_INSTRUCTION_EX[2], 
    CPO_INSTRUCTION_EX[1], CPO_INSTRUCTION_EX[0]}), .RES(X1N4142));
  REG5 X1I3322 (.CLK(CLK1), .EN(GLB_EN), .I({CPO_INSTRUCTION_EX[4], 
    CPO_INSTRUCTION_EX[3], CPO_INSTRUCTION_EX[2], CPO_INSTRUCTION_EX[1], 
    CPO_INSTRUCTION_EX[0]}), .O({CP0_INSTRUCTION[4], CP0_INSTRUCTION[3], 
    CP0_INSTRUCTION[2], CP0_INSTRUCTION[1], CP0_INSTRUCTION[0]}), .RES
    (FLUSH));
  AND2 X1I3347 (.I0(MEM_WRITE), .I1(ENABLE_DISPLAY), .O(X1N3422));
  AND2B1 X1I3361 (.I0(MEM_WRITE), .I1(ENABLE_SERIAL), .O(X1N2760));
  AND2B1 X1I3368 (.I0(MEM_WRITE), .I1(ENABLE_ROM), .O(X1N3367));
  RANDOM X1I3444 (.CLK(CLK1), .P({RANDOM[13], RANDOM[12], RANDOM[11], 
    RANDOM[10], RANDOM[9], RANDOM[8]}));
  X14SEG X1I3461 (.IN({DISPLAY[7], DISPLAY[6], DISPLAY[5], DISPLAY[4], 
    DISPLAY[3], DISPLAY[2], DISPLAY[1], DISPLAY[0]}), .LEFT({DISP_LEFT[6], 
    DISP_LEFT[5], DISP_LEFT[4], DISP_LEFT[3], DISP_LEFT[2], DISP_LEFT[1], 
    DISP_LEFT[0]}), .RIGHT({DISP_RIGHT[6], DISP_RIGHT[5], DISP_RIGHT[4], 
    DISP_RIGHT[3], DISP_RIGHT[2], DISP_RIGHT[1], DISP_RIGHT[0]}));
  REG32 EXE_RES (.CLK(CLK1), .EN(GLB_EN), .I({EXE_RES[31], EXE_RES[30], 
    EXE_RES[29], EXE_RES[28], EXE_RES[27], EXE_RES[26], EXE_RES[25], 
    EXE_RES[24], EXE_RES[23], EXE_RES[22], EXE_RES[21], EXE_RES[20], 
    EXE_RES[19], EXE_RES[18], EXE_RES[17], EXE_RES[16], EXE_RES[15], 
    EXE_RES[14], EXE_RES[13], EXE_RES[12], EXE_RES[11], EXE_RES[10], 
    EXE_RES[9], EXE_RES[8], EXE_RES[7], EXE_RES[6], EXE_RES[5], EXE_RES[4], 
    EXE_RES[3], EXE_RES[2], EXE_RES[1], EXE_RES[0]}), .O({EXE_FF[31], 
    EXE_FF[30], EXE_FF[29], EXE_FF[28], EXE_FF[27], EXE_FF[26], EXE_FF[25], 
    EXE_FF[24], EXE_FF[23], EXE_FF[22], EXE_FF[21], EXE_FF[20], EXE_FF[19], 
    EXE_FF[18], EXE_FF[17], EXE_FF[16], EXE_FF[15], EXE_FF[14], EXE_FF[13], 
    EXE_FF[12], EXE_FF[11], EXE_FF[10], EXE_FF[9], EXE_FF[8], EXE_FF[7], 
    EXE_FF[6], EXE_FF[5], EXE_FF[4], EXE_FF[3], EXE_FF[2], EXE_FF[1], 
    EXE_FF[0]}));
  REG32 X1I352 (.CLK(CLK1), .EN(GLB_EN), .I({MEM_RES[31], MEM_RES[30], 
    MEM_RES[29], MEM_RES[28], MEM_RES[27], MEM_RES[26], MEM_RES[25], 
    MEM_RES[24], MEM_RES[23], MEM_RES[22], MEM_RES[21], MEM_RES[20], 
    MEM_RES[19], MEM_RES[18], MEM_RES[17], MEM_RES[16], MEM_RES[15], 
    MEM_RES[14], MEM_RES[13], MEM_RES[12], MEM_RES[11], MEM_RES[10], 
    MEM_RES[9], MEM_RES[8], MEM_RES[7], MEM_RES[6], MEM_RES[5], MEM_RES[4], 
    MEM_RES[3], MEM_RES[2], MEM_RES[1], MEM_RES[0]}), .O({MEM_FF[31], 
    MEM_FF[30], MEM_FF[29], MEM_FF[28], MEM_FF[27], MEM_FF[26], MEM_FF[25], 
    MEM_FF[24], MEM_FF[23], MEM_FF[22], MEM_FF[21], MEM_FF[20], MEM_FF[19], 
    MEM_FF[18], MEM_FF[17], MEM_FF[16], MEM_FF[15], MEM_FF[14], MEM_FF[13], 
    MEM_FF[12], MEM_FF[11], MEM_FF[10], MEM_FF[9], MEM_FF[8], MEM_FF[7], 
    MEM_FF[6], MEM_FF[5], MEM_FF[4], MEM_FF[3], MEM_FF[2], MEM_FF[1], 
    MEM_FF[0]}));
  PC32 X1I355 (.CLK(CLK2), .EN(GLB_EN), .I({NOTSYSCALLPC[31], 
    NOTSYSCALLPC[30], NOTSYSCALLPC[29], NOTSYSCALLPC[28], NOTSYSCALLPC[27], 
    NOTSYSCALLPC[26], NOTSYSCALLPC[25], NOTSYSCALLPC[24], NOTSYSCALLPC[23], 
    NOTSYSCALLPC[22], NOTSYSCALLPC[21], NOTSYSCALLPC[20], NOTSYSCALLPC[19], 
    NOTSYSCALLPC[18], NOTSYSCALLPC[17], NOTSYSCALLPC[16], NOTSYSCALLPC[15], 
    NOTSYSCALLPC[14], NOTSYSCALLPC[13], NOTSYSCALLPC[12], NOTSYSCALLPC[11], 
    NOTSYSCALLPC[10], NOTSYSCALLPC[9], NOTSYSCALLPC[8], NOTSYSCALLPC[7], 
    NOTSYSCALLPC[6], NOTSYSCALLPC[5], NOTSYSCALLPC[4], NOTSYSCALLPC[3], 
    NOTSYSCALLPC[2], NOTSYSCALLPC[1], NOTSYSCALLPC[0]}), .O({PC[31], PC[30]
    , PC[29], PC[28], PC[27], PC[26], PC[25], PC[24], PC[23], PC[22], PC[21]
    , PC[20], PC[19], PC[18], PC[17], PC[16], PC[15], PC[14], PC[13], PC[12]
    , PC[11], PC[10], PC[9], PC[8], PC[7], PC[6], PC[5], PC[4], PC[3], PC[2]
    , PC[1], PC[0]}));
  REG6 X1I3555 (.CLK(CLK1), .EN(X1N4067), .I({CP0_INDEX_NEXT[5], 
    CP0_INDEX_NEXT[4], CP0_INDEX_NEXT[3], CP0_INDEX_NEXT[2], 
    CP0_INDEX_NEXT[1], CP0_INDEX_NEXT[0]}), .O({INDEX[13], INDEX[12], 
    INDEX[11], INDEX[10], INDEX[9], INDEX[8]}), .RES(X1N3557));
  GND X1I3556 (.G(X1N3557));
  CACHE X1I3587 (.ADDRESS({EXE_FF[11], EXE_FF[10], EXE_FF[9], EXE_FF[8], 
    EXE_FF[7], EXE_FF[6], EXE_FF[5], EXE_FF[4], EXE_FF[3], EXE_FF[2]}), .CLK
    (CLK1), .DATAIN({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], 
    CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], 
    CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], 
    CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], 
    CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], 
    CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8]
    , CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], 
    CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}), .DATA({CACHE_OUT[31], 
    CACHE_OUT[30], CACHE_OUT[29], CACHE_OUT[28], CACHE_OUT[27], 
    CACHE_OUT[26], CACHE_OUT[25], CACHE_OUT[24], CACHE_OUT[23], 
    CACHE_OUT[22], CACHE_OUT[21], CACHE_OUT[20], CACHE_OUT[19], 
    CACHE_OUT[18], CACHE_OUT[17], CACHE_OUT[16], CACHE_OUT[15], 
    CACHE_OUT[14], CACHE_OUT[13], CACHE_OUT[12], CACHE_OUT[11], 
    CACHE_OUT[10], CACHE_OUT[9], CACHE_OUT[8], CACHE_OUT[7], CACHE_OUT[6], 
    CACHE_OUT[5], CACHE_OUT[4], CACHE_OUT[3], CACHE_OUT[2], CACHE_OUT[1], 
    CACHE_OUT[0]}), .HIT(X1N4431), .PFNIN({DATA_PFN[19], DATA_PFN[18], 
    DATA_PFN[17], DATA_PFN[16], DATA_PFN[15], DATA_PFN[14], DATA_PFN[13], 
    DATA_PFN[12], DATA_PFN[11], DATA_PFN[10], DATA_PFN[9], DATA_PFN[8], 
    DATA_PFN[7], DATA_PFN[6], DATA_PFN[5], DATA_PFN[4], DATA_PFN[3], 
    DATA_PFN[2], DATA_PFN[1], DATA_PFN[0]}), .WRITE(X1N3817));
  BUFE32 X1I3588 (.E(X1N3655), .I({CACHE_OUT[31], CACHE_OUT[30], 
    CACHE_OUT[29], CACHE_OUT[28], CACHE_OUT[27], CACHE_OUT[26], 
    CACHE_OUT[25], CACHE_OUT[24], CACHE_OUT[23], CACHE_OUT[22], 
    CACHE_OUT[21], CACHE_OUT[20], CACHE_OUT[19], CACHE_OUT[18], 
    CACHE_OUT[17], CACHE_OUT[16], CACHE_OUT[15], CACHE_OUT[14], 
    CACHE_OUT[13], CACHE_OUT[12], CACHE_OUT[11], CACHE_OUT[10], CACHE_OUT[9]
    , CACHE_OUT[8], CACHE_OUT[7], CACHE_OUT[6], CACHE_OUT[5], CACHE_OUT[4], 
    CACHE_OUT[3], CACHE_OUT[2], CACHE_OUT[1], CACHE_OUT[0]}), .O({
    CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], 
    CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], 
    CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], 
    CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], 
    CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], 
    CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], 
    CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], 
    CACHE_DAT[1], CACHE_DAT[0]}));
  CACHE X1I3595 (.ADDRESS({PC[11], PC[10], PC[9], PC[8], PC[7], PC[6], PC[5]
    , PC[4], PC[3], PC[2]}), .CLK(CLK2), .DATAIN({MEM_DAT[31], MEM_DAT[30], 
    MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], 
    MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], 
    MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], 
    MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], 
    MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], 
    MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .DATA({
    CACHE_INSTRUCTION_PRE_DAT[31], CACHE_INSTRUCTION_PRE_DAT[30], 
    CACHE_INSTRUCTION_PRE_DAT[29], CACHE_INSTRUCTION_PRE_DAT[28], 
    CACHE_INSTRUCTION_PRE_DAT[27], CACHE_INSTRUCTION_PRE_DAT[26], 
    CACHE_INSTRUCTION_PRE_DAT[25], CACHE_INSTRUCTION_PRE_DAT[24], 
    CACHE_INSTRUCTION_PRE_DAT[23], CACHE_INSTRUCTION_PRE_DAT[22], 
    CACHE_INSTRUCTION_PRE_DAT[21], CACHE_INSTRUCTION_PRE_DAT[20], 
    CACHE_INSTRUCTION_PRE_DAT[19], CACHE_INSTRUCTION_PRE_DAT[18], 
    CACHE_INSTRUCTION_PRE_DAT[17], CACHE_INSTRUCTION_PRE_DAT[16], 
    CACHE_INSTRUCTION_PRE_DAT[15], CACHE_INSTRUCTION_PRE_DAT[14], 
    CACHE_INSTRUCTION_PRE_DAT[13], CACHE_INSTRUCTION_PRE_DAT[12], 
    CACHE_INSTRUCTION_PRE_DAT[11], CACHE_INSTRUCTION_PRE_DAT[10], 
    CACHE_INSTRUCTION_PRE_DAT[9], CACHE_INSTRUCTION_PRE_DAT[8], 
    CACHE_INSTRUCTION_PRE_DAT[7], CACHE_INSTRUCTION_PRE_DAT[6], 
    CACHE_INSTRUCTION_PRE_DAT[5], CACHE_INSTRUCTION_PRE_DAT[4], 
    CACHE_INSTRUCTION_PRE_DAT[3], CACHE_INSTRUCTION_PRE_DAT[2], 
    CACHE_INSTRUCTION_PRE_DAT[1], CACHE_INSTRUCTION_PRE_DAT[0]}), .HIT
    (INST_CACHE_HIT), .PFNIN({INST_PFN[19], INST_PFN[18], INST_PFN[17], 
    INST_PFN[16], INST_PFN[15], INST_PFN[14], INST_PFN[13], INST_PFN[12], 
    INST_PFN[11], INST_PFN[10], INST_PFN[9], INST_PFN[8], INST_PFN[7], 
    INST_PFN[6], INST_PFN[5], INST_PFN[4], INST_PFN[3], INST_PFN[2], 
    INST_PFN[1], INST_PFN[0]}), .WRITE(X1N5076));
  BUFE32 X1I3610 (.E(MEM_WRITE), .I({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}), .O({
    MEM_DAT[31], MEM_DAT[30], MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], 
    MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], 
    MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], 
    MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], 
    MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6]
    , MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]
    }));
  BUFE32 X1I3615 (.E(X1N4234), .I({MEM_DAT[31], MEM_DAT[30], MEM_DAT[29], 
    MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], 
    MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], 
    MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], 
    MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], 
    MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], 
    MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .O({CACHE_INST_DAT[31], 
    CACHE_INST_DAT[30], CACHE_INST_DAT[29], CACHE_INST_DAT[28], 
    CACHE_INST_DAT[27], CACHE_INST_DAT[26], CACHE_INST_DAT[25], 
    CACHE_INST_DAT[24], CACHE_INST_DAT[23], CACHE_INST_DAT[22], 
    CACHE_INST_DAT[21], CACHE_INST_DAT[20], CACHE_INST_DAT[19], 
    CACHE_INST_DAT[18], CACHE_INST_DAT[17], CACHE_INST_DAT[16], 
    CACHE_INST_DAT[15], CACHE_INST_DAT[14], CACHE_INST_DAT[13], 
    CACHE_INST_DAT[12], CACHE_INST_DAT[11], CACHE_INST_DAT[10], 
    CACHE_INST_DAT[9], CACHE_INST_DAT[8], CACHE_INST_DAT[7], 
    CACHE_INST_DAT[6], CACHE_INST_DAT[5], CACHE_INST_DAT[4], 
    CACHE_INST_DAT[3], CACHE_INST_DAT[2], CACHE_INST_DAT[1], 
    CACHE_INST_DAT[0]}));
  BUFE32 X1I3627 (.E(X1N6631), .I({MEM_DAT[31], MEM_DAT[30], MEM_DAT[29], 
    MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], 
    MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], 
    MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], 
    MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], 
    MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], 
    MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  AND3B1 X1I3654 (.I0(MEM_WRITE_SOON), .I1(CACHE), .I2(DATA_CACHE_HIT), .O
    (X1N3655));
  FDR X1I3684 (.C(CLK2), .D(X1N3715), .Q(INST_MEM_ACCESS), .R(X1N4234));
  AND2B1 X1I3714 (.I0(X1N4234), .I1(X1N3715), .O(HALT0));
  FD X1I3720 (.C(ILL_DAMN_WELL_CONNECT_IT_TO_THE_CLOCK), .D(CLK1_NBUF), .Q
    (X1N3738));
  OR4 X1I3727 (.I0(HALT0), .I1(HALT1), .I2(HALT2), .I3(HALT3), .O
    (ILL_DAMN_WELL_CONNECT_IT_TO_THE_CLOCK));
  SOP3 X1I3729 (.I0(X1N3730), .I1(X1N3744), .I2
    (ILL_DAMN_WELL_CONNECT_IT_TO_THE_CLOCK), .O(X1N3730));
  SOP3 X1I3734 (.I0(X1N3730), .I1(X1N3741), .I2
    (ILL_DAMN_WELL_CONNECT_IT_TO_THE_CLOCK), .O(X1N3744));
  XOR2 X1I3737 (.I0(X1N3738), .I1(CLK1_NBUF), .O(X1N3741));
  OR2 X1I3749 (.I0(INST_MEM_ACCESS), .I1(X1N3683), .O(X1N3715));
  AND4B2 X1I3759 (.I0(DATA_CACHE_HIT), .I1(FLUSH), .I2(CACHE), .I3(X1N5147)
    , .O(X1N3766));
  OR3 X1I3761 (.I0(DATA_MEM_ACCESS), .I1(X1N3766), .I2(X1N3834), .O(X1N3641)
    );
  AND2B1 X1I3763 (.I0(X1N3757), .I1(X1N3641), .O(HALT1));
  FDR X1I3774 (.C(CLK1), .D(X1N3641), .Q(DATA_MEM_ACCESS), .R(X1N3757));
  FDR X1I3797 (.C(CLK1), .D(X1N3798), .Q(MEM_WRITE), .R(X1N3757));
  AND2B1 X1I3805 (.I0(MEM_WRITE_SOON), .I1(X1N3798), .O(END_READ));
  OR2 X1I3808 (.I0(END_WRITE), .I1(END_READ), .O(X1N3757));
  OR2 X1I3836 (.I0(X1N3837), .I1(X1N3834), .O(X1N3798));
  AND2B1 X1I3842 (.I0(MEM_WRITE), .I1(X1N3837), .O(END_READ_B4_WRITE));
  OR3 X1I3848 (.I0(END_READ_B4_WRITE), .I1(END_READ), .I2(END_WRITE), .O
    (X1N3817));
  MMU X1I3860 (.CLK(CLK2), .DIRTY(MMU_DIRTY), .ENTRY_HI({CP0_ENTRY_LO[31], 
    CP0_ENTRY_LO[30], CP0_ENTRY_LO[29], CP0_ENTRY_LO[28], CP0_ENTRY_LO[27], 
    CP0_ENTRY_LO[26], CP0_ENTRY_LO[25], CP0_ENTRY_LO[24], CP0_ENTRY_LO[23], 
    CP0_ENTRY_LO[22], CP0_ENTRY_LO[21], CP0_ENTRY_LO[20], CP0_ENTRY_LO[19], 
    CP0_ENTRY_LO[18], CP0_ENTRY_LO[17], CP0_ENTRY_LO[16], CP0_ENTRY_LO[15], 
    CP0_ENTRY_LO[14], CP0_ENTRY_LO[13], CP0_ENTRY_LO[12], CP0_ENTRY_LO[11], 
    CP0_ENTRY_LO[10], CP0_ENTRY_LO[9], CP0_ENTRY_LO[8], CP0_ENTRY_LO[7], 
    CP0_ENTRY_LO[6], CP0_ENTRY_LO[5], CP0_ENTRY_LO[4], CP0_ENTRY_LO[3], 
    CP0_ENTRY_LO[2], CP0_ENTRY_LO[1], CP0_ENTRY_LO[0]}), .ENTRY_HI_OUT({
    MMU_ENTRY_HI[31], MMU_ENTRY_HI[30], MMU_ENTRY_HI[29], MMU_ENTRY_HI[28], 
    MMU_ENTRY_HI[27], MMU_ENTRY_HI[26], MMU_ENTRY_HI[25], MMU_ENTRY_HI[24], 
    MMU_ENTRY_HI[23], MMU_ENTRY_HI[22], MMU_ENTRY_HI[21], MMU_ENTRY_HI[20], 
    MMU_ENTRY_HI[19], MMU_ENTRY_HI[18], MMU_ENTRY_HI[17], MMU_ENTRY_HI[16], 
    MMU_ENTRY_HI[15], MMU_ENTRY_HI[14], MMU_ENTRY_HI[13], MMU_ENTRY_HI[12], 
    MMU_ENTRY_HI[11], MMU_ENTRY_HI[10], MMU_ENTRY_HI[9], MMU_ENTRY_HI[8], 
    MMU_ENTRY_HI[7], MMU_ENTRY_HI[6], MMU_ENTRY_HI[5], MMU_ENTRY_HI[4], 
    MMU_ENTRY_HI[3], MMU_ENTRY_HI[2], MMU_ENTRY_HI[1], MMU_ENTRY_HI[0]}), 
    .ENTRY_LO({CP0_ENTRY_HI[31], CP0_ENTRY_HI[30], CP0_ENTRY_HI[29], 
    CP0_ENTRY_HI[28], CP0_ENTRY_HI[27], CP0_ENTRY_HI[26], CP0_ENTRY_HI[25], 
    CP0_ENTRY_HI[24], CP0_ENTRY_HI[23], CP0_ENTRY_HI[22], CP0_ENTRY_HI[21], 
    CP0_ENTRY_HI[20], CP0_ENTRY_HI[19], CP0_ENTRY_HI[18], CP0_ENTRY_HI[17], 
    CP0_ENTRY_HI[16], CP0_ENTRY_HI[15], CP0_ENTRY_HI[14], CP0_ENTRY_HI[13], 
    CP0_ENTRY_HI[12], CP0_ENTRY_HI[11], CP0_ENTRY_HI[10], CP0_ENTRY_HI[9], 
    CP0_ENTRY_HI[8], CP0_ENTRY_HI[7], CP0_ENTRY_HI[6], CP0_ENTRY_HI[5], 
    CP0_ENTRY_HI[4], CP0_ENTRY_HI[3], CP0_ENTRY_HI[2], CP0_ENTRY_HI[1], 
    CP0_ENTRY_HI[0]}), .ENTRY_LO_OUT({MMU_ENTRY_LO[31], MMU_ENTRY_LO[30], 
    MMU_ENTRY_LO[29], MMU_ENTRY_LO[28], MMU_ENTRY_LO[27], MMU_ENTRY_LO[26], 
    MMU_ENTRY_LO[25], MMU_ENTRY_LO[24], MMU_ENTRY_LO[23], MMU_ENTRY_LO[22], 
    MMU_ENTRY_LO[21], MMU_ENTRY_LO[20], MMU_ENTRY_LO[19], MMU_ENTRY_LO[18], 
    MMU_ENTRY_LO[17], MMU_ENTRY_LO[16], MMU_ENTRY_LO[15], MMU_ENTRY_LO[14], 
    MMU_ENTRY_LO[13], MMU_ENTRY_LO[12], MMU_ENTRY_LO[11], MMU_ENTRY_LO[10], 
    MMU_ENTRY_LO[9], MMU_ENTRY_LO[8], MMU_ENTRY_LO[7], MMU_ENTRY_LO[6], 
    MMU_ENTRY_LO[5], MMU_ENTRY_LO[4], MMU_ENTRY_LO[3], MMU_ENTRY_LO[2], 
    MMU_ENTRY_LO[1], MMU_ENTRY_LO[0]}), .HIT(MMU_HIT), .HIT_BUT_NOT_VALID
    (X1N5060), .INDEX_IN({MMU_INDEX[5], MMU_INDEX[4], MMU_INDEX[3], 
    MMU_INDEX[2], MMU_INDEX[1], MMU_INDEX[0]}), .INDEX_OUT({MMU_INDEX_OUT[5]
    , MMU_INDEX_OUT[4], MMU_INDEX_OUT[3], MMU_INDEX_OUT[2], MMU_INDEX_OUT[1]
    , MMU_INDEX_OUT[0]}), .LOOK_UP(X1N4176), .NO_CACHE(MMU_DONT_CACHE), 
    .PFN({MMU_PFN[19], MMU_PFN[18], MMU_PFN[17], MMU_PFN[16], MMU_PFN[15], 
    MMU_PFN[14], MMU_PFN[13], MMU_PFN[12], MMU_PFN[11], MMU_PFN[10], 
    MMU_PFN[9], MMU_PFN[8], MMU_PFN[7], MMU_PFN[6], MMU_PFN[5], MMU_PFN[4], 
    MMU_PFN[3], MMU_PFN[2], MMU_PFN[1], MMU_PFN[0]}), .READ(X1N4177), 
    .VPN_INTO({MMU_VPN[19], MMU_VPN[18], MMU_VPN[17], MMU_VPN[16], 
    MMU_VPN[15], MMU_VPN[14], MMU_VPN[13], MMU_VPN[12], MMU_VPN[11], 
    MMU_VPN[10], MMU_VPN[9], MMU_VPN[8], MMU_VPN[7], MMU_VPN[6], MMU_VPN[5]
    , MMU_VPN[4], MMU_VPN[3], MMU_VPN[2], MMU_VPN[1], MMU_VPN[0]}), 
    .WRITE_IN(MMU_TLB_WRITE));
  BUFT32 X1I3867 (.I({CACHE_INSTRUCTION_PRE_DAT[31], 
    CACHE_INSTRUCTION_PRE_DAT[30], CACHE_INSTRUCTION_PRE_DAT[29], 
    CACHE_INSTRUCTION_PRE_DAT[28], CACHE_INSTRUCTION_PRE_DAT[27], 
    CACHE_INSTRUCTION_PRE_DAT[26], CACHE_INSTRUCTION_PRE_DAT[25], 
    CACHE_INSTRUCTION_PRE_DAT[24], CACHE_INSTRUCTION_PRE_DAT[23], 
    CACHE_INSTRUCTION_PRE_DAT[22], CACHE_INSTRUCTION_PRE_DAT[21], 
    CACHE_INSTRUCTION_PRE_DAT[20], CACHE_INSTRUCTION_PRE_DAT[19], 
    CACHE_INSTRUCTION_PRE_DAT[18], CACHE_INSTRUCTION_PRE_DAT[17], 
    CACHE_INSTRUCTION_PRE_DAT[16], CACHE_INSTRUCTION_PRE_DAT[15], 
    CACHE_INSTRUCTION_PRE_DAT[14], CACHE_INSTRUCTION_PRE_DAT[13], 
    CACHE_INSTRUCTION_PRE_DAT[12], CACHE_INSTRUCTION_PRE_DAT[11], 
    CACHE_INSTRUCTION_PRE_DAT[10], CACHE_INSTRUCTION_PRE_DAT[9], 
    CACHE_INSTRUCTION_PRE_DAT[8], CACHE_INSTRUCTION_PRE_DAT[7], 
    CACHE_INSTRUCTION_PRE_DAT[6], CACHE_INSTRUCTION_PRE_DAT[5], 
    CACHE_INSTRUCTION_PRE_DAT[4], CACHE_INSTRUCTION_PRE_DAT[3], 
    CACHE_INSTRUCTION_PRE_DAT[2], CACHE_INSTRUCTION_PRE_DAT[1], 
    CACHE_INSTRUCTION_PRE_DAT[0]}), .O({CACHE_INST_DAT[31], 
    CACHE_INST_DAT[30], CACHE_INST_DAT[29], CACHE_INST_DAT[28], 
    CACHE_INST_DAT[27], CACHE_INST_DAT[26], CACHE_INST_DAT[25], 
    CACHE_INST_DAT[24], CACHE_INST_DAT[23], CACHE_INST_DAT[22], 
    CACHE_INST_DAT[21], CACHE_INST_DAT[20], CACHE_INST_DAT[19], 
    CACHE_INST_DAT[18], CACHE_INST_DAT[17], CACHE_INST_DAT[16], 
    CACHE_INST_DAT[15], CACHE_INST_DAT[14], CACHE_INST_DAT[13], 
    CACHE_INST_DAT[12], CACHE_INST_DAT[11], CACHE_INST_DAT[10], 
    CACHE_INST_DAT[9], CACHE_INST_DAT[8], CACHE_INST_DAT[7], 
    CACHE_INST_DAT[6], CACHE_INST_DAT[5], CACHE_INST_DAT[4], 
    CACHE_INST_DAT[3], CACHE_INST_DAT[2], CACHE_INST_DAT[1], 
    CACHE_INST_DAT[0]}), .T(X1N4234));
  MUX2_1X32 X1I389 (.A({IMM[31], IMM[30], IMM[29], IMM[28], IMM[27], IMM[26]
    , IMM[25], IMM[24], IMM[23], IMM[22], IMM[21], IMM[20], IMM[19], IMM[18]
    , IMM[17], IMM[16], IMM[15], IMM[14], IMM[13], IMM[12], IMM[11], IMM[10]
    , IMM[9], IMM[8], IMM[7], IMM[6], IMM[5], IMM[4], IMM[3], IMM[2], IMM[1]
    , IMM[0]}), .B({REG_B_EXE_FF[31], REG_B_EXE_FF[30], REG_B_EXE_FF[29], 
    REG_B_EXE_FF[28], REG_B_EXE_FF[27], REG_B_EXE_FF[26], REG_B_EXE_FF[25], 
    REG_B_EXE_FF[24], REG_B_EXE_FF[23], REG_B_EXE_FF[22], REG_B_EXE_FF[21], 
    REG_B_EXE_FF[20], REG_B_EXE_FF[19], REG_B_EXE_FF[18], REG_B_EXE_FF[17], 
    REG_B_EXE_FF[16], REG_B_EXE_FF[15], REG_B_EXE_FF[14], REG_B_EXE_FF[13], 
    REG_B_EXE_FF[12], REG_B_EXE_FF[11], REG_B_EXE_FF[10], REG_B_EXE_FF[9], 
    REG_B_EXE_FF[8], REG_B_EXE_FF[7], REG_B_EXE_FF[6], REG_B_EXE_FF[5], 
    REG_B_EXE_FF[4], REG_B_EXE_FF[3], REG_B_EXE_FF[2], REG_B_EXE_FF[1], 
    REG_B_EXE_FF[0]}), .SB(SPECIAL_EXE), .S({B_EXE_INPUT[31], 
    B_EXE_INPUT[30], B_EXE_INPUT[29], B_EXE_INPUT[28], B_EXE_INPUT[27], 
    B_EXE_INPUT[26], B_EXE_INPUT[25], B_EXE_INPUT[24], B_EXE_INPUT[23], 
    B_EXE_INPUT[22], B_EXE_INPUT[21], B_EXE_INPUT[20], B_EXE_INPUT[19], 
    B_EXE_INPUT[18], B_EXE_INPUT[17], B_EXE_INPUT[16], B_EXE_INPUT[15], 
    B_EXE_INPUT[14], B_EXE_INPUT[13], B_EXE_INPUT[12], B_EXE_INPUT[11], 
    B_EXE_INPUT[10], B_EXE_INPUT[9], B_EXE_INPUT[8], B_EXE_INPUT[7], 
    B_EXE_INPUT[6], B_EXE_INPUT[5], B_EXE_INPUT[4], B_EXE_INPUT[3], 
    B_EXE_INPUT[2], B_EXE_INPUT[1], B_EXE_INPUT[0]}));
  REG32 X1I394 (.CLK(CLK1), .EN(GLB_EN), .I({REG_B_EXE_FF[31], 
    REG_B_EXE_FF[30], REG_B_EXE_FF[29], REG_B_EXE_FF[28], REG_B_EXE_FF[27], 
    REG_B_EXE_FF[26], REG_B_EXE_FF[25], REG_B_EXE_FF[24], REG_B_EXE_FF[23], 
    REG_B_EXE_FF[22], REG_B_EXE_FF[21], REG_B_EXE_FF[20], REG_B_EXE_FF[19], 
    REG_B_EXE_FF[18], REG_B_EXE_FF[17], REG_B_EXE_FF[16], REG_B_EXE_FF[15], 
    REG_B_EXE_FF[14], REG_B_EXE_FF[13], REG_B_EXE_FF[12], REG_B_EXE_FF[11], 
    REG_B_EXE_FF[10], REG_B_EXE_FF[9], REG_B_EXE_FF[8], REG_B_EXE_FF[7], 
    REG_B_EXE_FF[6], REG_B_EXE_FF[5], REG_B_EXE_FF[4], REG_B_EXE_FF[3], 
    REG_B_EXE_FF[2], REG_B_EXE_FF[1], REG_B_EXE_FF[0]}), .O({REG_B_MEM[31], 
    REG_B_MEM[30], REG_B_MEM[29], REG_B_MEM[28], REG_B_MEM[27], 
    REG_B_MEM[26], REG_B_MEM[25], REG_B_MEM[24], REG_B_MEM[23], 
    REG_B_MEM[22], REG_B_MEM[21], REG_B_MEM[20], REG_B_MEM[19], 
    REG_B_MEM[18], REG_B_MEM[17], REG_B_MEM[16], REG_B_MEM[15], 
    REG_B_MEM[14], REG_B_MEM[13], REG_B_MEM[12], REG_B_MEM[11], 
    REG_B_MEM[10], REG_B_MEM[9], REG_B_MEM[8], REG_B_MEM[7], REG_B_MEM[6], 
    REG_B_MEM[5], REG_B_MEM[4], REG_B_MEM[3], REG_B_MEM[2], REG_B_MEM[1], 
    REG_B_MEM[0]}));
  REG32 X1I4007 (.CLK(CLK1), .EN(X1N4042), .I({CP0_ENTRY_LO_NEXT[31], 
    CP0_ENTRY_LO_NEXT[30], CP0_ENTRY_LO_NEXT[29], CP0_ENTRY_LO_NEXT[28], 
    CP0_ENTRY_LO_NEXT[27], CP0_ENTRY_LO_NEXT[26], CP0_ENTRY_LO_NEXT[25], 
    CP0_ENTRY_LO_NEXT[24], CP0_ENTRY_LO_NEXT[23], CP0_ENTRY_LO_NEXT[22], 
    CP0_ENTRY_LO_NEXT[21], CP0_ENTRY_LO_NEXT[20], CP0_ENTRY_LO_NEXT[19], 
    CP0_ENTRY_LO_NEXT[18], CP0_ENTRY_LO_NEXT[17], CP0_ENTRY_LO_NEXT[16], 
    CP0_ENTRY_LO_NEXT[15], CP0_ENTRY_LO_NEXT[14], CP0_ENTRY_LO_NEXT[13], 
    CP0_ENTRY_LO_NEXT[12], CP0_ENTRY_LO_NEXT[11], CP0_ENTRY_LO_NEXT[10], 
    CP0_ENTRY_LO_NEXT[9], CP0_ENTRY_LO_NEXT[8], CP0_ENTRY_LO_NEXT[7], 
    CP0_ENTRY_LO_NEXT[6], CP0_ENTRY_LO_NEXT[5], CP0_ENTRY_LO_NEXT[4], 
    CP0_ENTRY_LO_NEXT[3], CP0_ENTRY_LO_NEXT[2], CP0_ENTRY_LO_NEXT[1], 
    CP0_ENTRY_LO_NEXT[0]}), .O({CP0_ENTRY_LO[31], CP0_ENTRY_LO[30], 
    CP0_ENTRY_LO[29], CP0_ENTRY_LO[28], CP0_ENTRY_LO[27], CP0_ENTRY_LO[26], 
    CP0_ENTRY_LO[25], CP0_ENTRY_LO[24], CP0_ENTRY_LO[23], CP0_ENTRY_LO[22], 
    CP0_ENTRY_LO[21], CP0_ENTRY_LO[20], CP0_ENTRY_LO[19], CP0_ENTRY_LO[18], 
    CP0_ENTRY_LO[17], CP0_ENTRY_LO[16], CP0_ENTRY_LO[15], CP0_ENTRY_LO[14], 
    CP0_ENTRY_LO[13], CP0_ENTRY_LO[12], CP0_ENTRY_LO[11], CP0_ENTRY_LO[10], 
    CP0_ENTRY_LO[9], CP0_ENTRY_LO[8], CP0_ENTRY_LO[7], CP0_ENTRY_LO[6], 
    CP0_ENTRY_LO[5], CP0_ENTRY_LO[4], CP0_ENTRY_LO[3], CP0_ENTRY_LO[2], 
    CP0_ENTRY_LO[1], CP0_ENTRY_LO[0]}));
  BUFE32 X1I4015 (.E(CPO_READ_ENTRY_LO), .I({CP0_ENTRY_LO[31], 
    CP0_ENTRY_LO[30], CP0_ENTRY_LO[29], CP0_ENTRY_LO[28], CP0_ENTRY_LO[27], 
    CP0_ENTRY_LO[26], CP0_ENTRY_LO[25], CP0_ENTRY_LO[24], CP0_ENTRY_LO[23], 
    CP0_ENTRY_LO[22], CP0_ENTRY_LO[21], CP0_ENTRY_LO[20], CP0_ENTRY_LO[19], 
    CP0_ENTRY_LO[18], CP0_ENTRY_LO[17], CP0_ENTRY_LO[16], CP0_ENTRY_LO[15], 
    CP0_ENTRY_LO[14], CP0_ENTRY_LO[13], CP0_ENTRY_LO[12], CP0_ENTRY_LO[11], 
    CP0_ENTRY_LO[10], CP0_ENTRY_LO[9], CP0_ENTRY_LO[8], CP0_ENTRY_LO[7], 
    CP0_ENTRY_LO[6], CP0_ENTRY_LO[5], CP0_ENTRY_LO[4], CP0_ENTRY_LO[3], 
    CP0_ENTRY_LO[2], CP0_ENTRY_LO[1], CP0_ENTRY_LO[0]}), .O({CACHE_DAT[31], 
    CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], 
    CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], 
    CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], 
    CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], 
    CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], 
    CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], 
    CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], 
    CACHE_DAT[0]}));
  MUX2_1X32 X1I4031 (.A({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], 
    CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], 
    CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], 
    CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], 
    CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], 
    CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8]
    , CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], 
    CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}), .B({MMU_ENTRY_HI[31], 
    MMU_ENTRY_HI[30], MMU_ENTRY_HI[29], MMU_ENTRY_HI[28], MMU_ENTRY_HI[27], 
    MMU_ENTRY_HI[26], MMU_ENTRY_HI[25], MMU_ENTRY_HI[24], MMU_ENTRY_HI[23], 
    MMU_ENTRY_HI[22], MMU_ENTRY_HI[21], MMU_ENTRY_HI[20], MMU_ENTRY_HI[19], 
    MMU_ENTRY_HI[18], MMU_ENTRY_HI[17], MMU_ENTRY_HI[16], MMU_ENTRY_HI[15], 
    MMU_ENTRY_HI[14], MMU_ENTRY_HI[13], MMU_ENTRY_HI[12], MMU_ENTRY_HI[11], 
    MMU_ENTRY_HI[10], MMU_ENTRY_HI[9], MMU_ENTRY_HI[8], MMU_ENTRY_HI[7], 
    MMU_ENTRY_HI[6], MMU_ENTRY_HI[5], MMU_ENTRY_HI[4], MMU_ENTRY_HI[3], 
    MMU_ENTRY_HI[2], MMU_ENTRY_HI[1], MMU_ENTRY_HI[0]}), .SB(X1N5287), .S({
    CP0_ENTRY_HI_NEXT[31], CP0_ENTRY_HI_NEXT[30], CP0_ENTRY_HI_NEXT[29], 
    CP0_ENTRY_HI_NEXT[28], CP0_ENTRY_HI_NEXT[27], CP0_ENTRY_HI_NEXT[26], 
    CP0_ENTRY_HI_NEXT[25], CP0_ENTRY_HI_NEXT[24], CP0_ENTRY_HI_NEXT[23], 
    CP0_ENTRY_HI_NEXT[22], CP0_ENTRY_HI_NEXT[21], CP0_ENTRY_HI_NEXT[20], 
    CP0_ENTRY_HI_NEXT[19], CP0_ENTRY_HI_NEXT[18], CP0_ENTRY_HI_NEXT[17], 
    CP0_ENTRY_HI_NEXT[16], CP0_ENTRY_HI_NEXT[15], CP0_ENTRY_HI_NEXT[14], 
    CP0_ENTRY_HI_NEXT[13], CP0_ENTRY_HI_NEXT[12], CP0_ENTRY_HI_NEXT[11], 
    CP0_ENTRY_HI_NEXT[10], CP0_ENTRY_HI_NEXT[9], CP0_ENTRY_HI_NEXT[8], 
    CP0_ENTRY_HI_NEXT[7], CP0_ENTRY_HI_NEXT[6], CP0_ENTRY_HI_NEXT[5], 
    CP0_ENTRY_HI_NEXT[4], CP0_ENTRY_HI_NEXT[3], CP0_ENTRY_HI_NEXT[2], 
    CP0_ENTRY_HI_NEXT[1], CP0_ENTRY_HI_NEXT[0]}));
  BUFE32 X1I4034 (.E(CPO_READ_ENTRY_HI), .I({CP0_ENTRY_HI[31], 
    CP0_ENTRY_HI[30], CP0_ENTRY_HI[29], CP0_ENTRY_HI[28], CP0_ENTRY_HI[27], 
    CP0_ENTRY_HI[26], CP0_ENTRY_HI[25], CP0_ENTRY_HI[24], CP0_ENTRY_HI[23], 
    CP0_ENTRY_HI[22], CP0_ENTRY_HI[21], CP0_ENTRY_HI[20], CP0_ENTRY_HI[19], 
    CP0_ENTRY_HI[18], CP0_ENTRY_HI[17], CP0_ENTRY_HI[16], CP0_ENTRY_HI[15], 
    CP0_ENTRY_HI[14], CP0_ENTRY_HI[13], CP0_ENTRY_HI[12], CP0_ENTRY_HI[11], 
    CP0_ENTRY_HI[10], CP0_ENTRY_HI[9], CP0_ENTRY_HI[8], CP0_ENTRY_HI[7], 
    CP0_ENTRY_HI[6], CP0_ENTRY_HI[5], CP0_ENTRY_HI[4], CP0_ENTRY_HI[3], 
    CP0_ENTRY_HI[2], CP0_ENTRY_HI[1], CP0_ENTRY_HI[0]}), .O({CACHE_DAT[31], 
    CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], 
    CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], 
    CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], 
    CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], 
    CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], 
    CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], 
    CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], 
    CACHE_DAT[0]}));
  OR2 X1I4041 (.I0(CPO_WRITE_ENTRY_LO), .I1(MMU_TLB_READ), .O(X1N4042));
  M2_1X6 X1I4058 (.A({MMU_INDEX_OUT[5], MMU_INDEX_OUT[4], MMU_INDEX_OUT[3], 
    MMU_INDEX_OUT[2], MMU_INDEX_OUT[1], MMU_INDEX_OUT[0]}), .B({
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8]}), .O({CP0_INDEX_NEXT[5], CP0_INDEX_NEXT[4], 
    CP0_INDEX_NEXT[3], CP0_INDEX_NEXT[2], CP0_INDEX_NEXT[1], 
    CP0_INDEX_NEXT[0]}), .SB(CPO_WRITTE_INDEX));
  OR2 X1I4066 (.I0(MMU_TLB_LOOK_UP), .I1(CPO_WRITTE_INDEX), .O(X1N4067));
  FDE X1I4069 (.C(CLK1), .CE(X1N4067), .D(X1N4072), .Q(INDEX31));
  M2_1 X1I4070 (.D0(MMU_HIT), .D1(CACHE_DAT[31]), .O(X1N4072), .S0
    (CPO_WRITTE_INDEX));
  REG20 X1I4089 (.CLK(CLK1), .EN(VCC), .I({MMU_PFN[19], MMU_PFN[18], 
    MMU_PFN[17], MMU_PFN[16], MMU_PFN[15], MMU_PFN[14], MMU_PFN[13], 
    MMU_PFN[12], MMU_PFN[11], MMU_PFN[10], MMU_PFN[9], MMU_PFN[8], 
    MMU_PFN[7], MMU_PFN[6], MMU_PFN[5], MMU_PFN[4], MMU_PFN[3], MMU_PFN[2], 
    MMU_PFN[1], MMU_PFN[0]}), .O({INST_PFN[19], INST_PFN[18], INST_PFN[17], 
    INST_PFN[16], INST_PFN[15], INST_PFN[14], INST_PFN[13], INST_PFN[12], 
    INST_PFN[11], INST_PFN[10], INST_PFN[9], INST_PFN[8], INST_PFN[7], 
    INST_PFN[6], INST_PFN[5], INST_PFN[4], INST_PFN[3], INST_PFN[2], 
    INST_PFN[1], INST_PFN[0]}));
  M2_1X20 X1I4090 (.A({EXE_FF[31], EXE_FF[30], EXE_FF[29], EXE_FF[28], 
    EXE_FF[27], EXE_FF[26], EXE_FF[25], EXE_FF[24], EXE_FF[23], EXE_FF[22], 
    EXE_FF[21], EXE_FF[20], EXE_FF[19], EXE_FF[18], EXE_FF[17], EXE_FF[16], 
    EXE_FF[15], EXE_FF[14], EXE_FF[13], EXE_FF[12]}), .B({PC[31], PC[30], 
    PC[29], PC[28], PC[27], PC[26], PC[25], PC[24], PC[23], PC[22], PC[21], 
    PC[20], PC[19], PC[18], PC[17], PC[16], PC[15], PC[14], PC[13], PC[12]})
    , .SB(X1N4112), .S({MMU_VPN[19], MMU_VPN[18], MMU_VPN[17], MMU_VPN[16], 
    MMU_VPN[15], MMU_VPN[14], MMU_VPN[13], MMU_VPN[12], MMU_VPN[11], 
    MMU_VPN[10], MMU_VPN[9], MMU_VPN[8], MMU_VPN[7], MMU_VPN[6], MMU_VPN[5]
    , MMU_VPN[4], MMU_VPN[3], MMU_VPN[2], MMU_VPN[1], MMU_VPN[0]}));
  REG20 X1I4094 (.CLK(CLK2), .EN(GLB_EN), .I({MMU_PFN[19], MMU_PFN[18], 
    MMU_PFN[17], MMU_PFN[16], MMU_PFN[15], MMU_PFN[14], MMU_PFN[13], 
    MMU_PFN[12], MMU_PFN[11], MMU_PFN[10], MMU_PFN[9], MMU_PFN[8], 
    MMU_PFN[7], MMU_PFN[6], MMU_PFN[5], MMU_PFN[4], MMU_PFN[3], MMU_PFN[2], 
    MMU_PFN[1], MMU_PFN[0]}), .O({DATA_PFN[19], DATA_PFN[18], DATA_PFN[17], 
    DATA_PFN[16], DATA_PFN[15], DATA_PFN[14], DATA_PFN[13], DATA_PFN[12], 
    DATA_PFN[11], DATA_PFN[10], DATA_PFN[9], DATA_PFN[8], DATA_PFN[7], 
    DATA_PFN[6], DATA_PFN[5], DATA_PFN[4], DATA_PFN[3], DATA_PFN[2], 
    DATA_PFN[1], DATA_PFN[0]}));
  M2_1X6 X1I4128 (.A({INDEX[13], INDEX[12], INDEX[11], INDEX[10], INDEX[9], 
    INDEX[8]}), .B({RANDOM[13], RANDOM[12], RANDOM[11], RANDOM[10], 
    RANDOM[9], RANDOM[8]}), .O({MMU_INDEX[5], MMU_INDEX[4], MMU_INDEX[3], 
    MMU_INDEX[2], MMU_INDEX[1], MMU_INDEX[0]}), .SB(MMU_TLB_WRITE_RANDOM));
  OR2B1 X1I4141 (.I0(X1N4148), .I1(FLUSH), .O(X1N4142));
  AND3B1 X1I4144 (.I0(INSTRUCTION[31]), .I1(INSTRUCTION[25]), .I2
    (SELECT_CPO), .O(X1N4148));
  BUF X1I4151 (.I(CP0_INSTRUCTION[0]), .O(MMU_TLB_READ));
  BUF X1I4152 (.I(CP0_INSTRUCTION[3]), .O(MMU_TLB_LOOK_UP));
  BUF X1I4153 (.I(CP0_INSTRUCTION[1]), .O(MMU_TLB_WRITE));
  BUF X1I4159 (.I(CP0_INSTRUCTION[2]), .O(MMU_TLB_WRITE_RANDOM));
  BUF X1I4164 (.I(CP0_INSTRUCTION[4]), .O(CP0_RETURN_FROM_EXCEPTION));
  AND2B1 X1I4175 (.I0(X1N4112), .I1(MMU_TLB_LOOK_UP), .O(X1N4176));
  AND2B1 X1I4178 (.I0(X1N4112), .I1(MMU_TLB_READ), .O(X1N4177));
  INC32 X1I426 (.A({PC[31], PC[30], PC[29], PC[28], PC[27], PC[26], PC[25], 
    PC[24], PC[23], PC[22], PC[21], PC[20], PC[19], PC[18], PC[17], PC[16], 
    PC[15], PC[14], PC[13], PC[12], PC[11], PC[10], PC[9], PC[8], PC[7], 
    PC[6], PC[5], PC[4], PC[3], PC[2], PC[1], PC[0]}), .S({PC_PLUS_FOUR[31]
    , PC_PLUS_FOUR[30], PC_PLUS_FOUR[29], PC_PLUS_FOUR[28], PC_PLUS_FOUR[27]
    , PC_PLUS_FOUR[26], PC_PLUS_FOUR[25], PC_PLUS_FOUR[24], PC_PLUS_FOUR[23]
    , PC_PLUS_FOUR[22], PC_PLUS_FOUR[21], PC_PLUS_FOUR[20], PC_PLUS_FOUR[19]
    , PC_PLUS_FOUR[18], PC_PLUS_FOUR[17], PC_PLUS_FOUR[16], PC_PLUS_FOUR[15]
    , PC_PLUS_FOUR[14], PC_PLUS_FOUR[13], PC_PLUS_FOUR[12], PC_PLUS_FOUR[11]
    , PC_PLUS_FOUR[10], PC_PLUS_FOUR[9], PC_PLUS_FOUR[8], PC_PLUS_FOUR[7], 
    PC_PLUS_FOUR[6], PC_PLUS_FOUR[5], PC_PLUS_FOUR[4], PC_PLUS_FOUR[3], 
    PC_PLUS_FOUR[2], PC_PLUS_FOUR[1], PC_PLUS_FOUR[0]}));
  MEM_DELAY X1I4311 (.C(CLK1), .D(MEM_WRITE), .Q(END_WRITE), .R(X1N3757));
  MEM_DELAY X1I4319 (.C(CLK1), .D(DATA_MEM_ACCESS), .Q(X1N3837), .R(X1N3757)
    );
  MEM_DELAY X1I4322 (.C(CLK2), .D(INST_MEM_ACCESS), .Q(X1N4234), .R
    (X1N4234));
  GND X1I4333 (.G(HALT2));
  GND X1I4335 (.G(HALT3));
  BUTTONS X1I4339 (.CLK(X1N2274), .SW1(SW1), .SW2(SW2), .SW3(RESET_IN));
  INV X1I4354 (.I(X1N3744), .O(GLB_EN));
  REG32 X1I4360 (.CLK(CLK1), .EN(INTERRUPT_MEM), .I({MEM_PC[31], MEM_PC[30]
    , MEM_PC[29], MEM_PC[28], MEM_PC[27], MEM_PC[26], MEM_PC[25], MEM_PC[24]
    , MEM_PC[23], MEM_PC[22], MEM_PC[21], MEM_PC[20], MEM_PC[19], MEM_PC[18]
    , MEM_PC[17], MEM_PC[16], MEM_PC[15], MEM_PC[14], MEM_PC[13], MEM_PC[12]
    , MEM_PC[11], MEM_PC[10], MEM_PC[9], MEM_PC[8], MEM_PC[7], MEM_PC[6], 
    MEM_PC[5], MEM_PC[4], MEM_PC[3], MEM_PC[2], MEM_PC[1], MEM_PC[0]}), .O({
    EPC[31], EPC[30], EPC[29], EPC[28], EPC[27], EPC[26], EPC[25], EPC[24], 
    EPC[23], EPC[22], EPC[21], EPC[20], EPC[19], EPC[18], EPC[17], EPC[16], 
    EPC[15], EPC[14], EPC[13], EPC[12], EPC[11], EPC[10], EPC[9], EPC[8], 
    EPC[7], EPC[6], EPC[5], EPC[4], EPC[3], EPC[2], EPC[1], EPC[0]}));
  FDE X1I4380 (.C(CLK2), .CE(GLB_EN), .D(MMU_DONT_CACHE), .Q
    (MMU_DONT_CACHE_DATA));
  FDE X1I4388 (.C(CLK2), .CE(GLB_EN), .D(MMU_DIRTY), .Q(MMU_DIRTY_DATA));
  FDE X1I4393 (.C(CLK2), .CE(GLB_EN), .D(MMU_HIT), .Q(MMU_HIT_DATA));
  FDE X1I4400 (.C(CLK1), .CE(GLB_EN), .D(MMU_HIT), .Q(MMU_HIT_INSTR));
  FDE X1I4407 (.C(CLK1), .CE(GLB_EN), .D(MMU_DONT_CACHE), .Q
    (MMU_DONT_CACHE_INTR));
  INV X1I4414 (.I(MMU_HIT_INSTR), .O(INT_FETCH_TLBL));
  OR2B1 X1I4416 (.I0(INST_CACHE_HIT), .I1(MMU_DONT_CACHE_INTR), .O(X1N4422)
    );
  AND2B1 X1I4426 (.I0(MMU_DONT_CACHE_INTR), .I1(X1N4234), .O(X1N5076));
  AND2B1 X1I4430 (.I0(MMU_DONT_CACHE_DATA), .I1(X1N4431), .O(DATA_CACHE_HIT)
    );
  OR3 X1I4432 (.I0(PC[0]), .I1(PC[1]), .I2(X1N5947), .O(INT_FETCH_ADEL)
    );
  MUX3_1X32 X1I444 (.A({REG_A_EXE[31], REG_A_EXE[30], REG_A_EXE[29], 
    REG_A_EXE[28], REG_A_EXE[27], REG_A_EXE[26], REG_A_EXE[25], 
    REG_A_EXE[24], REG_A_EXE[23], REG_A_EXE[22], REG_A_EXE[21], 
    REG_A_EXE[20], REG_A_EXE[19], REG_A_EXE[18], REG_A_EXE[17], 
    REG_A_EXE[16], REG_A_EXE[15], REG_A_EXE[14], REG_A_EXE[13], 
    REG_A_EXE[12], REG_A_EXE[11], REG_A_EXE[10], REG_A_EXE[9], REG_A_EXE[8]
    , REG_A_EXE[7], REG_A_EXE[6], REG_A_EXE[5], REG_A_EXE[4], REG_A_EXE[3], 
    REG_A_EXE[2], REG_A_EXE[1], REG_A_EXE[0]}), .B({SEL_PORT_A_MEM, 
    MEM_FF[31], MEM_FF[30], MEM_FF[29], MEM_FF[28], MEM_FF[27], MEM_FF[26], 
    MEM_FF[25], MEM_FF[24], MEM_FF[23], MEM_FF[22], MEM_FF[21], MEM_FF[20], 
    MEM_FF[19], MEM_FF[18], MEM_FF[17], MEM_FF[16], MEM_FF[15], MEM_FF[14], 
    MEM_FF[13], MEM_FF[12], MEM_FF[11], MEM_FF[10], MEM_FF[9], MEM_FF[8], 
    MEM_FF[7], MEM_FF[6], MEM_FF[5], MEM_FF[4], MEM_FF[3], MEM_FF[2], 
    MEM_FF[1], MEM_FF[0]}), .C({SEL_PORT_A_ALU, EXE_FF[31], EXE_FF[30], 
    EXE_FF[29], EXE_FF[28], EXE_FF[27], EXE_FF[26], EXE_FF[25], EXE_FF[24], 
    EXE_FF[23], EXE_FF[22], EXE_FF[21], EXE_FF[20], EXE_FF[19], EXE_FF[18], 
    EXE_FF[17], EXE_FF[16], EXE_FF[15], EXE_FF[14], EXE_FF[13], EXE_FF[12], 
    EXE_FF[11], EXE_FF[10], EXE_FF[9], EXE_FF[8], EXE_FF[7], EXE_FF[6], 
    EXE_FF[5], EXE_FF[4], EXE_FF[3], EXE_FF[2], EXE_FF[1], EXE_FF[0]}), .S({
    REG_A_EXE_FF[31], REG_A_EXE_FF[30], REG_A_EXE_FF[29], REG_A_EXE_FF[28], 
    REG_A_EXE_FF[27], REG_A_EXE_FF[26], REG_A_EXE_FF[25], REG_A_EXE_FF[24], 
    REG_A_EXE_FF[23], REG_A_EXE_FF[22], REG_A_EXE_FF[21], REG_A_EXE_FF[20], 
    REG_A_EXE_FF[19], REG_A_EXE_FF[18], REG_A_EXE_FF[17], REG_A_EXE_FF[16], 
    REG_A_EXE_FF[15], REG_A_EXE_FF[14], REG_A_EXE_FF[13], REG_A_EXE_FF[12], 
    REG_A_EXE_FF[11], REG_A_EXE_FF[10], REG_A_EXE_FF[9], REG_A_EXE_FF[8], 
    REG_A_EXE_FF[7], REG_A_EXE_FF[6], REG_A_EXE_FF[5], REG_A_EXE_FF[4], 
    REG_A_EXE_FF[3], REG_A_EXE_FF[2], REG_A_EXE_FF[1], REG_A_EXE_FF[0]}));
  FDRE X1I4445 (.C(CLK2), .CE(GLB_EN), .D(INT_FETCH_ADEL), .Q(INT_DEC_ADEL)
    , .R(FLUSH));
  FDRE X1I4450 (.C(CLK2), .CE(GLB_EN), .D(INT_FETCH_TLBL), .Q(INT_DEC_TLBL)
    , .R(FLUSH));
  AND4B1 X1I4491 (.I0(FLUSH), .I1(MEM_WRITE_SOON), .I2(X1N5147), .I3
    (X1N5616), .O(X1N3834));
  FDE X1I4505 (.C(CLK1), .CE(GLB_EN), .D(INTERRUPT_MEM), .Q(INTERRUPT));
  GND16 X1I4538 (.G({GND[15], GND[14], GND[13], GND[12], GND[11], GND[10], 
    GND[9], GND[8], GND[7], GND[6], GND[5], GND[4], GND[3], GND[2], GND[1], 
    GND[0]}));
  GND16 X1I4541 (.G({GND[31], GND[30], GND[29], GND[28], GND[27], GND[26], 
    GND[25], GND[24], GND[23], GND[22], GND[21], GND[20], GND[19], GND[18], 
    GND[17], GND[16]}));
  BUFE32 X1I4607 (.E(CPO_READ_BADVADDR), .I({CPO_BADVADDR[31], 
    CPO_BADVADDR[30], CPO_BADVADDR[29], CPO_BADVADDR[28], CPO_BADVADDR[27], 
    CPO_BADVADDR[26], CPO_BADVADDR[25], CPO_BADVADDR[24], CPO_BADVADDR[23], 
    CPO_BADVADDR[22], CPO_BADVADDR[21], CPO_BADVADDR[20], CPO_BADVADDR[19], 
    CPO_BADVADDR[18], CPO_BADVADDR[17], CPO_BADVADDR[16], CPO_BADVADDR[15], 
    CPO_BADVADDR[14], CPO_BADVADDR[13], CPO_BADVADDR[12], CPO_BADVADDR[11], 
    CPO_BADVADDR[10], CPO_BADVADDR[9], CPO_BADVADDR[8], CPO_BADVADDR[7], 
    CPO_BADVADDR[6], CPO_BADVADDR[5], CPO_BADVADDR[4], CPO_BADVADDR[3], 
    CPO_BADVADDR[2], CPO_BADVADDR[1], CPO_BADVADDR[0]}), .O({CACHE_DAT[31], 
    CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], 
    CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], 
    CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], 
    CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], 
    CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], 
    CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], 
    CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], 
    CACHE_DAT[0]}));
  REG32 X1I4610 (.CLK(CLK1), .EN(V_ADDRESS_ERROR), .I({EXE_FF[31], 
    EXE_FF[30], EXE_FF[29], EXE_FF[28], EXE_FF[27], EXE_FF[26], EXE_FF[25], 
    EXE_FF[24], EXE_FF[23], EXE_FF[22], EXE_FF[21], EXE_FF[20], EXE_FF[19], 
    EXE_FF[18], EXE_FF[17], EXE_FF[16], EXE_FF[15], EXE_FF[14], EXE_FF[13], 
    EXE_FF[12], EXE_FF[11], EXE_FF[10], EXE_FF[9], EXE_FF[8], EXE_FF[7], 
    EXE_FF[6], EXE_FF[5], EXE_FF[4], EXE_FF[3], EXE_FF[2], EXE_FF[1], 
    EXE_FF[0]}), .O({CPO_BADVADDR[31], CPO_BADVADDR[30], CPO_BADVADDR[29], 
    CPO_BADVADDR[28], CPO_BADVADDR[27], CPO_BADVADDR[26], CPO_BADVADDR[25], 
    CPO_BADVADDR[24], CPO_BADVADDR[23], CPO_BADVADDR[22], CPO_BADVADDR[21], 
    CPO_BADVADDR[20], CPO_BADVADDR[19], CPO_BADVADDR[18], CPO_BADVADDR[17], 
    CPO_BADVADDR[16], CPO_BADVADDR[15], CPO_BADVADDR[14], CPO_BADVADDR[13], 
    CPO_BADVADDR[12], CPO_BADVADDR[11], CPO_BADVADDR[10], CPO_BADVADDR[9], 
    CPO_BADVADDR[8], CPO_BADVADDR[7], CPO_BADVADDR[6], CPO_BADVADDR[5], 
    CPO_BADVADDR[4], CPO_BADVADDR[3], CPO_BADVADDR[2], CPO_BADVADDR[1], 
    CPO_BADVADDR[0]}));
  REG6 X1I4670 (.CLK(CLK1), .EN(CPO_WRITE_CONTEXT), .I({CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21]}), .O({CPO_CONTEXT[26], CPO_CONTEXT[25], CPO_CONTEXT[24], 
    CPO_CONTEXT[23], CPO_CONTEXT[22], CPO_CONTEXT[21]}), .RES(X1N4672));
  GND X1I4671 (.G(X1N4672));
  REG5 X1I4673 (.CLK(CLK1), .EN(CPO_WRITE_CONTEXT), .I({CACHE_DAT[31], 
    CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27]}), .O({
    CPO_CONTEXT[31], CPO_CONTEXT[30], CPO_CONTEXT[29], CPO_CONTEXT[28], 
    CPO_CONTEXT[27]}), .RES(X1N4672));
  BUFE32 X1I4684 (.E(CPO_READ_CONTEXT), .I({CPO_CONTEXT[31], CPO_CONTEXT[30]
    , CPO_CONTEXT[29], CPO_CONTEXT[28], CPO_CONTEXT[27], CPO_CONTEXT[26], 
    CPO_CONTEXT[25], CPO_CONTEXT[24], CPO_CONTEXT[23], CPO_CONTEXT[22], 
    CPO_CONTEXT[21], CPO_BADVADDR[30], CPO_BADVADDR[29], CPO_BADVADDR[28], 
    CPO_BADVADDR[27], CPO_BADVADDR[26], CPO_BADVADDR[25], CPO_BADVADDR[24], 
    CPO_BADVADDR[23], CPO_BADVADDR[22], CPO_BADVADDR[21], CPO_BADVADDR[20], 
    CPO_BADVADDR[19], CPO_BADVADDR[18], CPO_BADVADDR[17], CPO_BADVADDR[16], 
    CPO_BADVADDR[15], CPO_BADVADDR[14], CPO_BADVADDR[13], CPO_BADVADDR[12], 
    GND[1], GND[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], 
    CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], 
    CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], 
    CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], 
    CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], 
    CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8]
    , CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], 
    CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  VCC X1I4698 (.P(VCC));
  AND3 X1I4712 (.I0(INSTRUCTION[3]), .I1(INSTRUCTION[2]), .I2(SPECIAL), .O
    (X1N4777));
  INT_VAL X1I4725 (.D0(GND), .D1(GND), .D2(INT_DEC_ADEL), .D3(GND), .D4(GND)
    , .I0(GND), .I1(VCC), .I2(GND), .I3(GND), .I4(GND), .INT(GND), .Q0
    (X1N4768), .Q1(X1N4769), .Q2(X1N4770), .Q3(X1N4771), .Q4(X1N4772), 
    .VALID_IN(INT_DEC_ADEL), .VALID_OUT(X1N4767));
  INT_VAL X1I4760 (.D0(X1N4768), .D1(X1N4769), .D2(X1N4770), .D3(X1N4771), 
    .D4(X1N4772), .I0(INSTRUCTION[0]), .I1(GND), .I2(GND), .I3(VCC), .I4
    (GND), .INT(X1N4777), .Q0(INT_DEC[0]), .Q1(INT_DEC[1]), .Q2(INT_DEC[2])
    , .Q3(INT_DEC[3]), .Q4(INT_DEC[4]), .VALID_IN(X1N4767), .VALID_OUT
    (INT_DEC[5]));
  REG6 X1I4783 (.CLK(CLK1), .EN(GLB_EN), .I({INT_DEC[5], INT_DEC[4], 
    INT_DEC[3], INT_DEC[2], INT_DEC[1], INT_DEC[0]}), .O({INT_EXE[5], 
    INT_EXE[4], INT_EXE[3], INT_EXE[2], INT_EXE[1], INT_EXE[0]}), .RES
    (FLUSH));
  INT_VAL X1I4789 (.D0(INT_EXE[0]), .D1(INT_EXE[1]), .D2(INT_EXE[2]), .D3
    (INT_EXE[3]), .D4(INT_EXE[4]), .I0(GND), .I1(GND), .I2(VCC), .I3(VCC), 
    .I4(GND), .INT(OVERFLOW), .Q0(INT_EXE_OUT[0]), .Q1(INT_EXE_OUT[1]), .Q2
    (INT_EXE_OUT[2]), .Q3(INT_EXE_OUT[3]), .Q4(INT_EXE_OUT[4]), .VALID_IN
    (INT_EXE[5]), .VALID_OUT(INT_EXE_OUT[5]));
  REG6 X1I4795 (.CLK(CLK1), .EN(GLB_EN), .I({INT_EXE_OUT[5], INT_EXE_OUT[4]
    , INT_EXE_OUT[3], INT_EXE_OUT[2], INT_EXE_OUT[1], INT_EXE_OUT[0]}), .O({
    INT_MEM_IN[5], INT_MEM_IN[4], INT_MEM_IN[3], INT_MEM_IN[2], 
    INT_MEM_IN[1], INT_MEM_IN[0]}), .RES(FLUSH));
  INT_VAL X1I4837 (.D0(INT_MEM_IN[0]), .D1(INT_MEM_IN[1]), .D2
    (INT_MEM_IN[2]), .D3(INT_MEM_IN[3]), .D4(INT_MEM_IN[4]), .I0(VCC), .I1
    (VCC), .I2(GND), .I3(VCC), .I4(GND), .INT(INT_COPROCESSOR_UNUSABLE), .Q0
    (X1N4853), .Q1(X1N4830), .Q2(X1N4831), .Q3(X1N4832), .Q4(X1N4833), 
    .VALID_IN(INT_MEM_IN[5]), .VALID_OUT(X1N4829));
  INT_VAL X1I4838 (.D0(X1N4853), .D1(X1N4830), .D2(X1N4831), .D3(X1N4832), 
    .D4(X1N4833), .I0(MEM_WRITE_SOON), .I1(GND), .I2(VCC), .I3(GND), .I4
    (GND), .INT(GND), .Q0(X1N4821), .Q1(X1N4856), .Q2(X1N4820), .Q3(X1N4819)
    , .Q4(X1N4818), .VALID_IN(X1N4829), .VALID_OUT(X1N4822));
  INT_VAL X1I4839 (.D0(X1N4821), .D1(X1N4856), .D2(X1N4820), .D3(X1N4819), 
    .D4(X1N4818), .I0(MEM_WRITE_SOON), .I1(VCC), .I2(GND), .I3(GND), .I4
    (GND), .INT(GND), .Q0(X1N4809), .Q1(X1N4810), .Q2(X1N4811), .Q3(X1N4812)
    , .Q4(X1N4813), .VALID_IN(X1N4822), .VALID_OUT(X1N4808));
  INT_VAL X1I4855 (.D0(X1N4809), .D1(X1N4810), .D2(X1N4811), .D3(X1N4812), 
    .D4(X1N4813), .I0(VCC), .I1(GND), .I2(GND), .I3(GND), .I4(GND), .INT
    (GND), .Q0(X1N4867), .Q1(X1N4866), .Q2(X1N4865), .Q3(X1N4864), .Q4
    (X1N4863), .VALID_IN(X1N4808), .VALID_OUT(X1N4868));
  INT_VAL X1I4870 (.D0(X1N4867), .D1(X1N4866), .D2(X1N4865), .D3(X1N4864), 
    .D4(X1N4863), .I0(GND), .I1(GND), .I2(GND), .I3(GND), .I4(GND), .INT
    (EXT_INTERRUPT), .Q0(EXC_CODE[0]), .Q1(EXC_CODE[1]), .Q2(EXC_CODE[2]), 
    .Q3(EXC_CODE[3]), .Q4(EXC_CODE[4]), .VALID_IN(X1N4868), .VALID_OUT
    (X1N6323));
  AND2B1 X1I4881 (.I0(MMU_HIT_DATA), .I1(CACHE), .O(X1N4884));
  AND2B1 X1I4888 (.I0(MMU_DIRTY_DATA), .I1(MEM_WRITE_SOON), .O(X1N4891));
  AND2B1 X1I4893 (.I0(STATUS28), .I1(STATUS1), .O(X1N5268));
  INV X1I4894 (.I(STATUS29), .O(X1N4895));
  INV X1I4896 (.I(STATUS30), .O(X1N4903));
  REG5 X1I4900 (.CLK(CLK1), .EN(GLB_EN), .I({RANDON_STATS[4], 
    RANDON_STATS[3], RANDON_STATS[2], RANDON_STATS[1], RANDON_STATS[0]}), 
    .O({MEM_CP_ACCESS, MEM_CP_NO1, MEM_CP_NO0, MEM_BRANCH, INT_INST_ERROR})
    , .RES(FLUSH));
  BUFE32 X1I4905 (.E(CP0_READ_STATUS), .I({STATUS31, STATUS30, STATUS29, 
    STATUS28, GND[27], GND[26], GND[25], GND[24], GND[23], STATUS22, GND[21]
    , GND[20], GND[19], GND[18], GND[17], GND[16], STATUS[15], STATUS[14], 
    STATUS[13], STATUS[12], STATUS[11], STATUS[10], STATUS[9], STATUS[8], 
    GND[7], GND[6], STATUS5, STATUS4, STATUS3, STATUS2, STATUS1, STATUS0}), 
    .O({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], 
    CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], 
    CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], 
    CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], 
    CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], 
    CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], 
    CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], 
    CACHE_DAT[1], CACHE_DAT[0]}));
  AND2 X1I4926 (.I0(STATUS[9]), .I1(CPO_CAUSE[9]), .O(X1N4909));
  AND2 X1I4927 (.I0(STATUS[8]), .I1(CPO_CAUSE[8]), .O(X1N4910));
  AND2 X1I4928 (.I0(STATUS[10]), .I1(CPO_CAUSE[10]), .O(X1N4908));
  AND2 X1I4929 (.I0(STATUS[11]), .I1(CPO_CAUSE[11]), .O(X1N5407));
  REG16 X1I493 (.CLK(CLK1), .EN(GLB_EN), .I({INSTRUCTION[15], 
    INSTRUCTION[14], INSTRUCTION[13], INSTRUCTION[12], INSTRUCTION[11], 
    INSTRUCTION[10], INSTRUCTION[9], INSTRUCTION[8], INSTRUCTION[7], 
    INSTRUCTION[6], INSTRUCTION[5], INSTRUCTION[4], INSTRUCTION[3], 
    INSTRUCTION[2], INSTRUCTION[1], INSTRUCTION[0]}), .O({EXE_IMM[15], 
    EXE_IMM[14], EXE_IMM[13], EXE_IMM[12], EXE_IMM[11], EXE_IMM[10], 
    EXE_IMM[9], EXE_IMM[8], EXE_IMM[7], EXE_IMM[6], EXE_IMM[5], EXE_IMM[4], 
    EXE_IMM[3], EXE_IMM[2], EXE_IMM[1], EXE_IMM[0]}));
  AND2 X1I4930 (.I0(STATUS[15]), .I1(CPO_CAUSE[15]), .O(X1N4992));
  AND2 X1I4931 (.I0(STATUS[14]), .I1(CPO_CAUSE[14]), .O(X1N4990));
  AND2 X1I4932 (.I0(STATUS[12]), .I1(CPO_CAUSE[12]), .O(X1N4986));
  SIGN_EX X1I494 (.D({EXE_IMM[15], EXE_IMM[14], EXE_IMM[13], EXE_IMM[12], 
    EXE_IMM[11], EXE_IMM[10], EXE_IMM[9], EXE_IMM[8], EXE_IMM[7], EXE_IMM[6]
    , EXE_IMM[5], EXE_IMM[4], EXE_IMM[3], EXE_IMM[2], EXE_IMM[1], EXE_IMM[0]
    }), .EX_ZERO(OP[2]), .O({IMM[31], IMM[30], IMM[29], IMM[28], IMM[27], 
    IMM[26], IMM[25], IMM[24], IMM[23], IMM[22], IMM[21], IMM[20], IMM[19], 
    IMM[18], IMM[17], IMM[16], IMM[15], IMM[14], IMM[13], IMM[12], IMM[11], 
    IMM[10], IMM[9], IMM[8], IMM[7], IMM[6], IMM[5], IMM[4], IMM[3], IMM[2]
    , IMM[1], IMM[0]}));
  FDE X1I4948 (.C(CLK1), .CE(INT_COPROCESSOR_UNUSABLE), .D(MEM_CP_NO1), .Q
    (CPO_CAUSE29));
  REG5 X1I4954 (.CLK(CLK1), .EN(INTERRUPT_MEM), .I({EXC_CODE[4], EXC_CODE[3]
    , EXC_CODE[2], EXC_CODE[1], EXC_CODE[0]}), .O({CPO_CAUSE[6], 
    CPO_CAUSE[5], CPO_CAUSE[4], CPO_CAUSE[3], CPO_CAUSE[2]}), .RES(GND));
  FDE X1I4961 (.C(CLK1), .CE(CP0_WRITE_CAUSE), .D(CACHE_DAT[9]), .Q
    (CPO_CAUSE[9]));
  FDE X1I4962 (.C(CLK1), .CE(CP0_WRITE_CAUSE), .D(CACHE_DAT[8]), .Q
    (CPO_CAUSE[8]));
  AND2 X1I4968 (.I0(STATUS[13]), .I1(CPO_CAUSE[13]), .O(X1N4988));
  REG6 X1I4977 (.CLK(CLK1), .EN(VCC), .I({EXTERNAL_INTERRUPT1, 
    SERIAL_REQUEST, COUNTER_ZERO, GND[2], GND[1], GND[0]}), .O({
    CPO_CAUSE[15], CPO_CAUSE[14], CPO_CAUSE[13], CPO_CAUSE[12], 
    CPO_CAUSE[11], CPO_CAUSE[10]}), .RES(GND));
  SIGN_EX_SHIFT2 X1I498 (.D({INSTRUCTION[25], INSTRUCTION[24], 
    INSTRUCTION[23], INSTRUCTION[22], INSTRUCTION[21], INSTRUCTION[20], 
    INSTRUCTION[19], INSTRUCTION[18], INSTRUCTION[17], INSTRUCTION[16], 
    INSTRUCTION[15], INSTRUCTION[14], INSTRUCTION[13], INSTRUCTION[12], 
    INSTRUCTION[11], INSTRUCTION[10], INSTRUCTION[9], INSTRUCTION[8], 
    INSTRUCTION[7], INSTRUCTION[6], INSTRUCTION[5], INSTRUCTION[4], 
    INSTRUCTION[3], INSTRUCTION[2], INSTRUCTION[1], INSTRUCTION[0]}), .JL
    (JUMPLONG), .O({PC_BR_IMM[31], PC_BR_IMM[30], PC_BR_IMM[29], 
    PC_BR_IMM[28], PC_BR_IMM[27], PC_BR_IMM[26], PC_BR_IMM[25], 
    PC_BR_IMM[24], PC_BR_IMM[23], PC_BR_IMM[22], PC_BR_IMM[21], 
    PC_BR_IMM[20], PC_BR_IMM[19], PC_BR_IMM[18], PC_BR_IMM[17], 
    PC_BR_IMM[16], PC_BR_IMM[15], PC_BR_IMM[14], PC_BR_IMM[13], 
    PC_BR_IMM[12], PC_BR_IMM[11], PC_BR_IMM[10], PC_BR_IMM[9], PC_BR_IMM[8]
    , PC_BR_IMM[7], PC_BR_IMM[6], PC_BR_IMM[5], PC_BR_IMM[4], PC_BR_IMM[3], 
    PC_BR_IMM[2], PC_BR_IMM[1], PC_BR_IMM[0]}));
  FDE X1I4994 (.C(CLK1), .CE(INT_COPROCESSOR_UNUSABLE), .D(MEM_CP_NO0), .Q
    (CPO_CAUSE28));
  FDE X1I5000 (.C(CLK1), .CE(INTERRUPT_MEM), .D(MEM_BRANCH), .Q(CPO_CAUSE31)
    );
  REG5 X1I5011 (.CLK(CLK1), .EN(GLB_EN), .I({INSTRUCTION[30], 
    INSTRUCTION[27], INSTRUCTION[26], BRANCH, INST_ADDR_ERROR}), .O({
    RANDON_STATS[4], RANDON_STATS[3], RANDON_STATS[2], RANDON_STATS[1], 
    RANDON_STATS[0]}), .RES(FLUSH));
  FD4RE X1I5030 (.C(CLK1), .CE(CP0_WRITE_STATUS), .D0(CACHE_DAT[31]), .D1
    (CACHE_DAT[30]), .D2(CACHE_DAT[29]), .D3(CACHE_DAT[28]), .Q0(STATUS31), 
    .Q1(STATUS30), .Q2(STATUS29), .Q3(STATUS28), .R(RESET));
  FDSE X1I5037 (.C(CLK1), .CE(CP0_WRITE_STATUS), .D(CACHE_DAT[22]), .Q
    (STATUS22), .S(RESET));
  AND5B2 X1I5046 (.I0(X1N6067), .I1(DATA_MEM_ACCESS), .I2(MMU_HIT_INSTR), 
    .I3(CLK1_NBUF), .I4(X1N4422), .O(X1N3683));
  REG32 X1I505 (.CLK(CLK2), .EN(GLB_EN), .I({NEXT_STORED_PC[31], 
    NEXT_STORED_PC[30], NEXT_STORED_PC[29], NEXT_STORED_PC[28], 
    NEXT_STORED_PC[27], NEXT_STORED_PC[26], NEXT_STORED_PC[25], 
    NEXT_STORED_PC[24], NEXT_STORED_PC[23], NEXT_STORED_PC[22], 
    NEXT_STORED_PC[21], NEXT_STORED_PC[20], NEXT_STORED_PC[19], 
    NEXT_STORED_PC[18], NEXT_STORED_PC[17], NEXT_STORED_PC[16], 
    NEXT_STORED_PC[15], NEXT_STORED_PC[14], NEXT_STORED_PC[13], 
    NEXT_STORED_PC[12], NEXT_STORED_PC[11], NEXT_STORED_PC[10], 
    NEXT_STORED_PC[9], NEXT_STORED_PC[8], NEXT_STORED_PC[7], 
    NEXT_STORED_PC[6], NEXT_STORED_PC[5], NEXT_STORED_PC[4], 
    NEXT_STORED_PC[3], NEXT_STORED_PC[2], NEXT_STORED_PC[1], 
    NEXT_STORED_PC[0]}), .O({PC_TO_PIPELINE[31], PC_TO_PIPELINE[30], 
    PC_TO_PIPELINE[29], PC_TO_PIPELINE[28], PC_TO_PIPELINE[27], 
    PC_TO_PIPELINE[26], PC_TO_PIPELINE[25], PC_TO_PIPELINE[24], 
    PC_TO_PIPELINE[23], PC_TO_PIPELINE[22], PC_TO_PIPELINE[21], 
    PC_TO_PIPELINE[20], PC_TO_PIPELINE[19], PC_TO_PIPELINE[18], 
    PC_TO_PIPELINE[17], PC_TO_PIPELINE[16], PC_TO_PIPELINE[15], 
    PC_TO_PIPELINE[14], PC_TO_PIPELINE[13], PC_TO_PIPELINE[12], 
    PC_TO_PIPELINE[11], PC_TO_PIPELINE[10], PC_TO_PIPELINE[9], 
    PC_TO_PIPELINE[8], PC_TO_PIPELINE[7], PC_TO_PIPELINE[6], 
    PC_TO_PIPELINE[5], PC_TO_PIPELINE[4], PC_TO_PIPELINE[3], 
    PC_TO_PIPELINE[2], PC_TO_PIPELINE[1], PC_TO_PIPELINE[0]}));
  BUFE32 X1I5050 (.E(CPO_READ_PRID), .I({GND[31], GND[30], GND[29], GND[28]
    , GND[27], GND[26], GND[25], GND[24], GND[23], GND[22], GND[21], GND[20]
    , GND[19], GND[18], GND[17], GND[16], GND[15], GND[14], GND[13], GND[12]
    , GND[11], GND[10], GND[9], VCC, GND[7], GND[6], GND[5], GND[4], GND[3]
    , GND[2], GND[1], GND[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  M4_1E X1I5057 (.D0(X1N5268), .D1(X1N4895), .D2(X1N4903), .D3(X1N5273), .E
    (MEM_CP_ACCESS), .O(INT_COPROCESSOR_UNUSABLE), .S0(MEM_CP_NO0), .S1
    (MEM_CP_NO1));
  FDE X1I5062 (.C(CLK2), .CE(GLB_EN), .D(X1N5060), .Q(MMU_NOT_VALID_DATA));
  MUX2_1X32 X1I5066 (.A({MMU_ENTRY_LO[31], MMU_ENTRY_LO[30], 
    MMU_ENTRY_LO[29], MMU_ENTRY_LO[28], MMU_ENTRY_LO[27], MMU_ENTRY_LO[26], 
    MMU_ENTRY_LO[25], MMU_ENTRY_LO[24], MMU_ENTRY_LO[23], MMU_ENTRY_LO[22], 
    MMU_ENTRY_LO[21], MMU_ENTRY_LO[20], MMU_ENTRY_LO[19], MMU_ENTRY_LO[18], 
    MMU_ENTRY_LO[17], MMU_ENTRY_LO[16], MMU_ENTRY_LO[15], MMU_ENTRY_LO[14], 
    MMU_ENTRY_LO[13], MMU_ENTRY_LO[12], MMU_ENTRY_LO[11], MMU_ENTRY_LO[10], 
    MMU_ENTRY_LO[9], MMU_ENTRY_LO[8], MMU_ENTRY_LO[7], MMU_ENTRY_LO[6], 
    MMU_ENTRY_LO[5], MMU_ENTRY_LO[4], MMU_ENTRY_LO[3], MMU_ENTRY_LO[2], 
    MMU_ENTRY_LO[1], MMU_ENTRY_LO[0]}), .B({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}), .SB
    (CPO_WRITE_ENTRY_LO), .S({CP0_ENTRY_LO_NEXT[31], CP0_ENTRY_LO_NEXT[30], 
    CP0_ENTRY_LO_NEXT[29], CP0_ENTRY_LO_NEXT[28], CP0_ENTRY_LO_NEXT[27], 
    CP0_ENTRY_LO_NEXT[26], CP0_ENTRY_LO_NEXT[25], CP0_ENTRY_LO_NEXT[24], 
    CP0_ENTRY_LO_NEXT[23], CP0_ENTRY_LO_NEXT[22], CP0_ENTRY_LO_NEXT[21], 
    CP0_ENTRY_LO_NEXT[20], CP0_ENTRY_LO_NEXT[19], CP0_ENTRY_LO_NEXT[18], 
    CP0_ENTRY_LO_NEXT[17], CP0_ENTRY_LO_NEXT[16], CP0_ENTRY_LO_NEXT[15], 
    CP0_ENTRY_LO_NEXT[14], CP0_ENTRY_LO_NEXT[13], CP0_ENTRY_LO_NEXT[12], 
    CP0_ENTRY_LO_NEXT[11], CP0_ENTRY_LO_NEXT[10], CP0_ENTRY_LO_NEXT[9], 
    CP0_ENTRY_LO_NEXT[8], CP0_ENTRY_LO_NEXT[7], CP0_ENTRY_LO_NEXT[6], 
    CP0_ENTRY_LO_NEXT[5], CP0_ENTRY_LO_NEXT[4], CP0_ENTRY_LO_NEXT[3], 
    CP0_ENTRY_LO_NEXT[2], CP0_ENTRY_LO_NEXT[1], CP0_ENTRY_LO_NEXT[0]}));
  AND2 X1I5078 (.I0(INST_CACHE_HIT), .I1(END_WRITE), .O(X1N6663));
  AND2B1 X1I5087 (.I0(HALT1), .I1(CLK2_NBUF), .O(X1N4112));
  MUX2_1X32 X1I5130 (.A({INST_PFN[19], INST_PFN[18], INST_PFN[17], 
    INST_PFN[16], INST_PFN[15], INST_PFN[14], INST_PFN[13], INST_PFN[12], 
    INST_PFN[11], INST_PFN[10], INST_PFN[9], INST_PFN[8], INST_PFN[7], 
    INST_PFN[6], INST_PFN[5], INST_PFN[4], INST_PFN[3], INST_PFN[2], 
    INST_PFN[1], INST_PFN[0], PC[11], PC[10], PC[9], PC[8], PC[7], PC[6], 
    PC[5], PC[4], PC[3], PC[2], PC[1], PC[0]}), .B({DATA_PFN[19], 
    DATA_PFN[18], DATA_PFN[17], DATA_PFN[16], DATA_PFN[15], DATA_PFN[14], 
    DATA_PFN[13], DATA_PFN[12], DATA_PFN[11], DATA_PFN[10], DATA_PFN[9], 
    DATA_PFN[8], DATA_PFN[7], DATA_PFN[6], DATA_PFN[5], DATA_PFN[4], 
    DATA_PFN[3], DATA_PFN[2], DATA_PFN[1], DATA_PFN[0], EXE_FF[11], 
    EXE_FF[10], EXE_FF[9], EXE_FF[8], EXE_FF[7], EXE_FF[6], EXE_FF[5], 
    EXE_FF[4], EXE_FF[3], EXE_FF[2], EXE_FF[1], EXE_FF[0]}), .SB
    (DATA_MEM_ACCESS), .S({MEM_ACCESS_ADDRESS[31], MEM_ACCESS_ADDRESS[30], 
    MEM_ACCESS_ADDRESS[29], MEM_ACCESS_ADDRESS[28], MEM_ACCESS_ADDRESS[27], 
    MEM_ACCESS_ADDRESS[26], MEM_ACCESS_ADDRESS[25], MEM_ACCESS_ADDRESS[24], 
    MEM_ACCESS_ADDRESS[23], MEM_ACCESS_ADDRESS[22], MEM_ACCESS_ADDRESS[21], 
    MEM_ACCESS_ADDRESS[20], MEM_ACCESS_ADDRESS[19], MEM_ACCESS_ADDRESS[18], 
    MEM_ACCESS_ADDRESS[17], MEM_ACCESS_ADDRESS[16], MEM_ACCESS_ADDRESS[15], 
    MEM_ACCESS_ADDRESS[14], MEM_ACCESS_ADDRESS[13], MEM_ACCESS_ADDRESS[12], 
    MEM_ACCESS_ADDRESS[11], MEM_ACCESS_ADDRESS[10], MEM_ACCESS_ADDRESS[9], 
    MEM_ACCESS_ADDRESS[8], MEM_ACCESS_ADDRESS[7], MEM_ACCESS_ADDRESS[6], 
    MEM_ACCESS_ADDRESS[5], MEM_ACCESS_ADDRESS[4], MEM_ACCESS_ADDRESS[3], 
    MEM_ACCESS_ADDRESS[2], MEM_ACCESS_ADDRESS[1], MEM_ACCESS_ADDRESS[0]}));
  LD16 X1I5139 (.D({MEM_ACCESS_ADDRESS[31], MEM_ACCESS_ADDRESS[30], 
    MEM_ACCESS_ADDRESS[29], MEM_ACCESS_ADDRESS[28], MEM_ACCESS_ADDRESS[27], 
    MEM_ACCESS_ADDRESS[26], MEM_ACCESS_ADDRESS[25], MEM_ACCESS_ADDRESS[24], 
    MEM_ACCESS_ADDRESS[23], MEM_ACCESS_ADDRESS[22], MEM_ACCESS_ADDRESS[21], 
    MEM_ACCESS_ADDRESS[20], MEM_ACCESS_ADDRESS[19], MEM_ACCESS_ADDRESS[18], 
    MEM_ACCESS_ADDRESS[17], MEM_ACCESS_ADDRESS[16]}), .G(MEMORY), .Q({
    ADDRESS[31], ADDRESS[30], ADDRESS[29], ADDRESS[28], ADDRESS[27], 
    ADDRESS[26], ADDRESS[25], ADDRESS[24], ADDRESS[23], ADDRESS[22], 
    ADDRESS[21], ADDRESS[20], ADDRESS[19], ADDRESS[18], ADDRESS[17], 
    ADDRESS[16]}));
  MUX3_1X32 X1I514 (.A({PC_PLUS_FOUR[31], PC_PLUS_FOUR[30], PC_PLUS_FOUR[29]
    , PC_PLUS_FOUR[28], PC_PLUS_FOUR[27], PC_PLUS_FOUR[26], PC_PLUS_FOUR[25]
    , PC_PLUS_FOUR[24], PC_PLUS_FOUR[23], PC_PLUS_FOUR[22], PC_PLUS_FOUR[21]
    , PC_PLUS_FOUR[20], PC_PLUS_FOUR[19], PC_PLUS_FOUR[18], PC_PLUS_FOUR[17]
    , PC_PLUS_FOUR[16], PC_PLUS_FOUR[15], PC_PLUS_FOUR[14], PC_PLUS_FOUR[13]
    , PC_PLUS_FOUR[12], PC_PLUS_FOUR[11], PC_PLUS_FOUR[10], PC_PLUS_FOUR[9]
    , PC_PLUS_FOUR[8], PC_PLUS_FOUR[7], PC_PLUS_FOUR[6], PC_PLUS_FOUR[5], 
    PC_PLUS_FOUR[4], PC_PLUS_FOUR[3], PC_PLUS_FOUR[2], PC_PLUS_FOUR[1], 
    PC_PLUS_FOUR[0]}), .B({TAKEBRANCH, BRANCH[31], BRANCH[30], BRANCH[29], 
    BRANCH[28], BRANCH[27], BRANCH[26], BRANCH[25], BRANCH[24], BRANCH[23], 
    BRANCH[22], BRANCH[21], BRANCH[20], BRANCH[19], BRANCH[18], BRANCH[17], 
    BRANCH[16], BRANCH[15], BRANCH[14], BRANCH[13], BRANCH[12], BRANCH[11], 
    BRANCH[10], BRANCH[9], BRANCH[8], BRANCH[7], BRANCH[6], BRANCH[5], 
    BRANCH[4], BRANCH[3], BRANCH[2], BRANCH[1], BRANCH[0]}), .C({JMP2REG, 
    REG_A_EXE_FF[31], REG_A_EXE_FF[30], REG_A_EXE_FF[29], REG_A_EXE_FF[28], 
    REG_A_EXE_FF[27], REG_A_EXE_FF[26], REG_A_EXE_FF[25], REG_A_EXE_FF[24], 
    REG_A_EXE_FF[23], REG_A_EXE_FF[22], REG_A_EXE_FF[21], REG_A_EXE_FF[20], 
    REG_A_EXE_FF[19], REG_A_EXE_FF[18], REG_A_EXE_FF[17], REG_A_EXE_FF[16], 
    REG_A_EXE_FF[15], REG_A_EXE_FF[14], REG_A_EXE_FF[13], REG_A_EXE_FF[12], 
    REG_A_EXE_FF[11], REG_A_EXE_FF[10], REG_A_EXE_FF[9], REG_A_EXE_FF[8], 
    REG_A_EXE_FF[7], REG_A_EXE_FF[6], REG_A_EXE_FF[5], REG_A_EXE_FF[4], 
    REG_A_EXE_FF[3], REG_A_EXE_FF[2], REG_A_EXE_FF[1], REG_A_EXE_FF[0]}), 
    .S({NEXT_PC[31], NEXT_PC[30], NEXT_PC[29], NEXT_PC[28], NEXT_PC[27], 
    NEXT_PC[26], NEXT_PC[25], NEXT_PC[24], NEXT_PC[23], NEXT_PC[22], 
    NEXT_PC[21], NEXT_PC[20], NEXT_PC[19], NEXT_PC[18], NEXT_PC[17], 
    NEXT_PC[16], NEXT_PC[15], NEXT_PC[14], NEXT_PC[13], NEXT_PC[12], 
    NEXT_PC[11], NEXT_PC[10], NEXT_PC[9], NEXT_PC[8], NEXT_PC[7], NEXT_PC[6]
    , NEXT_PC[5], NEXT_PC[4], NEXT_PC[3], NEXT_PC[2], NEXT_PC[1], NEXT_PC[0]
    }));
  LD16 X1I5140 (.D({MEM_ACCESS_ADDRESS[15], MEM_ACCESS_ADDRESS[14], 
    MEM_ACCESS_ADDRESS[13], MEM_ACCESS_ADDRESS[12], MEM_ACCESS_ADDRESS[11], 
    MEM_ACCESS_ADDRESS[10], MEM_ACCESS_ADDRESS[9], MEM_ACCESS_ADDRESS[8], 
    MEM_ACCESS_ADDRESS[7], MEM_ACCESS_ADDRESS[6], MEM_ACCESS_ADDRESS[5], 
    MEM_ACCESS_ADDRESS[4], MEM_ACCESS_ADDRESS[3], MEM_ACCESS_ADDRESS[2], 
    MEM_ACCESS_ADDRESS[1], MEM_ACCESS_ADDRESS[0]}), .G(MEMORY), .Q({
    ADDRESS[15], ADDRESS[14], ADDRESS[13], ADDRESS[12], ADDRESS[11], 
    ADDRESS[10], ADDRESS[9], ADDRESS[8], ADDRESS[7], ADDRESS[6], ADDRESS[5]
    , ADDRESS[4], ADDRESS[3], ADDRESS[2], ADDRESS[1], ADDRESS[0]}));
  BUFE32 X1I5153 (.E(CPO_READ_INDEX), .I({INDEX31, GND[30], GND[29], GND[28]
    , GND[27], GND[26], GND[25], GND[24], GND[23], GND[22], GND[21], GND[20]
    , GND[19], GND[18], GND[17], GND[16], GND[15], GND[14], INDEX[13], 
    INDEX[12], INDEX[11], INDEX[10], INDEX[9], INDEX[8], GND[7], GND[6], 
    GND[5], GND[4], GND[3], GND[2], GND[1], GND[0]}), .O({CACHE_DAT[31], 
    CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], 
    CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], 
    CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], 
    CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], 
    CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], 
    CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], 
    CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], 
    CACHE_DAT[0]}));
  BUFE32 X1I5156 (.E(CPO_READ_RANDOM), .I({GND[31], GND[30], GND[29], 
    GND[28], GND[27], GND[26], GND[25], GND[24], GND[23], GND[22], GND[21], 
    GND[20], GND[19], GND[18], GND[17], GND[16], GND[15], GND[14], 
    RANDOM[13], RANDOM[12], RANDOM[11], RANDOM[10], RANDOM[9], RANDOM[8], 
    GND[7], GND[6], GND[5], GND[4], GND[3], GND[2], GND[1], GND[0]}), .O({
    CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], 
    CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], 
    CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], 
    CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], 
    CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], 
    CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], 
    CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], 
    CACHE_DAT[1], CACHE_DAT[0]}));
  FD8CE X1I5160 (.C(CLK1), .CE(CP0_WRITE_STATUS), .CLR(GND), .D({
    CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], 
    CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8]}), .Q({
    STATUS[15], STATUS[14], STATUS[13], STATUS[12], STATUS[11], STATUS[10], 
    STATUS[9], STATUS[8]}));
  OR3 X1I5168 (.I0(INTERRUPT_MEM), .I1(CP0_RETURN_FROM_EXCEPTION), .I2
    (CP0_WRITE_STATUS), .O(X1N6012));
  FDRE X1I5170 (.C(CLK1), .CE(X1N4935), .D(X1N5229), .Q(STATUS2), .R(RESET)
    );
  FDRE X1I5174 (.C(CLK1), .CE(X1N4935), .D(X1N5230), .Q(STATUS3), .R
    (RESET));
  FDRE X1I5187 (.C(CLK1), .CE(X1N4935), .D(X1N5208), .Q(STATUS0), .R(RESET)
    );
  FDRE X1I5188 (.C(CLK1), .CE(X1N4935), .D(X1N5212), .Q(STATUS1), .R
    (RESET));
  FDRE X1I5196 (.C(CLK1), .CE(X1N4935), .D(X1N5249), .Q(STATUS4), .R(RESET)
    );
  FDRE X1I5197 (.C(CLK1), .CE(X1N4935), .D(X1N5248), .Q(STATUS5), .R
    (RESET));
  M2_1E X1I5207 (.D0(CACHE_DAT[0]), .D1(STATUS2), .E(X1N6365), .O(X1N5208), 
    .S0(CP0_RETURN_FROM_EXCEPTION));
  M2_1E X1I5215 (.D0(CACHE_DAT[1]), .D1(STATUS3), .E(X1N6365), .O(X1N5212), 
    .S0(CP0_RETURN_FROM_EXCEPTION));
  M2_1 X1I5228 (.D0(X1N5235), .D1(STATUS0), .O(X1N5229), .S0(INTERRUPT_MEM)
    );
  M2_1 X1I5231 (.D0(X1N5234), .D1(STATUS1), .O(X1N5230), .S0
    (INTERRUPT_MEM));
  M2_1 X1I5232 (.D0(CACHE_DAT[3]), .D1(STATUS5), .O(X1N5234), .S0
    (CP0_RETURN_FROM_EXCEPTION));
  M2_1 X1I5233 (.D0(CACHE_DAT[2]), .D1(STATUS4), .O(X1N5235), .S0
    (CP0_RETURN_FROM_EXCEPTION));
  M2_1 X1I5251 (.D0(X1N5253), .D1(STATUS3), .O(X1N5248), .S0(INTERRUPT_MEM)
    );
  M2_1 X1I5252 (.D0(X1N5254), .D1(STATUS2), .O(X1N5249), .S0
    (INTERRUPT_MEM));
  M2_1 X1I5260 (.D0(CACHE_DAT[5]), .D1(STATUS5), .O(X1N5253), .S0
    (CP0_RETURN_FROM_EXCEPTION));
  M2_1 X1I5261 (.D0(CACHE_DAT[4]), .D1(STATUS4), .O(X1N5254), .S0
    (CP0_RETURN_FROM_EXCEPTION));
  INV X1I5272 (.I(STATUS31), .O(X1N5273));
  OR2 X1I5297 (.I0(CPO_WRITE_ENTRY_HI), .I1(X1N5287), .O(X1N5303));
  NOR6 X1I530 (.I0(INSTRUCTION[26]), .I1(INSTRUCTION[27]), .I2
    (INSTRUCTION[28]), .I3(INSTRUCTION[29]), .I4(INSTRUCTION[30]), .I5
    (INSTRUCTION[31]), .O(SPECIAL));
  OR2 X1I5305 (.I0(INT_DEC_ADEL), .I1(INT_DEC_TLBL), .O(INST_ADDR_ERROR));
  AND2 X1I5326 (.I0(BR_GEZ_LTZ), .I1(INSTRUCTION[20]), .O(X1N5327));
  REG32 X1I5342 (.CLK(CLK1), .EN(X1N5303), .I({CP0_ENTRY_HI_NEXT[31], 
    CP0_ENTRY_HI_NEXT[30], CP0_ENTRY_HI_NEXT[29], CP0_ENTRY_HI_NEXT[28], 
    CP0_ENTRY_HI_NEXT[27], CP0_ENTRY_HI_NEXT[26], CP0_ENTRY_HI_NEXT[25], 
    CP0_ENTRY_HI_NEXT[24], CP0_ENTRY_HI_NEXT[23], CP0_ENTRY_HI_NEXT[22], 
    CP0_ENTRY_HI_NEXT[21], CP0_ENTRY_HI_NEXT[20], CP0_ENTRY_HI_NEXT[19], 
    CP0_ENTRY_HI_NEXT[18], CP0_ENTRY_HI_NEXT[17], CP0_ENTRY_HI_NEXT[16], 
    CP0_ENTRY_HI_NEXT[15], CP0_ENTRY_HI_NEXT[14], CP0_ENTRY_HI_NEXT[13], 
    CP0_ENTRY_HI_NEXT[12], CP0_ENTRY_HI_NEXT[11], CP0_ENTRY_HI_NEXT[10], 
    CP0_ENTRY_HI_NEXT[9], CP0_ENTRY_HI_NEXT[8], CP0_ENTRY_HI_NEXT[7], 
    CP0_ENTRY_HI_NEXT[6], CP0_ENTRY_HI_NEXT[5], CP0_ENTRY_HI_NEXT[4], 
    CP0_ENTRY_HI_NEXT[3], CP0_ENTRY_HI_NEXT[2], CP0_ENTRY_HI_NEXT[1], 
    CP0_ENTRY_HI_NEXT[0]}), .O({CP0_ENTRY_HI[31], CP0_ENTRY_HI[30], 
    CP0_ENTRY_HI[29], CP0_ENTRY_HI[28], CP0_ENTRY_HI[27], CP0_ENTRY_HI[26], 
    CP0_ENTRY_HI[25], CP0_ENTRY_HI[24], CP0_ENTRY_HI[23], CP0_ENTRY_HI[22], 
    CP0_ENTRY_HI[21], CP0_ENTRY_HI[20], CP0_ENTRY_HI[19], CP0_ENTRY_HI[18], 
    CP0_ENTRY_HI[17], CP0_ENTRY_HI[16], CP0_ENTRY_HI[15], CP0_ENTRY_HI[14], 
    CP0_ENTRY_HI[13], CP0_ENTRY_HI[12], CP0_ENTRY_HI[11], CP0_ENTRY_HI[10], 
    CP0_ENTRY_HI[9], CP0_ENTRY_HI[8], CP0_ENTRY_HI[7], CP0_ENTRY_HI[6], 
    CP0_ENTRY_HI[5], CP0_ENTRY_HI[4], CP0_ENTRY_HI[3], CP0_ENTRY_HI[2], 
    CP0_ENTRY_HI[1], CP0_ENTRY_HI[0]}));
  ROTEIGHT2 X1I5344 (.I({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], 
    CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], 
    CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], 
    CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], 
    CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], 
    CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8]
    , CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], 
    CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}), .O({LOAD_ROTATED[31], 
    LOAD_ROTATED[30], LOAD_ROTATED[29], LOAD_ROTATED[28], LOAD_ROTATED[27], 
    LOAD_ROTATED[26], LOAD_ROTATED[25], LOAD_ROTATED[24], LOAD_ROTATED[23], 
    LOAD_ROTATED[22], LOAD_ROTATED[21], LOAD_ROTATED[20], LOAD_ROTATED[19], 
    LOAD_ROTATED[18], LOAD_ROTATED[17], LOAD_ROTATED[16], LOAD_ROTATED[15], 
    LOAD_ROTATED[14], LOAD_ROTATED[13], LOAD_ROTATED[12], LOAD_ROTATED[11], 
    LOAD_ROTATED[10], LOAD_ROTATED[9], LOAD_ROTATED[8], LOAD_ROTATED[7], 
    LOAD_ROTATED[6], LOAD_ROTATED[5], LOAD_ROTATED[4], LOAD_ROTATED[3], 
    LOAD_ROTATED[2], LOAD_ROTATED[1], LOAD_ROTATED[0]}), .S0(X1N5619), .S1
    (X1N5618));
  BYTEMASK X1I5360 (.A({LOAD_ROTATED[31], LOAD_ROTATED[30], LOAD_ROTATED[29]
    , LOAD_ROTATED[28], LOAD_ROTATED[27], LOAD_ROTATED[26], LOAD_ROTATED[25]
    , LOAD_ROTATED[24], LOAD_ROTATED[23], LOAD_ROTATED[22], LOAD_ROTATED[21]
    , LOAD_ROTATED[20], LOAD_ROTATED[19], LOAD_ROTATED[18], LOAD_ROTATED[17]
    , LOAD_ROTATED[16], LOAD_ROTATED[15], LOAD_ROTATED[14], LOAD_ROTATED[13]
    , LOAD_ROTATED[12], LOAD_ROTATED[11], LOAD_ROTATED[10], LOAD_ROTATED[9]
    , LOAD_ROTATED[8], LOAD_ROTATED[7], LOAD_ROTATED[6], LOAD_ROTATED[5], 
    LOAD_ROTATED[4], LOAD_ROTATED[3], LOAD_ROTATED[2], LOAD_ROTATED[1], 
    LOAD_ROTATED[0]}), .B({REG_B_MEM[31], REG_B_MEM[30], REG_B_MEM[29], 
    REG_B_MEM[28], REG_B_MEM[27], REG_B_MEM[26], REG_B_MEM[25], 
    REG_B_MEM[24], REG_B_MEM[23], REG_B_MEM[22], REG_B_MEM[21], 
    REG_B_MEM[20], REG_B_MEM[19], REG_B_MEM[18], REG_B_MEM[17], 
    REG_B_MEM[16], REG_B_MEM[15], REG_B_MEM[14], REG_B_MEM[13], 
    REG_B_MEM[12], REG_B_MEM[11], REG_B_MEM[10], REG_B_MEM[9], REG_B_MEM[8]
    , REG_B_MEM[7], REG_B_MEM[6], REG_B_MEM[5], REG_B_MEM[4], REG_B_MEM[3], 
    REG_B_MEM[2], REG_B_MEM[1], REG_B_MEM[0]}), .MASK(X1N5754), .NULL0(GND)
    , .NULL1(X1N5748), .NULL2(X1N5746), .NULL3(X1N5746), .O({
    LOAD_ROTATED_MASKED[31], LOAD_ROTATED_MASKED[30], 
    LOAD_ROTATED_MASKED[29], LOAD_ROTATED_MASKED[28], 
    LOAD_ROTATED_MASKED[27], LOAD_ROTATED_MASKED[26], 
    LOAD_ROTATED_MASKED[25], LOAD_ROTATED_MASKED[24], 
    LOAD_ROTATED_MASKED[23], LOAD_ROTATED_MASKED[22], 
    LOAD_ROTATED_MASKED[21], LOAD_ROTATED_MASKED[20], 
    LOAD_ROTATED_MASKED[19], LOAD_ROTATED_MASKED[18], 
    LOAD_ROTATED_MASKED[17], LOAD_ROTATED_MASKED[16], 
    LOAD_ROTATED_MASKED[15], LOAD_ROTATED_MASKED[14], 
    LOAD_ROTATED_MASKED[13], LOAD_ROTATED_MASKED[12], 
    LOAD_ROTATED_MASKED[11], LOAD_ROTATED_MASKED[10], LOAD_ROTATED_MASKED[9]
    , LOAD_ROTATED_MASKED[8], LOAD_ROTATED_MASKED[7], LOAD_ROTATED_MASKED[6]
    , LOAD_ROTATED_MASKED[5], LOAD_ROTATED_MASKED[4], LOAD_ROTATED_MASKED[3]
    , LOAD_ROTATED_MASKED[2], LOAD_ROTATED_MASKED[1], LOAD_ROTATED_MASKED[0]
    }), .SB0(X1N5736), .SB1(X1N5734), .SB2(X1N5732), .SB3(X1N5728));
  ROTEIGHT X1I5365 (.I({REG_B_MEM[31], REG_B_MEM[30], REG_B_MEM[29], 
    REG_B_MEM[28], REG_B_MEM[27], REG_B_MEM[26], REG_B_MEM[25], 
    REG_B_MEM[24], REG_B_MEM[23], REG_B_MEM[22], REG_B_MEM[21], 
    REG_B_MEM[20], REG_B_MEM[19], REG_B_MEM[18], REG_B_MEM[17], 
    REG_B_MEM[16], REG_B_MEM[15], REG_B_MEM[14], REG_B_MEM[13], 
    REG_B_MEM[12], REG_B_MEM[11], REG_B_MEM[10], REG_B_MEM[9], REG_B_MEM[8]
    , REG_B_MEM[7], REG_B_MEM[6], REG_B_MEM[5], REG_B_MEM[4], REG_B_MEM[3], 
    REG_B_MEM[2], REG_B_MEM[1], REG_B_MEM[0]}), .O({REG_B_MEM_SHIFTED[31], 
    REG_B_MEM_SHIFTED[30], REG_B_MEM_SHIFTED[29], REG_B_MEM_SHIFTED[28], 
    REG_B_MEM_SHIFTED[27], REG_B_MEM_SHIFTED[26], REG_B_MEM_SHIFTED[25], 
    REG_B_MEM_SHIFTED[24], REG_B_MEM_SHIFTED[23], REG_B_MEM_SHIFTED[22], 
    REG_B_MEM_SHIFTED[21], REG_B_MEM_SHIFTED[20], REG_B_MEM_SHIFTED[19], 
    REG_B_MEM_SHIFTED[18], REG_B_MEM_SHIFTED[17], REG_B_MEM_SHIFTED[16], 
    REG_B_MEM_SHIFTED[15], REG_B_MEM_SHIFTED[14], REG_B_MEM_SHIFTED[13], 
    REG_B_MEM_SHIFTED[12], REG_B_MEM_SHIFTED[11], REG_B_MEM_SHIFTED[10], 
    REG_B_MEM_SHIFTED[9], REG_B_MEM_SHIFTED[8], REG_B_MEM_SHIFTED[7], 
    REG_B_MEM_SHIFTED[6], REG_B_MEM_SHIFTED[5], REG_B_MEM_SHIFTED[4], 
    REG_B_MEM_SHIFTED[3], REG_B_MEM_SHIFTED[2], REG_B_MEM_SHIFTED[1], 
    REG_B_MEM_SHIFTED[0]}), .S0(X1N5507), .S1(X1N5524));
  BYTE_MUX X1I5373 (.A({MEMORY_BEFRE_WRITE[31], MEMORY_BEFRE_WRITE[30], 
    MEMORY_BEFRE_WRITE[29], MEMORY_BEFRE_WRITE[28], MEMORY_BEFRE_WRITE[27], 
    MEMORY_BEFRE_WRITE[26], MEMORY_BEFRE_WRITE[25], MEMORY_BEFRE_WRITE[24], 
    MEMORY_BEFRE_WRITE[23], MEMORY_BEFRE_WRITE[22], MEMORY_BEFRE_WRITE[21], 
    MEMORY_BEFRE_WRITE[20], MEMORY_BEFRE_WRITE[19], MEMORY_BEFRE_WRITE[18], 
    MEMORY_BEFRE_WRITE[17], MEMORY_BEFRE_WRITE[16], MEMORY_BEFRE_WRITE[15], 
    MEMORY_BEFRE_WRITE[14], MEMORY_BEFRE_WRITE[13], MEMORY_BEFRE_WRITE[12], 
    MEMORY_BEFRE_WRITE[11], MEMORY_BEFRE_WRITE[10], MEMORY_BEFRE_WRITE[9], 
    MEMORY_BEFRE_WRITE[8], MEMORY_BEFRE_WRITE[7], MEMORY_BEFRE_WRITE[6], 
    MEMORY_BEFRE_WRITE[5], MEMORY_BEFRE_WRITE[4], MEMORY_BEFRE_WRITE[3], 
    MEMORY_BEFRE_WRITE[2], MEMORY_BEFRE_WRITE[1], MEMORY_BEFRE_WRITE[0]}), 
    .B({REG_B_MEM_SHIFTED[31], REG_B_MEM_SHIFTED[30], REG_B_MEM_SHIFTED[29]
    , REG_B_MEM_SHIFTED[28], REG_B_MEM_SHIFTED[27], REG_B_MEM_SHIFTED[26], 
    REG_B_MEM_SHIFTED[25], REG_B_MEM_SHIFTED[24], REG_B_MEM_SHIFTED[23], 
    REG_B_MEM_SHIFTED[22], REG_B_MEM_SHIFTED[21], REG_B_MEM_SHIFTED[20], 
    REG_B_MEM_SHIFTED[19], REG_B_MEM_SHIFTED[18], REG_B_MEM_SHIFTED[17], 
    REG_B_MEM_SHIFTED[16], REG_B_MEM_SHIFTED[15], REG_B_MEM_SHIFTED[14], 
    REG_B_MEM_SHIFTED[13], REG_B_MEM_SHIFTED[12], REG_B_MEM_SHIFTED[11], 
    REG_B_MEM_SHIFTED[10], REG_B_MEM_SHIFTED[9], REG_B_MEM_SHIFTED[8], 
    REG_B_MEM_SHIFTED[7], REG_B_MEM_SHIFTED[6], REG_B_MEM_SHIFTED[5], 
    REG_B_MEM_SHIFTED[4], REG_B_MEM_SHIFTED[3], REG_B_MEM_SHIFTED[2], 
    REG_B_MEM_SHIFTED[1], REG_B_MEM_SHIFTED[0]}), .O({
    REG_B_MEM_SHIFTED_MASKED[31], REG_B_MEM_SHIFTED_MASKED[30], 
    REG_B_MEM_SHIFTED_MASKED[29], REG_B_MEM_SHIFTED_MASKED[28], 
    REG_B_MEM_SHIFTED_MASKED[27], REG_B_MEM_SHIFTED_MASKED[26], 
    REG_B_MEM_SHIFTED_MASKED[25], REG_B_MEM_SHIFTED_MASKED[24], 
    REG_B_MEM_SHIFTED_MASKED[23], REG_B_MEM_SHIFTED_MASKED[22], 
    REG_B_MEM_SHIFTED_MASKED[21], REG_B_MEM_SHIFTED_MASKED[20], 
    REG_B_MEM_SHIFTED_MASKED[19], REG_B_MEM_SHIFTED_MASKED[18], 
    REG_B_MEM_SHIFTED_MASKED[17], REG_B_MEM_SHIFTED_MASKED[16], 
    REG_B_MEM_SHIFTED_MASKED[15], REG_B_MEM_SHIFTED_MASKED[14], 
    REG_B_MEM_SHIFTED_MASKED[13], REG_B_MEM_SHIFTED_MASKED[12], 
    REG_B_MEM_SHIFTED_MASKED[11], REG_B_MEM_SHIFTED_MASKED[10], 
    REG_B_MEM_SHIFTED_MASKED[9], REG_B_MEM_SHIFTED_MASKED[8], 
    REG_B_MEM_SHIFTED_MASKED[7], REG_B_MEM_SHIFTED_MASKED[6], 
    REG_B_MEM_SHIFTED_MASKED[5], REG_B_MEM_SHIFTED_MASKED[4], 
    REG_B_MEM_SHIFTED_MASKED[3], REG_B_MEM_SHIFTED_MASKED[2], 
    REG_B_MEM_SHIFTED_MASKED[1], REG_B_MEM_SHIFTED_MASKED[0]}), .SB0
    (X1N5547), .SB1(X1N5596), .SB2(X1N5598), .SB3(X1N5600));
  FD4RE X1I5378 (.C(CLK1), .CE(GLB_EN), .D0(X1N5423), .D1(X1N5425), .D2
    (INSTRUCTION[28]), .D3(INSTRUCTION[31]), .Q0(X1N5383), .Q1(X1N5382), .Q2
    (X1N5381), .Q3(X1N5788), .R(FLUSH));
  FD4RE X1I5379 (.C(CLK1), .CE(GLB_EN), .D0(X1N5383), .D1(X1N5382), .D2
    (X1N5381), .D3(X1N5788), .Q0(LDST_SHIFT0), .Q1(LDST_SHIFT1), .Q2
    (LDST_SHIFT2), .Q3(CACHE), .R(FLUSH));
  OR5 X1I5406 (.I0(X1N5407), .I1(X1N4986), .I2(X1N4988), .I3(X1N4990), .I4
    (X1N4992), .O(X1N5414));
  OR2B1 X1I5419 (.I0(STATUS1), .I1(STATUS28), .O(X1N5418));
  OR2 X1I5420 (.I0(INSTRUCTION[30]), .I1(INSTRUCTION[26]), .O(X1N5423));
  OR2 X1I5424 (.I0(INSTRUCTION[30]), .I1(INSTRUCTION[27]), .O(X1N5425));
  AND3 X1I5457 (.I0(EXE_FF[0]), .I1(LDST_SHIFT0), .I2(CACHE), .O(X1N5459));
  AND4 X1I5458 (.I0(EXE_FF[1]), .I1(LDST_SHIFT1), .I2(LDST_SHIFT0), .I3
    (CACHE), .O(X1N5460));
  M2_1X5 X1I550 (.A({INSTRUCTION[20], INSTRUCTION[19], INSTRUCTION[18], 
    INSTRUCTION[17], INSTRUCTION[16]}), .B({INSTRUCTION[15], INSTRUCTION[14]
    , INSTRUCTION[13], INSTRUCTION[12], INSTRUCTION[11]}), .O({
    REG_DEST_RT_RD[4], REG_DEST_RT_RD[3], REG_DEST_RT_RD[2], 
    REG_DEST_RT_RD[1], REG_DEST_RT_RD[0]}), .SB(SPECIAL));
  XOR2 X1I5508 (.I0(LDST_SHIFT2), .I1(X1N5520), .O(X1N5507));
  XOR2 X1I5512 (.I0(X1N5516), .I1(X1N6434), .O(X1N5520));
  XOR2 X1I5513 (.I0(X1N5516), .I1(X1N6433), .O(X1N5519));
  XOR2 X1I5514 (.I0(X1N5521), .I1(X1N5519), .O(X1N5524));
  AND2 X1I5515 (.I0(LDST_SHIFT2), .I1(X1N5520), .O(X1N5521));
  SOP4 X1I5526 (.I0(X1N5507), .I1(X1N5524), .I2(X1N5559), .I3(X1N5552), .O
    (X1N5561));
  SOP4B1 X1I5529 (.I0(X1N5524), .I1(X1N5507), .I2(X1N5559), .I3(X1N5547), .O
    (X1N5550));
  SOP4B1 X1I5530 (.I0(X1N5507), .I1(X1N5524), .I2(LDST_SHIFT1), .I3(X1N5550)
    , .O(X1N5552));
  AND2B2 X1I5546 (.I0(X1N5524), .I1(X1N5507), .O(X1N5547));
  REG5 X1I555 (.CLK(CLK1), .EN(GLB_EN), .I({REG_DEST_FETCH[4], 
    REG_DEST_FETCH[3], REG_DEST_FETCH[2], REG_DEST_FETCH[1], 
    REG_DEST_FETCH[0]}), .O({REG_DEST_EXE[4], REG_DEST_EXE[3], 
    REG_DEST_EXE[2], REG_DEST_EXE[1], REG_DEST_EXE[0]}), .RES(FLUSH));
  XOR2 X1I5564 (.I0(X1N5567), .I1(X1N5550), .O(X1N5596));
  XOR2 X1I5565 (.I0(X1N5567), .I1(X1N5552), .O(X1N5598));
  XOR2 X1I5566 (.I0(X1N5567), .I1(X1N5561), .O(X1N5600));
  AND2B1 X1I5579 (.I0(X1N5547), .I1(LDST_SHIFT2), .O(X1N5567));
  OR2 X1I5584 (.I0(LDST_SHIFT0), .I1(LDST_SHIFT1), .O(X1N5559));
  AND3B2 X1I5608 (.I0(EXE_FF[1]), .I1(EXE_FF[0]), .I2(LDST_SHIFT1), .O
    (MEM_FULL_WRITE));
  OR2 X1I5615 (.I0(MEM_FULL_WRITE), .I1(DATA_CACHE_HIT), .O(X1N5616));
  AND2 X1I5623 (.I0(X1N5624), .I1(X1N5625), .O(X1N5620));
  XOR2 X1I5630 (.I0(X1N5620), .I1(X1N5628), .O(X1N5618));
  XOR2 X1I5631 (.I0(X1N5651), .I1(X1N6421), .O(X1N5628));
  XOR2 X1I5632 (.I0(X1N5651), .I1(X1N6439), .O(X1N5625));
  XOR2 X1I5633 (.I0(X1N5624), .I1(X1N5625), .O(X1N5619));
  AND2 X1I5634 (.I0(LDST_SHIFT2), .I1(LDST_SHIFT1), .O(X1N5624));
  AND2 X1I5649 (.I0(X1N5618), .I1(X1N5651), .O(X1N5668));
  AND2 X1I5650 (.I0(X1N5706), .I1(X1N5651), .O(X1N5670));
  AND3 X1I5655 (.I0(X1N5651), .I1(X1N5619), .I2(X1N5618), .O(X1N5666));
  XOR2 X1I5665 (.I0(X1N5671), .I1(X1N5666), .O(X1N5686));
  XOR2 X1I5667 (.I0(X1N5671), .I1(X1N5668), .O(X1N5684));
  XOR2 X1I5669 (.I0(X1N5671), .I1(X1N5670), .O(X1N5688));
  AND2 X1I5679 (.I0(X1N5696), .I1(X1N5686), .O(X1N5728));
  AND2 X1I5680 (.I0(X1N5696), .I1(X1N5684), .O(X1N5732));
  AND2 X1I5681 (.I0(X1N5696), .I1(X1N5688), .O(X1N5734));
  OR2 X1I5705 (.I0(X1N5619), .I1(X1N5618), .O(X1N5706));
  AND2B1 X1I5710 (.I0(X1N5706), .I1(X1N5651), .O(X1N5696));
  AND2 X1I5718 (.I0(X1N5651), .I1(LDST_SHIFT2), .O(X1N5671));
  INV X1I5720 (.I(X1N5706), .O(X1N5723));
  XOR2 X1I5722 (.I0(X1N5723), .I1(X1N5671), .O(X1N5726));
  AND2 X1I5727 (.I0(X1N5696), .I1(X1N5726), .O(X1N5736));
  AND2B1 X1I5738 (.I0(LDST_SHIFT0), .I1(X1N5746), .O(X1N5748));
  INV X1I5744 (.I(LDST_SHIFT1), .O(X1N5746));
  M2_1E X1I5753 (.D0(LOAD_ROTATED[15]), .D1(LOAD_ROTATED[7]), .E(X1N5764), 
    .O(X1N5754), .S0(LDST_SHIFT0));
  INV X1I5761 (.I(LDST_SHIFT2), .O(X1N5764));
  BUFE32 X1I5781 (.E(CP0_READ_CAUSE), .I({CPO_CAUSE31, GND, CPO_CAUSE29, 
    CPO_CAUSE28, GND[27], GND[26], GND[25], GND[24], GND[23], GND[22], 
    GND[21], GND[20], GND[19], GND[18], GND[17], GND[16], CPO_CAUSE[15], 
    CPO_CAUSE[14], CPO_CAUSE[13], CPO_CAUSE[12], CPO_CAUSE[11], 
    CPO_CAUSE[10], CPO_CAUSE[9], CPO_CAUSE[8], GND, CPO_CAUSE[6], 
    CPO_CAUSE[5], CPO_CAUSE[4], CPO_CAUSE[3], CPO_CAUSE[2], GND[1], GND[0]})
    , .O({CACHE_DAT[31], CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], 
    CACHE_DAT[27], CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], 
    CACHE_DAT[23], CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], 
    CACHE_DAT[19], CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], 
    CACHE_DAT[15], CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], 
    CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], 
    CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], 
    CACHE_DAT[1], CACHE_DAT[0]}));
  AND2B2 X1I5810 (.I0(RESET), .I1(STATUS22), .O(X1N6062));
  AND2B1 X1I5823 (.I0(RESET), .I1(STATUS22), .O(X1N5811));
  GND X1I5888 (.G(EXTERNAL_INTERRUPT1));
  REG5 X1I589 (.CLK(CLK1), .EN(GLB_EN), .I({REG_DEST_EXE[4], REG_DEST_EXE[3]
    , REG_DEST_EXE[2], REG_DEST_EXE[1], REG_DEST_EXE[0]}), .O({
    REG_DEST_MEM[4], REG_DEST_MEM[3], REG_DEST_MEM[2], REG_DEST_MEM[1], 
    REG_DEST_MEM[0]}), .RES(FLUSH));
  AND2B1 X1I5922 (.I0(INST_MEM_ACCESS), .I1(CLK2_NBUF), .O(X1N5147));
  AND2B1 X1I593 (.I0(SET_R0), .I1(REG_DEST_RT_RD[0]), .O(X1N595));
  FD16RE X1I5935 (.C(CLK1), .CE(X1N3422), .D({MEM_DAT[15], MEM_DAT[14], 
    MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], 
    MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], 
    MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .Q({DISPLAY[15], DISPLAY[14], 
    DISPLAY[13], DISPLAY[12], DISPLAY[11], DISPLAY[10], DISPLAY[9], 
    DISPLAY[8], DISPLAY[7], DISPLAY[6], DISPLAY[5], DISPLAY[4], DISPLAY[3], 
    DISPLAY[2], DISPLAY[1], DISPLAY[0]}), .R(GND));
  OR2 X1I594 (.I0(SET_R31), .I1(X1N595), .O(REG_DEST_FETCH[0]));
  AND2 X1I5946 (.I0(STATUS1), .I1(PC[31]), .O(X1N5947));
  OR2 X1I5961 (.I0(DATA_MEM_ACCESS), .I1(INST_MEM_ACCESS), .O(MEMORY));
  AND3 X1I5976 (.I0(STATUS1), .I1(EXE_FF[31]), .I2(CACHE), .O(X1N5975));
  AND2B1 X1I598 (.I0(SET_R0), .I1(REG_DEST_RT_RD[1]), .O(X1N600));
  AND4B2 X1I5985 (.I0(EXC_CODE[4]), .I1(EXC_CODE[3]), .I2(X1N6001), .I3
    (INTERRUPT_MEM));
  OR2 X1I599 (.I0(SET_R31), .I1(X1N600), .O(REG_DEST_FETCH[1]));
  OR3 X1I5997 (.I0(EXC_CODE[2]), .I1(EXC_CODE[1]), .I2(EXC_CODE[0]), .O
    (X1N6001));
  AND2 X1I6011 (.I0(X1N6012), .I1(GLB_EN), .O(X1N4935));
  RAM32X32S X1I6019 (.A0(CPO_REG_SELECT[0]), .A1(CPO_REG_SELECT[1]), .A2
    (CPO_REG_SELECT[2]), .A3(CPO_REG_SELECT[3]), .A4(GND), .D({CACHE_DAT[31]
    , CACHE_DAT[30], CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], 
    CACHE_DAT[26], CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], 
    CACHE_DAT[22], CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], 
    CACHE_DAT[18], CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], 
    CACHE_DAT[14], CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], 
    CACHE_DAT[10], CACHE_DAT[9], CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], 
    CACHE_DAT[5], CACHE_DAT[4], CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], 
    CACHE_DAT[0]}), .O({CP0_HI_REGS[31], CP0_HI_REGS[30], CP0_HI_REGS[29], 
    CP0_HI_REGS[28], CP0_HI_REGS[27], CP0_HI_REGS[26], CP0_HI_REGS[25], 
    CP0_HI_REGS[24], CP0_HI_REGS[23], CP0_HI_REGS[22], CP0_HI_REGS[21], 
    CP0_HI_REGS[20], CP0_HI_REGS[19], CP0_HI_REGS[18], CP0_HI_REGS[17], 
    CP0_HI_REGS[16], CP0_HI_REGS[15], CP0_HI_REGS[14], CP0_HI_REGS[13], 
    CP0_HI_REGS[12], CP0_HI_REGS[11], CP0_HI_REGS[10], CP0_HI_REGS[9], 
    CP0_HI_REGS[8], CP0_HI_REGS[7], CP0_HI_REGS[6], CP0_HI_REGS[5], 
    CP0_HI_REGS[4], CP0_HI_REGS[3], CP0_HI_REGS[2], CP0_HI_REGS[1], 
    CP0_HI_REGS[0]}), .WCLK(CLK1), .WE(X1N6037));
  BUFE32 X1I6020 (.E(X1N6025), .I({CP0_HI_REGS[31], CP0_HI_REGS[30], 
    CP0_HI_REGS[29], CP0_HI_REGS[28], CP0_HI_REGS[27], CP0_HI_REGS[26], 
    CP0_HI_REGS[25], CP0_HI_REGS[24], CP0_HI_REGS[23], CP0_HI_REGS[22], 
    CP0_HI_REGS[21], CP0_HI_REGS[20], CP0_HI_REGS[19], CP0_HI_REGS[18], 
    CP0_HI_REGS[17], CP0_HI_REGS[16], CP0_HI_REGS[15], CP0_HI_REGS[14], 
    CP0_HI_REGS[13], CP0_HI_REGS[12], CP0_HI_REGS[11], CP0_HI_REGS[10], 
    CP0_HI_REGS[9], CP0_HI_REGS[8], CP0_HI_REGS[7], CP0_HI_REGS[6], 
    CP0_HI_REGS[5], CP0_HI_REGS[4], CP0_HI_REGS[3], CP0_HI_REGS[2], 
    CP0_HI_REGS[1], CP0_HI_REGS[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  AND4 X1I6024 (.I0(CPO_REG_SELECT[4]), .I1(CPO_OUTPUT), .I2(CLK2_NBUF), .I3
    (GLB_EN), .O(X1N6025));
  AND5 X1I6032 (.I0(CPO_REG_SELECT[4]), .I1(CPO_WRITE), .I2(CLK2_NBUF), .I3
    (GLB_EN), .I4(X1N6030), .O(X1N6037));
  OR2B1 X1I6036 (.I0(STATUS28), .I1(STATUS1), .O(X1N6030));
  OR2 X1I6066 (.I0(INTERRUPT_MEM), .I1(INT_FETCH_ADEL), .O(X1N6067));
  AND2 X1I6071 (.I0(MMU_HIT_DATA), .I1(V_ADDRESS_ERROR), .O(X1N5287));
  AND3B1 X1I6079 (.I0(ADDRESS[2]), .I1(END_READ), .I2(ENABLE_SERIAL), .O
    (X1N2874));
  XNOR2 X1I6126 (.I0(INSTRUCTION[28]), .I1(INSTRUCTION[27]), .O(X1N6127));
  OR2 X1I613 (.I0(SET_R31), .I1(X1N616), .O(REG_DEST_FETCH[2]));
  AND3B2 X1I6130 (.I0(INSTRUCTION[28]), .I1(INSTRUCTION[27]), .I2
    (BR_INSTRUCTION), .O(BR_GEZ_LTZ));
  AND3B1 X1I6136 (.I0(INSTRUCTION[28]), .I1(INSTRUCTION[27]), .I2
    (BR_INSTRUCTION), .O(JUMPLONG));
  OR3 X1I6143 (.I0(JUMPLONG), .I1(X1N6144), .I2(X1N6177), .O(TAKEBRANCH));
  AND4B2 X1I6145 (.I0(INSTRUCTION[25]), .I1(INSTRUCTION[31]), .I2
    (INSTRUCTION[24]), .I3(INSTRUCTION[30]), .O(X1N6151));
  D2_4E X1I6150 (.A0(INSTRUCTION[26]), .A1(INSTRUCTION[27]), .D0(X1N6156), 
    .D1(X1N6158), .D2(X1N6160), .D3(X1N6161), .E(X1N6151));
  AND2 X1I6155 (.I0(X1N6156), .I1(GND), .O(X1N6175));
  AND2 X1I6157 (.I0(X1N6158), .I1(GND), .O(X1N6173));
  AND2 X1I6159 (.I0(X1N6160), .I1(GND), .O(X1N6171));
  AND2 X1I6162 (.I0(X1N6161), .I1(GND), .O(X1N6169));
  OR4 X1I6168 (.I0(X1N6169), .I1(X1N6171), .I2(X1N6173), .I3(X1N6175), .O
    (X1N6177));
  AND2B1 X1I617 (.I0(SET_R0), .I1(REG_DEST_RT_RD[2]), .O(X1N616));
  OR2 X1I620 (.I0(SET_R31), .I1(X1N623), .O(REG_DEST_FETCH[3]));
  OR2 X1I6215 (.I0(JMP2REG), .I1(TAKEBRANCH), .O(BRANCH));
  AND2B1 X1I6219 (.I0(BRANCH), .I1(GLB_EN), .O(X1N6218));
  AND2B1 X1I624 (.I0(SET_R0), .I1(REG_DEST_RT_RD[3]), .O(X1N623));
  MUX2_1X32 X1I6289 (.A({PC_PLUS_FOUR[31], PC_PLUS_FOUR[30], 
    PC_PLUS_FOUR[29], PC_PLUS_FOUR[28], PC_PLUS_FOUR[27], PC_PLUS_FOUR[26], 
    PC_PLUS_FOUR[25], PC_PLUS_FOUR[24], PC_PLUS_FOUR[23], PC_PLUS_FOUR[22], 
    PC_PLUS_FOUR[21], PC_PLUS_FOUR[20], PC_PLUS_FOUR[19], PC_PLUS_FOUR[18], 
    PC_PLUS_FOUR[17], PC_PLUS_FOUR[16], PC_PLUS_FOUR[15], PC_PLUS_FOUR[14], 
    PC_PLUS_FOUR[13], PC_PLUS_FOUR[12], PC_PLUS_FOUR[11], PC_PLUS_FOUR[10], 
    PC_PLUS_FOUR[9], PC_PLUS_FOUR[8], PC_PLUS_FOUR[7], PC_PLUS_FOUR[6], 
    PC_PLUS_FOUR[5], PC_PLUS_FOUR[4], PC_PLUS_FOUR[3], PC_PLUS_FOUR[2], 
    PC_PLUS_FOUR[1], PC_PLUS_FOUR[0]}), .B({ALU_PC[31], ALU_PC[30], 
    ALU_PC[29], ALU_PC[28], ALU_PC[27], ALU_PC[26], ALU_PC[25], ALU_PC[24], 
    ALU_PC[23], ALU_PC[22], ALU_PC[21], ALU_PC[20], ALU_PC[19], ALU_PC[18], 
    ALU_PC[17], ALU_PC[16], ALU_PC[15], ALU_PC[14], ALU_PC[13], ALU_PC[12], 
    ALU_PC[11], ALU_PC[10], ALU_PC[9], ALU_PC[8], ALU_PC[7], ALU_PC[6], 
    ALU_PC[5], ALU_PC[4], ALU_PC[3], ALU_PC[2], ALU_PC[1], ALU_PC[0]}), .SB
    (INST_ADDR_ERROR), .S({NEXT_STORED_PC[31], NEXT_STORED_PC[30], 
    NEXT_STORED_PC[29], NEXT_STORED_PC[28], NEXT_STORED_PC[27], 
    NEXT_STORED_PC[26], NEXT_STORED_PC[25], NEXT_STORED_PC[24], 
    NEXT_STORED_PC[23], NEXT_STORED_PC[22], NEXT_STORED_PC[21], 
    NEXT_STORED_PC[20], NEXT_STORED_PC[19], NEXT_STORED_PC[18], 
    NEXT_STORED_PC[17], NEXT_STORED_PC[16], NEXT_STORED_PC[15], 
    NEXT_STORED_PC[14], NEXT_STORED_PC[13], NEXT_STORED_PC[12], 
    NEXT_STORED_PC[11], NEXT_STORED_PC[10], NEXT_STORED_PC[9], 
    NEXT_STORED_PC[8], NEXT_STORED_PC[7], NEXT_STORED_PC[6], 
    NEXT_STORED_PC[5], NEXT_STORED_PC[4], NEXT_STORED_PC[3], 
    NEXT_STORED_PC[2], NEXT_STORED_PC[1], NEXT_STORED_PC[0]}));
  FDE X1I6307 (.C(CLK1), .CE(GLB_EN), .D(RESET_IN), .Q(RESET));
  FDE X1I6314 (.C(CLK1), .CE(GLB_EN), .D(SET_R31), .Q(SET_R31_EXE));
  OR2 X1I6334 (.I0(X1N6337), .I1(RESET_IN), .O(INTERRUPT_MEM));
  AND3 X1I6336 (.I0(GLB_EN), .I1(CLK2_NBUF), .I2(X1N6323), .O(X1N6337));
  OR2 X1I634 (.I0(SET_R31), .I1(X1N637), .O(REG_DEST_FETCH[4]));
  INV X1I6364 (.I(INTERRUPT_MEM), .O(X1N6365));
  AND2B1 X1I638 (.I0(SET_R0), .I1(REG_DEST_RT_RD[4]), .O(X1N637));
  OR2 X1I6394 (.I0(X1N6396), .I1(X1N6395), .O(ENABLE_ROM));
  AND5B4 X1I6403 (.I0(MMU_NOT_VALID_DATA), .I1(EXC_CODE[4]), .I2
    (EXC_CODE[3]), .I3(EXC_CODE[2]), .I4(EXC_CODE[1]), .O(X1N6409));
  AND2 X1I6420 (.I0(CACHE), .I1(EXE_FF[1]), .O(X1N6421));
  AND2 X1I6422 (.I0(CACHE), .I1(EXE_FF[0]), .O(X1N6439));
  AND2 X1I6431 (.I0(CACHE), .I1(EXE_FF[1]), .O(X1N6433));
  AND2 X1I6432 (.I0(CACHE), .I1(EXE_FF[0]), .O(X1N6434));
  OR3 X1I6450 (.I0(X1N5460), .I1(X1N5459), .I2(X1N5975), .O
    (INT_UNALIGNED_ACCESS));
  FD X1I6454 (.C(X1N6461), .D(X1N6456), .Q(X1N6457));
  INV X1I6455 (.I(X1N6457), .O(X1N6456));
  FD X1I6458 (.C(X1N6462), .D(X1N6460), .Q(X1N6461));
  INV X1I6459 (.I(X1N6461), .O(X1N6460));
  MEM X1I6505 (.ADDRESS({ADDRESS[31], ADDRESS[30], ADDRESS[29], ADDRESS[28]
    , ADDRESS[27], ADDRESS[26], ADDRESS[25], ADDRESS[24], ADDRESS[23], 
    ADDRESS[22], ADDRESS[21], ADDRESS[20], ADDRESS[19], ADDRESS[18], 
    ADDRESS[17], ADDRESS[16], ADDRESS[15], ADDRESS[14], ADDRESS[13], 
    ADDRESS[12], ADDRESS[11], ADDRESS[10], ADDRESS[9], ADDRESS[8], 
    ADDRESS[7], ADDRESS[6], ADDRESS[5], ADDRESS[4], ADDRESS[3], ADDRESS[2], 
    ADDRESS[1], ADDRESS[0]}), .CE(ENABLE_RAM2), .MEM_READ_DATA({RAM_READ[31]
    , RAM_READ[30], RAM_READ[29], RAM_READ[28], RAM_READ[27], RAM_READ[26], 
    RAM_READ[25], RAM_READ[24], RAM_READ[23], RAM_READ[22], RAM_READ[21], 
    RAM_READ[20], RAM_READ[19], RAM_READ[18], RAM_READ[17], RAM_READ[16], 
    RAM_READ[15], RAM_READ[14], RAM_READ[13], RAM_READ[12], RAM_READ[11], 
    RAM_READ[10], RAM_READ[9], RAM_READ[8], RAM_READ[7], RAM_READ[6], 
    RAM_READ[5], RAM_READ[4], RAM_READ[3], RAM_READ[2], RAM_READ[1], 
    RAM_READ[0]}), .OE(X1N6527), .WR(X1N6510), .WRITE_DATA({MEM_DAT[31], 
    MEM_DAT[30], MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], 
    MEM_DAT[25], MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], 
    MEM_DAT[20], MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], 
    MEM_DAT[15], MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], 
    MEM_DAT[10], MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5]
    , MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  AND2B1 X1I6508 (.I0(END_WRITE), .I1(MEM_WRITE), .O(X1N6510));
  AND3B2 X1I6509 (.I0(ADDRESS[27]), .I1(ADDRESS[28]), .I2(MEMORY), .O
    (ENABLE_RAM2));
  AND2B1 X1I6511 (.I0(MEM_WRITE), .I1(ENABLE_RAM2), .O(X1N6519));
  BUFE32 X1I6514 (.E(X1N6519), .I({RAM_READ[31], RAM_READ[30], RAM_READ[29]
    , RAM_READ[28], RAM_READ[27], RAM_READ[26], RAM_READ[25], RAM_READ[24], 
    RAM_READ[23], RAM_READ[22], RAM_READ[21], RAM_READ[20], RAM_READ[19], 
    RAM_READ[18], RAM_READ[17], RAM_READ[16], RAM_READ[15], RAM_READ[14], 
    RAM_READ[13], RAM_READ[12], RAM_READ[11], RAM_READ[10], RAM_READ[9], 
    RAM_READ[8], RAM_READ[7], RAM_READ[6], RAM_READ[5], RAM_READ[4], 
    RAM_READ[3], RAM_READ[2], RAM_READ[1], RAM_READ[0]}), .O({MEM_DAT[31], 
    MEM_DAT[30], MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], 
    MEM_DAT[25], MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], 
    MEM_DAT[20], MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], 
    MEM_DAT[15], MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], 
    MEM_DAT[10], MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5]
    , MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  INV X1I6526 (.I(MEM_WRITE), .O(X1N6527));
  AND3 X1I6588 (.I0(ADDRESS[23]), .I1(ADDRESS[24]), .I2(ADDRESS[25]), .O
    (X1N6590));
  AND3 X1I6589 (.I0(MEMORY), .I1(X1N6590), .I2(X1N1870), .O(X1N5951));
  RAM32X32S X1I6599 (.A0(ADDRESS[2]), .A1(ADDRESS[3]), .A2(ADDRESS[4]), .A3
    (ADDRESS[5]), .A4(ADDRESS[6]), .D({MEM_DAT[31], MEM_DAT[30], MEM_DAT[29]
    , MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], 
    MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], 
    MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], 
    MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], 
    MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], 
    MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .O({RAM2_READ[31], RAM2_READ[30], 
    RAM2_READ[29], RAM2_READ[28], RAM2_READ[27], RAM2_READ[26], 
    RAM2_READ[25], RAM2_READ[24], RAM2_READ[23], RAM2_READ[22], 
    RAM2_READ[21], RAM2_READ[20], RAM2_READ[19], RAM2_READ[18], 
    RAM2_READ[17], RAM2_READ[16], RAM2_READ[15], RAM2_READ[14], 
    RAM2_READ[13], RAM2_READ[12], RAM2_READ[11], RAM2_READ[10], RAM2_READ[9]
    , RAM2_READ[8], RAM2_READ[7], RAM2_READ[6], RAM2_READ[5], RAM2_READ[4], 
    RAM2_READ[3], RAM2_READ[2], RAM2_READ[1], RAM2_READ[0]}), .WCLK(CLK1), 
    .WE(X1N6609));
  AND2B1 X1I6607 (.I0(MEM_WRITE), .I1(ENABLE_RAM), .O(X1N6613));
  AND2 X1I6608 (.I0(END_WRITE), .I1(ENABLE_RAM), .O(X1N6609));
  BUFE32 X1I6611 (.E(X1N6613), .I({RAM2_READ[31], RAM2_READ[30], 
    RAM2_READ[29], RAM2_READ[28], RAM2_READ[27], RAM2_READ[26], 
    RAM2_READ[25], RAM2_READ[24], RAM2_READ[23], RAM2_READ[22], 
    RAM2_READ[21], RAM2_READ[20], RAM2_READ[19], RAM2_READ[18], 
    RAM2_READ[17], RAM2_READ[16], RAM2_READ[15], RAM2_READ[14], 
    RAM2_READ[13], RAM2_READ[12], RAM2_READ[11], RAM2_READ[10], RAM2_READ[9]
    , RAM2_READ[8], RAM2_READ[7], RAM2_READ[6], RAM2_READ[5], RAM2_READ[4], 
    RAM2_READ[3], RAM2_READ[2], RAM2_READ[1], RAM2_READ[0]}), .O({
    MEM_DAT[31], MEM_DAT[30], MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], 
    MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], 
    MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], 
    MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], 
    MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6]
    , MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]
    }));
  AND3B1 X1I6620 (.I0(ADDRESS[27]), .I1(ADDRESS[28]), .I2(MEMORY), .O
    (ENABLE_RAM));
  AND2B1 X1I6630 (.I0(MEM_WRITE), .I1(DATA_MEM_ACCESS), .O(X1N6631));
  AND2B1 X1I6633 (.I0(SHIFT_SET), .I1(X1N6634), .O(OVERFLOW));
  BUFE32 X1I6639 (.E(OUTPUT), .I({REG_B_MEM_SHIFTED_MASKED[31], 
    REG_B_MEM_SHIFTED_MASKED[30], REG_B_MEM_SHIFTED_MASKED[29], 
    REG_B_MEM_SHIFTED_MASKED[28], REG_B_MEM_SHIFTED_MASKED[27], 
    REG_B_MEM_SHIFTED_MASKED[26], REG_B_MEM_SHIFTED_MASKED[25], 
    REG_B_MEM_SHIFTED_MASKED[24], REG_B_MEM_SHIFTED_MASKED[23], 
    REG_B_MEM_SHIFTED_MASKED[22], REG_B_MEM_SHIFTED_MASKED[21], 
    REG_B_MEM_SHIFTED_MASKED[20], REG_B_MEM_SHIFTED_MASKED[19], 
    REG_B_MEM_SHIFTED_MASKED[18], REG_B_MEM_SHIFTED_MASKED[17], 
    REG_B_MEM_SHIFTED_MASKED[16], REG_B_MEM_SHIFTED_MASKED[15], 
    REG_B_MEM_SHIFTED_MASKED[14], REG_B_MEM_SHIFTED_MASKED[13], 
    REG_B_MEM_SHIFTED_MASKED[12], REG_B_MEM_SHIFTED_MASKED[11], 
    REG_B_MEM_SHIFTED_MASKED[10], REG_B_MEM_SHIFTED_MASKED[9], 
    REG_B_MEM_SHIFTED_MASKED[8], REG_B_MEM_SHIFTED_MASKED[7], 
    REG_B_MEM_SHIFTED_MASKED[6], REG_B_MEM_SHIFTED_MASKED[5], 
    REG_B_MEM_SHIFTED_MASKED[4], REG_B_MEM_SHIFTED_MASKED[3], 
    REG_B_MEM_SHIFTED_MASKED[2], REG_B_MEM_SHIFTED_MASKED[1], 
    REG_B_MEM_SHIFTED_MASKED[0]}), .O({CACHE_DAT[31], CACHE_DAT[30], 
    CACHE_DAT[29], CACHE_DAT[28], CACHE_DAT[27], CACHE_DAT[26], 
    CACHE_DAT[25], CACHE_DAT[24], CACHE_DAT[23], CACHE_DAT[22], 
    CACHE_DAT[21], CACHE_DAT[20], CACHE_DAT[19], CACHE_DAT[18], 
    CACHE_DAT[17], CACHE_DAT[16], CACHE_DAT[15], CACHE_DAT[14], 
    CACHE_DAT[13], CACHE_DAT[12], CACHE_DAT[11], CACHE_DAT[10], CACHE_DAT[9]
    , CACHE_DAT[8], CACHE_DAT[7], CACHE_DAT[6], CACHE_DAT[5], CACHE_DAT[4], 
    CACHE_DAT[3], CACHE_DAT[2], CACHE_DAT[1], CACHE_DAT[0]}));
  AND2B1 X1I6665 (.I0(RESET), .I1(TLB_REFIL), .O(X1N6667));
  FDE X1I6675 (.C(CLK1), .CE(GLB_EN), .D(X1N6409), .Q(TLB_REFIL));
  DCOUNT X1I6694 (.CLK(CLK1), .EN(X1N6709), .IN({MEM_DAT[31], MEM_DAT[30], 
    MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], 
    MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], 
    MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], 
    MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], 
    MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], 
    MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .LOAD(X1N6705), .O({
    COUNTER[31], COUNTER[30], COUNTER[29], COUNTER[28], COUNTER[27], 
    COUNTER[26], COUNTER[25], COUNTER[24], COUNTER[23], COUNTER[22], 
    COUNTER[21], COUNTER[20], COUNTER[19], COUNTER[18], COUNTER[17], 
    COUNTER[16], COUNTER[15], COUNTER[14], COUNTER[13], COUNTER[12], 
    COUNTER[11], COUNTER[10], COUNTER[9], COUNTER[8], COUNTER[7], COUNTER[6]
    , COUNTER[5], COUNTER[4], COUNTER[3], COUNTER[2], COUNTER[1], COUNTER[0]
    }), .ZERO(COUNTER_ZERO));
  BUFE32 X1I6698 (.E(X1N6697), .I({COUNTER[31], COUNTER[30], COUNTER[29], 
    COUNTER[28], COUNTER[27], COUNTER[26], COUNTER[25], COUNTER[24], 
    COUNTER[23], COUNTER[22], COUNTER[21], COUNTER[20], COUNTER[19], 
    COUNTER[18], COUNTER[17], COUNTER[16], COUNTER[15], COUNTER[14], 
    COUNTER[13], COUNTER[12], COUNTER[11], COUNTER[10], COUNTER[9], 
    COUNTER[8], COUNTER[7], COUNTER[6], COUNTER[5], COUNTER[4], COUNTER[3], 
    COUNTER[2], COUNTER[1], COUNTER[0]}), .O({MEM_DAT[31], MEM_DAT[30], 
    MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], 
    MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], 
    MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], 
    MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], 
    MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], 
    MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  AND2B1 X1I6699 (.I0(MEM_WRITE), .I1(ENABLE_COUNTER), .O(X1N6697));
  AND2 X1I6704 (.I0(END_WRITE), .I1(ENABLE_COUNTER), .O(X1N6705));
  BUFE X1I6720 (.E(X1N2760), .I(SERIAL_ACK), .O(MEM_DAT[9]));
  REG32 X1I6772 (.CLK(CLK1), .EN(END_READ_B4_WRITE), .I({MEM_DAT[31], 
    MEM_DAT[30], MEM_DAT[29], MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], 
    MEM_DAT[25], MEM_DAT[24], MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], 
    MEM_DAT[20], MEM_DAT[19], MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], 
    MEM_DAT[15], MEM_DAT[14], MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], 
    MEM_DAT[10], MEM_DAT[9], MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5]
    , MEM_DAT[4], MEM_DAT[3], MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}), .O({
    MEMORY_BEFRE_WRITE[31], MEMORY_BEFRE_WRITE[30], MEMORY_BEFRE_WRITE[29], 
    MEMORY_BEFRE_WRITE[28], MEMORY_BEFRE_WRITE[27], MEMORY_BEFRE_WRITE[26], 
    MEMORY_BEFRE_WRITE[25], MEMORY_BEFRE_WRITE[24], MEMORY_BEFRE_WRITE[23], 
    MEMORY_BEFRE_WRITE[22], MEMORY_BEFRE_WRITE[21], MEMORY_BEFRE_WRITE[20], 
    MEMORY_BEFRE_WRITE[19], MEMORY_BEFRE_WRITE[18], MEMORY_BEFRE_WRITE[17], 
    MEMORY_BEFRE_WRITE[16], MEMORY_BEFRE_WRITE[15], MEMORY_BEFRE_WRITE[14], 
    MEMORY_BEFRE_WRITE[13], MEMORY_BEFRE_WRITE[12], MEMORY_BEFRE_WRITE[11], 
    MEMORY_BEFRE_WRITE[10], MEMORY_BEFRE_WRITE[9], MEMORY_BEFRE_WRITE[8], 
    MEMORY_BEFRE_WRITE[7], MEMORY_BEFRE_WRITE[6], MEMORY_BEFRE_WRITE[5], 
    MEMORY_BEFRE_WRITE[4], MEMORY_BEFRE_WRITE[3], MEMORY_BEFRE_WRITE[2], 
    MEMORY_BEFRE_WRITE[1], MEMORY_BEFRE_WRITE[0]}));
  AND3B1 X1I6803 (.I0(COUNTER_ZERO), .I1(STATUS0), .I2(GLB_EN), .O(X1N6709)
    );
  FD X1I6825 (.C(X1N6832), .D(X1N6830), .Q(X1N6826));
  INV X1I6827 (.I(X1N2274), .O(X1N6831));
  INV X1I6828 (.I(X1N6826), .O(X1N6830));
  FD X1I6829 (.C(X1N6826), .D(X1N6831), .Q(X1N2274));
  INV X1I6834 (.I(X1N6832), .O(X1N6833));
  FD X1I6835 (.C(X1N6836), .D(X1N6833), .Q(X1N6832));
  INV X1I6838 (.I(X1N6836), .O(X1N6837));
  FD X1I6839 (.C(CLK), .D(X1N6837), .Q(X1N6836));
  OR4 X1I6844 (.I0(X1N4910), .I1(X1N4909), .I2(X1N4908), .I3(X1N5414), .O
    (X1N6846));
  AND2 X1I6845 (.I0(STATUS0), .I1(X1N6846), .O(EXT_INTERRUPT));
  BUF X1I6853 (.I(INT_UNALIGNED_ACCESS), .O(V_ADDRESS_ERROR));
  BUFE32 X1I6887 (.E(X1N6889), .I({GND[31], GND[30], GND[29], GND[28], 
    GND[27], GND[26], GND[25], GND[24], GND[23], GND[22], GND[21], GND[20], 
    GND[19], SW2, SW1, DISPLAY16, DISPLAY[15], DISPLAY[14], DISPLAY[13], 
    DISPLAY[12], DISPLAY[11], DISPLAY[10], DISPLAY[9], DISPLAY[8], 
    DISPLAY[7], DISPLAY[6], DISPLAY[5], DISPLAY[4], DISPLAY[3], DISPLAY[2], 
    DISPLAY[1], DISPLAY[0]}), .O({MEM_DAT[31], MEM_DAT[30], MEM_DAT[29], 
    MEM_DAT[28], MEM_DAT[27], MEM_DAT[26], MEM_DAT[25], MEM_DAT[24], 
    MEM_DAT[23], MEM_DAT[22], MEM_DAT[21], MEM_DAT[20], MEM_DAT[19], 
    MEM_DAT[18], MEM_DAT[17], MEM_DAT[16], MEM_DAT[15], MEM_DAT[14], 
    MEM_DAT[13], MEM_DAT[12], MEM_DAT[11], MEM_DAT[10], MEM_DAT[9], 
    MEM_DAT[8], MEM_DAT[7], MEM_DAT[6], MEM_DAT[5], MEM_DAT[4], MEM_DAT[3], 
    MEM_DAT[2], MEM_DAT[1], MEM_DAT[0]}));
  AND2B1 X1I6892 (.I0(MEM_WRITE), .I1(ENABLE_DISPLAY), .O(X1N6889));
  FDE X1I6895 (.C(CLK1), .CE(X1N3422), .D(MEM_DAT[16]), .Q(DISPLAY16));
  AND2 X1I6929 (.I0(END_WRITE), .I1(ENABLE_ROM), .O(X1N6933));
  AND2B1 X1I6935 (.I0(LDST_SHIFT0), .I1(LDST_SHIFT1), .O(X1N6938));
  GND X1I6939 (.G(X1N5651));
  REG5 X1I694 (.CLK(CLK1), .EN(GLB_EN), .I({REG_DEST_MEM[4], REG_DEST_MEM[3]
    , REG_DEST_MEM[2], REG_DEST_MEM[1], REG_DEST_MEM[0]}), .O({
    REG_DEST_WB[4], REG_DEST_WB[3], REG_DEST_WB[2], REG_DEST_WB[1], 
    REG_DEST_WB[0]}), .RES(FLUSH));
  AND2B1 X1I6941 (.I0(LDST_SHIFT0), .I1(LDST_SHIFT1), .O(X1N6944));
  GND X1I6946 (.G(X1N5516));
  CMP_EQ_5 X1I697 (.A({INSTRUCTION[25], INSTRUCTION[24], INSTRUCTION[23], 
    INSTRUCTION[22], INSTRUCTION[21]}), .B({REG_DEST_EXE[4], REG_DEST_EXE[3]
    , REG_DEST_EXE[2], REG_DEST_EXE[1], REG_DEST_EXE[0]}), .O(X1N6659));
  CMP_EQ_5 X1I704 (.A({INSTRUCTION[20], INSTRUCTION[19], INSTRUCTION[18], 
    INSTRUCTION[17], INSTRUCTION[16]}), .B({REG_DEST_EXE[4], REG_DEST_EXE[3]
    , REG_DEST_EXE[2], REG_DEST_EXE[1], REG_DEST_EXE[0]}), .O(X1N6656));
  FDE X1I710 (.C(CLK1), .CE(GLB_EN), .D(X1N6659), .Q(SEL_PORT_A_ALU));
  FDE X1I711 (.C(CLK1), .CE(GLB_EN), .D(X1N6656), .Q(SEL_PORT_B_ALU));
  FDE X1I731 (.C(CLK1), .CE(GLB_EN), .D(X1N739), .Q(SEL_PORT_B_MEM));
  FDE X1I732 (.C(CLK1), .CE(GLB_EN), .D(X1N740), .Q(SEL_PORT_A_MEM));
  CMP_EQ_5 X1I734 (.A({INSTRUCTION[25], INSTRUCTION[24], INSTRUCTION[23], 
    INSTRUCTION[22], INSTRUCTION[21]}), .B({REG_DEST_MEM[4], REG_DEST_MEM[3]
    , REG_DEST_MEM[2], REG_DEST_MEM[1], REG_DEST_MEM[0]}), .O(X1N740));
  CMP_EQ_5 X1I737 (.A({INSTRUCTION[20], INSTRUCTION[19], INSTRUCTION[18], 
    INSTRUCTION[17], INSTRUCTION[16]}), .B({REG_DEST_MEM[4], REG_DEST_MEM[3]
    , REG_DEST_MEM[2], REG_DEST_MEM[1], REG_DEST_MEM[0]}), .O(X1N739));
  ADD32 X1I755 (.A({LAST_PC_NULLED[31], LAST_PC_NULLED[30], 
    LAST_PC_NULLED[29], LAST_PC_NULLED[28], LAST_PC_NULLED[27], 
    LAST_PC_NULLED[26], LAST_PC_NULLED[25], LAST_PC_NULLED[24], 
    LAST_PC_NULLED[23], LAST_PC_NULLED[22], LAST_PC_NULLED[21], 
    LAST_PC_NULLED[20], LAST_PC_NULLED[19], LAST_PC_NULLED[18], 
    LAST_PC_NULLED[17], LAST_PC_NULLED[16], LAST_PC_NULLED[15], 
    LAST_PC_NULLED[14], LAST_PC_NULLED[13], LAST_PC_NULLED[12], 
    LAST_PC_NULLED[11], LAST_PC_NULLED[10], LAST_PC_NULLED[9], 
    LAST_PC_NULLED[8], LAST_PC_NULLED[7], LAST_PC_NULLED[6], 
    LAST_PC_NULLED[5], LAST_PC_NULLED[4], LAST_PC_NULLED[3], 
    LAST_PC_NULLED[2], LAST_PC_NULLED[1], LAST_PC_NULLED[0]}), .B({
    PC_BR_IMM[31], PC_BR_IMM[30], PC_BR_IMM[29], PC_BR_IMM[28], 
    PC_BR_IMM[27], PC_BR_IMM[26], PC_BR_IMM[25], PC_BR_IMM[24], 
    PC_BR_IMM[23], PC_BR_IMM[22], PC_BR_IMM[21], PC_BR_IMM[20], 
    PC_BR_IMM[19], PC_BR_IMM[18], PC_BR_IMM[17], PC_BR_IMM[16], 
    PC_BR_IMM[15], PC_BR_IMM[14], PC_BR_IMM[13], PC_BR_IMM[12], 
    PC_BR_IMM[11], PC_BR_IMM[10], PC_BR_IMM[9], PC_BR_IMM[8], PC_BR_IMM[7], 
    PC_BR_IMM[6], PC_BR_IMM[5], PC_BR_IMM[4], PC_BR_IMM[3], PC_BR_IMM[2], 
    PC_BR_IMM[1], PC_BR_IMM[0]}), .S({BRANCH[31], BRANCH[30], BRANCH[29], 
    BRANCH[28], BRANCH[27], BRANCH[26], BRANCH[25], BRANCH[24], BRANCH[23], 
    BRANCH[22], BRANCH[21], BRANCH[20], BRANCH[19], BRANCH[18], BRANCH[17], 
    BRANCH[16], BRANCH[15], BRANCH[14], BRANCH[13], BRANCH[12], BRANCH[11], 
    BRANCH[10], BRANCH[9], BRANCH[8], BRANCH[7], BRANCH[6], BRANCH[5], 
    BRANCH[4], BRANCH[3], BRANCH[2], BRANCH[1], BRANCH[0]}));
  AND4B2 X1I757 (.I0(INSTRUCTION[5]), .I1(INSTRUCTION[4]), .I2
    (INSTRUCTION[3]), .I3(SPECIAL), .O(JMP2REG));
  FDE X1I765 (.C(CLK1), .CE(GLB_EN), .D(SPECIAL), .Q(SPECIAL_EXE));
  NULL25TO0 X1I874 (.I({PC[31], PC[30], PC[29], PC[28], PC[27], PC[26], 
    PC[25], PC[24], PC[23], PC[22], PC[21], PC[20], PC[19], PC[18], PC[17], 
    PC[16], PC[15], PC[14], PC[13], PC[12], PC[11], PC[10], PC[9], PC[8], 
    PC[7], PC[6], PC[5], PC[4], PC[3], PC[2], PC[1], PC[0]}), .NULL
    (JUMPLONG), .O({LAST_PC_NULLED[31], LAST_PC_NULLED[30], 
    LAST_PC_NULLED[29], LAST_PC_NULLED[28], LAST_PC_NULLED[27], 
    LAST_PC_NULLED[26], LAST_PC_NULLED[25], LAST_PC_NULLED[24], 
    LAST_PC_NULLED[23], LAST_PC_NULLED[22], LAST_PC_NULLED[21], 
    LAST_PC_NULLED[20], LAST_PC_NULLED[19], LAST_PC_NULLED[18], 
    LAST_PC_NULLED[17], LAST_PC_NULLED[16], LAST_PC_NULLED[15], 
    LAST_PC_NULLED[14], LAST_PC_NULLED[13], LAST_PC_NULLED[12], 
    LAST_PC_NULLED[11], LAST_PC_NULLED[10], LAST_PC_NULLED[9], 
    LAST_PC_NULLED[8], LAST_PC_NULLED[7], LAST_PC_NULLED[6], 
    LAST_PC_NULLED[5], LAST_PC_NULLED[4], LAST_PC_NULLED[3], 
    LAST_PC_NULLED[2], LAST_PC_NULLED[1], LAST_PC_NULLED[0]}));
  MUX3_1X32 X1I882 (.A({ALU_RES[31], ALU_RES[30], ALU_RES[29], ALU_RES[28], 
    ALU_RES[27], ALU_RES[26], ALU_RES[25], ALU_RES[24], ALU_RES[23], 
    ALU_RES[22], ALU_RES[21], ALU_RES[20], ALU_RES[19], ALU_RES[18], 
    ALU_RES[17], ALU_RES[16], ALU_RES[15], ALU_RES[14], ALU_RES[13], 
    ALU_RES[12], ALU_RES[11], ALU_RES[10], ALU_RES[9], ALU_RES[8], 
    ALU_RES[7], ALU_RES[6], ALU_RES[5], ALU_RES[4], ALU_RES[3], ALU_RES[2], 
    ALU_RES[1], ALU_RES[0]}), .B({SHIFT_SET, SHIFT_RES[31], SHIFT_RES[30], 
    SHIFT_RES[29], SHIFT_RES[28], SHIFT_RES[27], SHIFT_RES[26], 
    SHIFT_RES[25], SHIFT_RES[24], SHIFT_RES[23], SHIFT_RES[22], 
    SHIFT_RES[21], SHIFT_RES[20], SHIFT_RES[19], SHIFT_RES[18], 
    SHIFT_RES[17], SHIFT_RES[16], SHIFT_RES[15], SHIFT_RES[14], 
    SHIFT_RES[13], SHIFT_RES[12], SHIFT_RES[11], SHIFT_RES[10], SHIFT_RES[9]
    , SHIFT_RES[8], SHIFT_RES[7], SHIFT_RES[6], SHIFT_RES[5], SHIFT_RES[4], 
    SHIFT_RES[3], SHIFT_RES[2], SHIFT_RES[1], SHIFT_RES[0]}), .C({
    SET_R31_EXE, PC_TO_PIPELINE[31], PC_TO_PIPELINE[30], PC_TO_PIPELINE[29]
    , PC_TO_PIPELINE[28], PC_TO_PIPELINE[27], PC_TO_PIPELINE[26], 
    PC_TO_PIPELINE[25], PC_TO_PIPELINE[24], PC_TO_PIPELINE[23], 
    PC_TO_PIPELINE[22], PC_TO_PIPELINE[21], PC_TO_PIPELINE[20], 
    PC_TO_PIPELINE[19], PC_TO_PIPELINE[18], PC_TO_PIPELINE[17], 
    PC_TO_PIPELINE[16], PC_TO_PIPELINE[15], PC_TO_PIPELINE[14], 
    PC_TO_PIPELINE[13], PC_TO_PIPELINE[12], PC_TO_PIPELINE[11], 
    PC_TO_PIPELINE[10], PC_TO_PIPELINE[9], PC_TO_PIPELINE[8], 
    PC_TO_PIPELINE[7], PC_TO_PIPELINE[6], PC_TO_PIPELINE[5], 
    PC_TO_PIPELINE[4], PC_TO_PIPELINE[3], PC_TO_PIPELINE[2], 
    PC_TO_PIPELINE[1], PC_TO_PIPELINE[0]}), .S({EXE_RES[31], EXE_RES[30], 
    EXE_RES[29], EXE_RES[28], EXE_RES[27], EXE_RES[26], EXE_RES[25], 
    EXE_RES[24], EXE_RES[23], EXE_RES[22], EXE_RES[21], EXE_RES[20], 
    EXE_RES[19], EXE_RES[18], EXE_RES[17], EXE_RES[16], EXE_RES[15], 
    EXE_RES[14], EXE_RES[13], EXE_RES[12], EXE_RES[11], EXE_RES[10], 
    EXE_RES[9], EXE_RES[8], EXE_RES[7], EXE_RES[6], EXE_RES[5], EXE_RES[4], 
    EXE_RES[3], EXE_RES[2], EXE_RES[1], EXE_RES[0]}));
  SHIFTER X1I888 (.ARITH(OP[0]), .I({B_EXE_INPUT[31], B_EXE_INPUT[30], 
    B_EXE_INPUT[29], B_EXE_INPUT[28], B_EXE_INPUT[27], B_EXE_INPUT[26], 
    B_EXE_INPUT[25], B_EXE_INPUT[24], B_EXE_INPUT[23], B_EXE_INPUT[22], 
    B_EXE_INPUT[21], B_EXE_INPUT[20], B_EXE_INPUT[19], B_EXE_INPUT[18], 
    B_EXE_INPUT[17], B_EXE_INPUT[16], B_EXE_INPUT[15], B_EXE_INPUT[14], 
    B_EXE_INPUT[13], B_EXE_INPUT[12], B_EXE_INPUT[11], B_EXE_INPUT[10], 
    B_EXE_INPUT[9], B_EXE_INPUT[8], B_EXE_INPUT[7], B_EXE_INPUT[6], 
    B_EXE_INPUT[5], B_EXE_INPUT[4], B_EXE_INPUT[3], B_EXE_INPUT[2], 
    B_EXE_INPUT[1], B_EXE_INPUT[0]}), .O({SHIFT_RES[31], SHIFT_RES[30], 
    SHIFT_RES[29], SHIFT_RES[28], SHIFT_RES[27], SHIFT_RES[26], 
    SHIFT_RES[25], SHIFT_RES[24], SHIFT_RES[23], SHIFT_RES[22], 
    SHIFT_RES[21], SHIFT_RES[20], SHIFT_RES[19], SHIFT_RES[18], 
    SHIFT_RES[17], SHIFT_RES[16], SHIFT_RES[15], SHIFT_RES[14], 
    SHIFT_RES[13], SHIFT_RES[12], SHIFT_RES[11], SHIFT_RES[10], SHIFT_RES[9]
    , SHIFT_RES[8], SHIFT_RES[7], SHIFT_RES[6], SHIFT_RES[5], SHIFT_RES[4], 
    SHIFT_RES[3], SHIFT_RES[2], SHIFT_RES[1], SHIFT_RES[0]}), .RIGHT(OP[1])
    , .SHIFT({SHIFT[4], SHIFT[3], SHIFT[2], SHIFT[1], SHIFT[0]}));

// WARNING - Component X1I882 has a vector with the same name as a pin: B
// WARNING - Component X1I514 has a vector with the same name as a pin: B
// WARNING - Component X1I444 has a vector with the same name as a pin: B
// WARNING - Component X1I314 has a vector with the same name as a pin: B
// WARNING - Component X1I882 has a vector with the same name as a pin: C
// WARNING - Component X1I514 has a vector with the same name as a pin: C
// WARNING - Component X1I444 has a vector with the same name as a pin: C
// WARNING - Component X1I314 has a vector with the same name as a pin: C
// WARNING - Component IGNORE_NO_LOAD3 has unconnected pins: 0 input, 6 output, 0 inout.
// WARNING - Component IGNORE_NO_LOAD1 has unconnected pins: 0 input, 11 output, 0 inout.
// WARNING - Component X1I5985 has unconnected pins: 0 input, 1 output, 0 inout.
// WARNING - Component IGNORE_NO_LOAD2 has unconnected pins: 0 input, 10 output, 0 inout.
// WARNING - Global net INSTRUCTION30,INSTRUCTION[27:26],BRANCH,INST_ADDR_ERROR is not defined in the .cfg file or no NETTYPE= attribute associated with it
endmodule  // X1
