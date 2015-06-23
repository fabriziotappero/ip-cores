//
//
//


module camera_link
(
  input [3:0] x_data_in,
  input       x_clk,
  
  input [3:0] y_data_in,
  input       y_clk,
  
  input [3:0] z_data_in,
  input       z_clk,

  input       reset
);

  // --------------------------------------------------------------------
  //
  wire  [27:0]  x_data_out;
  wire          x_dval      = x_data_out[26];
  wire          x_fval      = x_data_out[25];
  wire          x_lval      = x_data_out[24];
  wire          x_spare     = x_data_out[23];
  
  channel_link 
    i_channel_link_x
      (
          .clk_in(x_clk),
          .data_in(x_data_in),
          .data_out(x_data_out),
          
          .reset(reset)
      );


  // --------------------------------------------------------------------
  //
  wire  [27:0]  y_data_out;
  wire          y_dval      = y_data_out[26];
  wire          y_fval      = y_data_out[25];
  wire          y_lval      = y_data_out[24];
  wire          y_spare     = y_data_out[23];
  
  channel_link 
    i_channel_link_y
      (
          .clk_in(y_clk),
          .data_in(y_data_in),
          .data_out(y_data_out),
          
          .reset(reset)
      );


  // --------------------------------------------------------------------
  //
  wire  [27:0]  z_data_out;
  wire          z_dval      = z_data_out[26];
  wire          z_fval      = z_data_out[25];
  wire          z_lval      = z_data_out[24];
  wire          z_spare     = z_data_out[23];
  
  channel_link 
    i_channel_link_z
      (
          .clk_in(z_clk),
          .data_in(z_data_in),
          .data_out(z_data_out),
          
          .reset(reset)
      );


  // --------------------------------------------------------------------
  //
  wire [7:0] cl_port_a = { x_data_out[5], x_data_out[27], x_data_out[6], x_data_out[4:0] };
  wire [7:0] cl_port_b = { x_data_out[11], x_data_out[10], x_data_out[14:12], x_data_out[9:7] };
  wire [7:0] cl_port_c = { x_data_out[17:16], x_data_out[22:18], x_data_out[15] };
  wire [7:0] cl_port_d = { y_data_out[5], y_data_out[27], y_data_out[6], y_data_out[4:0] };
  wire [7:0] cl_port_e = { y_data_out[11], y_data_out[10], y_data_out[14:12], y_data_out[9:7] };
  wire [7:0] cl_port_f = { y_data_out[17:16], y_data_out[22:18], y_data_out[15] };
  wire [7:0] cl_port_g = { z_data_out[5], z_data_out[27], z_data_out[6], z_data_out[4:0] };
  wire [7:0] cl_port_h = { z_data_out[11], z_data_out[10], z_data_out[14:12], z_data_out[9:7] };

  wire [13:0] fpa_pixel_0 = { cl_port_a[5:0], cl_port_b };
  wire [13:0] fpa_pixel_1 = { cl_port_c[5:0], cl_port_d };
  wire [13:0] fpa_pixel_2 = { cl_port_e[5:0], cl_port_f };
  wire [13:0] fpa_pixel_3 = { cl_port_g[5:0], cl_port_h };

endmodule



