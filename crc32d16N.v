// ===========================================================================
// File    : crc32d16N.v
// Author  : cwinward
// Date    : Sat Dec 8 14:00:37 MST 2007
// Project : TI PHY design
//
// Copyright (c) notice
// This code adheres to the GNU public license
//
// ===========================================================================
//
// $Id: crc32d16N.v,v 1.1.1.1 2007-12-08 22:26:59 cmagleby Exp $
//
// ===========================================================================
//
// $Log: not supported by cvs2svn $
//
// ===========================================================================
// Function :  This provides the lcrc for the end of the pci express TLP 
//             packet.  This is 16 bits in 32 bits out.
//             For more data widths see www.gutzlogic.com
// ===========================================================================
// ===========================================================================

module crc32d16N (/*AUTOARG*/
   // Outputs
   crc32N, 
   // Inputs
   clk, resetN, load, d, en
   );
   input        clk;
   input 	resetN;
   input 	load;  //load the seed value
   input [15:0] d;     //16 bit of tlp data starting with seq. num
   input 	en;    //should be high the entire packet.

   output [31:0] crc32N; //inverted and swapped per pci spec.
   wire [31:0] 	 crc32N;

   assign 	 crc32N = {~crc32[0],~crc32[1],~crc32[2],~crc32[3],~crc32[4],~crc32[5],~crc32[6],~crc32[7],
			   ~crc32[8],~crc32[9],~crc32[10],~crc32[11],~crc32[12],~crc32[13],~crc32[14],~crc32[15],
			   ~crc32[16],~crc32[17],~crc32[18],~crc32[19],~crc32[20],~crc32[21],~crc32[22],~crc32[23], 
			   ~crc32[24],~crc32[25],~crc32[26],~crc32[27],~crc32[28],~crc32[29],~crc32[30],~crc32[31]};
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		crc;			// From make_crc32d16 of crc32d16.v
   // End of automatics
   
   /* -----\/----- EXCLUDED -----\/-----
   crc32d16 AUTO_TEMPLATE (.init(32'hFFFF_FFFF));
    -----/\----- EXCLUDED -----/\----- */
   
   crc32d16 make_crc32d16 (/*AUTOINST*/
			   // Outputs
			   .crc		(crc[31:0]),
			   // Inputs
			   .clk		(clk),
			   .resetN	(resetN),
			   .load	(load),
			   .d		(d[15:0]),
			   .init	(32'hFFFF_FFFF),	 // Templated
			   .en		(en));
   
endmodule

