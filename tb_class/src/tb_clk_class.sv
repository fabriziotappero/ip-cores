// --------------------------------------------------------------------
//

`timescale 1ps/1ps


// --------------------------------------------------------------------
//
interface tb_clk_if;
  logic clk = 0;
  logic enable = 0;
  time period;
  event clk_rise;
  event clk_fall;
  
  modport tb_m
  (
    output clk
  );
endinterface: tb_clk_if


// --------------------------------------------------------------------
//
class
  tb_clk_class;
  
  virtual tb_clk_if tb;

  // --------------------------------------------------------------------
  //
  function
    new
    (
      virtual tb_clk_if tb
    );
    
    this.tb = tb;
  endfunction: new
  

  // --------------------------------------------------------------------
  //
  task
    init_basic_clock
    (
      time period
    );
    
    tb.period = period;
    tb.enable = 1;
    
    $display( "^^^ %16.t | %m | Starting clock with period %t.", $time, period );
    
    fork
      forever
        if( tb.enable )
          begin
            #(period/2) tb.clk = 1;
            -> tb.clk_rise;
            #(period/2) tb.clk = 0;
            -> tb.clk_fall;
          end
    join_none
    
  endtask: init_basic_clock
  
  
  // --------------------------------------------------------------------
  //
  task
    enable_clock
    (
      logic enable
    );
    
    tb.enable = enable;
    
    $display( "^^^ %16.t | %m | Clock Enable =  %h.", $time, enable );
    
  endtask: enable_clock
  
endclass: tb_clk_class
  


