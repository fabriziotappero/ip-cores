//faux_hd_command_layer.v
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

module faux_hd_command_layer (
input               rst,            //reset
input               clk,



output              command_layer_ready,
output              command_layer_busy,

output              hd_read_from_host,
output      [31:0]  hd_data_from_host,

output              hd_write_to_host,
input       [31:0]  hd_data_to_host,


input               transport_layer_ready,
output  reg         send_reg_stb,
output  reg         send_dma_act_stb,
output  reg         send_data_stb,
output  reg         send_pio_stb,
output  reg         send_dev_bits_stb,

input               remote_abort,
input               xmit_error,
input               read_crc_fail,

input               h2d_reg_stb,
input               h2d_data_stb,

input               pio_request,
output reg   [15:0] pio_transfer_count,
output reg          pio_direction,
output reg   [7:0]  pio_e_status,

//FIS Structure
input        [7:0]  h2d_command,
input        [15:0] h2d_features,
input               h2d_cmd_bit,
input        [3:0]  h2d_port_mult,
input        [7:0]  h2d_control,
input        [7:0]  h2d_device,
input        [47:0] h2d_lba,
input        [15:0] h2d_sector_count,

output  reg         d2h_interrupt,
output  reg         d2h_notification,
output  reg  [7:0]  d2h_status,
output  reg  [7:0]  d2h_error,
output  reg  [3:0]  d2h_port_mult,
output  reg  [7:0]  d2h_device,
output  reg  [47:0] d2h_lba,
output  reg  [15:0] d2h_sector_count,

//command layer data interface
input               cl_if_strobe,
output      [31:0]  cl_if_data,
output              cl_if_ready,
input               cl_if_activate,
output      [23:0]  cl_if_size,

input               cl_of_strobe,
input       [31:0]  cl_of_data,
output      [1:0]   cl_of_ready,
input       [1:0]   cl_of_activate,
output      [23:0]  cl_of_size,

output      [3:0]   cl_state


);

//Parameters
parameter SLEEP_START       = 4'h0;
parameter SEND_DIAGNOSTICS  = 4'h1;
parameter IDLE              = 4'h2;
parameter DMA_READY         = 4'h3;
parameter READ_DATA         = 4'h4;
parameter SEND_DATA         = 4'h5;
parameter READ_IN_PROGRESS  = 4'h6;
parameter SEND_STATUS       = 4'h7;

//Registers/Wires
reg         [3:0]   state               = SLEEP_START;
wire                idle;

reg         [8:0]   byte_count          = 0;
reg         [15:0]  sector_count        = 0;
reg         [15:0]  sector_size         = 16'h0000;

reg         [15:0]  sleep_count         = 0;
reg         [15:0]  sleep_size          = 1000;


wire                soft_reset;

//Asynchronous Logic
assign              idle                = (state == IDLE);
assign              command_layer_busy  = !idle;
assign              command_layer_ready = idle;

//Short circuit the ping pong fifos
assign              hd_read_from_host   = cl_of_strobe;
assign              hd_data_from_host   = cl_of_data;
assign              cl_of_ready         = 1;
assign              cl_of_size          = 2048;

assign              hd_write_to_host    = cl_if_strobe;
assign              cl_if_data          = hd_data_to_host;
assign              cl_if_ready         = 1;
assign              cl_if_size          = 24'h0100;

assign              soft_reset          = h2d_control[`CONTROL_SRST_BIT];
assign              cl_state            = state;

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    state                               <=  SLEEP_START;

    send_reg_stb                        <=  0;
    send_dma_act_stb                    <=  0;
    send_data_stb                       <=  0;
    send_pio_stb                        <=  0;
    send_dev_bits_stb                   <=  0;

    sector_count                        <=  0;
    sector_size                         <=  1000;

    sleep_count                         <=  0;
    sleep_size                          <=  1000;



    pio_transfer_count                  <=  0;
    pio_direction                       <=  0;
    pio_e_status                        <=  0;

    d2h_interrupt                       <=  0;
    d2h_notification                    <=  0;
    d2h_status                          <=  8'h50;
    d2h_error                           <=  1;
    d2h_port_mult                       <=  0;
    d2h_lba                             <=  1;
    d2h_sector_count                    <=  1;
    d2h_device                          <=  0;

    byte_count                          <=  0;

  end
  else begin
    //Strobe Lines
    send_reg_stb                        <=  0;
    send_dma_act_stb                    <=  0;
    send_data_stb                       <=  0;
    send_pio_stb                        <=  0;
    send_dev_bits_stb                   <=  0;

    if (soft_reset) begin
      state                             <=  SLEEP_START;
      sleep_count                       <=  0;
      sleep_size                        <=  1000;
    end

    case (state)
      SLEEP_START: begin
        if (sleep_count  < sleep_size) begin
          sleep_count                   <=  sleep_count + 1;
        end
        else begin
          state                         <=  SEND_DIAGNOSTICS;
        end
      end
      SEND_DIAGNOSTICS: begin
        send_reg_stb                    <=  1;
        state                           <=  IDLE;
      end
      IDLE: begin
        if (h2d_reg_stb) begin
          if (h2d_cmd_bit) begin
            d2h_lba                     <=  h2d_lba;
            d2h_sector_count            <=  h2d_sector_count;

            sector_size                 <=  h2d_sector_count;

            case (h2d_command)
              `COMMAND_DMA_READ_EX: begin
                //send_data_stb           <=  1;
                sector_count            <=  0;
                sector_size             <=  h2d_sector_count;
                state                   <=  SEND_DATA;
              end
              `COMMAND_DMA_WRITE_EX: begin
                send_dma_act_stb        <=  1;
                sector_count            <=  0;
                sector_size             <=  h2d_sector_count;
                state                   <=  DMA_READY;
              end
              default: begin
                //unrecognized command
                $display ("fcl: Unrecognized command from host");
              end
            endcase
          end
        end
      end
      DMA_READY: begin
        if (transport_layer_ready) begin
          send_dma_act_stb          <=  1;
          byte_count                <=  0;
          state                     <=  READ_DATA;
        end
      end
      READ_DATA: begin
        if (cl_of_activate && cl_of_strobe) begin
          byte_count                <=  byte_count + 4;
        end
        if(byte_count == 508) begin
          sector_count              <=  sector_count + 1;
        end
        if (h2d_data_stb) begin
          if (sector_count  <  sector_size) begin
            state                   <=  DMA_READY;
          end
          else begin
            state                   <=  SEND_STATUS;
          end
        end
      end
      SEND_DATA: begin
        if (transport_layer_ready) begin
          sector_count              <=  sector_count + 1;
          send_data_stb             <=  1;
          state                     <=  READ_IN_PROGRESS;
          //state                     <=  SEND_STATUS;
        end
      end
      READ_IN_PROGRESS: begin
        if (!transport_layer_ready) begin
            state                   <= SEND_STATUS;
        end
        //if (sector_count < sector_size) begin
        //  state                     <=  SEND_DATA;
        //end
        //else begin
        //  if (transport_layer_ready) begin
        //    send_reg_stb            <=  1;
        //    //Send a done register
        //    state                   <=  SEND_STATUS;
        //  end
        //end
      end
      SEND_STATUS: begin
        if (transport_layer_ready) begin
          send_reg_stb            <=  1;
          //Send a done register
          state                   <=  IDLE;
        end
      end
      default: begin
        $display ("fcl: Entered illegal state, restart");
        state                       <=  SLEEP_START;
        sleep_count                 <=  0;
        sleep_size                  <=  1000;
      end
    endcase
  end
end




endmodule
