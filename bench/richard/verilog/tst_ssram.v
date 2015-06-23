/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  SSRAM memory devices tests                                 ////
////  This file is being included by the main testbench          ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001, 2002 Richard Herveille                  ////
////                          richard@asics.ws                   ////
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
//  $Id: tst_ssram.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
//
//  $Date: 2002-03-06 15:10:34 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//


	////////////////////////////////
	// SSRAM Sequential access test
	//

	// 1) Tests ssram sequential address access
	// 2) Tests page switch
	// 3) Test burst-action by filling memory backwards (high addresses first)
	task tst_ssram_seq;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;
		parameter SSRAM_TST_RUN = 128;
		parameter [31:0] SSRAM_TST_STARTA = `SSRAM_LOC + (SSRAM_TST_RUN<<2);
		parameter [ 7:0] SSRAM_SEL = SSRAM_TST_STARTA[28:21];

		integer n, k;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;
		reg [15:0] tmp0, tmp1;

		// SSRAM Mode Register bits
		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay, bl;

		begin

			$display("\n\n --- SSRAM SEQUENTIAL ACCESS TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			csc_data = {
				8'h00,       // reserved
				SSRAM_SEL,   // SEL
				4'h0,        // reserved
				1'b1,        // parity enabled
				1'b0,        // KRO, no meaning for ssram
				1'b0,        // BAS, no meaning for ssram
				1'b0,        // WP
				2'b00,       // MS, no meaning for ssram
				2'b10,       // BW == 32bit bus. Always for ssram (maybe hardwire ???)
				3'b001,      // MEM_TYPE == SDRAM
				1'b1         // EN == chip select enabled
			};
						
			// tms_data is unused for ssrams
			tms_data = {
				32'hx
			};

			// program chip select registers
			$display("\nProgramming SSRAM chip select register.");
			wbm.wb_write(0, 0, 32'h6000_0030, csc_data); // program cs4 config register (CSC4)

			$display("Programming SSRAM timing register.");
			wbm.wb_write(0, 0, 32'h6000_0034, tms_data); // program cs4 timing register (TMS4)

			// check written data
			wbm.wb_cmp(0, 0, 32'h6000_0030, csc_data);
			wbm.wb_cmp(0, 0, 32'h6000_0034, tms_data);

			cyc_delay = 0;
			stb_delay = 0;
			for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
			for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
			for (bl        = 1; bl        <= 8            ; bl        = bl        +1)
				begin

					$display("\nSSRAM sequential test. BL = %d, CYC-delay = %d, STB-delay = ", bl, cyc_delay, stb_delay);

					// fill sdrams
					$display("Filling SSRAM memory...");
					my_dat = 0;
					for (n=0; n < SSRAM_TST_RUN; n=n+1)
					begin
						my_adr = SSRAM_TST_STARTA + ( (SSRAM_TST_RUN -n -bl) <<2);
						for (k=0; k < bl; k=k+1)
							begin
								// fill destination backwards, but with linear bursts
								dest_adr   = my_adr + (k<<2);

								tmp0     = ~dest_adr[15:0] + bl + cyc_delay + stb_delay;
								tmp1     =  dest_adr[15:0] + bl + cyc_delay + stb_delay;
								my_dat   = {tmp0, tmp1};

								wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
							end
						end


					// read sdrams
					$display("Verifying SSRAM memory contents...");
					my_dat = 0;
					for (n=0; n < SSRAM_TST_RUN; n=n+1)
						begin
							my_adr   = n<<2;
							dest_adr = SSRAM_TST_STARTA + my_adr;

							tmp0     = ~dest_adr[15:0] + bl + cyc_delay + stb_delay;
							tmp1     =  dest_adr[15:0] + bl + cyc_delay + stb_delay;
							my_dat   = {tmp0, tmp1};

							wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
						end
				end

			repeat(10) @(posedge wb_clk); //wait a while

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask // test_ssram_seq
