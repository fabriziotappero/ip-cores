/*
 * Copyright (c) 2009, Kendall Correll
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

`timescale 1ns / 1ps

`define MHZ 100
`define WIDTH 8
`define SELECT_WIDTH 3
`define DEBOUNCE_MSEC 250
`define STRETCH_MSEC 250

module demo_top (
	input [1:0] buttons,
	output [`SELECT_WIDTH:0] indicators,
	
	input refclock
);

wire reset;
wire clock;
wire locked;
wire usec_tick;
wire msec_tick;
wire next_test;
wire next_step;
wire [`SELECT_WIDTH-1:0] select;
wire valid;

reg [1:0] buttons_reg;

// replace the clock generator with the appropriate module for your part
assign reset = ~locked;

/*clockgen clockgen (
	.inclk0(refclock),
	.c0(clock),
	.locked(locked)
);*/
clockgen clockgen (
	.CLKIN_IN(refclock),
	.CLKFX_OUT(clock),
	.CLKIN_IBUFG_OUT(),
	.LOCKED_OUT(locked)
);

// register inputs
always @(posedge clock)
begin
	buttons_reg <= buttons;
end

// this counter is always enabled, so subtract 1 from the count to account for
// the extra clock that it takes to reload the counter
pulser #(
	.count(`MHZ-1)
) usec_pulser (
	.enable(1'b1),
	.out(usec_tick),
	
	.clock(clock),
	.reset(1'b0)
);

// this counter is only enabled every few clocks, so use the full count because
// the clock that it takes to reload the counter will happen between enables
pulser #(
	.count(1000)
) msec_pulser (
	.enable(usec_tick),
	.out(msec_tick),
	
	.clock(clock),
	.reset(1'b0)
);

// this assumes that the buttons are normally low, it fires a pulse on the
// rising edge of a button event, and only accepts one event per DEBOUNCE_MSEC
debouncer #(
	.low_count(`DEBOUNCE_MSEC)
) next_test_debouncer (
	.enable(msec_tick),
	.in(buttons_reg[1]),
	.out(),
	.rising_pulse(next_test),
	.falling_pulse(),
	.valid(),
	
	.clock(clock),
	.reset(1'b0)
);

debouncer #(
	.low_count(`DEBOUNCE_MSEC)
) next_step_debouncer (
	.enable(msec_tick),
	.in(buttons_reg[0]),
	.out(),
	.rising_pulse(next_step),
	.falling_pulse(),
	.valid(),
	
	.clock(clock),
	.reset(1'b0)
);

// the arbiter demo module
demo #(
	.width(`WIDTH),
	.select_width(`SELECT_WIDTH)
) demo (
	.next_test(next_test),
	.next_step(next_step),
	.select(select),
	.valid(valid),
	
	.clock(clock),
	.reset(reset)
);

// this stretches brief changes long enough to be visible, specifically, to see
// select blip when the arbiter wraps around (a wrap around is the transition
// from granting a higher number req to a lower number, and while select blips,
// all grants are deasserted)
stretcher #(
	.count(`STRETCH_MSEC),
	.width(`SELECT_WIDTH)
) select_stretcher (
	.enable(msec_tick),
	.in(select),
	.out(indicators[`SELECT_WIDTH:1]),
	.valid(),
	
	.clock(clock),
	.reset(1'b0)
);

stretcher #(
	.count(`STRETCH_MSEC)
) valid_stretcher (
	.enable(msec_tick),
	.in(valid),
	.out(indicators[0]),
	.valid(),
	
	.clock(clock),
	.reset(1'b0)
);

endmodule