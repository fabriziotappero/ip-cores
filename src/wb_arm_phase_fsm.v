//
//
//

`timescale 1ns / 100ps



module 
  wb_arm_phase_fsm(
    input       ahb_hclk,
    input       ahb_hreset,
    input       ahb_hsel,
    input       ahb_hready_in,
    input       ahb_hready_out,
    input [1:0] ahb_htrans,
    output      ahb_data_phase,
    output      fsm_error
  );

  // -----------------------------
  //  do_transfer if not IDLE or BUSY
  wire do_transfer = (ahb_htrans == 2'b10) | (ahb_htrans == 2'b11);


  // -----------------------------
  //  state machine binary definitions
  parameter IDLE_STATE  = 3'b001;
  parameter DATA_STATE  = 3'b010;
  parameter ERROR_STATE = 3'b100;


  // -----------------------------
  //  state machine flop
  reg [2:0] state;
  reg [2:0] next_state;

  always @(posedge ahb_hclk)
    if(~ahb_hreset)
      state <= IDLE_STATE;
    else
      state <= next_state;


  // -----------------------------
  //  state machine
  always @(*)
    case(state)
      IDLE_STATE:   if( ahb_hsel & ahb_hready_in & do_transfer)
                      next_state <= DATA_STATE;
                    else
                      next_state <= IDLE_STATE;

      DATA_STATE:   if( ahb_hready_out )
                      next_state <= IDLE_STATE;
                    else
                      next_state <= DATA_STATE;

      ERROR_STATE:  next_state <= IDLE_STATE;

      default:      next_state <= ERROR_STATE;

    endcase


  // -----------------------------
  //  outputs
  assign ahb_data_phase = (state == DATA_STATE);
  assign fsm_error      = (state == ERROR_STATE);


endmodule

