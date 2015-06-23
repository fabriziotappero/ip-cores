// ============================================================================
// rtf68kSys.v
//  - 68k Test System
//
//
//	2010-2011  Robert Finch
//	robfinch<remove>@FPGAfield.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
// ============================================================================

module rtf68kSys
(
	xclk,
//	ifclk,
	gclk1,
	btn,
	swt,
	kclk, kd,
	an, ssg,
	led,
	ram_a, ram_d, ram_oe, ram_we, ram_lb, ram_ub, ram_clk, ram_adv, ram_ce, ram_cre, ram_wait,
	flash_ce, flash_st, flash_rp,
	hSync,vSync,red,green,blue,
	dac_sclk, dac_sync, dac_d,
	rst1626,clk1626,dq1626,
	eppAstb, eppDstb, eppWr, eppRst, eppDB, eppWait,
	rxd, txd
);
input xclk;
//input ifclk;
input gclk1;
input [3:0] btn;
input [7:0] swt;
inout kclk;
tri kclk;
inout kd;
tri kd;
output [3:0] an;
output [7:0] ssg;
output [7:0] led;

output tri [23:1] ram_a;
inout tri [15:0] ram_d;
output tri ram_lb;
output tri ram_ub;
output tri ram_clk;
output tri ram_adv;
output tri ram_cre;
input ram_wait;
output tri ram_oe;
output tri ram_ce;
output tri ram_we;
output tri flash_ce;
input flash_st;
output tri flash_rp;

output tri hSync;
output tri vSync;
output [2:0] red;
output [2:0] green;
output [1:0] blue;

output dac_sclk;
output dac_sync;
output dac_d;

output rst1626;
output clk1626;
inout dq1626;

input eppAstb;
input eppDstb;
input eppWr;
input eppRst;
inout [7:0] eppDB;
output eppWait;

input rxd;
output txd;

reg [31:0] adr;
reg [15:0] dbi;
wire [15:0] dbo;
wire as,uds,lds;
wire rw;
wire ulds = uds&lds;
wire sys_cyc = !as;
wire sys_stb = !ulds;
wire sys_we = !rw;
wire [1:0] sys_sel = ~{uds,lds};
wire [31:0] cpu_adr;
reg [15:0] valreg;
wire clk50;
wire video_clk;
wire vclk5x;
wire [2:0] vcti;
wire vcyc_o;
wire vstb_o;
wire vack_i;
wire [43:0] vadr_o;
wire [15:0] vdat_i;
wire [23:0] rgbo;

//assign red = rgbo[7:5];
//assign green = rgbo[4:2];
//assign blue = rgbo[1:0];

wire rom_dtack;
wire vec_dtack;
wire dtack;

wire pulse1000Hz;
wire blank,eol,eof;

wire [7:0] busEppOut;
reg [7:0] busEppIn;
wire ctlEppDwrOut;
wire ctlEppRdCycleOut;
wire [7:0] regEppAdrOut;
wire HandShakeReqIn,HandShakeReqIn2;
wire ctlEppStartOut;
wire ctlEppDoneIn,ctlEppDoneIn2;

wire [7:0] busMemDB,busMemDB2;
wire csMemctrl;

wire [15:0] mcDB;
wire [23:1] mcAD;
wire mcRamCS;
wire mcFlashCS;
wire mcMemWr;
wire mcMemOe;
wire mcMemUb;
wire mcMemLb;
wire mcMemCRE;
wire mcRamAdv;
wire mcRamClk;
wire mcRamWait;
wire mcFlashRp;
wire mcFlashStSts;
wire mcMemCtrlEnabled;

wire ffRamCRE;
wire ffRamAdv;
wire ffRamClk;
wire [15:0] ffRamDB;
wire [23:1] ffRamAD;
wire ffRamWe;
wire ffRamWeh;
wire ffRamCe;
wire ffRamOe;
wire ffRamUb;
wire ffRamLb;
wire ffFlashCe;
wire ffFlashRp;
wire ram_dtack;
wire ram_ack;
wire [15:0] ram_dat;

