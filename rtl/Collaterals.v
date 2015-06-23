`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/
//------------------------------------------------
module FFD_POSEDGE_ASYNC_RESET # ( parameter SIZE=`WIDTH )
	(
	input wire Clock,
	input wire Clear, 
	input wire [SIZE-1:0] D,
	output reg [SIZE-1:0] Q
	); 
 
  always @(posedge Clock or posedge Clear) 
    begin 
	   if (Clear) 
        Q = 0; 
      else 
        Q = D; 
    end 
endmodule 
//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=`WIDTH )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= `WIDTH'b0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=`WIDTH)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q <= Initial;
      else
		begin
		if (Enable)
			Q <= Q + 1;
			
		end			
  end

endmodule

//----------------------------------------------------------------------

module SELECT_1_TO_N # ( parameter SEL_WIDTH=4, parameter OUTPUT_WIDTH=16 )
 (
 input wire [SEL_WIDTH-1:0] Sel,
 input wire  En,
 output wire [OUTPUT_WIDTH-1:0] O
 );

reg[OUTPUT_WIDTH-1:0] shift;

always @ ( * )
begin
	if (~En)
		shift = 1;
	else
		shift = (1 << 	Sel);


end

assign O = ( ~En ) ? 0 : shift ;

//assign O = En & (1 << Sel);

endmodule 

//----------------------------------------------------------------------

module MUXFULLPARALELL_2SEL_GENERIC # ( parameter SIZE=`WIDTH )
 (
 input wire [1:0] Sel,
 input wire [SIZE-1:0]I1, I2, I3,I4,
 output reg [SIZE-1:0] O1
 );

always @( * )

  begin

    case (Sel)

      2'b00: O1 = I1;
      2'b01: O1 = I2;
		2'b10: O1 = I3;
		2'b11: O1 = I4;
		default: O1 = SIZE-1'b0;

    endcase

  end

endmodule 

//--------
module CIRCULAR_SHIFTLEFT_POSEDGE_EX # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset)
		tmp <= Initial;
	else
	begin
		if (Enable)
		begin
			if (tmp[SIZE-1])
			begin
				tmp <= Initial;
			end	
			else
			begin
				tmp <= tmp << 1;
			end	
		end	
	end	
  end
  
  
    assign O  = tmp;
endmodule
//------------------------------------------------
module MUXFULLPARALELL_3SEL_WALKINGONE # ( parameter SIZE=`WIDTH )
 (
 input wire [2:0] Sel,
 input wire [SIZE-1:0]I1, I2, I3,
 output reg [SIZE-1:0] O1
 );

always @( * )

  begin

    case (Sel)

      3'b001: O1 = I1;
      3'b010: O1 = I2;
		3'b100: O1 = I3;
		default: O1 = SIZE-1'b0;

    endcase

  end

endmodule 
//------------------------------------------------
module SHIFTLEFT_POSEDGE # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset)
		tmp <= Initial;
	else
	begin
		if (Enable)
			tmp <= tmp << 1;
	end	
  end
  
  
    assign O  = tmp;
endmodule
//------------------------------------------------
//------------------------------------------------
module CIRCULAR_SHIFTLEFT_POSEDGE # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset || tmp[SIZE-1])
		tmp <= Initial;
	else
	begin
		if (Enable)
			tmp <= tmp << 1;
	end	
  end
  
  
    assign O  = tmp;
endmodule
//-----------------------------------------------------------
/*
	Sorry forgot how this flop is called.
	Any way Truth table is this
	
	Q	S	Q_next R
	0	0	0		 0
	0	1	1		 0
	1	0	1		 0
	1	1	1		 0
	X	X	0		 1
	
	The idea is that it toggles from 0 to 1 when S = 1, but if it 
	gets another S = 1, it keeps the output to 1.
*/
module FFToggleOnce_1Bit
(
	input wire Clock,
	input wire Reset,
	input wire Enable,
	input wire S,
	output reg Q
	
);


reg Q_next;

always @ (negedge Clock)
begin
	Q <= Q_next;
end

always @ ( posedge Clock )
begin
	if (Reset)
		Q_next <= 0;
	else if (Enable)
		Q_next <= (S && !Q) || Q;
	else
		Q_next <= Q;
end
endmodule

//-----------------------------------------------------------
module UpCounter_16E
(
input wire Clock, 
input wire Reset,
input wire [15:0] Initial,
input wire Enable,
output wire [15:0] Q
);
	reg [15:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
         Temp = Initial;
      else
			if (Enable)
				Temp =  Temp + 1'b1;
  end
	assign Q = Temp;

endmodule
//-----------------------------------------------------------
module UpCounter_32
(
input wire Clock, 
input wire Reset,
input wire [31:0] Initial,
input wire Enable,
output wire [31:0] Q
);
	reg [31:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
		begin
         Temp = Initial;
		end	
      else
		begin
			if (Enable)
			begin
				Temp =  Temp + 1'b1;
			end
		end	
  end
	assign Q = Temp;

endmodule
//-----------------------------------------------------------
module UpCounter_3
(
input wire Clock, 
input wire Reset,
input wire [2:0] Initial,
input wire Enable,
output wire [2:0] Q
);
	reg [2:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
         Temp = Initial;
      else
			if (Enable)
				Temp =  Temp + 3'b1;
  end
	assign Q = Temp;

endmodule


module FFD32_POSEDGE
(
	input wire Clock,
	input wire[31:0] D,
	output reg[31:0] Q
);
	
	always @ (posedge Clock)
		Q <= D;
	
endmodule

//------------------------------------------------
module MUXFULLPARALELL_96bits_2SEL
 (
 input wire Sel,
 input wire [95:0]I1, I2,
 output reg [95:0] O1
 );



always @( * )

  begin

    case (Sel)

      1'b0: O1 = I1;
      1'b1: O1 = I2;

    endcase

  end

endmodule 
//------------------------------------------------

module MUXFULLPARALELL_16bits_2SEL_X
 (
 input wire [1:0] Sel,
 input wire [15:0]I1, I2, I3,
 output reg [15:0] O1
 );



always @( * )

  begin

    case (Sel)

      2'b00: O1 = I1;
      2'b01: O1 = I2;
		2'b10: O1 = I3;
		default: O1 = 16'b0;

    endcase

  end

endmodule 
//------------------------------------------------
module MUXFULLPARALELL_16bits_2SEL
 (
 input wire Sel,
 input wire [15:0]I1, I2,
 output reg [15:0] O1
 );



always @( * )

  begin

    case (Sel)

      1'b0: O1 = I1;
      1'b1: O1 = I2;

    endcase

  end

endmodule 

//--------------------------------------------------------------

  module FFT1 
  (
   input wire D,
   input wire Clock, 
   input wire Reset , 
   output reg Q       
 );
 
  always @ ( posedge Clock or posedge Reset )
  begin
  
	if (Reset)
	begin
    Q <= 1'b0;
   end 
	else 
	begin
		if (D) 
			Q <=  ! Q;
	end
	
  end//always
  
 endmodule
//--------------------------------------------------------------
