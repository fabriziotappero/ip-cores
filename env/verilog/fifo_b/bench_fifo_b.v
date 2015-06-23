`timescale 1ns/1ns

module bench_fifo_b;

  reg clk, reset;

  localparam width = 16, depth=32, asz=$clog2(depth), usz=$clog2(depth+1);

  initial clk = 0;
  always #10 clk = ~clk;

  reg gen_commit, gen_abort;
  reg chk_commit, chk_abort;
  reg fail;
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [width-1:0]      chk_data;               // From fifo_s of sd_fifo_b.v
  wire                  chk_drdy;               // From chk of sd_seq_check.v
  wire                  chk_srdy;               // From fifo_s of sd_fifo_b.v
  wire [usz-1:0]        chk_usage;              // From fifo_s of sd_fifo_b.v
  wire [width-1:0]      gen_data;               // From gen of sd_seq_gen.v
  wire                  gen_drdy;               // From fifo_s of sd_fifo_b.v
  wire                  gen_srdy;               // From gen of sd_seq_gen.v
  wire [usz-1:0]        gen_usage;              // From fifo_s of sd_fifo_b.v
  // End of automatics

/* sd_seq_gen AUTO_TEMPLATE
 (
 .p_\(.*\)   (gen_\1[]),
 );
 */
  sd_seq_gen #(width) gen
    (/*AUTOINST*/
     // Outputs
     .p_srdy                            (gen_srdy),              // Templated
     .p_data                            (gen_data[width-1:0]),   // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .p_drdy                            (gen_drdy));              // Templated

/* sd_seq_check AUTO_TEMPLATE
 (
 .c_\(.*\)   (chk_\1[]),
 );
 */
  sd_seq_check #(width) chk
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (chk_drdy),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (chk_srdy),              // Templated
     .c_data                            (chk_data[width-1:0]));   // Templated

/* sd_fifo_b AUTO_TEMPLATE
 (
     .p_\(.*\)   (chk_\1[]),
     .c_\(.*\)   (gen_\1[]),
 );
 */
  sd_fifo_b #(width, depth, 1, 1) fifo_b
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (gen_drdy),              // Templated
     .p_srdy                            (chk_srdy),              // Templated
     .p_data                            (chk_data[width-1:0]),   // Templated
     .p_usage                           (chk_usage[usz-1:0]),    // Templated
     .c_usage                           (gen_usage[usz-1:0]),    // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (gen_srdy),              // Templated
     .c_commit                          (gen_commit),            // Templated
     .c_abort                           (gen_abort),             // Templated
     .c_data                            (gen_data[width-1:0]),   // Templated
     .p_drdy                            (chk_drdy),              // Templated
     .p_commit                          (chk_commit),            // Templated
     .p_abort                           (chk_abort));             // Templated

  initial
    begin
`ifdef VCS
      $vcdpluson;
