/*
	Copyright © 2012 JeffLieu-lieumychuong@gmail.com
	
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
module mRateAdapter(
	//MAC Side signal
	input	i_TxClk,	
	input	i_TxEN,
	input	i_TxER,	
	input	[07:00] i8_TxD,
	
	input	i_RxClk,
	output	o_RxEN,
	output	o_RxER,
	output	[07:00] o8_RxD,
	
	input 	[1:0] i2_Speed,
	
	//SGMII PHY side
	input 	i_SamplingClk,
	input	i_GClk,
	output	o_TxEN,
	output	o_TxER,
	output	[07:00]	o8_TxD,

	input	i_RxEN,
	input	i_RxER,
	input	[07:00]	i8_RxD
);

	wire w_TxActive;
	reg r_TxActive;
	reg r_GTxEN;
	reg r_GTxER;
	reg [07:00] r8_GByte;
	reg [07:00] r8_Byte;
	reg [03:00] r4_LowNib;
	reg r_HighNib;	
	reg r_TxEN_D;
	reg r_TxER_D;
	reg r_Active;
	wire w_TxSop;
	wire w_TxEop;
	
	assign w_TxActive = i_TxEN | i_TxER;
	assign w_TxSop = (~r_TxActive & w_TxActive);
	assign w_TxEop = (r_TxActive & ~w_TxActive);
	
	always@(posedge i_TxClk)
	begin
		r_TxActive <= w_TxActive;
		
		r_HighNib <= (w_TxSop)?1'b1:(~r_HighNib);
		
		if(w_TxActive) begin
			if(r_HighNib) r8_Byte <= {i8_TxD[3:0],r4_LowNib};
			if(r_HighNib && (~w_TxSop)) r_TxEN_D <= i_TxEN;
			if(r_HighNib && (~w_TxSop)) r_TxER_D <= i_TxER;
		end else if(r_HighNib)
			 begin
			 r_TxEN_D <= 1'b0;
			 r_TxER_D <= 1'b0; 
			 end		
		if((~r_HighNib)|| (w_TxSop))
			r4_LowNib <= i8_TxD[3:0];
			
	end
	
	always@(posedge i_GClk)
	begin
		if(i_SamplingClk==1'b1) begin
			r8_GByte <= r8_Byte;
			r_GTxEN <= r_TxEN_D;
			r_GTxER <= r_TxER_D;
		end
	end
	
	assign o8_TxD = (i2_Speed==2'b10)?i8_TxD:r8_GByte;
	assign o_TxEN = (i2_Speed==2'b10)?i_TxEN:r_GTxEN;
	assign o_TxER = (i2_Speed==2'b10)?i_TxER:r_GTxER;
	

	//Receive
	//Receive Counter
	wire w_RxActive;
	reg r_RxActive;
	reg [03:00] r4_Cntr;
	wire w_RxSop;
	wire w_RxEop;
	reg [05:00] r6_GByte;
	reg [05:00] r6_MByte;
	
	assign w_RxSop = (~r_RxActive & w_RxActive);
	
	assign w_RxActive = i_RxEN | i_RxER;
	
	always@(posedge i_GClk)
	begin
		r_RxActive <= w_RxActive;		
		if(w_RxSop) r4_Cntr<=4'h0; 
		else if(w_RxActive) r4_Cntr <= ((r4_Cntr==4'h9)?4'h0:(r4_Cntr+4'h1));		
		else r4_Cntr <= 4'h0;
		
		if(r4_Cntr==4'h0) r6_GByte <= {i_RxEN,i_RxER,i8_RxD[3:0]};		
		else if(r4_Cntr==4'h5) r6_GByte <= {i_RxEN,i_RxER,i8_RxD[7:4]};		
	end
	
	always@(posedge i_RxClk)
	begin
		r6_MByte <= r6_GByte;	
	end
	

	assign o8_RxD = (i2_Speed==2'b10)?i8_RxD:{r6_MByte[3:0],r6_MByte[3:0]};
	assign o_RxEN = (i2_Speed==2'b10)?i_RxEN:r6_MByte[5];
	assign o_RxER = (i2_Speed==2'b10)?i_RxER:r6_MByte[4];



endmodule
