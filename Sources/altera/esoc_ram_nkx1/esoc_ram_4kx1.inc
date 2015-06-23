--Copyright (C) 1991-2011 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


FUNCTION esoc_ram_4kx1 
(
	address_a[11..0],
	address_b[11..0],
	clock_a,
	clock_b,
	data_a[0..0],
	data_b[0..0],
	rden_a,
	rden_b,
	wren_a,
	wren_b
)

RETURNS (
	q_a[0..0],
	q_b[0..0]
);