wire mysa;
wire [47:0] startAddress;
wire [7:0] mysaout;
wire saTrigger;

wire kbd_ack;
wire [15:0] kbd_dbo;
wire kbd_irq;
wire kbd_rst;

wire tc_ack;
wire [15:0] tc_dbo;

wire [15:0] dsc_rgbo;
wire dsc_ack;
wire [15:0] dsc_dbo;

wire [7:0] bm_rgbo;
wire [23:0] tx_rgbo;
wire bmc_ack;
wire [15:0] bmc_dbo;

wire sc_ack;
wire [15:0] sc_dat_o;
wire [23:0] sc_rgbo;

wire psg_ack;
wire [15:0] psg_dbo;
wire [11:0] psg_o;
wire psg_cyc;
wire psg_stb;
wire psg_we;
wire [1:0] psg_sel;

wire [7:0] uart_dbo;
wire uart_ack;

wire [15:0] rnd_dbo;
wire rnd_ack;

wire [15:0] tmp_dbo;
wire tmp_ack;

wire gra_ack;
wire gr_cyc_o;
wire gr_stb_o;
wire gr_we_o;
wire gr_ack_i;
wire [1:0] gr_sel_o;
wire [31:0] gr_adr_o;
wire [15:0] gr_dat_i;
wire [15:0] gr_dat_o;

wire sp_cyc_o;
wire sp_stb_o;
wire sp_we_o;
wire sp_ack_i;
wire [1:0] sp_sel_o;
wire [31:0] sp_adr_o;
wire [15:0] sp_dat_i;
wire [15:0] sp_dat_o;

// system clock generator
rtf68kSysClkgen u1
(
	.xreset(btn[0]),	// external reset
	.xclk(xclk),				// external clock source (100MHz)
	.rst(rst),					// system reset
	.clk50(clk50),				// system clock - 60.000 MHz
	.clk25(clk25),				// system clock - 10.000 MHz
	.vclk(video_clk),			// video clock  - 73.529 MHz
	.vclk5(vclk5x),
	.pulse1000Hz(pulse1000Hz)	// 1000 Hz timing pulse
);

assign red = rgbo[23:21];
assign green = rgbo[15:13];
assign blue = rgbo[7:6];

// XGA Timing generator
WXGASyncGen1680x1050_60Hz u2
(
	.rst(rst),
	.clk(video_clk),
	.hSync(hSync),
	.vSync(vSync),
	.blank(blank),
	.border(),
	.eol(eol),
	.eof(eof)
);

