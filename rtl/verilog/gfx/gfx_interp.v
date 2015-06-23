/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

INTERPOLATION MODULE - DIVIDER

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module interpolates by using div_uu division units

One division takes exactly point_width+1 ticks to complete, but many divisions can be pipelined at the same time.
*/
module gfx_interp(clk_i, rst_i,
  ack_i, ack_o,
  write_i,
  // Variables needed for interpolation
  edge0_i, edge1_i, area_i,
  // Raster position
  x_i, y_i, x_o, y_o,

  factor0_o, factor1_o,
  write_o
  );

parameter point_width  = 16;
parameter delay_width  = 5;
parameter div_delay    = point_width+1;
parameter result_width = 4;

input      clk_i;
input      rst_i;

input      ack_i;
output reg ack_o;

input      write_i;

input  [2*point_width-1:0] edge0_i;
input  [2*point_width-1:0] edge1_i;
input  [2*point_width-1:0] area_i;

input  [point_width-1:0] x_i;
input  [point_width-1:0] y_i;
output [point_width-1:0] x_o;
output [point_width-1:0] y_o;

// Generated pixel coordinates
output [point_width-1:0] factor0_o;
output [point_width-1:0] factor1_o;
// Write pixel output signal
output                   write_o;

// calculates factor0
wire   [point_width-1:0] interp0_quotient; // result
wire   [point_width-1:0] interp0_reminder;
wire                     interp0_div_by_zero;
wire                     interp0_overflow;
// calculates factor1
wire   [point_width-1:0] interp1_quotient; // result
wire   [point_width-1:0] interp1_reminder;
wire                     interp1_div_by_zero;
wire                     interp1_overflow;

reg  [delay_width-1:0] phase_counter;

wire                   division_enable;

always @(posedge clk_i or posedge rst_i)
if(rst_i)
  phase_counter <= 1'b0;
else if(division_enable)
  phase_counter <= (phase_counter + 1'b1 == div_delay) ? 1'b0 : phase_counter + 1'b1;

// State machine
reg state;
parameter wait_state   = 1'b0,
          write_state  = 1'b1;

// Manage states
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(write_o)
        state <= write_state;

    write_state:
      if(ack_i)
        state <= wait_state;

  endcase

always @(posedge clk_i or posedge rst_i)
begin
  // Reset
  if(rst_i)
    ack_o       <= 1'b0;
  else
    case (state)

      wait_state:
        ack_o   <= 1'b0;

      write_state:
        if(ack_i)
          ack_o <= 1'b1;

    endcase
   
end

wire [point_width-1:0] zeroes = 1'b0;

// division unit 0
	div_uu #(2*point_width) dut0 (
		.clk  (clk_i),
		.ena  (division_enable),
		.z    ({edge0_i[point_width-1:0], zeroes}),
		.d    (area_i[point_width-1:0]),
		.q    (interp0_quotient),
		.s    (interp0_reminder),
		.div0 (interp0_div_by_zero),
		.ovf  (interp0_overflow)
	);
// division unit 1
	div_uu #(2*point_width) dut1 (
		.clk  (clk_i),
		.ena  (division_enable),
		.z    ({edge1_i[point_width-1:0], zeroes}),
		.d    (area_i[point_width-1:0]),
		.q    (interp1_quotient),
		.s    (interp1_reminder),
		.div0 (interp1_div_by_zero),
		.ovf  (interp1_overflow)
	);

wire                  result_full;
wire                  result_valid;
wire [result_width:0] result_count;
wire                  result_deque = result_valid & (state == wait_state);

assign write_o = result_deque;

assign division_enable = ~result_full;

wire                   delay_valid;
wire [delay_width-1:0] delay_phase_counter;
wire                   division_complete = division_enable & delay_valid & (phase_counter == delay_phase_counter);

wire [point_width-1:0] delay_x, delay_y;

// Fifo for finished results
basic_fifo result_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {interp0_quotient, interp1_quotient, delay_x, delay_y} ),
  .enq_i     ( division_complete ),
  .full_o    ( result_full ), // TODO: use?
  .count_o   ( result_count ),

  .data_o    ( {factor0_o, factor1_o, x_o, y_o} ),
  .valid_o   ( result_valid ),
  .deq_i     ( result_deque )
);

defparam result_fifo.fifo_width     = 4*point_width;
defparam result_fifo.fifo_bit_depth = result_width;

// Another Fifo for current calculations
basic_fifo queue_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {phase_counter, x_i, y_i} ),
  .enq_i     ( write_i ),
  .full_o    ( ), // TODO: use?
  .count_o   ( ),

  .data_o    ( {delay_phase_counter, delay_x, delay_y} ),
  .valid_o   ( delay_valid ),
  .deq_i     ( division_complete )
);

defparam queue_fifo.fifo_width     = delay_width + 2*point_width;
defparam queue_fifo.fifo_bit_depth = delay_width;

endmodule

