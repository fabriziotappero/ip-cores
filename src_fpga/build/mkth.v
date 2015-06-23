module mkth(CLK,
	    RST,
	    
	    vga_controller_red,
	    RDY_vga_controller_red,
	    
	    vga_controller_blue,
	    RDY_vga_controller_blue,
	    
	    vga_controller_green,
	    RDY_vga_controller_green,
	    
	    vga_controller_sync_on_green,
	    RDY_vga_controller_sync_on_green,
	    
	    vga_controller_hsync,
	    RDY_vga_controller_hsync,
	    
	    vga_controller_vsync,
	    RDY_vga_controller_vsync,
	    
	    vga_controller_blank,
	    RDY_vga_controller_blank,
	    
	    vga_controller_switch_buffer_buffer,
	    EN_vga_controller_switch_buffer,
	    RDY_vga_controller_switch_buffer,
	    
	    vga_controller_data_resp_put,
	    EN_vga_controller_data_resp_put,
	    RDY_vga_controller_data_resp_put,
	    
	    EN_vga_controller_data_req_get,
	    vga_controller_data_req_get,
	    RDY_vga_controller_data_req_get,
	    
	    bram_controller_data_input_data,
	    EN_bram_controller_data_input,
	    RDY_bram_controller_data_input,
	    
	    bram_controller_wen_output,
	    RDY_bram_controller_wen_output,
	    
	    bram_controller_addr_output,
	    RDY_bram_controller_addr_output,
	    
	    bram_controller_data_output,
	    RDY_bram_controller_data_output,
	    
	    sram_controller_address_out,
	    RDY_sram_controller_address_out,
	    
	    sram_controller_data_O,
	    RDY_sram_controller_data_O,
	    
	    sram_controller_data_I,
	    EN_sram_controller_data_I,
	    RDY_sram_controller_data_I,
	    
	    sram_controller_data_T,
	    RDY_sram_controller_data_T,
	    
	    sram_controller_we_bytes_out,
	    RDY_sram_controller_we_bytes_out,
	    
	    sram_controller_we_out,
	    RDY_sram_controller_we_out,
	    
	    sram_controller_ce_out,
	    RDY_sram_controller_ce_out,
	    
	    sram_controller_oe_out,
	    RDY_sram_controller_oe_out,
	    
	    sram_controller_cen_out,
	    RDY_sram_controller_cen_out,
	    
	    sram_controller_adv_ld_out,
	    RDY_sram_controller_adv_ld_out,
	    
	    sram_controller2_address_out,
	    RDY_sram_controller2_address_out,
	    
	    sram_controller2_data_O,
	    RDY_sram_controller2_data_O,
	    
	    sram_controller2_data_I,
	    EN_sram_controller2_data_I,
	    RDY_sram_controller2_data_I,
	    
	    sram_controller2_data_T,
	    RDY_sram_controller2_data_T,
	    
	    sram_controller2_we_bytes_out,
	    RDY_sram_controller2_we_bytes_out,
	    
	    sram_controller2_we_out,
	    RDY_sram_controller2_we_out,
	    
	    sram_controller2_ce_out,
	    RDY_sram_controller2_ce_out,
	    
	    sram_controller2_oe_out,
	    RDY_sram_controller2_oe_out,
	    
	    sram_controller2_cen_out,
	    RDY_sram_controller2_cen_out,
	    
	    sram_controller2_adv_ld_out,
	    RDY_sram_controller2_adv_ld_out,
	    
	    error_status,
	    RDY_error_status);
  input  CLK;
  input  RST;
  
  // value method vga_controller_red
  output [7 : 0] vga_controller_red;
  output RDY_vga_controller_red;
  
  // value method vga_controller_blue
  output [7 : 0] vga_controller_blue;
  output RDY_vga_controller_blue;
  
  // value method vga_controller_green
  output [7 : 0] vga_controller_green;
  output RDY_vga_controller_green;
  
  // value method vga_controller_sync_on_green
  output vga_controller_sync_on_green;
  output RDY_vga_controller_sync_on_green;
  
  // value method vga_controller_hsync
  output vga_controller_hsync;
  output RDY_vga_controller_hsync;
  
  // value method vga_controller_vsync
  output vga_controller_vsync;
  output RDY_vga_controller_vsync;
  
  // value method vga_controller_blank
  output vga_controller_blank;
  output RDY_vga_controller_blank;
  
  // action method vga_controller_switch_buffer
  input  vga_controller_switch_buffer_buffer;
  input  EN_vga_controller_switch_buffer;
  output RDY_vga_controller_switch_buffer;
  
  // action method vga_controller_data_resp_put
  input  [31 : 0] vga_controller_data_resp_put;
  input  EN_vga_controller_data_resp_put;
  output RDY_vga_controller_data_resp_put;
  
  // actionvalue method vga_controller_data_req_get
  input  EN_vga_controller_data_req_get;
  output [51 : 0] vga_controller_data_req_get;
  output RDY_vga_controller_data_req_get;
  
  // action method bram_controller_data_input
  input  [31 : 0] bram_controller_data_input_data;
  input  EN_bram_controller_data_input;
  output RDY_bram_controller_data_input;
  
  // value method bram_controller_wen_output
  output [3 : 0] bram_controller_wen_output;
  output RDY_bram_controller_wen_output;
  
  // value method bram_controller_addr_output
  output [31 : 0] bram_controller_addr_output;
  output RDY_bram_controller_addr_output;
  
  // value method bram_controller_data_output
  output [31 : 0] bram_controller_data_output;
  output RDY_bram_controller_data_output;
  
  // value method sram_controller_address_out
  output [18 : 0] sram_controller_address_out;
  output RDY_sram_controller_address_out;
  
  // value method sram_controller_data_O
  output [31 : 0] sram_controller_data_O;
  output RDY_sram_controller_data_O;
  
  // action method sram_controller_data_I
  input  [31 : 0] sram_controller_data_I;
  input  EN_sram_controller_data_I;
  output RDY_sram_controller_data_I;
  
  // value method sram_controller_data_T
  output sram_controller_data_T;
  output RDY_sram_controller_data_T;
  
  // value method sram_controller_we_bytes_out
  output [3 : 0] sram_controller_we_bytes_out;
  output RDY_sram_controller_we_bytes_out;
  
  // value method sram_controller_we_out
  output sram_controller_we_out;
  output RDY_sram_controller_we_out;
  
  // value method sram_controller_ce_out
  output sram_controller_ce_out;
  output RDY_sram_controller_ce_out;
  
  // value method sram_controller_oe_out
  output sram_controller_oe_out;
  output RDY_sram_controller_oe_out;
  
  // value method sram_controller_cen_out
  output sram_controller_cen_out;
  output RDY_sram_controller_cen_out;
  
  // value method sram_controller_adv_ld_out
  output sram_controller_adv_ld_out;
  output RDY_sram_controller_adv_ld_out;
  
  // value method sram_controller2_address_out
  output [18 : 0] sram_controller2_address_out;
  output RDY_sram_controller2_address_out;
  
  // value method sram_controller2_data_O
  output [31 : 0] sram_controller2_data_O;
  output RDY_sram_controller2_data_O;
  
  // action method sram_controller2_data_I
  input  [31 : 0] sram_controller2_data_I;
  input  EN_sram_controller2_data_I;
  output RDY_sram_controller2_data_I;
  
  // value method sram_controller2_data_T
  output sram_controller2_data_T;
  output RDY_sram_controller2_data_T;
  
  // value method sram_controller2_we_bytes_out
  output [3 : 0] sram_controller2_we_bytes_out;
  output RDY_sram_controller2_we_bytes_out;
  
  // value method sram_controller2_we_out
  output sram_controller2_we_out;
  output RDY_sram_controller2_we_out;
  
  // value method sram_controller2_ce_out
  output sram_controller2_ce_out;
  output RDY_sram_controller2_ce_out;
  
  // value method sram_controller2_oe_out
  output sram_controller2_oe_out;
  output RDY_sram_controller2_oe_out;
  
  // value method sram_controller2_cen_out
  output sram_controller2_cen_out;
  output RDY_sram_controller2_cen_out;
  
  // value method sram_controller2_adv_ld_out
  output sram_controller2_adv_ld_out;
  output RDY_sram_controller2_adv_ld_out;
  
  // value method error_status
  output [7 : 0] error_status;
  output RDY_error_status;

  wire RST_N;
  assign RST_N = ~RST;

