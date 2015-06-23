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
*	  Input Cell:                                                                   *
*                                                                                 *
*	  InputPin: Value that comes from on-chip logic	and goes to pin                 *
*	  FromPreviousBSCell: Value from previous boundary scan cell                    *
*	  ToNextBSCell: Value for next boundary scan cell                               *
*	  CaptureDR, ShiftDR: TAP states                                                *
*	  TCK: Test Clock                                                               *
*                                                                                 *
**********************************************************************************/

// This is not a top module 
module InputCell( InputPin, FromPreviousBSCell, CaptureDR, ShiftDR, TCK, ToNextBSCell);
input  InputPin;
input  FromPreviousBSCell;
input  CaptureDR;
input  ShiftDR; 
input  TCK;     
                
reg Latch;      
                
output ToNextBSCell;
reg    ToNextBSCell;

wire SelectedInput = CaptureDR? InputPin : FromPreviousBSCell;

always @ (posedge TCK)
begin
	if(CaptureDR | ShiftDR)
		Latch<=SelectedInput;
end

always @ (negedge TCK)
begin
	ToNextBSCell<=Latch;
end


endmodule	// InputCell