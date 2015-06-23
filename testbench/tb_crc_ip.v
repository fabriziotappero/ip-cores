//////////////////////////////////////////////////////////////////
////
////
//// 	CRCAHB CORE BLOCK
////
////
////
//// This file is part of the APB to I2C project
////
//// http://www.opencores.org/cores/apbi2c/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// crcahb IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): -  Julio Cesar 
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////

module tb_crc_ip();

//Memory Map
localparam CRC_DR   = 32'h0;
localparam CRC_IDR  = 32'h4;
localparam CRC_CR   = 32'h8;
localparam CRC_INIT = 32'h10;
localparam CRC_POL  = 32'h14;

//HTRANS Encoding
localparam IDLE    = 2'b00;
localparam BUSY    = 2'b01;
localparam NON_SEQ = 2'b10;
localparam SEQ     = 2'b11;

//HSIZE Encoding
localparam BYTE      = 2'b00;
localparam HALF_WORD = 2'b01;
localparam WORD      = 2'b10;

//CRC_CR Encoding
localparam RESET             = 32'h00000001;
localparam POLY_SIZE_32      = 32'h00000000;
localparam POLY_SIZE_16      = 32'h00000001 << 3;
localparam POLY_SIZE_8       = 32'h00000001 << 4;
localparam POLY_SIZE_7       = 32'h00000003 << 3;
localparam REV_IN_NORMAL     = 32'h00000000;
localparam REV_IN_BYTE       = 32'h00000001 << 5;
localparam REV_IN_HALF_WORD  = 32'h00000001 << 6;
localparam REV_IN_WORD       = 32'h00000003 << 5;
localparam REV_OUT_NORMAL    = 32'h00000000;
localparam REV_OUT_REV       = 32'h00000001 << 7;

wire [31:0] HRDATA;
wire HREADYOUT;
wire HRESP;

reg [31:0] HWDATA;
reg [31:0] HADDR;
reg [ 2:0] HSIZE;
reg [ 1:0] HTRANS;
reg HWRITE;
reg HSElx;
reg HREADY;
reg HRESETn;
reg HCLK;

reg [31:0] result, golden;
reg [31:0] data_init, data_crc;
reg [31:0] data_rev;

task reset;
	begin
		HWDATA = 0;
		HADDR = 0;
		HSIZE = 0;
		HTRANS = 0;
		HWRITE = 0;
		HSElx = 0;
		HREADY = 1;
		HRESETn = 0;
		HCLK = 0;
		@(posedge HCLK);
		@(posedge HCLK);
		HRESETn = 1;
		@(posedge HCLK);
	end
endtask

task write_ahb;
	input [31:0] addr;
	input [31:0] data;
	input [ 1:0] size;
	begin
		HADDR <= addr;
		HSElx <= 1;
		HTRANS <= NON_SEQ;
		HSIZE <= size;
		HWRITE <= 1;
		@(negedge HCLK);
		if(HREADYOUT == 0)
			@(posedge HREADYOUT);
		@(posedge HCLK);
		HWDATA <= data;
		HSElx <= 0;
		HTRANS <= IDLE;
	end
endtask

task read_ahb;
	input  [31:0] addr;
	output [31:0] data_rd;
	begin
		HADDR <= addr;
		HSElx <= 1;
		HTRANS <= NON_SEQ;
		HWRITE <= 0;
		@(posedge HCLK);
		@(negedge HCLK);
		if(HREADYOUT == 0)
			@(posedge HREADYOUT);
		@(negedge HCLK);
		//@(posedge HCLK);
		data_rd = HRDATA;
		HSElx = 0;
		HTRANS = IDLE;
	end
endtask

task compare;
	input [31:0] golden;
	input [31:0] result;
	begin
		if(golden != result)
			begin
				$display("Error Founded...Expected %x, obtained %x", golden, result);	
				$stop;
			end
	end
endtask

