module gost89_round(
  input          clk,
  input  [511:0] sbox,
  input  [31:0]  key,
  input  [31:0]  n1,
  input  [31:0]  n2,
  output [31:0]  out1,
  output [31:0]  out2
);
  wire [31:0] tmp1, tmp2;

  assign tmp1 = n1 + key;

  gost89_sbox
    sbox1(sbox[511:448], tmp1[3:0],   tmp2[3:0]),
    sbox2(sbox[447:384], tmp1[7:4],   tmp2[7:4]),
    sbox3(sbox[383:320], tmp1[11:8],  tmp2[11:8]),
    sbox4(sbox[319:256], tmp1[15:12], tmp2[15:12]),
    sbox5(sbox[255:192], tmp1[19:16], tmp2[19:16]),
    sbox6(sbox[191:128], tmp1[23:20], tmp2[23:20]),
    sbox7(sbox[127:64],  tmp1[27:24], tmp2[27:24]),
    sbox8(sbox[63 :0],   tmp1[31:28], tmp2[31:28]);

  assign out1[10:0]  = tmp2[31:21] ^ n2[10:0];
  assign out1[31:11] = tmp2[20:0]  ^ n2[31:11];

  assign out2 = n1;
endmodule
