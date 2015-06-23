//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: USB device core (top)
//-----------------------------------------------------------------
module usbf_device
(
    // Clocking (48MHz) & Reset
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Interrupt output
    output              intr_o /*verilator public*/,
    
    // Peripheral Interface (from CPU)
    input [7:0]         addr_i /*verilator public*/,
    input [31:0]        data_i /*verilator public*/,
    output [31:0]       data_o /*verilator public*/,
    input               we_i /*verilator public*/,
    input               stb_i /*verilator public*/,

    // USB Transceiver Interface
    output              usb_vmo_o /*verilator public*/,
    output              usb_vpo_o /*verilator public*/,
    output              usb_oe_o /*verilator public*/,
    input               usb_rx_i /*verilator public*/,
    input               usb_vp_i /*verilator public*/,
    input               usb_vm_i /*verilator public*/,
    output              usb_speed_o /*verilator public*/,
    output              usb_susp_o /*verilator public*/,
    output              usb_mode_o /*verilator public*/,
    output              usb_en_o /*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [7:0]              utmi_data_w;
wire [7:0]              utmi_data_r;
wire                    utmi_txvalid;
wire                    utmi_txready;
wire                    utmi_rxvalid;
wire                    utmi_rxactive;
wire                    utmi_rxerror;
wire [1:0]              utmi_linestate;

wire                    usb_oen;
wire                    usb_tx_p;
wire                    usb_tx_n;
wire                    usb_rx_p;
wire                    usb_rx_n;
wire                    usb_rx;
wire                    usb_rst;

wire                    nrst;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------
usbf_sie
usb
(
    // Clocking (48MHz) & Reset
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Interrupt output
    .intr_o(intr_o),
    
    // Peripheral Interface (from CPU)
    .addr_i(addr_i),
    .data_i(data_i),
    .data_o(data_o),
    .we_i(we_i),
    .stb_i(stb_i),

    // UTMI interface
    .utmi_rst_i(usb_rst),
    .utmi_data_w(utmi_data_w),
    .utmi_data_r(utmi_data_r),
    .utmi_txvalid_o(utmi_txvalid),
    .utmi_txready_i(utmi_txready),
    .utmi_rxvalid_i(utmi_rxvalid),
    .utmi_rxactive_i(utmi_rxactive),
    .utmi_rxerror_i(utmi_rxerror),
    .utmi_linestate_i(utmi_linestate),

    // Pull-up enable
    .usb_en_o(usb_en_o)    
);

// USB-PHY module (UTMI->PHY interface)
usb_phy
u_phy
(
    // Clock (48MHz) & reset
    .clk(clk_i),
    .rst(nrst),

    // PHY Transmit Mode:
    // When phy_tx_mode_i is '0' the outputs are encoded as:
    //  TX- TX+
    //      0    0    Differential Logic '0'
    //      0    1    Differential Logic '1'
    //      1    0    Single Ended '0'
    //      1    1    Single Ended '0'
    // When phy_tx_mode_i is '1' the outputs are encoded as:
    //  TX- TX+
    //      0    0    Single Ended '0'
    //      0    1    Differential Logic '1'
    //      1    0    Differential Logic '0'
    //      1    1    Illegal State
    .phy_tx_mode_i(1'b0),

    // USB bus reset event
    .usb_rst_o(usb_rst),
    .usb_rst_i(1'b0),

    // Transciever Interface
    // Tx +/-
    .tx_dp_o(usb_tx_p),
    .tx_dn_o(usb_tx_n),

    // Tx output enable (active low)
    .tx_oen_o(usb_oen),

    // Receive data
    .rx_rcv_i(usb_rx),

    // Rx +/-
    .rx_dp_i(usb_rx_p),
    .rx_dn_i(usb_rx_n),

    // UTMI Interface

    // Transmit data [7:0]
    .utmi_data_i(utmi_data_w),

    // Transmit data enable
    .utmi_txvalid_i(utmi_txvalid),

    // Transmit ready (L=hold,H=load data)
    .utmi_txready_o(utmi_txready),

    // Receive data [7:0]
    .utmi_data_o(utmi_data_r),

    // Valid data on utmi_data_o
    .utmi_rxvalid_o(utmi_rxvalid),

    // Receive active (SYNC recieved)
    .utmi_rxactive_o(utmi_rxactive),

    // Rx error occurred
    .utmi_rxerror_o(utmi_rxerror),

    // Receive line state [1=RX-, 0=RX+]
    .utmi_linestate_o(utmi_linestate)
);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign usb_rx       = usb_rx_i;
assign usb_rx_p     = usb_vp_i;
assign usb_rx_n     = usb_vm_i;
assign usb_vpo_o    = usb_tx_p;
assign usb_vmo_o    = usb_tx_n;
assign usb_oe_o     = usb_oen;

assign usb_mode_o   = 1'b0;
assign usb_speed_o  = 1'b1;
assign usb_susp_o   = 1'b0;

assign nrst         = !rst_i;

endmodule
