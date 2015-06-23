
`include "../sv/tb_mod.sv"

module tb_top ();

  // default stimulus file name
  string stm_file  = "../stm/stimulus_file.stm";
  string tmp_fn;
  //  handle the plus args  Change stimulus file name.
  initial begin : file_select
    if($value$plusargs("STM_FILE=%s", tmp_fn)) begin
      stm_file = tmp_fn;
    end
  end
  
  dut_if theif();

  dut_module u1 (
    .rst_n    (theif.rst_n),
    .clk      (theif.clk),
    .out1     (theif.out1),
    .out2     (theif.out2),
    .addr     (theif.addr),
    .data_in  (theif.data_in),
    .data_out (theif.data_out),
    .sel      (theif.sel),
    .ack      (theif.ack)
  );

  
  tb_mod tb_inst(theif);

endmodule // tb_top
