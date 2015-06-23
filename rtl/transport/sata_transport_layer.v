//sata_transport_layer.v
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

module sata_transport_layer (
  input               rst,            //reset
  input               clk,
  input               phy_ready,


//Transport Layer Control/Status
  output              transport_layer_ready,
  input               sync_escape,

  output  reg         d2h_reg_stb,
  output  reg         dma_activate_stb,
  output  reg         d2h_data_stb,
  output  reg         dma_setup_stb,
  output  reg         pio_setup_stb,
  output  reg         set_device_bits_stb,

  output  reg         remote_abort,
  output              xmit_error,
  output              read_crc_error,

  input               send_command_stb,
  input               send_control_stb,
  input               send_data_stb,

//PIO
  output reg          pio_response,
  output reg          pio_direction,
  output reg  [15:0]  pio_transfer_count,
  output reg  [7:0]   pio_e_status,


//Host to Device Registers
  input       [7:0]   h2d_command,
  input       [15:0]  h2d_features,
  input       [7:0]   h2d_control,
  input       [3:0]   h2d_port_mult,
  input       [7:0]   h2d_device,
  input       [47:0]  h2d_lba,
  input       [15:0]  h2d_sector_count,

//Device to Host Registers
  output  reg         d2h_interrupt,
  output  reg         d2h_notification,
  output  reg [3:0]   d2h_port_mult,
  output  reg [7:0]   d2h_device,
  output  reg [47:0]  d2h_lba,
  output  reg [15:0]  d2h_sector_count,
  output  reg [7:0]   d2h_status,
  output  reg [7:0]   d2h_error,

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
  output              ll_sync_escape,

  output              ll_write_start,
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
  input               ll_remote_abort,

  output      [3:0]   lax_state
);


//Parameters
parameter           IDLE                  = 4'h0;
parameter           READ_FIS              = 4'h1;
parameter           WAIT_FOR_END          = 4'h2;


parameter           CHECK_FIS_TYPE        = 4'h1;
parameter           WRITE_H2D_REG         = 4'h2;
parameter           RETRY                 = 4'h3;
parameter           READ_D2H_REG          = 4'h4;
parameter           READ_PIO_SETUP        = 4'h5;
parameter           READ_SET_DEVICE_BITS  = 4'h6;
parameter           DMA_ACTIVATE          = 4'h7;
parameter           SEND_DATA             = 4'h8;
parameter           READ_DATA             = 4'h9;


//Registers/Wires
reg         [3:0]   fis_id_state;
reg         [3:0]   state;
reg                 detect_fis;
reg         [7:0]   current_fis;
wire                processing_fis;

//data direction
wire                data_direction;

//Detect FIS from the device
wire                detect_d2h_reg;
wire                detect_dma_activate;
wire                detect_dma_setup;
wire                detect_d2h_data;
wire                detect_pio_setup;
wire                detect_set_device_bits;

//control data signals
wire        [31:0]  register_fis          [5:0];
reg         [7:0]   register_fis_ptr;
reg                 cmd_bit;

reg                 reg_write_start;
wire        [31:0]  reg_write_data;
wire        [31:0]  reg_write_size;
reg                 reg_write_ready;
wire                reg_write_hold;
wire                reg_write_abort;
wire                reg_write_strobe;

//read register
wire                reg_read;
wire                reg_write;
reg         [7:0]   reg_read_count;
wire                reg_read_stb;



//data state machine signals
reg                 data_write_start;
wire                data_write_strobe;
wire                data_read_strobe;
wire        [31:0]  data_write_size;
wire        [31:0]  data_write_data;
wire                data_write_hold;
wire                data_write_abort;

reg                 data_read_ready;
reg                 send_data_fis_id;



//Asnchronous Logic
assign  lax_state               = state;
assign  transport_layer_ready   = (state == IDLE) && link_layer_ready;
assign  ll_sync_escape          = sync_escape;
assign  xmit_error              = ll_xmit_error;

//Attach Control/Data Signals to link layer depending on the conditions

