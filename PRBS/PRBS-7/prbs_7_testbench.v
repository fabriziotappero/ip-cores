// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module
  prbs_7_testbench();

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
  wire [7:0] prbs_7_to_8_data_out;

  prbs_7_to_8 i_prbs_7_to_8
  (
    .data_in( 8'h0 ),
    .scram_en( 1'b1 ),
    .scram_rst( reset ),
    .data_out(prbs_7_to_8_data_out),
    .rst( reset ),
    .clk( clock )
  );
  

  // --------------------------------------------------------------------
  wire [13:0] prbs_7_to_14_data_out;

  prbs_7_to_14 i_prbs_7_to_14
  (
    .data_in( 14'h0 ),
    .scram_en( 1'b1 ),
    .scram_rst( reset ),
    .data_out(prbs_7_to_14_data_out),
    .rst( reset ),
    .clk( clock )
  );


  // --------------------------------------------------------------------
  //  LFSR pseudo-random  x^7 + x^6 + 1  
  reg [7:0] lfsr;
  wire      lfsr_feedback = lfsr[6] ^ lfsr[5];
  
  always @(posedge clock)
    if( reset )
      lfsr <= 8'hff;
    else
      lfsr <= {lfsr[6:0], lfsr_feedback};


  // --------------------------------------------------------------------
  integer i = 0;
  integer fh;

  initial
    begin
      fh = $fopen( "prbs_7.csv" );
      $fdisplay( fh, "count, parallel 8 bit, parallel 14 bit, serial" );
    end

  always @( posedge clock )
    begin

      if( ~reset )
        begin
          $display( "-#- %16.t | 0x%2x | 0x%4x | 0x%2x", $time, prbs_7_to_8_data_out, prbs_7_to_14_data_out, lfsr );

          $fdisplay( fh, "%d,'%2x,'%4x,'%2x", i, prbs_7_to_8_data_out, prbs_7_to_14_data_out, lfsr );
          
          i = i + 1;
        end

    end

endmodule

