// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  unbuffered_gear_box_fsm
  (
    input               ugb_enable,

    output              adc_bus_bank_select,
    output              adc_rd_en,
    output      [3:0]   gear_select,

    input               ugb_clock,
    input               ugb_reset
  );

  // -----------------------------
  //  state machine binary definitions
  localparam STATE_13_IN_05_RESIDUE = 6'b0_1_0000;
  localparam STATE_13_IN_10_RESIDUE = 6'b1_1_0001;
  localparam STATE_00_IN_02_RESIDUE = 6'b0_0_0010;
  localparam STATE_13_IN_07_RESIDUE = 6'b0_1_0011;
  localparam STATE_13_IN_12_RESIDUE = 6'b1_1_0100;
  localparam STATE_00_IN_04_RESIDUE = 6'b0_0_0101;
  localparam STATE_13_IN_09_RESIDUE = 6'b0_1_0110;
  localparam STATE_00_IN_01_RESIDUE = 6'b1_0_0111;
  localparam STATE_13_IN_06_RESIDUE = 6'b1_1_1000;
  localparam STATE_13_IN_11_RESIDUE = 6'b0_1_1001;
  localparam STATE_00_IN_03_RESIDUE = 6'b1_0_1010;
  localparam STATE_13_IN_08_RESIDUE = 6'b1_1_1011;
  localparam STATE_00_IN_00_RESIDUE = 6'b0_0_1100;


  // -----------------------------
  //  state machine flop
  reg [5:0] state;
  reg [5:0] next_state;

  always @(posedge ugb_clock)
    if(ugb_reset)
      state <= STATE_00_IN_00_RESIDUE;
    else
      state <= next_state;


  // -----------------------------
  //  state machine


  always @( * )
    case(state)
      STATE_13_IN_05_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_10_RESIDUE;
                              else
                                next_state = STATE_13_IN_05_RESIDUE;

      STATE_13_IN_10_RESIDUE: if( ugb_enable )
                                next_state = STATE_00_IN_02_RESIDUE;
                              else
                                next_state = STATE_13_IN_10_RESIDUE;

      STATE_00_IN_02_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_07_RESIDUE;
                              else
                                next_state = STATE_00_IN_02_RESIDUE;

      STATE_13_IN_07_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_12_RESIDUE;
                              else
                                next_state = STATE_13_IN_07_RESIDUE;

      STATE_13_IN_12_RESIDUE: if( ugb_enable )
                                next_state = STATE_00_IN_04_RESIDUE;
                              else
                                next_state = STATE_13_IN_12_RESIDUE;

      STATE_00_IN_04_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_09_RESIDUE;
                              else
                                next_state = STATE_00_IN_04_RESIDUE;

      STATE_13_IN_09_RESIDUE: if( ugb_enable )
                                next_state = STATE_00_IN_01_RESIDUE;
                              else
                                next_state = STATE_13_IN_09_RESIDUE;

      STATE_00_IN_01_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_06_RESIDUE;
                              else
                                next_state = STATE_00_IN_01_RESIDUE;

      STATE_13_IN_06_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_11_RESIDUE;
                              else
                                next_state = STATE_13_IN_06_RESIDUE;

      STATE_13_IN_11_RESIDUE: if( ugb_enable )
                                next_state = STATE_00_IN_03_RESIDUE;
                              else
                                next_state = STATE_13_IN_11_RESIDUE;

      STATE_00_IN_03_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_08_RESIDUE;
                              else
                                next_state = STATE_00_IN_03_RESIDUE;

      STATE_13_IN_08_RESIDUE: if( ugb_enable )
                                next_state = STATE_00_IN_00_RESIDUE;
                              else
                                next_state = STATE_13_IN_08_RESIDUE;

      STATE_00_IN_00_RESIDUE: if( ugb_enable )
                                next_state = STATE_13_IN_05_RESIDUE;
                              else
                                next_state = STATE_00_IN_00_RESIDUE;

      default:                next_state   = STATE_00_IN_00_RESIDUE;

    endcase


  // --------------------------------------------------------------------
  //  outputs
  assign gear_select          = state[3:0];
  assign adc_rd_en            = state[4];
  assign adc_bus_bank_select  = state[5];


endmodule