crc_ip CRC_IP
(
	.HRDATA    ( HRDATA    ),
	.HREADYOUT ( HREADYOUT ),
	.HRESP     ( HRESP     ),
	.HWDATA    ( HWDATA    ),
	.HADDR     ( HADDR     ),
	.HSIZE     ( HSIZE     ),
	.HTRANS    ( HTRANS    ),
	.HWRITE    ( HWRITE    ),
	.HSElx     ( HSElx     ),
	.HREADY    ( HREADY    ),
	.HRESETn   ( HRESETn   ),
	.HCLK      ( HCLK      )
);

initial
	begin
		reset;

		write_ahb(CRC_DR, 32'h01020304, WORD);
		write_ahb(3'h1, 32'h05060708, WORD);
		write_ahb(3'h2, 32'h090a0b0c, WORD);
		write_ahb(3'h3, 32'h0d0e0f00, WORD);
		write_ahb(3'h4, 32'h00112233, WORD);

		read_ahb(CRC_DR, result);

		write_ahb(CRC_IDR, 32'h89abcdef, WORD);
		read_ahb(CRC_IDR, result);

		//Test Case 1: Write and Read in IDR
		golden = 32'h89abcdee;
		write_ahb(CRC_IDR, golden, WORD);
		read_ahb(CRC_IDR, result);
		compare(32'hff & golden, result);

		golden = 32'hffeeddcc;
		write_ahb(CRC_IDR, golden, BYTE);
		read_ahb(CRC_IDR, result);
		compare(32'hff & golden, result);

   //Test Case 2: Write and Read in CR
		golden = 32'hffeeddcc;

   //Test Case 2: Write and Read in CR
		golden = 32'hffeeddcc;
		write_ahb(CRC_CR, golden, WORD);
		read_ahb(CRC_CR, result);
		compare(32'hf8 & golden, result);

		golden = 32'hffeeddff;
		write_ahb(CRC_CR, golden, WORD);
		read_ahb(CRC_CR, result);
		compare(32'hf8 & golden, result);

	//Test Case 3: Write and Read in INIT
		golden = 32'hffeeddcc;
		write_ahb(CRC_INIT, golden, WORD);
		read_ahb(CRC_INIT, result);
		compare(golden, result);

		golden = 32'hffeeddff;
		write_ahb(CRC_INIT, golden, WORD);
		read_ahb(CRC_INIT, result);
		compare(golden, result);

	//Test Case 4: Write and Read in POL
		golden = 32'h11235813;
		write_ahb(CRC_POL, golden, WORD);
		read_ahb(CRC_POL, result);
		compare(golden, result);

		golden = 32'h24161614;
		write_ahb(CRC_POL, golden, WORD);
		read_ahb(CRC_POL, result);
		compare(golden, result);

	//Test Case 5: Programmable Initial CRC Value
		//POLY_SIZE_32, Data_32
		data_init = 32'h14635287;
		data_crc = 32'haabbccdd;
		golden = //crc_32(32'hddccbbaa, data_init);
		crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init))));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_32, Data_16
		data_init = 32'h14635287;
		data_crc = 32'h11223344;
		golden = crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_32, Data_8
		data_init = 32'h11223344;
		data_crc = 32'h01463528;
		golden = crc_32(data_crc[7:0], data_init);
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, BYTE);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);
 
		//POLY_SIZE_16, Data_32
		data_init = 32'hadefbc89;
		data_crc = 32'h01463528;
		golden = crc_16(data_crc[31:24], crc_16(data_crc[23:16], crc_16(data_crc[15:8], crc_16(data_crc[7:0], data_init))));
		write_ahb(CRC_POL, 32'h00018005, WORD);
		write_ahb(CRC_CR, POLY_SIZE_16 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_16, Data_16
		data_init = 32'h01463528;
		data_crc = 32'hadefbc89;
		golden = crc_16(data_crc[15:8], crc_16(data_crc[7:0], data_init));
		write_ahb(CRC_POL, 32'h00018005, WORD);
		write_ahb(CRC_CR, POLY_SIZE_16 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_16, Data_8
		data_init = 32'h01463d28;
		data_crc = 32'haedfbc89;
		golden = crc_16(data_crc[7:0], data_init);
		write_ahb(CRC_POL, 32'h00018005, WORD);
		write_ahb(CRC_CR, POLY_SIZE_16 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, BYTE);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_8, Data_32
		data_init = 32'h11453028;
		data_crc = 32'haed7bc39;
		golden = crc_8(data_crc[31:24], crc_8(data_crc[23:16], crc_8(data_crc[15:8], crc_8(data_crc[7:0], data_init))));
		write_ahb(CRC_POL, 32'h00000107, WORD);
		write_ahb(CRC_CR, POLY_SIZE_8 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_8, Data_16
		data_init = 32'h11003028;
		data_crc = 32'haed70039;
		golden = crc_8(data_crc[15:8], crc_8(data_crc[7:0], data_init));
		write_ahb(CRC_POL, 32'h00000107, WORD);
		write_ahb(CRC_CR, POLY_SIZE_8 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_8, Data_8
		data_init = 32'h11000028;
		data_crc = 32'hafdfff39;
		golden = crc_8(data_crc[7:0], data_init);
		write_ahb(CRC_POL, 32'h00000107, WORD);
		write_ahb(CRC_CR, POLY_SIZE_8 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, BYTE);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_7, Data_32
		data_init = 32'h11453087;
		data_crc = 32'haed7bcfd;
		golden = crc_7(data_crc[31:24], crc_7(data_crc[23:16], crc_7(data_crc[15:8], crc_7(data_crc[7:0], data_init))));
		write_ahb(CRC_POL, 32'h00000087, WORD);
		write_ahb(CRC_CR, POLY_SIZE_7 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_7, Data_16
		data_init = 32'h00453057;
		data_crc = 32'haed773fd;
		golden = crc_7(data_crc[15:8], crc_7(data_crc[7:0], data_init));
		write_ahb(CRC_POL, 32'h00000087, WORD);
		write_ahb(CRC_CR, POLY_SIZE_7 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

		//POLY_SIZE_7, Data_8
		data_init = 32'h0045301d;
		data_crc = 32'haed7732a;
		golden = crc_7(data_crc[7:0], data_init);
		write_ahb(CRC_POL, 32'h00000087, WORD);
		write_ahb(CRC_CR, POLY_SIZE_7 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, BYTE);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

	//Test Case 6: Test REV_IN configuratin
	//REV_IN_BYTE
		data_init = 32'h14635287;
		data_crc = 32'h1a2b3c4d;
		data_rev = 32'h58d43cb2;
		golden = crc_32(data_rev[31:24], crc_32(data_rev[23:16], crc_32(data_rev[15:8], crc_32(data_rev[7:0], data_init))));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET | REV_IN_BYTE, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);
	
	//REV_IN_HALF_WORD
		data_init = 32'h14635287;
		data_crc = 32'h1a2b3c4d;
		data_rev = 32'hd458b23c;
		golden = crc_32(data_rev[31:24], crc_32(data_rev[23:16], crc_32(data_rev[15:8], crc_32(data_rev[7:0], data_init))));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET | REV_IN_HALF_WORD, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

	//REV_IN_WORD
		data_init = 32'h14635287;
		data_crc = 32'h1a2b3c4d;
		data_rev = 32'hb23cd458;
		golden = crc_32(data_rev[31:24], crc_32(data_rev[23:16], crc_32(data_rev[15:8], crc_32(data_rev[7:0], data_init))));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET | REV_IN_WORD, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

	//Test Case 7: Test REV_OUT configuratin
	//REV_IN_BYTE
		data_init = 32'h14635287;
		data_crc = 32'h1a2b3c4d;
		golden = rev_out(crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init)))));
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET | REV_OUT_REV, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		compare(golden, result);
		$display("%x", golden);

	//Test Case 8: Test RESET, Data 32
		data_init = 32'h14635287;
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		
		//Data 1
		data_crc = 32'h00112233;
		write_ahb(CRC_DR, data_crc, WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 2
		data_crc = 32'h44556677;
		write_ahb(CRC_DR, data_crc, WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 3
		data_crc = 32'h8899aabb;
		write_ahb(CRC_DR, data_crc, WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 4
		data_crc = 32'hccddeeff;
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		write_ahb(CRC_CR, RESET, WORD);
		

		read_ahb(CRC_DR, result);
		golden = crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init))));
		compare(golden, result);
		$display("%x", golden);

		//Test Case 9: Test RESET, Data 16
		data_init = 32'h14635287;
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		
		//Data 1
		data_crc = 32'h00112233;
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 2
		data_crc = 32'h44556677;
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 3
		data_crc = 32'h8899aabb;
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 4
		data_crc = 32'hccddeeff;
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, HALF_WORD);
		write_ahb(CRC_CR, RESET, WORD);
		

		read_ahb(CRC_DR, result);
		golden = crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init));
		compare(golden, result);
		$display("%x", golden);

		//Test Case 10: Test RESET, Data 8
		data_init = 32'h14635287;
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		
		//Data 1
		data_crc = 32'h00112233;
		write_ahb(CRC_DR, data_crc, BYTE);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 2
		data_crc = 32'h44556677;
		write_ahb(CRC_DR, data_crc, BYTE);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 3
		data_crc = 32'h8899aabb;
		write_ahb(CRC_DR, data_crc, BYTE);
		write_ahb(CRC_CR, RESET, WORD);

		//Data 4
		data_crc = 32'hccddeeff;
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, BYTE);
		write_ahb(CRC_CR, RESET, WORD);
		

		read_ahb(CRC_DR, result);
		golden = crc_32(data_crc[7:0], data_init);
		compare(golden, result);
		$display("%x", golden);

		//Test Case 11: Write-Write-Reset
		data_init = 32'h146352dd;
		write_ahb(CRC_POL, 32'h04c11db7, WORD);
		write_ahb(CRC_CR, POLY_SIZE_32 | RESET, WORD);
		write_ahb(CRC_INIT, data_init, WORD);
		
		//Data 1
		data_crc = 32'h55112233;
		write_ahb(CRC_DR, data_crc, WORD);
		golden = crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init))));

		//Data 2
		data_crc = 32'h44006677;
		write_ahb(CRC_DR, data_crc, WORD);
		write_ahb(CRC_CR, RESET, WORD);

		read_ahb(CRC_DR, result);
		golden = crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], golden))));
		compare(golden, result);
		$display("%x", golden);

		//Data 3
		data_crc = 32'h44005127;
		data_init = 32'h11112222;
		write_ahb(CRC_INIT, data_init, WORD);
		write_ahb(CRC_DR, data_crc, WORD);
		read_ahb(CRC_DR, result);
		golden = crc_32(data_crc[31:24], crc_32(data_crc[23:16], crc_32(data_crc[15:8], crc_32(data_crc[7:0], data_init))));
		compare(golden, result);
		$display("%x", golden);
		$stop;
	end

