// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ps/1ps


module
  recover_clock
  #(
    parameter PROFILE_COUNT   = 20
  )
  (
    input       in,

    output reg  clock
  );

  time  in_time_buffer;
  time  clock_period_buffer;
  time  clock_out_period = 1000000;

  integer count = 0;

  // --------------------------------------------------------------------
  //
  reg internal_clock;

  initial
    begin

      internal_clock <= 1'bx;

      wait( in === 0 );

      repeat( PROFILE_COUNT )
        begin

          @( posedge in );
          in_time_buffer  = $time;
          @( negedge in );

          clock_period_buffer = $time - in_time_buffer;

          if( clock_period_buffer < clock_out_period )
            clock_out_period = clock_period_buffer;

          count = count + 1;

        end

      $display( "-#- %16.t | recover_clock: period (in sim time) = %t", $time, clock_out_period );

      @( posedge in )
        internal_clock <= 1'b1;

      forever
        #(clock_out_period/2) internal_clock <= ~internal_clock;

    end


  // --------------------------------------------------------------------
  //
  time  delta = 0;
  time  delta_buffer = 0;

  always @( posedge internal_clock)
    delta_buffer <= $time;

  always @( posedge in)
    if( internal_clock !== 1'bx )
      delta <= ($time - delta_buffer) %  clock_period_buffer;


  // --------------------------------------------------------------------
  //
  always @( * )
    clock = #(delta) internal_clock;


endmodule

