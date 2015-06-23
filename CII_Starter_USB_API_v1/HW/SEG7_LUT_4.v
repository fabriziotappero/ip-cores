//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

module SEG7_LUT_4 (	oSEG0,oSEG1,oSEG2,oSEG3,iDIG );
input	[15:0]	iDIG;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3;

SEG7_LUT	u0	(	oSEG0,iDIG[3:0]		);
SEG7_LUT	u1	(	oSEG1,iDIG[7:4]		);
SEG7_LUT	u2	(	oSEG2,iDIG[11:8]	);
SEG7_LUT	u3	(	oSEG3,iDIG[15:12]	);

endmodule