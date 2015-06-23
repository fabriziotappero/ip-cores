`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Dept. Architecture and Computing Technology. University of Seville
// Engineer:       Miguel Angel Rodriguez Jodar
// 
// Create Date:    19:13:39 4-Apr-2012 
// Design Name:    ULA
// Module Name:    ula_reference_design 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define cyclestart(a,b) ((a)==(b))
`define cycleend(a,b) ((a)==(b+1))

module ula(
    input clk14,			// 14MHz master clock
	 // CPU interfacing
    input [15:0] a,		// Address bus from CPU (not all lines are used)
    input [7:0] d,		// Data bus from VRAM
    input mreq_n,			// MREQ from CPU
    input ioreq_n,		// IORQ+A0 from CPU
	 output clkcpu,		// CLK to CPU
	 output msk_int_n,	// Vertical retrace interrupt, to CPU
	 // VRAM interfacing
    output [13:0] va,	 // Address bus to VRAM (16K)
    output vramoe_n,		 // 
    output vramcs_n,		 // Control signals for VRAM
    output vramwe_n,		 //
	 // Control signals
	 output vram_in_use,  // ==1 to indicate that VRAM is in use by ULA
	 input [2:0] BorderColor,  // current border colour
	 // Video output
    output r,				//
    output g,				// RGB TTL signal
    output b,				// with separate bright
    output i,				// and composite sync
    output csync			//		 
    );

	// Pixel clock
	reg clk7 = 0;
	always @(posedge clk14)
		clk7 <= !clk7;
		
	// Horizontal counter
	reg [8:0] hc = 0;
	always @(posedge clk7) begin
		if (hc==447)
			hc <= 0;
		else
			hc <= hc + 1;
	end
	
	// Vertical counter
	reg [8:0] vc = 0;
	always @(posedge clk7) begin
		if (hc==447) begin
			if (vc == 311)
				vc <= 0;
			else
				vc <= vc + 1;
		end
	end
	
	// HBlank generation
	reg HBlank_n = 1;
	always @(negedge clk7) begin
		if (`cyclestart(hc,320))
			HBlank_n <= 0;
		else if (`cycleend(hc,415))
			HBlank_n <= 1;
	end

	// HSync generation (6C ULA version)
	reg HSync_n = 1;
	always @(negedge clk7) begin
		if (`cyclestart(hc,344))
			HSync_n <= 0;
		else if (`cycleend(hc,375))
			HSync_n <= 1;
	end

	// VBlank generation
	reg VBlank_n = 1;
	always @(negedge clk7) begin
		if (`cyclestart(vc,248))
			VBlank_n <= 0;
		else if (`cycleend(vc,255))
			VBlank_n <= 1;
	end
	
	// VSync generation (PAL)
	reg VSync_n = 1;
	always @(negedge clk7) begin
		if (`cyclestart(vc,248))
			VSync_n <= 0;
		else if (`cycleend(vc,251))
			VSync_n <= 1;
	end
		
	// INT generation
	reg INT_n = 1;
	assign msk_int_n = INT_n;
	always @(negedge clk7) begin
		if (`cyclestart(vc,248) && `cyclestart(hc,0))
			INT_n <= 0;
		else if (`cyclestart(vc,248) && `cycleend(hc,31))
			INT_n <= 1;
	end

	// Border control signal (=0 when we're not displaying paper/ink pixels)
	reg Border_n = 1;
	always @(negedge clk7) begin
		if ( (vc[7] & vc[6]) | vc[8] | hc[8])
			Border_n <= 0;
		else
			Border_n <= 1;
	end
	
	// VidEN generation (delaying Border 8 clocks)
	reg VidEN_n = 1;
	always @(negedge clk7) begin
		if (hc[3])
			VidEN_n <= !Border_n;
	end
	
	// DataLatch generation (posedge to capture data from memory)
	reg DataLatch_n = 1;
	always @(negedge clk7) begin
		if (hc[0] & !hc[1] & Border_n & hc[3])
			DataLatch_n <= 0;
		else
			DataLatch_n <= 1;
	end
	
	// AttrLatch generation (posedge to capture data from memory)
	reg AttrLatch_n = 1;
	always @(negedge clk7) begin
		if (hc[0] & hc[1] & Border_n & hc[3])
			AttrLatch_n <= 0;
		else
			AttrLatch_n <= 1;
	end

	// SLoad generation (negedge to load shift register)
	reg SLoad = 0;
	always @(negedge clk7) begin
		if (!hc[0] & !hc[1] & hc[2] & !VidEN_n)
			SLoad <= 1;
		else
			SLoad <= 0;
	end
	
	// AOLatch generation (negedge to update attr output latch)
	reg AOLatch_n = 1;
	always @(negedge clk7) begin
		if (hc[0] & !hc[1] & hc[2])
			AOLatch_n <= 0;
		else
			AOLatch_n <= 1;
	end

	// First buffer for bitmap
	reg [7:0] BitmapReg = 0;
	always @(negedge DataLatch_n) begin
		BitmapReg <= d;
	end
	
	// Shift register (second bitmap register)
	reg [7:0] SRegister = 0;
	always @(negedge clk7) begin
		if (SLoad)
			SRegister <= BitmapReg;
		else
			SRegister <= {SRegister[6:0],1'b0};
	end

	// First buffer for attribute
	reg [7:0] AttrReg = 0;
	always @(negedge AttrLatch_n) begin
		AttrReg <= d;
	end
	
	// Second buffer for attribute
	reg [7:0] AttrOut = 0;
	always @(negedge AOLatch_n) begin
		if (!VidEN_n)
			AttrOut <= AttrReg;
		else
			AttrOut <= {2'b00,BorderColor,BorderColor};
	end

	// Flash counter and pixel generation
	reg [4:0] FlashCnt = 0;
	always @(negedge VSync_n) begin
		FlashCnt <= FlashCnt + 1;
	end
	wire Pixel = SRegister[7] ^ (AttrOut[7] & FlashCnt[4]);

	// RGB generation
	reg rI,rG,rR,rB;
	assign r = rR;
	assign g = rG;
	assign b = rB;
	assign i = rI;
	always @(*) begin
		if (HBlank_n && VBlank_n)
			{rI,rG,rR,rB} = (Pixel)? {AttrOut[6],AttrOut[2:0]} : {AttrOut[6],AttrOut[5:3]};
		else
			{rI,rG,rR,rB} = 4'b0000;
	end
	
	//CSync generation
	assign csync = HSync_n & VSync_n;
	
	// VRAM address and control line generation
	reg [13:0] rVA = 0;
	reg rVCS_n = 1;
	reg rVOE_n = 1;
	reg rVWE_n = 1;
	reg rVRAMInUse = 0;
	assign va = rVA;
	assign vramcs_n = rVCS_n;
	assign vramoe_n = rVOE_n;
	assign vramwe_n = rVWE_n;
	assign vram_in_use = rVRAMInUse;
	// Latches to hold delayed versions of V and H counters
	reg [8:0] v = 0;
	reg [8:0] c = 0;
	// Address and control line multiplexor ULA/CPU
	always @(negedge clk7) begin
		if (Border_n && (hc[3:0]==4'b0111 || hc[3:0]==4'b1011)) begin	// cycles 7 and 11: load V and C from VC and HC
			c <= hc;
			v <= vc;
		end
	end
	// Address and control line multiplexor ULA/CPU
	always @(*) begin
		if (Border_n && (hc[3:0]==4'b1000 || hc[3:0]==4'b1001 || hc[3:0]==4'b1100 || hc[3:0]==4'b1101)) begin	// cycles 8 and 12: present display address to VRAM 
			rVA = {1'b0,v[7:6],v[2:0],v[5:3],c[7:3]};						// (cycles 9 and 13 load display byte)
			rVCS_n = 0;
			rVOE_n = 0;
			rVWE_n = 1;
			rVRAMInUse = 1;
		end
		else if (Border_n && (hc[3:0]==4'b1010 || hc[3:0]==4'b1011 || hc[3:0]==4'b1110 || hc[3:0]==4'b1111)) begin	// cycles 10 and 14: present attribute address to VRAM
			rVA = {4'b0110,v[7:3],c[7:3]};										// (cycles 11 and 15 load attr byte)
			rVCS_n = 0;
			rVOE_n = 0;
			rVWE_n = 1;
			rVRAMInUse = 1;
		end
		else begin	// when VRAM is not in use by ULA, give it to CPU by putting ULA lines in high impedance mode.
			rVA = 14'bzzzzzzzzzzzzzz;
			rVCS_n = 1'bz;
			rVOE_n = 1'bz;
			rVWE_n = 1'bz;
			rVRAMInUse = 0;
		end
	end
				
	// CPU contention
	reg CPUClk = 0;
	assign clkcpu = CPUClk;
	reg ioreqtw3 = 0;
	reg mreqt23 = 0;
	wire Nor1 = (~(a[14] | ~ioreq_n)) | 
	            (~(~a[15] | ~ioreq_n)) | 
					(~(hc[2] | hc[3])) | 
					(~Border_n | ~ioreqtw3 | ~CPUClk | ~mreqt23);
	wire Nor2 = (~(hc[2] | hc[3])) | 
	            ~Border_n |
					~CPUClk |
					ioreq_n |
					~ioreqtw3;
	wire CLKContention = ~Nor1 | ~Nor2;
	always @(posedge clk7) begin	// change clk7 by clk14 for 7MHz CPU clock operation
		if (CPUClk && !CLKContention)   // if there's no contention, the clock can go low
			CPUClk <= 0;
		else
			CPUClk <= 1;
	end	
	always @(posedge CPUClk) begin
		ioreqtw3 <= ioreq_n;
		mreqt23 <= mreq_n;
	end
endmodule
