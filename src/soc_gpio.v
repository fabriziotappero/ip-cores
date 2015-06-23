// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"
`include "gpio_defines.v"


module soc_gpio 
  #(
    parameter dw = 32,
    parameter aw = `GPIO_ADDRHH+1,
    parameter gw = `GPIO_IOS
  ) 
  (
    input   [31:0]  gpio_data_i,
    output  [31:0]  gpio_data_o,
    input   [31:0]  gpio_addr_i,
    input   [3:0]   gpio_sel_i,
    input           gpio_we_i,
    input           gpio_cyc_i,
    input           gpio_stb_i,
    output          gpio_ack_o,
    output          gpio_err_o,
    output          gpio_rty_o,
  
    input	  [gw-1:0]  gpio_a_aux_i,		
    input   [gw-1:0]  gpio_a_ext_pad_i,	
    output  [gw-1:0]  gpio_a_ext_pad_o,	
    output  [gw-1:0]  gpio_a_ext_padoe_o,	
    output            gpio_a_inta_o,
  
    input	  [gw-1:0]  gpio_b_aux_i,		
    input   [gw-1:0]  gpio_b_ext_pad_i,	
    output  [gw-1:0]  gpio_b_ext_pad_o,	
    output  [gw-1:0]  gpio_b_ext_padoe_o,	
    output            gpio_b_inta_o,
    
    input	  [gw-1:0]  gpio_c_aux_i,		
    input   [gw-1:0]  gpio_c_ext_pad_i,	
    output  [gw-1:0]  gpio_c_ext_pad_o,	
    output  [gw-1:0]  gpio_c_ext_padoe_o,	
    output            gpio_c_inta_o,
    
    input	  [gw-1:0]  gpio_d_aux_i,		
    input   [gw-1:0]  gpio_d_ext_pad_i,	
    output  [gw-1:0]  gpio_d_ext_pad_o,	
    output  [gw-1:0]  gpio_d_ext_padoe_o,	
    output            gpio_d_inta_o,
    
    input	  [gw-1:0]  gpio_e_aux_i,		
    input   [gw-1:0]  gpio_e_ext_pad_i,	
    output  [gw-1:0]  gpio_e_ext_pad_o,	
    output  [gw-1:0]  gpio_e_ext_padoe_o,	
    output            gpio_e_inta_o,
  
    input	  [gw-1:0]  gpio_f_aux_i,		
    input   [gw-1:0]  gpio_f_ext_pad_i,	
    output  [gw-1:0]  gpio_f_ext_pad_o,	
    output  [gw-1:0]  gpio_f_ext_padoe_o,	
    output            gpio_f_inta_o,
    
    input	  [gw-1:0]  gpio_g_aux_i,		
    input   [gw-1:0]  gpio_g_ext_pad_i,	
    output  [gw-1:0]  gpio_g_ext_pad_o,	
    output  [gw-1:0]  gpio_g_ext_padoe_o,	
    output            gpio_g_inta_o,
    
    input           gpio_clk_i,
    input           gpio_rst_i
  );
                  
                
  //---------------------------------------------------
  // GPIO muxes                  
  wire  [dw-1:0]  gpio_a_dat_o;	
  wire            gpio_a_ack_o;	
  wire            gpio_a_err_o;	
    
  wire  [dw-1:0]  gpio_b_dat_o;	
  wire            gpio_b_ack_o;	
  wire            gpio_b_err_o;	

  wire  [dw-1:0]  gpio_c_dat_o;	
  wire            gpio_c_ack_o;	
  wire            gpio_c_err_o;	

  wire  [dw-1:0]  gpio_d_dat_o;	
  wire            gpio_d_ack_o;	
  wire            gpio_d_err_o;	

  wire  [dw-1:0]  gpio_e_dat_o;	
  wire            gpio_e_ack_o;	
  wire            gpio_e_err_o;	

  wire  [dw-1:0]  gpio_f_dat_o;	
  wire            gpio_f_ack_o;	
  wire            gpio_f_err_o;	

  wire  [dw-1:0]  gpio_g_dat_o;	
  wire            gpio_g_ack_o;	
  wire            gpio_g_err_o;	

  wire stub_ack_o = gpio_cyc_i & gpio_stb_i;
  
  reg  [dw-1:0]  mux_dat_o;	
  reg            mux_ack_o;	
  reg            mux_err_o;	
  
  // gpio regs are from offset 0x00-0x24
  reg gpio_offset_range;
  
  always @(*)
    casez( gpio_addr_i[5:2] )
      4'b00_??: gpio_offset_range = 1'b1;
      4'b01_??: gpio_offset_range = 1'b1;
      4'b10_00: gpio_offset_range = 1'b1;
      4'b10_01: gpio_offset_range = 1'b1;
      default:  gpio_offset_range = 1'b0;
    endcase
    
  wire gpio_addr_range = ~( |gpio_addr_i[23:6] ) & gpio_offset_range;
    
  always @(*)
    case( {gpio_addr_range, gpio_addr_i[27:24] } )
      5'h1_0:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_a_dat_o, gpio_a_ack_o, gpio_a_err_o};
      5'h1_1:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_b_dat_o, gpio_b_ack_o, gpio_b_err_o};
      5'h1_2:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_c_dat_o, gpio_c_ack_o, gpio_c_err_o};
      5'h1_3:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_d_dat_o, gpio_d_ack_o, gpio_d_err_o};
      5'h1_4:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_e_dat_o, gpio_e_ack_o, gpio_e_err_o};
      5'h1_5:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_f_dat_o, gpio_f_ack_o, gpio_f_err_o};
      5'h1_6:   {mux_dat_o, mux_ack_o, mux_err_o} = {gpio_g_dat_o, gpio_g_ack_o, gpio_g_err_o};
      default:  {mux_dat_o, mux_ack_o, mux_err_o} = {32'h1bad_c0de, stub_ack_o, 1'b0};
    endcase
  
  assign  gpio_data_o = mux_dat_o;	
  assign  gpio_ack_o = mux_ack_o;	
  assign  gpio_err_o = mux_err_o;	
  
            
  //---------------------------------------------------
  // GPIO a
  gpio_top
    i_gpio_a(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h0) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_a_dat_o),
  	          .wb_ack_o(gpio_a_ack_o),
  	          .wb_err_o(gpio_a_err_o),
  	          .wb_inta_o(gpio_a_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_a_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_a_ext_pad_i),
  	          .ext_pad_o(gpio_a_ext_pad_o),
  	          .ext_padoe_o(gpio_a_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO b
  gpio_top
    i_gpio_b(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h1) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_b_dat_o),
  	          .wb_ack_o(gpio_b_ack_o),
  	          .wb_err_o(gpio_b_err_o),
  	          .wb_inta_o(gpio_b_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_b_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_b_ext_pad_i),
  	          .ext_pad_o(gpio_b_ext_pad_o),
  	          .ext_padoe_o(gpio_b_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO c
  gpio_top
    i_gpio_c(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h2) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_c_dat_o),
  	          .wb_ack_o(gpio_c_ack_o),
  	          .wb_err_o(gpio_c_err_o),
  	          .wb_inta_o(gpio_c_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_c_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_c_ext_pad_i),
  	          .ext_pad_o(gpio_c_ext_pad_o),
  	          .ext_padoe_o(gpio_c_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO d
  gpio_top
    i_gpio_d(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h3) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_d_dat_o),
  	          .wb_ack_o(gpio_d_ack_o),
  	          .wb_err_o(gpio_d_err_o),
  	          .wb_inta_o(gpio_d_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_d_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_d_ext_pad_i),
  	          .ext_pad_o(gpio_d_ext_pad_o),
  	          .ext_padoe_o(gpio_d_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO e
  gpio_top
    i_gpio_e(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h4) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_e_dat_o),
  	          .wb_ack_o(gpio_e_ack_o),
  	          .wb_err_o(gpio_e_err_o),
  	          .wb_inta_o(gpio_e_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_e_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_e_ext_pad_i),
  	          .ext_pad_o(gpio_e_ext_pad_o),
  	          .ext_padoe_o(gpio_e_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO f
  gpio_top
    i_gpio_f(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h5) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_f_dat_o),
  	          .wb_ack_o(gpio_f_ack_o),
  	          .wb_err_o(gpio_f_err_o),
  	          .wb_inta_o(gpio_f_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_f_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_f_ext_pad_i),
  	          .ext_pad_o(gpio_f_ext_pad_o),
  	          .ext_padoe_o(gpio_f_ext_padoe_o)
            );

  //---------------------------------------------------
  // GPIO g
  gpio_top
    i_gpio_g(
  	          .wb_clk_i(gpio_clk_i),
  	          .wb_rst_i(gpio_rst_i),
  	          .wb_cyc_i(gpio_cyc_i & (gpio_addr_i[27:24] == 4'h6) ),
  	          .wb_adr_i(gpio_addr_i[7:0]),
  	          .wb_dat_i(gpio_data_i),
  	          .wb_sel_i(gpio_sel_i),
  	          .wb_we_i(gpio_we_i),
  	          .wb_stb_i(gpio_stb_i),
  	          .wb_dat_o(gpio_g_dat_o),
  	          .wb_ack_o(gpio_g_ack_o),
  	          .wb_err_o(gpio_g_err_o),
  	          .wb_inta_o(gpio_g_inta_o),
  	          
`ifdef GPIO_AUX_IMPLEMENT
  	          .aux_i(gpio_g_aux_i),
`endif // GPIO_AUX_IMPLEMENT
  	          
`ifdef GPIO_CLKPAD
              .clk_pad_i(gpio_clk_i),
`endif //  GPIO_CLKPAD
              
  	          .ext_pad_i(gpio_g_ext_pad_i),
  	          .ext_pad_o(gpio_g_ext_pad_o),
  	          .ext_padoe_o(gpio_g_ext_padoe_o)
            );

            
  //---------------------------------------------------
  // outputs
  assign gpio_rty_o = 1'b0;
  

endmodule




