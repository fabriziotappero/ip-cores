//sata_link_layer_write.v
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



//THERE APPEARS TO BE AN ERROR WHEN WRITING TO A HARDDRIVE, IT MANIFESTS AS A CRC ERROR

`include "sata_defines.v"

`define MIN_HOLDA_TIMEOUT 4
`define DHOLD_DELAY       8
`define DHOLD_DELAY_EN    0

module sata_link_layer_write(

  input               rst,            //reset
  input               clk,

  input               phy_ready,
  output              write_ready,
  input               en,
  output              idle,
  input               send_sync_escape,

  input               detect_align,
  input               detect_sync,
  input               detect_x_rdy,
  input               detect_r_rdy,
  input               detect_r_ip,
  input               detect_r_err,
  input               detect_r_ok,
  input               detect_cont,
  input               detect_hold,
  input               detect_holda,


  output  reg         send_holda,

  output      [31:0]  tx_dout,
  output              tx_isk,

  input       [31:0]  rx_din,
  input       [3:0]   rx_isk,

  input               write_start,
  output  reg         write_strobe,
  input       [31:0]  write_data,
  input       [31:0]  write_size,  //maximum 2048
  input               write_hold,
  output  reg         write_finished,
  output  reg         xmit_error,
  output  reg         wsize_z_error,
  input               write_abort,
  input               data_scrambler_en,
  input               is_device,
  output  reg [3:0]   state,
  output  reg [3:0]   fstate,

  output  reg         last_prim,
  output  reg         send_crc,
  output  reg         post_align_write,

  output  reg [23:0]  in_data_addra,
  output  reg [12:0]  d_count,
  output  reg [12:0]  write_count,
  output  reg [3:0]   buffer_pos

);

//Primatives
parameter           IDLE            = 4'h0;

//fstate
parameter           FIRST_DATA      = 4'h1;
parameter           ENQUEUE         = 4'h2;
parameter           WRITE_CRC       = 4'h3;
parameter           WAIT            = 4'h4;

//state
parameter           WRITE_START     = 4'h1;
parameter           WRITE           = 4'h2;
parameter           WRITE_END       = 4'h3;
parameter           WAIT_RESPONSE   = 4'h4;

//Registers/Wires
reg         [31:0]  post_align_data;

reg                 send_x_rdy;
reg                 send_sof;
reg                 send_eof;
reg                 send_wtrm;
reg                 send_cont;
reg                 send_hold;
//reg                 send_holda;
reg                 send_sync;

//Transport
reg       [31:0]    align_data_out;
reg                 prev_phy_ready;
wire                pos_phy_ready;
wire                neg_phy_ready;

reg                 prev_hold;
//wire                pos_hold;
wire                neg_holda;
reg       [3:0]     min_holda_count;
wire                min_holda_timeout;

reg       [3:0]     dhold_delay_cnt;
reg                 dhold_delay;



//CRC
//XXX: Tie the CRC_EN to the read strobe
wire      [31:0]    crc_dout;
reg       [31:0]    crc_data;

//Scrambler
reg                 scr_rst;
reg                 scr_en;
reg       [31:0]    scr_din;
wire      [31:0]    scr_dout;

//Internal FIFOs
reg       [23:0]    data_size;
reg                 wr_en;

wire      [31:0]    rd_dout;
wire                empty;
wire                enable_write_transaction;

reg       [31:0]    bump_buffer [0:3];
reg       [3:0]     data_pointer;


//XXX: Fix this aweful HACK!
wire      [31:0]    d0_buf;
wire      [31:0]    d1_buf;
wire      [31:0]    d2_buf;
wire      [31:0]    d3_buf;


//Sub Modules
blk_mem # (
  .DATA_WIDTH     (32                   ),
  .ADDRESS_WIDTH  (13                   )
)br(
  .clka           (clk                  ),
  .wea            (wr_en                ),
  .addra          (in_data_addra[12:0]  ),
  .dina           (scr_dout             ),

  .clkb           (clk                  ),
  .addrb          (write_count[12:0]    ),
  .doutb          (rd_dout              )
);


