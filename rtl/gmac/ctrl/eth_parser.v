//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
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

// ------------------------------------------------------------------------
// Description      : 
//   This module instantiates the Eth/Arp/IP/TCP/UDP Packet Parser
//
// ------------------------------------------------------------------------
module  g_eth_parser (
                    s_reset_n, 
                    app_clk,

               // Configuration
                    cfg_filters,
                    cfg_mac_sa,
                    cfg_ip_sa,

               // Input Control Information
                    eop,
                    dval,
                    data,
             
                // output status 
                    pkt_done,
                    pkt_len,
                    pkt_status,
                    pkt_drop_ind,
                    pkt_drop_reason
               );

//------------------------------
// Global Input signal
//------------------------------                    
input               s_reset_n; // Active low reset signal
input               app_clk  ; // Application clock

//------------------------------
// Configuration
//------------------------------
input [31:0]        cfg_filters; // Filter rules
                                 // [0] - filtering enabled
                                 // [1] - allow local mac-da only
                                 // [2] - allow local mac-da only + IP4 local ip-da
                                 // [3] - allow local mac-da only + IP4 local ip-da + TCP
                                 // [4] - allow local mac-da only + IP4 local ip-da + UDP
                                 // [5] - allow local mac-da only + IP4 local ip-da + ICMP
                                 // [6] - allow local mac-da only + ARP

input [47:0]        cfg_mac_sa;      // 48 bit mac DA
input [31:0]        cfg_ip_sa;   // 32 bit IP DA

//---------------------------
// Input Control Information
//---------------------------
input               eop;
input               dval;
input [7:0]         data;

//-----------------------------             
// output status 
//-----------------------------
output   [11:0]     pkt_len;     // Packet Length
output              pkt_done;    // Packet Processing done indication
output   [15:0]     pkt_status;  // packet processing status
                                 // [1:0] - MAC-DA
                                 //         2'b00  - Broadcast frame
                                 //         2'b01  - Multicast frame
                                 //         2'b10  - unicast frame, other than local DA
                                 //         2'b11  - unicast local DA frame
                                 // [3:2] - MAC-SA
                                 //         2'b00  - Broadcast frame
                                 //         2'b01  - Multicast frame
                                 //         2'b10  - unicast frame, other than local DA
                                 //         2'b11  - unicast local DA frame
                                 // [6:4] - 3'b000 - Unknown Ethernet frame
                                 //         3'b001 - IP4 Frame
                                 //         3'b010 - IP4 Frame + TCP
                                 //         3'b011 - IP4 Frame + UDP
                                 //         3'b100 - IP4 Frame + ICMP
                                 //         3'b101 - ARP frame
output          pkt_drop_ind;    // Packet Drop Inidcation

output [7:0]    pkt_drop_reason; // Reason for Frame Drop
                                 // [0] - Non Local DA
                                 // [1] - Local DA == Remote SA
                                 // [2] - Non Local IP-DA
                                 // [3] - Local IP-DA == Remote IP-SA
                                 // [4] - Not Valid IP4/TCP/UDP/ARP/ICMP Frame
                                 // [5] - L2 Check sum error
                                 // [6] - L3 Check Sum Error
                                 // [7] - L4 Check Sum Error

reg [11:0]      bcnt           ; // Byte counter
reg [11:0]      pkt_len        ; // packet length
reg             pkt_done       ; // packet complete indication + Packet Status Valid
reg             pkt_drop_ind   ;


