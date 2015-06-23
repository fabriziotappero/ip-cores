// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps


module
  tb_programmable_clk
  (
    output reg clock
  );
  
  
  // --------------------------------------------------------------------
  //  
  integer clk_duty_cycle = 50;
  
  task set_clk_duty_cycle;
  input integer duty_cycle;
    begin

      clk_duty_cycle = duty_cycle;

    end
  endtask
  
  
  // --------------------------------------------------------------------
  //  
  integer clk_period = 1515;

  task set_clk_period;
  input integer period;
    begin

      clk_period = period;

    end
  endtask


  // --------------------------------------------------------------------
  //  
  initial
    clock <= 1'b1;

  always
    if(clk_duty_cycle == 50)
      #(clk_period/2) clock <= ~clock;
    else
      if(clock)
        #(clk_period * (clk_duty_cycle/100)) clock <= ~clock;
      else
        #(clk_period * ( (100 - clk_duty_cycle)/100 ) ) clock <= ~clock;
        

endmodule

