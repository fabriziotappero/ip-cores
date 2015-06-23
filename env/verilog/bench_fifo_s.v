`timescale 1ns/1ns

module bench_fifo_s;

  reg clk, reset;

  localparam width = 8;

  initial clk = 0;
  always #10 clk = ~clk;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [width-1:0]	chk_data;		// From fifo_s of sd_fifo_s.v
  wire			chk_drdy;		// From chk of sd_seq_check.v
  wire			chk_srdy;		// From fifo_s of sd_fifo_s.v
  wire [width-1:0]	gen_data;		// From gen of sd_seq_gen.v
  wire			gen_drdy;		// From fifo_s of sd_fifo_s.v
  wire			gen_srdy;		// From gen of sd_seq_gen.v
  // End of automatics

/* sd_seq_gen AUTO_TEMPLATE
 (
 .p_\(.*\)   (gen_\1[]),
 );
 */
  sd_seq_gen gen
    (/*AUTOINST*/
     // Outputs
     .p_srdy				(gen_srdy),		 // Templated
     .p_data				(gen_data[width-1:0]),	 // Templated
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .p_drdy				(gen_drdy));		 // Templated

/* sd_seq_check AUTO_TEMPLATE
 (
 .c_\(.*\)   (chk_\1[]),
 );
 */
  sd_seq_check chk
    (/*AUTOINST*/
     // Outputs
     .c_drdy				(chk_drdy),		 // Templated
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(chk_srdy),		 // Templated
     .c_data				(chk_data[width-1:0]));	 // Templated

/* sd_fifo_s AUTO_TEMPLATE
 (
     .c_clk				(clk),
     .c_reset				(reset),
     .p_clk				(clk),
     .p_reset				(reset),
     .p_\(.*\)   (chk_\1[]),
     .c_\(.*\)   (gen_\1[]),
 );
 */
  sd_fifo_s #(8, 32, 1) fifo_s
    (/*AUTOINST*/
     // Outputs
     .c_drdy				(gen_drdy),		 // Templated
     .p_srdy				(chk_srdy),		 // Templated
     .p_data				(chk_data[width-1:0]),	 // Templated
     // Inputs
     .c_clk				(clk),			 // Templated
     .c_reset				(reset),		 // Templated
     .c_srdy				(gen_srdy),		 // Templated
     .c_data				(gen_data[width-1:0]),	 // Templated
     .p_clk				(clk),			 // Templated
     .p_reset				(reset),		 // Templated
     .p_drdy				(chk_drdy));		 // Templated

  initial
    begin
      $dumpfile("fifo_s.vcd");
      $dumpvars;
      reset = 1;
      #100;
      reset = 0;

      gen.rep_count = 1000;

      // burst normal data for 20 cycles
      repeat (20) @(posedge clk);

      gen.srdy_pat = 8'h5A;
      repeat (20) @(posedge clk);

      chk.drdy_pat = 8'hA5;
      repeat (40) @(posedge clk);

      // check FIFO overflow
      gen.srdy_pat = 8'hFD;
      repeat (100) @(posedge clk);

      // check FIFO underflow
      gen.srdy_pat = 8'h11;
      repeat (100) @(posedge clk);

      #5000;
      $finish;
    end

endmodule // bench_fifo_s
// Local Variables:
// verilog-library-directories:("." "../../rtl/verilog/buffers")
// End:
