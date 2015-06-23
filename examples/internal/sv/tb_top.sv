
`include "../sv/tb_mod.sv"

module tb_top ();

  top U1 (
    .rst_n  (theif.rst_n),
    .clk    (theif.clk),
    .out1   (),
    .in1    (),
    .state  ()
  );

  dut_if theif();

  tb_prg prg_inst(theif);

endmodule
