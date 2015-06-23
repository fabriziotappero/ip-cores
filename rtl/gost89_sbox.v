module gost89_sbox(
  input      [63:0] sbox,
  input      [3:0]  in,
  output reg [3:0]  out
);
  always @(in or sbox)
    case (in)
      4'h0: out <= sbox[63:60];
      4'h1: out <= sbox[59:56];
      4'h2: out <= sbox[55:52];
      4'h3: out <= sbox[51:48];
      4'h4: out <= sbox[47:44];
      4'h5: out <= sbox[43:40];
      4'h6: out <= sbox[39:36];
      4'h7: out <= sbox[35:32];
      4'h8: out <= sbox[31:28];
      4'h9: out <= sbox[27:24];
      4'ha: out <= sbox[23:20];
      4'hb: out <= sbox[19:16];
      4'hc: out <= sbox[15:12];
      4'hd: out <= sbox[11:8];
      4'he: out <= sbox[7:4];
      4'hf: out <= sbox[3:0];
    endcase
endmodule
