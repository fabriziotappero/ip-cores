//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores Data Path controller                        ////
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

module g_dpath_ctrl (
              rst_n               , 
              clk                 ,

              rx_buf_base_addr    ,
              tx_buf_base_addr    ,

    // gmac core to memory write interface
              g_rx_mem_rd         ,
              g_rx_mem_eop        ,
              g_rx_mem_addr       ,
              g_rx_block_rxrd     , 

       // descr handshake    
              g_rx_desc_req       ,
              g_rx_desc_discard   ,
              g_rx_desc_data      ,
              g_rx_desc_ack       ,

              g_rx_pkt_done       ,
              g_rx_pkt_len        ,
              g_rx_pkt_status     ,
              g_rx_pkt_drop       


      );


input         rst_n                 ; 
input         clk                   ;

input [3:0]   rx_buf_base_addr      ; // 8K Rx Base Address
input [3:0]   tx_buf_base_addr      ; // 8K tx Base Address

// gmac core to memory write interface
input         g_rx_mem_rd           ;
input         g_rx_mem_eop          ;
output [15:0] g_rx_mem_addr         ;
output        g_rx_block_rxrd       ; // Block Rx Read between EOP and PktDone

input         g_rx_pkt_done         ; // End of current Packet
input [11:0]  g_rx_pkt_len          ; // Packet Length 
input [15:0]  g_rx_pkt_status       ; // Packet Status
input         g_rx_pkt_drop         ; // Packet drop and rewind the pointer


//-----------------------------------
// Descriptor handshake
//----------------------------------
output        g_rx_desc_req         ; // rx desc request
output        g_rx_desc_discard     ; // rx desc discard indication
output [31:0] g_rx_desc_data        ; // rx desc data
input         g_rx_desc_ack         ; // rx desc ack


reg          g_rx_desc_req         ;
reg          g_rx_desc_discard     ; // rx desc discard indication
reg  [31:0]  g_rx_desc_data      ; // rx desc data

reg    [11:0] g_rx_mem_addr_int     ;

wire [15:0]   g_rx_mem_addr  = {rx_buf_base_addr,g_rx_mem_addr_int[11:0]};

 
reg         bStartFlag; // Indicate a SOP transaction, used for registering Start Address
reg         g_rx_block_rxrd; // Block Rx Read at the end of EOP and Enable on Packet Done
reg [11:0]  g_rx_saddr;
 
always @(negedge rst_n or posedge clk) begin
   if(rst_n == 0) begin
      g_rx_mem_addr_int <= 0;
      bStartFlag        <= 1;
      g_rx_block_rxrd   <= 0; 
      g_rx_saddr        <= 0;
      g_rx_desc_discard <= 0;
      g_rx_desc_data    <= 0;
      g_rx_desc_req     <= 0;
   end
   else begin
      if(bStartFlag && g_rx_mem_rd) begin
         g_rx_saddr   <= g_rx_mem_addr_int[11:0];
         bStartFlag   <= 0;
      end else if (g_rx_mem_rd && g_rx_mem_eop) begin
         bStartFlag   <= 1;
      end

      if(g_rx_mem_rd && g_rx_mem_eop)
         g_rx_block_rxrd   <= 1;
      else if(g_rx_pkt_done)
         g_rx_block_rxrd   <= 0;

      //-----------------------------
      // Finding the Frame Size
      //----------------------------
      if(g_rx_pkt_done && g_rx_pkt_drop) begin
         g_rx_mem_addr_int <= g_rx_saddr;
      end else if(g_rx_mem_rd && g_rx_mem_eop) begin
         // Realign to 32 bit boundary and add one free space at eop
         g_rx_mem_addr_int[1:0]  <= 0;
         g_rx_mem_addr_int[11:2] <= g_rx_mem_addr_int[11:2]+1;
      end else if(g_rx_mem_rd ) begin
         g_rx_mem_addr_int <= g_rx_mem_addr_int+1;
      end
      // Descriptor Request Generation
      if(g_rx_pkt_done) begin
          g_rx_desc_req   <= 1;
          if(g_rx_pkt_drop) begin
             g_rx_desc_discard <= 1;
          end else begin
             g_rx_desc_discard <= 0;
             g_rx_desc_data  <= {g_rx_pkt_status[5:0],rx_buf_base_addr[3:0],
                                 g_rx_saddr[11:2],g_rx_pkt_len[11:0]};
          end
      end
      else if (g_rx_desc_ack) begin
         g_rx_desc_req  <= 0;
         g_rx_desc_discard <= 0;
      end
   end
end


endmodule