always @(negedge s_reset_n  or posedge app_clk) begin
   if(s_reset_n == 1'b0) begin
      bcnt         <= 0;
      pkt_len      <= 0;
      pkt_done     <= 0;
      pkt_drop_ind <= 0;
   end
   else begin
      if(dval) begin
         if(eop) begin
            bcnt <= 0;
            pkt_len  <= bcnt +1;
            pkt_done <= 1;
         end else begin
            bcnt <= bcnt +1;
            pkt_done <= 0;
         end 
      end else begin
         pkt_done <= 0;
      end
   end 
end

reg        mac_da_bc     ; // frame da is broad cast
reg        mac_da_mc     ; // frame da is multicast
reg        mac_da_match  ; // frame da match to local address
reg        mac_sa_bc     ; // frame sa is broadcast
reg        mac_sa_mc     ; // frame sa is multicast
reg        mac_sa_match  ; // frame sa match to local address
reg        ipv4f         ; // frame is ipv4 
reg        arpf          ; // frame is arp
reg        tcpf          ; // frame is tcp
reg        udpf          ; // frame is udp
reg        ip_sa_match   ; // ip4 sa matches to local IP Address 
reg        ip_da_match   ; // ip4 da matches to local IP Address
reg[15:0]  pkt_status    ; // Packet Status

always @(negedge s_reset_n or posedge app_clk) begin
   if(s_reset_n == 1'b0) begin
      mac_da_bc     <= 0;
      mac_da_mc     <= 0;
      mac_da_match  <= 0;
      mac_sa_bc     <= 0;
      mac_sa_mc     <= 0;
      mac_sa_match  <= 0;
      ipv4f         <= 0;
      arpf          <= 0;
      tcpf          <= 0;
      udpf          <= 0;
      ip_sa_match   <= 0;
      ip_da_match   <= 0;
      pkt_status    <= 0;
   end
   else begin
      if(dval) begin
           if(!eop) begin
         // DA Analysis
              // Broadcast Frame   
              mac_da_bc      <=  (bcnt == 0) ? (data == 8'hff)             :
                                 (bcnt == 1) ? (data == 8'hff) & mac_da_bc :
                                 (bcnt == 2) ? (data == 8'hff) & mac_da_bc :
                                 (bcnt == 3) ? (data == 8'hff) & mac_da_bc :
                                 (bcnt == 4) ? (data == 8'hff) & mac_da_bc :
                                 (bcnt == 5) ? (data == 8'hff) & mac_da_bc : mac_da_bc;
              // multicast frame
              mac_da_mc       <= (bcnt == 0) ? (data[7] == 1'b1)  : mac_da_mc & !mac_da_bc;

              // local unicast frame
              mac_da_match    <= (bcnt == 0) ? (cfg_mac_sa[7:0]   == data) : 
                                 (bcnt == 1) ? (cfg_mac_sa[15:8]  == data) & mac_da_match :
                                 (bcnt == 2) ? (cfg_mac_sa[23:16] == data) & mac_da_match :
                                 (bcnt == 3) ? (cfg_mac_sa[31:24] == data) & mac_da_match :
                                 (bcnt == 4) ? (cfg_mac_sa[39:32] == data) & mac_da_match :
                                 (bcnt == 5) ? (cfg_mac_sa[47:40] == data) & mac_da_match : 
                                 mac_da_match; 


            // SA Analysis
              mac_sa_bc      <=  (bcnt == 6)  ? (data == 8'hff)             :
                                 (bcnt == 7)  ? (data == 8'hff) & mac_sa_bc :
                                 (bcnt == 8)  ? (data == 8'hff) & mac_sa_bc :
                                 (bcnt == 9)  ? (data == 8'hff) & mac_sa_bc :
                                 (bcnt == 10) ? (data == 8'hff) & mac_sa_bc :
                                 (bcnt == 11) ? (data == 8'hff) & mac_sa_bc : mac_sa_bc;

              mac_sa_mc      <= (bcnt == 6)  ? (data[7] == 1'b1)  : mac_sa_mc & !mac_sa_bc;

              mac_sa_match   <= (bcnt == 6)  ? (cfg_mac_sa[7:0]   == data) : 
                                (bcnt == 7)  ? (cfg_mac_sa[15:8]  == data) & mac_sa_match :
                                (bcnt == 8)  ? (cfg_mac_sa[23:16] == data) & mac_sa_match :
                                (bcnt == 9)  ? (cfg_mac_sa[31:24] == data) & mac_sa_match :
                                (bcnt == 10) ? (cfg_mac_sa[39:32] == data) & mac_sa_match :
                                (bcnt == 11) ? (cfg_mac_sa[47:40] == data) & mac_sa_match :
                                mac_sa_match;

             // L3 Protocol Analysis
              ipv4f          <= (bcnt == 12) ? (data == 8'h08) :
                             (bcnt == 13) ? (data == 8'h00) & ipv4f : ipv4f;

              arpf           <= (bcnt == 12) ? (data == 8'h08) :
                            (bcnt == 13) ? (data == 8'h06) & arpf : arpf;
             // L4 Protocol Analysis
              tcpf           <= (bcnt == 23) ? (data == 8'h06) & ipv4f: tcpf;
              udpf           <= (bcnt == 23) ? (data == 8'h11) & ipv4f: udpf;
             // IP DA and SA Match
              ip_sa_match     <= (bcnt == 26) ? (data == cfg_ip_sa[7:0])   & ipv4f: 
                                 (bcnt == 27) ? (data == cfg_ip_sa[15:8])  & ipv4f & ip_sa_match:
                                 (bcnt == 28) ? (data == cfg_ip_sa[23:16]) & ipv4f & ip_sa_match:
                                 (bcnt == 29) ? (data == cfg_ip_sa[31:24]) & ipv4f & ip_sa_match:
                                 ip_sa_match;
              ip_da_match     <= (bcnt == 26) ? (data == cfg_ip_sa[7:0])   & ipv4f: 
                                 (bcnt == 27) ? (data == cfg_ip_sa[15:8])  & ipv4f & ip_da_match:
                                 (bcnt == 28) ? (data == cfg_ip_sa[23:16]) & ipv4f & ip_da_match:
                                 (bcnt == 29) ? (data == cfg_ip_sa[31:24]) & ipv4f & ip_da_match:
                                 ip_da_match;

           end else begin // on EOP

            if(&mac_da_match) begin
               pkt_status[1:0] <= 2'b11; // Local DA
            end else if(mac_da_bc) begin 
               pkt_status[1:0] <= 2'b00;  // Broadcast frame
            end else if(mac_da_mc) begin 
               pkt_status[1:0] <= 2'b01; // Multicase frame
            end else
               pkt_status[1:0] <= 2'b10; // Unknown Unicast frame

            if(&mac_sa_match) begin
               pkt_status[3:2] <= 2'b11; // Local DA
            end else if(mac_sa_bc) begin 
               pkt_status[3:2] <= 2'b00;  // Broadcast frame
            end else if(mac_sa_mc) begin 
               pkt_status[3:2] <= 2'b01; // Multicast frame
            end else
               pkt_status[3:2] <= 2'b10; // Unknown Unicast frame

            if(tcpf) begin
               pkt_status[6:4] <= 3'b010; // IP4 Frame + TCP
            end else if(udpf) begin 
               pkt_status[6:4] <= 3'b011; // IP4 Frame + UDP
            end else if(arpf) begin 
               pkt_status[6:4] <= 3'b101; // ARP frame
            end else
               pkt_status[6:4] <= 2'b00; // UnKnown Ethernet frame

            mac_da_match  <= 0;
            mac_sa_match  <= 0;
            mac_sa_bc     <= 0;
            mac_sa_mc     <= 0;
            mac_da_bc     <= 0;
            mac_da_mc     <= 0;
	    tcpf          <= 0;
	    udpf          <= 0;
	    arpf          <= 0;
	    ipv4f         <= 0;
         end 
      end
   end 
end


endmodule
