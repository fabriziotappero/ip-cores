//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
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

/**********************************************
      Web-bone , Read from Memory and Write to WebBone External Memory
**********************************************/

module wb_wr_mem2mem (

              rst_n               , 
              clk                 ,


    // Master Interface Signal
              mem_taddr           ,
              mem_addr            ,
              mem_empty           ,
              mem_aempty          ,
              mem_rd              , 
              mem_dout            ,
              mem_eop             ,

              cfg_desc_baddr      ,
              desc_req            ,
              desc_ack            ,
              desc_disccard       ,
              desc_data           ,

 
    // Slave Interface Signal
              wbo_din             , 
              wbo_taddr           , 
              wbo_addr            , 
              wbo_be              , 
              wbo_we              , 
              wbo_ack             ,
              wbo_stb             , 
              wbo_cyc             , 
              wbo_err             ,
              wbo_rty
         );


parameter D_WD    = 16; // Data Width
parameter BE_WD   = 2;  // Byte Enable
parameter ADR_WD  = 28; // Address Width
parameter TAR_WD  = 4;  // Target Width

// State Machine
parameter   IDLE       = 3'h0;
parameter   RD_BYTE1   = 3'h1;
parameter   RD_BYTE2   = 3'h2;
parameter   RD_BYTE3   = 3'h3;
parameter   RD_BYTE4   = 3'h4;
parameter   WB_XFR     = 3'h5;
parameter   DESC_WAIT  = 3'h6;
parameter   DESC_XFR   = 3'h7;

input               clk      ;  // CLK_I The clock input [CLK_I] coordinates all activities 
                                // for the internal logic within the WISHBONE interconnect. 
                                // All WISHBONE output signals are registered at the 
                                // rising edge of [CLK_I]. 
                                // All WISHBONE input signals must be stable before the 
                                // rising edge of [CLK_I]. 
input               rst_n    ;  // RST_I The reset input [RST_I] forces the WISHBONE interface 
                                // to restart. Furthermore, all internal self-starting state 
                                // machines will be forced into an initial state. 

//------------------------------------------
// Stanard Memory Interface
//------------------------------------------
input [TAR_WD-1:0]  mem_taddr;  // target address 
input [15:0]        mem_addr;   // memory address 
input               mem_empty;  // memory empty 
input               mem_aempty; // memory empty 
output              mem_rd;     // memory read
input  [7:0]        mem_dout;   // memory read data
input               mem_eop;    // Last Transfer indication

//----------------------------------------
// Discriptor defination
//----------------------------------------
input              desc_req;    // descriptor request
output             desc_ack;    // descriptor ack
input              desc_disccard;// descriptor discard
input [15:6]       cfg_desc_baddr;  // descriptor memory base address
input [31:0]       desc_data;   // descriptor data

//------------------------------------------
// External Memory WB Interface
//------------------------------------------
output [TAR_WD-1:0] wbo_taddr ;
output              wbo_stb  ; // STB_O The strobe output [STB_O] indicates a valid data 
                               // transfer cycle. It is used to qualify various other signals 
                               // on the interface such as [SEL_O(7..0)]. The SLAVE must 
                               // assert either the [ACK_I], [ERR_I] or [RTY_I] signals in 
                               // response to every assertion of the [STB_O] signal. 
output              wbo_we   ; // WE_O The write enable output [WE_O] indicates whether the 
                               // current local bus cycle is a READ or WRITE cycle. The 
                               // signal is negated during READ cycles, and is asserted 
                               // during WRITE cycles. 
input               wbo_ack  ; // The acknowledge input [ACK_I], when asserted, 
                               // indicates the termination of a normal bus cycle. 
                               // Also see the [ERR_I] and [RTY_I] signal descriptions. 

output [ADR_WD-1:0] wbo_addr  ; // The address output array [ADR_O(63..0)] is used 
                               // to pass a binary address, with the most significant 
                               // address bit at the higher numbered end of the signal array. 
                               // The lower array boundary is specific to the data port size. 
                               // The higher array boundary is core-specific. 
                               // In some cases (such as FIFO interfaces) 
                               // the array may not be present on the interface. 

