/*
 * WISHBONE to SystemACE MPU + CY7C67300 bridge
 * Copyright (C) 2008 Sebastien Bourdeauducq - http://lekernel.net
 * This file is part of Milkymist.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* Flag synchronizer from clock domain 0 to 1
 * See http://www.fpga4fun.com/CrossClockDomain.html
 */

module aceusb_sync(
	input clk0,
	input flagi,
	
	input clk1,
	output flago
);

/* Turn the flag into a level change */
reg toggle;
initial toggle = 1'b0;
always @(posedge clk0)
	if(flagi) toggle <= ~toggle;

/* Synchronize the level change to clk1.
 * We add a third flip-flop to be able to detect level changes. */
reg [2:0] sync;
initial sync = 3'b000;
always @(posedge clk1)
	sync <= {sync[1:0], toggle};

/* Recreate the flag from the level change into the clk1 domain */
assign flago = sync[2] ^ sync[1];

endmodule
