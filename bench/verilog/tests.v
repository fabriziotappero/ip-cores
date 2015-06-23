/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Tests Library                                              ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/vga_lcd/   ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: tests.v,v 1.1 2001-08-16 10:01:05 rudi Exp $
//
//  $Date: 2001-08-16 10:01:05 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//
//
//
//                        


task show_errors;
begin

$display("\n");
$display("     +--------------------+");
$display("     |  Total ERRORS: %0d   |", error_cnt);
$display("     +--------------------+");

end
endtask


task reg_test;

reg	[31:0]	data;
reg	[31:0]	pattern;
integer		n;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** Register Test                                 ***");
$display("*****************************************************\n");



show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask



task io_test1;

reg	[31:0]	data;
reg	[31:0]	data1;
reg	[31:0]	data2;
reg	[31:0]	data3;
integer		n;
integer		id;
integer		del;
integer		del_max;
integer		iordy_del;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** IO Test 1                                     ***");
$display("*** Testing WISHBONE wait state insertion, and    ***");
$display("*** iordy assertion.                              ***");
$display("*****************************************************\n");

id = 0;
del_max = 16;
for(del=0;del<del_max;del=del+1)
for(id=0;id<2;id=id+1)
begin
	if(!verbose)
	$display("*** MODE SELECT: 'iordy' enable: %0d, wb-delay: %0d\n", id, del);

