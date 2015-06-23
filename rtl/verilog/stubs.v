////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 stubs for the pad cells					////
////									////
//// TODO:								////
//// - Nothing								////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module ICP (PAD, PI, GND5O, GND5R, VDD5O, VDD5R, CLAMPC, PO, Y);
	input PAD; 
	input PI;
	input GND5O;
	input GND5R;
	input VDD5O;
	input VDD5R;
	input CLAMPC;
	output PO;
	output Y;
endmodule

module BT4P (A, EN, GND5O, GND5R, VDD5O, VDD5R, CLAMPC, PAD);
	input A;
	input EN;
	input GND5O;
	input GND5R;
	input VDD5O;
	input VDD5R;
	input CLAMPC;
	output PAD;
endmodule

module CORNERCLMP (GND5O, GND5R, VDD5O, VDD5R, CLAMPC);
	input CLAMPC;
	input VDD5O;
	input VDD5R;
	input GND5O;
	input GND5R;
endmodule

module GND5ALLPADP (VDD5O, VDD5R, CLAMPC, GND);
	input CLAMPC;
	input VDD5O;
	input VDD5R;
	input GND;
endmodule

module VDD5ALLPADP (GND5O, GND5R, CLAMPC, VDD);
	input CLAMPC;
	input GND5O;
	input GND5R;
	input VDD;
endmodule

/*module FILLERP_110 (GND5O, GND5R, VDD5O, VDD5R, CLAMPC);
	input CLAMPC;
	input VDD5O;
	input VDD5R;
	input GND5O;
	input GND5R;
endmodule
*/