scrambler scr (
  .rst            (scr_rst              ),
  .clk            (clk                  ),
  .prim_scrambler (1'b0                 ),
  .en             (scr_en               ),
  .din            (scr_din              ),
  .dout           (scr_dout             )
);
crc c (
//reset the CRC any time we're in IDLE
  .rst            (scr_rst              ),
  .clk            (clk                  ),
  .en             (write_strobe         ),
  .din            (write_data           ),
  .dout           (crc_dout             )
);


//Asynchronous Logic
assign              idle  = (state == IDLE);

assign              tx_dout = (send_x_rdy)  ? `PRIM_X_RDY:
                              (send_sof)    ? `PRIM_SOF:
                              (send_eof)    ? `PRIM_EOF:
                              (send_wtrm)   ? `PRIM_WTRM:
                              (send_cont)   ? `PRIM_CONT:
                              (send_hold)   ? `PRIM_HOLD:
                              (send_holda)  ? `PRIM_HOLDA:
                              (send_sync)   ? `PRIM_SYNC:
                              bump_buffer[buffer_pos];

assign              tx_isk  = ( send_x_rdy  ||
                                send_sof    ||
                                send_eof    ||
                                send_wtrm   ||
                                send_cont   ||
                                send_hold   ||
                                send_holda  ||
                                send_sync);

assign              enable_write_transaction  = (in_data_addra != 0);
assign              empty                     = (in_data_addra == 0);
assign              pos_phy_ready             = phy_ready && ~prev_phy_ready;
assign              neg_phy_ready             = ~phy_ready  && prev_phy_ready;
//assign              pos_hold                  = detect_hold  && ~prev_hold;
assign              min_holda_timeout         = (min_holda_count >= `MIN_HOLDA_TIMEOUT);

assign              d0_buf                    = bump_buffer[0];
assign              d1_buf                    = bump_buffer[1];
assign              d2_buf                    = bump_buffer[2];
assign              d3_buf                    = bump_buffer[3];
assign              write_ready               = phy_ready && !send_holda;


//Synchronous Logic
//Incomming buffer (this is the buffer afte the scrambler and CRC)
always @ (posedge clk) begin
  if (rst) begin
    fstate          <=  IDLE;
    data_size       <=  0;
    in_data_addra   <=  0;
    scr_din         <=  0;
    scr_en          <=  0;
    scr_rst         <=  1;
    wr_en           <=  0;
    write_strobe    <=  0;
    crc_data        <=  0;
  end
  else begin
    //Strobes
    scr_en          <=  0;
    wr_en           <=  0;
    write_strobe    <=  0;
    scr_rst         <=  0;


    case (fstate)
      IDLE: begin
        in_data_addra     <=  0;
        if (write_start) begin
          //add an extra space for the CRC
          write_strobe    <=  1;
          data_size       <=  write_size;
          scr_en          <=  1;
          scr_din         <=  0;
          fstate          <=  FIRST_DATA;
        end
      end
      FIRST_DATA: begin
          write_strobe    <=  1;
          wr_en           <=  1;
          scr_en          <=  1;
          scr_din         <=  write_data;
          fstate          <=  ENQUEUE;
      end
      ENQUEUE: begin
        if (data_size == 1) begin
          in_data_addra   <=  in_data_addra + 1;
          wr_en           <=  1;
          scr_en          <=  1;
          scr_din         <=  crc_dout;
          fstate          <=  WRITE_CRC;
        end
        else begin
          if (in_data_addra < data_size - 1) begin
//          if (in_data_addra < data_size) begin
            //Put all the data into the FIFO
            write_strobe    <=  1;
            wr_en           <=  1;
            scr_en          <=  1;
            in_data_addra   <=  in_data_addra + 1;
            scr_din         <=  write_data;
          end
          else begin
            //put the CRC into the FIFO
            //in_data_addra   <=  in_data_addra + 1;
            wr_en           <=  1;
            scr_en          <=  1;
            in_data_addra   <=  in_data_addra + 1;
            scr_din         <=  crc_dout;
            fstate          <=  WRITE_CRC;
          end
        end
      end
      WRITE_CRC: begin
        fstate            <=  WAIT;
      end
      WAIT: begin
        scr_rst           <=  1;
        if (state == WRITE) begin
          //Because a transaction is in progress and our write buffer is full we can reset the in address to 0
          in_data_addra   <=  0;
        end
        if (write_finished) begin
          fstate          <=  IDLE;
          data_size       <=  0;
        end
      end
      default: begin
        fstate            <=  IDLE;
      end
    endcase
    if (send_sync_escape) begin
      fstate              <=  IDLE;
      data_size           <=  0;
    end
  end
end


//Detect Hold Delay
always @ (posedge clk) begin
  if (rst) begin
    dhold_delay     <=  0;
    dhold_delay_cnt <=  0;

  end
  else begin

    if (dhold_delay_cnt < `DHOLD_DELAY) begin
      dhold_delay_cnt <=  dhold_delay_cnt + 1;
    end
    else begin
      dhold_delay   <=  1;
    end

    //Always deassert dhold_delay whenever detect hold goes low
    if (!detect_hold) begin
      dhold_delay_cnt <=  0;
      dhold_delay     <=  0;
    end
  end
end



always @ (posedge clk) begin
  if (rst) begin
    state           <=  IDLE;

    post_align_write  <=  0;
    post_align_data <=  32'h0;

    send_x_rdy      <=  0;
    send_sof        <=  0;
    send_eof        <=  0;
    send_wtrm       <=  0;
    send_cont       <=  0;
    send_hold       <=  0;
    send_holda      <=  0;
    send_crc        <=  0;
    send_sync       <=  0;

    write_count     <=  0;
    //write_strobe    <=  0;
    write_finished  <=  0;

    //error strobe
    xmit_error      <=  0;
    wsize_z_error   <=  0;
    last_prim       <=  0;
    align_data_out  <=  0;
    min_holda_count <=  `MIN_HOLDA_TIMEOUT;
    prev_phy_ready  <=  0;
    prev_hold       <=  0;

    bump_buffer[0]  <=  0;
    bump_buffer[1]  <=  0;
    bump_buffer[2]  <=  0;
    bump_buffer[3]  <=  0;

    d_count         <=  0;
    buffer_pos      <=  0;

  end
  else begin
    if ((state == WRITE_START) || ((state != IDLE) &&  (d_count != write_count))) begin
      bump_buffer[3]  <=  bump_buffer[2];
      bump_buffer[2]  <=  bump_buffer[1];
      bump_buffer[1]  <=  bump_buffer[0];
      bump_buffer[0]  <=  rd_dout;
      d_count         <=  write_count;
    end

    //write_strobe    <=  0;
    write_finished  <=  0;

    xmit_error      <=  0;
    wsize_z_error   <=  0;

    //previous
    prev_phy_ready  <=  phy_ready;

`ifdef DHOLD_DELAY_EN
    prev_hold     <=  dhold_delay;
`else
    prev_hold     <=  detect_hold;
`endif

    if (min_holda_count < `MIN_HOLDA_TIMEOUT) begin
      min_holda_count <=  min_holda_count + 1;
    end

    if (phy_ready) begin
      send_sync     <=  0;
      send_x_rdy    <=  0;
      send_sof      <=  0;
      send_eof      <=  0;
      send_wtrm     <=  0;
      send_cont     <=  0;
      send_hold     <=  0;
      send_holda    <=  0;
      send_crc      <=  0;
      last_prim     <=  0;
    end

    case (state)
      IDLE: begin
        buffer_pos  <=  0;
        send_sync   <=  1;
        if (enable_write_transaction) begin
          //There is some data within the input write buffer
          state         <=  WRITE_START;
          write_count   <=  0;
          d_count       <=  0;
        end
      end
      WRITE_START: begin
        if (phy_ready) begin
          send_sync   <=  1;
          if (!is_device && detect_x_rdy) begin
            //hard drive wins the draw :(
            state         <=  IDLE;
          end
          else if (detect_r_rdy) begin
            state         <=  WRITE;
            send_sof      <=  1;
            //bump_buffer[buffer_pos]      <=  rd_dout;
            write_count   <=  write_count + 1;
            //Send First Read
            //read the first packet of data
          end
          else begin
            send_x_rdy      <=  1;
          end
        end
      end
      WRITE: begin
        if (!write_ready) begin
          if (neg_phy_ready && (buffer_pos == 0)) begin
            buffer_pos        <=  buffer_pos + 1;
          end

`ifdef DHOLD_DELAY_EN
          if (dhold_delay || !min_holda_timeout) begin
`else
          if (detect_hold || !min_holda_timeout) begin
`endif
            //Haven't sent out a holda yet
            send_holda        <=  1;
          end
          else begin

          //Detect the remote side finishing up with a hold
          //if (!detect_hold && min_holda_timeout) begin
            if (send_holda && !last_prim) begin
              last_prim       <=  1;
              send_holda      <=  1;
            end
          end
        end

        else begin
          if (write_count <= data_size + 1) begin
            if (buffer_pos > 0) begin
              buffer_pos      <=  buffer_pos - 1;
              if (buffer_pos == 1) begin
                write_count   <=  write_count + 1;
              end
            end
            else begin
              write_count     <=  write_count + 1;
            end
          end
          else begin
           send_eof          <=  1;
           state             <=  WAIT_RESPONSE;
          end
        end

//I can use this to see if the phy is ready too
`ifdef DHOLD_DELAY_EN
        if (dhold_delay && (buffer_pos == 0)) begin
`else
        if (detect_hold && (buffer_pos == 0)) begin
`endif
          min_holda_count         <=  0;
//XXX: I may need this to capture holds at the end of a trnasfer
          buffer_pos              <=  buffer_pos + 1;
          send_holda              <=  1;
        end
      end
      WRITE_END: begin
        state             <=  WAIT_RESPONSE;
      end
      WAIT_RESPONSE: begin
        send_wtrm           <=  1;
        if (detect_r_err) begin
          write_finished    <=  1;
          xmit_error        <=  1;
          state             <=  IDLE;
        end
        else if (detect_r_ok) begin
          write_finished    <=  1;
          state             <=  IDLE;
        end
      end
      default: begin
        state               <=  IDLE;
      end
    endcase
    if (send_sync_escape) begin
      send_sync             <=  1;
      state                 <=  IDLE;
      buffer_pos            <=  0;
      write_count           <=  0;
      d_count               <=  0;
    end
  end
end


endmodule