//Write Control
assign  ll_write_start          = (reg_write)   ? reg_write_start                : data_write_start;
assign  ll_write_data           = (reg_write)   ? register_fis[register_fis_ptr] : data_write_data;
assign  ll_write_size           = (reg_write)   ? reg_write_size                 : data_write_size;
assign  ll_write_hold           = (reg_write)   ? 0                              : data_write_hold;
assign  ll_write_abort          = (reg_write)   ? 0                              : data_write_abort;
assign  cl_if_strobe            = (reg_write)   ? 0                              : (!send_data_fis_id && data_write_strobe);

//Read Control
assign  ll_read_ready           = (reg_read)    ? 1                              : data_read_ready;
assign  cl_of_strobe            = (reg_read)    ? 0                              : ((state == READ_DATA) && data_read_strobe);
assign  cl_of_data              = ll_read_data;

//Data Register Write Control Signals
assign  data_write_data         = (send_data_fis_id)     ? `FIS_DATA                : cl_if_data;
                                                      //the first DWORD is the FIS ID
assign  data_write_size         = (cl_if_size + 1);
//assign  data_write_size         = cl_if_size;
                                                      //Add 1 to the size so that there is room for the FIS ID
assign  data_write_strobe       = ll_write_strobe;
assign  data_read_strobe        = ll_read_strobe;
assign  data_write_hold         = 0;
                                                   //There should never be a hold on the data becuase the CL will set it up
assign  data_write_abort        = 0;
assign  read_crc_error          = !ll_read_crc_ok;


//H2D Register Write control signals
assign  reg_write_strobe        = ll_write_strobe;
assign  reg_write_size          = `FIS_H2D_REG_SIZE;
assign  reg_write_hold          = 0;
assign  reg_write_abort         = 0;
assign  reg_write               = (state == WRITE_H2D_REG)        || (send_command_stb || send_control_stb);

//D2H Register Read control signals
assign  reg_read                = (state == READ_D2H_REG)         ||  detect_d2h_reg          ||
                                  (state == READ_PIO_SETUP)       ||  detect_pio_setup        ||
                                  (state == READ_SET_DEVICE_BITS) ||  detect_set_device_bits;

assign  reg_read_stb            = ll_read_strobe;

//Data Read control signals

//Detect Signals
assign  processing_fis          = (state == READ_FIS);

assign  detect_d2h_reg          = detect_fis ? (ll_read_data[7:0] == `FIS_D2H_REG)       : (current_fis == `FIS_D2H_REG      );
assign  detect_dma_activate     = detect_fis ? (ll_read_data[7:0] == `FIS_DMA_ACT)       : (current_fis == `FIS_DMA_ACT      );
assign  detect_d2h_data         = detect_fis ? (ll_read_data[7:0] == `FIS_DATA)          : (current_fis == `FIS_DATA         );
assign  detect_dma_setup        = detect_fis ? (ll_read_data[7:0] == `FIS_DMA_SETUP)     : (current_fis == `FIS_DMA_SETUP    );
assign  detect_pio_setup        = detect_fis ? (ll_read_data[7:0] == `FIS_PIO_SETUP)     : (current_fis == `FIS_PIO_SETUP    );
assign  detect_set_device_bits  = detect_fis ? (ll_read_data[7:0] == `FIS_SET_DEV_BITS)  : (current_fis == `FIS_SET_DEV_BITS );

