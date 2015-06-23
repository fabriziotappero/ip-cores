////////////////////////////////////////////////////////////////////////////
////									////
//// t6507 IP Core	 						////
////									////
//// This file is part of the t6507 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// I/O wrapper for the 6507 processor			 		////
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
`include "stubs.v"
module t6507lp_io(clk, reset_n, scan_enable, data_in, rw_mem, data_out, address);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'b0001;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'b0001;

	input clk;
	wire clkIO;

	input reset_n;
	wire reset_nIO;

	input scan_enable;
	wire scan_enableIO;

	input [DATA_SIZE_:0] data_in;
	reg [DATA_SIZE_:0] data_inIO;

	output rw_mem;
	wire rw_memIO;

	output [DATA_SIZE_:0] data_out;
	reg [DATA_SIZE_:0] data_outIO;

	output [ADDR_SIZE_:0] address;
	reg [ADDR_SIZE_:0] addressIO;

	wire pipo0, pipo1, pipo2, pipo3, pipo4, pipo5, pipo6, pipo7, pipo8, pipo9, pipo10, chainfinal;

	wire muxed;

	t6507lp t6507lp(  //core
		.clk		(clkIO),
		.reset_n	(reset_nIO),
		.data_in	(data_inIO),
		.rw_mem		(rw_memIO),
		.data_out	(data_outIO),
		.address	(addressIO)
	);

	wire vdd, gnd, dummy_clampc;

	ICP scan_pad(
		.PAD	(scan_enable), 
		.PI	(pipo10),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(chain_final),
		.Y	(scan_enableIO)
	);

/*	ICP test_pad(
		.PAD	(pintest), 
		.PI	(1'b1),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo0),
		.Y	(pintestIO)
	);
*/
	ICP clk_pad(
		.PAD	(clk), 
		.PI	(pipo9),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo10),
		.Y	(clkIO)
	);

	ICP reset_n_pad(
		.PAD	(reset_n), 
		.PI	(pipo8),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo9),
		.Y	(reset_nIO)
	);

	ICP data_in_pad0(
		.PAD	(data_in[0]), 
		.PI	(pipo7),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo8),
		.Y	(data_inIO[0])
	);

	ICP data_in_pad1(
		.PAD	(data_in[1]), 
		.PI	(pipo6),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo7),
		.Y	(data_inIO[1])
	);

	ICP data_in_pad2(
		.PAD	(data_in[2]), 
		.PI	(pipo5),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo6),
		.Y	(data_inIO[2])
	);

	ICP data_in_pad3(
		.PAD	(data_in[3]), 
		.PI	(pipo4),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo5),
		.Y	(data_inIO[3])
	);

	ICP data_in_pad4(
		.PAD	(data_in[4]), 
		.PI	(pipo3),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo4),
		.Y	(data_inIO[4])
	);

	ICP data_in_pad5(
		.PAD	(data_in[5]), 
		.PI	(pipo2),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo3),
		.Y	(data_inIO[5])
	);

	ICP data_in_pad6(
		.PAD	(data_in[6]), 
		.PI	(pipo1),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo2),
		.Y	(data_inIO[6])
	);

	ICP data_in_pad7(
		.PAD	(data_in[7]), 
		.PI	(pipo0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PO	(pipo1),
		.Y	(data_inIO[7])
	);

	BT4P rw_mem_pad(
		.A	(muxed),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(rw_mem)
	);

	BT4P data_out_pad0(
		.A	(data_outIO[0]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[0])
	);

	BT4P data_out_pad1(
		.A	(data_outIO[1]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[1])
	);

	BT4P data_out_pad2(
		.A	(data_outIO[2]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[2])
	);

	BT4P data_out_pad3(
		.A	(data_outIO[3]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[3])
	);

	BT4P data_out_pad4(
		.A	(data_outIO[4]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[4])
	);

	BT4P data_out_pad5(
		.A	(data_outIO[5]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[5])
	);

	BT4P data_out_pad6(
		.A	(data_outIO[6]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[6])
	);

	BT4P data_out_pad7(
		.A	(data_outIO[7]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(data_out[7])
	);

	BT4P address_pad0(
		.A	(addressIO[0]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[0])
	);

	BT4P address_pad1(
		.A	(addressIO[1]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[1])
	);
	BT4P address_pad2(
		.A	(addressIO[2]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[2])
	);
	BT4P address_pad3(
		.A	(addressIO[3]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[3])
	);
	BT4P address_pad4(
		.A	(addressIO[4]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[4])
	);
	BT4P address_pad5(
		.A	(addressIO[5]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[5])
	);
	BT4P address_pad6(
		.A	(addressIO[6]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[6])
	);
	BT4P address_pad7(
		.A	(addressIO[7]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[7])
	);
	BT4P address_pad8(
		.A	(addressIO[8]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[8])
	);
	BT4P address_pad9(
		.A	(addressIO[9]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[9])
	);
	BT4P address_pad10(
		.A	(addressIO[10]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[10])
	);
	BT4P address_pad11(
		.A	(addressIO[11]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[11])
	);

	BT4P address_pad12(
		.A	(addressIO[12]),
		.EN	(1'b0),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.CLAMPC	(dummy_clampc),
		.PAD	(address[12])
	);

	CORNERCLMP left_up_pad (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);

	CORNERCLMP left_down_pad (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);

	CORNERCLMP right_up_pad (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);

	CORNERCLMP right_down_pad (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);

 	GND5ALLPADP gnd_pad_left (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND	(gnd)
	);

	GND5ALLPADP gnd_pad_right (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND	(gnd)
	);

	GND5ALLPADP gnd_pad_up (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND	(gnd)
	);

	GND5ALLPADP gnd_pad_down (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND	(gnd)
	);

	VDD5ALLPADP vdd_pad_left (
		.CLAMPC	(dummy_clampc),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD	(vdd)
	);

	VDD5ALLPADP vdd_pad_right (
		.CLAMPC	(dummy_clampc),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD	(vdd)
	);

	VDD5ALLPADP vdd_pad_up (
		.CLAMPC	(dummy_clampc),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD	(vdd)
	);

	VDD5ALLPADP vdd_pad_down (
		.CLAMPC	(dummy_clampc),
		.GND5O	(gnd),
		.GND5R	(gnd),
		.VDD	(vdd)
	);

	assign muxed = (reset_nIO == 1'b1) ? chainfinal : rw_memIO;

 
/*	FILLERP_110 filler0 (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);

	FILLERP_110 filler1 (
		.CLAMPC	(dummy_clampc),
		.VDD5O	(vdd),
		.VDD5R	(vdd),
		.GND5O	(gnd),
		.GND5R	(gnd)
	);
*/
endmodule
