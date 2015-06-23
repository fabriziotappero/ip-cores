//
//
//


module channel_link
(
    input               clk_in,
    input       [3:0]   data_in,
    output  reg [27:0]  data_out,
    
    input               reset
);

  // --------------------------------------------------------------------
  //

  wire [3:0]  clk_7x_index;
  wire        clkout_7x;
  
  camera_link_clk i_camera_link_clk
  (
    .clk_in(clk_in),
  
    .clk_7x_index(clk_7x_index),
    .clk_out_7x(clkout_7x),
    .clock_good(),
  
    .reset(reset)
  );
  

  // --------------------------------------------------------------------
  //
  reg payload [6:0] [3:0];

  always @(negedge clkout_7x)
    begin
      payload[clk_7x_index][0] <= data_in[0];
      payload[clk_7x_index][1] <= data_in[1];
      payload[clk_7x_index][2] <= data_in[2];
      payload[clk_7x_index][3] <= data_in[3];
    end


  // --------------------------------------------------------------------
  //
  always @(posedge clkout_7x)
    if( clk_7x_index == 6 )
      begin
        data_out[0]   <= payload[6][0];
        data_out[1]   <= payload[5][0];
        data_out[2]   <= payload[4][0];
        data_out[3]   <= payload[3][0];
        data_out[4]   <= payload[2][0];
        data_out[6]   <= payload[1][0];
        data_out[7]   <= payload[0][0];

        data_out[8]   <= payload[6][1];
        data_out[9]   <= payload[5][1];
        data_out[12]  <= payload[4][1];
        data_out[13]  <= payload[3][1];
        data_out[14]  <= payload[2][1];
        data_out[15]  <= payload[1][1];
        data_out[18]  <= payload[0][1];

        data_out[19]  <= payload[6][2];
        data_out[20]  <= payload[5][2];
        data_out[21]  <= payload[4][2];
        data_out[22]  <= payload[3][2];
        data_out[24]  <= payload[2][2];
        data_out[25]  <= payload[1][2];
        data_out[26]  <= payload[0][2];

        data_out[27]  <= payload[6][3];
        data_out[5]   <= payload[5][3];
        data_out[10]  <= payload[4][3];
        data_out[11]  <= payload[3][3];
        data_out[16]  <= payload[2][3];
        data_out[17]  <= payload[1][3];
        data_out[23]  <= payload[0][3];
      end


endmodule