for(iordy_del=0;iordy_del<(id ? 600 : 1);iordy_del=iordy_del+10)
   begin

	if(verbose)
	$display("*** MODE SELECT: 'iordy' enable: %0d, wb-delay: %0d iordy_del: %0d\n",
		id, del, iordy_del);

	a0.iordy_enable = id;
	a0.iordy_delay = 600;	// Delay in nS
	a0.init_mem;

	if(id==1)	data1 = 32'h0000_0082;
	else		data1 = 32'h0000_0080;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	m0.wb_rd1( `STAT, 4'hf, data );
	m0.wb_rd1( `PCTR, 4'hf, data );

   	repeat(10)	@(posedge clk);

	// Read only Test of ATA registers
	if(verbose)	$display(">>> Running Read Only test 1 ... (%0t)", $time);
	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != (n+8) )
		   begin
			$display("ERROR: Read 1 Mismatch: Expected: %h Got: %h (%0t)",
				(n+8), data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 1 ... (%0t)", $time);

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_wr1( `ATA_DEV + (n*4) , 4'hf, ~n[15:0] );
		if(a0.mem[n+8] != ~n[15:0] )
		   begin
			$display("ERROR: Write 1 Mismatch: Expected: %h Got: %h (%0t)",
				~n[15:0], a0.mem[n+8], $time);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != ~n[15:0] )
		   begin
			$display("ERROR: Read 2 Mismatch: Expected: %h Got: %h (%0t)",
				~n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 2 ... (%0t)", $time);

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_wr1( `ATA_DEV + (n*4) , 4'hf, n[15:0] );
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != n[15:0] )
		   begin
			$display("ERROR: Read 3 Mismatch: Expected: %h Got: %h (%0t)",
				n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");


	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 3 ... (%0t)", $time);

	for(n=0;n<16;n=n+4)
	   begin
		m0.wb_wr4( `ATA_DEV + (n*4) , 4'hf, del,
				{16'h0, ~n[13:0], 2'h3},
				{16'h0, ~n[13:0], 2'h2},
				{16'h0, ~n[13:0], 2'h1},
				{16'h0, ~n[13:0], 2'h0}		);

		m0.wb_rd4( `ATA_DEV + (n*4) , 4'hf, del, data, data1, data2, data3 );

		if(	(data[15:0]  != {~n[13:0], 2'h3}) |
			(data1[15:0] != {~n[13:0], 2'h2}) |
			(data2[15:0] != {~n[13:0], 2'h1}) |
			(data3[15:0] != {~n[13:0], 2'h0}) )
		   begin
			$display("ERROR: Read 3 Mismatch: Expected: %h Got: %h (%0t)",
				n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");


	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 4 (RMW) ... (%0t)", $time);

	a0.init_mem;

	for(n=0;n<16;n=n+1)
	   begin
		m0.wr_mem[n] = n[15:0];
		m0.wb_rmw( `ATA_DEV + (n*4) , 4'hf, del, 1, 1);
		data = m0.rd_mem[n];

		data2[15:0] =  n[15:0] + 8;

		data1 = a0.mem[n+8];
		data3 = n[15:0];

		if(	(data[15:0]  != data2[15:0] ) |
			(data1[15:0] != data3[15:0]) )
		   begin
			$display("ERROR: Read 4a Mismatch: Expected: %h Got: %h (%0t)",
				data2[15:0], data[15:0], $time);
			$display("ERROR: Read 4b Mismatch: Expected: %h Got: %h (%0t)",
				data1[15:0], data3[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

   end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


task io_test2;

reg	[31:0]	data;
reg	[31:0]	data1;
reg	[31:0]	data2;
reg	[31:0]	data3;
integer		n;
integer		id;
integer		del;
integer		del_max;
integer		pio_mode;
integer		iordy_del;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** IO Test 2                                     ***");
$display("*** Testing PIO Modes, iordy assertion and        ***");
$display("*** iordy delays.                                 ***");
$display("*****************************************************\n");

id = 0;
del = 1;
verbose = 0;
iordy_del = 0;
pio_mode=4;

for(pio_mode=0;pio_mode<5;pio_mode=pio_mode+1)
for(id=0;id<2;id=id+1)
begin
	if(!verbose)
	$display("*** MODE SELECT: PIO mode: %0d iordy enable: %0d", pio_mode, id);

for(iordy_del=0;iordy_del < (id ? 600 : 1); iordy_del=iordy_del+1)
   begin

	if(verbose)
	$display("*** MODE SELECT: PIO mode: %0d, 'iordy' enable: %0d iordy del: %0d\n",
		pio_mode, id, iordy_del );

	a0.mode = pio_mode;
	a0.iordy_enable = id;
	a0.iordy_delay = iordy_del;	// Delay in nS
	a0.init_mem;

	data1 = 32'h0000_0001;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	data1 = 32'h1000_0000;
	m0.wb_rd1( `STAT, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: STAT Register read Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	case(pio_mode)
	   0: data1 = {8'h18, 8'h02, 8'h1c, 8'h04};	// Teoc, T4, T2, T1
	   1: data1 = {8'h05, 8'h01, 8'h1c, 8'h02};	// Teoc, T4, T2, T1
	   2: data1 = {8'h01, 8'h01, 8'h1c, 8'h00};	// Teoc, T4, T2, T1
	   3: data1 = {8'h07, 8'h00, 8'h07, 8'h00};	// Teoc, T4, T2, T1
	   4: data1 = {8'h02, 8'h00, 8'h06, 8'h00};	// Teoc, T4, T2, T1
	endcase
	m0.wb_wr1( `PCTR, 4'hf, data1);
	m0.wb_rd1( `PCTR, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: PCTR Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	if(id==1)	data1 = 32'h0000_0082;
	else		data1 = 32'h0000_0080;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

   	repeat(10)	@(posedge clk);

	// Read only Test of ATA registers
	if(verbose)	$display(">>> Running Read Only test 1 ... (%0t)", $time);
	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != (n+8) )
		   begin
			$display("ERROR: Read 1 Mismatch: Expected: %h Got: %h (%0t)",
				(n+8), data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 1 ... (%0t)", $time);

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_wr1( `ATA_DEV + (n*4) , 4'hf, ~n[15:0] );
		if(a0.mem[n+8] != ~n[15:0] )
		   begin
			$display("ERROR: Write 1 Mismatch: Expected: %h Got: %h (%0t)",
				~n[15:0], a0.mem[n+8], $time);
			error_cnt = error_cnt + 1;
		   end
	   end

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != ~n[15:0] )
		   begin
			$display("ERROR: Read 2 Mismatch: Expected: %h Got: %h (%0t)",
				~n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 2 ... (%0t)", $time);

	for(n=0;n<16;n=n+1)
	   begin
		m0.wb_wr1( `ATA_DEV + (n*4) , 4'hf, n[15:0] );
		m0.wb_rd1( `ATA_DEV + (n*4) , 4'hf, data );
		if(data[15:0] != n[15:0] )
		   begin
			$display("ERROR: Read 3 Mismatch: Expected: %h Got: %h (%0t)",
				n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");


	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 3 ... (%0t)", $time);

	for(n=0;n<16;n=n+4)
	   begin
		m0.wb_wr4( `ATA_DEV + (n*4) , 4'hf, del,
				{16'h0, ~n[13:0], 2'h3},
				{16'h0, ~n[13:0], 2'h2},
				{16'h0, ~n[13:0], 2'h1},
				{16'h0, ~n[13:0], 2'h0}		);

		m0.wb_rd4( `ATA_DEV + (n*4) , 4'hf, del, data, data1, data2, data3 );

		if(	(data[15:0]  != {~n[13:0], 2'h3}) |
			(data1[15:0] != {~n[13:0], 2'h2}) |
			(data2[15:0] != {~n[13:0], 2'h1}) |
			(data3[15:0] != {~n[13:0], 2'h0}) )
		   begin
			$display("ERROR: Read 3 Mismatch: Expected: %h Got: %h (%0t)",
				n[15:0], data[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");


	// Write Then Read Test of ATA registers
	if(verbose)	$display(">>> Running Read/Write test 4 (RMW) ... (%0t)", $time);

	a0.init_mem;

	for(n=0;n<16;n=n+1)
	   begin
		m0.wr_mem[n] = n[15:0];
		m0.wb_rmw( `ATA_DEV + (n*4) , 4'hf, del, 1, 1);
		data = m0.rd_mem[n];

		data2[15:0] =  n[15:0] + 8;

		data1 = a0.mem[n+8];
		data3 = n[15:0];

		if(	(data[15:0]  != data2[15:0] ) |
			(data1[15:0] != data3[15:0]) )
		   begin
			$display("ERROR: Read 4a Mismatch: Expected: %h Got: %h (%0t)",
				data2[15:0], data[15:0], $time);
			$display("ERROR: Read 4b Mismatch: Expected: %h Got: %h (%0t)",
				data1[15:0], data3[15:0], $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	if(verbose)	$display("");

   end
end


show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask



task rst_test;
reg	[31:0]	data;
reg	[31:0]	data1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** RST Test                                      ***");
$display("***                                               ***");
$display("*****************************************************\n");


	a0.iordy_enable = 0;
	a0.iordy_delay = 0;	// Delay in nS
	a0.init_mem;

	data1 = 32'h0000_0080;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	m0.wb_rd1( `STAT, 4'hf, data );
	m0.wb_rd1( `PCTR, 4'hf, data );

	if(ata_rst_ !== 1'b1)
	   begin
		$display("ERROR: ATA Reset not deasserted ... (%0t)", $time);
		error_cnt = error_cnt + 1;
	   end
   	repeat(500)	@(posedge clk);

	data1[0] = 1;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

   	repeat(100)
	   begin
		if(ata_rst_ !== 1'b0)
		   begin
			$display("ERROR: ATA Reset not asserted ... (%0t)", $time);
			error_cnt = error_cnt + 1;
		   end

		@(posedge clk);
	   end

	data1[0] = 0;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	if(ata_rst_ !== 1'b1)
	   begin
		$display("ERROR: ATA Reset not deasserted ... (%0t)", $time);
		error_cnt = error_cnt + 1;
	   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask



task int_test;
reg	[31:0]	data;
reg	[31:0]	data1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** INT Test                                      ***");
$display("***                                               ***");
$display("*****************************************************\n");

	a0.iordy_enable = 0;
	a0.iordy_delay = 0;
	a0.init_mem;

	data1 = 32'h0000_0080;
	m0.wb_wr1( `CTRL, 4'hf, data1);
	m0.wb_rd1( `CTRL, 4'hf, data );
	if(data != data1 )
	   begin
		$display("ERROR: CTRL Register write Mismatch: Expected: %h Got: %h (%0t)",
			data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	// No interrupts at this point
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0000;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (1), Expected: %0h Got: %0h (%0t)", $time, data1, data);
		error_cnt = error_cnt + 1;
	   end

   	repeat(20)	@(posedge clk);

	
	// No interrupts at this point
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0000;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (2), Expected: %0h Got: %0h (%0t)", $time, data1, data);
		error_cnt = error_cnt + 1;
	   end

	// Assert Interrup
	ata_intrq_r = 1;
   	repeat(10)	@(posedge clk);
	ata_intrq_r = 0;


	// Check to see if int bit is set
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0001;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (3), Expected: %0h Got: %0h (%0t)", data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

   	repeat(10)	@(posedge clk);

	// Make sure it is not cleared after another read
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0001;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (4), Expected: %0h Got: %0h (%0t)", data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	// Clear interrupt
	data1 = 32'h0000_0000;
	m0.wb_wr1( `STAT, 4'hf, data1 );


	// Should be cleared now ...
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0000;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (5), Expected: %0h Got: %0h (%0t)", data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

	// Check again ....
	m0.wb_rd1( `STAT, 4'hf, data );
	data1 = 32'h1000_0000;
	if(data !== data1)
	   begin
		$display("ERROR: ATA STATUS mismatch (6), Expected: %0h Got: %0h (%0t)", data1, data, $time);
		error_cnt = error_cnt + 1;
	   end

   	repeat(100)	@(posedge clk);

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


