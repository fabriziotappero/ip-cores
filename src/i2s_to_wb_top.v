// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module
  i2s_to_wb_top
  (
    input   [31:0]  wbs_data_i,
    output  [31:0]  wbs_data_o,
    input   [31:0]  wbs_addr_i,
    input   [3:0]   wbs_sel_i,
    input           wbs_we_i,
    input           wbs_cyc_i,
    input           wbs_stb_i,
    output          wbs_ack_o,
    output          wbs_err_o,
    output          wbs_rty_o,

    input           i2s_sck_i,
    input           i2s_ws_i,
    output          i2s_sd_o,

    input           i2s_clk_i,
    input           i2s_rst_i
  );
  
  
  //---------------------------------------------------
  // register encoder
  reg [3:0] register_index_r;

  always @(*)
    case( wbs_addr_i[19:0] )
      20'h0_0000: register_index_r = 4'h0;
      20'h0_0004: register_index_r = 4'h1;
      20'h0_0008: register_index_r = 4'h2;
      20'h0_000c: register_index_r = 4'h3;
      20'h0_0010: register_index_r = 4'h4;
      default:    register_index_r = 4'hf;
    endcase


  //---------------------------------------------------
  // register offset 0x0  -- 
  reg [31:0]  i2s_register_0;
  wire        i2s_register_0_we = (wbs_cyc_i & wbs_stb_i & wbs_we_i) & (register_index_r == 4'h0);

  always @( posedge i2s_clk_i )
    if( i2s_rst_i )
      i2s_register_0 <= 32'h00000000;
    else if( i2s_register_0_we )
      i2s_register_0 <= wbs_data_i;


  //---------------------------------------------------
  // register offset 0x4  -- 
  reg [31:0]  i2s_register_1;

  always @( posedge i2s_clk_i )
    if( i2s_rst_i )
      i2s_register_1 <= 32'h00000000;
    else if( (wbs_cyc_i & wbs_stb_i & wbs_we_i) & (register_index_r == 4'h1) )
      i2s_register_1 <= wbs_data_i;
      

  //---------------------------------------------------
  // register offset 0x8  -- read only
  wire [31:0] i2s_register_2;
  

  //---------------------------------------------------
  // register offset 0xc  -- read only
  wire [31:0] i2s_register_3;

  
  //---------------------------------------------------
  // register offset 0x10  -- write only
  wire [31:0] i2s_register_4;
  wire        i2s_register_4_we = (wbs_cyc_i & wbs_stb_i & wbs_we_i) & (register_index_r == 4'h4);

  
  //---------------------------------------------------
  // register mux
  reg [31:0]  wbs_data_o_r;

  always @(*)
    case( register_index_r )
      4'h0:     wbs_data_o_r = i2s_register_0;
      4'h1:     wbs_data_o_r = i2s_register_1;
      4'h2:     wbs_data_o_r = i2s_register_2;
      4'h3:     wbs_data_o_r = i2s_register_3;
      4'h4:     wbs_data_o_r = i2s_register_4;
      4'hf:     wbs_data_o_r = 32'h1bad_c0de;
      default:  wbs_data_o_r = 32'h1bad_c0de;
    endcase
    

  //---------------------------------------------------
  // wishbone clock domain
  wire        i2s_ws_edge;
  wire [31:0] fifo_right_data; 
  wire [31:0] fifo_left_data; 
  wire        fifo_ack;
  wire        fifo_ready;
  
  i2s_to_wb_tx_if #( .DMA_BUFFER_MAX_WIDTH(12) )
    i_i2s_to_wb_tx_if
    (
      .i2s_enable(i2s_register_0[0]),
      .i2s_ws_edge(i2s_ws_edge),
      .i2s_ws_i(i2s_ws_i),
      
      .fifo_ack(fifo_ack),
      
      .fifo_ready(fifo_ready),
      .fifo_right_data(fifo_right_data),
      .fifo_left_data(fifo_left_data),
      
      .dma_rd_pointer_i( wbs_data_i ),
      .dma_rd_pointer_o( i2s_register_4 ),
      
      .dma_rd_pointer_we( i2s_register_4_we ),
      .dma_word_size( {9'h0, 3'b100} ),
      .dma_buffer_size( 12'h1BC ),
      
      .dma_overflow_error(),
  
      .i2s_clk_i(i2s_clk_i),
      .i2s_rst_i(i2s_rst_i)
    );
    
    
  //---------------------------------------------------
  // i2s clock domain
  
  i2s_to_wb_tx
    i_i2s_to_wb_tx
    (
      .fifo_right_data(fifo_right_data),
      .fifo_left_data(fifo_left_data),
      .fifo_ready(fifo_ready),
      
      .fifo_ack(fifo_ack),
    
      .i2s_ws_edge(i2s_ws_edge),
    
      .i2s_enable(i2s_register_0[0]),
      .i2s_sck_i(i2s_sck_i),
      .i2s_ws_i(i2s_ws_i),
      .i2s_sd_o(i2s_sd_o)
    );
    
    
  //---------------------------------------------------
  // assign outputs
  
  assign wbs_data_o = wbs_data_o_r;
  assign wbs_ack_o  = wbs_cyc_i & wbs_stb_i;
  assign wbs_err_o  = 1'b0;
  assign wbs_rty_o  = 1'b0;
  

endmodule
