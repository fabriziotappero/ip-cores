`timescale 1ns/10ps

module flash_stub (
    input  [20:0] flash_addr_,
    output [31:0] flash_data_,
    input         flash_oe_n_,
    input         flash_we_n_,
    input         flash_ce2_
  );

  // Registers and nets
  reg  [31:0] rom[2**21-1:0];
  reg  [31:0] dat_o;

  // Continous assignments
  assign flash_data_ = flash_ce2_ ? dat_o : 32'hzzzzzzzz;

  // Behaviour
  initial $readmemh("00_mov.ml403", rom, 21'h0);
  initial $readmemh("hd.ml403",   rom, 21'h100000);

  always @(*) dat_o <= #110
    (!flash_oe_n_ & flash_we_n_ & flash_ce2_) ?
      rom[flash_addr_] : 32'hzzzzzzzz;

endmodule
