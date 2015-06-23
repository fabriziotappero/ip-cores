/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  Multiple memory devices tests                              ////
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
//  $Id: tst_multi_mem.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
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

	///////////////////////////////
	// SDRAM/SRAM Block copy test1
	//

	// Test multi-memory accesses (SDRAM & SRAM)
	// 1) Copy memory-block from SDRAM to SRAM
	// 2) Copy block from SRAM to SDRAM
	// 3) Run test for all CS settings for SDRAMS
	task tst_blk_cpy1;

		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;
		parameter MAX_BSIZE = 8;

		parameter [31:0] SDRAM_STARTA = `SDRAM1_LOC;
		parameter [ 7:0] SDRAM_SEL = SDRAM_STARTA[28:21];
		parameter [31:0] SRAM_STARTA = `SRAM_LOC;
		parameter [ 7:0] SRAM_SEL = SRAM_STARTA[28:21];
		parameter TST_RUN = 64; // only perform a few accesses

		parameter SDRAM_SRC = SDRAM_STARTA;
		parameter SRAM_SRC  = SRAM_STARTA;

		integer n, wcnt, bsize;
		reg [31:0] my_adr, src_adr, dest_adr;
		reg [31:0] my_dat;
		reg [31:0] tmp [MAX_BSIZE -1 :0];
		reg [31:0] sdram_dest;

		// config register mode bits
		reg [1:0] kro, bas; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl; // a single register doesn't work with the for-loops
		reg [2:0] cl, bl;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- Multiple memory block copy TEST-1- ---\n\n");

			// clear Wishbone-Master-model current-error-counter 
			wbm.set_cur_err_cnt(0);

			// program asynchronous SRAMs
			csc_data = {
				8'h00,    //     reserved
				SRAM_SEL, // SEL base address (a[28:21] == 8'b0100_0000)
				4'h0,     //     reserved
				1'b0,     // PEN no parity
				1'b0,     // KRO ---
				1'b0,     // BAS ---
				1'b0,     // WP  no write protection
				2'b00,    // MS  ---
				2'h2,     // BW  Bus width
				3'h2,     // MEM memory type == asynchronous
				1'b1      // EN  enable chip select
			};				

			tms_data = {
				6'h0,  // reserved
				6'h0,  // Twwd =  5ns =>  0ns
				4'h0,  // Twd  =  0ns =>  0ns
				4'h1,  // Twpw = 15ns => 20ns
				4'h0,  // Trdz =  8ns => 10ns
				8'h02  // Trdv = 20ns => 20ns
			};				

			// program chip select registers
			wbm.wb_write(0, 0, 32'h6000_0018, csc_data);      // program cs1 config register
			wbm.wb_write(0, 0, 32'h6000_001c, tms_data);      // program cs1 timing register

			// check written data
			wbm.wb_cmp(0, 0, 32'h6000_0018, csc_data);
			wbm.wb_cmp(0, 0, 32'h6000_001c, tms_data);


			// SDRAMS
			kro = 1;
			bas = 1;

			wbl = 0; // programmed burst length
			cl  = 2; // cas latency
			bl  = 0; // burst length

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
						SDRAM_SEL,  // SEL
						4'h0,       // reserved
						1'b0,       // parity disabled
						kro[0],     // KRO
						bas[0],     // BAS
						1'b0,       // WP
						2'b10,      // MS == 256MB
						2'b01 ,     // BW == 16bit bus per device
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

					// calculate sdram destination address
					if (bas)
						sdram_dest = SDRAM_SRC + 32'h0001_0000; // add row address
					else
						sdram_dest = SDRAM_SRC + 32'h0000_0800; // add column address

					cyc_delay = 1;
					stb_delay = 2;
					bsize     = 0;
					wcnt      = 0;
					for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
					for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
					for (bsize     = 0; bsize     <  MAX_BSIZE;     bsize     = bsize     +1)
						begin

							if (cyc_delay == 0)
								while ( ((bsize +1) % (1 << bl) != 0) && (bsize < (MAX_BSIZE -1)) )
									bsize = bsize +1;

							$display("SDRAM/SRAM block copy test-1-. CYC-delay = %d, STB-delay = %d, burst-size = %d", cyc_delay, stb_delay, bsize);

							// fill sdrams
							my_dat = 0;
							for (n = 0; n < TST_RUN; n=n+1)
								begin
									my_adr   = (n << 2);
									dest_adr = SDRAM_SRC + my_adr;
									my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

									wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
								end

							// perform Read-Modify-Write cycle
							n = 0;
							while (n < TST_RUN)
								begin	
									// copy from sdrams into srams
									for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
									begin 
										my_adr   = (n + wcnt) << 2;
										src_adr  = SDRAM_SRC + my_adr;

										// read memory contents
										wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

										// modify memory contents
										tmp[wcnt] = my_dat +1;
									end

									for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
									begin 
										my_adr   = (n + wcnt) << 2;
										dest_adr = SRAM_SRC + my_adr;

										// write contents back into memory
										wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
									end

									// copy from srams into sdrams
									for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
									begin 
										my_adr   = (n + wcnt) << 2;
										src_adr  = SRAM_SRC + my_adr;

										// read memory contents
										wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

										// modify memory contents
										tmp[wcnt] = my_dat -1;
									end

									for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
									begin 
										my_adr   = (n + wcnt) << 2;
										dest_adr = sdram_dest + my_adr;

										// write contents back into memory
										wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
									end

									n = n + bsize +1;
								end

							// read sdrams
							my_dat = 0;
							for (n=0; n < TST_RUN; n=n+1)
								begin
									my_adr   = (n << 2);
									dest_adr = sdram_dest + my_adr;
									my_dat   = my_adr + my_dat + kro + bas + wbl + cl + bl + cyc_delay + stb_delay;

									wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat);
								end
						end
				end

			// show Wishbone-Master-model current-error-counter 
			wbm.show_cur_err_cnt;

			$display("\nSDRAM/SRAM block copy test-1- ended");

		end
	endtask // tst_blk_cpy1


	///////////////////////////////
	// SDRAM/SDRAM Block copy test2
	//

	// Test multimemory accesses (SDRAM & SDRAM)
	// 1) Copy memory block from SDRAM1 to SDRAM2
	// 2) Copy block from SDRAM2 to SDRAM1
	// 3) Use different pages/banks for copy (4 runs)
	// 4) Run test for all CS settings for SDRAM1 & SDRAM2
	//
	// THIS IS A VERY LONG TEST !!!!
	// MAY RUN FOR A COUPLE OF WEEKS
	task tst_blk_cpy2;

		// if the MAX_ numbers are larger than 15, adjust the appropriate _reg registers (see below)
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;
		parameter MAX_BSIZE = 8;

		parameter [31:0] SDRAM1_STARTA = `SDRAM1_LOC;
		parameter [ 7:0] SDRAM1_SEL = SDRAM1_STARTA[28:21];
		parameter [31:0] SDRAM2_STARTA = `SDRAM2_LOC;
		parameter [ 7:0] SDRAM2_SEL = SDRAM2_STARTA[28:21];
		parameter TST_RUN = 32; // only perform a few accesses

		parameter SDRAM0 = SDRAM1_STARTA;
		parameter SDRAM1 = SDRAM2_STARTA;

		integer n, wcnt, bsize, opt;
		reg [31:0] my_adr, src_adr, dest_adr, dest_adr0, dest_adr1;
		reg [31:0] my_dat;
		reg [31:0] tmp [MAX_BSIZE -1 :0];

		// display registers (convert integers into regs)
		reg [1:0] opt_reg;
		reg [3:0] cyc_reg, stb_reg, bsz_reg;

		// config register mode bits
		reg [1:0] kro0, bas0, kro1, bas1; // a single register doesn't work with the for-loops

		// SDRAM Mode Register bits
		reg [1:0] wbl0, wbl1; // a single register doesn't work with the for-loops
		reg [2:0] cl0, bl0, cl1, bl1;

		reg [31:0] csc_data, tms_data;

		integer cyc_delay, stb_delay;

	begin

		$display("\n\n --- Multiple memory block copy TEST-2- ---\n\n");

		// clear Wishbone-Master-model current-error-counter 
		wbm.set_cur_err_cnt(0);

		for(opt = 0; opt <= 4; opt = opt +1)
		begin
			// SDRAM1
			kro0 = 0;
			bas0 = 0;

			wbl0 = 0;
			cl0  = 2; // cas latency = 2
			bl0  = 1;

			// variables for TMS register
			for (cl0  = 2; cl0  <= 3; cl0  = cl0  +1)
			for (wbl0 = 0; wbl0 <= 1; wbl0 = wbl0 +1)
			for (bl0  = 0; bl0  <= 3; bl0  = bl0  +1)

			// variables for CSC register
			for (kro0 = 0; kro0 <= 1; kro0 = kro0 +1)
//			for (bas0 = 0; bas0 <= 1; bas0 = bas0 +1) // ignore bas, speed up test
			begin
				csc_data = {
					8'h00,       // reserved
					SDRAM1_SEL,  // SEL
					4'h0,        // reserved
					1'b0,        // parity disabled
					kro0[0],     // KRO
					bas0[0],     // BAS
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
					wbl0[0],// write burst length
					2'b00,  // OM  == normal operation
					cl0,    // cas latency
					1'b0,   // BT == sequential burst type
					bl0     // BL == burst length
				};

				// program chip select registers
				$display("\nProgramming SDRAM1 chip select register. KRO = %d, BAS = %d", kro0, bas0);
				wbm.wb_write(0, 0, 32'h6000_0028, csc_data); // program cs3 config register (CSC3)

				$display("Programming SDRAM1 timing register. WBL = %d, CL = %d, BL = %d\n", wbl0, cl0, bl0);
				wbm.wb_write(0, 0, 32'h6000_002c, tms_data); // program cs3 timing register (TMS3)

				// check written data
				wbm.wb_cmp(0, 0, 32'h6000_0028, csc_data);
				wbm.wb_cmp(0, 0, 32'h6000_002c, tms_data);

				// calculate sdram destination address
				if (!opt[0])
						dest_adr0 = SDRAM0;
				else
					if (bas0)
						dest_adr0 = SDRAM0 + 32'h0001_0000; // add row address
					else
						dest_adr0 = SDRAM0 + 32'h0000_0800; // add column address

				//SDRAM1
				kro1 = 0;
				bas1 = 0;

				wbl1 = 1;
				cl1  = 2; // cas latency = 2
				bl1  = 2;

				// variables for TMS register
				for (cl1  = 2; cl1  <= 3; cl1  = cl1  +1)
				for (wbl1 = 0; wbl1 <= 1; wbl1 = wbl1 +1)
				for (bl1  = 0; bl1  <= 3; bl1  = bl1  +1)

				// variables for CSC register
				for (kro1 = 0; kro1 <= 1; kro1 = kro1 +1)
//				for (bas1 = 0; bas1 <= 1; bas1 = bas1 +1) // ignore bas, speed up test
				begin
					csc_data = {
						8'h00,       // reserved
						SDRAM2_SEL,  // SEL
						4'h0,        // reserved
						1'b0,        // parity disabled
						kro1[0],     // KRO
						bas1[0],     // BAS
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
						wbl1[0],// write burst length
						2'b00,  // OM  == normal operation
						cl1,    // cas latency
						1'b0,   // BT == sequential burst type
						bl1     // BL == burst length
					};

					// program chip select registers
					$display("\nProgramming SDRAM2 chip select register. KRO = %d, BAS = %d", kro1, bas1);
					wbm.wb_write(0, 0, 32'h6000_0020, csc_data); // program cs3 config register (CSC2)

					$display("Programming SDRAM2 timing register. WBL = %d, CL = %d, BL = %d\n", wbl1, cl1, bl1);
					wbm.wb_write(0, 0, 32'h6000_0024, tms_data); // program cs3 timing register (TMS2)

					// check written data
					wbm.wb_cmp(0, 0, 32'h6000_0020, csc_data);
					wbm.wb_cmp(0, 0, 32'h6000_0024, tms_data);
	
					// calculate sdram destination address
					if (!opt[1])
						dest_adr1 = SDRAM1;
					else
						if (bas1)
							dest_adr1 = SDRAM1 + 32'h0001_0000; // add row address
						else
							dest_adr1 = SDRAM1 + 32'h0000_0800; // add column address

					cyc_delay = 0;
					stb_delay = 0;
					bsize     = 2;
					wcnt      = 0;
					for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
					for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
					for (bsize     = 0; bsize     <  MAX_BSIZE;     bsize     = bsize     +1)
					begin
						if (cyc_delay == 0)
							while ( ( ((bsize +1) % (1 << bl0) !=0) && ((1 << bl0) % (bsize +1) !=0) ) || 
							        ( ((bsize +1) % (1 << bl1) !=0) && ((1 << bl1) % (bsize +1) !=0) ) 
							      )
								bsize = bsize +1;


						// convert integers into regs (for display)
						opt_reg = opt;
						cyc_reg = cyc_delay;
						stb_reg = stb_delay;
						bsz_reg = bsize;


						$display("SDRAM multi-memory block copy test-2-. Opt = %d, CYC-delay = %d, STB-delay = %d, burst-size = %d", opt_reg, cyc_reg, stb_reg, bsz_reg);

						// fill sdram0
						my_dat = 0;
						for (n = 0; n < TST_RUN; n=n+1)
						begin
							my_adr   = (n << 2);
							dest_adr = SDRAM0 + my_adr;
							my_dat   = my_adr + my_dat + kro0 + kro1 + bas0 + bas1 + wbl0 + wbl1 + cl0 + cl1 + bl0 + bl1 + cyc_delay + stb_delay;

							wbm.wb_write(cyc_delay, stb_delay, dest_adr, my_dat);
						end

						// perform Read-Modify-Write cycle
						n = 0;
						while (n < TST_RUN)
						begin	
							// copy from sdram0 into sdram1
							for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
							begin 
								my_adr   = (n + wcnt) << 2;
								src_adr  = SDRAM0 + my_adr;

								// read memory contents
								wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

								// modify memory contents
								tmp[wcnt] = my_dat +1;
							end

							for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
							begin 
								my_adr   = (n + wcnt) << 2;
								dest_adr = dest_adr1 + my_adr;

								// write contents back into memory
								wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
							end

							// copy from sdram1 into sdram0
							for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
							begin 
								my_adr   = (n + wcnt) << 2;
								src_adr  = dest_adr1 + my_adr;

								// read memory contents
								wbm.wb_read(cyc_delay, stb_delay, src_adr, my_dat);

								// modify memory contents
								tmp[wcnt] = my_dat +1;
							end

							for (wcnt = 0; wcnt <= bsize; wcnt = wcnt +1)
							begin 
								my_adr   = (n + wcnt) << 2;
								dest_adr = dest_adr0 + my_adr;

								// write contents back into memory
								wbm.wb_write(cyc_delay, stb_delay, dest_adr, tmp[wcnt]);
							end

							n = n + bsize +1;
						end

						// read sdrams
						my_dat = 0;
						for (n=0; n < TST_RUN; n=n+1)
						begin
							my_adr   = (n << 2);
							dest_adr = dest_adr0 + my_adr;
							my_dat   = my_adr + my_dat + kro0 + kro1 + bas0 + bas1 + wbl0 + wbl1 + cl0 + cl1 + bl0 + bl1 + cyc_delay + stb_delay;

							wbm.wb_cmp(cyc_delay, stb_delay, dest_adr, my_dat +2);
						end
					end
				end
			end
		end

		// show Wishbone-Master-model current-error-counter 
		wbm.show_cur_err_cnt;
		$display("\nSDRAM/SRAM block copy test-2- ended");

	end
	endtask // tst_blk_cpy2

