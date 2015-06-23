module sync_bench;

  parameter width = 16;
  
  reg a_clk, a_reset;
  reg b_clk, b_reset;
  
  wire [width-1:0]      a_data;

  wire                  a_srdy, a_drdy;
  wire                  b_srdy, b_drdy;

  initial
    begin
`ifdef VCS
      $vcdpluson;
`else
      $dumpfile ("sync.vcd");
      $dumpvars;
`endif
      
      a_clk = 0;
      b_clk = 0;
      a_reset = 1;
      b_reset = 1;
      #200;
      a_reset = 0;
      b_reset = 0;
      #200;

      seq_gen.send (25);

      seq_gen.srdy_pat = 8'h01;

      seq_gen.send (25);

      seq_gen.srdy_pat = 8'hFF;
      seq_chk.drdy_pat = 8'h01;

      seq_gen.send (25);

      seq_gen.srdy_pat = 8'h01;
      
      seq_gen.send (25);
      
      
      #2000;

      if (seq_chk.last_seq == 100)
        $display ("TEST PASSED");
      else
        $display ("TEST FAILED");
        
      $finish;
    end // initial begin

  initial
    begin
      #50000; // timeout value

      $display ("TEST FAILED");
      $finish;
    end

  always a_clk = #5 ~a_clk;
  always b_clk = #17 ~b_clk;
  
  sd_seq_gen #(.width(width)) seq_gen
    (
     .clk                               (a_clk),
     .reset                             (a_reset),
     .p_srdy                            (a_srdy),
     .p_data                            (a_data),
     // Inputs
     .p_drdy                            (a_drdy));
  
  sd_sync sync0
    (
     // Outputs
     .c_drdy                            (a_drdy),
     .p_srdy                            (b_srdy),
     // Inputs
     .c_clk                             (a_clk),
     .c_reset                           (a_reset),
     .c_srdy                            (a_srdy),
     .p_clk                             (b_clk),
     .p_reset                           (b_reset),
     .p_drdy                            (b_drdy));

  sd_seq_check #(.width(width)) seq_chk
    (
     // Outputs
     .c_drdy                            (b_drdy),
     // Inputs
     .clk                               (b_clk),
     .reset                             (b_reset),
     .c_srdy                            (b_srdy),
     .c_data                            (a_data));
  
endmodule // sync_bench
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/utility" "../common")
// End:


