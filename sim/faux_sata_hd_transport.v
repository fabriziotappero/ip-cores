//faux_sata_hd_transport_layer.v
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

module faux_sata_hd_transport (

input               rst,            //reset
input               clk,

//Trasport Layer Control/Status
output              transport_layer_ready,
input               send_reg_stb,
input               send_dma_act_stb,
input               send_data_stb,
input               send_pio_stb,
input               send_dev_bits_stb,


output  reg         remote_abort,
output  reg         xmit_error,
output  reg         read_crc_fail,

output  reg         h2d_reg_stb,
output  reg         h2d_data_stb,

output              pio_request,
input       [15:0]  pio_transfer_count,
input               pio_direction,
input       [7:0]   pio_e_status,


//Host to Device Registers
output  reg [7:0]   h2d_command,
output  reg [15:0]  h2d_features,
output  reg         h2d_cmd_bit,
output  reg [7:0]   h2d_control,
output  reg [3:0]   h2d_port_mult,
output  reg [7:0]   h2d_device,
output  reg [47:0]  h2d_lba,
output  reg [15:0]  h2d_sector_count,

//Device to Host Registers
input               d2h_interrupt,
input               d2h_notification,
input       [3:0]   d2h_port_mult,
input       [7:0]   d2h_device,
input       [47:0]  d2h_lba,
input       [15:0]  d2h_sector_count,
input       [7:0]   d2h_status,
input       [7:0]   d2h_error,

//DMA Specific Control

//Data Control
input               cl_if_ready,
output reg          cl_if_activate,
input       [23:0]  cl_if_size,

output              cl_if_strobe,
input       [31:0]  cl_if_data,

input       [1:0]   cl_of_ready,
output  reg [1:0]   cl_of_activate,
output              cl_of_strobe,
output      [31:0]  cl_of_data,
input       [23:0]  cl_of_size,


//Link Layer Interface
input               link_layer_ready,

output  reg         ll_write_start,
input               ll_write_strobe,
input               ll_write_finished,
output      [31:0]  ll_write_data,
output      [31:0]  ll_write_size,
output              ll_write_hold,
output              ll_write_abort,
input               ll_xmit_error,

input               ll_read_start,
output              ll_read_ready,
input       [31:0]  ll_read_data,
input               ll_read_strobe,
input               ll_read_finished,
input               ll_read_crc_ok,
input               ll_remote_abort


);


//Parameters
parameter           IDLE                  = 4'h0;
parameter           READ_FIS              = 4'h1;
parameter           WAIT_FOR_END          = 4'h2;

parameter           CHECK_FIS_TYPE        = 4'h1;
parameter           READ_H2D_REG          = 4'h2;
parameter           READ_DATA             = 4'h3;

parameter           WRITE_D2H_REG         = 4'h4;
parameter           WRITE_DEV_BITS        = 4'h5;
parameter           WRITE_PIO_SETUP       = 4'h6;
parameter           WRITE_DMA_ACTIVATE    = 4'h7;
parameter           WRITE_DMA_SETUP       = 4'h8;
parameter           SEND_DATA             = 4'h9;
parameter           RETRY                 = 4'hA;

//Registers/Wires
reg         [3:0]   state;
reg         [3:0]   next_state;
reg         [3:0]   fis_id_state;

reg         [3:0]   reg_read_count;
//Detect Wires
wire                detect_h2d_reg;
wire                detect_h2d_data;
reg                 send_data_fis_id;


reg                 detect_fis;
reg         [7:0]   current_fis;

//Control buffer
reg         [7:0]   d2h_write_ptr;

wire        [31:0]  d2h_reg_buffer  [5:0];
wire        [31:0]  d2h_pio_setup   [5:0];
wire        [31:0]  d2h_dev_bits    [2:0];
wire        [31:0]  d2h_dma_act;
wire        [31:0]  d2h_data_fis_id;

//Submodules
//Asychronous Logic
assign  transport_layer_ready       = (state == IDLE)   &&  link_layer_ready;
assign  detect_h2d_reg  = detect_fis  ? (ll_read_data[7:0]  ==  `FIS_H2D_REG)       : (current_fis == `FIS_H2D_REG    );
assign  detect_h2d_data = detect_fis  ? (ll_read_data[7:0]  ==  `FIS_DATA)          : (current_fis == `FIS_DATA       );

//Device to host structural packets
assign  d2h_reg_buffer[0] = {d2h_error, d2h_status, 1'b0, d2h_interrupt, 2'b00, d2h_port_mult, `FIS_D2H_REG};
assign  d2h_reg_buffer[1] = {d2h_device, d2h_lba[23:0]};
assign  d2h_reg_buffer[2] = {8'h00, d2h_lba[47:24]};
assign  d2h_reg_buffer[3] = {16'h0000, d2h_sector_count};
assign  d2h_reg_buffer[4] = 32'h0;

assign  d2h_pio_setup[0]  = {d2h_error, d2h_status, 1'b0, d2h_interrupt, pio_direction, 1'b0, d2h_port_mult, `FIS_PIO_SETUP};
assign  d2h_pio_setup[1]  = {d2h_device, d2h_lba[23:0]};
assign  d2h_pio_setup[2]  = {8'h00, d2h_lba[47:24]};
assign  d2h_pio_setup[3]  = {pio_e_status, 8'h00, d2h_sector_count};
assign  d2h_pio_setup[4]  = {16'h0000, pio_transfer_count};


assign  d2h_dev_bits[0]   = { d2h_error,
                              1'b0, d2h_status[6:4], 1'b0, d2h_status[2:0],
                              d2h_notification, d2h_interrupt, 2'b00, d2h_port_mult,
                              `FIS_SET_DEV_BITS};

assign  d2h_dev_bits[1]   = 32'h00000000;

assign  d2h_dma_act       = {8'h00, 8'h00, 4'h0, d2h_port_mult, `FIS_DMA_ACT};

assign  d2h_data_fis_id   = {8'h00, 8'h00, 4'h0, d2h_port_mult, `FIS_DATA};



//Link Layer Signals

//Write
assign  ll_write_data     = (send_data_fis_id)              ? d2h_data_fis_id                                       :
                            (state == SEND_DATA)            ? cl_if_data                                            :
                            ((state == WRITE_D2H_REG)     || send_reg_stb       )   ? d2h_reg_buffer[d2h_write_ptr] :
                            ((state == WRITE_DEV_BITS)    || send_dev_bits_stb  )   ? d2h_dev_bits[d2h_write_ptr]   :
                            ((state == WRITE_DMA_ACTIVATE)|| send_dma_act_stb   )   ? d2h_dma_act                   :
                            ((state == WRITE_PIO_SETUP)   || send_pio_stb       )   ? d2h_pio_setup[d2h_write_ptr]  :
                            32'h00000000;
assign  ll_write_size     = (send_data_stb)                 ? cl_if_size + 1                                        :
                            (state == SEND_DATA)            ? cl_if_size + 1                                        :
                            ((state == WRITE_D2H_REG)       || send_reg_stb       ) ? `FIS_D2H_REG_SIZE             :
                            ((state == WRITE_DEV_BITS)      || send_dev_bits_stb  ) ? `FIS_SET_DEV_BITS_SIZE        :
                            ((state == WRITE_DMA_ACTIVATE)  || send_dma_act_stb   ) ? `FIS_DMA_ACT_SIZE             :
                            ((state == WRITE_PIO_SETUP)     || send_pio_stb       ) ? `FIS_PIO_SETUP_SIZE           :
                            24'h000000;
assign  ll_write_hold     = (state == SEND_DATA)            ? !cl_of_activate               :
                            1'b0;
assign  ll_write_abort    = 1'b0;
assign  cl_if_strobe      = (state == SEND_DATA)            ? ll_write_strobe               : 0;

//Read
assign  ll_read_ready     = (state == READ_DATA)            ? cl_of_activate                :
                            1'b1;

assign  cl_of_data        = (state == READ_DATA)            ? ll_read_data                  :
                            32'h00000000;
assign  cl_of_strobe      = (state == READ_DATA)            ? ll_read_strobe                :
                            1'b0;

//Synchronous Logic

//FIS ID State machine
always @ (posedge clk) begin
  if (rst) begin
    fis_id_state            <=  IDLE;
    detect_fis              <=  0;
    current_fis             <=  0;
  end
  else begin
    //in order to set all the detect_* high when the actual fis is detected send this strobe
    case (fis_id_state)
      IDLE: begin
        current_fis         <=  0;
        detect_fis          <=  0;
        if (ll_read_start) begin
          detect_fis        <=  1;
          fis_id_state      <=  READ_FIS;
        end
      end
      READ_FIS: begin
        if (ll_read_strobe) begin
          detect_fis        <=  0;
          current_fis         <=  ll_read_data[7:0];
          fis_id_state        <=  WAIT_FOR_END;
        end
      end
      WAIT_FOR_END: begin
        if (ll_read_finished) begin
          current_fis       <=  0;
          fis_id_state      <=  IDLE;
        end
      end
      default: begin
        fis_id_state        <=  IDLE;
      end
    endcase
  end
end

//Main State machine
always @ (posedge clk) begin
  if (rst) begin
    state                       <=  IDLE;
    next_state                  <=  IDLE;
    d2h_write_ptr               <=  0;
    reg_read_count              <=  0;

    h2d_reg_stb                 <=  0;
    h2d_data_stb                <=  0;
    h2d_command                 <=  0;

    cl_of_activate              <=  0;

    //Link Layer Interface
    ll_write_start              <=  0;
    send_data_fis_id            <=  0;

    h2d_command                 <=  0;
    h2d_features                <=  0;
    h2d_cmd_bit                 <=  0;
    h2d_control                 <=  0;
    h2d_port_mult               <=  0;
    h2d_device                  <=  0;
    h2d_lba                     <=  0;
    h2d_sector_count            <=  0;

    cl_if_activate              <=  0;

  end
  else begin
    //Strobes
    h2d_reg_stb                 <=  0;
    h2d_data_stb                <=  0;
    ll_write_start              <=  0;
    xmit_error                  <=  0;
    read_crc_fail               <=  0;

    //if there is any outptu buffers available
    if ((cl_of_ready > 0) && (cl_of_activate == 0)) begin
      if (cl_of_ready[0]) begin
        cl_of_activate[0]       <=  1;
      end
      else begin
        cl_of_activate[1]       <=  1;
      end
    end

    //if there is any cl incomming buffers available grab it
    if (cl_if_ready && !cl_if_activate) begin
      cl_if_activate            <=  1;
    end


    //Remote Abortion
    if (ll_remote_abort) begin
      state                     <=  IDLE;
      remote_abort              <=  0;
    end
    if (ll_xmit_error) begin
      xmit_error                <=  1;
    end
    if (!ll_read_crc_ok) begin
      read_crc_fail             <=  1;
    end

    case (state)
      IDLE: begin
        d2h_write_ptr           <=  0;
        reg_read_count          <=  0;
        send_data_fis_id        <=  0;
        next_state              <=  IDLE;

        //detect an incomming FIS
        if (ll_read_start) begin
          state                 <=  CHECK_FIS_TYPE;
        end
        //Command Layer Initiated a transaction
        if (link_layer_ready) begin
          if (send_reg_stb) begin
            ll_write_start        <=  1;
            state                 <=  WRITE_D2H_REG;
          end
          else if (send_dev_bits_stb) begin
            ll_write_start        <=  1;
            state                 <=  WRITE_DEV_BITS;
          end
          else if (send_dma_act_stb) begin
            ll_write_start        <=  1;
            state                 <=  WRITE_DMA_ACTIVATE;
          end
          else if (send_pio_stb) begin
            ll_write_start        <=  1;
            state                 <=  WRITE_PIO_SETUP;
          end
          else if (send_data_stb) begin
            ll_write_start        <=  1;
            send_data_fis_id      <=  1;
            state                 <=  SEND_DATA;
          end
        end
      end
      CHECK_FIS_TYPE: begin
        if (detect_h2d_reg) begin
          h2d_features[7:0]     <=  ll_read_data[31:24];
          h2d_command           <=  ll_read_data[23:16];
          h2d_cmd_bit           <=  ll_read_data[15];
          h2d_port_mult         <=  ll_read_data[11:8];

          state                 <=  READ_H2D_REG;
          reg_read_count        <=  reg_read_count + 1;
        end
        else if (detect_h2d_data) begin
          state                 <=  READ_DATA;
        end
        if (ll_read_finished) begin
          //unrecognized FIS
          state                 <=  IDLE;
        end

      end
      READ_H2D_REG: begin
        case (reg_read_count)
          1:  begin
            h2d_device          <=  ll_read_data[31:24];
            h2d_lba[23:0]       <=  ll_read_data[23:0];
          end
          2:  begin
            h2d_features[15:8]  <=  ll_read_data[31:24];
            h2d_lba[47:24]      <=  ll_read_data[23:0];
          end
          3:  begin
            h2d_control         <=  ll_read_data[31:24];
            h2d_sector_count    <=  ll_read_data[15:0];
          end
          4:  begin
          end
          default: begin
          end
        endcase
        if (ll_read_strobe) begin
          reg_read_count        <=  reg_read_count + 1;
        end
        if (ll_read_finished) begin
          h2d_reg_stb           <=  1;
          state                 <=  IDLE;
        end
      end
      READ_DATA: begin
        //NOTE: the data_read_ready will automatically 'flow control' the data from the link layer
        //so we don't have to check it here
        //NOTE: We don't have to keep track of the count because the lower level will give a max of 2048 DWORDS

        if (ll_read_finished) begin
          h2d_data_stb          <=  1;
          cl_of_activate        <=  0;
          state                 <=  IDLE;
        end
      end
      WRITE_D2H_REG: begin
        if (ll_write_strobe) begin
          d2h_write_ptr         <=  d2h_write_ptr + 1;
        end
        if (ll_write_finished) begin
          if (ll_xmit_error) begin
            next_state            <=  state;
            state                 <=  RETRY;
          end
          else begin
            state                 <=  IDLE;
          end
        end
      end
      WRITE_DEV_BITS: begin
        if (ll_write_strobe) begin
          d2h_write_ptr         <=  d2h_write_ptr + 1;
        end
        if (ll_write_finished) begin
          if (ll_xmit_error) begin
            next_state            <=  state;
            state                 <=  RETRY;
          end
          else begin
            state                 <=  IDLE;
          end
        end
      end
      WRITE_PIO_SETUP: begin
        if (ll_write_strobe) begin
          d2h_write_ptr         <=  d2h_write_ptr + 1;
        end
        if (ll_write_finished) begin
          if (ll_xmit_error) begin
            next_state            <=  state;
            state                 <=  RETRY;
          end
          else begin
            state                 <=  IDLE;
          end
        end
      end
      WRITE_DMA_ACTIVATE: begin
        if (ll_write_strobe) begin
          d2h_write_ptr         <=  d2h_write_ptr + 1;
        end
        if (ll_write_finished) begin
          if (ll_xmit_error) begin
            next_state            <=  state;
            state                 <=  RETRY;
          end
          else begin
            state                 <=  IDLE;
          end
        end
      end
      WRITE_DMA_SETUP: begin
//XXX:  not implemented yet
        state                   <=  IDLE;
      end
      SEND_DATA: begin
        if (ll_write_strobe && send_data_fis_id) begin
          send_data_fis_id      <=  0;
        end
        if (ll_write_finished) begin
          cl_if_activate        <=  0;
          state                 <=  IDLE;
        end
      end
      RETRY: begin
        d2h_write_ptr           <=  0;
        reg_read_count          <=  0;
        if (link_layer_ready) begin
          ll_write_start        <=  1;
          state                 <=  next_state;
          next_state            <=  IDLE;
        end
      end
      default: begin
        state                   <=  IDLE;
      end
    endcase
  end
end


endmodule
