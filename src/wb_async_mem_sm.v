// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module 
  wb_async_mem_sm
  #(
    parameter DW = 32,
    parameter AW = 32
  ) 
  (
    input   [(DW-1):0]  wb_data_i,
    input   [(AW-1):0]  wb_addr_i,
    output              wb_we_o,
    output              wb_cyc_o,
    output              wb_stb_o,
    input               wb_ack_i,
    input               wb_err_i,
    input               wb_rty_i,
    
    input   [(DW-1):0]  mem_d,
    input   [(AW-1):0]  mem_a,
    input               mem_oe_n,
    input   [3:0]       mem_bls_n,
    input               mem_we_n,
    input               mem_cs_n,
    
    input               mem_we_n_fall, 
    input               mem_oe_n_fall,
    
    output  [5:0]       dbg_state,
    
    input               wb_clk_i,
    input               wb_rst_i
  );
  
  
  // --------------------------------------------------------------------
  //  wires
  wire address_change;
  
  
  // --------------------------------------------------------------------
  //  state machine

  localparam   STATE_IDLE     = 6'b000001;
  localparam   STATE_WE       = 6'b000010;
  localparam   STATE_OE       = 6'b000100;
  localparam   STATE_DONE     = 6'b001000;
  localparam   STATE_ERROR    = 6'b010000;
  localparam   STATE_GLITCH   = 6'b100000;

  reg [5:0] state;
  reg [5:0] next_state;
  
  always @(posedge wb_clk_i or posedge wb_rst_i)
    if(wb_rst_i)
      state <= STATE_IDLE;
    else
      state <= next_state;

  always @(*)
    case( state )
      STATE_IDLE:       if( (mem_oe_n & mem_we_n) | mem_cs_n )
                          next_state = STATE_IDLE;
                        else
                          if( ~mem_oe_n & ~mem_we_n )
                            next_state = STATE_ERROR;
                          else
                            if( ~mem_we_n )
                              next_state = STATE_WE;
                            else  
                              next_state = STATE_OE;                              
                            
      STATE_WE:         if( mem_we_n | mem_cs_n )
                          next_state = STATE_ERROR;
                        else
                          if( wb_ack_i )
                            next_state = STATE_DONE;
                          else
                            next_state = STATE_WE;
                            
      STATE_OE:         if( mem_oe_n | mem_cs_n | address_change )
                          next_state = STATE_ERROR;
                        else
                          if( wb_ack_i )
                            next_state = STATE_DONE;
                          else
                            next_state = STATE_OE;
                            
      STATE_DONE:       if( mem_cs_n )
                          next_state = STATE_IDLE;  
                        else
                          if( mem_we_n_fall )
                            next_state = STATE_WE;
                          else if( mem_oe_n_fall ) 
                            next_state = STATE_OE;
                          else  
                            next_state = STATE_DONE;
                            
      STATE_ERROR:      next_state = STATE_IDLE;
                        
      STATE_GLITCH:     next_state = STATE_IDLE;
                        
      default:          next_state = STATE_GLITCH;
    endcase
    
    
// --------------------------------------------------------------------
//  wb_addr_i flop
  reg [(AW-1):0] wb_addr_i_r;
  assign address_change = (wb_addr_i != wb_addr_i_r);
  
  always @(posedge wb_clk_i)
    if( (state != STATE_DONE) | (state != STATE_OE) ) 
      wb_addr_i_r <= wb_addr_i;
      
    
// --------------------------------------------------------------------
//  outputs
  assign wb_cyc_o = (state == STATE_WE) | (state == STATE_OE);
  assign wb_stb_o = (state == STATE_WE) | (state == STATE_OE);
  assign wb_we_o  = (state == STATE_WE);
    
  assign dbg_state = state;
    
endmodule

