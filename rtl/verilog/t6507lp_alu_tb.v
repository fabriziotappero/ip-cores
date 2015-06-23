////////////////////////////////////////////////////////////////////////////
////                                                                    ////
//// T6507LP IP Core                                                    ////
////                                                                    ////
//// This file is part of the T6507LP project                           ////
//// http://www.opencores.org/cores/t6507lp/                            ////
////                                                                    ////
//// Description                                                        ////
//// 6507 ALU Testbench                                                 ////
////                                                                    ////
//// To Do:                                                             ////
//// - Search for TODO                                                  ////
////                                                                    ////
//// Author(s):                                                         ////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com                    ////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com     ////
////                                                                    ////
////////////////////////////////////////////////////////////////////////////
////                                                                    ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                       ////
////                                                                    ////
//// This source file may be used and distributed without               ////
//// restriction provided that this copyright statement is not          ////
//// removed from the file and that any derivative work contains        ////
//// the original copyright notice and the associated disclaimer.       ////
////                                                                    ////
//// This source file is free software; you can redistribute it         ////
//// and/or modify it under the terms of the GNU Lesser General         ////
//// Public License as published by the Free Software Foundation;       ////
//// either version 2.1 of the License, or (at your option) any         ////
//// later version.                                                     ////
////                                                                    ////
//// This source is distributed in the hope that it will be             ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied         ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ////
//// PURPOSE. See the GNU Lesser General Public License for more        ////
//// details.                                                           ////
////                                                                    ////
//// You should have received a copy of the GNU Lesser General          ////
//// Public License along with this source; if not, download it         ////
//// from http://www.opencores.org/lgpl.shtml                           ////
////                                                                    ////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module t6507lp_alu_tb;

