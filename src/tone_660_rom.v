// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module tone_660_rom( addr, q );

  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 7;
  
  input [(ADDR_WIDTH-1):0] addr;
  output [(DATA_WIDTH-1):0] q;
  
  // Declare the RAM variable
  reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
  reg [ADDR_WIDTH-1:0] addr_reg;
  
  
  assign q = ram[addr];

  initial
    $readmemh( "../../../../i2s_to_wb/scilab/tone_roms/tone_660_at_48000sps_rom.txt", ram );

endmodule


