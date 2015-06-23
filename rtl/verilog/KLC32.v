// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32.v
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
`define STACK_VECTOR	32'h00000000
`define RESET_VECTOR	32'h00000004
`define NMI_VECTOR		32'h0000007C
`define IRQ_VECTOR		32'h00000064
`define TRAP_VECTOR		32'h00000080
`define TRAPV_VECTOR	32'h0000001C
`define TRACE_VECTOR	32'h00000024
`define BUS_ERR_VECTOR	32'h00000008
`define ILLEGAL_INSN	32'h00000010
`define PRIVILEGE_VIOLATION	32'h00000020

`define MISC	6'd0
`define JMP32		6'd32
`define JSR32		6'd33
`define RTS			6'd34
`define RTI			6'd35
`define TRACE_ON	6'd48
`define TRACE_OFF	6'd49
`define USER_MODE	6'd50
`define SET_IM		6'd51
`define RST			6'd52
`define STOP		6'd53
`define R		6'd1
`define ABS			6'd1
`define SGN			6'd2
`define NEG			6'd3
`define NOT			6'd4
`define EXTB		6'd5
`define EXTH		6'd6
`define UNLK		6'd24
`define MTSPR		6'd32
`define MFSPR		6'd33
`define MOV_CRn2CRn	6'd48
`define MOV_CRn2REG	6'd49
`define MOV_REG2CRn	6'd50
`define EXEC		6'd63
`define RR		6'd2
`define ADD			6'd4
`define SUB			6'd5
`define CMP			6'd6
`define AND			6'd8
`define OR			6'd9
`define EOR			6'd10
`define ANDC		6'd11
`define NAND		6'd12
`define NOR			6'd13
`define ENOR		6'd14
`define ORC			6'd15
`define SHL			6'd16
`define SHR			6'd17
`define ROL			6'd18
`define ROR			6'd19
`define JMP_RR		6'd20
`define JSR_RR		6'd21
`define MAX			6'd22
`define MIN			6'd23
`define MULU		6'd24
`define MULUH		6'd25
`define MULS		6'd26
`define MULSH		6'd27
`define DIVU		6'd28
`define DIVS		6'd29
`define MODU		6'd30
`define MODS		6'd31
`define LWX			6'd48
`define LHX			6'd49
`define LBX			6'd50
`define LHUX		6'd51
`define LBUX		6'd52
`define SWX			6'd56
`define SHX			6'd57
`define SBX			6'd58
`define BCDADD		6'd60
`define BCDSUB		6'd61
`define RRR		6'd3
`define ADDI	6'd4
`define SUBI	6'd5
`define CMPI	6'd6
`define ANDI	6'd8
`define ORI		6'd9
`define EORI	6'd10
`define MULUI	6'd12
`define MULSI	6'd13
`define DIVUI	6'd14
`define DIVSI	6'd15
`define Bcc		6'd16
`define BRA			4'd0
`define BRN			4'd1
`define BHI			4'd2
`define BLS			4'd3
`define BHS			4'd4
`define BLO			4'd5
`define BNE			4'd6
`define BEQ			4'd7
`define BVC			4'd8
`define BVS			4'd9
`define BPL			4'd10
`define BMI			4'd11
`define BGE			4'd12
`define BLT			4'd13
`define BGT			4'd14
`define BLE			4'd15
`define TRAPcc	6'd17
`define TRAP		4'd0
`define TRN			4'd1
`define THI			4'd2
`define TLS			4'd3
`define THS			4'd4
`define TLO			4'd5
`define TNE			4'd6
`define TEQ			4'd7
`define TVC			4'd8
`define TVS			4'd9
`define TPL			4'd10
`define TMI			4'd11
`define TGE			4'd12
`define TLT			4'd13
`define TGT			4'd14
`define TLE			4'd15
`define SETcc	6'd18
`define SET			4'd0
`define STN			4'd1
`define SHI			4'd2
`define SLS			4'd3
`define SHS			4'd4
`define SLO			4'd5
`define SNE			4'd6
`define SEQ			4'd7
`define SVC			4'd8
`define SVS			4'd9
`define SPL			4'd10
`define SMI			4'd11
`define SGE			4'd12
`define SLT			4'd13
`define SGT			4'd14
`define SLE			4'd15
`define CRxx	6'd19
`define ANDI_CCR	5'd8
`define ORI_CCR		5'd9
`define EORI_CCR	5'd10
`define CROR		10'd449
`define CRORC		10'd417
`define CRAND		10'd257
`define CRANDC		10'd129
`define CRXOR		10'd193
`define CRNOR		10'd33
`define CRNAND		10'd225
`define CRXNOR		10'd289
`define JMP		6'd20
`define JSR		6'd21

`define TAS		6'd46
`define LW		6'd48
`define LH		6'd49
`define LB		6'd50
`define LHU		6'd51
`define LBU		6'd52
`define POP		6'd53
`define LINK	6'd54
`define PEA		6'd55
`define SW		6'd56
`define SH		6'd57
`define SB		6'd58
`define PUSH	6'd59
`define NOP		6'd60

module KLC32(rst_i, clk_i, ipl_i, vpa_i, halt_i, inta_o, fc_o, rst_o, cyc_o, stb_o, ack_i, err_i, sel_o, we_o, adr_o, dat_i, dat_o);
parameter IFETCH = 8'd1;
parameter REGFETCHA = 8'd2;
parameter REGFETCHB = 8'd3;
parameter EXECUTE = 8'd4;
parameter MEMORY1 = 8'd5;
parameter MEMORY1_ACK = 8'd6;
parameter WRITEBACK = 8'd7;
parameter JSR1 = 8'd10;
parameter JSR2 = 8'd11;
parameter JSRShort = 8'd12;
parameter RTS = 8'd13;
parameter JMP = 8'd14;
parameter LOAD_SP = 8'd15;
parameter VECTOR = 8'd16;
parameter INTA = 8'd20;
parameter FETCH_VECTOR = 8'd21;
parameter TRAP1 = 8'd22;
parameter TRAP2 = 8'd23;
parameter TRAP3 = 8'd24;
parameter RTI1 = 8'd25;
parameter RTI2 = 8'd26;
parameter RTI3 = 8'd27;
parameter TRAP = 8'd28;
parameter RESET = 8'd29;
parameter JSR32 = 8'd30;
parameter JMP32 = 8'd31;
parameter WRITE_FLAGS = 8'd32;
parameter FETCH_IMM32 = 8'd33;
parameter REGFETCHC = 8'd34;
parameter PUSH1 = 8'd35;
parameter PUSH2 = 8'd36;
parameter PUSH3 = 8'd37;
parameter POP1 = 8'd38;
parameter POP2 = 8'd39;
parameter POP3 = 8'd40;
parameter LINK = 8'd41;
parameter UNLK = 8'd42;
parameter TAS = 8'd43;
parameter TAS2 = 8'd44;
parameter PEA = 8'd45;
parameter MULTDIV1 = 8'd49;
parameter MULTDIV2 = 8'd50;
parameter MULT1 = 8'd51;
parameter MULT2 = 8'd52;
parameter MULT3 = 8'd53;
parameter MULT4 = 8'd54;
parameter MULT5 = 8'd55;
parameter MULT6 = 8'd56;
parameter MULT7 = 8'd57;
parameter DIV1 = 8'd61;
parameter DIV2 = 8'd62;
input rst_i;
input clk_i;
input [2:0] ipl_i;
input vpa_i;
input halt_i;
output inta_o;
reg inta_o;
output [2:0] fc_o;
reg [2:0] fc_o;
output rst_o;
output cyc_o;
reg cyc_o;
output stb_o;
reg stb_o;
input ack_i;
input err_i;
output we_o;
reg we_o;
output [3:0] sel_o;
reg [3:0] sel_o;
output [31:0] adr_o;
reg [31:0] adr_o;
input [31:0] dat_i;
output [31:0] dat_o;
reg [31:0] dat_o;

reg cpu_clk_en;
reg clk_en;
wire clk;

reg [7:0] state;
reg [31:0] ir;
reg tf,sf;
reg [31:0] pc;
reg [31:0] usp,ssp;
reg [31:0] ctr;
wire [5:0] opcode=ir[31:26];
reg Rcbit;
reg [5:0] mopcode;
wire [5:0] func=ir[5:0];
wire [9:0] func1=ir[10:1];
wire [3:0] cond=ir[19:16];
wire [31:0] brdisp = {{16{ir[15]}},ir[15:2],2'b0};
reg [4:0] Rn;
reg [31:0] regfile [31:0];
wire [31:0] rfo1 = regfile[Rn];
wire [31:0] rfo = (Rn==5'd0) ? 32'd0 : (Rn==5'd31) ? (sf ? ssp : usp) : rfo1;
reg vf,nf,cf,zf;
reg xer_ov,xer_ca,xer_so;
reg [2:0] im;
reg [2:0] iplr;
reg [7:0] vecnum;
reg [31:0] vector;
reg [31:0] ea;
reg [15:0] rstsh;
assign rst_o = rstsh[15];
reg prev_nmi;
reg nmi_edge;
reg [31:0] sr1;
reg [31:0] tgt;
reg [31:0] a,b,c,imm,aa,bb;
wire signed [31:0] as = a;
wire signed [31:0] bs = b;
reg [31:0] res;
reg [3:0] cr0,cr1,cr2,cr3,cr4,cr5,cr6,cr7;
wire [31:0] cr = {cr7,cr6,cr5,cr4,cr3,cr2,cr1,cr0};
wire [31:0] sr = {tf,1'b0,sf,2'b00,im,16'd0};
reg [31:0] tick;
reg [31:0] be_addr;

reg [5:0] cnt;
reg [31:0] div_r0;
reg [31:0] div_q0;
reg [31:0] div_q,div_r;
wire [32:0] div_dif = div_r0 - bb;

wire IsSubi = opcode==`SUBI;
wire IsCmpi = opcode==`CMPI;
wire IsSub = opcode==`RR && func==`SUB;
wire IsCmp = opcode==`RR && func==`CMP;
wire IsNeg = opcode==`R && func==`NEG;
wire IsDivi = opcode==`DIVUI || opcode==`DIVSI;
wire IsDivu = opcode==`DIVUI || (opcode==`RR && (func==`DIVU || func==`MODU));
wire IsMult = opcode==`MULUI || opcode==`MULSI || (opcode==`RR && (func==`MULU || func==`MULS || func==`MULUH || func==`MULSH));
wire IsDiv = opcode==`DIVUI || opcode==`DIVSI || (opcode==`RR && (func==`DIVU || func==`DIVS || func==`MODU || func==`MODS));

wire hasConst16 = 
	opcode==`ADDI || opcode==`SUBI || opcode==`CMPI ||
	opcode==`ANDI || opcode==`ORI || opcode==`EORI ||
	opcode==`LW || opcode==`LH || opcode==`LB || opcode==`LHU || opcode==`LBU ||
	opcode==`SW || opcode==`SH || opcode==`SB ||
	opcode==`PEA || opcode==`TAS || opcode==`LINK
	;
wire isStop =
	opcode==`MISC && (func==`STOP)
	;