output [BE_WD-1:0] wbo_be     ; // Byte Enable 
                               // SEL_O(7..0) The select output array [SEL_O(7..0)] indicates 
                               // where valid data is expected on the [DAT_I(63..0)] signal 
                               // array during READ cycles, and where it is placed on the 
                               // [DAT_O(63..0)] signal array during WRITE cycles. 
                               // Also see the [DAT_I(63..0)], [DAT_O(63..0)] and [STB_O] 
                               // signal descriptions.

output            wbo_cyc    ; // CYC_O The cycle output [CYC_O], when asserted, 
                               // indicates that a valid bus cycle is in progress. 
                               // The signal is asserted for the duration of all bus cycles. 
                               // For example, during a BLOCK transfer cycle there can be 
                               // multiple data transfers. The [CYC_O] signal is asserted 
                               // during the first data transfer, and remains asserted 
                               // until the last data transfer. The [CYC_O] signal is useful 
                               // for interfaces with multi-port interfaces 
                               // (such as dual port memories). In these cases, 
                               // the [CYC_O] signal requests use of a common bus from an 
                               // arbiter. Once the arbiter grants the bus to the MASTER, 
                               // it is held until [CYC_O] is negated. 

output [D_WD-1:0] wbo_din;     // DAT_I(63..0) The data input array [DAT_I(63..0)] is 
                               // used to pass binary data. The array boundaries are 
                               // determined by the port size. Also see the [DAT_O(63..0)] 
                               // and [SEL_O(7..0)] signal descriptions. 

input             wbo_err; // ERR_I The error input [ERR_I] indicates an abnormal 
                           // cycle termination. The source of the error, and the 
                           // response generated by the MASTER is defined by the IP core 
                           // supplier in the WISHBONE DATASHEET. Also see the [ACK_I] 
                           // and [RTY_I] signal descriptions. 

input             wbo_rty; // RTY_I The retry input [RTY_I] indicates that the indicates 
                           // that the interface is not ready to accept or send data, and 
                           // that the cycle should be retried. When and how the cycle is 
                           // retried is defined by the IP core supplier in the WISHBONE 
                           // DATASHEET. Also see the [ERR_I] and [RTY_I] signal 
                           // descriptions. 

//-------------------------------------------
// Register Dec
//-------------------------------------------

reg [TAR_WD-1:0]     wbo_taddr ;
reg [ADR_WD-1:0]     wbo_addr  ;
reg                  wbo_stb   ;
reg                  wbo_we    ;
reg [BE_WD-1:0]      wbo_be    ;
reg                  wbo_cyc   ;
reg [D_WD-1:0]       wbo_din   ;
reg [2:0]            state     ;

reg                  mem_rd    ;
reg [3:0]            desc_ptr  ; // descriptor pointer, in 32 bit mode
reg                  mem_eop_l ; // delayed eop signal
reg                  desc_ack  ; // delayed eop signal

