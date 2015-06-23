// ============================================================================
// RAMCtrl.v
//  - Interface to PSRAM
//
//
//	2010  Robert Finch
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
//
//	Verilog 1995
//	Webpack 9.2i  xc3s1200-4fg320
//	177 slices / 339 LUTs / 107.262 MHz
//  120 ff's / 
//
// ============================================================================

// 36/256  6/16
// 16x with only 6x
// 276 slices / 770 LUTs / 246 FF's / 119.446 MHz

module rtf68kSysRAMCtrl
(
	rst_i, clk_i, gblen,
	as, dtack, rw, uds, lds, adr, dat_i, dat_o,
	eppWr, eppRd, eppAdr, eppDati, eppDato, eppHSreq, eppStart, eppDone,
	vcti_i, vcyc_i, vack_o, vadr_i, vdat_o,
	gr_cyc_i, gr_stb_i, gr_ack_o, gr_we_i, gr_sel_i, gr_adr_i, gr_dat_i, gr_dat_o,
	sp_cyc_i, sp_stb_i, sp_ack_o, sp_we_i, sp_sel_i, sp_adr_i, sp_dat_i, sp_dat_o,
	ar_cyc_i, ar_stb_i, ar_ack_o, ar_we_i, ar_sel_i, ar_adr_i, ar_dat_i, ar_dat_o,
	ap_cyc_i, ap_stb_i, ap_ack_o, ap_we_i, ap_sel_i, ap_adr_i, ap_dat_i, ap_dat_o,
	ram_clk, ram_adv, ram_cre, ram_ce, ram_we, ram_oe, ram_lb, ram_ub, ram_a, ram_d, ram_weh,
	flash_ce, flash_st, flash_rp
);
parameter pClkFreq = 60000000;
parameter ABIT=24;
// timing parameters must be at least 1
parameter tRC = pClkFreq / 14285714 + 1;	// 70 ns
parameter tWC = pClkFreq / 14285714 + 1;	// 70 ns
parameter tAPA = pClkFreq / 50000000 + 1;	// 20 ns	page mode access time
parameter tPWR = pClkFreq / 6667 + 1;		// 150 micro seconds
parameter pRCRValue = 23'h000090;			// enables page mode (default setting 0010
parameter pBCRValue = 23'h089D1F;
parameter tRCFlash = pClkFreq / 9090909 + 1;	// 110 ns

// states
parameter POWER_UP   = 6'd0;
parameter WRITE_RCR  = 6'd1;
parameter WRITE_RCR_WAIT = 6'd2;
parameter WRITE_BCR      = 6'd3;
parameter WRITE_BCR_WAIT = 6'd4;
parameter IDLE   = 6'd5;
parameter CPU_ACCESS = 6'd6;
parameter CPU_ACCESS1 = 6'd7;
parameter CPU_NACK = 6'd8;
parameter WAIT_NACK = 6'd9;
parameter STORE_WAIT = 6'd12;
parameter FETCH_VIDEO = 6'd13;
parameter FV1 = 6'd14;
parameter FV2 = 6'd15;
parameter FV_NACK = 6'd16;
parameter RANDOMIZE = 6'd17;
parameter RANDOMIZE2 = 6'd18;

parameter EPP_STORE = 6'd21;
parameter EPP_FETCH = 6'd22;
parameter EPP_NACK = 6'd23;

parameter CPU_STORE = 6'd24;
parameter CPU_STORE2 = 6'd25;
parameter CST_NACK = 6'd26;

parameter AP_FETCH = 6'd27;
parameter AP_NACK = 6'd28;
parameter GR_ACCESS = 6'd29;
parameter GR_NACK = 6'd30;
parameter SP_ACCESS = 6'd31;
parameter SP_NACK = 6'd32;

parameter WB_CAB=3'b001;		// constant address burst
parameter WB_BURST=3'b010;		// incrementing burst cycle
parameter WB_EOB=3'b111;		// end-of-burst