wire c_ri,c_rr;
wire v_ri,v_rr;
carry u1 (.op(IsSubi|IsCmpi), .a(a[31]), .b(imm[31]), .s(res[31]), .c(c_ri));
carry u2 (.op(IsSub|IsCmp|IsNeg), .a(a[31]), .b(b[31]), .s(res[31]), .c(c_rr));
overflow u3 (.op(IsSubi|IsCmpi), .a(a[31]), .b(imm[31]), .s(res[31]), .v(v_ri));
overflow u4 (.op(IsSub|IsCmp|IsNeg), .a(a[31]), .b(b[31]), .s(res[31]), .v(v_rr));

wire [7:0] bcdaddo,bcdsubo;
wire bcdaddc,bcdsubc;
BCDAdd u5 (.ci(cr0[0]),.a(a[7:0]),.b(b[7:0]),.o(bcdaddo),.c(bcdaddc));
BCDSub u6 (.ci(cr0[0]),.a(a[7:0]),.b(b[7:0]),.o(bcdsubo),.c(bcdsubc));

wire [63:0] shlo = {32'd0,a} << b[4:0];
wire [63:0] shro = {a,32'd0} >> b[4:0];

reg res_sgn;
wire [31:0] mp0 = aa[15:0] * bb[15:0];
wire [31:0] mp1 = aa[15:0] * bb[31:16];
wire [31:0] mp2 = aa[31:16] * bb[15:0];
wire [31:0] mp3 = aa[31:16] * bb[31:16];
reg [63:0] prod;
wire divByZero;

function GetCrBit;
input [4:0] Rn;
begin
	case(Rn[4:2])
	3'd0:	GetCrBit = cr0[Rn[1:0]];
	3'd1:	GetCrBit = cr1[Rn[1:0]];
	3'd2:	GetCrBit = cr2[Rn[1:0]];
	3'd3:	GetCrBit = cr3[Rn[1:0]];
	3'd4:	GetCrBit = cr4[Rn[1:0]];
	3'd5:	GetCrBit = cr5[Rn[1:0]];
	3'd6:	GetCrBit = cr6[Rn[1:0]];
	3'd7:	GetCrBit = cr7[Rn[1:0]];
	endcase
end
endfunction

function [3:0] GetCr;
input [2:0] Rn;
begin
	case(Rn)
	3'd0:	GetCr = cr0;
	3'd1:	GetCr = cr1;
	3'd2:	GetCr = cr2;
	3'd3:	GetCr = cr3;
	3'd4:	GetCr = cr4;
	3'd5:	GetCr = cr5;
	3'd6:	GetCr = cr6;
	3'd7:	GetCr = cr7;
	endcase
end
endfunction

wire [3:0] crc = GetCr(Rn[4:2]);
wire cr_zf = crc[2];
wire cr_nf = crc[3];
wire cr_cf = crc[0];
wire cr_vf = crc[1];

//-----------------------------------------------------------------------------
// Clock control
// - reset or NMI reenables the clock
// - this circuit must be under the clk_i domain
//-----------------------------------------------------------------------------
//
BUFGCE u20 (.CE(cpu_clk_en), .I(clk_i), .O(clk) );

always @(posedge clk_i)
if (rst_i) begin
	cpu_clk_en <= 1'b1;
end
else begin
	if (ipl_i==3'd7)
		cpu_clk_en <= 1'b1;
	else
		cpu_clk_en <= clk_en;
end


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

always @(posedge clk)
if (rst_i) begin
	prev_nmi <= 1'b0;
	nmi_edge <= 1'b0;
	state <= RESET;
	im <= 3'b111;
	sf <= 1'b1;
	tf <= 1'b0;
	inta_o <= 1'b0;
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	sel_o <= 4'b0000;
	we_o <= 1'b0;
	clk_en <= 1'b1;
	tick <= 32'd0;
	rstsh <= 16'hFFFF;
end
else begin
tick <= tick + 32'd1;
clk_en <= 1'b1;
rstsh <= {rstsh,1'b0};
prev_nmi <= ipl_i==3'd7;
if (!prev_nmi && (ipl_i==3'd7))
	nmi_edge <= 1'b1;

case(state)
`include "RESET.v"
`include "VECTOR.v"
`include "IFETCH.v"

`include "REGFETCHA.v"
`include "REGFETCHB.v"
`include "REGFETCHC.v"
`include "FETCH_IMM32.v"
`include "EXECUTE.v"
`include "MEMORY.v"
`include "PUSH.v"
`include "POP.v"
`include "WRITEBACK.v"
`include "WRITE_FLAGS.v"

`include "JMP.v"
`include "JSR.v"
`include "RTS.v"
`include "INTA.v"
`include "TRAP.v"
`include "RTI.v"

`include "MULTDIV.v"

endcase

`include "bus_error.v"

end

endmodule
