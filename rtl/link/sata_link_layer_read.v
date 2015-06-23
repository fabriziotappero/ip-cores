//sata_link_layer_read.v
/*
Distributed under the MIT license.
Copyright (c) 2011 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


`include "sata_defines.v"

module sata_link_layer_read (

  input               rst,            //reset
  input               clk,

  input               phy_ready,
  input               en,
  output              idle,

  input               sync_escape,
  input               dbg_hold,

  input               detect_align,
  input               detect_sync,
  input               detect_x_rdy,
  input               detect_sof,
  input               detect_eof,
  input               detect_wtrm,
  input               detect_holda,
  input               detect_hold,
  input               detect_cont,
  input               detect_xrdy_xrdy,

  output      [31:0]  tx_dout,
  output              tx_isk,

  input       [31:0]  rx_din,
  input       [3:0]   rx_isk,

  output  reg         read_strobe,
  output  reg  [31:0] read_data,
  input               read_ready,
  output              read_start,
  output              read_finished,
  output  reg         remote_abort,

  output  reg         crc_ok,
//  output  wire        crc_ok,

  input               data_scrambler_en,
  input               is_device,
  output      [3:0]   lax_r_state



);
//Primatives
parameter           IDLE        = 4'h0;
parameter           READ_START  = 4'h1;
parameter           READ        = 4'h2;
parameter           READ_END    = 4'h3;
parameter           SEND_STATUS = 4'h4;

//Registers/Wires
reg         [3:0]   state;

reg                 send_r_rdy;
reg                 send_r_ip;
reg                 send_r_err;
reg                 send_r_ok;
reg                 send_hold;
reg                 send_holda;
reg                 send_sync;

//CRC
//XXX: Tie the CRC_EN to an incomming data dword
wire                crc_en;
wire      [31:0]    crc_din;
wire      [31:0]    crc_dout;
reg                 crc_data;
reg                 crc_check;

reg       [31:0]    prev_crc;
reg       [31:0]    prev_data;
wire                data_valid;
reg                 first_dword;



//Descrambler
wire                descr_en;
wire      [31:0]    descr_din;
wire      [31:0]    descr_dout;

//SubModules
crc c (
  .rst            (rst      || idle ),
  .clk            (clk              ),
  .en             (crc_en           ),
  .din            (crc_din          ),
  .dout           (crc_dout         )
);

scrambler descr (
  .rst            (rst      ||  idle),
  .clk            (clk              ),
  .prim_scrambler (0                ),
  .en             (descr_en         ),
  .din            (rx_din           ),
  .dout           (descr_dout       )
);



//Asynchronous Logic
assign              idle    = (state == IDLE);
assign              tx_dout = (send_r_rdy)  ? `PRIM_R_RDY :
                              (send_r_ip)   ? `PRIM_R_IP  :
                              (send_r_err)  ? `PRIM_R_ERR :
                              (send_r_ok)   ? `PRIM_R_OK  :
                              (send_hold)   ? `PRIM_HOLD  :
                              (send_sync)   ? `PRIM_SYNC  :
                              (send_holda)  ? `PRIM_HOLDA :
                              `PRIM_SYNC;

assign              tx_isk  = ( send_r_rdy  ||
                                send_r_ip   ||
                                send_r_err  ||
                                send_r_ok   ||
                                send_hold   ||
                                send_holda  ||
                                send_sync);

assign              crc_din       = (data_scrambler_en) ? descr_dout : rx_din;
//assign              read_data     = (read_strobe) ? rx_din : 32'h0;
assign              read_finished = detect_eof;
assign              read_start    = detect_sof;
assign              data_valid    = (state == READ) &&
                                    (rx_isk == 0)   &&
                                    (!detect_hold)  &&
                                    (!detect_holda) &&
                                    (!detect_align);

assign              crc_en        = data_valid;
assign              descr_en      = (data_scrambler_en && (detect_sof || data_valid));
assign              descr_din     = (data_valid) ? rx_din : 32'h00000000;
//assign              crc_ok        = (prev_data == prev_crc);

assign              lax_r_state   = state;

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    state             <=  IDLE;
    send_r_rdy        <=  0;
    send_r_ip         <=  0;
    send_r_err        <=  0;
    send_r_ok         <=  0;
    send_hold         <=  0;
    send_holda        <=  0;
    send_sync         <=  0;

    crc_ok            <=  0;

    prev_crc          <=  0;
    prev_data         <=  0;
    read_data         <=  0;
    read_strobe       <=  0;
    first_dword       <=  0;

    remote_abort      <=  0;

  end
  else begin
    read_strobe       <=  0;
    remote_abort      <=  0;

    if (phy_ready) begin
      send_r_rdy        <=  0;
      send_r_ip         <=  0;
      send_r_err        <=  0;
      send_r_ok         <=  0;
      send_hold         <=  0;
      send_sync         <=  0;
      send_holda        <=  0;
    end

    case (state)
      IDLE: begin
        read_data     <=  0;
        send_sync     <=  1;
        if (!detect_align) begin
          crc_ok            <=  0;
          prev_crc          <=  0;
          prev_data         <=  0;
          if (detect_x_rdy) begin
            if (detect_xrdy_xrdy) begin
              if (!is_device) begin
                if (read_ready || sync_escape) begin
                //Transport is ready
                  if (phy_ready) begin
                    send_r_rdy  <=  1;
                    state       <=  READ_START;
                  end
                end
              end
            end
            else begin
              if (read_ready || sync_escape) begin
                //Transport is ready
//XXX: I think this is okay because remote will continue to send X_RDY Primative
                if (phy_ready) begin
                  send_r_rdy  <=  1;
                  state       <=  READ_START;
                end
              end
            end
//            else begin
//              //Transport Read is not ready
//              send_sync   <=  1;
//            end
          end
        end
      end
      READ_START: begin
        //wait for a start of frame
        send_r_rdy            <=  1;
        if (detect_sync) begin
            remote_abort      <=  1;
            state             <=  IDLE;
        end
        else if (detect_sof) begin
          state         <=  READ;
          send_r_ip     <=  1;
          first_dword   <=  1;
        end
      end
      READ: begin
        if (sync_escape) begin
          send_sync           <=  1;
          if (detect_sync) begin
            state       <=  IDLE;
          end
        end
        else begin
          if (detect_eof) begin
            //check the CRC
            state         <=  READ_END;
            send_r_ip     <=  1;
            //if (prev_data == prev_crc) begin
            if (prev_data == prev_crc) begin
              crc_ok      <=  1;
            end
          end
          else begin
            if (detect_sync) begin
              remote_abort      <=  1;
              state             <=  IDLE;
            end
            else if (!read_ready || dbg_hold) begin
              //we should still have 20 DWORD of data to write
              send_hold         <=  1;
            end
            else if (detect_hold) begin
              send_holda        <=  1;
            end
            else begin
              send_r_ip         <=  1;
            end
          end
          if (data_valid) begin
            if (first_dword) begin
              first_dword   <=  0;
            end
            else begin
              read_strobe   <=  1;
            end
            read_data     <=  prev_data;
            if (data_scrambler_en) begin
              prev_data   <=  descr_dout;
            end
            else begin
              prev_data   <=  rx_din;
            end
            prev_crc      <=  crc_din;
          end

        end

        //put data into the incomming buffer
        //check to see if we have enough room for 20 more dwords
        //if not send a hold
      end
      READ_END: begin
        //send r ok or r err
//XXX: Watch out for PHY_READY
        //if CRC checks out OK then send an R_OK
        //if CRC does not check out then send an R_ERR
        //if (phy_ready) begin
          if (crc_ok) begin
            send_r_ok     <=  1;
            state         <=  SEND_STATUS;
          end
          else begin
            send_r_err    <=  1;
            state         <=  SEND_STATUS;
          end
        //end
      end
      SEND_STATUS: begin
        if (send_r_ok) begin
          send_r_ok       <=  1;
        end
        else begin
          send_r_err      <=  1;
        end
        if (detect_sync) begin
          state         <=  IDLE;
        end
      end
      default: begin
        state         <=  IDLE;
      end
    endcase
  end
end
endmodule
