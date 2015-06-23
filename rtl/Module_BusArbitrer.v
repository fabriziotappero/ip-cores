`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/



module Module_BusArbitrer
(
input wire Clock,
input wire Reset,

input wire [`MAX_CORES-1:0] iRequest,
output wire [`MAX_CORES-1:0] oGrant,
output wire [`MAX_CORE_BITS-1:0] oBusSelect
);

wire[`MAX_CORES-1:0] wCurrentMasterMask;
wire[`MAX_CORE_BITS-1:0] wCurrentBusMaster;
wire wCurrentRequest;

//Just one requester can have the bus at a given
//point in time, the mask makes sure this happens
genvar i;
generate
for (i = 0; i < `MAX_CORES; i = i +1)
begin : ARB
	assign oGrant[i] = iRequest[i] & wCurrentMasterMask[i];
end
endgenerate
	


//When a requester relinquishes the bus (by negating its [iRequest] signal),
//the switch is turned to the next position
//So while iRequest == 1 the ciruclar list will not move

CIRCULAR_SHIFTLEFT_POSEDGE_EX # (`MAX_CORES) SHL_A
(
 .Clock( Clock ),
 .Enable( ~wCurrentRequest ),
 .Reset( Reset ),
 .Initial(`MAX_CORES'b1), 
 .O( wCurrentMasterMask )
 
);

assign oBusSelect = wCurrentBusMaster;

//Poll the current request
assign wCurrentRequest = iRequest[ wCurrentBusMaster ];


UPCOUNTER_POSEDGE # (`MAX_CORE_BITS ) UP1
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Initial( `MAX_CORE_BITS'd0 ),
	.Enable(~wCurrentRequest),
	.Q(wCurrentBusMaster)
);

endmodule
