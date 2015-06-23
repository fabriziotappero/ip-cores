`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
`include "rtf65002_defines.v"

module rtf65002d(rst_md, rst_i, clk_i, nmi_i, irq_i, irq_vect, bte_o, cti_o, bl_o, lock_o, cyc_o, stb_o, ack_i, rty_i, err_i, we_o, sel_o, adr_o, dat_i, dat_o, km_o);
parameter RESET1 = 6'd0;
parameter IFETCH = 6'd1;
parameter DECODE = 6'd2;
parameter STORE1 = 6'd3;
parameter STORE2 = 6'd4;
parameter CALC = 6'd5;
parameter JSR161 = 6'd6;
parameter RTS1 = 6'd7;
parameter IY3 = 6'd8;
parameter BSR1 = 6'd9;
parameter BYTE_IX5 = 6'd10;
parameter BYTE_IY5 = 6'd11;
parameter WAIT_DHIT = 6'd12;
parameter RESET2 = 6'd13;
parameter MULDIV1 = 6'd14;
parameter MULDIV2 = 6'd15;
parameter BYTE_DECODE = 6'd16;
parameter BYTE_CALC = 6'd17;
parameter BUS_ERROR = 6'd18;
parameter LOAD_MAC1 = 6'd19;
parameter LOAD_MAC2 = 6'd20;
parameter LOAD_MAC3 = 6'd21;
parameter MVN3 = 6'd22;
parameter PUSHA1 = 6'd23;
parameter POPA1 = 6'd24;
parameter BYTE_IFETCH = 6'd25;
parameter LOAD_DCACHE = 6'd26;
parameter LOAD_ICACHE = 6'd27;
parameter LOAD_IBUF1 = 6'd28;
parameter LOAD_IBUF2 = 6'd29;
parameter LOAD_IBUF3 = 6'd30;
parameter ICACHE1 = 6'd31;
parameter IBUF1 = 6'd32;
parameter DCACHE1 = 6'd33;
parameter CMPS1 = 6'd34;
parameter HALF_CALC = 6'd35;
parameter MVN816 = 6'd36;

parameter SPIN_CYCLES = 8'd30;

input rst_md;		// reset mode, 1=emulation mode, 0=native mode
input rst_i;
input clk_i;
input nmi_i;
input irq_i;
input [8:0] irq_vect;
output reg [1:0] bte_o;
output reg [2:0] cti_o;
output reg [5:0] bl_o;
output reg lock_o;
output reg cyc_o;
output reg stb_o;
input ack_i;
input rty_i;
input err_i;
output reg we_o;
output reg [3:0] sel_o;
output reg [33:0] adr_o;
input [31:0] dat_i;
output reg [31:0] dat_o;

output km_o;

reg [5:0] state;
reg [5:0] retstate;
wire [63:0] insn;
reg [63:0] ibuf;
reg [31:0] bufadr;
reg [63:0] exbuf;

