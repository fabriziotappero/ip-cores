// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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

module rtf65002_alu(clk, state, resin, pg2, ir, acc, x, y, isp, rfoa, rfob, a, b, b8, Rt,
	icacheOn, dcacheOn, write_allocate, prod, tick, lfsr, abs8, vbr, nmoi,
	derr_address, history_buf, spage, sp, df, cf,
	res);
input clk;
input [5:0] state;
input [32:0] resin;
input pg2;
input [63:0] ir;
input [31:0] acc;
input [31:0] x;
input [31:0] y;
input [31:0] isp;
input [31:0] rfoa;
input [31:0] rfob;
input [31:0] a;
input [31:0] b;
input [7:0] b8;
input [3:0] Rt;
input icacheOn;
input dcacheOn;
input write_allocate;
input [63:0] prod;
input [31:0] tick;
input [31:0] lfsr;
input [31:0] abs8;
input [31:0] vbr;
input nmoi;
input [31:0] derr_address;
input [31:0] history_buf;
input [31:0] spage;
input [15:0] sp;
input df;
input cf;
output reg [32:0] res;

`ifdef SUPPORT_SHIFT
wire [31:0] shlo = a << b[4:0];
wire [31:0] shro = a >> b[4:0];
`else
wire [31:0] shlo = 32'd0;
wire [31:0] shro = 32'd0;
`endif

always @*
	case({pg2,ir[7:0]})
	`DEX:	res <= x - 32'd1;
	`INX:	res <= x + 32'd1;
	`DEY,`MVP:	res <= y - 32'd1;
	`INY:	res <= y + 32'd1;
	`STS,`MVN,`CMPS:	res <= y + 32'd1;
	`DEA:	res <= acc - 32'd1;
	`INA:	res <= acc + 32'd1;
	`TSX,`TSA:	res <= isp;
	`TXS,`TXA,`TXY:	res <= x;
	`TAX,`TAY,`TAS:	res <= acc;
	`TYA,`TYX:	res <= y;
	`TRS:		res <= rfoa;
	`TSR:		begin
					case(ir[11:8])
					4'h0:	
						begin
`ifdef SUPPORT_ICACHE
							res[0] <= icacheOn;
`endif
`ifdef SUPPORT_DCACHE
							res[1] <= dcacheOn;
							res[2] <= write_allocate;
`endif
							res[32:3] <= 30'd0;
						end
					4'h2:	res <= prod[31:0];
					4'h3:	res <= prod[63:32];
					4'h4:	res <= tick;
					4'h5:	res <= lfsr;
					4'd7:	res <= abs8;
					4'h8:	res <= {vbr[31:1],nmoi};
					4'h9:	res <= derr_address;
`ifdef DEBUG
					4'hA:	res <= history_buf;
