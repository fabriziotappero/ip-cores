/* ===============================================================
	(C) 2005  Robert Finch
	All rights reserved.
	robfinch@opencores.org

	rtfSpriteController.v
		sprite / hardware cursor controller

	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If you do modify the code, please state the origin and
	note that you have modified the code.

	NO WARRANTY.
	THIS Work, IS PROVIDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.


	Sprite Controller

	FEATURES
	- parameterized number of sprites
	- eight sprite image cache buffers
		- each image cache is capable of holding multiple
		  sprite images
		- cache may be accessed like a memory by the processor
		- an embedded DMA controller may also be used for
			sprite reload
	- programmable image offset within cache
	- programmable sprite width,height, and pixel size
		- sprite width and height may vary from 1 to 64 as long
		  as the product doesn't exceed 1024.
	    - pixels may be programmed to be 1,2,3 or 4 video clocks
	      both height and width are programmable
	- programmable sprite position
	- 16 bits for color
		eg 32k color + 1 bit alpha blending indicator (1,5,5,5)
	- fixed display and DMA priority
	    sprite 0 highest, sprite 7 lowest

		This core requires an external timing generator to
	provide horizontal and vertical sync signals, but
	otherwise can be used as a display controller on it's
	own. However, normally this core would be embedded
	within another core such as a VGA controller. Sprite
	positions are referenced to the rising edge of the
	vertical and horizontal sync pulses.
		The core includes an embedded dual port RAM to hold the
	sprite images. The image RAM is updated using a built in DMA
	controller. The DMA controller uses 16 bit accesses to fill
	the sprite buffers, as the sprite buffers are only 16 bits
	wide. The circuit features an automatic bus transaction
	timeout; if the system bus hasn't responded within 20 clock
	cycles, the DMA controller moves onto the next address.
		The controller uses a ram underlay to cache the values
	of the registers. This is a lot cheaper resource wise than
	using a 32 to 1 multiplexor (well at least for an FPGA).

	All registers are 16 bits wide

	These registers repeat in incrementing block of four registers
	and pertain to each sprite
	0:	HPOS	- position register
			[15: 0]	horizontal position (hctr value)
	1:	VPOS	[15:0]	vertical position (vctr value)

	2:	SZ	- size register
			bits
			[ 5: 0]	width of sprite in pixels - 1
			[ 7: 6]	size of horizontal pixels - 1 in clock cycles
			[13: 8]	height of sprite in pixels -1
			[15:14]	size of vertical pixels in scan-lines - 1
				* the product of width * height cannot exceed 1024 !
				if it does, the display will begin repeating
				
	3: OFFS	[9:0] image offset
			offset of the sprite image within the sprite image cache
			typically zero

	4: ADRH	[15:0] sprite image address bits [42:27]
	5: ADRL	[15:0] sprite image address bits [26:11]
			These registers contain the location of the sprite image
			in system memory.	
			The low order 11 bits are fixed at zero. The DMA
			controller will assign the low order 11 bits
			during DMA.
	
	6: TC	[15:0]	transparent color
			This register identifies which color of the sprite
			is transparent


	8-63:	registers for seven other sprites

	Global status and control
	116: BTC	[23:0] background transparent color
	117: BTC
	118: BC	[23:0] background color
	119: BC
	120: EN	[15:0] sprite enable register
	121: IE	[15:0] sprite interrupt enable / status
	122: SCOL	[15:0] sprite-sprite collision register
	123: BCOL	[15:0] sprite-background collision register
	124: DT		[ 7:0] sprite DMA trigger


	1635 LUTs/ 1112 slices/ 82MHz - Spartan3e-4
	3 8x8 multipliers (for alpha blending)
	8 block rams
=============================================================== */