`else
      $dumpfile("fifo_b.lxt");
      $dumpvars;
`endif
      reset = 1;
      gen.rep_count = 0;
      gen_commit = 0;
      gen_abort  = 0;
      chk_commit = 1;
      chk_abort  = 0;
      fail = 0;
      #100;
      reset = 0;
      repeat (5) @(posedge clk);

      do_reset();
      test1();

      do_reset();
      test2();

      do_reset();
      test3();

      if (fail)
        $display ("!!!!! TEST FAILED !!!!!");
      else
        $display ("----- TEST PASSED -----");
      $finish;
    end // initial begin

  task do_reset;
    begin
      gen.rep_count = 0;
      gen_commit = 0;
      gen_abort  = 0;
      chk_commit = 1;
      chk_abort  = 0;
      reset = 1;
      repeat (5) @(posedge clk);
      reset = 0;
      
      repeat (10) @(posedge clk);
    end
  endtask // do_reset

  task end_check;
    begin
      if (chk.err_cnt > 0)
        fail = 1;
    end
  endtask
    

  // test basic overflow/underflow
  task test1;
    begin
      $display ("Running test 1");
      gen_commit = 1;
      //gen.rep_count = 2000;

      fork
        begin : traffic_gen
          gen.send (depth * 2);

          repeat (5) @(posedge clk);
          gen.srdy_pat = 8'h5A;
          gen.send (depth * 2);
     
          repeat (5) @(posedge clk);
          chk.drdy_pat = 8'hA5;
          gen.send (depth * 2);
      
          // check FIFO overflow
          repeat (5) @(posedge clk);
          gen.srdy_pat = 8'hFD;
          gen.send (depth * 4);

          // check FIFO underflow
          repeat (5) @(posedge clk);
          gen.srdy_pat = 8'h11;
          gen.send (depth * 4);

          repeat (20) @(posedge clk);
          disable t1_timeout;
        end // block: traffic_gen

        begin : t1_timeout
          repeat (50 * depth)
            @(posedge clk);
 
          fail = 1;
          disable traffic_gen;
          $display ("%t: ERROR: test1 timeout", $time);
        end
      join

      #500;
      end_check();
    end
  endtask // test1

  // test of write commit/abort behavior
  task test2;
    begin
      $display ("Running test 2");
      // first fill up entire FIFO
      //chk.drdy_pat = 0;
      gen_commit = 0;
      gen.send (depth-1);
      #50;

      wait (gen_drdy == 0);
      @(posedge clk);
      gen_abort <= #1 1;

      @(posedge clk);
      gen_abort <= #1 0;
      #5;
      if (gen_drdy !== 1)
	begin
	  $display ("%t: ERROR -- drdy should be asserted on empty FIFO", $time);
          fail = 1;
	  #100 $finish;
	end
      

      gen.send (depth-2);
      @(posedge clk);
      gen_commit <= 1;
      gen.send (1);
      gen_commit <= 0;

      repeat (depth+10)
	@(posedge clk);

      if (chk.last_seq != (depth*2-2))
	begin
	  $display ("%t: ERROR -- last sequence number incorrect (%x)", $time, chk.last_seq);
          fail = 1;
	  $finish;
	end
      

      #5000;
      end_check();
    end
  endtask // test2

  // test read/commit behavior
  task test3;
    begin
      $display ("Running test 3");
      // fill up FIFO
      gen_commit <= 1;
      chk_commit <= 0;
      chk_abort  <= 0;

      @(negedge clk);
      chk.drdy_pat = 0;
      chk.c_drdy = 0;
      chk.nxt_c_drdy = 0;

      repeat (10) @(posedge clk);
      gen.send (depth-1);

      // read out contents of FIFO
      chk.drdy_pat = 8'h5A;

      repeat (depth*2+2)
	@(posedge clk);
      chk.drdy_pat = 0;

      // FIFO should be full at this point to write side, and empty to
      // read side
      if (gen_drdy || chk_srdy)
	begin
	  $display ("ERROR -- c_drdy or p_srdy asserted");
          fail = 1;
	  #100 $finish;
	end
      
      // reset the read pointer and the expected value
      chk.last_seq = 0;
      chk_abort <= #1 1;
      @(posedge clk);
      chk_abort <= #1 0;

      // read out contents of FIFO again
      chk.drdy_pat = 8'hFF;

      @(posedge clk);
      repeat (depth-3) @(posedge clk);
      chk_commit <= #1 1;
      repeat (4) @(posedge clk);
      chk_commit <= #1 0;

      // All data has been committed, so drdy should be asserted
      if (gen_drdy !== 1)
	begin
	  $display ("%t: ERROR -- c_drdy not asserted", $time);
          fail = 1;
	  #100 $finish;
	end
      #500;
      end_check();
      
    end
  endtask

endmodule // bench_fifo_s
// Local Variables:
// verilog-library-directories:("." "../common" "../../../rtl/verilog/buffers")
// End:
