`define CLK_HALF_PERIOD 10
`define RESET_DURATION  15
`timescale 1ps/1ps
module ecpu_tb;


  // alu parameters
  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
  wire  [(DWIDTH -1):0]   A_ACC         ;
	wire  [(DWIDTH -1):0]   B_ACC         ;
  wire                    CLK           ;

	reg                     INT_EXT       ;
  wire                    RESET_N       ;




  ecpu          #(DWIDTH, OPWIDTH, Mk, N) ecpu0           (
		                                                        INT_EXT       , 
                                                            A_ACC         ,
                                                            B_ACC         ,
		                                                        RESET_N       , 
		                                                        CLK
		                                                      );

  ecpu_monitor  #(DWIDTH, OPWIDTH, Mk, N) ecpu_monitor0   (
		                                                        INT_EXT       , 
                                                            A_ACC         ,
                                                            B_ACC         ,
		                                                        RESET_N       , 
		                                                        CLK
		                                                      );

  // initialize main inputs
  // and set simulation duration
  //
  initial
  begin
    INT_EXT = 1'b0;
    `ifdef MAX_SIM_TIME
      #(`MAX_SIM_TIME);
    `else
      #100000000;
    `endif
    $display("End of sim at [%0t ps]", $time);
    $finish;
  end
  
  
  // reset control
  wire [63:0] duration;
  assign duration = 64'd0 + (`RESET_DURATION * `CLK_HALF_PERIOD * 2);
  reset_gen ecpu0_reset_gen   (CLK, RESET_N, duration);
  
  // generate clk
  clk_gen   ecpu0_clk_gen     (CLK, `CLK_HALF_PERIOD, `CLK_HALF_PERIOD);
  
  // add a ticker
  ticker    ecpu0_tb_ticker   ();
  
  `ifndef verilator
    initial
    begin
      $dumpfile("ecpu_tb.vcd");
      $dumpvars;
    end
  `endif
  
endmodule
