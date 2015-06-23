/*!
   memfifo -- implementation of EZ-USB slave FIFO's (input and output) a FIFO using the DDR3 SDRAM for ZTEX USB-FPGA Modules 2.13
   Copyright (C) 2009-2014 ZTEX GmbH.
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
/*
   Implements the EZ-USB Slave FIFO interface for both 
   directions. It also includes an scheduler (required if both
   directions are used at the same time) and short packets (PKTEND).
*/  
module ezusb_io #(
	parameter OUTEP = 2,            // EP for FPGA -> EZ-USB transfers
	parameter INEP = 6              // EP for EZ-USB -> FPGA transfers 
    ) (
        output ifclk,
        input reset,                    // asynchronous reset input
        output reset_out,		// synchronous reset output
        // pins
        input ifclk_in,
        inout [15:0] fd,
	output reg SLWR, PKTEND,
	output SLRD, SLOE, 
	output [1:0] FIFOADDR,
	input EMPTY_FLAG, FULL_FLAG,
	// signals for FPGA -> EZ-USB transfer
        input [15:0] DI,                // data written to EZ-USB
        input DI_valid,			// 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
        output DI_ready, 		// 1 if new data are accepted
        input DI_enable,		// setting to 0 disables FPGA -> EZ-USB transfers
        input [15:0] pktend_timeout,	// timeout in multiples of 65536 clocks before a short packet committed
    					// setting to 0 disables this feature
	// signals for EZ-USB -> FPGA transfer
        output reg [15:0] DO,           // data read from EZ-USB
        output reg DO_valid,		// 1 indicated valid data
        input DO_ready,			// setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
    					// set to 0 to disable data reads 
        // debug output
        output [3:0] status
    );


    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    
    IBUFG ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk_inbuf) 
    );

    BUFG ifclk_fb_buf (
        .I(ifclk_fbout),
        .O(ifclk_fbin)
     ); 

    BUFG ifclk_out_buf (
        .I(ifclk_out),
        .O(ifclk)
     ); 

    MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT_F(20.0),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(0.0),
       .CLKOUT0_DIVIDE_F(20.0), 
       .CLKOUT1_DIVIDE(1),
       .CLKOUT2_DIVIDE(1),
       .CLKOUT3_DIVIDE(1),
       .CLKOUT4_DIVIDE(1),
       .CLKOUT5_DIVIDE(1),
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT4_CASCADE("FALSE"), 
       .DIVCLK_DIVIDE(1),
       .REF_JITTER1(0.0),
       .STARTUP_WAIT("FALSE")
    )  isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       .CLKFBOUT(ifclk_fbout),
       .CLKIN1(ifclk_inbuf),
       .PWRDWN(1'b0),
       .RST(reset),
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    reg reset_ifclk = 1;
    reg if_out, if_in;
    reg [4:0] if_out_buf;
    reg [15:0] fd_buf;
    reg resend;
    reg SLRD_buf, pktend_req, pktend_en;
    reg [31:0] pktend_cnt;

    // FPGA <-> EZ-USB signals
    assign SLOE = if_out;
//    assign FIFOADDR[0] = 1'b0;
//    assign FIFOADDR[1] = !if_out;
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1;
    assign fd = if_out ? fd_buf : {16{1'bz}};
    assign SLRD = SLRD_buf || !DO_ready;

    assign status = { !SLRD_buf, !SLWR, resend, if_out };

    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out & if_out_buf[4] && !resend;
    assign reset_out = reset || reset_ifclk;
    
    always @ (posedge ifclk)
    begin
	reset_ifclk <= reset || !locked;
	// FPGA -> EZ-USB
        if ( reset_ifclk )
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;  // direction of EZ-USB interface: 1 means FPGA writes / EZ_USB reads
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf = {5{!DI_enable}};
	end else if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )  	// FPGA -> EZ-USB
	begin
	    SLWR <= 1'b0;
	    SLRD_buf <= 1'b1;
	    resend <= 1'b0;
	    if ( !resend ) fd_buf <= DI;
	end else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready )  		// EZ-USB -> FPGA
	begin
	    SLWR <= 1'b1;
	    DO <= fd;
	    SLRD_buf <= 1'b0;
	end else if (if_out == if_out_buf[4])
	begin
	    if ( !SLWR && !FULL_FLAG ) resend <= 1'b1;  // FLAGS are received two clocks after data. If FULL_FLAG was asserted last data was ignored and has to be re-sent.
	    SLRD_buf <= 1'b1;
	    SLWR <= 1'b1;
	    if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG);
	end 
	if_out_buf <= { if_out_buf[3:0], if_out };
	if ( DO_ready ) DO_valid <= !if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf;  // assertion of SLRD_buf takes two clocks to take effect
	
	// PKTEND processing
        if ( reset_ifclk || DI_valid )
        begin
    	    pktend_req <= 1'b0;
    	    pktend_en <= !reset_ifclk;
    	    pktend_cnt <= 32'd0;
    	    PKTEND <= 1'b1;
    	end else 
    	begin
    	    pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
    	    pktend_cnt <= pktend_cnt + 1;
    	    if ( pktend_req && if_out && if_out_buf[4] )
    	    begin
    		PKTEND <= 1'b0;
    		pktend_req <= 1'b0;
    		pktend_en <= 1'b0;
    	    end else 
    	    begin
    		PKTEND <= 1'b1;
    		pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
    	    end
    	end
    	    
	
	
    end


endmodule

