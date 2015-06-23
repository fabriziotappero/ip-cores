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
   Top level module: glues everything together.    
*/  

`define IDX(x) (((x)+1)*(8)-1):((x)*(8))

module memfifo (
	input fxclk_in,
	input ifclk_in,
	input reset,
	input [1:0] mode,
	// debug
	output [9:0] led1,
	output [19:0] led2,
	input SW8,
	input SW10,
	// ddr3 
	inout [15:0] ddr3_dq,
	inout [1:0] ddr3_dqs_n,
	inout [1:0] ddr3_dqs_p,
	output [13:0] ddr3_addr,
	output [2:0] ddr3_ba,
	output ddr3_ras_n,
	output ddr3_cas_n,
	output ddr3_we_n,
        output ddr3_reset_n,
	output [0:0] ddr3_ck_p,
        output [0:0] ddr3_ck_n,
	output [0:0] ddr3_cke,
        output [1:0] ddr3_dm,
	output [0:0] ddr3_odt,
	// ez-usb
        inout [15:0] fd,
	output SLWR, SLRD,
	output SLOE, FIFOADDR0, FIFOADDR1, PKTEND,
	input FLAGA, FLAGB
    );

    wire reset_mem, reset_usb;
    wire ifclk;
    reg reset_ifclk;
    wire [24:0] mem_free;
    wire [9:0] status;
    wire [3:0] if_status;
    reg [1:0] mode_buf;
    
    // input fifo
    reg [127:0] DI;
    wire FULL, WRERR, USB_DO_valid;
    reg WREN, wrerr_buf;
    wire [15:0] USB_DO;
    reg [127:0] in_data;
    reg [3:0] wr_cnt;
    reg [6:0] test_cnt;
    reg [13:0] test_cs;
    reg in_valid;
    wire test_sync;
    reg [1:0] clk_div;

    // output fifo
    wire [127:0] DO;
    wire EMPTY, RDERR, USB_DI_ready;
    reg RDEN, rderr_buf, USB_DI_valid;
    reg [127:0] rd_buf;
    reg [2:0] rd_cnt;

    dram_fifo #(
        .FIRST_WORD_FALL_THROUGH("TRUE"),  			// Sets the FIFO FWFT to FALSE, TRUE
	.ALMOST_EMPTY_OFFSET2(13'h0008),
    ) dram_fifo_inst (
	.fxclk_in(fxclk_in),					// 48 MHz input clock pin
        .reset(reset || reset_usb),
        .reset_out(reset_mem),					// reset output
      	.clkout2(),	 					// PLL clock outputs not used for memory interface
      	.clkout3(),	
      	.clkout4(),	
      	.clkout5(),	
	// Memory interface ports
	.ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .ddr3_addr(ddr3_addr),
        .ddr3_ba(ddr3_ba),
        .ddr3_ras_n(ddr3_ras_n),
        .ddr3_cas_n(ddr3_cas_n),
        .ddr3_we_n(ddr3_we_n),
        .ddr3_reset_n(ddr3_reset_n),
        .ddr3_ck_p(ddr3_ck_p),
        .ddr3_ck_n(ddr3_ck_n),
        .ddr3_cke(ddr3_cke),
	.ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt),
	// input fifo interface, see "7 Series Memory Resources" user guide (ug743)
	.DI(DI),
        .FULL(FULL),                    // 1-bit output: Full flag
        .ALMOSTFULL1(),  	     	// 1-bit output: Almost full flag
        .ALMOSTFULL2(),  	     	// 1-bit output: Almost full flag
        .WRERR(WRERR),                  // 1-bit output: Write error
        .WREN(WREN),                    // 1-bit input: Write enable
        .WRCLK(ifclk),                  // 1-bit input: Rising edge write clock.
	// output fifo interface, see "7 Series Memory Resources" user guide (ug743)
	.DO(DO),
	.EMPTY(EMPTY),                  // 1-bit output: Empty flag
        .ALMOSTEMPTY1(),                // 1-bit output: Almost empty flag
        .ALMOSTEMPTY2(),                // 1-bit output: Almost empty flag
        .RDERR(RDERR),                  // 1-bit output: Read error
        .RDCLK(ifclk),                  // 1-bit input: Read clock
        .RDEN(RDEN),                    // 1-bit input: Read enable
	// free memory
	.mem_free_out(mem_free),
	// for debugging
	.status(status)
    );

    ezusb_io #(
	.OUTEP(2),		        // EP for FPGA -> EZ-USB transfers
	.INEP(6), 		        // EP for EZ-USB -> FPGA transfers 
    ) ezusb_io_inst (
        .ifclk(ifclk),
        .reset(reset),   		// asynchronous reset input
        .reset_out(reset_usb),		// synchronous reset output
        // pins
        .ifclk_in(ifclk_in),
        .fd(fd),
	.SLWR(SLWR),
	.SLRD(SLRD),
	.SLOE(SLOE), 
	.PKTEND(PKTEND),
	.FIFOADDR({FIFOADDR1, FIFOADDR0}), 
	.EMPTY_FLAG(FLAGA),
	.FULL_FLAG(FLAGB),
	// signals for FPGA -> EZ-USB transfer
	.DI(rd_buf[15:0]),		// data written to EZ-USB
	.DI_valid(USB_DI_valid),	// 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
	.DI_ready(USB_DI_ready),	// 1 if new data are accepted
	.DI_enable(1'b1),		// setting to 0 disables FPGA -> EZ-USB transfers
        .pktend_timeout(16'd73),	// timeout in multiples of 65536 clocks (approx. 0.1s @ 48 MHz) before a short packet committed
    					// setting to 0 disables this feature
	// signals for EZ-USB -> FPGA transfer
	.DO(USB_DO),			// data read from EZ-USB
	.DO_valid(USB_DO_valid),	// 1 indicated valid data
	.DO_ready((mode_buf==2'd0) && !reset_ifclk && !FULL),	// setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
        // debug output
	.status(if_status)	
    );

/*    BUFR ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk) 
    ); */
//    assign ifclk = ifclk_in;

    // debug board LEDs    
    assign led1 = SW10 ? status : { EMPTY, FULL, wrerr_buf, rderr_buf, if_status, FLAGB, FLAGA };
    
    assign led2[0] = mem_free != { 1'b1, 24'd0 };
    assign led2[1] = mem_free[23:19] < 5'd30;
    assign led2[2] = mem_free[23:19] < 5'd29;
    assign led2[3] = mem_free[23:19] < 5'd27;
    assign led2[4] = mem_free[23:19] < 5'd25;
    assign led2[5] = mem_free[23:19] < 5'd24;
    assign led2[6] = mem_free[23:19] < 5'd22;
    assign led2[7] = mem_free[23:19] < 5'd20;
    assign led2[8] = mem_free[23:19] < 5'd19;
    assign led2[9] = mem_free[23:19] < 5'd17;
    assign led2[10] = mem_free[23:19] < 5'd15;
    assign led2[11] = mem_free[23:19] < 5'd13;
    assign led2[12] = mem_free[23:19] < 5'd12;
    assign led2[13] = mem_free[23:19] < 5'd10;
    assign led2[14] = mem_free[23:19] < 5'd8;
    assign led2[15] = mem_free[23:19] < 5'd7;
    assign led2[16] = mem_free[23:19] < 5'd5;
    assign led2[17] = mem_free[23:19] < 5'd3;
    assign led2[18] = mem_free[23:19] < 5'd2;
    assign led2[19] = mem_free == 25'd0;

    assign test_sync = wr_cnt[0] || (wr_cnt == 4'd14);

    always @ (posedge ifclk)
    begin
	reset_ifclk <= reset || reset_usb || reset_mem;
	
	if ( reset_ifclk ) 
	begin
	    rderr_buf <= 1'b0;
	    wrerr_buf <= 1'b0;
	end else
	begin
	    rderr_buf <= rderr_buf || RDERR;
	    wrerr_buf <= wrerr_buf || WRERR;
	end

	// FPGA -> EZ-USB FIFO
        if ( reset_ifclk )
        begin
	    rd_cnt <= 3'd0;
	    USB_DI_valid <= 1'd0;
	end else if ( USB_DI_ready )
	begin
	    USB_DI_valid <= !EMPTY;
	    if ( !EMPTY )
	    begin
	        if ( rd_cnt == 3'd0 )
	        begin
	    	    rd_buf <= DO;
		end else
	    	begin
	    	    rd_buf[111:0] <= rd_buf[127:16];
		end
		rd_cnt <= rd_cnt+1;
	    end
	end

	RDEN <= !reset_ifclk && USB_DI_ready && !EMPTY && (rd_cnt==3'd0);
	
	if ( reset_ifclk ) 
	begin
	    in_data <= 128'd0;
	    in_valid <= 1'b0;
	    wr_cnt <= 4'd0;
	    test_cnt <= 7'd0;
	    test_cs <= 12'd47;
	    WREN <= 1'b0;
	    clk_div <= 2'd3;
	end else if ( !FULL )
	begin
	    if ( in_valid ) DI <= in_data;

    	    if ( mode_buf == 2'd0 )		// input from USB
    	    begin
    		if ( USB_DO_valid )
    		begin
		    in_data <= { USB_DO, in_data[127:16] };
		    in_valid <= wr_cnt[2:0] == 3'd7;
	    	    wr_cnt <= wr_cnt + 1;
	    	end else
	    	begin
		    in_valid <= 1'b0;
		end
    	    end else if ( clk_div == 2'd0 )	// test data generator
	    begin
	        if ( wr_cnt == 4'd15 )
	        begin
	    	    test_cs <= 12'd47;
		    in_data[126:120] <= test_cs[6:0] ^ test_cs[13:7];
		    in_valid <= 1'b1;
		end else
		begin
		    test_cnt <= test_cnt + 7'd111;
		    test_cs <= test_cs + { test_sync, test_cnt };
		    in_data[126:120] <= test_cnt;
		    in_valid <= 1'b0;
		end
		in_data[127] <= test_sync;
		in_data[119:0] <= in_data[127:8];
	    	wr_cnt <= wr_cnt + 1;
	    end else 
	    begin
	        in_valid <= 1'b0;
	    end

	    if ( (mode_buf==2'd1) || ((mode_buf==2'd3) && SW8 ) ) 
	    begin
	        clk_div <= 2'd0;	// data rate: 48 MByte/s
	    end else 
	    begin
	        clk_div <= clk_div + 1;	// data rate: 12 MByte/s
	    end
	end
	WREN <= !reset_ifclk && in_valid && !FULL;
	mode_buf<=mode;
    end
	    
endmodule