// SYSCON
input  rst_i;			// system reset
input  clk_i;			// system clock
input gblen;
// Slave
input  as;			// cycle valid
output dtack;			// transfer acknowledge
input  rw;			// write enable
input  uds;
input  lds;
input  [43:0] adr;	// address
input  [15:0] dat_i;	// data input
output [15:0] dat_o;	// data output
// Epp interface
input eppWr;
input eppRd;
input [7:0] eppAdr;
input [7:0] eppDati;
output [7:0] eppDato;
reg [7:0] eppDato;
output eppHSreq;
output eppDone;
input eppStart;
// WISHBONE Slave
input  [2:0] vcti_i;
input  vcyc_i;
output vack_o;
input  [23:0] vadr_i;
output [15:0] vdat_o;
// WISHBONE Slave
input  gr_cyc_i;			// cycle valid
input  gr_stb_i;			// strobe
output gr_ack_o;			// transfer acknowledge
input  gr_we_i;			// write enable
input  [ 1:0] gr_sel_i;	// byte select
input  [31:0] gr_adr_i;	// address
input  [15:0] gr_dat_i;	// data input
output [15:0] gr_dat_o;	// data output
reg [15:0] gr_dat_o;
// WISHBONE Slave
input  sp_cyc_i;			// cycle valid
input  sp_stb_i;			// strobe
output sp_ack_o;			// transfer acknowledge
input  sp_we_i;			// write enable
input  [ 1:0] sp_sel_i;	// byte select
input  [31:0] sp_adr_i;	// address
input  [15:0] sp_dat_i;	// data input
output [15:0] sp_dat_o;	// data output
reg [15:0] sp_dat_o;
// WISHBONE Slave
input  ar_cyc_i;			// cycle valid
input  ar_stb_i;			// strobe
output ar_ack_o;			// transfer acknowledge
input  ar_we_i;			// write enable
input  [ 1:0] ar_sel_i;	// byte select
input  [43:0] ar_adr_i;	// address
input  [15:0] ar_dat_i;	// data input
output [15:0] ar_dat_o;	// data output
// WISHBONE Slave
input  ap_cyc_i;			// cycle valid
input  ap_stb_i;			// strobe
output ap_ack_o;			// transfer acknowledge
input  ap_we_i;			// write enable
input  [ 1:0] ap_sel_i;	// byte select
input  [43:0] ap_adr_i;	// address
input  [15:0] ap_dat_i;	// data input
output [15:0] ap_dat_o;	// data output
// RAM ports
output ram_clk;
tri ram_clk;
output ram_adv;
tri ram_adv;
output ram_cre;
tri ram_cre;
output ram_ce;
tri ram_ce;
output ram_we;
tri ram_we;
output ram_weh;
tri ram_weh;
output ram_oe;
tri ram_oe;
output ram_lb;
tri ram_lb;
output ram_ub;
tri ram_ub;
output [23:1] ram_a;
tri [23:1] ram_a;
inout  [15:0] ram_d;
tri    [15:0] ram_d;
output flash_ce;
tri flash_ce;
output flash_rp;
tri flash_rp;
input flash_st;

reg iram_cre;
reg iram_ce;
reg iram_we;
reg iram_oe;
reg iram_lb;
reg iram_ub;
reg iram_weh;
reg [23:1] iram_a;
reg [15:0] rdat;

reg iflash_ce;

assign ram_clk = gblen ? 1'b0 : 1'bz;	// always low
assign ram_adv = gblen ? 1'b0 : 1'bz;	// always low - asynch mode

reg [22:0] BCRReg;
reg [22:0] RCRReg;

wire pud;
reg gack;

reg [15:0] vdat_o;
reg [15:0] dat_o;
reg [15:0] ap_dat_o;
reg vack1_o;
reg ap_ack_o;
reg ar_ack_o;
assign vack_o = vack1_o & vcyc_i;

