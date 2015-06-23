/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: HDL code for ZTEX USB-FPGA Module 1.15b (one double hash pipe)
   Copyright (C) 2011-2012 ZTEX GmbH
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

module ztex_ufm1_15d3 (fxclk_in, reset, clk_reset, pll_stop,  dcm_progclk, dcm_progdata, dcm_progen,  rd_clk, wr_clk, wr_start, read, write);

	input fxclk_in, reset, clk_reset, pll_stop, dcm_progclk, dcm_progdata, dcm_progen, rd_clk, wr_clk, wr_start;
	input [7:0] read;
	output [7:0] write;

	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2, reset_buf;
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [95:0] outbuf;
	reg [7:0] read_buf, write_buf;
	
	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset;
	wire [2:1] dcm_status;
	wire [31:0] golden_nonce, nonce2, hash2;
	
	miner253 m (
	    .clk(clk),
	    .reset(reset_buf),
	    .midstate(inbuf[351:96]),
	    .data(inbuf[95:0]),
	    .golden_nonce(golden_nonce),
	    .nonce2(nonce2),
	    .hash2(hash2)
	);

	BUFG bufg_fxclk (
          .I(fxclk_in),
          .O(fxclk)
        );

	BUFG bufg_clk (
          .I(pll_clk0),
          .O(clk)
        );

        DCM_CLKGEN #(
	  .CLKFX_DIVIDE(4.0),
          .CLKFX_MULTIPLY(32),
          .CLKFXDV_DIVIDE(2),
          .CLKIN_PERIOD(20.8333)
	) 
	dcm0 (
    	  .CLKIN(fxclk),
          .CLKFXDV(dcm_clk),
          .FREEZEDCM(1'b0),
          .PROGCLK(dcm_progclk_buf),
          .PROGDATA(dcm_progdata_buf),
          .PROGEN(dcm_progen_buf),
          .LOCKED(dcm_locked),
          .STATUS(dcm_status),
          .RST(clk_reset)
	);

	PLL_BASE #(
    	    .BANDWIDTH("LOW"),
    	    .CLKFBOUT_MULT(4),
    	    .CLKOUT0_DIVIDE(4),
    	    .CLKOUT0_DUTY_CYCLE(0.5),
    	    .CLK_FEEDBACK("CLKFBOUT"), 
    	    .COMPENSATION("INTERNAL"),
	    .DIVCLK_DIVIDE(1),
    	    .REF_JITTER(0.10),
	    .RESET_ON_LOSS_OF_LOCK("FALSE")
       )
       pll0 (
    	    .CLKFBOUT(pll_fb),
	    .CLKOUT0(pll_clk0),
	    .CLKFBIN(pll_fb),
	    .CLKIN(dcm_clk),
	    .RST(pll_reset)
	);

	assign write = write_buf;
	assign pll_reset = pll_stop | ~dcm_locked | clk_reset | dcm_status[2];
	
	always @ (posedge clk)
	begin
    		if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
		begin
		    inbuf_tmp[351:344] <= read_buf;
		    inbuf_tmp[343:0] <= inbuf_tmp[351:8];
		end;
		inbuf <= inbuf_tmp;  // due to TIG's
		    
		if ( wr_start_b1 && wr_start_b2 )
		begin
   		    wr_delay <= 5'd0;
		end else 
		begin
		    wr_delay[0] <= 1'b1;
		    wr_delay[4:1] <= wr_delay[3:0];
		end
		
		if ( ! wr_delay[4] ) 
		begin
   		    outbuf <= { hash2, nonce2, golden_nonce };
   		end else
   		begin
		    if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) ) 
			outbuf[87:0] <= outbuf[95:8];
   		end

		read_buf <= read;
		write_buf <= outbuf[7:0];

		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];

		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];

		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;

		
		reset_buf <= reset;
	end

	always @ (posedge fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end


endmodule

