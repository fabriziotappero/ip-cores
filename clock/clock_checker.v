// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 10ps/1ps

module
  clock_checker
  (
    input test_clk
  );


  // --------------------------------------------------------------------
  time sim_time;
  real freq, freq_mhz;

  task display_freq;
    input   real  expected_freq;   // in Mhz
    output  time  period;
    begin

    @(posedge test_clk);    // delay to ensure a good clock
    @(posedge test_clk);
    
    @(posedge test_clk);
    sim_time = $time;

    @(posedge test_clk);
    period = $time - sim_time;

    freq      = 1 / ( period * 1e-11);
    freq_mhz  = (freq / 1e6);

    $display( "-#- %16.t | display_freq: freq = %0d Mhz | freq = %0e | period (in sim time) = %0t", $time, freq_mhz , freq, period );

    if( expected_freq != 0 )
      if( (expected_freq * 1.01 < freq_mhz ) | (expected_freq * 0.99 > freq_mhz ) )
        begin
          $display( "-!- %16.t | display_freq: ERROR!!! expected %0d Mhz but measured %0d Mhz", $time, expected_freq, freq_mhz );
          log.inc_fail_count();
        end


    end
  endtask


endmodule
