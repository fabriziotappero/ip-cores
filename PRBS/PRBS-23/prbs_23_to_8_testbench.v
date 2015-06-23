// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module
  prbs_23_to_8_testbench();

  // --------------------------------------------------------------------
  reg clock = 0;

  always
    #(20) clock <= ~clock;


  // --------------------------------------------------------------------
  reg reset = 1;

  initial
    begin
      reset <= 1'b1;

      repeat(3)
        @(posedge clock);

      reset <= 1'b0;
    end


  // --------------------------------------------------------------------
  wire [7:0] prbs_data_out;

  prbs_23_to_8 i_prbs_23_to_8
  (
    .data_in( 8'h0 ),
    .scram_en( 1'b1 ),
    .scram_rst( reset ),
    .data_out(prbs_data_out),
    .rst( reset ),
    .clk( clock )
  );
  
  
  // --------------------------------------------------------------------
  reg [7:0] prbs_data_out_1;
  reg [7:0] prbs_data_out_2;
  reg [7:0] prbs_data_out_3;
  
  always @( posedge clock )
    prbs_data_out_1 <= prbs_data_out;

  always @( posedge clock )
    prbs_data_out_2 <= prbs_data_out_1;

  always @( posedge clock )
    prbs_data_out_3 <= prbs_data_out_2;

  wire hit = (prbs_data_out == 8'h0a) & (prbs_data_out_1 == 8'h20) & (prbs_data_out_2 == 8'hf2) & (prbs_data_out_3 == 8'h4e);
  
  always @( negedge clock )
    if( hit == 1'b1 )
      $stop();
    

  // --------------------------------------------------------------------
  integer i = 0;
  integer fh;

  initial
    begin
      fh = $fopen( "prbs.csv" );
      $fdisplay( fh, "count, parallel 8 bit" );
    end

  always @( posedge clock )
    begin

      if( ~reset )
        begin
          $display( "-#- %16.t | 0x%2x", $time, prbs_data_out );

          $fdisplay( fh, "%d,'%2x", i, prbs_data_out );
          
          i = i + 1;
        end

    end

endmodule