`include  "t6507lp_package.v"

reg        clk;
reg        reset_n;
reg        alu_enable;
wire [7:0] alu_result;
wire [7:0] alu_status;
reg  [7:0] alu_opcode;
reg  [7:0] alu_a;
wire [7:0] alu_x;
wire [7:0] alu_y;

integer i, j;
integer ADC_RESULTS, SBC_RESULTS;

reg [7:0] alu_result_expected;
reg [7:0] alu_status_expected;
reg [7:0] alu_x_expected;
reg [7:0] alu_y_expected;

reg       C_in;
reg       C_temp;
reg       sign;
reg [7:0] temp1;
reg [7:0] temp2;
reg [3:0] AL;
reg [3:0] AH;
reg [3:0] BL;
reg [3:0] BH;
reg [7:0] alu_result_expected_temp;

t6507lp_alu DUT (
	.clk        (   clk    ),
	.reset_n    ( reset_n  ),
	.alu_enable (alu_enable),
	.alu_result (alu_result),
	.alu_status (alu_status),
	.alu_opcode (alu_opcode),
	.alu_a      (  alu_a   ),
	.alu_x      (  alu_x   ),
	.alu_y      (  alu_y   )
);


localparam period = 10;

task check;
	begin
		$display("               RESULTS       EXPECTED");
		$display("alu_result       %h             %h   ", alu_result, alu_result_expected);
		$display("alu_status    %b       %b   ", alu_status, alu_status_expected);
		$display("alu_x            %h             %h   ", alu_x,      alu_x_expected     );
		$display("alu_y            %h             %h   ", alu_y,      alu_y_expected     );
		if ((alu_result_expected == alu_result) && (alu_status_expected == alu_status) && (alu_x_expected == alu_x) && (alu_y_expected == alu_y))
		begin
			$display("Instruction %h... OK!", alu_opcode);
		end
		else
		begin
			$display("ERROR at instruction %h",alu_opcode);
			$finish;
		end
	end
endtask


always begin
	#(period/2) clk = ~clk;
end

initial
begin
	//ADC_RESULT = fopen("ADC_RESULTS.txt");
	//SBC_RESULT = fopen("SBC_RESULTS.txt");

	// Reset
	clk = 0;
	reset_n = 0;
	@(negedge clk);
	reset_n = 1;
	alu_enable = 1;
	alu_result_expected = 8'h00;
	alu_status_expected = 8'b00100010;
	alu_x_expected = 8'h00;
	alu_y_expected = 8'h00;

	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
	@(negedge clk);
	alu_result_expected = 8'h00;
                              // NV1BDIZC
	alu_status_expected = 8'b00100010;
	check;

	// ADC
	for (i = 0; i < 256; i = i + 1)
	begin
		alu_a = i;
		alu_opcode = LDA_IMM;
		@(negedge clk);
		alu_result_expected = i;
		alu_status_expected[Z] = (alu_a == 0) ? 1 : 0;
		alu_status_expected[N] = alu_a[7];
		check;
		for (j = 0; j < 256; j = j + 1)
		begin
			alu_opcode = ADC_IMM;
			alu_a = j;
			@(negedge clk);
			sign = alu_result_expected[7];
			{alu_status_expected[C], alu_result_expected} = alu_result_expected + alu_a + alu_status_expected[C];
			alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
			alu_status_expected[N] = alu_result_expected[7];
			alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
			check;
		end
	end

	// SBC
	for (i = 0; i < 256; i = i + 1)
	begin
		alu_a = i;
		alu_opcode = LDA_IMM;
		@(negedge clk);
		alu_result_expected = i;
		alu_status_expected[Z] = (alu_a == 0) ? 1 : 0;
		alu_status_expected[N] = alu_a[7];
		check;
		for (j = 0; j < 256; j = j + 1)
		begin
			alu_opcode = SBC_IMM;
			alu_a = j;
			@(negedge clk);
			sign = alu_result_expected[7];
			alu_result_expected = alu_result_expected - alu_a - (1 - alu_status_expected[C]);
			alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
			alu_status_expected[N] = alu_result_expected[7];
			alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] == alu_result_expected[7]));
			alu_status_expected[C] = ~alu_result_expected[7];
			check;
		end
	end
	
	// CLC
	alu_opcode = CLC_IMP;
	@(negedge clk);
	alu_status_expected[C] = 0;
	check;
	
/*
	// SED
	alu_opcode = SED_IMP;
	@(negedge clk);
	alu_status_expected[D] = 1;
	check;
	
	// ADC
	alu_opcode = ADC_IMM;
	alu_a = 8'h12;
	@(negedge clk);
	sign = alu_result_expected[7];
	AL = alu_a[3:0] + alu_result_expected[3:0] + alu_status_expected[C];
	$display("AL = %b", AL);
	AH = alu_a[7:4] + alu_result_expected[7:4] + AL[4];
	$display("AH = %b", AH);
	if (AL > 9) begin
	  temp1 = AL - 6;
	end
	else begin
	  temp1 = AL;
	end
	$display("temp1 = %b", temp1);
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
	if (AH > 9) begin
	  temp2 = AH - 6;
	end
	else begin
	  temp2 = AH;
	end
	$display("temp2 = %b", temp2);
	alu_status_expected[C] = (temp2 > 15) ? 1 : 0;
	alu_result_expected = {temp2[3:0],temp1[3:0]};
	$display("A = %b PS = %b", alu_result_expected, alu_status_expected);
	check;

	// CLD
	alu_opcode = CLD_IMP;
	@(negedge clk);
	alu_status_expected[D] = 0;
	check;
*/
/*
	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
        //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
	alu_status_expected[N] = 0;
	alu_status_expected[Z] = 1;
	check;
	
	// SED
	alu_opcode = SED_IMP;
	//$display("A = %h B = %h X = %h Y = %h", alu_result, alu_a, alu_x, alu_y);
	@(negedge clk);
	alu_status_expected[D] = 1;
	check;

	// ADC
	alu_opcode = ADC_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = $random;
		//$display("A = %h B = %h C = %b X = %h Y = %h", alu_result, alu_a, alu_status_expected[C], alu_x, alu_y);
		@(negedge clk);
		AL = alu_result_expected[3:0] + alu_a[3:0] + alu_status_expected[C];
		AH = alu_result_expected[7:4] + alu_a[7:4] + AL[4];
		if (AL > 9) AL = AL + 6;
		if (AH > 9) AH = AH + 6;
		alu_status_expected[C] = AH[4];
		alu_result_expected = {AH[3:0],AL[3:0]};
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
		check;
	end
	//$stop;
	// CLD
	alu_opcode = CLD_IMP;
	@(negedge clk);
	alu_status_expected[D] = 0;
	check;
*/
	// ASL
	alu_opcode = ASL_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		{alu_status_expected[C], alu_result_expected} = {alu_a,1'b0};
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// ROL
	alu_opcode = ROL_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		{alu_status_expected[C], alu_result_expected} = {alu_a,alu_status_expected[C]};
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end
	
	// ROR
	alu_opcode = ROR_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		{alu_result_expected, alu_status_expected[C]} = {alu_status_expected[C],alu_a};
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end
	
	// LDA
	alu_a = 137;
	alu_opcode = LDA_IMM;
	@(negedge clk);
	alu_result_expected = 8'd137;
	//                       NV1BDIZC
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check;
	
	// EOR
	alu_opcode = EOR_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = alu_a ^ alu_result_expected;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	/*
	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
    //$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
	//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check;

	// SBC
	alu_opcode = SBC_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = 1;
		@(negedge clk);
		//$display("i = %d alu_opcode = %h alu_enable = %d", i, alu_opcode, alu_enable);
		//$display("DUT.A = %h DUT.X = %h DUT.Y = %h", DUT.A, DUT.X, DUT.Y);
		//$display("op1 = %d op2 = %d  c = %d d = %d n = %d v = %d result = %d", alu_a, DUT.A, alu_status[C], alu_status[D], alu_status[N], alu_status[V], alu_result);
		sign = alu_result_expected[7];
		alu_result_expected = alu_result_expected - alu_a - ( 1 - alu_status_expected[C]);
		alu_status_expected[C] = ~alu_result_expected[7];
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		//$display("alu_a[7] = %b == sign = %b && alu_a[7] = %b != alu_result_expected[7] = %b", alu_a[7], sign, alu_a[7], alu_result_expected[7]);
		alu_status_expected[V] = ((alu_a[7] == sign) && (alu_a[7] != alu_result_expected[7]));
		check;
	end
	*/

	// LDA
	alu_opcode = LDA_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = i;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// LDX
	alu_opcode = LDX_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_x_expected = alu_a;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		check;
	end

	// LDY
	alu_opcode = LDY_IMM;
	for (i = 0; i < 1001; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_y_expected = alu_a;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		check;
	end

	// STA
	alu_opcode = STA_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		check;
	end

	// STX
	alu_opcode = STX_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		check;
	end

	// STY
	alu_opcode = STY_ABS;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		check;
	end

	// CMP
	alu_opcode = CMP_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp1 = alu_result_expected - alu_a;
		alu_status_expected[Z] = (temp1 == 0) ? 1 : 0;
		alu_status_expected[N] = temp1[7];
		alu_status_expected[C] = (alu_result_expected >= alu_a) ? 1 : 0;
		check;
	end

	// CPX
	alu_opcode = CPX_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp1 = alu_x_expected - alu_a;
		alu_status_expected[Z] = (temp1 == 0) ? 1 : 0;
		alu_status_expected[N] = temp1[7];
		alu_status_expected[C] = (alu_x_expected >= alu_a) ? 1 : 0;
		check;
	end

	// CPY
	alu_opcode = CPY_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		temp1 = alu_y_expected - alu_a;
		alu_status_expected[Z] = (temp1 == 0) ? 1 : 0;
		alu_status_expected[N] = temp1[7];
		alu_status_expected[C] = (alu_y_expected >= alu_a) ? 1 : 0;
		check;
	end
	

	// AND
	alu_opcode = AND_IMM;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = alu_a & alu_result_expected;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// ASL
	alu_opcode = ASL_ACC;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_status_expected[C] = alu_result_expected[7];
		alu_result_expected[7:0] = alu_result_expected << 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// INC
	alu_opcode = INC_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = alu_a + 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// INX
	alu_opcode = INX_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_x_expected = alu_x_expected + 1;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		check;
	end

	// INY
	alu_opcode = INY_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_y_expected = alu_y_expected + 1;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		check;
	end

	// DEC
	alu_opcode = DEC_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_result_expected = alu_a - 1;
		alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_result_expected[7];
		check;
	end

	// DEX
	alu_opcode = DEX_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_x_expected = alu_x_expected - 1;
		alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_x_expected[7];
		check;
	end

	// DEY
	alu_opcode = DEY_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_y_expected = alu_y_expected - 1;
		alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
		alu_status_expected[N] = alu_y_expected[7];
		check;
	end


	// LDA
	alu_a = 0;
	alu_opcode = LDA_IMM;
	@(negedge clk);
	alu_result_expected = 8'h00;
	//                       NV1BDIZC
        alu_status_expected[Z] = 1;
	alu_status_expected[N] = 0;
	check;

	// BIT
	alu_opcode = BIT_ZPG;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_status_expected[Z] = ((alu_a & alu_result_expected) == 0) ? 1 : 0;
		alu_status_expected[V] = alu_a[6];
		alu_status_expected[N] = alu_a[7];
		check;
	end

	// RTI
	alu_opcode = RTI_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_status_expected[C] = alu_a[C];
		alu_status_expected[Z] = alu_a[Z];
		alu_status_expected[N] = alu_a[N];
		alu_status_expected[V] = alu_a[V];
		alu_status_expected[B] = alu_a[B];
		alu_status_expected[D] = alu_a[D];
		alu_status_expected[I] = alu_a[I];
		check;
	end

	// PLP
	alu_opcode = PLP_IMP;
	for (i = 0; i < 1000; i = i + 1)
	begin
		alu_a = i;
		@(negedge clk);
		alu_status_expected[C] = alu_a[C];
		alu_status_expected[Z] = alu_a[Z];
		alu_status_expected[N] = alu_a[N];
		alu_status_expected[V] = alu_a[V];
		alu_status_expected[B] = alu_a[B];
		alu_status_expected[D] = alu_a[D];
		alu_status_expected[I] = alu_a[I];
		check;
	end

	// PHA
	alu_opcode = PHA_IMP;
	@(negedge clk);
	check;

	// PHP
	alu_opcode = PHP_IMP;
	@(negedge clk);
	check;

	// BRK
	alu_opcode = BRK_IMP;
	@(negedge clk);
	alu_status_expected[B] = 1;
	check;
		
	// SEC
	alu_opcode = SEC_IMP;
	@(negedge clk);
	alu_status_expected[C] = 1;
	check;

	// SED
	alu_opcode = SED_IMP;
	@(negedge clk);
	alu_status_expected[D] = 1;
	check;

	// SEI
	alu_opcode = SEI_IMP;
	@(negedge clk);
	alu_status_expected[I] = 1;
	check;

	// CLC
	alu_opcode = CLC_IMP;
	@(negedge clk);
	alu_status_expected[C] = 0;
	check;

	// CLD
	alu_opcode = CLD_IMP;
	@(negedge clk);
	alu_status_expected[D] = 0;
	check;

	// CLI
	alu_opcode = CLI_IMP;
	@(negedge clk);
	alu_status_expected[I] = 0;
	check;

	// CLV
	alu_opcode = CLV_IMP;
	@(negedge clk);
	alu_status_expected[V] = 0;
	check;

	// LDA
	alu_opcode = LDA_IMM;
	alu_a = 8'h76;
	@(negedge clk);
	alu_result_expected = alu_a;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check;

	// TAX
	alu_opcode = TAX_IMP;
	@(negedge clk);
	alu_x_expected = alu_result_expected;
	alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_x_expected[7];
	check;

	// TAY
	alu_opcode = TAY_IMP;
	@(negedge clk);
	alu_y_expected = alu_result_expected;
	alu_status_expected[Z] = (alu_y_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_y_expected[7];
	check;
	
	// TSX
	alu_opcode = TSX_IMP;
	@(negedge clk);
	alu_x_expected = alu_a;
	//alu_result_expected = alu_a;
	alu_status_expected[Z] = (alu_x_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_x_expected[7];
	check;

	// TXA
	alu_opcode = TXA_IMP;
	@(negedge clk);
	alu_result_expected = alu_x_expected;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check;

	// TXS
	alu_opcode = TXS_IMP;
	@(negedge clk);
	alu_result_expected = alu_x_expected;
	check;

	// TYA
	alu_opcode = TYA_IMP;
	@(negedge clk);
	alu_result_expected = alu_y_expected;
	alu_status_expected[Z] = (alu_result_expected == 0) ? 1 : 0;
	alu_status_expected[N] = alu_result_expected[7];
	check;

	// Nothing should happen
	// BCC
	alu_opcode = BCC_REL;
	@(negedge clk);
	check;

	// BCS
	alu_opcode = BCS_REL;
	@(negedge clk);
	check;

	// BEQ
	alu_opcode = BEQ_REL;
	@(negedge clk);
	check;

	// BMI
	alu_opcode = BMI_REL;
	@(negedge clk);
	check;

	// BNE
	alu_opcode = BNE_REL;
	@(negedge clk);
	check;

	// BPL
	alu_opcode = BPL_REL;
	@(negedge clk);
	check;

	// BVC
	alu_opcode = BVC_REL;
	@(negedge clk);
	check;

	// BVS
	alu_opcode = BVS_REL;
	@(negedge clk);
	check;
	
	// JMP
	alu_opcode = JMP_ABS;
	@(negedge clk);
	check;

	// JMP
	alu_opcode = JMP_IND;
	@(negedge clk);
	check;
	
	// JSR
	alu_opcode = JSR_ABS;
	@(negedge clk);
	check;
	
	// NOP
	alu_opcode = NOP_IMP;
	@(negedge clk);
	check;

	// RTS
	alu_opcode = RTS_IMP;
	@(negedge clk);
	check;

	$display("TEST PASSED");
	$finish;
end

endmodule


