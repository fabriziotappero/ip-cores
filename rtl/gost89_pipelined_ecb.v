module gost89_pipelined_ecb_encrypt(
  input          clk,
  input  [511:0] sbox,
  input  [255:0] key,
  input  [63:0]  in,
  output [63:0]  out
);
  reg  [31:0] n1[31:0], n2[31:0];
  wire [31:0] out1[31:0], out2[31:0];

  always @(posedge clk) begin
    n1[0]  <= in[63:32]; n2[0]  <= in[31:0];
    n1[1]  <= out1[0];   n2[1]  <= out2[0];
    n1[2]  <= out1[1];   n2[2]  <= out2[1];
    n1[3]  <= out1[2];   n2[3]  <= out2[2];
    n1[4]  <= out1[3];   n2[4]  <= out2[3];
    n1[5]  <= out1[4];   n2[5]  <= out2[4];
    n1[6]  <= out1[5];   n2[6]  <= out2[5];
    n1[7]  <= out1[6];   n2[7]  <= out2[6];
    n1[8]  <= out1[7];   n2[8]  <= out2[7];
    n1[9]  <= out1[8];   n2[9]  <= out2[8];
    n1[10] <= out1[9];   n2[10] <= out2[9];
    n1[11] <= out1[10];  n2[11] <= out2[10];
    n1[12] <= out1[11];  n2[12] <= out2[11];
    n1[13] <= out1[12];  n2[13] <= out2[12];
    n1[14] <= out1[13];  n2[14] <= out2[13];
    n1[15] <= out1[14];  n2[15] <= out2[14];
    n1[16] <= out1[15];  n2[16] <= out2[15];
    n1[17] <= out1[16];  n2[17] <= out2[16];
    n1[18] <= out1[17];  n2[18] <= out2[17];
    n1[19] <= out1[18];  n2[19] <= out2[18];
    n1[20] <= out1[19];  n2[20] <= out2[19];
    n1[21] <= out1[20];  n2[21] <= out2[20];
    n1[22] <= out1[21];  n2[22] <= out2[21];
    n1[23] <= out1[22];  n2[23] <= out2[22];
    n1[24] <= out1[23];  n2[24] <= out2[23];
    n1[25] <= out1[24];  n2[25] <= out2[24];
    n1[26] <= out1[25];  n2[26] <= out2[25];
    n1[27] <= out1[26];  n2[27] <= out2[26];
    n1[28] <= out1[27];  n2[28] <= out2[27];
    n1[29] <= out1[28];  n2[29] <= out2[28];
    n1[30] <= out1[29];  n2[30] <= out2[29];
    n1[31] <= out1[30];  n2[31] <= out2[30];
  end

  gost89_round
    r1 (clk, sbox, key[255:224], n1[0],  n2[0],  out1[0],  out2[0]),
    r2 (clk, sbox, key[223:192], n1[1],  n2[1],  out1[1],  out2[1]),
    r3 (clk, sbox, key[191:160], n1[2],  n2[2],  out1[2],  out2[2]),
    r4 (clk, sbox, key[159:128], n1[3],  n2[3],  out1[3],  out2[3]),
    r5 (clk, sbox, key[127:96],  n1[4],  n2[4],  out1[4],  out2[4]),
    r6 (clk, sbox, key[95:64],   n1[5],  n2[5],  out1[5],  out2[5]),
    r7 (clk, sbox, key[63:32],   n1[6],  n2[6],  out1[6],  out2[6]),
    r8 (clk, sbox, key[31:0],    n1[7],  n2[7],  out1[7],  out2[7]),
    r9 (clk, sbox, key[255:224], n1[8],  n2[8],  out1[8],  out2[8]),
    r10(clk, sbox, key[223:192], n1[9],  n2[9],  out1[9],  out2[9]),
    r11(clk, sbox, key[191:160], n1[10], n2[10], out1[10], out2[10]),
    r12(clk, sbox, key[159:128], n1[11], n2[11], out1[11], out2[11]),
    r13(clk, sbox, key[127:96],  n1[12], n2[12], out1[12], out2[12]),
    r14(clk, sbox, key[95:64],   n1[13], n2[13], out1[13], out2[13]),
    r15(clk, sbox, key[63:32],   n1[14], n2[14], out1[14], out2[14]),
    r16(clk, sbox, key[31:0],    n1[15], n2[15], out1[15], out2[15]),
    r17(clk, sbox, key[255:224], n1[16], n2[16], out1[16], out2[16]),
    r18(clk, sbox, key[223:192], n1[17], n2[17], out1[17], out2[17]),
    r19(clk, sbox, key[191:160], n1[18], n2[18], out1[18], out2[18]),
    r20(clk, sbox, key[159:128], n1[19], n2[19], out1[19], out2[19]),
    r21(clk, sbox, key[127:96],  n1[20], n2[20], out1[20], out2[20]),
    r22(clk, sbox, key[95:64],   n1[21], n2[21], out1[21], out2[21]),
    r23(clk, sbox, key[63:32],   n1[22], n2[22], out1[22], out2[22]),
    r24(clk, sbox, key[31:0],    n1[23], n2[23], out1[23], out2[23]),
    r25(clk, sbox, key[31:0],    n1[24], n2[24], out1[24], out2[24]),
    r26(clk, sbox, key[63:32],   n1[25], n2[25], out1[25], out2[25]),
    r27(clk, sbox, key[95:64],   n1[26], n2[26], out1[26], out2[26]),
    r28(clk, sbox, key[127:96],  n1[27], n2[27], out1[27], out2[27]),
    r29(clk, sbox, key[159:128], n1[28], n2[28], out1[28], out2[28]),
    r30(clk, sbox, key[191:160], n1[29], n2[29], out1[29], out2[29]),
    r31(clk, sbox, key[223:192], n1[30], n2[30], out1[30], out2[30]),
    r32(clk, sbox, key[255:224], n1[31], n2[31], out1[31], out2[31]);

  assign out[31:0]  = out1[31];
  assign out[63:32] = out2[31];