`endif
					4'hE:	res <= {spage[31:16],sp};
					4'hF:	res <= isp;
					default:	res <= 33'd0;
					endcase
				end
	`ASL_ACC:	res <= {acc,1'b0};
	`ROL_ACC:	res <= {acc,cf};
	`LSR_ACC:	res <= {acc[0],1'b0,acc[31:1]};
	`ROR_ACC:	res <= {acc[0],cf,acc[31:1]};

	`RR:
		begin
			case(ir[23:20])
			`ADD_RR:	res <= rfoa + rfob + {31'b0,df&cf};
			`SUB_RR:	res <= rfoa - rfob - {31'b0,df&~cf&|ir[19:16]};
			`AND_RR:	res <= rfoa & rfob;
			`OR_RR:		res <= rfoa | rfob;
			`EOR_RR:	res <= rfoa ^ rfob;
`ifdef SUPPORT_SHIFT
			`ASL_RRR:	res <= shlo;
			`LSR_RRR:	res <= shro;
`endif
			default:	res <= 33'd0;
			endcase
		end
	`LD_RR:		res <= rfoa;
	`ASL_RR:	res <= {rfoa,1'b0};
	`ROL_RR:	res <= {rfoa,cf};
	`LSR_RR:	res <= {rfoa[0],1'b0,rfoa[31:1]};
	`ROR_RR:	res <= {rfoa[0],cf,rfoa[31:1]};
	`DEC_RR:	res <= rfoa - 32'd1;
	`INC_RR:	res <= rfoa + 32'd1;
	
	`ADD_R:		res <= rfoa + rfob + {31'b0,df&cf};
	`SUB_R:		res <= rfoa - rfob - {31'b0,df&~cf&|ir[15:12]};
	`AND_R:		res <= rfoa & rfob;
	`OR_R:		res <= rfoa | rfob;
	`EOR_R:		res <= rfoa ^ rfob;
	
	`ADD_IMM4:	res <= rfoa + {{28{ir[15]}},ir[15:12]} + {31'b0,df&cf};
	`SUB_IMM4:	res <= rfoa - {{28{ir[15]}},ir[15:12]} - {31'b0,df&~cf&|ir[11:8]};
	`OR_IMM4:	res <= rfoa | {{28{ir[15]}},ir[15:12]};
	`AND_IMM4: 	res <= rfoa & {{28{ir[15]}},ir[15:12]};
	`EOR_IMM4:	res <= rfoa ^ {{28{ir[15]}},ir[15:12]};

	`ADD_IMM8:	res <= rfoa + {{24{ir[23]}},ir[23:16]} + {31'b0,df&cf};
	`SUB_IMM8:	res <= rfoa - {{24{ir[23]}},ir[23:16]} - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM8:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM8:	res <= 33'd0;
	`MOD_IMM8:	res <= 33'd0;
`endif
	`OR_IMM8:	res <= rfoa | {{24{ir[23]}},ir[23:16]};
	`AND_IMM8: 	res <= rfoa & {{24{ir[23]}},ir[23:16]};
	`EOR_IMM8:	res <= rfoa ^ {{24{ir[23]}},ir[23:16]};
	`CMP_IMM8:	res <= acc - {{24{ir[15]}},ir[15:8]};


	`ADD_IMM16:	res <= rfoa + {{16{ir[31]}},ir[31:16]} + {31'b0,df&cf};
	`SUB_IMM16:	res <= rfoa - {{16{ir[31]}},ir[31:16]} - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM16:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM16:	res <= 33'd0;
	`MOD_IMM16:	res <= 33'd0;
`endif
	`OR_IMM16:	res <= rfoa | {{16{ir[31]}},ir[31:16]};
	`AND_IMM16:	
		begin
		res <= rfoa & {{16{ir[31]}},ir[31:16]};
		$display("%h & %h", rfoa, {{16{ir[31]}},ir[31:16]});
		end
	`EOR_IMM16:	res <= rfoa ^ {{16{ir[31]}},ir[31:16]};

	`ADD_IMM32:	res <= rfoa + ir[47:16] + {31'b0,df&cf};
	`SUB_IMM32:	res <= rfoa - ir[47:16] - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM16:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM32:	res <= 33'd0;
	`MOD_IMM32:	res <= 33'd0;
`endif
	`OR_IMM32:	res <= rfoa | ir[47:16];
	`AND_IMM32:	res <= rfoa & ir[47:16];
	`EOR_IMM32:	res <= rfoa ^ ir[47:16];

	`LDX_IMM32,`LDY_IMM32,`LDA_IMM32:	res <= ir[39:8];
	`LDX_IMM16,`LDA_IMM16:	res <= {{16{ir[23]}},ir[23:8]};
	`LDX_IMM8,`LDA_IMM8: res <= {{24{ir[15]}},ir[15:8]};

	`SUB_SP8:	res <= isp - {{24{ir[15]}},ir[15:8]};
	`SUB_SP16:	res <= isp - {{16{ir[23]}},ir[23:8]};
	`SUB_SP32:	res <= isp - ir[39:8];

	`CPX_IMM32:	res <= x - ir[39:8];
	`CPY_IMM32:	res <= y - ir[39:8];
	// The following results are available for CALC only after the DECODE/LOAD_MAC
	// stage as the 'a' and 'b' side registers need to be loaded.
	`ADD_ZPX,`ADD_IX,`ADD_IY,`ADD_ABS,`ADD_ABSX,`ADD_RIND,`ADD_DSP:	res <= a + b + {31'b0,df&cf};
	`SUB_ZPX,`SUB_IX,`SUB_IY,`SUB_ABS,`SUB_ABSX,`SUB_RIND,`SUB_DSP:	res <= a - b - {31'b0,df&~cf&|Rt}; // Also CMP
	`AND_ZPX,`AND_IX,`AND_IY,`AND_ABS,`AND_ABSX,`AND_RIND,`AND_DSP:	res <= a & b;	// Also BIT
	`OR_ZPX,`OR_IX,`OR_IY,`OR_ABS,`OR_ABSX,`OR_RIND,`OR_DSP:		res <= a | b;	// Also LD
	`EOR_ZPX,`EOR_IX,`EOR_IY,`EOR_ABS,`EOR_ABSX,`EOR_RIND,`EOR_DSP:	res <= a ^ b;
	`LDX_ZPY,`LDX_ABS,`LDX_ABSY:	res <= b;
	`LDY_ZPX,`LDY_ABS,`LDY_ABSX:	res <= b;
	`CPX_ZPX,`CPX_ABS:	res <= x - b;
	`CPY_ZPX,`CPY_ABS:	res <= y - b;
`ifdef SUPPORT_SHIFT
	`ASL_IMM8:	res <= shlo;
	`LSR_IMM8:	res <= shro;
`endif
	`ASL_ZPX,`ASL_ABS,`ASL_ABSX:	res <= {b,1'b0};
	`ROL_ZPX,`ROL_ABS,`ROL_ABSX:	res <= {b,cf};
	`LSR_ZPX,`LSR_ABS,`LSR_ABSX:	res <= {b[0],1'b0,b[31:1]};
	`ROR_ZPX,`ROR_ABS,`ROR_ABSX:	res <= {b[0],cf,b[31:1]};
	`INC_ZPX,`INC_ABS,`INC_ABSX:	res <= b + 32'd1;
	`DEC_ZPX,`DEC_ABS,`DEC_ABSX:	res <= b - 32'd1;
	`ORB_ZPX,`ORB_ABS,`ORB_ABSX:	res <= a | {24'h0,b8};
	`BMS_ZPX,`BMS_ABS,`BMS_ABSX:	res <= b | (32'b1 << acc[4:0]);
	`BMC_ZPX,`BMC_ABS,`BMC_ABSX:	res <= b & (~(32'b1 << acc[4:0]));
	`BMF_ZPX,`BMF_ABS,`BMF_ABSX:	res <= b ^ (32'b1 << acc[4:0]);
	`BMT_ZPX,`BMT_ABS,`BMT_ABSX:	res <= b & (32'b1 << acc[4:0]);
	`TRB_ZPX,`TRB_ABS:	res <= ~a & b;
	`TSB_ZPX,`TSB_ABS:	res <= a | b;
	`SPL_ABS,`SPL_ABSX:	res <= b;
	default:	res <= 33'd0;
	endcase
endmodule
