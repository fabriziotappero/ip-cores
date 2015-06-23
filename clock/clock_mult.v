//
//
//

`timescale 1ps/1ps


module clock_mult
#(
  parameter MULT = 7
)
(
  input       clock_in,
  output reg  clock_out,
  output reg  clock_good,

  input  reset
);

  // --------------------------------------------------------------------
  //
  time  clock_in_time_buffer;
  time  clock_out_period;

  wire enable = (reset === 1'b0) & ((clock_in === 1'b0) | (clock_in === 1'b1));

  reg [(MULT - 1):0] delayed_clock_in = 0;

  initial
    begin
      clock_out             <= 0;
      clock_out_period      <= 0;
      clock_good            <= 0;

      wait( ~enable );

      @(posedge clock_in);
      clock_in_time_buffer  = $time;

      @(posedge clock_in);
      clock_out_period      = ($time - clock_in_time_buffer) / MULT;

      @(posedge clock_in);
      clock_good            = 1;

    end


  // --------------------------------------------------------------------
  //
  integer i;

  always @( * )
    for( i = 0; i < MULT; i = i + 1 )
      delayed_clock_in[i] <= #(i * clock_out_period) clock_in;


  // --------------------------------------------------------------------
  //
  integer j;

  always @(posedge clock_in)
    begin
      if(clock_good)
        begin
          clock_out = 1'b1;
          #(clock_out_period/2);
          clock_out = 1'b0;
          for( j = 1; j < MULT; j = j + 1 )
            begin
              @(posedge delayed_clock_in[j]);
              clock_out = 1'b1;
              #(clock_out_period/2);
              clock_out = 1'b0;
            end
        end
    end


endmodule



