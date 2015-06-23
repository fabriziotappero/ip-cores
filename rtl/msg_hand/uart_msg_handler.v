//////////////////////////////////////////////////////////////////////
////                                                              ////
////  UART Message Handler Module                                 ////
////                                                              ////
////  This file is part of the uart2spi cores project             ////
////  http://www.opencores.org/cores/uart2spi/                    ////
////                                                              ////
////  Description                                                 ////
////  Uart Message Handler definitions.                           ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module uart_msg_handler (  
        reset_n ,
        sys_clk ,


    // UART-TX Information
        tx_data_avail,
        tx_rd,
        tx_data,
         

    // UART-RX Information
        rx_ready,
        rx_wr,
        rx_data,

      // Towards Register Interface
        reg_addr,
        reg_wr,  
        reg_wdata,
        reg_req,
	reg_ack,
	reg_rdata

     );


// Define the Message Hanlde States
`define IDLE	         4'h0
`define IDLE_TX_MSG1	 4'h1
`define IDLE_TX_MSG2	 4'h2
`define RX_CMD_PHASE	 4'h3
`define WR_ADR_PHASE	 4'h4
`define WR_DATA_PHASE	 4'h5
`define SEND_WR_REQ	 4'h6
`define RD_ADDR_PHASE	 4'h7
`define SEND_RD_REQ	 4'h8
`define SEND_RD_DATA	 4'h9
`define TX_MSG           4'hA
     
`define BREAK_CHAR       8'h0A

//---------------------------------
// Global Dec
// ---------------------------------

input        reset_n               ; // line reset
input        sys_clk               ; // line clock


//--------------------------------------
// UART TXD Path
// -------------------------------------
output         tx_data_avail        ; // Indicate valid TXD Data available
output [7:0]   tx_data              ; // TXD Data to be transmited
input          tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// UART RXD Path
// -------------------------------------
output         rx_ready            ; // Indicate Ready to accept the Read Data
input [7:0]    rx_data             ; // RXD Data 
input          rx_wr               ; // Valid RXD Data

//---------------------------------------
// Control Unit interface
// --------------------------------------

output  [15:0] reg_addr           ; // Operend-1
output  [31:0]  reg_wdata          ; // Operend-2
output         reg_req            ; // Register Request
output         reg_wr             ; // 1 -> write; 0 -> read
input          reg_ack            ; // Register Ack
input   [31:0] reg_rdata          ;

// Local Wire/Register Decleration
//
//
reg             tx_data_avail      ;
reg [7:0]       tx_data            ;
reg [16*8-1:0]  TxMsgBuf           ; // 16 Byte Tx Message Buffer
reg  [4:0]      TxMsgSize          ;
reg  [4:0]      RxMsgCnt           ; // Count the Receive Message Count
reg  [3:0]      State              ;
reg  [3:0]      NextState          ;
reg  [15:0]     cmd                ; // command
reg  [15:0]     reg_addr           ; // reg_addr
reg  [31:0]      reg_wdata          ; // reg_addr
reg             reg_wr             ; // 1 -> Reg Write request, 0 -> Read Requestion
reg             reg_req            ; // 1 -> Register request


wire rx_ready = 1; 
/****************************************************************
*  UART Message Hanlding Steps
*
*  1. On Reset Or Unknown command, Send the Default Message
*     Select Option:
*     wr <addr> <data>
*     rd <addr>
*  2. Wait for User command <wr/rd> 
*  3. On <wr> command move to write address phase;
*  phase
*       A. After write address phase move to write data phase
*       B. After write data phase, once user press \r command ; send register req
*          and write request and address + data 
*       C. On receiving register ack response; send <success> message back and move
*          to state-2
*  3.  On <rd> command move to read address phase;
*       A. After read address phase , once user press '\r' command; send
*          register req , read request 
*       C. On receiving register ack response; send <response + read_data> message and move
*          to state-2
*  *****************************************************************/

