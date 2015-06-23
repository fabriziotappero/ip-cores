/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  Asynchronous memory devices tests                          ////
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
//  $Id: tst_asram.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
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


	///////////////////////////////////////
	// Asynchronous memory sequential test
	//

	// 1) Fill entire SRAM memory using sequential accesses
	// 2) Test 8/16/32 bit wide asynchronous accesses
	// 2) Verify memory contents
	//
	// THIS IS A FULL MEMORY TEST, TAKES A WHILE
	task tst_amem_seq;
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SRAM_STARTA = `SRAM_LOC;
		parameter [ 7:0] SRAM_SEL = SRAM_STARTA[28:21];
		parameter SRAM_TST_RUN = 1<<11; // entire sram memory

		integer n, cnt;
		reg [1:0] tmp;
		reg [31:0] my_adr;
		reg [31:0] my_dat;

		reg[1:0] bw;
		reg [31:0] csr_data, tms_data;

		integer cyc_delay, stb_delay;

		begin

			$display("\n\n --- ASYNCHRONOUS MEMORY SEQUENTIAL/FILL TEST ---\n\n");

			bw = 2;
			for (bw = 0; bw < 3; bw = bw +1)
			begin
				csr_data = {
					8'h00,    //     reserved
					SRAM_SEL, // SEL base address (a[28:21] == 8'b0100_0000)
					4'h0,     //     reserved
					1'b0,     // PEN no parity
					1'b0,     // KRO ---
					1'b0,     // BAS ---
					1'b0,     // WP  no write protection
					2'b00,    // MS  ---
					bw,       // BW  Bus width
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
				wbm.wb_write(0, 0, 32'h6000_0018, csr_data);      // program cs1 config register
				wbm.wb_write(0, 0, 32'h6000_001c, tms_data);      // program cs1 timing register

				// check written data
				wbm.wb_cmp(0, 0, 32'h6000_0018, csr_data);
				wbm.wb_cmp(0, 0, 32'h6000_001c, tms_data);

				cyc_delay = 1;
				stb_delay = 1;
				for (cyc_delay = 0; cyc_delay < MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
				for (stb_delay = 0; stb_delay < MAX_STB_DELAY; stb_delay = stb_delay +1)
					begin				
						$display("Asynchronous memory sequential test. CYC-delay = %d, STB-delay = %d, BW = %d", cyc_delay, stb_delay, bw);
						
						// fill srams
						tmp = ~(bw +1);

						my_dat = 0;
						for (n=0; n < (SRAM_TST_RUN<<tmp); n=n+1)
							begin
								my_adr = SRAM_STARTA + (n << bw);

								cnt = (n >> tmp) + cyc_delay + stb_delay;

								case (bw)
									2'b00: //  8bit asynchronous memory connected
										case (n[1:0])
											2'b00: my_dat[7:0] = ~cnt[ 7:0];
											2'b01: my_dat[7:0] = ~cnt[15:8];
											2'b10: my_dat[7:0] =  cnt[ 7:0];
											2'b11: my_dat[7:0] =  cnt[15:8];
										endcase
									2'b01: // 16bit asynchronous memory connected
										if (n[0])
											my_dat[15:0] = cnt;
										else
											my_dat[15:0] = ~cnt;
									2'b10: // 32bit asynchronous memory connected
										begin
											my_dat[31:16] = cnt;
											my_dat[15: 0] = ~cnt;
										end
									2'b11: // reserved
										begin
										end
								endcase

								wbm.wb_write(cyc_delay, stb_delay, my_adr, my_dat);
							end

						// read srams
						my_dat = 0;
						for (n=0; n < SRAM_TST_RUN; n=n+1)
							begin
								my_adr = SRAM_STARTA + (n<<2); // always read 32bits
								my_dat[31:16] =  (n + cyc_delay + stb_delay);
								my_dat[15: 0] = ~(n + cyc_delay + stb_delay);

								wbm.wb_cmp(cyc_delay, stb_delay, my_adr, my_dat);
							end
					end
			end

			$display("\nAsynchronous memory sequential test ended");

		end
	endtask // tst_amem_seq


	///////////////////////////////////////
	// Asynchronous memory back2back test
	//

	// 1) Test back-2-back read/write accesses to asynchronous memory
	task tst_amem_b2b;
		parameter MAX_CYC_DELAY = 5;
		parameter MAX_STB_DELAY = 5;

		parameter [31:0] SRAM_STARTA = `SRAM_LOC;
		parameter [ 7:0] SRAM_SEL = SRAM_STARTA[28:21];
		parameter SRAM_TST_RUN = 64; // only do a few accesses

		integer n, cnt;
		reg [1:0] tmp;
		reg [31:0] my_adr;
		reg [31:0] my_dat;

		reg [31:0] csr_data, tms_data;

		integer cyc_delay, stb_delay;

		begin
			csr_data = {
				8'h00,    //     reserved
				SRAM_SEL, // SEL base address (a[28:21] == 8'b0100_0000)
				4'h0,     //     reserved
				1'b0,     // PEN no parity
				1'b0,     // KRO ---
				1'b0,     // BAS ---
				1'b0,     // WP  no write protection
				2'b00,    // MS  ---
				2'h2,     // BW  32bit Bus width
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
			wbm.wb_write(0, 0, 32'h6000_0018, csr_data);      // program cs1 config register
			wbm.wb_write(0, 0, 32'h6000_001c, tms_data);      // program cs1 timing register

			// check written data
			wbm.wb_cmp(0, 0, 32'h6000_0018, csr_data);
			wbm.wb_cmp(0, 0, 32'h6000_001c, tms_data);

			cyc_delay = 1;
			stb_delay = 1;
			for (cyc_delay = 0; cyc_delay <= MAX_CYC_DELAY; cyc_delay = cyc_delay +1)
			for (stb_delay = 0; stb_delay <= MAX_STB_DELAY; stb_delay = stb_delay +1)
				begin				
					$display("Asynchronous memory back-2-back test. CYC-delay = %d, STB-delay = %d", cyc_delay, stb_delay);
						
					// fill srams

					my_dat = 0;
					for (n=0; n < SRAM_TST_RUN; n=n+1)
						begin
							my_adr = SRAM_STARTA + (n << 2);

							cnt = n + cyc_delay + stb_delay;

							my_dat[31:16] = cnt;
							my_dat[15: 0] = ~cnt;

							wbm.wb_write(cyc_delay, stb_delay, my_adr, my_dat);

							// read srams
							my_adr = SRAM_STARTA + (n<<2); // always read 32bits
							wbm.wb_cmp(cyc_delay, stb_delay, my_adr, my_dat);
						end
				end

			$display("\nAsynchronous memory back-2-back test ended");
		end
	endtask // tst_amem_b2b

