// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module
  i2s_to_wb_tx_dma
  #(
    parameter DMA_BUFFER_MAX_WIDTH = 12
  )
  (
    input   [31:0]  wbm_data_i,
    output  [31:0]  wbm_data_o,
    output  [31:0]  wbm_addr_o,
    output  [3:0]   wbm_sel_o,
    output          wbm_we_o,
    output          wbm_cyc_o,
    output          wbm_stb_o,
    input           wbm_ack_i,
    input           wbm_err_i,
    input           wbm_rty_i,
  
    input           i2s_enable,

    input           fifo_pop,
    
    output          fifo_empty,
  
    output  [31:0]  dma_rd_pointer_o,
    input   [31:0]  dma_rd_pointer_i,
    
    input           dma_rd_pointer_we,
    
    input   [(DMA_BUFFER_MAX_WIDTH - 1):0]  dma_word_size,
    input   [(DMA_BUFFER_MAX_WIDTH - 1):0]  dma_buffer_size,
    
    output          dma_overflow_error,
    
    input           i2s_clk_i,
    output          i2s_rst_i
  );
  

  //---------------------------------------------------
  // fifo
  wire        fifo_wr_enable;
  wire        fifo_full;
    
  sync_fifo #( .depth(4), .width(32) )
    i_fifo
    (
     .clk(i2s_clk_i),
     .reset(i2s_rst_i),
     .wr_enable(fifo_wr_enable),
     .rd_enable( fifo_pop ),
     .empty(fifo_empty),
     .full(fifo_full),
     .rd_data(wbm_data_o),
     .wr_data(wbm_data_i),
     .count()
     );
     
     
  //---------------------------------------------------
  // 
  wire dma_fsm_error;
  
  i2s_to_wb_dma_fsm 
    i_i2s_to_wb_dma_fsm
    (
      .dma_enable(i2s_enable),
      .dma_ack_i(wbm_ack_i),
      
      .fifo_empty(fifo_empty),
      .fifo_full(fifo_full),
      
      .fifo_wr_enable(fifo_wr_enable),
      .dma_fsm_error(dma_fsm_error),
  
      .dma_clk_i(i2s_clk_i),
      .dma_rst_i(i2s_rst_i)
    );
    

  //---------------------------------------------------
  // 
  reg  [31:0]  dma_buffer_base_r;
  wire [31:DMA_BUFFER_MAX_WIDTH] dma_buffer_base_w = dma_buffer_base_r[31:DMA_BUFFER_MAX_WIDTH];
  
  always @(posedge i2s_clk_i)
    if( i2s_rst_i )
      dma_buffer_base_r <= 0;
    else if( dma_rd_pointer_we )
      dma_buffer_base_r <= dma_rd_pointer_i;
  

  //---------------------------------------------------
  // 
  reg  [DMA_BUFFER_MAX_WIDTH:0]  dma_rd_pointer_o_r;
  
  wire [(DMA_BUFFER_MAX_WIDTH - 1):0] dma_middle = dma_buffer_base_r[(DMA_BUFFER_MAX_WIDTH - 1):0] + {1'b0, dma_buffer_size[(DMA_BUFFER_MAX_WIDTH - 1):1]}; 
  wire [(DMA_BUFFER_MAX_WIDTH - 1):0] dma_bottom = dma_buffer_base_r[(DMA_BUFFER_MAX_WIDTH - 1):0] + dma_buffer_size - dma_word_size - 1;
  
  always @(posedge i2s_clk_i)
    if( dma_rd_pointer_we )
      dma_rd_pointer_o_r <= {1'b0, dma_buffer_base_r[(DMA_BUFFER_MAX_WIDTH - 1):0]};
    else if( dma_rd_pointer_o_r > dma_bottom )
      dma_rd_pointer_o_r <= {1'b0, dma_buffer_base_r[(DMA_BUFFER_MAX_WIDTH - 1):0]};
    else if(fifo_wr_enable)  
      dma_rd_pointer_o_r <= dma_rd_pointer_o_r + dma_word_size;
  

  //---------------------------------------------------
  // assign outputs
  
  assign dma_rd_pointer_o    = {dma_buffer_base_w, dma_rd_pointer_o_r[(DMA_BUFFER_MAX_WIDTH - 1):0]};
  assign dma_overflow_error  = dma_rd_pointer_o_r[DMA_BUFFER_MAX_WIDTH];
  
  assign wbm_addr_o = {dma_buffer_base_w, dma_rd_pointer_o_r[(DMA_BUFFER_MAX_WIDTH - 1):0]};
  assign wbm_sel_o  = 4'b1111;
  assign wbm_we_o   = 1'b0;
  assign wbm_cyc_o  = fifo_wr_enable;
  assign wbm_stb_o  = fifo_wr_enable;
  
endmodule