always @(negedge reset_n or posedge sys_clk)
begin
   if(reset_n == 1'b0) begin
      tx_data_avail <= 0;
      reg_req       <= 0;
      State         <= `IDLE;
      NextState     <= `IDLE;
   end else begin
   case(State)
      // Send Default Message
      `IDLE: begin
   	  TxMsgBuf      <= "Command Format:\n";  // Align to 16 character format by appending space character
          TxMsgSize     <= 16;
	  tx_data_avail <= 0;
	  State         <= `TX_MSG;
	  NextState     <= `IDLE_TX_MSG1;
       end

      // Send Default Message (Contd..)
      `IDLE_TX_MSG1: begin
	   TxMsgBuf      <= "wm <ad> <data>\n "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 15;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `IDLE_TX_MSG2;
        end

      // Send Default Message (Contd..)
      `IDLE_TX_MSG2: begin
	   TxMsgBuf      <= "rm <ad>\n>>      ";  // Align to 16 character format by appending space character
           TxMsgSize     <= 10;
	   tx_data_avail <= 0;
	   RxMsgCnt      <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
      end

       // Wait for Response
    `RX_CMD_PHASE: begin
	if(rx_wr == 1) begin
	   //if(RxMsgCnt == 0 && rx_data == " ") begin // Ignore the same
	   if(RxMsgCnt == 0 && rx_data == 8'h20) begin // Ignore the same
	   //end else if(RxMsgCnt > 0 && rx_data == " ") begin // Check the command
	   end else if(RxMsgCnt > 0 && rx_data == 8'h20) begin // Check the command
	     //if(cmd == "wm") begin
	     if(cmd == 16'h776D) begin
		 RxMsgCnt <= 0;
		 reg_addr <= 0;
		 reg_wdata <= 0;
		 State <= `WR_ADR_PHASE;
	      //end else if(cmd == "rm") begin
	      end else if(cmd == 16'h726D) begin
		 reg_addr <= 0;
		 RxMsgCnt <= 0;
		 State <= `RD_ADDR_PHASE;
             end else begin // Unknow command
	        State         <= `IDLE;
             end
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State         <= `IDLE;
	   end 
	   else begin
              cmd <=  (cmd << 8) | rx_data ;
	      RxMsgCnt <= RxMsgCnt+1;
           end
        end 
     end
       // Write Address Phase 
    `WR_ADR_PHASE: begin
	if(rx_wr == 1) begin
	   //if(RxMsgCnt == 0 && rx_data == " ") begin // Ignore the Space character
	   if(RxMsgCnt == 0 && rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(RxMsgCnt > 0 && rx_data == " ") begin // Move to write data phase
	   end else if(RxMsgCnt > 0 && rx_data == 8'h20) begin // Move to write data phase
	      State         <= `WR_DATA_PHASE;
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State         <= `IDLE;
	   end else begin 
              reg_addr <= (reg_addr << 4) | char2hex(rx_data); 
	      RxMsgCnt <= RxMsgCnt+1;
           end
	end
     end
    // Write Data Phase 
    `WR_DATA_PHASE: begin
	if(rx_wr == 1) begin
	   //if(rx_data == " ") begin // Ignore the Space character
	   if(rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State           <= `SEND_WR_REQ;
	      reg_wr          <= 1'b1; // Write request
	      reg_req         <= 1'b1;
	   end else begin // A to F
                 reg_wdata <= (reg_wdata << 4) | char2hex(rx_data); 
           end
	end
     end
    `SEND_WR_REQ: begin
	if(reg_ack)  begin
	   reg_req       <= 1'b0;
	   TxMsgBuf      <= "cmd success\n>>  "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 14;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
       end
    end

       // Write Address Phase 
    `RD_ADDR_PHASE: begin
	if(rx_wr == 1) begin
	   //if(rx_data == " ") begin // Ignore the Space character
	   if(rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State           <= `SEND_RD_REQ;
	      reg_wr          <= 1'b0; // Read request
	      reg_req         <= 1'b1; // Reg Request
	   end 
	   else begin // A to F
                 reg_addr     <= (reg_addr << 4) | char2hex(rx_data); 
	         RxMsgCnt <= RxMsgCnt+1;
	      end
           end
	end

    `SEND_RD_REQ: begin
	if(reg_ack)  begin
	   reg_req       <= 1'b0;
	   TxMsgBuf      <= "Response:       "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 10;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `SEND_RD_DATA;
       end
    end
    `SEND_RD_DATA: begin // Wait for Operation Completion
	   TxMsgBuf[16*8-1:15*8] <= hex2char(reg_rdata[31:28]);
	   TxMsgBuf[15*8-1:14*8] <= hex2char(reg_rdata[27:24]);
	   TxMsgBuf[14*8-1:13*8] <= hex2char(reg_rdata[23:20]);
	   TxMsgBuf[13*8-1:12*8] <= hex2char(reg_rdata[19:16]);
	   TxMsgBuf[12*8-1:11*8] <= hex2char(reg_rdata[15:12]);
	   TxMsgBuf[11*8-1:10*8] <= hex2char(reg_rdata[11:8]);
	   TxMsgBuf[10*8-1:9*8]  <= hex2char(reg_rdata[7:4]);
	   TxMsgBuf[9*8-1:8*8]   <= hex2char(reg_rdata[3:0]);
	   TxMsgBuf[8*8-1:7*8]   <= "\n";
           TxMsgSize     <= 9;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
     end

       // Send Default Message (Contd..)
    `TX_MSG: begin
	   tx_data_avail    <= 1;
	   tx_data          <= TxMsgBuf[16*8-1:15*8];
	   if(TxMsgSize == 0) begin
	      tx_data_avail <= 0;
	      State         <= NextState;
           end else if(tx_rd) begin
   	      TxMsgBuf      <= TxMsgBuf << 8;
              TxMsgSize     <= TxMsgSize -1;
           end
        end
   endcase
   end
end


// Character to hex number
function [3:0] char2hex;
input [7:0] data_in;
case (data_in)
     8'h30:	char2hex = 4'h0; // character '0' 
     8'h31:	char2hex = 4'h1; // character '1'
     8'h32:	char2hex = 4'h2; // character '2'
     8'h33:	char2hex = 4'h3; // character '3'
     8'h34:	char2hex = 4'h4; // character '4' 
     8'h35:	char2hex = 4'h5; // character '5'
     8'h36:	char2hex = 4'h6; // character '6'
     8'h37:	char2hex = 4'h7; // character '7'
     8'h38:	char2hex = 4'h8; // character '8'
     8'h39:	char2hex = 4'h9; // character '9'
     8'h41:	char2hex = 4'hA; // character 'A'
     8'h42:	char2hex = 4'hB; // character 'B'
     8'h43:	char2hex = 4'hC; // character 'C'
     8'h44:	char2hex = 4'hD; // character 'D'
     8'h45:	char2hex = 4'hE; // character 'E'
     8'h46:	char2hex = 4'hF; // character 'F'
     8'h61:	char2hex = 4'hA; // character 'a'
     8'h62:	char2hex = 4'hB; // character 'b'
     8'h63:	char2hex = 4'hC; // character 'c'
     8'h64:	char2hex = 4'hD; // character 'd'
     8'h65:	char2hex = 4'hE; // character 'e'
     8'h66:	char2hex = 4'hF; // character 'f'
      default :  char2hex = 4'hF;
   endcase 
endfunction

// Hex to Asci Character 
function [7:0] hex2char;
input [3:0] data_in;
case (data_in)
     4'h0:	hex2char = 8'h30; // character '0' 
     4'h1:	hex2char = 8'h31; // character '1'
     4'h2:	hex2char = 8'h32; // character '2'
     4'h3:	hex2char = 8'h33; // character '3'
     4'h4:	hex2char = 8'h34; // character '4' 
     4'h5:	hex2char = 8'h35; // character '5'
     4'h6:	hex2char = 8'h36; // character '6'
     4'h7:	hex2char = 8'h37; // character '7'
     4'h8:	hex2char = 8'h38; // character '8'
     4'h9:	hex2char = 8'h39; // character '9'
     4'hA:	hex2char = 8'h41; // character 'A'
     4'hB:	hex2char = 8'h42; // character 'B'
     4'hC:	hex2char = 8'h43; // character 'C'
     4'hD:	hex2char = 8'h44; // character 'D'
     4'hE:	hex2char = 8'h45; // character 'E'
     4'hF:	hex2char = 8'h46; // character 'F'
   endcase 
endfunction
endmodule
