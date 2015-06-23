//////////////////////////////////////////////////////////////////
//                                                              //
//  Top-level module instantiating the entire Amber 2 system.   //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  This is the highest level synthesizable module in the       //
//  project. The ports in this module represent pins on the     //
//  FPGA.                                                       //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2012 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////
`include "global_timescale.vh"

module eth_test  
(
// MD interface - serial configuration of PHY
inout                       md_io,
input                       mdc_i,

// MAC interface - packet to DUT
input                       mtx_clk_i,
output reg [3:0]            mtxd_o, 
output reg                  mtxdv_o,
output reg                  mtxerr_o,


// MAC interface - packet from DUT
input      [3:0]            mrxd_i, 
input                       mrxdv_i
);

`include "debug_functions.vh"
`include "system_functions.vh"

// mxt state machine
localparam IDLE = 4'd0;
localparam TX_0 = 4'd1;
localparam TX_1 = 4'd2;
localparam WAIT = 4'd3;
localparam PREA = 4'd4;
localparam PREB = 4'd5;
localparam GAP  = 4'd6;
localparam CRC0 = 4'd7;
localparam CRCN = 4'd8;
localparam POLL = 4'd9;


// rx state machine
localparam RX_IDLE = 4'd0;
localparam RX_0    = 4'd1;
localparam RX_1    = 4'd2;
localparam RX_PRE  = 4'd3;
localparam RX_DONE = 4'd4;


// md state machine
localparam MD_REGADDR = 4'd0;
localparam MD_PHYADDR = 4'd1;
localparam MD_WRITE0  = 4'd2;
localparam MD_READ0   = 4'd3;
localparam MD_START1  = 4'd4;
localparam MD_START0  = 4'd5;
localparam MD_IDLE    = 4'd6;
localparam MD_TURN0   = 4'd7;
localparam MD_TURN1   = 4'd8;
localparam MD_RDATA   = 4'd9;
localparam MD_WDATA   = 4'd10;
localparam MD_WXFR    = 4'd11;

localparam MDREAD  = 1'd0;
localparam MDWRITE = 1'd1;


// MD register addresses        
localparam MII_BMCR     = 5'd0;        /* Basic mode control register */
localparam MII_BMSR     = 5'd1;        /* Basic mode status register  */
localparam MII_CTRL1000 = 5'd9;        /* 1000BASE-T control          */


reg [7:0]   mem [2**16-1:0];
reg [7:0]   eth [13:0];

reg [7:0]   rxm [2047:0];

reg [15:0]  line_r  = 16'd0;
reg [15:0]  rx_line_r;

reg [3:0]   state_r = IDLE;
reg [3:0]   md_state_r = MD_IDLE;
reg [3:0]   rx_state_r = RX_IDLE;
reg [15:0]  pkt_len_r;
reg [31:0]  wcount_r;
reg [15:0]  pkt_pos_r;
reg [3:0]   pcount_r;

reg         md_op_r = MDREAD;
reg [4:0]   md_count_r;
reg [4:0]   md_phy_addr_r;
reg [4:0]   md_reg_addr_r;
reg [15:0]  md_rdata_r;
reg [15:0]  md_wdata_r;
reg [15:0]  md_bmcr_r = 'd0;
reg [15:0]  md_ctrl1000_r = 16'hffff;
wire        init;
wire [31:0] crc;
wire [3:0]  crc_dinx;                                 
reg  [3:0]  crc_din;
wire        enable;
reg  [3:0]  mrxd_r;

reg  [7:0]  last_pkt_num_r = 'd0;


integer             pkt_to_amber_file;
integer             pkt_to_amber_ack_file;
integer             pkt_from_amber_file;

reg [8*20-1:0]      pkt_to_amber     = "pkt_to_amber.mem";
reg [8*20-1:0]      pkt_to_amber_ack = "pkt_to_amber_ack.txt";
reg [8*20-1:0]      pkt_from_amber   = "pkt_from_amber.mem";

reg     [4*8-1:0]   line;
integer             fgets_return;
integer             pkt_to_amber_address;
reg [7:0]           pkt_to_amber_data;

integer             x;
reg [7:0]           pkt_from_amber_num = 8'd1;


// initializwe the ack file to 0
// this allows sim_socket to write the first packet
initial
    begin
    pkt_to_amber_ack_file = $fopen(pkt_to_amber_ack, "w");
    $fwrite(pkt_to_amber_ack_file, "0\n");
    $fclose(pkt_to_amber_ack_file);
    end
    
    
// ============================
// packet tx state machine
// ============================
always@(posedge mtx_clk_i)
    begin
    case (state_r)
        IDLE:
            begin
            mtxd_o    <= 'd0;
            mtxdv_o   <= 'd0;
            mtxerr_o  <= 'd0;
            wcount_r  <= 'd0;
            
            if (md_bmcr_r[9])  // autoneg bit set by software
                begin
                wcount_r  <= wcount_r + 1'd1;
                if (wcount_r == 32'd10000)
                    begin
                    state_r   <= POLL;
                    wcount_r  <= 'd0;
                    $display("Start polling for packets to send to amber");
                    end
                end
            end

        
        
        WAIT:
            begin
            wcount_r <= wcount_r + 1'd1;
            if (wcount_r == 32'd100)
                begin
                wcount_r <= 'd0;
                state_r  <= POLL;
                end
            end

        
        POLL: // scan for new packets
            begin
            mtxd_o    <= 'd0;
            mtxdv_o   <= 'd0;
            mtxerr_o  <= 'd0;
            
            
            pkt_to_amber_file               = $fopen(pkt_to_amber, "r");            
            fgets_return                    = $fgets(line, pkt_to_amber_file);
            pkt_to_amber_address = 0;
            while (fgets_return)
                begin
                pkt_to_amber_data           = hex_chars_to_8bits (line[23:8]);
                mem[pkt_to_amber_address]   = pkt_to_amber_data[7:0];
                pkt_to_amber_address        = pkt_to_amber_address + 1;
                fgets_return                = $fgets(line, pkt_to_amber_file);                
                end
            $fclose(pkt_to_amber_file);

            
            if (mem[0] != last_pkt_num_r) 
                begin
                state_r         <= PREA;
                pkt_len_r       <= {mem[1], mem[2]} + 16'd14;
                last_pkt_num_r  <= mem[0];
                line_r          <= 'd0;
                pkt_pos_r       <= 'd0;
                pcount_r        <= 'd0;
                wcount_r        <= 'd0;
    
                pkt_to_amber_ack_file = $fopen(pkt_to_amber_ack, "w");
                $fwrite(pkt_to_amber_ack_file, "%d\n", mem[0]);
                $fclose(pkt_to_amber_ack_file);
                end
            else begin
                state_r   <= WAIT;
                end
                
            end
                        
        
        
        PREA: // Preamble
            begin
            mtxd_o    <= 4'b0101;
            mtxdv_o   <= 1'd1;
            pcount_r  <= pcount_r + 1'd1;
            if (pcount_r == 4'd6)
                begin
                pcount_r  <= 'd0;
                state_r   <= PREB;            
                end
            end
            
            
        PREB:
            begin
            mtxd_o    <= 4'b1101;
            mtxdv_o   <= 1'd1;
            state_r   <= TX_0;
            
            print_pkt(1'd1, line_r);  
            end 
            
                           
        TX_0:  // low 4 bits
            begin
            mtxd_o    <= mem[line_r+3][3:0];
            mtxdv_o   <= 1'd1;
            state_r   <= TX_1;
            end
            
            
        TX_1:  // high 4 bits
            begin
            mtxd_o    <= mem[line_r+3][7:4];
            mtxdv_o   <= 1'd1;
            line_r    <= line_r + 1'd1;
            
            if (pkt_pos_r + 1'd1 == pkt_len_r)
                state_r     <= CRC0;
            else
                begin
                state_r     <= TX_0;
                pkt_pos_r   <= pkt_pos_r + 1'd1;
                end
            end

                        
        CRC0:
            begin
            mtxd_o    <= {~crc[28], ~crc[29], ~crc[30], ~crc[31]};
            mtxdv_o   <= 1'd1;
            state_r   <= POLL;
            end
            
    endcase
    end
            


assign init    = state_r == PREB;
assign enable  = state_r != CRC0;

always @*
    begin
        crc_din = state_r == TX_0 ? mem[line_r+3][3:0] : 
                  state_r == TX_1 ? mem[line_r+3][7:4] :
                                   32'd0               ;
    end
    
                                       
assign crc_dinx = {crc_din[0], crc_din[1], crc_din[2], crc_din[3]};


// Gen CRC, using the EthMac CRC generator
eth_crc eth_crc (
    .Clk        ( mtx_clk_i ),
    .Reset      ( 1'd0      ),
    .Data       ( crc_dinx  ),
    .Enable     ( enable    ),
    .Initialize ( init      ),

    .Crc        ( crc       ),
    .CrcError   (           )
);


// ============================
// packet rx state machine
// ============================
always@(posedge mtx_clk_i)
    begin
    case (rx_state_r)
        RX_IDLE:
            begin  
            rx_line_r  <= 'd0;       
            if (mrxdv_i)  // autoneg bit set by software
                begin
                rx_state_r   <= RX_PRE;
                end
            end
                       
        RX_PRE:
            begin
            if (mrxd_i == 4'hd)
                rx_state_r   <= RX_0;
            end
                               
        RX_0:  // low 4 bits
            begin
            mrxd_r <= mrxd_i;
            
            if (mrxdv_i)
                rx_state_r     <= RX_1;
            else
                rx_state_r     <= RX_DONE;
            end
            
            
        RX_1:  // high 4 bits
            begin
            rxm[rx_line_r]      <= {mrxd_i, mrxd_r};
            rx_line_r           <= rx_line_r + 1'd1;
            
            if (mrxdv_i)
                rx_state_r     <= RX_0;
            else
                rx_state_r     <= RX_DONE;
            end


        RX_DONE: 
            begin
            print_pkt(1'd0, 16'd0);  
            rx_state_r     <= RX_IDLE;
            
                
            pkt_from_amber_file     = $fopen(pkt_from_amber, "w");
            $fwrite(pkt_from_amber_file, "%02h\n", pkt_from_amber_num);
            
            for (x=0;x<rx_line_r;x=x+1)
                $fwrite(pkt_from_amber_file, "%02h\n", rxm[x]);
            $fclose(pkt_from_amber_file);
            
            
            if (pkt_from_amber_num == 8'd255)
                pkt_from_amber_num  <= 8'd1; 
            else
                pkt_from_amber_num  <=  pkt_from_amber_num + 1'd1; 
            end
            
            
    endcase
    end




// ============================
// management data state machine
// ============================
always@(posedge mdc_i)
    begin
    case (md_state_r)
    
        MD_IDLE:
            begin
            md_count_r <= 'd0;
            if (md_io == 1'd0)
                md_state_r   <= MD_START0;
            end
            
            
        MD_START0:
            begin
            if (md_io == 1'd1)
                md_state_r   <= MD_START1;
            else
                md_state_r   <= MD_IDLE;
            end
            
            
        MD_START1:
            begin
            if (md_io == 1'd1)
                md_state_r  <= MD_READ0;
            else
                md_state_r  <= MD_WRITE0;
            end
            
            
       MD_READ0:
            begin
            if (md_io == 1'd0)
                begin
                md_state_r  <= MD_PHYADDR;
                md_op_r     <= MDREAD;
                end
            else
                md_state_r  <= MD_IDLE;
            end 
            
            
       MD_WRITE0:
            begin
            if (md_io == 1'd1)
                begin
                md_state_r  <= MD_PHYADDR;
                md_op_r     <= MDWRITE;
                end
            else
                md_state_r  <= MD_IDLE;
            end 
            
        MD_PHYADDR:
            begin
            md_count_r      <= md_count_r + 1'd1;
            md_phy_addr_r   <= {md_phy_addr_r[3:0], md_io};
            
            if (md_count_r == 5'd4)
                begin
                md_state_r  <= MD_REGADDR;
                md_count_r  <= 'd0;                
                end
            end
            
        MD_REGADDR:
            begin
            md_count_r      <= md_count_r + 1'd1;
            md_reg_addr_r   <= {md_reg_addr_r[3:0], md_io};
            
            if (md_count_r == 5'd4)
                begin
                md_count_r  <= 'd0;                
                md_state_r  <= MD_TURN0;
                end
            end


        MD_TURN0:
            md_state_r  <= MD_TURN1;

        MD_TURN1:
            begin
            if (md_op_r == MDREAD)
                md_state_r  <= MD_RDATA;
            else    
                md_state_r  <= MD_WDATA;
                
            case (md_reg_addr_r)
                MII_BMCR        : md_rdata_r <= md_bmcr_r;
                MII_BMSR        : md_rdata_r <= 16'hfe04;
                MII_CTRL1000    : md_rdata_r <= md_ctrl1000_r;
                default         : md_rdata_r <= 'd0;   
            endcase
            end
            
            
        MD_RDATA:
            begin
            md_count_r  <= md_count_r + 1'd1;
            md_rdata_r  <= {md_rdata_r[14:0], 1'd0};
            
            if (md_count_r == 5'd15)
                md_state_r  <= MD_IDLE;
            
            end


        MD_WDATA:
            begin
            md_count_r  <= md_count_r + 1'd1;
            md_wdata_r  <= {md_wdata_r[14:0], md_io};
            
            if (md_count_r == 5'd15)
                begin
                md_state_r  <= MD_WXFR;
                md_count_r  <= 'd0;                
                end
            end


        MD_WXFR:
            begin
            case (md_reg_addr_r)
                MII_BMCR        : md_bmcr_r     <= md_wdata_r;
                MII_CTRL1000    : md_ctrl1000_r <= md_wdata_r;
            endcase
            md_state_r  <= MD_IDLE;
            end
            
            
    endcase
    end


assign md_io = md_state_r == MD_RDATA ? md_rdata_r[15] : 1'bz;



task print_pkt;
input        tx;   /* 1 for tx, 0 for rx */
input [31:0] start;
reg   [15:0] eth_type;
reg   [7:0]  proto;
reg   [31:0] frame;
reg   [3:0]  ip_hdr_len;
reg   [15:0] ip_len;
reg   [3:0]  tcp_hdr_len;
reg   [15:0] tcp_bdy_len;
reg   [7:0]  tmp;
reg   [15:0] arp_op;

integer      i;
begin
    frame = start;
    
    if (tx) $write("%6d pkt to   amber ", tb.clk_count);
    else    $write("%6d pkt from amber ", tb.clk_count);
    
    $display("mac-dst %h:%h:%h:%h:%h:%h, mac-src %h:%h:%h:%h:%h:%h, type %h%h", 
        rmem(tx,frame+0), rmem(tx,frame+1),rmem(tx,frame+2),rmem(tx,frame+3),rmem(tx,frame+4),rmem(tx,frame+5),
        rmem(tx,frame+6), rmem(tx,frame+7),rmem(tx,frame+8),rmem(tx,frame+9),rmem(tx,frame+10),rmem(tx,frame+11),
        rmem(tx,frame+12),rmem(tx,frame+13));
        
    eth_type = {rmem(tx,frame+12),rmem(tx,frame+13)};

    if (eth_type == 16'h0806) // arp
        begin
        frame       = frame + 14;
        arp_op      = rmem(tx,frame+6) << 8 | rmem(tx,frame+7);
        
        $write("ARP operation %0d", arp_op);
      
        if (arp_op == 16'd1)
            $write(" look for ip %0d.%0d.%0d.%0d", 
                rmem(tx,frame+24), rmem(tx,frame+25),rmem(tx,frame+26),rmem(tx,frame+27));  
        $write("\n");      
        end
    
    if (eth_type == 16'h0800) // ip
        begin
        frame       = frame + 14;
        proto       = rmem(tx,frame+9);
        tmp         = rmem(tx,frame+0);
        ip_hdr_len  = tmp[3:0];
        ip_len      = {rmem(tx,frame+2), rmem(tx,frame+3)};
        
        $display("   ip-dst %0d.%0d.%0d.%0d, ip-src %0d.%0d.%0d.%0d, proto %0d, ip_len %0d, ihl %0d", 
            rmem(tx,frame+16), rmem(tx,frame+17),rmem(tx,frame+18),rmem(tx,frame+19),
            rmem(tx,frame+12), rmem(tx,frame+13),rmem(tx,frame+14),rmem(tx,frame+15), 
            proto, ip_len, ip_hdr_len*4);
        
        if (proto == 8'd6) // TCP
            begin
            frame       = frame + ip_hdr_len*4;
            tmp         = rmem(tx,frame+12);
            tcp_hdr_len = tmp[7:4];
            tcp_bdy_len = ip_len - ({ip_hdr_len,2'd0} + {tcp_hdr_len,2'd0});
            
            $display("   tcp-dst %0d, tcp-src %0d, tcp hdr len %0d, tcp bdy len %0d", 
                {rmem(tx,frame+2), rmem(tx,frame+3)},
                {rmem(tx,frame+0), rmem(tx,frame+1)}, tcp_hdr_len*4, tcp_bdy_len);
            $display("   tcp-seq %0d, tcp-ack %0d", 
                {rmem(tx,frame+4), rmem(tx,frame+5), rmem(tx,frame+6), rmem(tx,frame+7)},
                {rmem(tx,frame+8), rmem(tx,frame+9), rmem(tx,frame+10), rmem(tx,frame+11)});
                
            if (tcp_bdy_len != 16'd0)
                begin
                for (i=0;i<tcp_bdy_len;i=i+1)
                    if ((rmem(tx,frame+tcp_hdr_len*4+i) > 31 && rmem(tx,frame+tcp_hdr_len*4+i) < 128) ||
                        (rmem(tx,frame+tcp_hdr_len*4+i) == "\n"))
                        $write("%c",  rmem(tx,frame+tcp_hdr_len*4+i));
                end
                
            end
        end
    $display("----");
end
endtask


function [7:0] rmem;
input        tx;   /* 1 for tx, 0 for rx */
input [31:0] addr;
begin
    if (tx)
        rmem = mem[addr+3];
    else
        rmem = rxm[addr];
end
endfunction


wire [8*6-1:0] XSTATE = 
    state_r == IDLE ? "IDLE"    :
    state_r == WAIT ? "WAIT"    :
    state_r == TX_0 ? "TX_0"    :
    state_r == TX_1 ? "TX_1"    :
    state_r == PREA ? "PREA"    :
    state_r == PREB ? "PREB"    :
    state_r == GAP  ? "GAP"     :
    state_r == CRC0 ? "CRC0"    :
    state_r == CRCN ? "CRCN"    :
    state_r == POLL ? "POLL"    :
                      "UNKNOWN" ;

wire [8*12-1:0] XRXSTATE = 
    state_r == RX_IDLE  ? "RX_IDLE" :
    state_r == RX_0     ? "RX_0"    :
    state_r == RX_1     ? "RX_1"    :
    state_r == RX_PRE   ? "RX_PRE"  :
    state_r == RX_DONE  ? "RX_DONE" :
                          "UNKNOWN" ;

wire [8*12-1:0] XMDSTATE =
    md_state_r == MD_WXFR    ?  "MD_WXFR"    :
    md_state_r == MD_WDATA   ?  "MD_WDATA"   :
    md_state_r == MD_RDATA   ?  "MD_RDATA"   :
    md_state_r == MD_TURN1   ?  "MD_TURN1"   :
    md_state_r == MD_TURN0   ?  "MD_TURN0"   :
    md_state_r == MD_REGADDR ?  "MD_REGADDR" :
    md_state_r == MD_PHYADDR ?  "MD_PHYADDR" :
    md_state_r == MD_WRITE0  ?  "MD_WRITE0"  :
    md_state_r == MD_READ0   ?  "MD_READ0"   :
    md_state_r == MD_START1  ?  "MD_START1"  :
    md_state_r == MD_START0  ?  "MD_START0"  :
    md_state_r == MD_IDLE    ?  "MD_IDLE"    :
                                "UNKNOWN"    ;

endmodule


