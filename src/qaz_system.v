// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module qaz_system(
                    input   [31:0]  sys_data_i,
                    output  [31:0]  sys_data_o,
                    input   [31:0]  sys_addr_i,
                    input   [3:0]   sys_sel_i,
                    input           sys_we_i,
                    input           sys_cyc_i,
                    input           sys_stb_i,
                    output          sys_ack_o,
                    output          sys_err_o,
                    output          sys_rty_o,
                    
                    input           async_rst_i,
                    
                    output reg      sys_audio_clk_en,
                    
                    output    [6:0]   hex0,
                    output    [6:0]   hex1,
                    output    [6:0]   hex2,
                    output    [6:0]   hex3,
    
                    input           sys_clk_i, 
                    output          sys_rst_o
                  );
                  

  //---------------------------------------------------
  // register encoder
  reg [3:0] register_offset_r;
                  
  always @(*)
    case( sys_addr_i[19:0] )
      20'h0_0000: register_offset_r = 4'h0;
      20'h0_0004: register_offset_r = 4'h4;
      default:    register_offset_r = 4'hf;
    endcase
    
                  
  //---------------------------------------------------
  // register offset 0x0  -- system control register
  reg sys_rst_r;
  
  always @( posedge sys_clk_i )
    if( sys_rst_o )
      sys_rst_r <= 1'h0;
    else if( (sys_cyc_i & sys_stb_i & sys_we_i) & (register_offset_r == 4'h0) )
      sys_rst_r <= sys_data_i[0];
      
  always @( posedge sys_clk_i )
    if( sys_rst_o )
      sys_audio_clk_en <= 1'h0;
    else if( (sys_cyc_i & sys_stb_i & sys_we_i) & (register_offset_r == 4'h0) )
      sys_audio_clk_en <= sys_data_i[4];
      
  wire [31:0]  sys_register_0 = { 
                                  27'b0, 
                                  sys_audio_clk_en,
                                  3'b000,
                                  sys_rst_r 
                                };
    
  
  //---------------------------------------------------
  // register offset 0x4  -- hex led display register
  reg [31:0]  sys_register_4;
  
  always @( posedge sys_clk_i )
    if( sys_rst_o )
      sys_register_4 <= 32'h0000ffff;
    else if( (sys_cyc_i & sys_stb_i & sys_we_i) & (register_offset_r == 4'h4) )
      sys_register_4 <= sys_data_i;
    
  
  //---------------------------------------------------
  // register mux
  reg [31:0]  sys_data_o_r;
  
  always @(*)
    case( register_offset_r )
      4'h0:     sys_data_o_r = sys_register_0;
      4'h4:     sys_data_o_r = sys_register_4;
      4'hf:     sys_data_o_r = 32'h1bad_c0de;
      default:  sys_data_o_r = 32'h1bad_c0de;
    endcase
  

  //---------------------------------------------------
  // sync reset
  sync 
    i_sync_reset( 
            .async_sig( async_rst_i | sys_rst_r ), 
            .sync_out(sys_rst_o), 
            .clk(sys_clk_i) 
          );
          
                  
  //---------------------------------------------------
  // hex led encoders
  hex_led_encoder
    i_hex0(
            .encoder(hex0),
            .nibble(sys_register_4[3:0])
          );
          
  hex_led_encoder
    i_hex1(
            .encoder(hex1),
            .nibble(sys_register_4[7:4])
          );
          
  hex_led_encoder
    i_hex2(
            .encoder(hex2),
            .nibble(sys_register_4[11:8])
          );
          
  hex_led_encoder
    i_hex3(
            .encoder(hex3),
            .nibble(sys_register_4[15:12])
          );
          
                                                       
  //---------------------------------------------------
  // outputs
  assign sys_data_o = sys_data_o_r;
  assign sys_ack_o = sys_cyc_i & sys_stb_i;
  assign sys_err_o = 1'b0;
  assign sys_rty_o = 1'b0;

endmodule

