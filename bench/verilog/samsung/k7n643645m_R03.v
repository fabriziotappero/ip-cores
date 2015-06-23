`define addr_bits 21
`define data_bits 36

module K7N643645M (
  Dq,
  Addr,
  K,
  CKEb,
  Bwa_n,
  Bwb_n,
  Bwc_n,
  Bwd_n,
  WEb,
  ADV,
  OEb,
  CS1b,
  CS2,
  CS2b,
  LBOb,
  ZZ); 

  parameter mem_sizes = 2 * 1024 * 1024 - 1;

  inout [(`data_bits - 1) : 0] Dq;
  input [(`addr_bits - 1) : 0] Addr;

  input K;
  input ADV;
  input CKEb;
  input WEb;

  input Bwa_n;
  input Bwb_n;
  input Bwc_n;
  input Bwd_n;

  input CS1b;
  input CS2;
  input CS2b;
  input OEb;
  input ZZ;
  input LBOb;

  initial 
  begin
    $display("Replace this file with the original file from Samsung. You can find it on the Samsung semiconductor home page under High Speed SRAM / NtRAM / K7N643645M");
  end
endmodule