always #10
	HCLK = !HCLK;

function [31:0] rev_out;
	input [31:0] in;
	integer i;
	begin
		for(i = 0; i < 32; i = i + 1)
			rev_out[i] = in[31 - i];
	end
endfunction

  function [31:0] crc_32;

    input [7:0] Data;
    input [31:0] crc;
    reg [7:0] d;
    reg [31:0] c;
    reg [31:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[6] ^ d[0] ^ c[24] ^ c[30];
    newcrc[1] = d[7] ^ d[6] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[30] ^ c[31];
    newcrc[2] = d[7] ^ d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31];
    newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[27] ^ c[31];
    newcrc[4] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30];
    newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
    newcrc[6] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
    newcrc[7] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];
    newcrc[8] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
    newcrc[9] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29];
    newcrc[10] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29];
    newcrc[11] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
    newcrc[12] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30];
    newcrc[13] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31];
    newcrc[14] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31];
    newcrc[15] = d[7] ^ d[5] ^ d[4] ^ d[3] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31];
    newcrc[16] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[24] ^ c[28] ^ c[29];
    newcrc[17] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[25] ^ c[29] ^ c[30];
    newcrc[18] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[26] ^ c[30] ^ c[31];
    newcrc[19] = d[7] ^ d[3] ^ c[11] ^ c[27] ^ c[31];
    newcrc[20] = d[4] ^ c[12] ^ c[28];
    newcrc[21] = d[5] ^ c[13] ^ c[29];
    newcrc[22] = d[0] ^ c[14] ^ c[24];
    newcrc[23] = d[6] ^ d[1] ^ d[0] ^ c[15] ^ c[24] ^ c[25] ^ c[30];
    newcrc[24] = d[7] ^ d[2] ^ d[1] ^ c[16] ^ c[25] ^ c[26] ^ c[31];
    newcrc[25] = d[3] ^ d[2] ^ c[17] ^ c[26] ^ c[27];
    newcrc[26] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30];
    newcrc[27] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31];
    newcrc[28] = d[6] ^ d[5] ^ d[2] ^ c[20] ^ c[26] ^ c[29] ^ c[30];
    newcrc[29] = d[7] ^ d[6] ^ d[3] ^ c[21] ^ c[27] ^ c[30] ^ c[31];
    newcrc[30] = d[7] ^ d[4] ^ c[22] ^ c[28] ^ c[31];
    newcrc[31] = d[5] ^ c[23] ^ c[29];
    crc_32 = newcrc;
  end
  endfunction