integer n;
reg cf,nf,zf,vf,bf,im,df,em;
reg tf;		// trace mode flag
reg ttrig;	// trace trigger
reg em1;
reg gie;	// global interrupt enable (set when sp is loaded)
reg hwi;	// hardware interrupt indicator
reg nmoi;	// native mode on interrupt
wire [31:0] sr = {nf,vf,em,tf,17'b0,m816,m_bit,x_bit,3'b0,bf,df,im,zf,cf};
reg m_bit;	// acc/mem is 16 bit
reg x_bit;	// index regs are 16 bit
reg m816;	// 816 mode
wire m16 = m816 & ~m_bit;
wire xb16 = m816 & ~x_bit;
wire [7:0] sr8 = m816 ? {nf,vf,m_bit,x_bit,df,im,zf,cf} : {nf,vf,1'b0,bf,df,im,zf,cf};
reg nmi1,nmi_edge;
reg wai;
reg spi;		// spinlock interrupt
reg [7:0] spi_cnt;
reg wrrf;		// write register file
reg [31:0] acc;
reg [31:0] x;
reg [31:0] y;
reg [15:0] sp;
reg [15:0] dpr;		// direct page register
reg [7:0] dbr;		// data bank register
reg [31:0] spage;	// stack page
wire [7:0] acc8 = acc[7:0];
wire [7:0] x8 = x[7:0];
wire [7:0] y8 = y[7:0];
wire [15:0] acc16 = acc[15:0];
wire [15:0] x16 = x[15:0];
wire [15:0] y16 = y[15:0];
wire [31:0] x_dec = x - 32'd1;
wire [31:0] x_inc = x + 32'd1;
wire [31:0] y_dec = y - 32'd1;
wire [31:0] y_inc = y + 32'd1;
wire [31:0] acc_dec = acc - 32'd1;
wire [31:0] acc_inc = acc + 32'd1;
reg [31:0] isp;		// interrupt stack pointer
reg [31:0] oisp;	// original isp for bus retry
wire [63:0] prod;
reg [15:0] tmp16;
wire [31:0] q,r;
reg [31:0] tick;
wire [15:0] sp_dec = sp - 16'd1;
wire [15:0] sp_inc = sp + 16'd1;
wire [15:0] sp_dec2 = sp - 16'd2;
wire [31:0] isp_dec = isp - 32'd1;
wire [31:0] isp_inc = isp + 32'd1;
reg [3:0] suppress_pcinc;
reg [31:0] pc;
reg [31:0] opc;
wire [3:0] pc_inc;
reg [3:0] pc_inc2;
wire [3:0] pc_inc8;
wire [31:0] pcp2 = pc + (32'd2 & suppress_pcinc);	// for branches
wire [31:0] pcp4 = pc + (32'd4 & suppress_pcinc);	// for branches
wire [31:0] pcp8 = pc + 32'd8;						// cache controller needs this
reg [31:0] abs8;	// 8 bit mode absolute address register
reg [31:0] vbr;		// vector table base register
wire bhit=pc==bufadr;
reg [2:0] bcnt;		// burst count for cache controller
reg [31:0] regfile [15:0];
reg [63:0] ir;
reg pg2;
wire [8:0] ir9 = {pg2,ir[7:0]};
wire [3:0] Ra = ir[11:8];
wire [3:0] Rb = ir[15:12];
reg [31:0] rfoa;
reg [31:0] rfob;
always @(Ra or x or y or acc)
case(Ra)
4'h0:	rfoa <= 32'd0;
4'h1:	rfoa <= acc;
4'h2:	rfoa <= x;
4'h3:	rfoa <= y;
default:	rfoa <= regfile[Ra];
endcase
always @(Rb or x or y or acc)
case(Rb)
4'h0:	rfob <= 32'd0;
4'h1:	rfob <= acc;
4'h2:	rfob <= x;
4'h3:	rfob <= y;
default:	rfob <= regfile[Rb];
endcase
reg [3:0] Rt;
reg [33:0] ea;
reg first_ifetch;
reg [5:0] ic_whence;
reg [31:0] lfsr;
wire lfsr_fb; 
xnor(lfsr_fb,lfsr[0],lfsr[1],lfsr[21],lfsr[31]);
reg [31:0] a, b;
wire signed [31:0] as = a;
wire signed [31:0] bs = b;
wire lt = as < bs;
wire eq = a==b;
wire ltu = a < b;

reg [7:0] b8;
reg [15:0] b16;
wire [32:0] alu_out;
reg [32:0] res;
reg [16:0] res16;
reg [8:0] res8;
wire resv8,resv16,resv32;
wire resc8 = res8[8];
wire resc16 = res16[16];
wire resc32 = res[32];
wire resz8 = ~|res8[7:0];
wire resz16 = ~|res16[15:0];
wire resz32 = ~|res[31:0];
wire resn8 = res8[7];
wire resn16 = res16[15];
wire resn32 = res[31];

reg [33:0] vect;
reg [31:0] ia;			// temporary reg to hold indirect address
reg isInsnCacheLoad;
reg isDataCacheLoad;
reg isCacheReset;
wire hit0,hit1;
`ifdef SUPPORT_DCACHE
wire dhit;
`else
wire dhit = 1'b0;
`endif
reg write_allocate;
wire wr;
reg [3:0] wrsel;
reg [31:0] radr;
reg [1:0] radr2LSB;
wire [33:0] radr34 = {radr,radr2LSB};
wire [33:0] radr34p1 = radr34 + 34'd1;
reg [31:0] wadr;
reg [1:0] wadr2LSB;
reg [31:0] wdat;
wire [31:0] rdat;
reg [4:0] load_what;
reg [5:0] store_what;
reg [8:0] intno;			// interrupt number to take
reg [31:0] derr_address;
reg imiss;
reg dmiss;
reg icacheOn,dcacheOn;
`ifdef SUPPORT_DCACHE
wire unCachedData = radr[31:20]==12'hFFD || !dcacheOn;	// I/O area is uncached
`else
wire unCachedData = 1'b1;
`endif
`ifdef SUPPORT_ICACHE
wire unCachedInsn = pc[31:13]==19'h0 || !icacheOn;		// The lowest 8kB is uncached.
`else
wire unCachedInsn = 1'b1;
`endif
`ifdef ICACHE_2WAY
reg [31:0] clfsr;
wire clfsr_fb; 
xnor(clfsr_fb,clfsr[0],clfsr[1],clfsr[21],clfsr[31]);
wire [1:0] whichrd;
wire whichwr=clfsr[0];
`endif
reg [31:0] ilfsr;
wire ilfsr_fb;
xnor(ilfsr_fb,ilfsr[0],ilfsr[1],ilfsr[21],ilfsr[31]);
reg km;			// kernel mode indicator
assign km_o = km;

`ifdef DEBUG
reg [31:0] history_buf [127:0];
reg [6:0] history_ndx;
reg hist_capture;
`endif

reg isBusErr;
reg isBrk,isMove,isSts;
reg isMove816;
reg isRTI,isRTL,isRTS;
reg isOrb,isStb;
reg isRMW;
reg isSub,isSub8;
reg isJsrIndx,isJsrInd;
reg ldMuldiv;
reg isPusha,isPopa;

wire isCmp = ir9==`CPX_ZPX || ir9==`CPX_ABS || ir9==`CPX_IMM32 ||
			 ir9==`CPY_ZPX || ir9==`CPY_ABS || ir9==`CPY_IMM32;
wire isRMW32 =
			 ir9==`ASL_ZPX || ir9==`ROL_ZPX || ir9==`LSR_ZPX || ir9==`ROR_ZPX || ir9==`INC_ZPX || ir9==`DEC_ZPX ||
			 ir9==`ASL_ABS || ir9==`ROL_ABS || ir9==`LSR_ABS || ir9==`ROR_ABS || ir9==`INC_ABS || ir9==`DEC_ABS ||
			 ir9==`ASL_ABSX || ir9==`ROL_ABSX || ir9==`LSR_ABSX || ir9==`ROR_ABSX || ir9==`INC_ABSX || ir9==`DEC_ABSX ||
			 ir9==`TRB_ZP || ir9==`TRB_ZPX || ir9==`TRB_ABS || ir9==`TSB_ZP || ir9==`TSB_ZPX || ir9==`TSB_ABS ||
			 ir9==`BMS_ZPX || ir9==`BMS_ABS || ir9==`BMS_ABSX ||
			 ir9==`BMC_ZPX || ir9==`BMC_ABS || ir9==`BMC_ABSX ||
			 ir9==`BMF_ZPX || ir9==`BMF_ABS || ir9==`BMF_ABSX
			 ;
wire isRMW8 =
			 ir9==`ASL_ZP || ir9==`ROL_ZP || ir9==`LSR_ZP || ir9==`ROR_ZP || ir9==`INC_ZP || ir9==`DEC_ZP ||
			 ir9==`ASL_ZPX || ir9==`ROL_ZPX || ir9==`LSR_ZPX || ir9==`ROR_ZPX || ir9==`INC_ZPX || ir9==`DEC_ZPX ||
			 ir9==`ASL_ABS || ir9==`ROL_ABS || ir9==`LSR_ABS || ir9==`ROR_ABS || ir9==`INC_ABS || ir9==`DEC_ABS ||
			 ir9==`ASL_ABSX || ir9==`ROL_ABSX || ir9==`LSR_ABSX || ir9==`ROR_ABSX || ir9==`INC_ABSX || ir9==`DEC_ABSX ||
			 ir9==`TRB_ZP || ir9==`TRB_ZPX || ir9==`TRB_ABS || ir9==`TSB_ZP || ir9==`TSB_ZPX || ir9==`TSB_ABS;
			 ;

// Registerable decodes
// The following decodes can be registered because they aren't needed until at least the cycle after
// the DECODE stage.

always @(posedge clk)
	if (state==DECODE||state==BYTE_DECODE) begin
		isSub <= ir9==`SUB_ZPX || ir9==`SUB_IX || ir9==`SUB_IY ||
			 ir9==`SUB_ABS || ir9==`SUB_ABSX || ir9==`SUB_IMM8 || ir9==`SUB_IMM16 || ir9==`SUB_IMM32;
		isSub8 <= ir9==`SBC_ZP || ir9==`SBC_ZPX || ir9==`SBC_IX || ir9==`SBC_IY || ir9==`SBC_I ||
			 ir9==`SBC_ABS || ir9==`SBC_ABSX || ir9==`SBC_ABSY || ir9==`SBC_IMM;
		isRMW <= em ? isRMW8 : isRMW32;
		isOrb <= ir9==`ORB_ZPX || ir9==`ORB_IX || ir9==`ORB_IY || ir9==`ORB_ABS || ir9==`ORB_ABSX;
		isStb <= ir9==`STB_ZPX || ir9==`STB_ABS || ir9==`STB_ABSX;
		isRTI <= ir9==`RTI;
		isRTL <= ir9==`RTL;
		isRTS <= ir9==`RTS;
		isBrk <= ir9==`BRK;
		isMove <= ir9==`MVP || ir9==`MVN;
		isSts <= ir9==`STS;
		isJsrIndx <= ir9==`JSR_INDX;
		isJsrInd <= ir9==`JSR_IND;
		ldMuldiv <= ir9==`MUL_IMM8 || ir9==`MUL_IMM16 || ir9==`MUL_IMM32 ||
			ir9==`DIV_IMM8 || ir9==`MOD_IMM8 || ir9==`DIV_IMM16 || ir9==`DIV_IMM32 || ir9==`MOD_IMM16 || ir9==`MOD_IMM32 ||
			(ir9==`RR && (
			ir[23:20]==`MUL_RR || ir[23:20]==`MULS_RR || ir[23:20]==`DIV_RR || ir[23:20]==`DIVS_RR || ir[23:20]==`MOD_RR || ir[23:20]==`MODS_RR)); 
		isPusha <= ir9==`PUSHA;
		isPopa <= ir9==`POPA;
	end
	else
		ldMuldiv <= 1'b0;

`ifdef SUPPORT_EXEC
wire isExec = ir9==`EXEC;
wire isAtni = ir9==`ATNI;
`else
wire isExec = 1'b0;
wire isAtni = 1'b0;
`endif
wire md_done;
wire clk;
reg isIY;
reg isIY24;
reg isI24;

rtf65002_pcinc upci1
(
	.opcode(ir9),
	.suppress_pcinc(suppress_pcinc),
	.inc(pc_inc)
);

rtf65002_pcinc8 upci2
(
	.opcode(ir[7:0]),
	.suppress_pcinc(suppress_pcinc),
	.inc(pc_inc8),
	.m16(m16),
	.xb16(xb16)
);
	
mult_div umd1
(
	.rst(rst_i),
	.clk(clk),
	.ld(ldMuldiv),
	.op(ir9),
	.fn(ir[23:20]),
	.a(a),
	.b(b),
	.p(prod),
	.q(q),
	.r(r),
	.done(md_done)
);

`ifdef SUPPORT_ICACHE
`ifdef ICACHE_2WAY
rtf65002_icachemem2way icm0 (
	.whichrd(whichrd),
	.whichwr(whichwr),
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem2way tgm0 (
	.whichrd(whichrd),
	.whichwr(isCacheReset ? adr_o[13]: whichwr),
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[31:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`else
`ifdef ICACHE_4K
rtf65002_icachemem4k icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem4k tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[33:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`ifdef ICACHE_8K
rtf65002_icachemem8k icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem8k tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[33:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`ifdef ICACHE_16K
rtf65002_icachemem icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[31:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`endif	// ICACHE_2WAY

wire ihit = (hit0 & hit1);//(pc[2:0] > 3'd1 ? hit1 : 1'b1));
`else
wire ihit = 1'b0;
`endif

`ifdef SUPPORT_DCACHE
assign wr = state==STORE2 && dhit && ack_i;

rtf65002_dcachemem dcm0 (
	.wclk(clk),
	.wr(wr | (ack_i & isDataCacheLoad)),
	.sel(sel_o),
	.wadr(adr_o[33:2]),
	.wdat(wr ? dat_o : dat_i),
	.rclk(~clk),
	.radr(radr),
	.rdat(rdat)
);

rtf65002_dtagmem dtm0 (
	.wclk(clk),
	.wr(wr | (ack_i & isDataCacheLoad) | isCacheReset),
	.wadr(adr_o[33:2]),
	.cr(!isCacheReset),
	.rclk(~clk),
	.radr(radr),
	.hit(dhit)
);
`endif

overflow uovr1 (
	.op(isSub),
	.a(a[31]),
	.b(b[31]),
	.s(res[31]),
	.v(resv32)
);

overflow uovr2 (
	.op(isSub8),
	.a(acc8[7]),
	.b(b8[7]),
	.s(res8[7]),
	.v(resv8)
);

wire [15:0] bcaio;
wire [15:0] bcao;
wire [15:0] bcsio;
wire [15:0] bcso;
wire bcaico,bcaco,bcsico,bcsco;
wire bcaico8,bcaco8,bcsico8,bcsco8;

`ifdef SUPPORT_BCD
BCDAdd4 ubcdai1 (.ci(cf),.a(acc16),.b(ir[23:8]),.o(bcaio),.c(bcaico),.c8(bcaico8));
BCDAdd4 ubcda2 (.ci(cf),.a(acc16),.b(b8),.o(bcao),.c(bcaco),.c8(bcaco8));
BCDSub4 ubcdsi1 (.ci(cf),.a(acc16),.b(ir[23:8]),.o(bcsio),.c(bcsico),.c8(bcsico8));
BCDSub4 ubcds2 (.ci(cf),.a(acc16),.b(b8),.o(bcso),.c(bcsco),.c8(bcsco8));
`endif

reg [7:0] dati;
always @(radr2LSB or dat_i)
case(radr2LSB)
2'd0:	dati <= dat_i[7:0];
2'd1:	dati <= dat_i[15:8];
2'd2:	dati <= dat_i[23:16];
2'd3:	dati <= dat_i[31:24];
endcase
`ifdef SUPPORT_DCACHE
reg [7:0] rdat8;
always @(radr2LSB or rdat)
case(radr2LSB)
2'd0:	rdat8 <= rdat[7:0];
2'd1:	rdat8 <= rdat[15:8];
2'd2:	rdat8 <= rdat[23:16];
2'd3:	rdat8 <= rdat[31:24];
endcase
`endif

// Evaluate branches
// 
reg takb;
always @(ir9 or cf or vf or nf or zf)
case(ir9)
`BEQ:	takb <= zf;
`BNE:	takb <= !zf;
`BPL:	takb <= !nf;
`BMI:	takb <= nf;
`BCS:	takb <= cf;
`BCC:	takb <= !cf;
`BVS:	takb <= vf;
`BVC:	takb <= !vf;
`BRA:	takb <= 1'b1;
`BRL:	takb <= 1'b1;
`BHI:	takb <= cf & !zf;
`BLS:	takb <= !cf | zf;
`BGE:	takb <= (nf & vf)|(!nf & !vf);
`BLT:	takb <= (nf & !vf)|(!nf & vf);
`BGT:	takb <= (nf & vf & !zf) + (!nf & !vf & !zf);
`BLE:	takb <= zf | (nf & !vf)|(!nf & vf);
default:	takb <= 1'b0;
endcase

wire [31:0] mvnsrc_address	= {abs8[31:24],ir[23:16],x16};
wire [31:0] mvndst_address	= {abs8[31:24],ir[15: 8],y16};
wire [31:0] iapy8 			= ia + y16;		// Don't add in abs8, already included with ia
wire [31:0] zp_address 		= {abs8[31:16],8'h00,ir[15:8]} + dpr;
wire [31:0] zpx_address 	= {abs8[31:16],{8'h00,ir[15:8]} + x16} + dpr;
wire [31:0] zpy_address	 	= {abs8[31:16],{8'h00,ir[15:8]} + y16} + dpr;
wire [31:0] abs_address 	= {abs8[31:24],dbr,ir[23:8]};
wire [31:0] absx_address 	= {abs8[31:24],dbr,ir[23:8] + x16};	// simulates 64k bank wrap-around
wire [31:0] absy_address 	= {abs8[31:24],dbr,ir[23:8] + y16};
wire [31:0] al_address		= {abs8[31:24],ir[31:8]};
wire [31:0] alx_address		= {abs8[31:24],ir[31:8] + x16};
wire [31:0] zpx32xy_address 	= ir[23:12] + rfoa;
wire [31:0] absx32xy_address 	= ir[47:16] + rfob;
wire [31:0] zpx32_address 		= ir[31:20] + rfob;
wire [31:0] absx32_address 		= ir[55:24] + rfob;

wire [31:0] dsp_address = m816 ? {abs8[31:24],8'h00,sp + ir[15:8]} : {abs8[31:16],8'h01,sp[7:0]+ir[15:8]};

rtf65002_alu ualu1
(
	.clk(clk),
	.state(state),
	.resin(res),
	.pg2(pg2),
	.ir(ir),
	.acc(acc),
	.x(x),
	.y(y),
	.isp(isp),
	.rfoa(rfoa),
	.rfob(rfob),
	.a(a),
	.b(b),
	.b8(b8),
	.Rt(Rt),
	.icacheOn(icacheOn),
	.dcacheOn(dcacheOn),
	.write_allocate(write_allocate),
	.prod(prod),
	.tick(tick),
	.lfsr(lfsr),
	.abs8(abs8),
	.vbr(vbr),
	.nmoi(nmoi),
	.derr_address(derr_address),
	.history_buf(history_buf[history_ndx]),
	.spage(spage),
	.sp(sp),
	.df(df),
	.cf(cf),
	.res(alu_out)
);


//-----------------------------------------------------------------------------
// Clock control
// - reset or NMI reenables the clock
// - this circuit must be under the clk_i domain
//-----------------------------------------------------------------------------
//
reg cpu_clk_en;
reg clk_en;
BUFGCE u20 (.CE(cpu_clk_en), .I(clk_i), .O(clk) );

always @(posedge clk_i)
if (rst_i) begin
	cpu_clk_en <= 1'b1;
	nmi1 <= 1'b0;
end
else begin
	nmi1 <= nmi_i;
	if (nmi_i)
		cpu_clk_en <= 1'b1;
	else
		cpu_clk_en <= clk_en;
end

always @(posedge clk)
if (rst_i) begin
	bte_o <= 2'b00;
	cti_o <= 3'b000;
	bl_o <= 6'd0;
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	we_o <= 1'b0;
	sel_o <= 4'h0;
	adr_o <= 34'd0;
	dat_o <= 32'd0;
	nmi_edge <= 1'b0;
	wai <= 1'b0;
	spi <= 1'b0;
	spi_cnt <= SPIN_CYCLES;
	cf <= 1'b0;
	ir <= 64'hEAEAEAEAEAEAEAEA;
	imiss <= `FALSE;
	dmiss <= `FALSE;
	dcacheOn <= 1'b0;
	icacheOn <= 1'b1;
	write_allocate <= 1'b0;
	nmoi <= 1'b1;
	state <= RESET1;
	m816 <= 1'b0;
	m_bit <= 1'b1;
	x_bit <= 1'b1;
	if (rst_md) begin
		pc <= 32'h0000FFF0;		// set high-order pc to zero
		vect <= `BYTE_RST_VECT;
		em <= 1'b1;
	end
	else begin
		vect <= `RST_VECT;
		em <= 1'b0;
		pc <= 32'hFFFFFFF0;
	end
	suppress_pcinc <= 4'hF;
	exbuf <= 64'd0;
	dbr <= 8'h00;
	dpr <= 16'h0000;
	spage <= 32'h00000100;
	bufadr <= 32'd0;
	abs8 <= 32'd0;
	clk_en <= 1'b1;
	isCacheReset <= `TRUE;
	gie <= 1'b0;
	tick <= 32'd0;
	isIY <= 1'b0;
	isIY24 <= 1'b0;
	isI24 <= `FALSE;
	load_what <= `NOTHING;
`ifdef DEBUG
	hist_capture <= `TRUE;
	history_ndx <= 6'd0;
`endif
	pg2 <= `FALSE;
	tf <= `FALSE;
	km <= `TRUE;
	wrrf <= 1'b0;
end
else begin
wrrf <= 1'b0;
tick <= tick + 32'd1;
ilfsr <= {ilfsr,ilfsr_fb};
if (nmi_i & !nmi1)
	nmi_edge <= 1'b1;
if (nmi_i|nmi1)
	clk_en <= 1'b1;
case(state)
// Loop in this state until all the cache address tage have been flagged as
// invalid.
//
RESET1:
	begin
		adr_o <= adr_o + 32'd4;
		if (adr_o[13:4]==10'h3FF) begin
			state <= RESET2;
			isCacheReset <= `FALSE;
		end
	end
RESET2:
	begin
		radr <= vect[31:2];
		radr2LSB <= vect[1:0];
		load_what <= em ? `PC_70 : `PC_310;
		state <= LOAD_MAC1;
	end

`include "ifetch.v"
`ifdef SUPPORT_EM8
`include "byte_ifetch.v"
`include "byte_decode.v"
`include "byte_calc.v"
`ifdef SUPPORT_816
`include "half_calc.v"
`endif
`endif

`include "load_mac.v"
`include "store.v"

// This state waits for a data hit before continuing. It's used after a store 
// operation when write allocation is taking place.
WAIT_DHIT:
	if (dhit)
		state <= retstate;

DECODE:	decode_tsk();
CALC:	calc_tsk();

MULDIV1:	state <= MULDIV2;
MULDIV2:
	if (md_done) begin
		state <= IFETCH;
		case(ir9)
		`RR:
			case(ir[23:20])
			`MUL_RR:	begin res <= prod[31:0]; end
			`MULS_RR:	begin res <= prod[31:0]; end
`ifdef SUPPORT_DIVMOD
			`DIV_RR:	begin res <= q; end
			`DIVS_RR:	begin res <= q; end
			`MOD_RR:	begin res <= r; end
			`MODS_RR:	begin res <= r; end
`endif
			endcase
		`MUL_IMM8,`MUL_IMM16,`MUL_IMM32:	res <= prod[31:0];
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8,`DIV_IMM16,`DIV_IMM32:	res <= q;
		`MOD_IMM8,`MOD_IMM16,`MOD_IMM32:	res <= r;
`endif
		endcase
	end

`ifdef SUPPORT_BERR
BUS_ERROR:
	begin
		pg2 <= `FALSE;
		ir <= {8{`BRK}};
`ifdef DEBUG
		hist_capture <= `FALSE;
`endif
		radr <= isp_dec;
		wadr <= isp_dec;
		isp <= isp_dec;
		store_what <= `STW_OPC;
		vect <= {vbr[31:9],intno,2'b00};
		hwi <= `TRUE;
		isBusErr <= `TRUE;
		next_state(STORE1);
	end
`endif

`include "rtf65002_string.v"
`include "cache_controller.v"

endcase

if (wrrf || state==IFETCH || state==LOAD_MAC3) begin
	regfile[Rt] <= res[31:0];
	case(Rt)
	4'h1:	acc <= res[31:0];
	4'h2:	x <= res[31:0];
	4'h3:	y <= res[31:0];
	default:	;
	endcase
end

end


`include "decode.v"
`include "calc.v"
`include "load_tsk.v"
`include "wb_task.v"
`include "misc_task.v"

task next_state;
input [5:0] nxt;
begin
	state <= nxt;
end
endtask

function [127:0] fnStateName;
input [5:0] state;
case(state)
RESET1:	fnStateName = "RESET1     ";
RESET2:	fnStateName = "RESET2     ";
IFETCH:	fnStateName = "IFETCH     ";
DECODE:	fnStateName = "DECODE     ";
STORE1:	fnStateName = "STORE1     ";
STORE2:	fnStateName = "STORE2     ";
CALC:	fnStateName = "CALC       ";
RTS1:	fnStateName = "RTS1       ";
IY3:	fnStateName = "IY3        ";
BYTE_IX5:	fnStateName = "BYTE_IX5   ";
BYTE_IY5:	fnStateName = "BYTE_IY5   ";
WAIT_DHIT:	fnStateName = "WAIT_DHIT  ";
MULDIV1:	fnStateName = "MULDIV1    ";
MULDIV2:	fnStateName = "MULDIV2    ";
BYTE_DECODE:	fnStateName = "BYTE_DECODE";
BYTE_CALC:	fnStateName = "BYTE_CALC  ";
BUS_ERROR:	fnStateName = "BUS_ERROR  ";
LOAD_MAC1:	fnStateName = "LOAD_MAC1  ";
LOAD_MAC2:	fnStateName = "LOAD_MAC2  ";
LOAD_MAC3:	fnStateName = "LOAD_MAC3  ";
MVN3:		fnStateName = "MVN3       ";
PUSHA1:		fnStateName = "PUSHA1     ";
POPA1:		fnStateName = "POPA1      ";
BYTE_IFETCH:	fnStateName = "BYTE_IFETCH";
LOAD_DCACHE:	fnStateName = "LOAD_DCACHE";
LOAD_ICACHE:	fnStateName = "LOAD_ICACHE";
LOAD_IBUF1:		fnStateName = "LOAD_IBUF1 ";
LOAD_IBUF2:		fnStateName = "LOAD_IBUF2 ";
LOAD_IBUF3:		fnStateName = "LOAD_IBUF3 ";
ICACHE1:		fnStateName = "ICACHE1    ";
IBUF1:			fnStateName = "IBUF1      ";
DCACHE1:		fnStateName = "DCACHE1    ";
CMPS1:			fnStateName = "CMPS1      ";
HALF_CALC:		fnStateName = "HALF_CALC  ";
default:		fnStateName = "UNKNOWN    ";
endcase
endfunction

endmodule