endmodule

module gost89_pipelined_ecb_decrypt(
  input          clk,
  input  [511:0] sbox,
  input  [255:0] key,
  input  [63:0]  in,
  output [63:0]  out
);
  reg  [31:0] n1[31:0], n2[31:0];
  wire [31:0] out1[31:0], out2[31:0];

  always @(posedge clk) begin
    n1[0]  <= in[63:32]; n2[0]  <= in[31:0];
    n1[1]  <= out1[0];   n2[1]  <= out2[0];
    n1[2]  <= out1[1];   n2[2]  <= out2[1];
    n1[3]  <= out1[2];   n2[3]  <= out2[2];
    n1[4]  <= out1[3];   n2[4]  <= out2[3];
    n1[5]  <= out1[4];   n2[5]  <= out2[4];
    n1[6]  <= out1[5];   n2[6]  <= out2[5];
    n1[7]  <= out1[6];   n2[7]  <= out2[6];
    n1[8]  <= out1[7];   n2[8]  <= out2[7];
    n1[9]  <= out1[8];   n2[9]  <= out2[8];
    n1[10] <= out1[9];   n2[10] <= out2[9];
    n1[11] <= out1[10];  n2[11] <= out2[10];
    n1[12] <= out1[11];  n2[12] <= out2[11];
    n1[13] <= out1[12];  n2[13] <= out2[12];
    n1[14] <= out1[13];  n2[14] <= out2[13];
    n1[15] <= out1[14];  n2[15] <= out2[14];
    n1[16] <= out1[15];  n2[16] <= out2[15];
    n1[17] <= out1[16];  n2[17] <= out2[16];
    n1[18] <= out1[17];  n2[18] <= out2[17];
    n1[19] <= out1[18];  n2[19] <= out2[18];
    n1[20] <= out1[19];  n2[20] <= out2[19];
    n1[21] <= out1[20];  n2[21] <= out2[20];
    n1[22] <= out1[21];  n2[22] <= out2[21];
    n1[23] <= out1[22];  n2[23] <= out2[22];
    n1[24] <= out1[23];  n2[24] <= out2[23];
    n1[25] <= out1[24];  n2[25] <= out2[24];
    n1[26] <= out1[25];  n2[26] <= out2[25];
    n1[27] <= out1[26];  n2[27] <= out2[26];
    n1[28] <= out1[27];  n2[28] <= out2[27];
    n1[29] <= out1[28];  n2[29] <= out2[28];
    n1[30] <= out1[29];  n2[30] <= out2[29];
    n1[31] <= out1[30];  n2[31] <= out2[30];
  end

  gost89_round
    r1 (clk, sbox, key[255:224], n1[0],  n2[0],  out1[0],  out2[0]),
    r2 (clk, sbox, key[223:192], n1[1],  n2[1],  out1[1],  out2[1]),
    r3 (clk, sbox, key[191:160], n1[2],  n2[2],  out1[2],  out2[2]),
    r4 (clk, sbox, key[159:128], n1[3],  n2[3],  out1[3],  out2[3]),
    r5 (clk, sbox, key[127:96],  n1[4],  n2[4],  out1[4],  out2[4]),
    r6 (clk, sbox, key[95:64],   n1[5],  n2[5],  out1[5],  out2[5]),
    r7 (clk, sbox, key[63:32],   n1[6],  n2[6],  out1[6],  out2[6]),
    r8 (clk, sbox, key[31:0],    n1[7],  n2[7],  out1[7],  out2[7]),
    r9 (clk, sbox, key[31:0],    n1[8],  n2[8],  out1[8],  out2[8]),
    r10(clk, sbox, key[63:32],   n1[9],  n2[9],  out1[9],  out2[9]),
    r11(clk, sbox, key[95:64],   n1[10], n2[10], out1[10], out2[10]),
    r12(clk, sbox, key[127:96],  n1[11], n2[11], out1[11], out2[11]),
    r13(clk, sbox, key[159:128], n1[12], n2[12], out1[12], out2[12]),
    r14(clk, sbox, key[191:160], n1[13], n2[13], out1[13], out2[13]),
    r15(clk, sbox, key[223:192], n1[14], n2[14], out1[14], out2[14]),
    r16(clk, sbox, key[255:224], n1[15], n2[15], out1[15], out2[15]),
    r17(clk, sbox, key[31:0],    n1[16], n2[16], out1[16], out2[16]),
    r18(clk, sbox, key[63:32],   n1[17], n2[17], out1[17], out2[17]),
    r19(clk, sbox, key[95:64],   n1[18], n2[18], out1[18], out2[18]),
    r20(clk, sbox, key[127:96],  n1[19], n2[19], out1[19], out2[19]),
    r21(clk, sbox, key[159:128], n1[20], n2[20], out1[20], out2[20]),
    r22(clk, sbox, key[191:160], n1[21], n2[21], out1[21], out2[21]),
    r23(clk, sbox, key[223:192], n1[22], n2[22], out1[22], out2[22]),
    r24(clk, sbox, key[255:224], n1[23], n2[23], out1[23], out2[23]),
    r25(clk, sbox, key[31:0],    n1[24], n2[24], out1[24], out2[24]),
    r26(clk, sbox, key[63:32],   n1[25], n2[25], out1[25], out2[25]),
    r27(clk, sbox, key[95:64],   n1[26], n2[26], out1[26], out2[26]),
    r28(clk, sbox, key[127:96],  n1[27], n2[27], out1[27], out2[27]),
    r29(clk, sbox, key[159:128], n1[28], n2[28], out1[28], out2[28]),
    r30(clk, sbox, key[191:160], n1[29], n2[29], out1[29], out2[29]),
    r31(clk, sbox, key[223:192], n1[30], n2[30], out1[30], out2[30]),
    r32(clk, sbox, key[255:224], n1[31], n2[31], out1[31], out2[31]);

  assign out[31:0]  = out1[31];
  assign out[63:32] = out2[31];
endmodule
