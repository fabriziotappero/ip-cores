// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module
  tb_clk
  #(
    parameter CLK_DUTY_CYCLE  = 50,
    parameter CLK_PERIOD      = 32
  )
  (
    output reg clock
  );

  initial
    clock <= 1'b1;

  always
    if(CLK_DUTY_CYCLE == 50)
      #(CLK_PERIOD/2) clock <= ~clock;
    else
      if(clock)
        #(CLK_PERIOD * (CLK_DUTY_CYCLE/100)) clock <= ~clock;
      else
        #(CLK_PERIOD * ( (100 - CLK_DUTY_CYCLE)/100 ) ) clock <= ~clock;

endmodule

