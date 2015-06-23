/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Entropy Coding, Huffman tables, Testbench             ////
////                                                             ////
////  Testbench for the default huffman tables functions.        ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: bench_top.v,v 1.1 2002-10-29 20:05:40 rherveille Exp $
//
//  $Date: 2002-10-29 20:05:40 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//

`include "timescale.v"

module bench_top();
  parameter verbose = 1;


  integer err_cnt;

  reg        clk, rst;

  reg [7:0] n;
  reg [4:0] r, s;
  reg [1:0] mode;

  reg        enc_die;

  // from encoder
  wire [7:0] enc_do;
  wire       enc_doe, enc_busy;

  // from decoder fifo
  wire [7:0] dec_di;
  wire       fempty_dec, ffull_dec, fread_dec;
  reg        dfread_dec;
  wire       dec_die;

  // from decoder
  wire [7:0] dec_do;
  wire       dec_doe, dec_busy;

  // from check-fifo
  wire [7:0] verify_q;

  // hookup huffman-encoder
  huffman_enc
  encoder(
	.clk(clk),
	.rst(rst),
	.tablesel(mode),
	.di(n),
	.die(enc_die),
	.do(enc_do),
	.doe(enc_doe),
	.busy(enc_busy)
  );


  // hookup small fifo
  // buffer between encoder-and-decoder
  assign fread_dec = ~fempty_dec & ~dec_busy & ~dfread_dec;

  always @(posedge clk)
    dfread_dec <= #1 fread_dec;

  generic_fifo_lfsr #(4,8)
  fifo_dec (
	.clk(clk),
	.nReset(rst),
	.rst(1'b0),
	.wreq(enc_doe),
	.rreq(fread_dec),
	.d(enc_do),
	.q(dec_di),
	.empty(fempty_dec),
	.full(),
	.aempty(),
	.afull(ffull_dec)
  );


  // hookup huffman-decoder
  huffman_dec
  decoder(
	.clk(clk),
	.rst(rst),
	.tablesel(mode),
	.di(dec_di),
	.die(dfread_dec),
	.do(dec_do),
	.doe(dec_doe),
	.busy(dec_busy)
  );

  // hookup results fifo
  // push encoder-input in fifo
  generic_fifo_lfsr #(4,8)
  check_fifo (
	.clk(clk),
	.nReset(rst),
	.rst(1'b0),
	.wreq(enc_die),
	.rreq(dec_doe),
	.d(n),
	.q(verify_q),
	.empty(),
	.full(),
	.aempty(),
	.afull()
  );

  //
  // TESTBENCH
  //
  always #5 clk = ~clk;

  // check values
  always @(posedge clk)
    if(dec_doe)
      if(verify_q !== dec_do)
        begin
            $display("\nERROR: output check error, expected %x, received %x, at %t\n", verify_q, dec_do, $time);
            err_cnt = err_cnt +1;
        end


  // stop testbench after a number of errors
  always @(err_cnt)
    if(err_cnt > 10)
      begin
          $display("More than 10 errors detected.");
	  $display("Testbench stopped.");
	  $stop;
      end

  // start test
  initial
  begin
	// waves statement
	`ifdef WAVES
	   $shm_open("waves");
	   $shm_probe("AS",bench_top,"AS");
	   $display("INFO: Signal dump enabled ...\n\n");
	`endif

	clk = 0;
	err_cnt = 0;
	enc_die = 0;

	$display("**********************");
	$display("* Starting testbench *");
	$display("**********************");

	tst_dc_luminance;
	tst_dc_chrominance;
	tst_ac_luminance;
	tst_ac_chrominance;

	repeat(100) @(posedge clk);
	$display("Total errors: %d", err_cnt);
	$stop;
  end



  //
  // DC Luminance
  //
  task tst_dc_luminance;
  begin
	$display("\nTesting DC luminance codes\n");
	rst = 0;
	repeat(2) @(posedge clk);
	rst = 1;
	mode = 2'b00;
	@(posedge clk);

	for(n=0; n<12; n=n+1)
	begin
	    while(enc_busy)
	      begin
	          if(verbose)
	            $display("waiting for busy");
	          @(posedge clk);
	      end

	    enc_die = #1 1;
	    @(posedge clk);
	    enc_die = #1 0;
	end

	repeat(40) @(posedge clk);
  end
  endtask


  //
  // DC Chrominance
  //
  task tst_dc_chrominance;
  begin
	$display("\nTesting DC chrominance codes\n");
	rst = 0;
	repeat(2) @(posedge clk);
	rst = 1;
	mode = 2'b01;
	@(posedge clk);

	for(n=0; n<12; n=n+1)
	begin
	    while(enc_busy)
	      begin
	          if(verbose)
	            $display("waiting for busy");
	          repeat(2) @(posedge clk);
	      end

	    enc_die = #1 1;
	    @(posedge clk);
	    enc_die = #1 0;
	end

	repeat(40) @(posedge clk);
  end
  endtask


  //
  // AC Luminance
  //
  task tst_ac_luminance;
  begin
	$display("\nTesting AC luminance codes\n");
	rst = 0;
	repeat(2) @(posedge clk);
	rst = 1;
	mode = 2'b10;
	@(posedge clk);

	for(r=0; r<=5'hf; r=r+5'h1)
	for(s=1; s<4'hb; s=s+5'h1)
	begin
	    while(enc_busy)
	      begin
	          if(verbose)
	            $display("waiting for busy");
	          @(posedge clk);
	      end

	    repeat(5) @(posedge clk); // go slow, otherwise fifo might overrun

	    enc_die = #1 1;
	    n = #1 {r[3:0],s[3:0]};
	    @(posedge clk);
	    enc_die = #1 0;
	end

	repeat(100) @(posedge clk);
  end
  endtask


  //
  // AC Luminance
  //
  task tst_ac_chrominance;
  begin
	$display("\nTesting AC chrominance codes\n");
	rst = 0;
	repeat(2) @(posedge clk);
	rst = 1;
	mode = 2'b11;
	@(posedge clk);

	for(r=0; r<=5'hf; r=r+5'h1)
	for(s=1; s<4'hb; s=s+5'h1)
	begin
	    while(enc_busy)
	      begin
	          if(verbose)
	            $display("waiting for busy");
	          @(posedge clk);
	      end

	    repeat(5) @(posedge clk); // go slow, otherwise fifo might overrun

	    enc_die = #1 1;
	    n = #1 {r[3:0],s[3:0]};
	    @(posedge clk);
	    enc_die = #1 0;
	end

	repeat(100) @(posedge clk);
  end
  endtask

endmodule