assign ram_d = (gblen && (iram_weh==1'b0)) ? rdat : {16{1'bz}};

wire isCPUAccess = !as & (!uds | !lds);
wire isVideoRead = vcyc_i;
wire isARWrite = ar_cyc_i && ar_stb_i && ar_we_i && (ar_adr_i[43:24]==20'h00);
wire isAPRead = ap_cyc_i && ap_stb_i && (ap_adr_i[43:24]==20'h00);

// Forces ack_o low immediately when cyc_i or stb_i is lost.
reg dtack1;
assign dtack = (uds & lds) | dtack1;

reg gack1;
assign gr_ack_o = gack1 & gr_cyc_i & gr_stb_i;
reg spack;
assign sp_ack_o = spack & sp_cyc_i & sp_stb_i;

reg [31:0] sadr;
reg [15:0] sdat;
reg [1:0] ssel;
reg [2:0] src;
reg [7:0] vhold;

reg [7:0] cnt;
wire cnt_done = cnt==8'd0;
wire flash = adr[31:24]==8'hFE;
assign iflash_rp = rst_i;

reg [ 5:0] state;
reg [7:0] ectl;
reg [23:0] eadr;
assign eppDone = state==EPP_NACK;
assign eppHSreq = eppAdr==8'h0E || eppAdr==8'h0F;
wire eppCycle = (eppAdr==8'h0E || eppAdr==8'h0F) && eppStart;
reg [15:0] edat,edato;
wire eword = ectl[5];
wire eppDudCycle = (!(ectl[0] ^ eadr[0])) && eword;	// read odd, write even

assign ram_cre 	= gblen ? iram_cre : 1'bz;
assign ram_ce 	= gblen ? iram_ce : 1'bz;
assign ram_we 	= gblen ? iram_we : 1'bz;
assign ram_oe 	= gblen ? iram_oe : 1'bz;
assign ram_weh 	= gblen ? iram_weh : 1'bz;
assign ram_ub 	= gblen ? iram_ub : 1'bz;
assign ram_lb 	= gblen ? iram_lb : 1'bz;
assign ram_a 	= gblen ? iram_a : {23{1'bz}};
assign flash_ce = gblen ? iflash_ce : 1'bz;
assign flash_rp = gblen ? iflash_rp : 1'bz;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Epp register reads
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

always @(eppAdr)
	case(eppAdr)
	8'h08:	eppDato <= ectl;
	8'h09:	eppDato <= eadr[ 7: 0];
	8'h0A:	eppDato <= eadr[15: 8];
	8'h0B:	eppDato <= eadr[23:16];
	8'h0C:	eppDato <= edato[7:0];
	8'h0D:	eppDato <= eadr[0] ? ram_d[15:8] : ram_d[7:0];
	8'h0E:	eppDato <= edato[7:0];
	default:	eppDato <= 8'h00;	// prepare for wor
	endcase
	
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Probably not necessary, but who knows ?
// FPGA's typically have an internal power up delay, which is likely
// greater than the RAM's.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PSRAMCtrl_PudTimer u7 (rst_i, clk_i, pud);

always @(posedge clk_i)
	if (rst_i) begin
		BCRReg <= pBCRValue;
		RCRReg <= pRCRValue;
	end

    reg [15:0] radr;

always @(posedge clk_i)
	if (rst_i) begin
		iram_cre <= 1'b0;
		iram_ce  <= 1'b1;
		iram_we  <= 1'b1;
		iram_weh <= 1'b1;
		iram_oe  <= 1'b1;
		iram_lb  <= 1'b1;
		iram_ub  <= 1'b1;
		iram_a   <= 23'h7FFFFF;
		iflash_ce <= 1'b1;
		vack1_o  <= 1'b0;
		ar_ack_o <= 1'b0;
		ap_ack_o <= 1'b0;
		dtack1    <= 1'b1;
		gack1   <= 1'b0;
		dat_o	<= 16'hFFFF;
		state   <= POWER_UP;
		radr <= 16'h0000;
		rdat <= 32'h0000_0000;
		edato <= 16'h8765;
	end
	else begin

		// Downcount the RAM access timing counter
		if (!cnt_done)
			cnt <= cnt - 8'd1;

		// Clear bus transfer acknowledge
		if (!ar_cyc_i || !ar_stb_i)
			ar_ack_o <= 1'b0;

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Epp control register access
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		//
		if (eppWr) begin
			case(eppAdr)
			8'h08:	begin
					ectl <= eppDati;
					end
			8'h09:	eadr[7:0] <= eppDati;
			8'h0A:	eadr[15:8] <= eppDati;
			8'h0B:	eadr[23:16] <= eppDati;
			8'h0C:	if (eadr[0])
						edat[15:8] <= eppDati;
					else
						edat[7:0] <= eppDati;
			8'h0E,8'h0F:
				begin
						if (eadr[0])
							edat[15:8] <= eppDati;
						else
							edat[7:0] <= eppDati;
					end
			endcase
		end

		case(state)

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Power-up
		//
		// Don't do anything for 150 micro-seconds.
		// Then set the RAM's control registers as desired.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		POWER_UP:
			if (!pud)
				state <= WRITE_RCR;

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Wait for a read or write access request.
		// Dispatch
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		IDLE:
			begin
				cnt <= tRC;		// read access time (70ns)
				// Drive the RAM control signals inactive then
				// override them later.
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_ub <= 1'b1;
				iram_lb <= 1'b1;
				iflash_ce <= 1'b1;

				// We can only get out of the IDLE state if the global
				// enable signal is active.
				//
				if (!gblen)
					;
				// Wait for flash to be ready.
				else if (!flash_st)
					;

				// Page align video address
				else if (isVideoRead) begin
					state <= FETCH_VIDEO;
					iram_ce <= 1'b0;
					iram_oe <= 1'b0;
					iram_ub <= 1'b0;
					iram_lb <= 1'b0;
					iram_a <= vadr_i[23:1];
				end
				/*
				else if (isARWrite) begin
					state <= STORE_WAIT;
					ram_ce <= 1'b0;
					ram_we <= 1'b0;
					ram_oe <= 1'b1;
					ram_ub <= 1'b0;
					ram_lb <= 1'b0;
					ram_a <= ar_adr_i[23:1];
					rdat <= ar_dat_i;
					src <= 3'd0;
				end
				*/
				// Teh data strobes may not be active yet. They become
				// active a cycle after the address strobe.
				else if (!as) begin
					state <= CPU_ACCESS;
					if (flash)
						cnt <= tRCFlash;
					iram_a <= adr[23:1];
					iram_ce   <= !(adr[31:24]==8'h00);
					iflash_ce <= !(adr[31:24]==8'hFE);
					iram_oe <= !rw;
					iram_we <=  rw || (adr[31:24]==8'hFE);
					iram_weh <= rw;
					iram_ub <= uds;
					iram_lb <= lds;
					rdat <= dat_i;
				end
				else if (gr_cyc_i) begin
					state <= GR_ACCESS;
					iram_a <= gr_adr_i[23:1];
					iram_ce <= 1'b0;
					iram_oe <= gr_we_i;
					iram_we <= !gr_we_i;
					iram_weh <= !gr_we_i;
					iram_ub <= gr_sel_i[1];
					iram_lb <= gr_sel_i[0];
					rdat <= gr_dat_i;
				end
				else if (sp_cyc_i) begin
					state <= SP_ACCESS;
					iram_a <= sp_adr_i[23:1];
					iram_ce <= 1'b0;
					iram_oe <= sp_we_i;
					iram_we <= !sp_we_i;
					iram_weh <= !sp_we_i;
					iram_ub <= sp_sel_i[1];
					iram_lb <= sp_sel_i[0];
					rdat <= sp_dat_i;
				end
				else if (isAPRead) begin
					state <= AP_FETCH;
					iram_ce <= 1'b0;
					iram_oe <= 1'b0;
					iram_ub <= 1'b0;
					iram_lb <= 1'b0;
					iram_a <= ap_adr_i;
					src <= 3'd2;
				end
				else if (eppCycle) begin
					if (eppDudCycle) begin
						edato[7:0] <= edato[15:8];
						state <= EPP_NACK;
					end
					else begin
						cnt <= tRC;		// read (or write) access time (70ns)
						iram_oe <= !ectl[0];
						iram_we <=  ectl[0];
						iram_weh <= ectl[0];
						iram_ce <= 1'b0;
						iram_a <= eadr[23:1];
						if (eword) begin
							iram_lb <= 1'b0;
							iram_ub <= 1'b0;
						end
						else begin
							iram_lb <=  eadr[0];
							iram_ub <= !eadr[0];
						end
						rdat <= edat;
						state <= ectl[0] ? EPP_FETCH : EPP_STORE;
					end
				end
			end


		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Memory Fetch/Store completion
		// - If the address is still on the same page, use page mode timing
		// - Terminate the write cycle to the RAM as soon as access time
		//   is met by driving ram_we high (inactive).
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		CPU_ACCESS:
			// Wait for a data strobe to go active (low)
			if (~lds | ~uds) begin
				cnt <= rw ? tRC : tWC;
				state <= CPU_ACCESS1;
				iram_a <= adr[23:1];
				iram_ce <= 1'b0;
				iram_oe <= ~rw;
				iram_we <=  rw || (adr[31:24]==8'hFE);
				iram_weh <= rw;
				iram_ub <= uds;
				iram_lb <= lds;
				rdat   <= dat_i;
			end

		CPU_ACCESS1:
			if (cnt_done) begin
				iram_we <= 1'b1;		// cause a rising edge on we
				dat_o <= ram_d;
				dtack1 <= 1'b0;
				state <= CPU_NACK;
			end

		CPU_NACK:
			// Wait for both data strobes to go inactive (high)
			// The address strobe should also go high at this point,
			// unless it's an RMW cycle.
			if (uds & lds) begin
				dtack1 <= 1'b1;
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_lb <= 1'b1;
				iram_ub <= 1'b1;
				if (as)
					state <= IDLE;
				// Must be a RMW (read-modify-write) cycle
				// Or a longword access
				// go back for another access
				else
					state <= CPU_ACCESS;
			end
		
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		//
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		GR_ACCESS:
			if (cnt_done) begin
				iram_we <= 1'b1;
				gr_dat_o <= ram_d;
				gack1 <= 1'b1;
				state <= GR_NACK;
			end
		GR_NACK:
			if (!gr_cyc_i || !gr_stb_i) begin
				gack1 <= 1'b0;
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_lb <= 1'b1;
				iram_ub <= 1'b1;
				state <= IDLE;
			end
		
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		//
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		SP_ACCESS:
			if (cnt_done) begin
				iram_we <= 1'b1;
				sp_dat_o <= ram_d;
				spack <= 1'b1;
				state <= SP_NACK;
			end
		SP_NACK:
			if (!sp_cyc_i || !sp_stb_i) begin
				spack <= 1'b0;
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_lb <= 1'b1;
				iram_ub <= 1'b1;
				state <= IDLE;
			end
		
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		//
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		AP_FETCH:
			if (cnt_done) begin
				ap_dat_o <= ram_d;
				ap_ack_o <= 1'b1;
				state <= AP_NACK;
			end
		AP_NACK:
			if (!ap_cyc_i || !ap_stb_i) begin
				ap_ack_o <= 1'b0;
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_lb <= 1'b1;
				iram_ub <= 1'b1;
				state <= IDLE;
			end
	

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Fetch video data using page mode access.
		// A whole memory page of 32 bytes is fetched.
		// Typically 5+30 = 35 clock cycles are required assuming a
		// 60 MHz clock.
		// 2+15+1 = 18 clock cycles @ 25 MHz
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		FETCH_VIDEO:
			if (cnt_done) begin
				vack1_o <= 1'b1;
				vdat_o <= ram_d;
				iram_a <= iram_a + 23'd1;
				if (iram_a[4:1]==4'hF)
					state <= FV_NACK;
			end
			else
				vack1_o <= 1'b0;

		FV_NACK:
			if (!vcyc_i) begin
				vack1_o <= 1'b0;
				iram_ce <= 1'b1;
				iram_oe <= 1'b1;
				iram_we <= 1'b1;
				iram_weh <= 1'b1;
				iram_lb <= 1'b1;
				iram_ub <= 1'b1;
				state <= IDLE;
			end
			


		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Epp access states.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		EPP_STORE:
			if (cnt_done) begin
				iram_we <= 1'b1;
				state <= EPP_NACK;
			end
		EPP_FETCH:
			if (cnt_done) begin
				edato <= ram_d;
				state <= EPP_NACK;
			end
		EPP_NACK:
			begin
				if (eppCycle==1'b0) begin
					iram_ce <= 1'b1;
					iram_oe <= 1'b1;
					iram_we <= 1'b1;
					iram_weh <= 1'b1;
					iram_lb <= 1'b1;
					iram_ub <= 1'b1;
					state <= IDLE;
					eadr <= eadr + 23'd1;
				end
			end

		//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Memory randomizer.
		// - On power up memory is usually filled with zeros, as a result the 
		//   display appears blank and one can't tell whether or not the video
		//   (or perhaps anything else) is actually working.
		//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
		RANDOMIZE:
			begin
				state <= RANDOMIZE2;
				iram_ce  <= 1'b0;
				iram_oe  <= 1'b1;
				iram_we  <= 1'b0;
				iram_lb  <= 1'b0;
				iram_ub  <= 1'b0;
				iram_a   <= iram_a + 23'd1;
				rdat    <= rdat * 17'h10DCD + 32'h1;
//				rdat <= 16'hE003;
//				rdat <= {2{ram_a[8:6],ram_a[8:6],ram_a[8:7]}};
				cnt     <= tWC;
			end
		RANDOMIZE2:
			if (cnt_done) begin
				if (iram_a==23'h7F_FFFF)
					state <= IDLE;
				else
					state <= RANDOMIZE;
				iram_ce <= 1'b1;
				iram_we <= 1'b1;
			end


		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Write to the RAM's control registers
		// RCR: enables page mode (default setting 0010
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		WRITE_RCR:
			begin
				state   <= WRITE_RCR_WAIT;
				iram_cre <= 1'b1;
				iram_ce  <= 1'b0;
				iram_we  <= 1'b0;
				iram_a   <= RCRReg;
				cnt 	<= tWC;
			end
		WRITE_RCR_WAIT:
			if (cnt_done) begin
				state   <= WRITE_BCR;
				iram_cre <= 1'b0;
				iram_ce  <= 1'b1;
				iram_we  <= 1'b1;
			end
		WRITE_BCR:
			begin
				state <= WRITE_BCR_WAIT;
				iram_cre <= 1'b1;
				iram_ce  <= 1'b0;
				iram_we  <= 1'b0;
				iram_a   <= BCRReg;
				cnt 	<= tWC;
			end
		WRITE_BCR_WAIT:
			if (cnt_done) begin
				state <= IDLE;	//RANDOMIZE;
				iram_cre <= 1'b0;
				iram_ce  <= 1'b1;
				iram_we  <= 1'b1;
				iram_a   <= 23'd0;
			end
		default:
			state <= IDLE;
		endcase
	end

endmodule