mkTH_fpga h264_mod(.CLK(CLK),
	    .RST_N(RST_N),
	    
	    .vga_controller_red(vga_controller_red),
	    .RDY_vga_controller_red(RDY_vga_controller_red),
	    
	    .vga_controller_blue(vga_controller_blue),
	    .RDY_vga_controller_blue(RDY_vga_controller_blue),
	    
	    .vga_controller_green(vga_controller_green),
	    .RDY_vga_controller_green(RDY_vga_controller_green),
	    
	    .vga_controller_sync_on_green(vga_controller_sync_on_green),
	    .RDY_vga_controller_sync_on_green(RDY_vga_controller_sync_on_green),
	    
	    .vga_controller_hsync(vga_controller_hsync),
	    .RDY_vga_controller_hsync(RDY_vga_controller_hsync),
	    
	    .vga_controller_vsync(vga_controller_vsync),
	    .RDY_vga_controller_vsync(RDY_vga_controller_vsync),
	    
	    .vga_controller_blank(vga_controller_blank),
	    .RDY_vga_controller_blank(RDY_vga_controller_blank),
	    
	    .vga_controller_switch_buffer_buffer(vga_controller_switch_buffer_buffer),
	    .EN_vga_controller_switch_buffer(EN_vga_controller_switch_buffer),
	    .RDY_vga_controller_switch_buffer(RDY_vga_controller_switch_buffer),
	    
	    .vga_controller_data_resp_put(vga_controller_data_resp_put),
	    .EN_vga_controller_data_resp_put(EN_vga_controller_data_resp_put),
	    .RDY_vga_controller_data_resp_put(RDY_vga_controller_data_resp_put),
	    
	    .EN_vga_controller_data_req_get(EN_vga_controller_data_req_get),
	    .vga_controller_data_req_get(vga_controller_data_req_get),
	    .RDY_vga_controller_data_req_get(RDY_vga_controller_data_req_get),
	    
	    .bram_controller_data_input_data(bram_controller_data_input_data),
	    .EN_bram_controller_data_input(EN_bram_controller_data_input),
	    .RDY_bram_controller_data_input(RDY_bram_controller_data_input),
	    
	    .bram_controller_wen_output(bram_controller_wen_output),
	    .RDY_bram_controller_wen_output(RDY_bram_controller_wen_output),
	    
	    .bram_controller_addr_output(bram_controller_addr_output),
	    .RDY_bram_controller_addr_output(RDY_bram_controller_addr_output),
	    
	    .bram_controller_data_output(bram_controller_data_output),
	    .RDY_bram_controller_data_output(RDY_bram_controller_data_output),
	    
	    .sram_controller_address_out(sram_controller_address_out),
	    .RDY_sram_controller_address_out(RDY_sram_controller_address_out),
	    
	    .sram_controller_data_O(sram_controller_data_O),
	    .RDY_sram_controller_data_O(RDY_sram_controller_data_O),
	    
	    .sram_controller_data_I_data(sram_controller_data_I),
	    .EN_sram_controller_data_I(EN_sram_controller_data_I),
	    .RDY_sram_controller_data_I(RDY_sram_controller_data_I),
	    
	    .sram_controller_data_T(sram_controller_data_T),
	    .RDY_sram_controller_data_T(RDY_sram_controller_data_T),
	    
	    .sram_controller_we_bytes_out(sram_controller_we_bytes_out),
	    .RDY_sram_controller_we_bytes_out(RDY_sram_controller_we_bytes_out),
	    
	    .sram_controller_we_out(sram_controller_we_out),
	    .RDY_sram_controller_we_out(RDY_sram_controller_we_out),
	    
	    .sram_controller_ce_out(sram_controller_ce_out),
	    .RDY_sram_controller_ce_out(RDY_sram_controller_ce_out),
	    
	    .sram_controller_oe_out(sram_controller_oe_out),
	    .RDY_sram_controller_oe_out(RDY_sram_controller_oe_out),
	    
	    .sram_controller_cen_out(sram_controller_cen_out),
	    .RDY_sram_controller_cen_out(RDY_sram_controller_cen_out),
	    
	    .sram_controller_adv_ld_out(sram_controller_adv_ld_out),
	    .RDY_sram_controller_adv_ld_out(RDY_sram_controller_adv_ld_out),
	    
	    .sram_controller2_address_out(sram_controller2_address_out),
	    .RDY_sram_controller2_address_out(RDY_sram_controller2_address_out),
	    
	    .sram_controller2_data_O(sram_controller2_data_O),
	    .RDY_sram_controller2_data_O(RDY_sram_controller2_data_O),
	    
	    .sram_controller2_data_I_data(sram_controller2_data_I),
	    .EN_sram_controller2_data_I(EN_sram_controller2_data_I),
	    .RDY_sram_controller2_data_I(RDY_sram_controller2_data_I),
	    
	    .sram_controller2_data_T(sram_controller2_data_T),
	    .RDY_sram_controller2_data_T(RDY_sram_controller2_data_T),
	    
	    .sram_controller2_we_bytes_out(sram_controller2_we_bytes_out),
	    .RDY_sram_controller2_we_bytes_out(RDY_sram_controller2_we_bytes_out),
	    
	    .sram_controller2_we_out(sram_controller2_we_out),
	    .RDY_sram_controller2_we_out(RDY_sram_controller2_we_out),
	    
	    .sram_controller2_ce_out(sram_controller2_ce_out),
	    .RDY_sram_controller2_ce_out(RDY_sram_controller2_ce_out),
	    
	    .sram_controller2_oe_out(sram_controller2_oe_out),
	    .RDY_sram_controller2_oe_out(RDY_sram_controller2_oe_out),
	   
	    .sram_controller2_cen_out(sram_controller2_cen_out),
	    .RDY_sram_controller2_cen_out(RDY_sram_controller2_cen_out),
	    
	    .sram_controller2_adv_ld_out(sram_controller2_adv_ld_out),
	    .RDY_sram_controller2_adv_ld_out(RDY_sram_controller2_adv_ld_out),
	    
	    .error_status(error_status),
	    .RDY_error_status(RDY_error_status));

endmodule
