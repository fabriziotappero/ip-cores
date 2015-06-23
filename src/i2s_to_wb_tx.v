// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module
  i2s_to_wb_tx
  (
    input   [31:0]  fifo_right_data,
    input   [31:0]  fifo_left_data,
    input           fifo_ready,
    
    output reg      fifo_ack,
    
    output          i2s_ws_edge,
  
    input           i2s_enable,
    input           i2s_sck_i,
    input           i2s_ws_i,
    output          i2s_sd_o
  );

  //---------------------------------------------------
  // fifo_ready edge detection
  reg [2:0] fifo_ready_r;
  wire      fifo_ready_s = fifo_ready_r[1];

  always @(posedge i2s_sck_i)
    fifo_ready_r <= {fifo_ready_r[1:0], fifo_ready};

  wire fifo_ready_rise_edge = (fifo_ready_r[1] ^ fifo_ready_r[2]) & fifo_ready_r[1];


  //---------------------------------------------------
  // i2s_ws_i edge detection
  reg [1:0] i2s_ws_i_r;

  always @(posedge i2s_sck_i)
    i2s_ws_i_r <= {i2s_ws_i_r[0], i2s_ws_i};

  wire i2s_ws_rise_edge;
  wire i2s_ws_fall_edge;

  assign i2s_ws_rise_edge = (i2s_ws_i_r[0] ^ i2s_ws_i_r[1]) & i2s_ws_i_r[0];  // right
  assign i2s_ws_fall_edge = (i2s_ws_i_r[0] ^ i2s_ws_i_r[1]) & ~i2s_ws_i_r[0]; // left


  //---------------------------------------------------
  //  data out shift reg
  reg  [31:0] sd_r;
  wire [31:0] sd_w = i2s_ws_i ? fifo_right_data : fifo_left_data;

  always @(negedge i2s_sck_i)
    if( i2s_ws_edge )
      sd_r <= sd_w;
    else
      sd_r <= {sd_r[30:0], 1'b0};

  //---------------------------------------------------
  // ack flop
  always @(posedge i2s_sck_i)
    if( fifo_ready_s & i2s_ws_edge )
      fifo_ack <= 1'b1;
    else if( ~fifo_ready_s )
      fifo_ack <= 1'b0;
  
  
  //---------------------------------------------------
  // assign outputs

  assign i2s_sd_o     = sd_r[31];
  assign i2s_ws_edge  = i2s_ws_rise_edge | i2s_ws_fall_edge;

endmodule



