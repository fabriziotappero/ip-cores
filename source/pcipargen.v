//
//                  PCI Parity Generator.
//
// PCI Target generates PAR in the data phase of a read cycle. 
// The 1's sum on AD, CBE and PAR is even.
//
//   Date 		  Version	Author	Description
//   2005-05-13   R00A00	PAU		First alfa revision	(eng)
//
//  Copyright (C) 2005 Peio Azkarate, peio@opencores.org
//
//   This source file is free software; you can redistribute it     |
//   and/or modify it under the terms of the GNU Lesser General     |
//   Public License as published by the Free Software Foundation;   |
//   either version 2.1 of the License, or (at your option) any     |
//   later version.                                                 |


module pcipargen_new (clk_i, pcidatout_i, cbe_i, parOE_i, par_o);

	input clk_i;
	input [31:0] pcidatout_i;
	input [3:0] cbe_i;
	input parOE_i;
	output par_o;


  	wire [31:0] d;
  	wire pardat;
  	wire parcbe;
  	wire par;
  	wire par_s;

	assign d = pcidatout_i;

	assign pardat = d[0]  ^ d[1]  ^ d[2]  ^ d[3]  ^ d[4]  ^ d[5]  ^ d[6]  ^ d[7]  ^ 
			   d[8]  ^ d[9]  ^ d[10] ^ d[11] ^ d[12] ^ d[13] ^ d[14] ^ d[15] ^ 
			   d[16] ^ d[17] ^ d[18] ^ d[19] ^ d[20] ^ d[21] ^ d[22] ^ d[23] ^ 
			   d[24] ^ d[25] ^ d[26] ^ d[27] ^ d[28] ^ d[29] ^ d[30] ^ d[31];
						
	assign parcbe = cbe_i[0] ^ cbe_i[1] ^ cbe_i[2] ^ cbe_i[3]; 

	assign par = pardat ^ parcbe;

    // PAR
	assign par_o = ( parOE_i == 1 ) ? par_s : 1'bZ;

endmodule
/*
component sync
port (
    clk             : in std_logic;
    d           : in std_logic;
    q               : out std_logic
);
end component;

component sync2
port (
    clk             : in std_logic;
    d           : in std_logic;
    q               : out std_logic
);
end component;

begin



    u1: sync2 port map (
		clk => clk_i,
		d => par,
		q => par_s
	);
	



end rtl;
*/