reg  [23:0]  tWrData; // Temp 24 Bit Data
always @(negedge rst_n or posedge clk) begin
   if(rst_n == 0) begin
      wbo_taddr <= 0;
      wbo_addr  <= 0;
      wbo_stb   <= 0;
      wbo_we    <= 0;
      wbo_be    <= 0;
      wbo_cyc   <= 0;
      wbo_din   <= 0;
      mem_rd    <= 0;
      desc_ptr  <= 0;
      mem_eop_l <= 0;
      desc_ack  <= 0;
      tWrData   <= 0;
      state     <= IDLE;
   end
   else begin
      case(state)
       IDLE: begin
          desc_ack <= 0;
          if(!mem_empty) begin
             mem_rd         <= 1;
             mem_eop_l      <= 0;
             tWrData[7:0]   <= mem_dout[7:0];
             state          <= RD_BYTE1;
          end
       end
       RD_BYTE1: begin // End of First Transfer
          if(mem_rd && mem_eop) begin
             mem_rd    <= 0;
             mem_eop_l <= mem_eop;
             wbo_taddr <= mem_taddr;
             wbo_addr  <= mem_addr[14:2];
             wbo_stb   <= 1'b1;
             wbo_we    <= 1'b1;
             wbo_be    <= 4'h1; // Assigned Aligned 32bit address
             wbo_din   <= {24'h0,mem_dout[7:0]};
             wbo_cyc   <= 1;
             state     <= WB_XFR;
          end else if(!(mem_empty || (mem_rd && mem_aempty))) begin
             mem_rd    <= 1;
             state     <= RD_BYTE2;
          end else begin
             mem_rd    <= 0;
          end
          if(mem_rd) begin
             tWrData[7:0]   <= mem_dout[7:0];
          end
       end

       RD_BYTE2: begin // End of Second Transfer
          if(mem_rd && mem_eop) begin
             mem_rd    <= 0;
             mem_eop_l <= mem_eop;
             wbo_taddr <= mem_taddr;
             wbo_addr  <= mem_addr[14:2];
             wbo_stb   <= 1'b1;
             wbo_we    <= 1'b1;
             wbo_be    <= 4'h3; // Assigned Aligned 32bit address
             wbo_din   <= {16'h0,mem_dout[7:0],tWrData[7:0]};
             wbo_cyc   <= 1;
             state     <= WB_XFR;
          end else if(!(mem_empty || (mem_rd && mem_aempty))) begin
             mem_rd    <= 1;
             state     <= RD_BYTE3;
          end else begin
             mem_rd    <= 0;
          end
          if(mem_rd) begin
             tWrData[15:8]   <= mem_dout[7:0];
          end
       end


       RD_BYTE3: begin // End of Third Transfer
          if(mem_rd && mem_eop) begin
             mem_rd    <= 0;
             mem_eop_l <= mem_eop;
             wbo_taddr <= mem_taddr;
             wbo_addr  <= mem_addr[14:2];
             wbo_stb   <= 1'b1;
             wbo_we    <= 1'b1;
             wbo_be    <= 4'h7; // Assigned Aligned 32bit address
             wbo_din   <= {8'h0,mem_dout[7:0],tWrData[15:0]};
             wbo_cyc   <= 1;
             state     <= WB_XFR;
          end else if(!(mem_empty || (mem_rd && mem_aempty))) begin
             mem_rd    <= 1;
             state     <= RD_BYTE4;
          end else begin
             mem_rd    <= 0;
          end
          if(mem_rd) begin
             tWrData[23:16]   <= mem_dout[7:0];
          end
       end

       RD_BYTE4: begin // End of Fourth Transfer
             mem_rd    <= 0;
             mem_eop_l <= mem_eop;
             wbo_taddr <= mem_taddr;
             wbo_addr  <= mem_addr[14:2];
             wbo_stb   <= 1'b1;
             wbo_we    <= 1'b1;
             wbo_be    <= 4'hF; // Assigned Aligned 32bit address
             wbo_din   <= {mem_dout[7:0],tWrData[23:0]};
             wbo_cyc   <= 1;
             state     <= WB_XFR;
       end

       WB_XFR: begin
          if(wbo_ack) begin
             wbo_stb   <= 0;
             wbo_cyc   <= 0;
             if(mem_eop_l) begin
                state     <= DESC_WAIT;
             end else begin
                state     <= IDLE; // Next Byte
             end
          end 
       end


       DESC_WAIT: begin
          if(desc_req) begin
             desc_ack    <= 1;
             if(desc_disccard) begin // if the Desc is discarded
                state     <= IDLE;
             end
             else begin
                wbo_addr  <= {cfg_desc_baddr[15:6],desc_ptr[3:0]}; // Each Transfer is 32bit
                wbo_be    <= 4'hF;
                wbo_din   <= desc_data;
                wbo_we    <= 1'b1;
                wbo_stb   <= 1'b1;
                wbo_cyc   <= 1;
                state     <= DESC_XFR;
                desc_ptr  <= desc_ptr+1;
             end
          end
       end
       DESC_XFR: begin
           desc_ack <= 0;
          if(wbo_ack) begin
              wbo_stb   <= 1'b0;
              wbo_cyc   <= 1'b0;
              state     <= IDLE;
          end 
       end

      endcase
   end
end



endmodule
