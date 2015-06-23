//-----------------------------------------------------------------------------
// system.tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module system_tb
  (
  );

  // START USER CODE (Do not remove this line)

  // User: Put your signals here. Code in this
  //       section will not be overwritten.
  parameter PERIOD = 10000;

  // END USER CODE (Do not remove this line)


  // Internal signals

  reg CLK;
  reg RST_N;
  wire INTR;

  system
    dut (
      .RST_N ( RST_N ),
      .CLK ( CLK ),
      .INTR_IN ( INTR ),
      .INTR_OUT ( INTR )
    );

  // START USER CODE (Do not remove this line)

  // User: Put your stimulus here. Code in this
  //       section will not be overwritten.
     initial begin
        RST_N = 1'b0;
        @(negedge CLK);
        @(negedge CLK);
        @(negedge CLK);
        RST_N = 1'b1;
     end
     
     always begin
        CLK = 1'b0;
        #(PERIOD/2) CLK = 1'b1;
        #(PERIOD/2);
     end
	 
  // END USER CODE (Do not remove this line)

endmodule

