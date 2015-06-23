// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module
  i2s_to_wb_tx_if
  #(
    parameter DMA_BUFFER_MAX_WIDTH = 12
  )
  (
    input           i2s_enable,
    input           i2s_ws_edge,
    input           i2s_ws_i,
    
    input           fifo_ack,
    
    output          fifo_ready,
    output  [31:0]  fifo_right_data,
    output  [31:0]  fifo_left_data,
    
    output  [31:0]  dma_rd_pointer_o,
    input   [31:0]  dma_rd_pointer_i,
    
    input           dma_rd_pointer_we,
    
    input   [(DMA_BUFFER_MAX_WIDTH - 1):0]  dma_word_size,
    input   [(DMA_BUFFER_MAX_WIDTH - 1):0]  dma_buffer_size,
    
    output          dma_overflow_error,

    input           i2s_clk_i,
    input           i2s_rst_i
  );
  
  //---------------------------------------------------
  // 
  wire  [31:0]  wbm_right_data_i;
  wire  [31:0]  wbm_right_data_o;
  wire  [31:0]  wbm_right_addr_o;
  wire  [3:0]   wbm_right_sel_o;
  wire          wbm_right_we_o;
  wire          wbm_right_cyc_o;
  wire          wbm_right_stb_o;
  wire          wbm_right_ack_i;
  wire          wbm_right_err_i;
  wire          wbm_right_rty_i;

    
  //---------------------------------------------------
  //  sync fifo_ack
  reg  [1:0]  fifo_ack_r;
  wire        fifo_ack_s = fifo_ack_r[1];

  always @(posedge i2s_clk_i)
    fifo_ack_r <= {fifo_ack_r[0], fifo_ack};
      

  //---------------------------------------------------
  //  sync i2s_ws_edge
  reg  [1:0]  i2s_ws_edge_r;
  wire        i2s_ws_edge_s = i2s_ws_edge_r[1];

  always @(posedge i2s_clk_i)
    i2s_ws_edge_r <= {i2s_ws_edge_r[0], i2s_ws_edge};
      

  //---------------------------------------------------
  //  sync i2s_ws_i
  reg  [1:0]  i2s_ws_i_r;
  wire        i2s_ws_i_s = i2s_ws_i_r[1];

  always @(posedge i2s_clk_i)
    i2s_ws_i_r <= {i2s_ws_i_r[0], i2s_ws_i};
    

  //---------------------------------------------------
  //
  wire [31:0] tone_out;

  tone_440_rom
    i_tone_440_rom
    (
      .addr(dma_rd_pointer_o[8:2]),
      .q(tone_out)
    );
    
    assign wbm_right_ack_i  = wbm_right_cyc_o & wbm_right_stb_o;
    assign wbm_right_data_i = tone_out;

    
  //---------------------------------------------------
  // fifo fsm
  wire fifo_empty;
  wire fifo_pop_right;
  wire fifo_pop_left;
  wire fifo_fsm_error;
  
  i2s_to_wb_fifo_fsm 
    i_i2s_to_wb_fifo_fsm
    (
      .i2s_ws_edge(i2s_ws_edge_s),
      .i2s_ws_i(i2s_ws_i_s),
      
      .fifo_enable(i2s_enable),
      .fifo_empty(fifo_empty),
      .fifo_ack(fifo_ack_s),
      
      .fifo_pop_right(fifo_pop_right),
      .fifo_pop_left(fifo_pop_left),
      .fifo_fsm_error(fifo_fsm_error),
      .fifo_ready(fifo_ready),
  
      .i2s_clk_i(i2s_clk_i),
      .i2s_rst_i(i2s_rst_i)
    );
    
    
  //---------------------------------------------------
  //  
  i2s_to_wb_tx_dma #( .DMA_BUFFER_MAX_WIDTH(DMA_BUFFER_MAX_WIDTH) )
    i_tx_dma_right
    (
      .wbm_data_i(wbm_right_data_i),
      .wbm_data_o(wbm_right_data_o),
      .wbm_addr_o(wbm_right_addr_o),
      .wbm_sel_o(wbm_right_sel_o),
      .wbm_we_o(wbm_right_we_o),
      .wbm_cyc_o(wbm_right_cyc_o),
      .wbm_stb_o(wbm_right_stb_o),
      .wbm_ack_i(wbm_right_ack_i),
      .wbm_err_i(wbm_right_err_i),
      .wbm_rty_i(wbm_right_rty_i),
    
      .i2s_enable(i2s_enable),
  
      .fifo_pop(fifo_pop_right),
      
      .fifo_empty(fifo_empty),
    
      .dma_rd_pointer_o(dma_rd_pointer_o),
      .dma_rd_pointer_i(dma_rd_pointer_i),
      
      .dma_rd_pointer_we(dma_rd_pointer_we),
      
      .dma_word_size(dma_word_size),
      .dma_buffer_size(dma_buffer_size),
      
      .dma_overflow_error(dma_overflow_error),
      
      .i2s_clk_i(i2s_clk_i),
      .i2s_rst_i(i2s_rst_i)
    );
  

  //---------------------------------------------------
  // assign outputs
  
  assign fifo_left_data   = 32'h0;
  assign fifo_right_data  = wbm_right_data_o;

  
endmodule