FF_PS2KbdToAscii kbd1
(
	.rst_i(rst),
	.clk_i(clk25),
	.cyc_i(sys_cyc),
	.stb_i(sys_stb),
	.ack_o(kbd_ack),
	.adr_i({12'hFFF,cpu_adr}),	// FFF_FFDC_000x
	.dat_o(kbd_dbo),
//	.vol_o(),
	.kclk(kclk),
	.kd(kd),
	.irq(kbd_irq),
	.rst_o(kbd_rst)
);

rtfSimpleUart #(16666667) uuart
(
	// WISHBONE Slave interface
	.rst_i(rst),			// reset
	.clk_i(clk25),			// eg 100.7MHz
	.cyc_i(sys_cyc),		// cycle valid
	.stb_i(sys_stb),		// strobe
	.we_i(sys_we),			// 1 = write
	.adr_i(cpu_adr),	// register address
	.dat_i(dbo[7:0]),		// data input bus
	.dat_o(uart_dbo),		// data output bus
	.ack_o(uart_ack),		// transfer acknowledge
	.vol_o(),				// volatile register selected
	.irq_o(),				// interrupt request
	//----------------
	.cts_ni(1'b0),		// clear to send - active low - (flow control)
	.rts_no(),			// request to send - active low - (flow control)
	.dsr_ni(1'b0),		// data set ready - active low
	.dcd_ni(1'b0),		// data carrier detect - active low
	.dtr_no(),			// data terminal ready - active low
	.rxd_i(rxd),			// serial data in
	.txd_o(txd),			// serial data out
	.data_present_o()
);

//reg [7:0] led;
assign led = eppDB;	// Have to set it to something....

// Epp interface circuit courtesy Diligent
//
EppCtrl ueppctrl (
	.clk(clk25),
	.EppAstb(eppAstb),
	.EppDstb(eppDstb),
	.EppWr(eppWr),
	.EppRst(!rst),
	.EppDB(eppDB),
	.EppWait(eppWait),
	
	.busEppOut(busEppOut),
	.busEppIn(busEppIn),
	.ctlEppDwrOut(ctlEppDwrOut),
	.ctlEppRdCycleOut(ctlEppRdCycleOut),
	.regEppAdrOut(regEppAdrOut),
	.HandShakeReqIn(HandShakeReqIn|HandShakeReqIn2),
	.ctlEppStartOut(ctlEppStartOut),
	.ctlEppDoneIn(ctlEppDoneIn|ctlEppDoneIn2)
);
always @(regEppAdrOut or busMemDB or busMemDB2 or mysaout)
	casex(regEppAdrOut)
	8'b00000xxx:	busEppIn <= busMemDB;
	8'b00001xxx:	busEppIn <= busMemDB2;
	8'b10000xxx:	busEppIn <= mysaout;
	default:		busEppIn <= 8'hFF;
	endcase


CompSel ucs1
(
	.regEppAdrIn(regEppAdrOut),
	.CS0_7(csMemctrl)
);

// Responds to epp register address range 0x80-0x86
//
/*
EppStartAddress usa1
(
	.rst(rst),
	.clk(clk25),
	.wr(ctlEppDwrOut),
	.ad(regEppAdrOut),
	.dbi(busEppOut),
	.dbo(mysaout),
	.myad(mysa),
	.trigger(saTrigger),
	.startAddress(startAddress)
);
*/
wire ackLoadedBit = sys_cyc && sys_stb && (cpu_adr[31:8]==24'hFFDD_00);


// Epp source memory controller - courtesy Diligent
//
NexysOnBoardMemCtrl  umemctrl1
(
	.clk(clk25),
	.HandShakeReqOut(HandShakeReqIn),
	.ctlMsmStartIn(ctlEppStartOut),
	.ctlMsmDoneOut(ctlEppDoneIn),
	.ctlMsmDwrIn(ctlEppDwrOut),
	.ctlEppRdCycleIn(ctlEppRdCycleOut),
	.EppRdDataOut(busMemDB),
	.EppWrDataIn(busEppOut),
	.regEppAdrIn(regEppAdrOut),
	.ComponentSelect(csMemctrl),

	.MemDB(mcDB),
	.MemAdr(mcAD),
	.FlashByte(mcFB),
	.RamCS(mcRamCS),
	.FlashCS(mcFlashCS),
	.MemWR(mcMemWr),
	.MemOE(mcMemOe),
	.RamUB(mcMemUb),
	.RamLB(mcMemLb),
	.RamCRE(mcMemCRE),
	.RamAdv(mcRamAdv),
	.RamClk(mcRamClk),
	.RamWait(mcRamWait),
	.FlashRp(mcFlashRp),
	.FlashStSts(mcFlashStSts),
	.MemCtrlEnabled(mcMemCtrlEnabled)
);


reg bm_owns;
reg [3:0] tcnt;
reg [15:0] cdat_i;

wire cs_vec = !as && ((cpu_adr[31:0] <  32'h00000008) || (cpu_adr[31:4]==28'hFFFFFFF));
wire cs_ram = !as && (cpu_adr[31:0] >= 32'h00000008 && cpu_adr[31:16] < 16'hFFD0);
wire cs_rom = !as && (cpu_adr[31:16]==16'hFFFF);
wire cs_stk = !as && (cpu_adr[31:12]==20'hFFFE_0);
wire csThreadNdx = !ulds && (cpu_adr[31:0]==32'hFFDD_0008);

//input ram_wait;

assign ram_cre 	= mcMemCtrlEnabled ? mcMemCRE : ffRamCRE;
assign ram_adv 	= mcMemCtrlEnabled ? mcRamAdv : ffRamAdv;
assign ram_clk 	= mcMemCtrlEnabled ? mcRamClk : ffRamClk;
assign ram_d 	= mcMemCtrlEnabled ? (!mcMemWr ? mcDB : 16'hZZZZ) : (!ffRamWeh ? ffRamDB : 16'hZZZZ);
assign mcDB 	= !mcMemWr ? 16'hZZZZ : ram_d;
assign ffRamDB 	= !ffRamWe ? 16'hZZZZ : ram_d;
assign ram_a 	= mcMemCtrlEnabled ? mcAD : ffRamAD;
assign ram_we 	= mcMemCtrlEnabled ? mcMemWr : ffRamWe;
assign ram_oe	= mcMemCtrlEnabled ? mcMemOe : ffRamOe;
assign ram_ce 	= mcMemCtrlEnabled ? mcRamCS : ffRamCe;
assign ram_lb 	= mcMemCtrlEnabled ? mcMemLb : ffRamLb;
assign ram_ub 	= mcMemCtrlEnabled ? mcMemUb : ffRamUb;
assign flash_ce = mcMemCtrlEnabled ? mcFlashCS : ffFlashCe;
assign flash_rp = mcMemCtrlEnabled ? mcFlashRp : ffFlashRp;
assign mcFlashStSts = flash_st;

// Responds to epp register address range 0x08-0x0F
//
rtf68kSysRAMCtrl #(16666667) u20
(
	.rst_i(rst),
	.clk_i(clk25),
	.gblen(!mcMemCtrlEnabled),

	// CPU port
	.as(!cs_ram),
	.dtack(ram_dtack),
	.rw(rw),
	.uds(uds),
	.lds(lds),
	.adr({12'h000,adr}),
	.dat_i(dbo),
	.dat_o(ram_dat),

	// Graphics Accelerator
	.gr_cyc_i(gr_cyc_o),
	.gr_stb_i(gr_stb_o),
	.gr_ack_o(gr_ack_i),
	.gr_we_i(gr_we_o),
	.gr_sel_i(gr_sel_o),
	.gr_adr_i(gr_adr_o),
	.gr_dat_i(gr_dat_o),
	.gr_dat_o(gr_dat_i),

	// Sprite
	.sp_cyc_i(sp_cyc_o),
	.sp_stb_i(sp_stb_o),
	.sp_ack_o(sp_ack_i),
	.sp_we_i(sp_we_o),
	.sp_sel_i(sp_sel_o),
	.sp_adr_i(sp_adr_o),
	.sp_dat_i(sp_dat_o),
	.sp_dat_o(sp_dat_i),

	// Epp Port
	.eppRd(ctlEppEdCycleOut),
	.eppWr(ctlEppDwrOut),
	.eppAdr(regEppAdrOut),
	.eppDati(busEppOut),
	.eppDato(busMemDB2),
	.eppHSreq(HandShakeReqIn2),
	.eppStart(ctlEppStartOut),
	.eppDone(ctlEppDoneIn2),

	// Video Port
	.vcti_i(vcti),
	.vcyc_i(vcyc_o),
	.vack_o(vack_i),
	.vadr_i(vadr_o),
	.vdat_o(vdat_i),

	// Audio Port
	.ar_cyc_i(),
	.ar_stb_i(),
	.ar_ack_o(),
	.ar_we_i(),
	.ar_sel_i(),
	.ar_adr_i(),
	.ar_dat_i(),
	.ar_dat_o(),

	// Audio Port
	.ap_cyc_i(psg_cyc),
	.ap_stb_i(psg_stb),
	.ap_ack_o(),
	.ap_we_i(psg_we),
	.ap_sel_i(psg_sel),
	.ap_adr_i(),
	.ap_dat_i(),
	.ap_dat_o(),
	
	// PSRam connections
	.ram_clk(ffRamClk),
	.ram_adv(ffRamAdv),
	.ram_cre(ffRamCRE),
	.ram_ce(ffRamCe),
	.ram_we(ffRamWe),
	.ram_oe(ffRamOe),
	.ram_lb(ffRamLb),
	.ram_ub(ffRamUb),
	.ram_a(ffRamAD),
	.ram_d(ffRamDB),
	
	.ram_weh(ffRamWeh),
	
	// Flash connections
	.flash_ce(ffFlashCe),
	.flash_rp(ffFlashRp),
	.flash_st(flash_st)
);

// Bitmap controller
// 416 x 262 - 8bpp
//
// Responds to address range:	
// 	FFF_FFDA_B0xx
// Uses memory in the range
//  000_0002_0000 to 000_0003_FFFF
// for the bitmap display
//

rtfBitmapController u4
(
	.rst_i(rst),
	.clk_i(clk25),

	.bte_o(),
	.cti_o(vcti),
	.cyc_o(vcyc_o),
	.stb_o(vstb_o),
	.ack_i(vack_i),
	.adr_o(vadr_o),
	.dat_i(vdat_i),

	.vclk(video_clk),
	.eol(eol),
	.eof(eof),
	.blank(blank),
	.rgbo(bm_rgbo),
	.page(1'b0)
);

// Text controller overlays bitmap controller output

rtfTextController tc1
(
	.rst_i(rst),
	.clk_i(clk25),

	.cyc_i(sys_cyc),
	.stb_i(sys_stb),
	.ack_o(tc_ack),
	.we_i(sys_we),
	.sel_i(sys_sel),
	.adr_i({12'hFFF,cpu_adr}),
	.dat_i(dbo),
	.dat_o(tc_dbo),

	.lp(),
	.curpos(),
	.vclk(video_clk),
	.eol(eol),
	.eof(eof),
	.blank(blank),
	.border(),
	.rgbIn({bm_rgbo[7:5],5'd0,bm_rgbo[4:2],5'd0,bm_rgbo[1:0],6'b0}),
	.rgbOut(tx_rgbo)
);

rtfSpriteController sc1
(
    // Bus Slave interface
    //------------------------------
    // Slave signals
	.rst_i(rst),
	.clk_i(clk25),
	.s_cyc_i(sys_cyc),
	.s_stb_i(sys_stb),
	.s_ack_o(sc_ack),
	.s_we_i(sys_we),
	.s_sel_i(sys_sel),
	.s_adr_i({12'hFFF,adr}),
	.s_dat_i(dbo),
	.s_dat_o(sc_dat_o),
	.vol_o(),			// volatile register
	//------------------------------
	// Bus Master Signals
	.m_soc_o(),	// start of cycle
	.m_cyc_o(sp_cyc_o),	// cycle is valid
	.m_stb_o(sp_stb_o),	// strobe output
	.m_ack_i(sp_ack_i),	// input data is ready
	.m_we_o(sp_we_o),		// write (always inactive)
	.m_sel_o(sp_sel_o),	// byte select
	.m_adr_o(sp_adr_o),	// DMA address
	.m_dat_i(sp_dat_i),	// data input
	.m_dat_o(sp_dat_o),	// data output (always zero)
	//--------------------------
	.vclk(video_clk),
	.hSync(eol),
	.vSync(eof),
	.blank(blank),
	.rgbIn(tx_rgbo),
	.rgbOut(sc_rgbo),
	.irq()
);

assign rgbo =
	swt[0] ? {dsc_rgbo[14:10],3'b100,dsc_rgbo[9:5],3'b100,dsc_rgbo[4:0],3'b100} :
	swt[1] ? {tx_rgbo[23:0]} :
	swt[2] ? {sc_rgbo[23:0]} :
		     {bm_rgbo[7:5],5'd0,bm_rgbo[4:2],5'd0,bm_rgbo[1:0],6'b0};

wire [7:0] ds1307dbo;

wire cs_ds1307 = sys_cyc && sys_stb && (cpu_adr==24'hFFD8_03);
wire ds1307ack;

reg [3:0] dp;
// Seven segment LED driver
seven_seg #(16666667) ssd0
(
	.rst(rst),				// reset
	.clk(clk25),		// clock
	.dp(dp),
	.val(valreg),
//	.val(ssval),
	.ssLedAnode(an),
	.ssLedSeg(ssg)
);

// ADSR Sound generator
// 
PSG16 #(17) upsg1
(
	.rst_i(rst),
	.clk_i(clk25),
	.cyc_i(sys_cyc),
	.stb_i(sys_stb),
	.ack_o(psg_ack),
	.we_i(sys_we),
	.sel_i(sys_sel), 
	.adr_i({12'hFFF,cpu_adr}), 
	.dat_i(dbo), 
	.dat_o(psg_dbo),
	.vol_o(),

	.bg(), 
	.m_cyc_o(psg_cyc),
	.m_stb_o(psg_stb),
	.m_ack_i(),
	.m_we_o(psg_we),
	.m_sel_o(psg_sel),
	.m_adr_o(),
	.m_dat_i(),
	
	.o(psg_o)
);

dac121s101 udac1
(
	.rst_i(rst),
	.clk_i(clk25),
	.cyc_i(1'b1),
	.stb_i(1'b1),
	.ack_o(),
	.we_i(1'b1),
	.dat_i(psg_o),
	.sclk(dac_sclk),
	.sync(dac_sync),
	.d(dac_d)
);


rtfRandom u13
(
	.rst_i(rst),
	.clk_i(clk25),
	.cyc_i(sys_cyc),
	.stb_i(sys_stb),
	.ack_o(rnd_ack),
	.we_i(sys_we),
	.adr_i({12'hFFF,cpu_adr}),
	.dat_i(dbo),
	.dat_o(rnd_dbo),
	.vol_o()
);

rtfGraphicsAccelerator u14
(
	.rst_i(rst),
	.clk_i(clk25),
	
	.s_cyc_i(sys_cyc),
	.s_stb_i(sys_stb),
	.s_we_i(sys_we),
	.s_ack_o(gra_ack),
	.s_sel_i(sys_sel),
	.s_adr_i(cpu_adr),
	.s_dat_i(dbo),
	.s_dat_o(),
	
	.m_cyc_o(gr_cyc_o),
	.m_stb_o(gr_stb_o),
	.m_we_o(gr_we_o),
	.m_ack_i(gr_ack_i),
	.m_sel_o(gr_sel_o),
	.m_adr_o(gr_adr_o),
	.m_dat_i(gr_dat_i),
	.m_dat_o(gr_dat_o)
);

// dtack
// for high whenever address strobe goes inactive
//
reg [4:0] stkdt;
always @(posedge clk25)
	if (rst) begin
		stkdt <= 5'b00000;
	end
	else begin
		if (cs_stk & !ulds)
			stkdt <= {stkdt,1'b1};
		else
			stkdt <= 5'd0;
	end
wire stk_dtack = !stkdt[3] | ulds;

assign rom_dtack = !cs_rom;
assign vec_dtack = !cs_vec;

assign dtack = ulds | (
	  rom_dtack
	& vec_dtack
	& ram_dtack
	& !tc_ack
	& !ackLoadedBit
//	& !dsc_ack
	& !kbd_ack
	& !uart_ack
	& !psg_ack
	& !rnd_ack
//	& !tmp_ack
	& !gra_ack
	& !sc_ack
	& stk_dtack
//	& !ds1307ack
	);

reg pulse1000HzB;
always @(posedge clk25)
if (rst) begin
	pulse1000HzB <= 1'b0;
end
else begin
	if (pulse1000Hz)
		pulse1000HzB <= 1'b1;
	else begin
	if (cpu_adr==32'hFFFF0000)
		pulse1000HzB <= 1'b0;
	end
end

wire [2:0] ipl;

VT148 u11
(
	.en(1'b0),
	.i0(1'b1),
	.i1(1'b1),
	.i2(1'b1),
	.i3(1'b1),
	.i4(1'b1),
	.i5(1'b1),
	.i6(!pulse1000HzB),
	.i7(!kbd_rst),
	.o(ipl),
	.gs(),
	.eo()
);


reg [7:0] ThreadNdx;
always @(posedge clk25)
if (rst)
	ThreadNdx <= 8'h00;
else begin
	if (csThreadNdx && !rw)
		ThreadNdx <= dbi[7:0];
end
always @(cpu_adr)
if (cpu_adr[31:8]==24'h000100)
	adr <= {16'h0001,ThreadNdx,cpu_adr[7:0]};
else
	adr <= cpu_adr;

//always @(cpu_adr) adr <= cpu_adr;

TG68 u10
(
	.clk(clk25),
	.reset(!rst),
	.clkena_in(1'b1),
	.IPL(ipl),
	.dtack(dtack),
	.addr(cpu_adr),
	.data_in(dbi),
	.data_out(dbo),
	.as(as),
	.uds(uds),
	.lds(lds),
	.rw(rw),
	.drive_data()
);

wire [15:0] bootromo;
wire [15:0] sysstko;

bootrom ubootrom
(
	.clk(clk25),
	.adr(adr),
	.romo(bootromo)
);

RAMB16_S18 SYSSTACK0
(
	.CLK(clk25),
	.ADDR(adr[10:1]),
	.DI(dbo),
	.DIP(2'b11),
	.DO(sysstko),
	.EN(cs_stk & !ulds),
	.WE(!rw),
	.SSR(1'b0)
);

always @(adr or kbd_dbo or tc_dbo or cdat_i or
	cs_rom or cs_vec or uart_dbo or rnd_dbo or tc_dbo or psg_dbo or
	bootromo or ram_dat or bmc_dbo or saTrigger or startAddress)
	if (cs_rom) begin
		casex(adr[15:0])
		16'b0001_xxxx_xxxx_xxxx:	dbi <= bootromo;
		16'b0010_xxxx_xxxx_xxxx:	dbi <= bootromo;
		16'b0011_xxxx_xxxx_xxxx:	dbi <= bootromo;
		default:	dbi <= 16'h4e71;
		endcase
	end
	else if (cs_vec) begin
		case(adr[15:0])
		16'h0000:	dbi <= 16'hFFFE;	// Reset SSP
		16'h0002:	dbi <= 16'h07FC;
		16'h0004:	dbi <= 16'hFFFF;	// Reset PC
		16'h0006:	dbi <= 16'h1100;
		// vectors
		16'hFFF0:	dbi <= 16'd31;
		16'hFFF2:	dbi <= 16'd30;
		16'hFFF4:	dbi <= 16'd29;
		16'hFFF6:	dbi <= 16'd28;
		16'hFFF8:	dbi <= 16'd28;
		16'hFFFA:	dbi <= 16'd29;
		16'hFFFC:	dbi <= 16'd30;
		16'hFFFE:	dbi <= 16'd31;
		default:	dbi <= 16'h3000;
		endcase
	end
	else begin
		casex(adr & 32'hFFFFFFFE)
		32'h00xx_xxxx:	dbi <= ram_dat;
		32'hFFDC_000x:	dbi <= kbd_dbo;
		32'hFFDC_0A0x:	dbi <= {2{uart_dbo}};
		32'hFFDC_0C0x:	dbi <= rnd_dbo;
		32'hFFD0_xxxx:	dbi <= tc_dbo;
		32'hFFD1_xxxx:	dbi <= tc_dbo;
		32'hFFD2_xxxx:	dbi <= tc_dbo;
//		32'hFFD8_xxxx:	dbi <= sc_dat_o;
		32'hFFDA_00xx:	dbi <= tc_dbo;
		32'hFFD4_00xx:	dbi <= psg_dbo;
		32'hFFDD_0000:	dbi <= {16{saTrigger}};
		32'hFFDD_0004:	dbi <= startAddress[31:16];
		32'hFFDD_0006:	dbi <= startAddress[15:0];
		32'hFFDD_0008:	dbi <= {2{ThreadNdx}};
		32'hFFFE_0xxx:	dbi <= sysstko;
		default:	dbi <= 16'h4e71;
		endcase
	end

always @(posedge clk25 or posedge rst)
	if (rst) valreg <= 16'h8765;
	else begin
	if (1'b1) begin
		dp <= {cs_rom,cs_vec};
		valreg <= btn[1] ? adr[31:16] : adr[15:0];
	end
	end

endmodule
