// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module
  pcie_scrambler_testbench ();

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
  wire [7:0] data_out;

  pcie_scrambler i_pcie_scrambler
  (
    .data_in( 0 ),
    .scram_en( 1'b1 ),
    .scram_rst( reset ),
    .data_out(data_out),
    .rst( reset ),
    .clk( clock )
  );


// --------------------------------------------------------------------
integer i = 0;
integer fh;

  initial
    begin
      fh = $fopen( "pcie_scrambler_0_in.csv" );
      $fdisplay( fh, "count, data_out" );
    end

  always @( posedge clock )
    begin

      if( ~reset )
        begin
          $display( "-#- %16.t | 0x%2x", $time, data_out );

          $fdisplay( fh, "%d,`%2x", i, data_out );
          
          i = i + 1;
        end

    end


endmodule

