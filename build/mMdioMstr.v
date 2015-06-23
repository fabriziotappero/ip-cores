/*
Copyright � 2012 JeffLieu-lieumychuong@gmail.com

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
	
File		:
Description	:	
Remarks		:
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/

module mMdioMstr(
	input i_Clk,
	input i_ARst_L,
	//Wishbone interface
	input i_Cyc,i_Stb,i_WEn,
	output reg o_Ack,
	input [1:0] i2_Addr,
	input [31:0] i32_WrData,
	output reg [31:0] o32_RdData,
	
	//MDIO Interface
	output 	o_Mdc,
	inout 	io_Mdio);
	
	
	reg [15:0] r16_WrData;
	reg [15:0] r16_RdData;
	reg [15:0] r16_Cmd;
	reg [4:0] r5_BitCnt;
	reg [3:0] rv_ClkDiv;
	reg r_Mdc;
	reg r_Mdo;
	reg r_Frame;
	wire w_NewCmd;
	reg r_NewCmd;
	wire w_ReadFrame;
	
	//Bus Interface
	always@(posedge i_Clk or negedge i_ARst_L)
	if(~i_ARst_L) begin 
		r16_Cmd <= 16'h0;
		r16_WrData <= 16'h0;
		r_NewCmd <= 1'b0;
	end else begin 
		if(i_Cyc & i_Stb & i_WEn) 
			case(i2_Addr)
			2'b00:	r16_Cmd <= i32_WrData[15:0];
			2'b01:	r16_WrData <= i32_WrData[15:0];
			endcase
		case(i2_Addr)
			2'b00:	o32_RdData <= {16'h0,r16_Cmd};
			2'b01:	o32_RdData <= {16'h0,r16_WrData};
			2'b10:	o32_RdData <= {16'h0,r16_RdData};
			2'b11:	o32_RdData <= {16'h0,r16_RdData};
		endcase
		
		o_Ack <= (~o_Ack) & i_Cyc & i_Stb;		
		if(r_Frame)//Reset
			r_NewCmd <= 1'b0;
		else if(w_NewCmd)	//Set
			r_NewCmd <= 1'b1;
	end
	
	assign w_NewCmd = i_Cyc & i_Stb & i_WEn & o_Ack & (i2_Addr==2'b00);
	assign w_ReadFrame = (r16_Cmd[13:12]==2'b10)?1'b1:1'b0;
	
	assign o_Mdc = r_Mdc?1'bz:1'b0;	//OpenDrain
	assign io_Mdio = (r_Mdo|(~r_Frame))?1'bz:1'b0;
	always@(posedge i_Clk or negedge i_ARst_L)
	if(~i_ARst_L)
		begin 
			rv_ClkDiv <= 4'b0;
			r_Mdc<=1'b0;
		end
	else begin 
			rv_ClkDiv <= rv_ClkDiv+4'b1;
			if(&rv_ClkDiv) r_Mdc<=~r_Mdc;
		end
	
	
	always@(posedge i_Clk or negedge i_ARst_L)
	if(~i_ARst_L)
		begin 
			r_Frame <= 1'b0;
			r5_BitCnt <= 5'b11111;
			r_Mdo <= 1'b1;
			r16_RdData <= 16'h0;
		end
	else 
		begin 			
			if((&rv_ClkDiv) && ~r_Mdc) 
			begin //At the rising edge of MDC clock
				if(r_NewCmd) 		//If New Command Available Start Frame Half a clock earlier by 
					r_Frame<=1'b1; 
				else 
				if(~(|r5_BitCnt))
					r_Frame<=1'b0;
			end 
			
			if(~r_Frame) r_Mdo <= 1'b1;
			else 
				if(r_Frame && (&rv_ClkDiv) && r_Mdc)  //AT the Falling edge and 
				begin 
				r_Mdo <= r5_BitCnt[4]?r16_Cmd[r5_BitCnt[3:0]]:(w_ReadFrame?1'b1:r16_WrData[r5_BitCnt[3:0]]);
				end
			
			if(~r_Frame)	//Load Bit Count
				r5_BitCnt <= 5'b11111;
			else if(r_Frame && (&rv_ClkDiv) && ~r_Mdc)	//At the rising edge count down
				r5_BitCnt<=r5_BitCnt-5'b1;
			
			if((r_Frame && (&rv_ClkDiv) && ~r_Mdc))
				r16_RdData[r5_BitCnt[3:0]]<=io_Mdio;
		end
	

endmodule