function [15:0] crc_16;

    input [7:0] Data;
    input [15:0] crc;
    reg [7:0] d;
    reg [15:0] c;
    reg [15:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    newcrc[1] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    newcrc[2] = d[1] ^ d[0] ^ c[8] ^ c[9];
    newcrc[3] = d[2] ^ d[1] ^ c[9] ^ c[10];
    newcrc[4] = d[3] ^ d[2] ^ c[10] ^ c[11];
    newcrc[5] = d[4] ^ d[3] ^ c[11] ^ c[12];
    newcrc[6] = d[5] ^ d[4] ^ c[12] ^ c[13];
    newcrc[7] = d[6] ^ d[5] ^ c[13] ^ c[14];
    newcrc[8] = d[7] ^ d[6] ^ c[0] ^ c[14] ^ c[15];
    newcrc[9] = d[7] ^ c[1] ^ c[15];
    newcrc[10] = c[2];
    newcrc[11] = c[3];
    newcrc[12] = c[4];
    newcrc[13] = c[5];
    newcrc[14] = c[6];
    newcrc[15] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
    crc_16 = newcrc;
  end
  endfunction

function [7:0] crc_8;

    input [7:0] Data;
    input [7:0] crc;
    reg [7:0] d;
    reg [7:0] c;
    reg [7:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[7] ^ d[6] ^ d[0] ^ c[0] ^ c[6] ^ c[7];
    newcrc[1] = d[6] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[6];
    newcrc[2] = d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[2] ^ c[6];
    newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[1] ^ c[2] ^ c[3] ^ c[7];
    newcrc[4] = d[4] ^ d[3] ^ d[2] ^ c[2] ^ c[3] ^ c[4];
    newcrc[5] = d[5] ^ d[4] ^ d[3] ^ c[3] ^ c[4] ^ c[5];
    newcrc[6] = d[6] ^ d[5] ^ d[4] ^ c[4] ^ c[5] ^ c[6];
    newcrc[7] = d[7] ^ d[6] ^ d[5] ^ c[5] ^ c[6] ^ c[7];
    crc_8 = newcrc;
  end
  endfunction

function [6:0] crc_7;

    input [7:0] Data;
    input [6:0] crc;
    reg [7:0] d;
    reg [6:0] c;
    reg [6:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[7] ^ d[6] ^ d[5] ^ d[0] ^ c[4] ^ c[5] ^ c[6];
    newcrc[1] = d[5] ^ d[1] ^ d[0] ^ c[0] ^ c[4];
    newcrc[2] = d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[4] ^ c[6];
    newcrc[3] = d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[1] ^ c[2] ^ c[5];
    newcrc[4] = d[7] ^ d[4] ^ d[3] ^ d[2] ^ c[1] ^ c[2] ^ c[3] ^ c[6];
    newcrc[5] = d[5] ^ d[4] ^ d[3] ^ c[2] ^ c[3] ^ c[4];
    newcrc[6] = d[6] ^ d[5] ^ d[4] ^ c[3] ^ c[4] ^ c[5];
    crc_7 = newcrc;
		end
		endfunction
endmodule
