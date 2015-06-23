//	MODULE  : shift_compare_serial.v
//	AUTHOR  : Stephan Neuhold
//	VERSION : v1.00
//
//	REVISION HISTORY:
//	-----------------
//	No revisions
//
//	FUNCTION DESCRIPTION:
//	---------------------
//	This module provides the shifting in of data
//	and comparing that data to the synchronisation
//	pattern. Once the synchronisation pattern has
//	been found, the last eight bits of data
//	shifted in are presented.
//	
//	The shift register and comparator are
//	automatically scaled to the correct length
//	using the "length" generic.

`timescale 1 ns / 1 ns

module shift_compare_serial(	clock,
										reset,
										enable,
										din,
										b,
										eq,
										din_shifted);

	parameter									length = 5;
	parameter									frequency = 50;
								
	input											clock;
	input											reset;
	input											enable;
	input											din;
	input				[(2**length) - 1:0]	b;
	output										eq;
	output	reg	[7:0]						din_shifted;
	
	reg				[(2**length) - 1:0]	b_swapped;
	wire				[(2**length):0]		r;
	wire				[(2**length) - 1:0]	q;
	wire				[(2**length) - 1:0]	a;
	wire											GND;
	integer										i;
	integer										j;

//***************************************************
//*	This process swaps the bits in the data byte.
//*	This is done to present the data in the format
//*	that it is entered in the PROM file.
//***************************************************
always @ (a)	
for (i = 0; i < 8; i = i + 1)
begin
	din_shifted[i] <= a[((2**length) - 1) - i];
end

//*******************************************************
//*	This process swaps the bits of every byte of the
//*	synchronisation pattern. This is done so that
//*	data read in from the PROM can be directly
//*	compared. Data from the PROM is read with all
//*	bits of every byte swapped.
//*	e.g.
//*	If the data in the PROM is 28h then this is read in
//*	the following way:
//*	00010100
//*******************************************************
always @ (b)
for (i = 0; i < 2**length / 8; i = i + 1)
begin
	for (j = 0; j < 8; j = j + 1)
	begin
		b_swapped[(8 * i) + j] <= b[7 + (8 * i) - j];
	end
end


//***********************************************
//*	This is the first FF of the shift register.
//*	It needs to be seperated from the rest
//*	since it has a different input.
//***********************************************
assign GND = 1'b0;
assign r[0] = 1'b1;

FDRE	Data_Shifter_0_Serial(
	.C(clock),
	.D(din),
	.CE(enable),
	.R(reset),
	.Q(a[0])
	);

//***************************************************
//*	This loop generates as many registers needed
//*	based on the length of the synchronisation
//*	word.
//***************************************************
genvar x;
generate	
for (x = 1; x < 2**length; x = x + 1)
begin:	Shifter_Serial
	FDRE	Data_Shifter_Serial(
		.C(clock),
		.D(a[x - 1]),
		.CE(enable),
		.R(reset),
		.Q(a[x])
		);
end
endgenerate

//***********************************************
//*	This loop generates as many LUTs and MUXCYs
//*	as needed based on the length of the
//*	synchronisation word.
//***********************************************
genvar y;
generate
for (y = 0; y < 2**length; y = y + 1)
begin:	Comparator_Serial
	my_LUT2	Comparator_LUTs_Serial(
		.I0(a[y]),
		.I1(b_swapped[y]),
		.O(q[y])
		);
		
	MUXCY	Comparator_MUXs_Serial(
		.DI(GND),
		.CI(r[y]),
		.S(q[y]),
		.O(r[y + 1])
		);
end
endgenerate

assign eq = r[(2**length)];

endmodule