`define VENDOR_XILINX	// block ram vendor (only one defined for now)

module rtfSpriteController(
// Bus Slave interface
//------------------------------
// Slave signals
input rst_i,			// reset
input clk_i,			// clock
input         s_cyc_i,	// cycle valid
input         s_stb_i,	// data transfer
output        s_ack_o,	// transfer acknowledge
input         s_we_i,	// write
input  [ 1:0] s_sel_i,	// byte select
input  [43:0] s_adr_i,	// address
input  [15:0] s_dat_i,	// data input
output reg [15:0] s_dat_o,	// data output
output vol_o,			// volatile register
//------------------------------
// Bus Master Signals
output reg    m_soc_o,	// start of cycle
output        m_cyc_o,	// cycle is valid
output		  m_stb_o,	// strobe output
input         m_ack_i,	// input data is ready
output        m_we_o,		// write (always inactive)
output [ 1:0] m_sel_o,	// byte select
output [43:0] m_adr_o,	// DMA address
input  [15:0] m_dat_i,	// data input
output [15:0] m_dat_o,	// data output (always zero)
//--------------------------
input vclk,					// video dot clock
input hSync,				// horizontal sync pulse
input vSync,				// vertical sync pulse
input blank,				// blanking signal
input [24:0] rgbIn,			// input pixel stream
output reg [23:0] rgbOut,	// output pixel stream
output irq					// interrupt request
);

//--------------------------------------------------------------------
// Core Parameters
//--------------------------------------------------------------------
parameter pnSpr = 8;		// number of sprites
parameter phBits = 11;		// number of bits in horizontal timing counter
parameter pvBits = 11;		// number of bits in vertical timing counter
parameter pColorBits = 16;	// number of bits used for color data
localparam pnSprm = pnSpr-1;


//--------------------------------------------------------------------
// Variable Declarations
//--------------------------------------------------------------------

wire [2:0] sprN = s_adr_i[6:4];

reg [phBits-1:0] hctr;		// horizontal reference counter (counts dots since hSync)
reg [pvBits-1:0] vctr;		// vertical reference counter (counts scanlines since vSync)
reg sprSprIRQ;
reg sprBkIRQ;

reg [15:0] out;			// sprite output
reg outact;				// sprite output is active
wire bkCollision;		// sprite-background collision
reg [23:0] bgTc;		// background transparent color
reg [23:0] bkColor;		// background color


reg [7:0] sprWe;	// block ram write enable for image cache update
reg [7:0] sprRe;	// block ram read enable for image cache update

// Global control registers
reg [7:0] sprEn;   // enable sprite
reg [7:0] sprCollision;	    // sprite-sprite collision
reg sprSprIe;			// sprite-sprite interrupt enable
reg sprBkIe;            // sprite-background interrupt enable
reg sprSprIRQPending;   // sprite-sprite collision interrupt pending
reg sprBkIRQPending;    // sprite-background collision interrupt pending
reg sprSprIRQPending1;  // sprite-sprite collision interrupt pending
reg sprBkIRQPending1;   // sprite-background collision interrupt pending
reg sprSprIRQ1;			// vclk domain regs
reg sprBkIRQ1;

// Sprite control registers
reg [7:0] sprSprCollision;
reg [7:0] sprSprCollision1;
reg [7:0] sprBkCollision;
reg [7:0] sprBkCollision1;
reg [pColorBits-1:0] sprTc [pnSprm:0];		// sprite transparent color code
// How big the pixels are:
// 1,2,3,or 4 video clocks
reg [1:0] hSprRes [pnSprm:0];		// sprite horizontal resolution
reg [1:0] vSprRes [pnSprm:0];		// sprite vertical resolution
reg [5:0] sprWidth [pnSprm:0];		// number of pixels in X direction
reg [5:0] sprHeight [pnSprm:0];		// number of vertical pixels

// display and timing signals
reg [7:0] hSprReset;   // horizontal reset
reg [7:0] vSprReset;   // vertical reset
reg [7:0] hSprDe;		// sprite horizontal display enable
reg [7:0] vSprDe;		// sprite vertical display enable
reg [7:0] sprDe;			// display enable
reg [phBits-1:0] hSprPos [7:0];	// sprite horizontal position
reg [pvBits-1:0] vSprPos [7:0];	// sprite vertical position
reg [5:0] hSprCnt [7:0];	// sprite horizontal display counter
reg [5:0] vSprCnt [7:0];	// vertical display counter
reg [9:0] sprImageOffs [7:0];	// offset within sprite memory
reg [9:0] sprAddr [7:0];	// index into sprite memory
reg [9:0] sprAddrB [7:0];	// backup address cache for rescan
wire [pColorBits-1:0] sprOut [7:0];	// sprite image data output

// DMA access
reg [26:11] sprSysAddrL [7:0];	// system memory address of sprite image (low bits)
reg [42:27] sprSysAddrH [7:0];	// system memory address of sprite image (high bits)
reg [2:0] dmaOwner;			// which sprite has the DMA channel
reg [7:0] sprDt;		// DMA trigger register
wire dmaDone;				// DMA is finished
reg [10:0] dmaCount;		// this counter forms the low order 11 bits of the system address for DMA
reg [10:0] dmaCountNext;	// next value dmaCount will be loaded with
reg [10:0] updAdr;			// this counter is used to index the sprite image cache
reg [10:0] updAdrNext;
reg dmaStart;				// this flag pulses high for a single cycle at the start of a DMA
reg dmaActive;				// this flag indicates that a block DMA transfer is active

integer n;

//--------------------------------------------------------------------
// DMA control / bus interfacing
//--------------------------------------------------------------------
wire cs_ram = s_cyc_i && s_stb_i && (s_adr_i[43:16]==28'hFFF_FFD8);
wire cs_regs = s_cyc_i && s_stb_i && (s_adr_i[43:8]==36'hFFF_FFDA_D0);

reg sprRamRdy;
always @(posedge clk_i)
	sprRamRdy = cs_ram;


assign m_stb_o = m_cyc_o;		
assign s_ack_o = cs_regs ? 1'b1 : cs_ram ? (s_we_i ? 1 : sprRamRdy) : 0;
assign vol_o = cs_regs & s_adr_i[7:2]>6'd59;
assign irq = sprSprIRQ|sprBkIRQ;

//--------------------------------------------------------------------
// DMA control / bus interfacing
//--------------------------------------------------------------------

wire btout;
wire sbi_rdy1 = m_ack_i|btout;
busTimeoutCtr #(20) br0(
	.rst(rst_i),
	.crst(1'b0),
	.clk(clk_i),
	.ce(1'b1),
	.req(m_soc_o),
	.rdy(m_ack_i),
	.timeout(btout)
);

assign m_we_o   = 1'b0;
assign m_sel_o  = 2'b11;
assign m_adr_o  = {1'b0,sprSysAddrH[dmaOwner],sprSysAddrL[dmaOwner],dmaCount[9:0],1'b0};
assign m_dat_o = 32'd0;

// DMA address generator goes based on the requests that have been acknowledged
assign dmaDone = dmaCountNext[10] & sbi_rdy1;

always @(dmaCount)
dmaCountNext = dmaCount + 1;

always @(posedge clk_i)
if (rst_i)
	dmaCount = 0;
else begin
	if (dmaStart)
		dmaCount = 0;
	else if (sbi_rdy1 && !dmaDone)
		dmaCount = dmaCountNext;
end

// sprite cache address generator goes based on the responses that are ready
wire updDone = updAdrNext[10] & sbi_rdy1;

always @(updAdr)
	updAdrNext = updAdr + 1;

always @(posedge clk_i)
if (rst_i)
	updAdr = 0;
else begin
	if (dmaStart)
		updAdr = 0;
	else if (sbi_rdy1 && !updDone)
		updAdr = updAdrNext;
end

// Arbitrate access to DMA channel - priority ordered
always @(posedge clk_i)
if (rst_i) begin
	dmaActive <= 1'b0;
	dmaOwner <= 3'd0;
	dmaStart <= 1'b0;
	m_soc_o  <= 1'b0;
end
else begin
	dmaStart <= 1'b0;
	m_soc_o  <= 1'b0;
	if (!dmaActive || updDone) begin
		dmaStart  <= |sprDt;
		dmaActive <= |sprDt;
		m_soc_o   <= |sprDt;
		dmaOwner  <= 0;
		for (n = 7; n >= 0; n = n - 1)
			if (sprDt[n]) dmaOwner <= n;
	end
	if (sbi_rdy1 && !updDone)
		m_soc_o <= 1'b1;
end

assign m_cyc_o = dmaActive & !dmaDone;

// generate a write enable strobe for the sprite image memory
always @(dmaOwner, dmaActive, s_adr_i, cs_ram, s_we_i)
for (n = 0; n < 8; n = n + 1)
	sprWe[n] = (dmaOwner==n && dmaActive)||(cs_ram & s_we_i & s_adr_i[13:11]==n);

always @(cs_ram, s_adr_i)
for (n = 0; n < 8; n = n + 1)
	sprRe[n] = cs_ram & s_adr_i[13:11]==n;

wire [15:0] sr_dout [7:0];
wire [15:0] sr_dout_all = sr_dout[0]|sr_dout[1]|sr_dout[2]|sr_dout[3]|sr_dout[4]|sr_dout[5]|sr_dout[6]|sr_dout[7];

// register/sprite memory output mux
always @*
if (cs_ram)
	s_dat_o <= sr_dout_all;
else if (cs_regs)
	case (s_adr_i[7:1])		// synopsys full_case parallel_case
	7'd120:	s_dat_o <= {8'b0,sprEn};
	7'd121:	s_dat_o <= {sprBkIRQPending|sprSprIRQPending,5'b0,sprBkIRQPending,sprSprIRQPending,6'b0,sprBkIe,sprSprIe};
	7'd122:	s_dat_o <= {8'b0,sprSprCollision};
	7'd123:	s_dat_o <= sprBkCollision;
	7'd124:	s_dat_o <= sprDt;
	default:	s_dat_o <= 0;
	endcase
else
	s_dat_o <= 32'd0;


// vclk -> clk_i
always @(posedge clk_i)
begin
	sprSprIRQ <= sprSprIRQ1;
	sprBkIRQ <= sprBkIRQ1;
	sprSprIRQPending <= sprSprIRQPending1;
	sprBkIRQPending <= sprBkIRQPending1;
	sprSprCollision <= sprSprCollision1;
	sprBkCollision <= sprBkCollision1;
end


// register updates
// on the clk_i domain
always @(posedge clk_i)
if (rst_i) begin
	sprEn <= 8'hFF;
	sprDt <= 0;
    for (n = 0; n < pnSpr; n = n + 1) begin
		sprSysAddrL[n] <= 5'b0100_0 + n;	//xxxx_4000
		sprSysAddrH[n] <= 16'h0000;			//0000_xxxx
	end
	sprSprIe <= 0;
	sprBkIe  <= 0;

    // Set reasonable starting positions on the screen
    // so that the sprites might be visible for testing
    for (n = 0; n < pnSpr; n = n + 1) begin
        hSprPos[n] <= 440 + n * 40;
        vSprPos[n] <= 200;
        sprTc[n] <= 16'h6739;
		sprWidth[n] <= 31;  // 32x32 sprites
		sprHeight[n] <= 31;
		hSprRes[n] <= 0;	// our standard display
		vSprRes[n] <= 1;
		sprImageOffs[n] <= 0;
	end
    hSprPos[0] <= 290;
    vSprPos[0] <= 72;

    bgTc <= 24'h00_00_00;
    bkColor <= 24'hFF_FF_60;
end
else begin
	// clear DMA trigger bit once DMA is recognized
	if (dmaStart)
		sprDt[dmaOwner] <= 1'b0;

	if (cs_regs & s_we_i) begin

		casex (s_adr_i[7:1])

		7'b0xxx000:
			 begin
	    		if (s_sel_i[0]) hSprPos[sprN][ 7:0] <= s_dat_i[ 7:0];
	    		if (s_sel_i[1]) hSprPos[sprN][10:8] <= s_dat_i[10:8];
    		end
		7'b0xxx001:
			 begin
	    		if (s_sel_i[0]) vSprPos[sprN][ 7:0] <= s_dat_i[ 7:0];
	    		if (s_sel_i[1]) vSprPos[sprN][10:8] <= s_dat_i[10:8];
    		end
    	7'b0xxx010:
			begin
	    		if (s_sel_i[0]) begin
					sprWidth[sprN] <= s_dat_i[5:0];
	            	hSprRes[sprN] <= s_dat_i[7:6];
	            end
	    		if (s_sel_i[1]) begin
					sprHeight[sprN] <= s_dat_i[13:8];
	            	vSprRes[sprN] <= s_dat_i[15:14];
	            end
			end
    	7'b0xxx011:
			begin
	            if (s_sel_i[0]) sprImageOffs[sprN][ 7:0] <= s_dat_i[ 7:0];
	            if (s_sel_i[1]) sprImageOffs[sprN][ 9:8] <= s_dat_i[ 9:8];
			end
		7'b0xxx100:
			begin	// DMA address set on clk_i domain
				if (s_sel_i[0]) sprSysAddrH[sprN][34:27] <= s_dat_i[ 7:0];
				if (s_sel_i[1]) sprSysAddrH[sprN][42:35] <= s_dat_i[15:8];
			end
		7'b0xxx101:
			begin	// DMA address set on clk_i domain
				if (s_sel_i[0]) sprSysAddrL[sprN][18:11] <= s_dat_i[ 7:0];
				if (s_sel_i[1]) sprSysAddrL[sprN][26:19] <= s_dat_i[15:0];
			end
		7'b0xxx110:
			begin
			if (s_sel_i[0]) sprTc[sprN][ 7:0] <= s_dat_i[ 7:0];
			if (s_sel_i[1]) sprTc[sprN][15:8] <= s_dat_i[15:8];
			end

		7'd116:
			begin
				if (s_sel_i[0]) bgTc[7:0] <= s_dat_i[7:0];
				if (s_sel_i[1]) bgTc[15:8] <= s_dat_i[15:8];
			end
		7'd117:
			begin
				if (s_sel_i[0]) bgTc[23:16] <= s_dat_i[7:0];
			end
		7'd118:
			begin
				if (s_sel_i[0]) bkColor[23:16] <= s_dat_i[7:0];
			end
		7'd119:
			begin
				if (s_sel_i[0]) bkColor[7:0] <= s_dat_i[7:0];
				if (s_sel_i[1]) bkColor[15:8] <= s_dat_i[15:8];
			end
		7'd120:
			begin
				if (s_sel_i[0]) sprEn <= s_dat_i;
			end
		7'd121:
			begin
				if (s_sel_i[0]) begin
					sprSprIe <= s_dat_i[0];
					sprBkIe <= s_dat_i[1];
				end
			end
		// update DMA trigger
		// s_dat_i[7:0] indicates which triggers to set  (1=set,0=ignore)
		// s_dat_i[7:0] indicates which triggers to clear (1=clear,0=ignore)
		7'd124:	
			begin
				if (s_sel_i[0])
					sprDt <= sprDt | s_dat_i[7:0];
			end
		7'd125:
			begin
				if (s_sel_i[0])
					sprDt <= sprDt & ~s_dat_i[7:0];
			end
		default:	;
		endcase
	
	end
end

//-------------------------------------------------------------
// Sprite Image Cache RAM
// This RAM is dual ported with an SoC side and a display
// controller side.
//-------------------------------------------------------------
wire [10:1] sr_adr = m_cyc_o ? m_adr_o[10:1] : s_adr_i[10:1];
wire [15:0] sr_din = m_cyc_o ? m_dat_i[15:0] : s_dat_i[15:0];
wire sr_ce = m_cyc_o ? sbi_rdy1 : cs_ram;

// Note: the sprite output can't be zeroed out using the rst input!!!
// We need to know what the output is to determine if it's the 
// transparent color.
genvar g;
generate
	for (g = 0; g < 8; g = g + 1)
	begin : genSpriteRam
	    rtfSpriteRam #(.pDw(pColorBits)) sprRam0
	    (
	    	.clka(vclk),
	    	.adra(sprAddr[g]),
	    	.dia(16'hFFFF),
	    	.doa(sprOut[g]),
	    	.cea(1'b1),
	    	.wea(1'b0),
	    	.rsta(1'b0),
	    	
			.clkb(clk_i),
			.adrb(sr_adr),
			.dib(sr_din),
			.dob(sr_dout[g]),
			.ceb(sr_ce),
			.web(sprWe[g]),
			.rstb(!sprRe[g])
		);
	end
endgenerate



//-------------------------------------------------------------
// Timing counters and addressing
// Sprites are like miniature bitmapped displays, they need
// all the same timing controls.
//-------------------------------------------------------------

// Create a timing reference using horizontal and vertical
// soc
wire hSyncEdge, vSyncEdge;
edge_det ed0(.rst(rst_i), .clk(vclk), .ce(1'b1), .i(hSync), .pe(hSyncEdge), .ne(), .ee() );
edge_det ed1(.rst(rst_i), .clk(vclk), .ce(1'b1), .i(vSync), .pe(vSyncEdge), .ne(), .ee() );

always @(posedge vclk)
if (rst_i)        	hctr <= 0;
else if (hSyncEdge) hctr <= 0;
else            	hctr <= hctr + 1;

always @(posedge vclk)
if (rst_i)        	vctr <= 0;
else if (vSyncEdge) vctr <= 0;
else if (hSyncEdge) vctr <= vctr + 1;

// track sprite horizontal reset
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
	hSprReset[n] <= hctr==hSprPos[n];

// track sprite vertical reset
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
	vSprReset[n] <= vctr==vSprPos[n];

always @(hSprDe, vSprDe)
for (n = 0; n < 8; n = n + 1)
	sprDe[n] <= hSprDe[n] & vSprDe[n];


// take care of sprite size scaling
// video clock division
reg [7:0] hSprNextPixel;
reg [7:0] vSprNextPixel;
reg [1:0] hSprPt [7:0];   // horizontal pixel toggle
reg [1:0] vSprPt [7:0];   // vertical pixel toggle
always @(n)
for (n = 0; n < 8; n = n + 1)
    hSprNextPixel[n] = hSprPt[n]==hSprRes[n];
always @(n)
for (n = 0; n < 8; n = n + 1)
    vSprNextPixel[n] = vSprPt[n]==vSprRes[n];

// horizontal pixel toggle counter
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
	if (hSprReset[n])
		hSprPt[n] <= 0;
    else if (hSprNextPixel[n])
        hSprPt[n] <= 0;
    else
        hSprPt[n] <= hSprPt[n] + 1;

// vertical pixel toggle counter
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
    if (hSprReset[n]) begin
    	if (vSprReset[n])
    		vSprPt[n] <= 0;
        else if (vSprNextPixel[n])
            vSprPt[n] <= 0;
        else
            vSprPt[n] <= vSprPt[n] + 1;
    end


// clock sprite image address counters
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1) begin
    // hReset and vReset - top left of sprite,
    // reset address to image offset
	if (hSprReset[n] & vSprReset[n]) begin
		sprAddr[n]  <= sprImageOffs[n];
		sprAddrB[n] <= sprImageOffs[n];
	end
	// hReset:
	//  If the next vertical pixel
	//      set backup address to current address
	//  else
	//      set current address to backup address
	//      in order to rescan the line
	else if (hSprReset[n]) begin
		if (vSprNextPixel[n])
			sprAddrB[n] <= sprAddr[n];
		else
			sprAddr[n]  <= sprAddrB[n];
	end
	// Not hReset or vReset - somewhere on the sprite scan line
	// just advance the address when the next pixel should be
	// fetched
	else if (sprDe[n] & hSprNextPixel[n])
		sprAddr[n] <= sprAddr[n] + 1;
end


// clock sprite column (X) counter
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
	if (hSprReset[n])
		hSprCnt[n] <= 0;
	else if (hSprNextPixel[n])
		hSprCnt[n] <= hSprCnt[n] + 1;


// clock sprite horizontal display enable
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1) begin
	if (hSprReset[n])
		hSprDe[n] <= 1;
	else if (hSprNextPixel[n]) begin
		if (hSprCnt[n] == sprWidth[n])
			hSprDe[n] <= 0;
	end
end


// clock the sprite row (Y) counter
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1)
	if (hSprReset[n]) begin
		if (vSprReset[n])
			vSprCnt[n] <= 0;
		else if (vSprNextPixel[n])
			vSprCnt[n] <= vSprCnt[n] + 1;
	end


// clock sprite vertical display enable
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1) begin
	if (hSprReset[n]) begin
		if (vSprReset[n])
			vSprDe[n] <= 1;
		else if (vSprNextPixel[n]) begin
			if (vSprCnt[n] == sprHeight[n])
				vSprDe[n] <= 0;
		end
	end
end


//-------------------------------------------------------------
// Output stage
//-------------------------------------------------------------

// function used for color blending
// given an alpha and a color component, determine the resulting color
// this blends towards black or white
// alpha is eight bits ranging between 0 and 1.999...
// 1 bit whole, 7 bits fraction
function [7:0] fnBlend;
input [7:0] alpha;
input [7:0] colorbits;

begin
	fnBlend = (({8'b0,colorbits} * alpha) >> 7);
end
endfunction


// pipeline delays for display enable
reg [7:0] sprDe1;
reg [7:0] sproact;
always @(posedge vclk)
for (n = 0; n < 8; n = n + 1) begin
	sprDe1[n] <= sprDe[n];
end


// Detect which sprite outputs are active
// The sprite output is active if the current display pixel
// address is within the sprite's area, the sprite is enabled,
// and it's not a transparent pixel that's being displayed.
always @(n, sprEn, sprDe1)
for (n = 0; n < 8; n = n + 1)
	sproact[n] <= sprEn[n] && sprDe1[n] && sprTc[n]!=sprOut[n];

// register sprite activity flag
// The image combiner uses this flag to know what to do with
// the sprite output.
always @(posedge vclk)
outact = |sproact;

// Display data comes from the active sprite with the
// highest display priority.
// Make sure that alpha blending is turned off when
// no sprite is active.
always @(posedge vclk)
begin
	out = 16'h0080;	// alpha blend max (and off)
	for (n = 7; n >= 0; n = n - 1)
		if (sproact[n]) out = sprOut[n];
end


// combine the text / graphics color output with sprite color output
// blend color output
wire [23:0] blendedColor = {
 	fnBlend(out[7:0],rgbIn[23:16]),		// R
 	fnBlend(out[7:0],rgbIn[15: 8]),		// G
 	fnBlend(out[7:0],rgbIn[ 7: 0])};	// B


// display color priority bit [24] 1=display is over sprite
always @(posedge vclk)
if (blank)
	rgbOut <= 0;
else begin
	if (rgbIn[24] && rgbIn[23:0] != bgTc)	// color is in front of sprite
		rgbOut <= rgbIn[23:0];
	else if (outact) begin
		if (!out[15])				// a sprite is displayed without alpha blending
			rgbOut <= {out[14:10],3'b0,out[9:5],3'b0,out[4:0],3'b0};
		else
			rgbOut <= blendedColor;
	end else
		rgbOut <= rgbIn[23:0];
end


//--------------------------------------------------------------------
// Collision logic
//--------------------------------------------------------------------

// Detect when a sprite-sprite collision has occurred. The criteria
// for this is that a pixel from the sprite is being displayed, while
// there is a pixel from another sprite that could be displayed at the
// same time.
always @(sproact)
case (sproact)
8'b00000000,
8'b00000001,
8'b00000010,
8'b00000100,
8'b00001000,
8'b00010000,
8'b00100000,
8'b01000000,
8'b10000000:	sprCollision = 0;
default:		sprCollision = 1;
endcase

// Detect when a sprite-background collision has occurred
assign bkCollision = (rgbIn[24] && rgbIn[23:0] != bgTc) ? 0 :
		outact && rgbIn[23:0] != bkColor;

// Load the sprite collision register. This register continually
// accumulates collision bits until reset by reading the register.
// Set the collision IRQ on the first collision and don't set it
// again until after the collision register has been read.
always @(posedge vclk)
if (rst_i) begin
	sprSprIRQPending1 <= 0;
	sprSprCollision1 <= 0;
	sprSprIRQ1 <= 0;
end
else if (sprCollision) begin
	// isFirstCollision
	if ((sprSprCollision1==0)||(cs_regs && s_sel_i[0] && s_adr_i[7:1]==7'd122)) begin
		sprSprIRQPending1 <= 1;
		sprSprIRQ1 <= sprSprIe;
		sprSprCollision1 <= sproact;
	end
	else
		sprSprCollision1 <= sprSprCollision1|sproact;
end
else if (cs_regs && s_sel_i[0] && s_adr_i[7:1]==7'd122) begin
	sprSprCollision1 <= 0;
	sprSprIRQPending1 <= 0;
	sprSprIRQ1 <= 0;
end


// Load the sprite background collision register. This register
// continually accumulates collision bits until reset by reading
// the register.
// Set the collision IRQ on the first collision and don't set it
// again until after the collision register has been read.
// Note the background collision indicator is externally supplied,
// it will come from the color processing logic.
always @(posedge vclk)
if (rst_i) begin
	sprBkIRQPending1 <= 0;
	sprBkCollision1 <= 0;
	sprBkIRQ1 <= 0;
end
else if (bkCollision) begin
	// Is the register being cleared at the same time
	// a collision occurss ?
	// isFirstCollision
	if ((sprBkCollision1==0) || (cs_regs && s_sel_i[0] && s_adr_i[7:1]==7'd123)) begin	
		sprBkIRQ1 <= sprBkIe;
		sprBkCollision1 <= sproact;
		sprBkIRQPending1 <= 1;
	end
	else
		sprBkCollision1 <= sprBkCollision1|sproact;
end
else if (cs_regs && s_sel_i[0] && s_adr_i[7:1]==7'd123) begin
	sprBkCollision1 <= 0;
	sprBkIRQPending1 <= 0;
	sprBkIRQ1 <= 0;
end

endmodule
