//////////////////////////////////////////////////////////////////
////
////
//// 	CRCAHB CORE BLOCK
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
//// crcahb IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): -  Julio Cesar 
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

module crc_control_unit
(
 //OUTPUTS
 output reg [1:0] byte_sel,
 output bypass_byte0,
 output buffer_full,
 output read_wait,
 output bypass_size,
 output set_crc_init_sel,
 output clear_crc_init_sel,
 output crc_out_en,
 output byte_en,
 output reset_pending,
 //INPUTS
 input [1:0] size_in,
 input write,
 input reset_chain,
 input clk,
 input rst_n
);

//States definition for state_full
localparam EMPTY   = 2'b00;
localparam WRITE_1 = 2'b01;
localparam WRITE_2 = 2'b10;
localparam BYPASS  = 2'b11;

//States definition for state_byte
localparam IDLE   = 3'b100;
localparam BYTE_0 = 3'b000;
localparam BYTE_1 = 3'b001;
localparam BYTE_2 = 3'b010;
localparam BYTE_3 = 3'b011;

//States definition for state_reset
localparam NO_RESET = 3'b000;
localparam RESET    = 3'b001;
localparam WAIT     = 3'b010;
localparam WRITE    = 3'b011;
localparam RESET_2  = 3'b100;

//Coding for size signal
localparam BYTE      = 2'b00;
localparam HALF_WORD = 2'b01;
localparam WORD      = 2'b10;

//Flops Definition
reg [1:0] state_full;
reg [2:0] state_byte;
reg [2:0] state_reset;

//Internal signals
reg [1:0] next_state_full;
reg [2:0] next_state_byte;
reg [2:0] next_state_reset;

wire last_byte;
wire has_data;


//FSM for management of writes in the input buffers 
//Definition of state register
always @(posedge clk)
 begin
  if(!rst_n)
   state_full <= EMPTY;
  else
   state_full <= next_state_full;
 end

//This signal indicates that the last byte is in processing
assign last_byte = (size_in == BYTE      && state_byte == BYTE_0) ||
                   (size_in == HALF_WORD && state_byte == BYTE_1) ||
                   (size_in == WORD      && state_byte == BYTE_3) ;

//Next state Logic
always @(*)
 begin
  next_state_full = state_full;
  case(state_full)
   EMPTY  : next_state_full = (write) ? WRITE_1 : EMPTY;
   WRITE_1: 
    begin
     if(last_byte)
      begin
       if(!write)
        next_state_full = EMPTY;
      end
     else
      begin
       if(write)
        next_state_full = WRITE_2;
      end
    end
   WRITE_2:
    begin
     if(last_byte)
      next_state_full = (write) ? BYPASS : WRITE_1;
    end
   BYPASS :
    begin
     if(last_byte && !write)
      next_state_full = WRITE_1;
    end
  endcase
 end

//The flag full indicates that buffer is full and any attempt of writing must wait
assign buffer_full = (state_full == WRITE_2 && !last_byte) ||
                     (state_full == BYPASS  && !last_byte);

assign read_wait = (state_byte != IDLE);

//This signal controls the selection of the byte0 
//When bypass_byte0 = 1 the input of byte_ff is taken
//Otherwise, its output is taken
assign bypass_byte0 = (state_full != BYPASS); 

//This signal indicates that there are data in the second position of the buffer
assign has_data = (state_full == WRITE_2) ||
                  (state_full == BYPASS ) ;


//FSM for management of readings in the buffer
//Definition of state register
always @(posedge clk)
 begin
  if(!rst_n)
   state_byte <= IDLE;
  else
   state_byte <= next_state_byte;
 end

always @(*)
 begin
  next_state_byte = state_byte;
  case(state_byte)
   IDLE: next_state_byte = (write) ? BYTE_0 : IDLE;
   BYTE_0:
    begin
     if(size_in == BYTE)
      begin
       if(!write && !has_data)
        next_state_byte = IDLE;
      end
     else
      begin
       next_state_byte = BYTE_1;
      end
    end
   BYTE_1:
    begin
     if(size_in == HALF_WORD)
      begin
       if(has_data || (write && !buffer_full))
        next_state_byte = BYTE_0;
       else
        next_state_byte = IDLE;
      end
     else
      begin
       next_state_byte = BYTE_2;
      end
    end
   BYTE_2:
    begin
     next_state_byte = BYTE_3;
    end
   BYTE_3:
    begin
     if(has_data || (write && !buffer_full))
      next_state_byte = BYTE_0;
     else
      next_state_byte = IDLE;
    end
  endcase
 end

//The signal byte_sel controls the number of byte that will be processed by CRC Unit
always @(*)
 begin
  byte_sel = 2'b00;
  case(state_byte)
   BYTE_0: byte_sel = BYTE_0;
   BYTE_1: byte_sel = BYTE_1;
   BYTE_2: byte_sel = BYTE_2;
   BYTE_3: byte_sel = BYTE_3;
  endcase
 end
//This signal controls the selection of the metadata size 
//When bypass_size = 1 the input of size_ff is taken
//Otherwise, its output is taken
assign bypass_size = !( (state_full != BYPASS && state_byte != BYTE_0) ||
                        (state_full == BYPASS)
                      );

//This signal enables the write in the crc_out register
assign crc_out_en = (state_byte != IDLE);

//
assign byte_en = (state_byte == BYTE_0 && (size_in == HALF_WORD || size_in == WORD) && state_full != BYPASS) ||
                 (last_byte && has_data);

//FSM for control of reset of chained operation
//Definition of state register
always @(posedge clk)
 begin
  if(!rst_n)
   state_reset <= NO_RESET;
  else
   state_reset <= next_state_reset;
 end

always @(*)
 begin
  next_state_reset = state_reset;
  case(state_reset)
   NO_RESET:
    begin
     if((reset_chain && !has_data && state_byte != IDLE && !last_byte) || (reset_chain && has_data && last_byte))
      next_state_reset = RESET;
     if(reset_chain  && has_data && !last_byte)
      next_state_reset = WAIT;
    end
   RESET:
    begin
     if(last_byte)
      next_state_reset = NO_RESET;
     else
      next_state_reset = (write) ? WRITE : RESET;
    end
   WAIT:
    begin
     if(last_byte)
      next_state_reset = (write) ? WRITE : RESET;
     else
      next_state_reset = WAIT;
    end
   WRITE:
    begin
     if(reset_chain)
      next_state_reset = (last_byte) ? RESET : RESET_2;
     else
      next_state_reset = (last_byte) ? NO_RESET : WRITE;
    end
   RESET_2:
    begin
     if(last_byte)
      next_state_reset = (write) ? WRITE : RESET;
     else
      next_state_reset = RESET_2;
    end
  endcase
 end

//This signal set the crc_init_sel flop
//When seted this flop turn on the chained operation of crc 
assign set_crc_init_sel = (state_byte == BYTE_0);

//This signal clear the crc_init_sel
//The clear get priority over set
assign clear_crc_init_sel = (state_reset == NO_RESET && last_byte && reset_chain) ||
                            (state_byte  == IDLE     && reset_chain             ) ||
                            (state_reset == RESET    && last_byte               ) ||
                            (state_reset == WRITE    && last_byte               ) ||
                            (state_reset == RESET_2  && last_byte               ) ;

assign reset_pending = (state_reset != NO_RESET);

endmodule
