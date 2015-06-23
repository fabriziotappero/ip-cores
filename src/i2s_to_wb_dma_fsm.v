//
//
//

`include "timescale.v"


module 
  i2s_to_wb_dma_fsm
  (
    input           dma_enable,
    input           dma_ack_i,
    
    input           fifo_empty,
    input           fifo_full,
    
    output          fifo_wr_enable,
    
    output          dma_fsm_error,

    input           dma_clk_i,
    input           dma_rst_i
  );
  

  // -----------------------------
  //  state machine binary definitions
  parameter IDLE_STATE  = 4'b0001;
  parameter DMA_STATE   = 4'b0010;
  parameter WAIT_STATE  = 4'b0100;
  parameter ERROR_STATE = 4'b1000;


  // -----------------------------
  //  state machine flop
  reg [3:0] state;
  reg [3:0] next_state;

  always @(posedge dma_clk_i)
    if(dma_rst_i)
      state <= IDLE_STATE;
    else
      state <= next_state;


  // -----------------------------
  //  state machine
  always @(*)
    case(state)
      IDLE_STATE:   if( dma_enable & fifo_empty )
                      next_state <= DMA_STATE;
                    else
                      next_state <= IDLE_STATE;

      DMA_STATE:    if( ~dma_enable | fifo_full )
                      next_state <= IDLE_STATE;
                    else if( ~dma_ack_i )
                      next_state <= WAIT_STATE;
                    else
                      next_state <= DMA_STATE;

      WAIT_STATE:   if( dma_ack_i )
                      next_state <= DMA_STATE; 
                    else
                      next_state <= WAIT_STATE;

      ERROR_STATE:  next_state <= IDLE_STATE;

      default:      next_state <= ERROR_STATE;

    endcase
    
         
  // -----------------------------
  //  outputs
  assign fifo_wr_enable = ( (state == DMA_STATE) | (state == WAIT_STATE) ) & (next_state != WAIT_STATE) & dma_enable & ~fifo_full;
  assign dma_fsm_error  = (state == ERROR_STATE);
  

endmodule

