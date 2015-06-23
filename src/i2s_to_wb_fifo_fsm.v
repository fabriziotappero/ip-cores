//
//
//

`include "timescale.v"


module 
  i2s_to_wb_fifo_fsm
  (
    input   i2s_ws_edge,
    input   i2s_ws_i, 
    
    input   fifo_enable,
    input   fifo_empty,
    input   fifo_ack,
    
    output  fifo_pop_right,
    output  fifo_pop_left,
    output  fifo_fsm_error,
    output  fifo_ready,

    input   i2s_clk_i,
    input   i2s_rst_i
  );
  

  // -----------------------------
  //  state machine binary definitions
  parameter IDLE_STATE  = 4'b0001;
  parameter ACK_WAIT    = 4'b0010;
  parameter POP_STATE   = 4'b0100;
  parameter ERROR_STATE = 4'b1000;


  // -----------------------------
  //  state machine flop
  reg [3:0] state;
  reg [3:0] next_state;

  always @(posedge i2s_clk_i or posedge i2s_rst_i)
    if(i2s_rst_i)
      state <= IDLE_STATE;
    else
      state <= next_state;


  // -----------------------------
  //  state machine
  always @(*)
    case(state)
      IDLE_STATE:   if( fifo_enable & ~fifo_ack )
                      next_state <= ACK_WAIT;
                    else
                      next_state <= IDLE_STATE;

      ACK_WAIT:     if( ~fifo_enable )
                      next_state <= IDLE_STATE;
                    else if( fifo_ack )
                      next_state <= POP_STATE;
                    else
                      next_state <= ACK_WAIT;

      POP_STATE:    if( fifo_empty )
                      next_state <= ERROR_STATE;
                    else
                      next_state <= IDLE_STATE;

      ERROR_STATE:  next_state <= ACK_WAIT;

      default:      next_state <= ERROR_STATE;

    endcase
    
    
  // -----------------------------
  //  outputs
  assign fifo_pop_right = (state == POP_STATE) & i2s_ws_i; 
  assign fifo_pop_left  = (state == POP_STATE) & ~i2s_ws_i; 
  assign fifo_fsm_error = (state == ERROR_STATE);
  assign fifo_ready     = (state == ACK_WAIT);

endmodule