assign  register_fis[0]         = {h2d_features[7:0], h2d_command, cmd_bit, 3'b000, h2d_port_mult, `FIS_H2D_REG};
assign  register_fis[1]         = {h2d_device, h2d_lba[23:0]};
assign  register_fis[2]         = {h2d_features[15:8], h2d_lba[47:24]};
assign  register_fis[3]         = {h2d_control, 8'h00, h2d_sector_count};
assign  register_fis[4]         = {32'h00000000};

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
    if(ll_read_finished) begin
      current_fis           <=  0;
      fis_id_state          <=  IDLE;
    end
    else begin
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
end


//main DATA state machine
always @ (posedge clk) begin
  if (rst) begin
    state                       <=  IDLE;
    cl_of_activate              <=  0;
    cl_if_activate              <=  0;
    data_read_ready             <=  0;

    //Data Send

    send_data_fis_id            <=  0;

    //H2D Register
    register_fis_ptr            <=  0;
    reg_write_start             <=  0;

    //D2H Register
    reg_read_count              <=  0;

    //Device Status
    d2h_interrupt               <=  0;
    d2h_notification            <=  0;
    d2h_port_mult               <=  0;
    d2h_lba                     <=  0;
    d2h_sector_count            <=  0;
    d2h_status                  <=  0;
    d2h_error                   <=  0;

    d2h_reg_stb                 <=  0;
    d2h_data_stb                <=  0;
    pio_setup_stb               <=  0;
    set_device_bits_stb         <=  0;
    dma_activate_stb            <=  0;
    dma_setup_stb               <=  0;

    remote_abort                <=  0;

    cmd_bit                     <=  0;

    //PIO
    pio_transfer_count          <=  0;
    pio_e_status                <=  0;
    pio_direction               <=  0;
    pio_response                <=  0;

    data_write_start            <=  0;

  end
  else begin
    //Strobed signals
    if (phy_ready) begin
      //only deassert a link layer strobe when Phy is ready
      data_write_start          <=  0;
      reg_write_start           <=  0;
    end

    d2h_reg_stb                 <=  0;
    d2h_data_stb                <=  0;
    pio_setup_stb               <=  0;
    set_device_bits_stb         <=  0;
    dma_activate_stb            <=  0;
    dma_setup_stb               <=  0;

    remote_abort                <=  0;



    d2h_device                  <=  0;
    //Always attempt to get a free buffer
    if ((cl_of_activate == 0) && (cl_of_ready > 0)) begin
      if (cl_of_ready[0]) begin
        cl_of_activate[0]       <= 1;
      end
      else begin
        cl_of_activate[1]       <= 1;
      end
      data_read_ready           <= 1;
    end
    else if (cl_of_activate == 0) begin
//XXX: NO BUFFER AVAILABLE!!!! Can't accept new data from the Hard Drive
      data_read_ready           <= 0;
    end

    //Always attempt to get the incomming buffer
    if (cl_if_ready && !cl_if_activate) begin
      cl_if_activate            <=  1;
    end

    case (state)
      IDLE: begin
        register_fis_ptr        <=  0;
        reg_read_count          <=  0;
        cmd_bit                 <=  0;
        //Detect a FIS
        if(ll_read_start) begin
          //detect the start of a frame
          state                 <=  CHECK_FIS_TYPE;
//Clear Errors when a new transaction starts
        end
        //Send Register
        if (send_command_stb || send_control_stb) begin
//Clear Errors when a new transaction starts

          if (send_command_stb) begin
            cmd_bit               <=  1;
          end
          else if (send_control_stb) begin
            cmd_bit               <=  0;
          end

          reg_write_start       <=  1;
          state                 <=  WRITE_H2D_REG;
        end
        //Send Data
        else if (send_data_stb) begin
//Clear Errors when a new transaction starts
          data_write_start      <=  1;
          send_data_fis_id      <=  1;
          state                 <=  SEND_DATA;
        end
      end
      CHECK_FIS_TYPE: begin
        if (detect_dma_setup) begin
//XXX: Future work!
          reg_read_count        <=  reg_read_count + 1;
          state                 <=  IDLE;
        end
        else if (detect_dma_activate) begin
          //hard drive is ready to receive data
          state                 <=  DMA_ACTIVATE;
          reg_read_count        <=  reg_read_count + 1;
          //state                 <=  IDLE;
        end
        else if (detect_d2h_data) begin
          //incomming data, because the out FIFO is directly connected to the output during a read
          state                 <=  READ_DATA;
        end
        else if (detect_d2h_reg) begin
          //store the error, status interrupt from this read
          d2h_status            <=  ll_read_data[23:16];
          d2h_error             <=  ll_read_data[31:24];
          d2h_interrupt         <=  ll_read_data[14];
          d2h_port_mult         <=  ll_read_data[11:8];

          state                 <=  READ_D2H_REG;
          reg_read_count        <=  reg_read_count + 1;
        end
        else if (detect_pio_setup) begin
          //store the error, status, direction interrupt from this read
          pio_response          <=  1;

          d2h_status            <=  ll_read_data[23:16];
          d2h_error             <=  ll_read_data[31:24];
          d2h_interrupt         <=  ll_read_data[14];
          pio_direction         <=  ll_read_data[13];
          d2h_port_mult         <=  ll_read_data[11:8];

          state                 <=  READ_PIO_SETUP;
          reg_read_count        <=  reg_read_count + 1;
        end
        else if (detect_set_device_bits) begin
          //store the error, a subset of the status bit and the interrupt
          state                 <=  IDLE;
          d2h_status[6:4]       <=  ll_read_data[22:20];
          d2h_status[2:0]       <=  ll_read_data[18:16];
          d2h_error             <=  ll_read_data[31:24];
          d2h_notification      <=  ll_read_data[15];
          d2h_interrupt         <=  ll_read_data[14];
          d2h_port_mult         <=  ll_read_data[11:8];

          state                 <=  READ_SET_DEVICE_BITS;
        end
        else if (ll_read_finished) begin
          //unrecognized FIS
          state                 <=  IDLE;
        end
      end
      WRITE_H2D_REG: begin
        if  (register_fis_ptr < `FIS_H2D_REG_SIZE) begin
          if (reg_write_strobe) begin
            register_fis_ptr    <=  register_fis_ptr + 1;
          end
        end
        if (ll_write_finished) begin
          if (ll_xmit_error) begin
            state               <=  RETRY;
          end
          else begin
            state               <=  IDLE;
          end
        end
      end
      RETRY: begin
        if (link_layer_ready) begin
          reg_write_start       <=  1;
          register_fis_ptr      <=  0;
          state                 <=  WRITE_H2D_REG;
        end
      end
      READ_D2H_REG: begin
        case (reg_read_count)
          1: begin
            d2h_device          <=  ll_read_data[31:24];
            d2h_lba[23:0]       <=  ll_read_data[23:0];
          end
          2: begin
            d2h_lba[47:24]      <=  ll_read_data[23:0];
          end
          3: begin
            d2h_sector_count    <=  ll_read_data[15:0];
          end
          4: begin
          end
          default: begin
          end
        endcase
        if (reg_read_stb) begin
          reg_read_count        <=  reg_read_count + 1;
        end
        if (ll_read_finished) begin
          d2h_reg_stb           <=  1;
          state                 <=  IDLE;
        end
      end
      READ_PIO_SETUP: begin
        case (reg_read_count)
          1: begin
            d2h_device          <=  ll_read_data[31:24];
            d2h_lba[23:0]       <=  ll_read_data[23:0];
          end
          2: begin
            d2h_lba[47:24]      <=  ll_read_data[23:0];
          end
          3: begin
            d2h_sector_count    <=  ll_read_data[15:0];
            pio_e_status        <=  ll_read_data[31:24];
          end
          4: begin
            pio_transfer_count  <=  ll_read_data[15:0];
          end
          default: begin
          end
        endcase
        if (reg_read_stb) begin
          reg_read_count        <=  reg_read_count + 1;
        end
        if (ll_read_finished) begin
          pio_setup_stb         <=  1;
          state                 <=  IDLE;
        end
      end
      READ_SET_DEVICE_BITS: begin
        state                 <=  IDLE;
        set_device_bits_stb   <=  1;
      end
      DMA_ACTIVATE: begin
        state                 <=  IDLE;
        dma_activate_stb      <=  1;
      end
      SEND_DATA: begin
        if (ll_write_strobe && send_data_fis_id) begin
          send_data_fis_id      <=  0;
        end
        if (ll_write_finished) begin
          cl_if_activate        <=  0;
          state                 <=  IDLE;
          if (pio_response) begin
            //write the end status to the status pin
            d2h_status          <=  pio_e_status;
          end
        end
      end
      READ_DATA: begin
        //NOTE: the data_read_ready will automatically 'flow control' the data from the link layer
        //so we don't have to check it here
        //NOTE: We don't have to keep track of the count because the lower level will give a max of 2048 DWORDS
        if (ll_read_finished) begin
          //deactivate FIFO
          d2h_data_stb      <=  1;
          cl_of_activate    <=  0;
          state             <=  IDLE;
          if (pio_response) begin
            //write the end status to the status pin
            d2h_status        <=  pio_e_status;
          end
        end
      end
      default: begin
        state               <=  IDLE;
      end
    endcase
    if (sync_escape) begin
      state                 <=  IDLE;
    end
  end
end


endmodule


