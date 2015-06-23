//	MODULE  : clock_management.v
//	AUTHOR  : Stephan Neuhold
//	VERSION : v1.00
//
//	REVISION HISTORY:
//	-----------------
//	No revisions
//
//	FUNCTION DESCRIPTION:
//	---------------------
//	This module generates an enable signal for
//	the shift register and comparator. It also
//	generates the clock signal that is connected
//	to the PROM.
//	The enable and clock signals are generated
//	based on the "frequency" generic entered for
//	the system clock.
//	The clock signal is only generated at the
//	appropriate times. All other states the clock
//	signal is kept at a logic high. The PROMs
//	address counter only increments on a rising
//	edge of this clock.

`timescale 1 ns / 1 ns

module clock_management(	clock,
									enable,
									read_enable,
									cclk);
							
	input							clock;
	input							enable;
	output		reg			read_enable;
	output						cclk;
	
	parameter					length = 5;
	parameter					frequency = 50;
	wire					[3:0]	SRL_length = (frequency / 20) - 1;
	defparam						Divider0.INIT = 16'h0001;

	reg							cclk_int = 1'b1;
	wire							enable_cclk;					

//***************************************************
//*	The length of the SRL16 is based on the system
//*	clock frequency entered. This frequency is then
//*	"divided" down to approximately 10MHz.
//***************************************************	
SRL16	Divider0(
	.CLK(clock),
	.D(enable_cclk),
	.A0(SRL_length[0]),
	.A1(SRL_length[1]),
	.A2(SRL_length[2]),
	.A3(SRL_length[3]),
	.Q(enable_cclk)
	);
	
//***************************************************
//*	This process generates the enable signal for
//*	the shift register and the comparator. It also
//*	generates the clock signal used to increment
//*	the PROMs address counter.
//***************************************************	
always @ (posedge clock)
begin
	if (enable)
	begin
		if (enable_cclk)
			cclk_int <= ~cclk_int;
		if (enable_cclk & cclk_int)
			read_enable <= 1'b1;
		else
			read_enable <= 1'b0;
	end
	else
		cclk_int <= 1'b1;
end

assign cclk = cclk_int;

endmodule