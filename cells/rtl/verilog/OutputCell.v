/**********************************************************************************
*                                                                                 *
*  This verilog file is a part of the Boundary Scan Implementation and comes in   *
*  a pack with several other files. It is fully IEEE 1149.1 compliant.            *
*  For details check www.opencores.org (pdf files, bsdl file, etc.)               *
*                                                                                 *
*  Copyright (C) 2000 Igor Mohor (igorm@opencores.org) and OPENCORES.ORG          *
*                                                                                 *
*  This program is free software; you can redistribute it and/or modify           *
*  it under the terms of the GNU General Public License as published by           *
*  the Free Software Foundation; either version 2 of the License, or              *
*  (at your option) any later version.                                            *
*                                                                                 *
*  See the file COPYING for the full details of the license.                      *
*                                                                                 *
*  OPENCORES.ORG is looking for new open source IP cores and developers that      *
*  would like to help in our mission.                                             *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*	  Output Cell:                                                                  *
*                                                                                 *
*	  FromCore: Value that comes from on-chip logic	and goes to pin                 *
*	  FromPreviousBSCell: Value from previous boundary scan cell                    *
*	  ToNextBSCell: Value for next boundary scan cell                               *
*	  CaptureDR, ShiftDR, UpdateDR: TAP states                                      *
*	  extest: Instruction Register Command                                          *
*	  TCK: Test Clock                                                               *
*	  TristatedPin: Signal from core is connected to this output pin via BS         *
*	  FromOutputEnable: This pin comes from core or ControlCell                     *
*                                                                                 *
*	  Signal that is connected to TristatedPin comes from core or BS chain.         *
*	  Tristate control is generated in core or BS chain (ControlCell).              *
*                                                                                 *
**********************************************************************************/

// This is not a top module 
module OutputCell( FromCore, FromPreviousBSCell, CaptureDR, ShiftDR, UpdateDR, extest, TCK, ToNextBSCell, FromOutputEnable, TristatedPin);
input  FromCore;
input  FromPreviousBSCell;
input  CaptureDR;
input  ShiftDR;
input  UpdateDR;
input  extest;
input  TCK;
input  FromOutputEnable;

reg Latch;

output ToNextBSCell;
reg    ToNextBSCell;

output TristatedPin;

reg  ShiftedControl;

wire SelectedInput = CaptureDR? FromCore : FromPreviousBSCell;

always @ (posedge TCK)
begin
	if(CaptureDR | ShiftDR)
		Latch<=SelectedInput;
end

always @ (negedge TCK)
begin
	ToNextBSCell<=Latch;
end

always @ (negedge TCK)
begin
	if(UpdateDR)
		ShiftedControl<=ToNextBSCell;
end

wire MuxedSignal = extest? ShiftedControl : FromCore;
assign TristatedPin = FromOutputEnable? MuxedSignal : 1'bz;

endmodule	// OutputCell