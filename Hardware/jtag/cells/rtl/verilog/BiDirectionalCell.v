/**********************************************************************************
*																																									*
*		BiDirectional Cell:																														*
*																																									*
*		FromCore: Value that comes from on-chip logic and goes to pin									*
*		ToCore: Value that is read-in from the pin and goes to core										*
*		FromPreviousBSCell: Value from previous boundary scan cell										*
*		ToNextBSCell: Value for next boundary scan cell																*
*		CaptureDR, ShiftDR, UpdateDR: TAP states																			*
*		extest: Instruction Register Command																					*
*		TCK: Test Clock																																*
*		BiDirPin: Bidirectional pin connected to this BS cell													*
*		FromOutputEnable: This pin comes from core or ControlCell											*
*																																									*
*		Signal that is connected to BiDirPin comes from core or BS chain. Tristate		*
*		control is generated in core or BS chain (ControlCell).												*
*																																									*
**********************************************************************************/

module BiDirectionalCell( FromCore, ToCore, FromPreviousBSCell, CaptureDR, ShiftDR, UpdateDR, extest, TCK, ToNextBSCell, FromOutputEnable, BiDirPin);
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

output BiDirPin;
output ToCore;

reg  ShiftedControl;

wire SelectedInput = CaptureDR? BiDirPin : FromPreviousBSCell;

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
assign BiDirPin = FromOutputEnable? MuxedSignal : 1'bz;

//BUF Buffer (.I(BiDirPin), .O(ToCore));
assign ToCore = BiDirPin;


endmodule	// TristateCell