//////////////////////////////////////////////////////////////////
////
////
//// 	APB module to I2C Core
////
////
////
//// This file is part of the APB to I2C project
////
//// http://www.opencores.org/cores/apbi2c/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// apbi2c_spec IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): - Felipe Fernandes Da Costa, fefe2560@gmail.com
////		  Ronal Dario Celaya
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////

`timescale 1ns/1ps //timescale 

module apb(
			//standard ARM
	    		input PCLK,
			input PRESETn,
			input PSELx,
			input PWRITE,
			input PENABLE,
			input [31:0] PADDR,
			input [31:0] PWDATA,

			//internal pin
			input [31:0] READ_DATA_ON_RX,
			input ERROR,
			input TX_EMPTY,
			input RX_EMPTY,
			
			//external pin
			output [31:0] PRDATA,

			//internal pin 
			output reg [13:0] INTERNAL_I2C_REGISTER_CONFIG,
			output reg [13:0] INTERNAL_I2C_REGISTER_TIMEOUT,
			output [31:0] WRITE_DATA_ON_TX,
			output  WR_ENA,
			output  RD_ENA,
			
			//outside port 
			output PREADY,
			output PSLVERR,

			//interruption
			output INT_RX,
			output INT_TX
	   

	  );

//ENABLE WRITE ON TX FIFO
assign WR_ENA = (PWRITE == 1'b1 & PENABLE == 1'b1 & PADDR == 32'd0 & PSELx == 1'b1)?  1'b1:1'b0;

//ENABLE READ ON RX FIFO
assign RD_ENA = (PWRITE == 1'b0 & PENABLE == 1'b1  & PADDR == 32'd4 & PSELx == 1'b1)?  1'b1:1'b0;

//WRITE ON I2C MODULE
assign PREADY = ((WR_ENA == 1'b1 | RD_ENA == 1'b1 | PADDR == 32'd8 | PADDR == 32'd12) &  (PENABLE == 1'b1 & PSELx == 1'b1))? 1'b1:1'b0;

//INPUT TO WRITE ON TX FIFO
assign WRITE_DATA_ON_TX = (PADDR == 32'd0)? PWDATA:PWDATA;

//OUTPUT DATA FROM RX TO PRDATA
assign PRDATA = (PADDR == 32'd4)? READ_DATA_ON_RX:READ_DATA_ON_RX;

//ERROR FROM I2C CORE
assign PSLVERR = ERROR; 

//INTERRUPTION FROM I2C
assign INT_TX = TX_EMPTY;

//INTERRUPTION FROM I2C
assign INT_RX = RX_EMPTY;

//This is sequential logic used only to register configuration
always@(posedge PCLK)
begin

	if(!PRESETn)
	begin
		INTERNAL_I2C_REGISTER_CONFIG <= 14'd0;
		INTERNAL_I2C_REGISTER_TIMEOUT <= 14'd0;
	end
	else
	begin

		// Set configuration to i2c
		if(PADDR == 32'd8 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1)
		begin
			INTERNAL_I2C_REGISTER_CONFIG <= PWDATA[13:0];
		end
		else if(PADDR == 32'd12 && PSELx == 1'b1 && PWRITE == 1'b1 && PREADY == 1'b1)
		begin
			INTERNAL_I2C_REGISTER_TIMEOUT <= PWDATA[13:0];
		end
		else
		begin
			INTERNAL_I2C_REGISTER_CONFIG <= INTERNAL_I2C_REGISTER_CONFIG;
		end
		
	end

end 


endmodule
