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
//              !!!! This file is auto generated !!!!
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: Simplified USB device serial interface engine
//-----------------------------------------------------------------
module usbf_sie
(
    // Clocking (48MHz) & Reset
    input  wire           clk_i /*verilator public*/,
    input  wire           rst_i /*verilator public*/,

    // Interrupt output
    output reg            intr_o /*verilator public*/,

    // Peripheral Interface
    input  wire [7:0]     addr_i /*verilator public*/,
    input  wire [31:0]    data_i /*verilator public*/,
    output reg [31:0]     data_o /*verilator public*/,
    input  wire           we_i /*verilator public*/,
    input  wire           stb_i /*verilator public*/,

    // UTMI interface
    input  wire           utmi_rst_i /*verilator public*/,
    output wire [7:0]     utmi_data_w /*verilator public*/,
    input  wire [7:0]     utmi_data_r /*verilator public*/,
    output reg            utmi_txvalid_o /*verilator public*/,
    input  wire           utmi_txready_i /*verilator public*/,
    input  wire           utmi_rxvalid_i /*verilator public*/,
    input  wire           utmi_rxactive_i /*verilator public*/,
    input  wire           utmi_rxerror_i /*verilator public*/,
    input  wire [1:0]     utmi_linestate_i /*verilator public*/,

    // Pull-up enable
    output reg            usb_en_o /*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// Current state
parameter STATE_RX_IDLE                 = 4'b0000;
parameter STATE_RX_TOKEN2               = 4'b0001;
parameter STATE_RX_TOKEN3               = 4'b0010;
parameter STATE_RX_TOKEN_COMPLETE       = 4'b0011;
parameter STATE_RX_SOF2                 = 4'b0100;
parameter STATE_RX_SOF3                 = 4'b0101;
parameter STATE_RX_DATA                 = 4'b0110;
parameter STATE_RX_DATA_IGNORE          = 4'b0111;
parameter STATE_RX_DATA_COMPLETE        = 4'b1000;
parameter STATE_TX_DATA                 = 4'b1001;
parameter STATE_TX_CRC                  = 4'b1010;
parameter STATE_TX_CRC1                 = 4'b1011;
parameter STATE_TX_CRC2                 = 4'b1100;
parameter STATE_TX_ACK                  = 4'b1101;
parameter STATE_TX_NAK                  = 4'b1110;
parameter STATE_TX_STALL                = 4'b1111;
reg [3:0] usb_state;

reg  [7:0]                utmi_txdata;

// CRC16
reg [15:0]                crc_sum;
wire [15:0]               crc_out;
wire [7:0]                crc_data_in;

// Others
reg [6:0]                 usb_this_device;
reg [6:0]                 usb_next_address;
reg                       usb_address_pending;
reg                       usb_event_bus_reset;

// Interrupt enables
reg                       usb_int_en_tx;
reg                       usb_int_en_rx;
reg                       usb_int_en_sof;

// Incoming request type
reg                       usb_rx_pid_out;
reg                       usb_rx_pid_in;
reg                       usb_rx_pid_setup;

// Request details
reg [10:0]                usb_frame_number;
reg [6:0]                 usb_address;
reg [2-1:0]               usb_endpoint;

// Request action
reg                       usb_rx_accept_data;
reg                       usb_rx_send_nak;
reg                       usb_rx_send_stall;

// Transmit details
reg [7:0] usb_tx_idx;

// Endpoint state
reg                       usb_ep_tx_pend[3:0];
reg                       usb_ep_tx_data1[3:0];
reg [7:0]                 usb_ep_tx_count[3:0];
reg                       usb_ep_stall[3:0];
reg                       usb_ep_iso[3:0];

reg [7:0]                 usb_rx_count;

reg                       usb_ep0_rx_setup;

reg                       usb_ep_full[3:0];
reg [7:0]                 usb_ep_rx_count[3:0];
reg                       usb_ep_crc_err[3:0];

// Endpoint receive FIFO (Host -> Device)
reg                       usb_fifo_rd_push[3:0];
reg                       usb_fifo_rd_flush[3:0];
reg                       usb_fifo_rd_pop[3:0];
reg [7:0]                 usb_fifo_rd_in;
wire [7:0]                usb_fifo_rd_out[3:0];

// Endpoint transmit FIFO (Device -> Host)
reg                       usb_fifo_wr_push[3:0];
reg                       usb_fifo_wr_pop[3:0];
reg                       usb_fifo_wr_flush[3:0];
reg [7:0]                 usb_fifo_wr_data[3:0];
wire [7:0]                usb_fifo_wr_out[3:0];
reg [7:0]                 usb_write_data;

wire new_data_ready       = utmi_rxvalid_i & utmi_rxactive_i;

//-----------------------------------------------------------------
// Peripheral Memory Map
//-----------------------------------------------------------------
`define USB_FUNC_CTRL              8'd0
`define USB_FUNC_STAT              8'd0
`define USB_FUNC_EP0            8'd4
`define USB_FUNC_EP0_DATA       8'd32
`define USB_FUNC_EP1            8'd8
`define USB_FUNC_EP1_DATA       8'd36
`define USB_FUNC_EP2            8'd12
`define USB_FUNC_EP2_DATA       8'd40
`define USB_FUNC_EP3            8'd16
`define USB_FUNC_EP3_DATA       8'd44

//-----------------------------------------------------------------
// Register Definitions
//-----------------------------------------------------------------
// USB_FUNC_CTRL
`define USB_FUNC_CTRL_ADDR         6:0
`define USB_FUNC_CTRL_ADDR_SET     8
`define USB_FUNC_CTRL_INT_EN_TX    9
`define USB_FUNC_CTRL_INT_EN_RX    10
`define USB_FUNC_CTRL_INT_EN_SOF   11
`define USB_FUNC_CTRL_PULLUP_EN    12

// USB_FUNC_STAT
`define USB_FUNC_STAT_FRAME        10:0
`define USB_FUNC_STAT_LS_RXP       16
`define USB_FUNC_STAT_LS_RXN       17
`define USB_FUNC_STAT_RST          18

// USB_FUNC_EPx
`define USB_EP_COUNT               7:0
`define USB_EP_TX_READY            16
`define USB_EP_RX_AVAIL            17
`define USB_EP_RX_ACK              18
`define USB_EP_RX_SETUP            18
`define USB_EP_RX_CRC_ERR          19
`define USB_EP_STALL               20
`define USB_EP_TX_FLUSH            21
`define USB_EP_ISO                 22

//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------

// Tokens
`define PID_OUT                    8'hE1
`define PID_IN                     8'h69
`define PID_SOF                    8'hA5
`define PID_SETUP                  8'h2D

// Data
`define PID_DATA0                  8'hC3
`define PID_DATA1                  8'h4B

// Handshake
`define PID_ACK                    8'hD2
`define PID_NAK                    8'h5A
`define PID_STALL                  8'h1E

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

// CRC16
usbf_crc16
u_crc16
(
    .crc_in(crc_sum),
    .din(crc_data_in),
    .crc_out(crc_out)
);

//-----------------------------------------------------------------
// Endpoint 0: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(8),
  .ADDR_W(3)
)
u_fifo_rx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[0]),

    .flush_i(usb_fifo_rd_flush[0]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[0]),
    .pop_i(usb_fifo_rd_pop[0])
);

//-----------------------------------------------------------------
// Endpoint 0: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(8),
  .ADDR_W(3)
)
u_fifo_tx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[0]),
    .push_i(usb_fifo_wr_push[0]),

    .flush_i(usb_fifo_wr_flush[0]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[0]),
    .pop_i(usb_fifo_wr_pop[0])
);
//-----------------------------------------------------------------
// Endpoint 1: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[1]),

    .flush_i(usb_fifo_rd_flush[1]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[1]),
    .pop_i(usb_fifo_rd_pop[1])
);

//-----------------------------------------------------------------
// Endpoint 1: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[1]),
    .push_i(usb_fifo_wr_push[1]),

    .flush_i(usb_fifo_wr_flush[1]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[1]),
    .pop_i(usb_fifo_wr_pop[1])
);
//-----------------------------------------------------------------
// Endpoint 2: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[2]),

    .flush_i(usb_fifo_rd_flush[2]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[2]),
    .pop_i(usb_fifo_rd_pop[2])
);

//-----------------------------------------------------------------
// Endpoint 2: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[2]),
    .push_i(usb_fifo_wr_push[2]),

    .flush_i(usb_fifo_wr_flush[2]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[2]),
    .pop_i(usb_fifo_wr_pop[2])
);
//-----------------------------------------------------------------
// Endpoint 3: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[3]),

    .flush_i(usb_fifo_rd_flush[3]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[3]),
    .pop_i(usb_fifo_rd_pop[3])
);

//-----------------------------------------------------------------
// Endpoint 3: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[3]),
    .push_i(usb_fifo_wr_push[3]),

    .flush_i(usb_fifo_wr_flush[3]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[3]),
    .pop_i(usb_fifo_wr_pop[3])
);

//-----------------------------------------------------------------
// Next state
//-----------------------------------------------------------------
reg [3:0] next_state_r;

always @ *
begin
    next_state_r = usb_state;

    //-----------------------------------------
    // State Machine
    //-----------------------------------------
    case (usb_state)

        //-----------------------------------------
        // IDLE
        //-----------------------------------------
        STATE_RX_IDLE :
        begin
           if (new_data_ready)
           begin
               // Decode PID
               case (utmi_data_r)

                  `PID_OUT, `PID_IN, `PID_SETUP:
                        next_state_r  = STATE_RX_TOKEN2;

                  `PID_SOF:
                        next_state_r  = STATE_RX_SOF2;

                  `PID_DATA0, `PID_DATA1:
                  begin
                        if (usb_rx_accept_data && !usb_rx_send_stall)
                            next_state_r  = STATE_RX_DATA;
                        else
                            next_state_r  = STATE_RX_DATA_IGNORE;
                  end

                  `PID_ACK, `PID_NAK, `PID_STALL:
                        next_state_r  = STATE_RX_IDLE;

                  default :
                    ;
               endcase
           end
        end

        //-----------------------------------------
        // SOF (BYTE 2)
        //-----------------------------------------
        STATE_RX_SOF2 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_SOF3;
        end

        //-----------------------------------------
        // SOF (BYTE 3)
        //-----------------------------------------
        STATE_RX_SOF3 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_IDLE;
        end

        //-----------------------------------------
        // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
        //-----------------------------------------
        STATE_RX_TOKEN2 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_TOKEN3;
        end

        //-----------------------------------------
        // TOKEN (IN/OUT/SETUP) (Endpoint/CRC)
        //-----------------------------------------
        STATE_RX_TOKEN3 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_TOKEN_COMPLETE;
        end

        //-----------------------------------------
        // RX_TOKEN_COMPLETE
        //-----------------------------------------
        STATE_RX_TOKEN_COMPLETE :
        begin
            next_state_r  = STATE_RX_IDLE;

            // Addressed to this device?
            if (usb_address == usb_this_device)
            begin
                //-------------------------------
                // IN transfer (device -> host)
                //-------------------------------
                if (usb_rx_pid_in)
                begin
                    // Stalled endpoint?
                    if (usb_ep_stall[usb_endpoint])
                        next_state_r  = STATE_TX_STALL;
                    // Some data to TX?
                    else if (usb_ep_tx_pend[usb_endpoint])
                        next_state_r  = STATE_TX_DATA;
                    // No data to TX
                    else
                        next_state_r  = STATE_TX_NAK;
                end
            end
        end

        //-----------------------------------------
        // RX_DATA
        //-----------------------------------------
        STATE_RX_DATA :
        begin
           // Receive complete
           if (utmi_rxactive_i == 1'b0)
                next_state_r = STATE_RX_DATA_COMPLETE;
        end

        //-----------------------------------------
        // RX_DATA_IGNORE
        //-----------------------------------------
        STATE_RX_DATA_IGNORE :
        begin
           // Receive complete
           if (utmi_rxactive_i == 1'b0)
           begin
                // ISO endpoint?
                if (usb_ep_iso[usb_endpoint])
                    next_state_r  = STATE_RX_IDLE;
                // Send STALL?
                else if (usb_rx_send_stall)
                    next_state_r  = STATE_TX_STALL;
                // Send NAK
                else if (usb_rx_send_nak)
                    next_state_r  = STATE_TX_NAK;
                else
                    next_state_r  = STATE_RX_IDLE;
           end
        end

        //-----------------------------------------
        // RX_DATA_COMPLETE
        //-----------------------------------------
        STATE_RX_DATA_COMPLETE :
        begin
            // Check for CRC error on receive data
            if (crc_sum != 16'hB001)
                next_state_r = STATE_RX_IDLE;
            // Good CRC
            else
            begin
                // ISO endpoint?
                if (usb_ep_iso[usb_endpoint])
                    next_state_r = STATE_RX_IDLE;
                // Non-ISO, send ACK
                else
                    next_state_r = STATE_TX_ACK;
            end
        end

        //-----------------------------------------
        // TX_ACK/NAK/STALL
        //-----------------------------------------
        STATE_TX_ACK, STATE_TX_NAK, STATE_TX_STALL :
        begin
            // Data sent?
            if (utmi_txready_i)
               next_state_r = STATE_RX_IDLE;
        end

        //-----------------------------------------
        // TX_DATA
        //-----------------------------------------
        STATE_TX_DATA :
        begin
            // Data sent?
            if (utmi_txready_i)
            begin
                // Generate CRC16 at end of packet
                if (usb_tx_idx == usb_ep_tx_count[usb_endpoint])
                    next_state_r  = STATE_TX_CRC;
            end
        end

        //-----------------------------------------
        // TX_CRC (generate)
        //-----------------------------------------
        STATE_TX_CRC :
            next_state_r  = STATE_TX_CRC1;

        //-----------------------------------------
        // TX_CRC1 (first byte)
        //-----------------------------------------
        STATE_TX_CRC1 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r  = STATE_TX_CRC2;
        end

        //-----------------------------------------
        // TX_CRC (second byte)
        //-----------------------------------------
        STATE_TX_CRC2 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r  = STATE_RX_IDLE;
        end

        default :
           ;

    endcase

    //-----------------------------------------
    // USB Bus Reset (HOST->DEVICE)
    //----------------------------------------- 
    if (utmi_rst_i)
        next_state_r  = STATE_RX_IDLE;
end

// Update state
always @ (posedge rst_i or posedge clk_i)
begin
   if (rst_i == 1'b1)
        usb_state   <= STATE_RX_IDLE;
   else
        usb_state   <= next_state_r;
end

//-----------------------------------------------------------------
// Tx
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        utmi_txvalid_o      <= 1'b0;
        utmi_txdata         <= 8'h00;

        usb_tx_idx          <= 8'b0;

        usb_ep_tx_pend[0]   <= 1'b0;
        usb_ep_tx_data1[0]  <= 1'b0;
        usb_ep_tx_count[0]  <= 8'b0;
        usb_fifo_wr_pop[0]  <= 1'b0;
        usb_fifo_wr_push[0] <= 1'b0;
        usb_fifo_wr_data[0] <= 8'h00;
        usb_fifo_wr_flush[0]<= 1'b0;
        usb_ep_tx_pend[1]   <= 1'b0;
        usb_ep_tx_data1[1]  <= 1'b0;
        usb_ep_tx_count[1]  <= 8'b0;
        usb_fifo_wr_pop[1]  <= 1'b0;
        usb_fifo_wr_push[1] <= 1'b0;
        usb_fifo_wr_data[1] <= 8'h00;
        usb_fifo_wr_flush[1]<= 1'b0;
        usb_ep_tx_pend[2]   <= 1'b0;
        usb_ep_tx_data1[2]  <= 1'b0;
        usb_ep_tx_count[2]  <= 8'b0;
        usb_fifo_wr_pop[2]  <= 1'b0;
        usb_fifo_wr_push[2] <= 1'b0;
        usb_fifo_wr_data[2] <= 8'h00;
        usb_fifo_wr_flush[2]<= 1'b0;
        usb_ep_tx_pend[3]   <= 1'b0;
        usb_ep_tx_data1[3]  <= 1'b0;
        usb_ep_tx_count[3]  <= 8'b0;
        usb_fifo_wr_pop[3]  <= 1'b0;
        usb_fifo_wr_push[3] <= 1'b0;
        usb_fifo_wr_data[3] <= 8'h00;
        usb_fifo_wr_flush[3]<= 1'b0;
   end
   else
   begin
        usb_fifo_wr_pop[0]   <= 1'b0;
        usb_fifo_wr_push[0]  <= 1'b0;
        usb_fifo_wr_flush[0] <= 1'b0;
        usb_fifo_wr_pop[1]   <= 1'b0;
        usb_fifo_wr_push[1]  <= 1'b0;
        usb_fifo_wr_flush[1] <= 1'b0;
        usb_fifo_wr_pop[2]   <= 1'b0;
        usb_fifo_wr_push[2]  <= 1'b0;
        usb_fifo_wr_flush[2] <= 1'b0;
        usb_fifo_wr_pop[3]   <= 1'b0;
        usb_fifo_wr_push[3]  <= 1'b0;
        usb_fifo_wr_flush[3] <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   usb_tx_idx <= 8'b0;

                   // Decode PID
                   case (utmi_data_r)
                      `PID_SETUP:
                      begin
                            // Send DATA1 when responding to SETUP
                            usb_ep_tx_data1[0]  <= 1'b1;
                      end

                      default :
                          ;
                   endcase
               end
            end

            //-----------------------------------------
            // TX_ACK
            //-----------------------------------------
            STATE_TX_ACK :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_ACK;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_NAK
            //-----------------------------------------
            STATE_TX_NAK :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_NAK;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_STALL
            //-----------------------------------------
            STATE_TX_STALL :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_STALL;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_DATA
            //-----------------------------------------
            STATE_TX_DATA :
            begin
                // Tx active
                utmi_txvalid_o    <= 1'b1;

                // Send PID (first byte - DATA0 or DATA1)
                if (usb_tx_idx == 8'b0)
                begin
                    if (usb_ep_tx_data1[usb_endpoint])
                        utmi_txdata     <= `PID_DATA1;
                    else
                        utmi_txdata     <= `PID_DATA0;
                end
                // Data to send
                else
                    utmi_txdata     <= usb_write_data;

                // Data sent?
                if (utmi_txready_i)
                begin
                   // First byte is PID (not CRC'd)
                   if (usb_tx_idx == 8'b0)
                   begin
                        usb_tx_idx   <= usb_tx_idx + 8'd1;

                        // Switch to next DATAx
                        usb_ep_tx_data1[usb_endpoint] <= ~usb_ep_tx_data1[usb_endpoint];
                   end
                   else
                   begin

                        // Pop FIFO
                        usb_fifo_wr_pop[usb_endpoint]  <= 1'b1;

                        // Increment index
                        usb_tx_idx      <= usb_tx_idx + 8'd1;
                   end
                end
            end

            //-----------------------------------------
            // TX_CRC1 (first byte)
            //-----------------------------------------
            STATE_TX_CRC1 :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data sent?
                if (utmi_txready_i)
                begin
                    // Transfer now complete
                    utmi_txvalid_o  <= 1'b0;

                    // Mark data as sent
                    usb_ep_tx_pend[usb_endpoint]   <= 1'b0;

                end
            end

            //-----------------------------------------
            // RX_TOKEN_COMPLETE
            //-----------------------------------------
            STATE_RX_TOKEN_COMPLETE :
            begin
                // Addressed to this device?
                if (usb_address == usb_this_device)
                begin
                    //-------------------------------
                    // SETUP transfer (EP0)
                    //-------------------------------
                    if (usb_rx_pid_setup)
                    begin
                        // New SETUP token resets Tx pending status on EP0
                        usb_ep_tx_pend[0]    <= 1'b0;
                        usb_fifo_wr_flush[0] <= 1'b1;
                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_EP0 :
           begin
                usb_ep_tx_pend[0]  <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[0] <= data_i[`USB_EP_COUNT];
           end

           `USB_FUNC_EP1 :
           begin
                usb_ep_tx_pend[1]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[1]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[1]   <= 1'b1;
           end
           `USB_FUNC_EP2 :
           begin
                usb_ep_tx_pend[2]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[2]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[2]   <= 1'b1;
           end
           `USB_FUNC_EP3 :
           begin
                usb_ep_tx_pend[3]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[3]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[3]   <= 1'b1;
           end

           `USB_FUNC_EP0_DATA:
           begin
             usb_fifo_wr_data[0] <= data_i[7:0];
             usb_fifo_wr_push[0] <= 1'b1;
           end
           `USB_FUNC_EP1_DATA:
           begin
             usb_fifo_wr_data[1] <= data_i[7:0];
             usb_fifo_wr_push[1] <= 1'b1;
           end
           `USB_FUNC_EP2_DATA:
           begin
             usb_fifo_wr_data[2] <= data_i[7:0];
             usb_fifo_wr_push[2] <= 1'b1;
           end
           `USB_FUNC_EP3_DATA:
           begin
             usb_fifo_wr_data[3] <= data_i[7:0];
             usb_fifo_wr_push[3] <= 1'b1;
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            // Reset endpoint state    
            usb_ep_tx_pend[0] <= 1'b0;
            usb_ep_tx_data1[0]<= 1'b0;
            usb_ep_tx_pend[1] <= 1'b0;
            usb_ep_tx_data1[1]<= 1'b0;
            usb_ep_tx_pend[2] <= 1'b0;
            usb_ep_tx_data1[2]<= 1'b0;
            usb_ep_tx_pend[3] <= 1'b0;
            usb_ep_tx_data1[3]<= 1'b0;

            // Reset to IDLE
            utmi_txvalid_o        <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// Rx
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        // Other
        usb_rx_pid_out      <= 1'b0;
        usb_rx_pid_in       <= 1'b0;
        usb_rx_pid_setup    <= 1'b0;

        usb_endpoint        <= 2'b0;

        usb_rx_accept_data  <= 1'b0;
        usb_rx_send_nak     <= 1'b0;
        usb_rx_send_stall   <= 1'b0;

        usb_rx_count        <= 8'b0;
        usb_ep0_rx_setup    <= 1'b0;

        usb_ep_stall[0]     <= 1'b0;
        usb_ep_iso[0]       <= 1'b0;
        usb_fifo_rd_push[0] <= 1'b0;
        usb_fifo_rd_flush[0]<= 1'b0;

        usb_ep_full[0]      <= 1'b0;
        usb_ep_rx_count[0]  <= 8'b0;
        usb_ep_crc_err[0]   <= 1'b0;
        usb_ep_stall[1]     <= 1'b0;
        usb_ep_iso[1]       <= 1'b0;
        usb_fifo_rd_push[1] <= 1'b0;
        usb_fifo_rd_flush[1]<= 1'b0;

        usb_ep_full[1]      <= 1'b0;
        usb_ep_rx_count[1]  <= 8'b0;
        usb_ep_crc_err[1]   <= 1'b0;
        usb_ep_stall[2]     <= 1'b0;
        usb_ep_iso[2]       <= 1'b0;
        usb_fifo_rd_push[2] <= 1'b0;
        usb_fifo_rd_flush[2]<= 1'b0;

        usb_ep_full[2]      <= 1'b0;
        usb_ep_rx_count[2]  <= 8'b0;
        usb_ep_crc_err[2]   <= 1'b0;
        usb_ep_stall[3]     <= 1'b0;
        usb_ep_iso[3]       <= 1'b0;
        usb_fifo_rd_push[3] <= 1'b0;
        usb_fifo_rd_flush[3]<= 1'b0;

        usb_ep_full[3]      <= 1'b0;
        usb_ep_rx_count[3]  <= 8'b0;
        usb_ep_crc_err[3]   <= 1'b0;
        usb_fifo_rd_in  <= 8'b0;
   end
   else
   begin
        usb_fifo_rd_push[0]  <= 1'b0;
        usb_fifo_rd_flush[0] <= 1'b0;
        usb_fifo_rd_push[1]  <= 1'b0;
        usb_fifo_rd_flush[1] <= 1'b0;
        usb_fifo_rd_push[2]  <= 1'b0;
        usb_fifo_rd_flush[2] <= 1'b0;
        usb_fifo_rd_push[3]  <= 1'b0;
        usb_fifo_rd_flush[3] <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   // Decode PID
                   case (utmi_data_r)

                      `PID_OUT:
                      begin
                            usb_rx_pid_out      <= 1'b1;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                      `PID_IN:
                      begin
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b1;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                      `PID_SETUP:
                      begin
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b1;

                            // Reset EP0 stall status on SETUP
                            usb_rx_send_stall   <= 1'b0;
                            usb_ep_stall[0]     <= 1'b0;
                      end

                      `PID_DATA0:
                      begin
                            if (usb_rx_accept_data && !usb_rx_send_stall)
                            begin
                                usb_rx_accept_data  <= 1'b0;
                                usb_rx_count        <= 0;
                            end
                      end

                      `PID_DATA1:
                      begin
                            if (usb_rx_accept_data && !usb_rx_send_stall)
                            begin
                                usb_rx_accept_data  <= 1'b0;
                                usb_rx_count        <= 0;
                            end
                      end

                      `PID_ACK:
                      begin
                      end

                      `PID_NAK:
                      begin
                      end

                      `PID_STALL:
                      begin
                      end

                      default :
                      begin
                            // Reset state
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                   endcase
               end
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
            //-----------------------------------------
            STATE_RX_TOKEN2 :
            begin
               if (new_data_ready)
                   usb_endpoint[0]  <= utmi_data_r[7];
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Endpoint/CRC)
            //-----------------------------------------
            STATE_RX_TOKEN3 :
            begin
               if (new_data_ready)
                   usb_endpoint[2-1:1] <= utmi_data_r[2-2:0];
            end

            //-----------------------------------------
            // RX_TOKEN_COMPLETE
            //-----------------------------------------
            STATE_RX_TOKEN_COMPLETE :
            begin

                // Ignore following data unless addressed
                usb_rx_accept_data <= 1'b0;
                usb_rx_send_nak    <= 1'b0;
                usb_rx_send_stall  <= 1'b0;

                // Addressed to this device?
                if (usb_address == usb_this_device)
                begin
                    //-------------------------------
                    // OUT transfer (host -> device)
                    //-------------------------------
                    if (usb_rx_pid_out)
                    begin
                        usb_rx_accept_data      <= !usb_ep_full[usb_endpoint];
                        usb_rx_send_nak         <= usb_ep_full[usb_endpoint];
                        usb_rx_send_stall       <= usb_ep_stall[usb_endpoint];
                    end
                    //-------------------------------
                    // SETUP transfer (EP0)
                    //-------------------------------
                    else if (usb_rx_pid_setup)
                    begin
                        // Must accept data!
                        usb_rx_accept_data      <= 1'b1;
                    end
                end
                else
                begin
                end
            end

            //-----------------------------------------
            // RX_DATA
            //-----------------------------------------
            STATE_RX_DATA :
            begin
               if (new_data_ready)
               begin
                   // Increment index
                   usb_rx_count     <= usb_rx_count + 1;

                   // Write incoming data to FIFO
                   usb_fifo_rd_in   <= utmi_data_r;

                   // Push data into correct EP FIFO
                   usb_fifo_rd_push[usb_endpoint]  <= 1'b1;

               end
            end

            //-----------------------------------------
            // RX_DATA_IGNORE
            //-----------------------------------------
            STATE_RX_DATA_IGNORE :
            begin
            end

            //-----------------------------------------
            // RX_DATA_COMPLETE
            //-----------------------------------------
            STATE_RX_DATA_COMPLETE :
            begin
                // Check for CRC error on receive data
                if (crc_sum != 16'hB001)
                begin

                    // Signal error and reset FIFO
                    usb_ep_full[usb_endpoint]       <= 1'b0;
                    usb_ep_crc_err[usb_endpoint]    <= 1'b1;
                    usb_fifo_rd_flush[usb_endpoint] <= 1'b1;
                    usb_ep_rx_count[usb_endpoint]   <= 8'b0;
                end
                // Good CRC
                else
                begin
                    // Update status
                    usb_ep_full[usb_endpoint]       <= 1'b1;
                    usb_ep_rx_count[usb_endpoint]   <= usb_rx_count;

                    // Endpoint 0 is different
                    if (usb_endpoint == 2'b0)
                    begin
                        usb_ep0_rx_setup    <= usb_rx_pid_setup;
                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_EP0 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[0]       <= 1'b0;
                    usb_ep0_rx_setup     <= 1'b0;
                    usb_ep_crc_err[0]    <= 1'b0;
                    usb_fifo_rd_flush[0] <= 1'b1;
                end
                usb_ep_iso[0]      <= 1'b0;

                // Respond with STALL on EP0?
                if (data_i[`USB_EP_STALL])
                    usb_ep_stall[0]     <= 1'b1;
           end

           `USB_FUNC_EP1 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[1]       <= 1'b0;
                    usb_ep_crc_err[1]    <= 1'b0;
                    usb_fifo_rd_flush[1] <= 1'b1;
                end
                usb_ep_iso[1]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[1]      <= data_i[`USB_EP_STALL];
           end
           `USB_FUNC_EP2 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[2]       <= 1'b0;
                    usb_ep_crc_err[2]    <= 1'b0;
                    usb_fifo_rd_flush[2] <= 1'b1;
                end
                usb_ep_iso[2]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[2]      <= data_i[`USB_EP_STALL];
           end
           `USB_FUNC_EP3 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[3]       <= 1'b0;
                    usb_ep_crc_err[3]    <= 1'b0;
                    usb_fifo_rd_flush[3] <= 1'b1;
                end
                usb_ep_iso[3]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[3]      <= data_i[`USB_EP_STALL];
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            // Reset endpoint state    
            usb_ep_full[0]    <= 1'b0;
            usb_ep_rx_count[0]<= 8'b0;
            usb_ep_full[1]    <= 1'b0;
            usb_ep_rx_count[1]<= 8'b0;
            usb_ep_full[2]    <= 1'b0;
            usb_ep_rx_count[2]<= 8'b0;
            usb_ep_full[3]    <= 1'b0;
            usb_ep_rx_count[3]<= 8'b0;

            usb_ep0_rx_setup      <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// CRC generation
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        crc_sum             <= 16'hFFFF;
   end
   else
   begin
        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   // Data packet?
                   if (utmi_data_r == `PID_DATA0 || utmi_data_r == `PID_DATA1)
                      if (usb_rx_accept_data && !usb_rx_send_stall)
                          crc_sum             <= 16'hFFFF;
               end
            end

            //-----------------------------------------
            // RX_DATA
            //-----------------------------------------
            STATE_RX_DATA :
            begin
               if (new_data_ready)
                   crc_sum          <= crc_out;
            end

            //-----------------------------------------
            // TX_DATA
            //-----------------------------------------
            STATE_TX_DATA :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                   // First byte is PID (not CRC'd)
                   if (usb_tx_idx == 8'b0)
                   begin
                        // Reset CRC16
                        crc_sum      <= 16'hFFFF;
                   end
                   else
                   begin
                        // Next CRC start value
                        crc_sum      <= crc_out;
                   end
                end
            end

            //-----------------------------------------
            // TX_CRC (generate)
            //-----------------------------------------
            STATE_TX_CRC :
            begin
                // Next CRC start value
                crc_sum   <= crc_sum ^ 16'hFFFF;
            end

            default :
               ;

        endcase
   end
end

//-----------------------------------------------------------------
// Address / Frame / Misc
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        usb_en_o            <= 1'b0;

        usb_frame_number    <= 11'h000;
        usb_address         <= 7'h00;
        usb_this_device     <= 7'h00;
        usb_next_address    <= 7'h00;
        usb_address_pending <= 1'b0;
        usb_event_bus_reset <= 1'b0;
   end
   else
   begin
        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // SOF (BYTE 2)
            //-----------------------------------------
            STATE_RX_SOF2 :
            begin
               if (new_data_ready)
                   usb_frame_number[7:0]    <= utmi_data_r;
            end

            //-----------------------------------------
            // SOF (BYTE 3)
            //-----------------------------------------
            STATE_RX_SOF3 :
            begin
               if (new_data_ready)
                   usb_frame_number[10:8]   <= utmi_data_r[2:0];
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
            //-----------------------------------------
            STATE_RX_TOKEN2 :
            begin
               if (new_data_ready)
                   usb_address  <= utmi_data_r[6:0];
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                    // Address changes actually occur in status phase    
                    if (usb_address_pending)
                    begin
                        usb_address_pending <= 1'b0;
                        usb_this_device     <= usb_next_address;

                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_CTRL :
           begin
                // Set new device address?
                if (data_i[`USB_FUNC_CTRL_ADDR_SET])
                begin

                    // Device address change occurs in the status stage
                    usb_next_address    <= data_i[`USB_FUNC_CTRL_ADDR];
                    usb_address_pending <= 1'b1;
                end

                usb_en_o            <= data_i[`USB_FUNC_CTRL_PULLUP_EN];

                // Clear bus reset event status
                usb_event_bus_reset <= 1'b0;
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            usb_event_bus_reset   <= 1'b1;

            // Reset SOF
            usb_frame_number      <= 11'h000;

            // Reset device address
            usb_this_device       <= 7'h00;
            usb_address_pending   <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// Interrupts
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        intr_o              <= 1'b0;

        // Interrupt control
        usb_int_en_tx       <= 1'b0;
        usb_int_en_rx       <= 1'b0;
        usb_int_en_sof      <= 1'b0;
   end
   else
   begin
        intr_o              <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // SOF (BYTE 3)
            //-----------------------------------------
            STATE_RX_SOF3 :
            begin
               if (new_data_ready)
               begin
                   // Generate interrupt?
                   if (usb_int_en_sof)
                        intr_o <= 1'b1;
               end
            end

            //-----------------------------------------
            // RX_DATA_COMPLETE
            //-----------------------------------------
            STATE_RX_DATA_COMPLETE :
            begin
                // Generate interrupt on Rx complete?
                if (usb_int_en_rx)
                    intr_o <= 1'b1;
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                    // Generate interrupt on Tx complete?
                    if (usb_int_en_tx)
                        intr_o <= 1'b1;
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_CTRL :
           begin
                // Interrupt control
                usb_int_en_tx       <= data_i[`USB_FUNC_CTRL_INT_EN_TX];
                usb_int_en_rx       <= data_i[`USB_FUNC_CTRL_INT_EN_RX];
                usb_int_en_sof      <= data_i[`USB_FUNC_CTRL_INT_EN_SOF];
           end

           default :
               ;
           endcase
   end
end

//-----------------------------------------------------------------
// Peripheral Registers (Read)
//-----------------------------------------------------------------
always @ *
begin
   case (addr_i)

   `USB_FUNC_STAT :
   begin
        data_o = 32'b0;
        data_o[`USB_FUNC_STAT_FRAME]  = usb_frame_number;
        data_o[`USB_FUNC_STAT_LS_RXP] = utmi_linestate_i[0];
        data_o[`USB_FUNC_STAT_LS_RXN] = utmi_linestate_i[1];
        data_o[`USB_FUNC_STAT_RST]    = usb_event_bus_reset;
   end

   `USB_FUNC_EP0:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[0];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[0];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[0];
        data_o[`USB_EP_RX_SETUP]  = usb_ep0_rx_setup;
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[0];
        data_o[`USB_EP_STALL]     = usb_ep_stall[0];
   end

   `USB_FUNC_EP1:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[1];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[1];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[1];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[1];
        data_o[`USB_EP_STALL]     = usb_ep_stall[1];
   end
   `USB_FUNC_EP2:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[2];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[2];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[2];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[2];
        data_o[`USB_EP_STALL]     = usb_ep_stall[2];
   end
   `USB_FUNC_EP3:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[3];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[3];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[3];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[3];
        data_o[`USB_EP_STALL]     = usb_ep_stall[3];
   end

   `USB_FUNC_EP0_DATA:
        data_o = {24'b0, usb_fifo_rd_out[0]};
   `USB_FUNC_EP1_DATA:
        data_o = {24'b0, usb_fifo_rd_out[1]};
   `USB_FUNC_EP2_DATA:
        data_o = {24'b0, usb_fifo_rd_out[2]};
   `USB_FUNC_EP3_DATA:
        data_o = {24'b0, usb_fifo_rd_out[3]};

   default :
        data_o = 32'h00000000;
   endcase
end

always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        usb_fifo_rd_pop[0]   <= 1'b0;
        usb_fifo_rd_pop[1]   <= 1'b0;
        usb_fifo_rd_pop[2]   <= 1'b0;
        usb_fifo_rd_pop[3]   <= 1'b0;
   end
   else
   begin

        usb_fifo_rd_pop[0]   <= 1'b0;
        usb_fifo_rd_pop[1]   <= 1'b0;
        usb_fifo_rd_pop[2]   <= 1'b0;
        usb_fifo_rd_pop[3]   <= 1'b0;

       // Read cycle?
       if (~we_i & stb_i)
           case (addr_i)
           `USB_FUNC_EP0_DATA:
                usb_fifo_rd_pop[0] <= 1'b1;
           `USB_FUNC_EP1_DATA:
                usb_fifo_rd_pop[1] <= 1'b1;
           `USB_FUNC_EP2_DATA:
                usb_fifo_rd_pop[2] <= 1'b1;
           `USB_FUNC_EP3_DATA:
                usb_fifo_rd_pop[3] <= 1'b1;

           default :
                ;
           endcase
   end
end

// Decode endpoint to FIFO
always @ *
begin
  usb_write_data = 8'b0;
  case (usb_endpoint)
    0 : usb_write_data  = usb_fifo_wr_out[0];
    1 : usb_write_data  = usb_fifo_wr_out[1];
    2 : usb_write_data  = usb_fifo_wr_out[2];
    3 : usb_write_data  = usb_fifo_wr_out[3];
  endcase
end

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign utmi_data_w = (usb_state == STATE_TX_CRC1) ? crc_sum[7:0] :
                     (usb_state == STATE_TX_CRC2) ? crc_sum[15:8] :
                     utmi_txdata;

assign crc_data_in = (usb_state == STATE_RX_DATA || usb_state == STATE_RX_IDLE) ? utmi_data_r : usb_write_data;

endmodule
