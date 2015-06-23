/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  SDRAM memory devices tests                                 ////
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
//  $Id: tst_sdram.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
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
	// SDRAM memory fill test
	//

	// Test memory contents overwrite
	// 1) Fill entire SDRAM memory
	// 2) Verify memory contents
	// 3) Test for BAS setting
	//
	// THIS IS A FULL MEMORY TEST
	// MAY RUN FOR A FEW DAYS
	task tst_sdram_memfill;
		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC; // start at address 0
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = ( 1<<(`SDRAM_COLA_HI+1)<<(`SDRAM_ROWA_HI+1) ) *4;

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;
		integer bank_cnt, col_cnt;

		begin

			$display("\n\n --- SDRAM MEMORY FILL TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			// choose some settings, other settings will be tested
			// in next tests
			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 2; // burst length = 4

			// variables for CSC register
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,      // reserved
							SDRAM1_SEL, // SEL
							4'h0,       // reserved
							1'b0,       // parity disabled
							kro[0],     // KRO
							bas[0],     // BAS
							1'b0,       // WP
							2'b10,      // MS == 256MB
							2'b01,      // BW == 16bit bus per device
							3'b000,     // MEM_TYPE == SDRAM
							1'b1        // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("Programming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						// only select cyc_delay = 0
						// only select stb_delay = 0
						// --> fastest test_run.
						// other possibilities will be tested by next tests
						cyc_delay = 0;
						stb_delay = 0;

							begin
		
								// fill sdrams
								$display("Filling SDRAM memory... (This takes a while)");
								my_dat = 0;
								bank_cnt = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = n<<2;
										dest_adr = SDRAM_TST_RUN -1 - my_adr; // fill backward
										my_dat   = my_adr;

										if (n % (1<<(`SDRAM_COLA_HI+1)<<(`SDRAM_ROWA_HI+1)) == 0)
											begin
												col_cnt = 0;
												bank_cnt = bank_cnt +1;
											end

										if (n % (1<<(`SDRAM_COLA_HI+1)) == 0)
											begin
												$display("Filling bank %d, column %d", bank_cnt, col_cnt);
												col_cnt = col_cnt +1;
											end

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_dat = 0;
								bank_cnt = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = n<<2;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr;

										if (n % (1<<(`SDRAM_COLA_HI+1)) == 0)
											begin
												$display("Verifying bank %d", bank_cnt);
												bank_cnt = bank_cnt +1;
											end

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
									end
							end

							repeat(10) @(posedge wb_clk); //wait a while
					end


			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask // test_sdram_memfill


	////////////////////////////////
	// SDRAM parity test
	//

	// 1) This is practically the 'SDRAM sequential access test'
	// 2) First check parity operation
	// 3) Then introduce some parity errors
	task tst_sdram_parity;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC + (1<<`SDRAM_COLA_HI) + (1<<`SDRAM_COLA_HI>>1); // start at 75% of page
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = 16; // a few runs

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		integer mod_par;

		begin

			$display("\n\n --- SDRAM PARITY TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 1; // burst length = 8

			// simply set the parity bits to zero, when introducing parity errors
			set_par = 4'b0;

			// use second SDRAMS set as parity sdrams
			sel_pbus = 1;

			for(mod_par = 0; mod_par <= 1; mod_par = mod_par +1)
			begin

				// switch between parity and parity errors
				sel_par  = mod_par;

				if(sel_par)
					$display("\n-- Checking parity generation --");
				else
					$display("\n-- Introducing parity errors --");

				// variables for TMS register
				
				// skip these settings, since they are not relevant to parity
//				for (cl  = 2; cl  <= 3; cl  = cl  +1)
//				for (wbl = 0; wbl <= 1; wbl = wbl +1)
//				for (bl  = 0; bl  <= 3; bl  = bl  +1)

				// variables for CSC register
//				for (kro = 0; kro <= 1; kro = kro +1)
//				for (bas = 0; bas <= 1; bas = bas +1)

					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b1,        // parity enabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("Programming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 0;
						stb_delay = 0;

						// skip cyc_delay and stb_delay.
						// They are not relevant to parity generation
//						for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
//						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM parity test. CYC-delay = %d, STB-delay = ", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = n<<2;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = n<<2;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
									end
							end

							repeat(10) @(posedge wb_clk); //wait a while
					end

			end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask // test_sdram_parity

	////////////////////////////////
	// SDRAM Sequential access test
	//

	// 1) Tests sdram sequential address access
	// 2) Tests page switch
	// 3) Tests bank-switching using BAS-bit
	// 4) Test burst-action by filling SDRAM backwards (high addresses first)
	// 5) Run test for all possible CS settings for SDRAMS
	task tst_sdram_seq;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;
		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC + (1<<`SDRAM_COLA_HI) + (1<<`SDRAM_COLA_HI>>1); // start at 75% of page
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = (1<<`SDRAM_COLA_HI>>1); // run for half page length

		integer n, k;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;
		reg [15:0] tmp0, tmp1;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM SEQUENTIAL ACCESS TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 2; // burst length

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b0,        // parity disabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("Programming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 0;
						stb_delay = 0;
						for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM sequential test. CYC-delay = %d, STB-delay = ", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+(1<<bl) )
								begin
									my_adr = SDRAM_TST_STARTA +( (SDRAM_TST_RUN -n -(1<<bl)) <<2);
									for (k=0; k < (1<<bl); k=k+1)
										begin
											// fill destination backwards, but with linear bursts
											dest_adr   = my_adr + (k<<2);

											tmp0     = ~dest_adr[15:0] + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;
											tmp1     =  dest_adr[15:0] + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;
											my_dat   = {tmp0, tmp1};

											wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
										end
									end


								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = n<<2;
										dest_adr = SDRAM_TST_STARTA + my_adr;

										tmp0     = ~dest_adr[15:0] + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;
										tmp1     =  dest_adr[15:0] + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;
										my_dat   = {tmp0, tmp1};

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
									end
							end

							repeat(10) @(posedge wb_clk); //wait a while
					end


			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask // test_sdram_seq


	/////////////////////////////
	// SDRAM Random access test
	//

	// 1) Tests sdram random address access
	// 2) Run test for all possible CS settings for SDRAMS
	task tst_sdram_rnd;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC; // start somewhere in memory
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = 64; // run a few accesses

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM RANDOM ACCESS TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 2; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,      // reserved
							SDRAM1_SEL, // SEL
							4'h0,       // reserved
							1'b0,       // parity disabled
							kro[0],     // KRO
							bas[0],     // BAS
							1'b0,       // WP
							2'b10,      // MS == 256MB
							2'b01,      // BW == 16bit bus per device
							3'b000,     // MEM_TYPE == SDRAM
							1'b1        // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("\nProgramming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						// random access requires CYC signal to be broken up (delay >= 1)
						// otherwise MemoryController expects sequential burst
						cyc_delay = 1;
						stb_delay = 0;
						for (cyc_delay = 1; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM random test. CYC-delay = %d, STB-delay = ", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory...");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2) + my_adr;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// read sdrams
								$display("Verifying SDRAM memory contents...\n");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2) + my_adr;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask //tst_sdram_rnd


	/////////////////////////
	// SDRAM seq RMW test
	//

	// 1) Tests sdram RMW cycle using sequential address accesses
	// 2) Run test for all possible CS settings for SDRAMS
	task tst_sdram_rmw_seq;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC; // start somewhere in memory (at dword boundary)
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = 64; // only do a few runs

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM SEQUENTIAL ACCESS READ-MODIFY-WRITE TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 1; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b0,        // parity disabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("\nProgramming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 1;
						stb_delay = 0;
						for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM sequential Read-Modify-Write test. CYC-delay = %d, STB-delay = %d", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory with initial contents ...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// perform Read-Modify-Write cycle
								$display("Performing RMW cycle ...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;

										// read memory contents
										wbm.wb_read(cyc_delay, stb_delay, dest_adr, my_dat);

										// modify memory contents
										my_dat = my_dat +1;

										// write contents back into memory
										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);

									end

								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat +1);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask //tst_sdram_rmw_seq

	/////////////////////////
	// SDRAM Random RMW test
	//

	// 1) Tests sdram RMW cycle using random address accesses
	// 2) Run test for all possible CS settings for SDRAMS
	task tst_sdram_rmw_rnd;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM_TST_STARTA = `SDRAM1_LOC; // start somewhere in memory
		parameter [ 7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = 64; // only do a few runs

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM RANDOM ACCESS READ-MODIFY-WRITE TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 2; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b0,        // parity disabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("\nProgramming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						// random access requires CYC signal to be broken up (delay >= 1)
						// otherwise MemoryController expects sequential burst
						cyc_delay = 1;
						stb_delay = 0;
						for (cyc_delay = 1; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM random Read-Modify-Write test. CYC-delay = %d, STB-delay = %d", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory with initial contents ...");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2) + my_adr;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// perform Read-Modify-Write cycle
								$display("Performing RMW cycle ...");
								my_adr = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2) + my_adr;
										dest_adr = SDRAM_TST_STARTA + my_adr;

										// read memory contents
										wbm.wb_read(cyc_delay, stb_delay, dest_adr, my_dat);

										// modify memory contents
										my_dat = my_dat +1;

										// write contents back into memory
										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);

									end

								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2) + my_adr;
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat +1);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask //tst_sdram_rmw_rnd


	//////////////////////////
	// SDRAM Block copy test1
	//

	// 1) Copy block of memory inside same memory block (chip select)
	// 2) Run test for all possible CS settings for SDRAM
	task tst_sdram_blk_cpy1;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM1_STARTA = `SDRAM1_LOC;
		parameter [ 7:0] SDRAM1_SEL = SDRAM1_STARTA[28:21];
		parameter SDRAM_TST_RUN = 64; // only do a few runs

		parameter MAX_BSIZE = 8;

		parameter SDRAM_SRC = SDRAM1_STARTA;
		parameter SDRAM_DST = SDRAM1_STARTA + 32'h0001_0000;

		integer n, wcnt, bsize;
		reg [31:0] my_adr, src_adr, dest_adr;
		reg [31:0] my_dat;
		reg [31:0] tmp [MAX_BSIZE -1 :0];

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM block copy TEST-1- ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 1; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b0,        // parity disabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("Programming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 0;
						stb_delay = 0;
						bsize     = 2;
						wcnt      = 0;
						for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
						for (bsize     = 0; bsize     <  MAX_BSIZE;     bsize     = bsize     +1)
							begin
		
								if (cyc_delay == 0)
									while ( ((bsize +1) % (1 << bl) != 0) && (bsize < (MAX_BSIZE -1)) )
										bsize = bsize +1;

								$display("Block copy test-1-. CYC-delay = %d, STB-delay = %d, burst-size = %d", cyc_delay, stb_delay, bsize);

								// fill sdrams
								my_dat = 0;
								for (n = 0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_SRC + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// perform Read-Modify-Write cycle
								n = 0;
								while (n < SDRAM_TST_RUN)
									begin	
										// read data from sdrams
										for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
										begin 
											my_adr   = (n + wcnt) << 2;
											src_adr  = SDRAM_SRC + my_adr;

											// read memory contents
											wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

											// modify memory contents
											tmp[wcnt] = my_dat +1;
										end

										// copy data into sdrams; new location
										for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
										begin 
											my_adr   = (n + wcnt) << 2;
											dest_adr = SDRAM_DST + my_adr;

											// write contents back into memory
											wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
										end

										n = n + bsize +1;
									end

								// read sdrams
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_DST + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat +1);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

			$display("\nSDRAM block copy test-1- ended");

		end
	endtask // tst_sdram_blk_cpy1



	//////////////////////////
	// SDRAM Block copy test2
	//

	// 1) Copy a modified block of memory to the same memory location
	// 2) Run test for all possible CS settings for SDRAM
	task tst_sdram_blk_cpy2;
	
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SDRAM1_STARTA = `SDRAM1_LOC;
		parameter [ 7:0] SDRAM1_SEL = SDRAM1_STARTA[28:21];

		parameter SDRAM_TST_RUN = 64; // only do a few runs

		parameter MAX_BSIZE = 8;

		parameter SDRAM_SRC = SDRAM1_STARTA;

		integer n, wcnt, bsize;
		reg [31:0] my_adr, src_adr, dest_adr;
		reg [31:0] my_dat;
		reg [31:0] tmp [MAX_BSIZE -1 :0];

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM block copy TEST-2- ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 1; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
			for (bas = 0; bas <= 1; bas = bas +1)
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b0,        // parity disabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("Programming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 0;
						stb_delay = 0;
						bsize     = 2;
						wcnt      = 0;
						for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
						for (bsize     = 0; bsize     <  MAX_BSIZE;     bsize     = bsize     +1)
							begin

								if (cyc_delay == 0)
									while ( ((bsize +1) % (1 << bl) != 0) && (bsize < (MAX_BSIZE -1)) )
										bsize = bsize +1;

								$display("Block copy test-2-. CYC-delay = %d, STB-delay = %d, burst-size = %d", cyc_delay, stb_delay, bsize);

								// fill sdrams
								my_dat = 0;
								for (n = 0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_SRC + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// perform Read-Modify-Write cycle
								n = 0;
								while (n < SDRAM_TST_RUN)
									begin	
										// read data from sdrams
										for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
										begin 
											my_adr   = (n + wcnt) << 2;
											src_adr  = SDRAM_SRC + my_adr;

											// read memory contents
											wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

											// modify memory contents
											tmp[wcnt] = my_dat +1;
										end

										// copy data into sdrams; new location
										for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
										begin 
											my_adr   = (n + wcnt) << 2;
											dest_adr = SDRAM_SRC + my_adr;

											// write contents back into memory
											wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
										end

										n = n + bsize +1;
									end

								// read sdrams
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_SRC + my_adr;
										my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat +1);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

			$display("\nSDRAM block copy test-2- ended");

		end
	endtask // tst_sdram_blk_cpy


	/////////////////////////////
	// SDRAM byte access test
	//

	// 1) Test byte/word writes (SDRAM DQM lines)
	// 2) Run for all CS settings for SDRAMS
	// 3) This test also checks the parity bits
	task tst_sdram_bytes;

		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter SDRAM_TST_STARTA = `SDRAM1_LOC; // start at address 0
		parameter [7:0] SDRAM1_SEL = SDRAM_TST_STARTA[28:21];
		parameter SDRAM_TST_RUN = 64; // only do a few runs

		integer n;
		reg [31:0] my_adr, dest_adr;
		reg [31:0] my_dat;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer sel;
		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- SDRAM BYTE ACCESS TEST ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			// use second SDRAMS set as parity sdrams
			sel_pbus = 1;

			// choose some default settings
			kro = 0;
			bas = 0;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency = 2
			bl  = 2; // burst length = 4

			// variables for TMS register
			for (cl  = 2; cl  <= 3; cl  = cl  +1)
			for (wbl = 0; wbl <= 1; wbl = wbl +1)
			for (bl  = 0; bl  <= 3; bl  = bl  +1)

			// variables for CSC register
			for (kro = 0; kro <= 1; kro = kro +1)
//			for (bas = 0; bas <= 1; bas = bas +1) // ignore BAS for this test
					begin
						csc_data = {
							8'h00,       // reserved
							SDRAM1_SEL,  // SEL
							4'h0,        // reserved
							1'b1,        // parity enabled
							kro[0],      // KRO
							bas[0],      // BAS
							1'b0,        // WP
							2'b10,       // MS == 256MB
							2'b01,       // BW == 16bit bus per device
							3'b000,      // MEM_TYPE == SDRAM
							1'b1         // EN == chip select enabled
						};
						
						tms_data = {
							4'h0,   // reserved
							4'h8,   // Trfc == 7 (+1)
							4'h4,   // Trp == 2 (+1) ?????
							3'h3,   // Trcd == 2 (+1)
							2'b11,  // Twr == 2 (+1)
							5'h0,   // reserved
							wbl[0], // write burst length
							2'b00,  // OM  == normal operation
							cl,     // cas latency
							1'b0,   // BT == sequential burst type
							bl
						};

						// program chip select registers
						$display("\nProgramming SDRAM chip select register. KRO = %d, BAS = %d", kro, bas);
						wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

						$display("\nProgramming SDRAM timing register. WBL = %d, CL = %d, BL = %d\n", wbl, cl, bl);
						wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

						// check written data
						wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
						wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

						cyc_delay = 1;
						stb_delay = 0;
						for (cyc_delay = 1; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
						for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
							begin
		
								$display("\nSDRAM byte test. CYC-delay = %d, STB-delay = ", cyc_delay, stb_delay);

								// fill sdrams
								$display("Filling SDRAM memory...");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;
										my_dat   = {my_dat[7:0] +8'd3, my_dat[7:0] +8'd2, my_dat[7:0] +8'd1, my_dat[7:0]};

										wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
									end

								// switch memory contents
								$display("Swapping bytes...");
								my_adr = 0;
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
								for (sel=0; sel < 16; sel=sel+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;
										wbm.wb_read(cyc_delay, stb_delay, dest_adr, my_dat);

										my_dat = {my_dat[31:24] +8'd1, my_dat[23:16] +8'd1, my_dat[15:8] +8'd1, my_dat[7:0] +8'd1};
										wbm.wb_write_sel(cyc_delay, stb_delay, sel, dest_adr, my_dat);

									end

								// read sdrams
								$display("Verifying SDRAM memory contents...");
								my_dat = 0;
								for (n=0; n < SDRAM_TST_RUN; n=n+1)
									begin
										my_adr   = (n << 2);
										dest_adr = SDRAM_TST_STARTA + my_adr;
										my_dat   = my_adr + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

										my_dat   = {my_dat[7:0] +8'd3, my_dat[7:0] +8'd2, my_dat[7:0] +8'd1, my_dat[7:0]};
										my_dat   = {my_dat[31:24] +8'd8, my_dat[23:16] +8'd8, my_dat[15:8] +8'd8, my_dat[7:0] +8'd8};

										wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
									end
							end
					end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

		end
	endtask //tst_sdram_bytes
