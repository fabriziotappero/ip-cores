`timescale 1ns/1ns

module bench_bpdrop;

  reg clk, reset;

  initial
    begin
      clk = 0;
      forever clk = #5 ~clk;
    end

  wire a_srdy, a_drdy;
  wire [7:0] a_data;
  wire       b_srdy, b_drdy;

  wire       fr_start, fr_end;
  assign fr_start = a_data[1:0] == 0;
  assign fr_end   = a_data[1:0] == 3;

  sd_seq_gen #(.width(8)) sgen
    (
     // Outputs
     .p_srdy                            (a_srdy),
     .p_data                            (a_data[7:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .p_drdy                            (a_drdy));
  
  sd_bpdrop #(.cnt_sz(4)) bpdrop
    (
     // Outputs
     .nc_drdy                           (a_drdy),
     .np_srdy                           (b_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .g_max_count                       (4'd5),
     .c_srdy                            (a_srdy),
     .c_fr_start                        (fr_start),
     .c_fr_end                          (fr_end),
     .p_drdy                            (b_drdy));

  sd_seq_check #(.width(8)) scheck
    (
     // Outputs
     .c_drdy                            (b_drdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (b_srdy),
     .c_data                            (a_data[7:0]));

  initial
    begin
`ifdef VCS
      $vcdpluson;
`else
      $dumpfile("bench_bpdrop.vcd");
      $dumpvars;
`endif
      reset = 1;
      repeat (10) @(negedge clk);
      reset = 0;

      // initial flow control to drop
      scheck.drdy_pat = 8'h1;
      sgen.send(64);
      
      // still drop
      scheck.drdy_pat = 8'h7;
      sgen.send(64);

      // pass
      scheck.drdy_pat = 8'h88;
      sgen.send(64);
      
      #1000;
      $finish;
    end
      
  
endmodule // bench_bpdrop
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/utility/" "../common")
// End:
