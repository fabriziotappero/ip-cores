/*
Copyright Ã‚Â© 2012 JeffLieu-lieumychuong@gmail.com

	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.

File		:	sgmii_demo.v
Description	:	This file implements top-level file to test SGMII core

Remarks		:

Revision	:
	Date	Author	Description

*/
`define CMD_NOP	3'b000
`define CMD_RD	3'b001
`define CMD_WR	3'b010
`define CMD_WT	3'b011
`define CMD_JMP	3'b100
`define CMD_JEQ	3'b101
`define CMD_END	3'b111
`define MDIO_RD 2'b10
`define MDIO_WR 2'b01
`define MDIO_RD_FRAME(RDWR,PHYADDR,REGADDR) {16'h0,2'b01,RDWR,PHYADDR,REGADDR,2'b11}
`define MDIO_WR_FRAME(RDWR,PHYADDR,REGADDR) {16'h0,2'b01,RDWR,PHYADDR,REGADDR,2'b10}
`define MDIO_RD_REG27 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_RD_FRAME(`MDIO_RD,5'b0,5'd27)}
`define MDIO_RD_REG17 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_RD_FRAME(`MDIO_RD,5'b0,5'd17)}
`define MDIO_RD_REG00 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_WR_FRAME(`MDIO_RD,5'b0,5'd0)}
`define MDIO_RD_REG01 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_RD_FRAME(`MDIO_RD,5'b0,5'd01)}
`define MDIO_RD_REG04 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_RD_FRAME(`MDIO_RD,5'b0,5'd04)}
`define MDIO_RD_REG22 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_RD_FRAME(`MDIO_RD,5'b0,5'd22)}
`define MDIO_WR_REG27 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_WR_FRAME(`MDIO_WR,5'b0,5'd27)}
`define MDIO_WR_REG00 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_WR_FRAME(`MDIO_WR,5'b0,5'd0)}
`define MDIO_WR_REG22 {2'b10,8'hFF,`CMD_WR	,8'h00	,`MDIO_WR_FRAME(`MDIO_WR,5'b0,5'd22)}


module mWishboneMaster88E1111#(parameter pCommands=32,pAddrW=8,pChipSelect=2)
(
	output [pChipSelect-1:0] ov_CSel,
	output o_Cyc,
	output o_Stb,
	output o_WEn,
	output 	[31:0]	o32_WrData,
	input	[31:0]	i32_RdData,
	output [pAddrW-1:0] ov_Addr,
	input 	i_Ack,
	input 	i_ARst_L,
	input 	i_Clk);
	
	localparam pInstrWidth = pAddrW+32+3+8+pChipSelect;
	localparam 	pFETCH 	= 4'b0001,
				pEXECU	= 4'b0010,
				pNEXTI	= 4'b0100,
				pWAIT	= 4'b1000;
	
	
	reg [3:0]	r4_State;
	reg [pInstrWidth-1:0]	rv_InstrReg;	
	reg [pInstrWidth-1:0]	rv_MicroCodes[0:pCommands-1];
	reg [31:0] r32_ReadData;
	
	reg [7:0]	r8_InstrCnt;
	reg [31:0]	r32_WaitTmr;
	wire [2:0]	w3_Opcode;
	wire [7:0]	w8_WaitTime;
	
	/*Instruction Format
			y-bit chipslect, 8-bit WaitTime, 3bit-Opcode, x-bit Address, 32-bit Data
	*/
	assign ov_CSel		= rv_InstrReg[pInstrWidth-1-:pChipSelect];
	assign w8_WaitTime 	= rv_InstrReg[pInstrWidth-1-pChipSelect-:8];
	assign w3_Opcode 	= rv_InstrReg[pInstrWidth-1-pChipSelect-8-:3];
	assign ov_Addr 		= rv_InstrReg[pInstrWidth-1-pChipSelect-8-3-:pAddrW];
	assign o32_WrData 	= rv_InstrReg[31:0];
	
	
	always@(posedge i_Clk or negedge i_ARst_L)
	if(!i_ARst_L) begin 
			r8_InstrCnt <= 8'h0;	
			r4_State <= pFETCH;
			r32_WaitTmr <= 32'h0;
		end
	else begin
		case(r4_State)
		pFETCH	:	begin 
						rv_InstrReg <= rv_MicroCodes[r8_InstrCnt];
						r4_State <= pEXECU;
					end
		pEXECU	:	begin 
						if(w3_Opcode==`CMD_WT)
							begin 
							r4_State<=pWAIT;
							r32_WaitTmr <= o32_WrData[31:0];							
							end
						else if(w3_Opcode==`CMD_RD||w3_Opcode==`CMD_WR) begin 
							if(i_Ack) 
								begin 
								r4_State<=pWAIT;
								r32_WaitTmr <= {24'h0,w8_WaitTime};
								if(w3_Opcode==`CMD_RD)	r32_ReadData <= i32_RdData;
								end
							end 
						else begin
							r4_State<=pWAIT;
							r32_WaitTmr <= {24'h0,w8_WaitTime};
							end
					end
		pNEXTI	:	begin 
						if(w3_Opcode==`CMD_JMP)
							r8_InstrCnt <= ov_Addr;									
						else 
							if(w3_Opcode==`CMD_JEQ) begin 
								if(r32_ReadData==o32_WrData)
									r8_InstrCnt <= ov_Addr;									
								else 
									r8_InstrCnt <= r8_InstrCnt+8'h1;
							end 
							else 
								r8_InstrCnt <= r8_InstrCnt+8'h1;
						r4_State <= pFETCH;
					end
		pWAIT	: 	if(w3_Opcode==`CMD_END)
						r4_State <= pWAIT;
					else 
						if(r32_WaitTmr==0) r4_State <= pNEXTI; else r32_WaitTmr<=r32_WaitTmr-16'h1;
		endcase	
		end
	
	assign o_Cyc = (r4_State==pEXECU)?1'b1:1'b0;
	assign o_Stb = (r4_State==pEXECU)?1'b1:1'b0;
	assign o_WEn = (r4_State==pEXECU&&w3_Opcode==`CMD_WR)?1'b1:1'b0;

	
	
	always@(posedge i_Clk)
	begin
		rv_MicroCodes[0]	<={2'b01,8'h4,`CMD_RD	,8'h28	,32'h0			};
		rv_MicroCodes[1]	<={2'b01,8'h4,`CMD_WR	,8'h20	,32'hFFFF		};//Set link timer to 1.6ms
		rv_MicroCodes[2]	<={2'b01,8'h4,`CMD_WR	,8'h24	,32'h001F		};//
		rv_MicroCodes[3]	<={2'b01,8'h4,`CMD_WR	,8'h7C	,32'h0001		};//Enable SGMII Mode, MAC Side
		rv_MicroCodes[4]	<={2'b01,8'h4,`CMD_WR	,8'h00	,32'h1340		};//Restart			
				
		rv_MicroCodes[5]	<=`MDIO_RD_REG27;
		rv_MicroCodes[6]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};	
		
		rv_MicroCodes[7]	<={2'b10,8'h4,`CMD_RD	,8'h02	,32'h1340		};//Read MDIO Registers		
				
		rv_MicroCodes[8]	<={2'b10,8'h4,`CMD_WR	,8'h01	,{r32_ReadData[31:4],4'h4}};//Write to Register 27 to change mode
		rv_MicroCodes[9]	<=`MDIO_WR_REG27;
		rv_MicroCodes[10]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};

		rv_MicroCodes[11]	<=`MDIO_RD_REG22;
		rv_MicroCodes[12]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};	
		
		rv_MicroCodes[13]	<={2'b10,8'h4,`CMD_RD	,8'h02	,32'h1340		};//Read MDIO Registers		
		
		rv_MicroCodes[14]	<={2'b10,8'h4,`CMD_WR	,8'h01	,{r32_ReadData[31:8],8'h01}	};//Switch Page
		rv_MicroCodes[15]	<=`MDIO_WR_REG22;
		rv_MicroCodes[16]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};	
		
		rv_MicroCodes[17]	<={2'b10,8'h4,`CMD_WR	,8'h01	,32'h0000_9000	};//Soft Reset, Disable Auto Negotiation
		rv_MicroCodes[18]	<=`MDIO_WR_REG00;
		rv_MicroCodes[19]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd125_000_000};		
		
		rv_MicroCodes[20]	<=`MDIO_RD_REG04;
		rv_MicroCodes[21]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};	
		
		rv_MicroCodes[22]	<=`MDIO_RD_REG00;
		rv_MicroCodes[23]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048		};	
		
		rv_MicroCodes[24]	<=`MDIO_RD_REG01;
		rv_MicroCodes[25]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048};	
		
		rv_MicroCodes[26]	<=`MDIO_RD_REG17;
		rv_MicroCodes[27]	<={2'b00,8'hFF,`CMD_WT	,8'h00	,32'd2048};	
			
		rv_MicroCodes[28]	<={2'b00,8'hFF,`CMD_JMP	,8'd20	,32'b0			};		
	end		
endmodule
