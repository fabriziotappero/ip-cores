/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
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
//  $Id: tests.v,v 1.7 2002-01-21 13:10:37 rudi Exp $
//
//  $Date: 2002-01-21 13:10:37 $
//  $Revision: 1.7 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.6  2001/11/29 02:17:36  rudi
//
//
//               - More Synthesis cleanup, mostly for speed
//               - Several bug fixes
//               - Changed code to avoid auto-precharge and
//                 burst-terminate combinations (apparently illegal ?)
//                 Now we will do a manual precharge ...
//
//               Revision 1.5  2001/11/13 00:45:19  rudi
//
//               Just minor test bench update, syncing all the files.
//
//               Revision 1.4  2001/11/11 01:52:03  rudi
//
//               Minor fixes to testbench ...
//
//               Revision 1.3  2001/09/02 02:29:43  rudi
//
//               Fixed the TMS register setup to be tight and correct.
//
//               Revision 1.2  2001/08/10 08:16:21  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Removed "Refresh Early" configuration
//
//               Revision 1.1  2001/07/29 07:34:40  rudi
//
//
//               1) Changed Directory Structure
//               2) Fixed several minor bugs
//
//               Revision 1.1.1.1  2001/05/13 09:36:38  rudi
//               Created Directory Structure
//
//
//
//                        



task sdram_bo;

integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		write;
reg	[31:0]	mem_data;
reg	[1:0]	bas, kro;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Bank Overflow test 1                    ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

//force sdram0.Debug = 1;
del = 1;
bas = 0;
kro = 1;
for(kro=0;kro<2;kro=kro+1)
for(bas=0;bas<2;bas=bas+1)
begin

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821 | (bas<<9) | (kro<<10));

fill_mem(1024);

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd8,		// Trfc [27:24]
					4'd3,		// Trp [23:20]
					3'd3,		// Trcd [19:17]
					2'd2,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2,		// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0		// Burst Length
					});

$display("kro: %0d, bas: %0d", kro, bas);

m0.mem_fill;
for(n=250;n<260;n=n+1)
   begin

	m0.wb_rd_mult(`MEM_BASE +     (n*4), 4'hf, del, 1);

	if(!bas)
		case(n[9:8])
		   0: mem_data = sdram0.Bank0[n];
		   1: mem_data = sdram0.Bank1[n-256];
		   2: mem_data = sdram0.Bank2[n];
		   3: mem_data = sdram0.Bank3[n];
		endcase
	else	mem_data = sdram0.Bank0[n];

	if((mem_data !== m0.rd_mem[n-250]) |
		(|mem_data === 1'bx) |
		(|m0.rd_mem[n-250] === 1'bx)	 )
	   begin
		$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
		n, mem_data, m0.rd_mem[n-250],  $time);
		error_cnt = error_cnt + 1;
	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


task sdram_rd1;
input		quick;

integer		quick;
integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		write;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Read test 1 ...      ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821);

case(quick)
 0: sz_max = 64;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 6;
endcase

size = 4;
del = 0;
mode = 2;
write = 1;	// enable writes for parity !

//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd8,		// Trfc [27:24]
					4'd3,		// Trp [23:20]
					3'd3,		// Trcd [19:17]
					2'd2,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("Mode: %b", mode);
for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE +        0, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE +        0, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

	for(n=0;n<(size*4);n=n+1)
	   begin
		if((sdram0.Bank0[n] !== m0.rd_mem[n]) |
			(|sdram0.Bank0[n] === 1'bx) |
			(|m0.rd_mem[n] === 1'bx)	 )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, sdram0.Bank0[n], m0.rd_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



task sdram_wr1;
input		quick;

integer		quick;
integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Write test 1 ...     ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821);

case(quick)
 0: sz_max = 64;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 6;
endcase

size = 1;
del = 2;
mode = 16;
read = 1;
//force sdram0.Debug = 1;

for(mode=0;mode<20;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	if(mode[1])
	   sz_inc = 1;
	else
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d (%t)", mode,  size, del, $time);

	m0.wb_wr_mult(`MEM_BASE +        0, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE +        0, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	for(n=0;n< (size*4);n=n+1)
	   begin
		if((sdram0.Bank0[n] !== m0.wr_mem[n]) |
			(|sdram0.Bank0[n] === 1'bx) |
			(|m0.wr_mem[n] === 1'bx)	 )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, sdram0.Bank0[n], m0.wr_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


task sdram_rd2;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Read test 2 ...      ***");
$display("*** Different Row and Bank                        ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin
// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821 | (bas[0]<<9));

size = 33;
del = 0;
mode = 0;

//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);

	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2);n=n+1)
	   begin
		adr = (m * page_size) + (m*size*2) + n;

		if(bas[0])	data = sdram0.Bank0[adr];
		else
		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.rd_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.rd_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.rd_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end
   end

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


task sdram_wr2;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Write test 2 ...     ***");
$display("*** Different Row and Bank                        ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821 | (bas[0]<<9));

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 3;
del = 0;
mode = 10;
//force sdram0.Debug = 1;

for(mode=0;mode<20;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[4:2])
	   0: bs = 0;	// 1 Transfer
	   1: bs = 1;	// 2 Transfers
	   2: bs = 2;	// 4 Transfers
	   3: bs = 3;	// 8 Transfers
	   4: bs = 7;	// Page Size Transfer
	endcase

	if(mode[1])
	   begin
		sz_inc = 1;
	   end
	else
	   begin
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase
	   end

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {		// 22'h3fff_ff,

					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	for(m=0;m<4;m=m+1)
	for(n=0;n<size*2;n=n+1)
	   begin
		adr = (m * page_size) + (m*size*2) + n;

		if(bas[0])	data = sdram0.Bank0[adr];
		else
		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.wr_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.wr_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.wr_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end
end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



task sdram_rd3;
input		quick;

integer		quick;
integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		sbs, write;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Read test 3 ...      ***");
$display("*** Keep Row Open Active                          ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21);

case(quick)
 0: sz_max = 65;
 1: sz_max = 33;
 2: sz_max = 17;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 4;
del = 0;
mode = 8;
write = 1;
//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sbs = 1;
	   1: sbs = 2;
	   2: sbs = 4;
	   3: sbs = 8;
	   4: sbs = 1024;
	endcase

	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {	

					4'd0,		// RESERVED [31:28]
					4'd5,		// Trfc [27:24]
					4'd1,		// Trp [23:20]
					3'd1,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});


if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE +        0, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE +        0, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

	for(n=0;n<(size*4);n=n+1)
	   begin
		if((sdram0.Bank0[n] !== m0.rd_mem[n]) |
			(|sdram0.Bank0[n] === 1'bx) |
			(|m0.rd_mem[n] === 1'bx)	 )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, sdram0.Bank0[n], m0.rd_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



task sdram_wr3;
input		quick;

integer		quick;
integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		sbs, read;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Write test 3 ...     ***");
$display("*** Keep Row Open Active                          ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21);

case(quick)
 0: sz_max = 64;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 8;
del = 0;
mode = 16;
read = 1;
//force sdram0.Debug = 1;

for(mode=0;mode<20;mode=mode+1)
begin

	sdram0.mem_fill(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	case(mode[4:2])
	   0: sbs = 1;
	   1: sbs = 2;
	   2: sbs = 4;
	   3: sbs = 8;
	   4: sbs = 1024;
	endcase

	if(mode[1])
	   sz_inc = 1;
	else
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {	

					4'd0,		// RESERVED [31:28]
					4'd5,		// Trfc [27:24]
					4'd1,		// Trp [23:20]
					3'd1,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
//bw_clear;
	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	m0.wb_wr_mult(`MEM_BASE +        0, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE +        0, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

//bw_report;
	repeat(10)	@(posedge clk);

	for(n=0;n< (size*4);n=n+1)
	   begin
		if((sdram0.Bank0[n] !== m0.wr_mem[n]) |
			(|sdram0.Bank0[n] === 1'bx) |
			(|m0.wr_mem[n] === 1'bx)	 )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, sdram0.Bank0[n], m0.wr_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



task sdram_rd4;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;
integer		write;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Read test 4 ...      ***");
$display("*** KRO & Different Row and Bank                  ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin
fill_mem(1024);

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21 | (bas[0]<<9));

size = 2;
del = 3;
mode = 0;
write = 1;
//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin
	sdram0.mem_fill(1024);

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

//$display("Accessing Bank 0");
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);

//$display("Accessing Bank 1");
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);

//$display("Accessing Bank 2");
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);

//$display("Accessing Bank 3");
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);

	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2);n=n+1)                                                             
	   begin
		adr = (m * page_size) + (m*(size*2)) + n;

		if(bas[0])	data = sdram0.Bank0[adr];
		else
		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.rd_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.rd_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.rd_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end
   end
end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask




task sdram_wr4;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Write test 4 ...     ***");
$display("*** KRO & Different Row and Bank                  ***");
$display("*****************************************************\n");

//force sdram0.Debug = 1;

page_size = 256; // 64 mbit x 32 SDRAM

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21 | (bas[0]<<9));

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 8;
endcase

size = 1;
del = 3;
mode = 4;
read = 1;

for(mode=0;mode<20;mode=mode+1)
begin

	//sdram0.mem_fill(1024);
	fill_mem(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	if(mode[1])
	   sz_inc = 1;
	else
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);

	repeat(20)	@(posedge clk);

	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2);n=n+1)
	   begin
		adr = (m * page_size) + (m*size*2) + n;

		if(bas[0])	data = sdram0.Bank0[adr];
		else
		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.wr_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.wr_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.wr_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



`ifdef MULTI_SDRAM

task sdram_rd5;
input		quick;

integer		quick;
integer		s,n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;
integer		write;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Read test 5 ...      ***");
$display("*** KRO & Different Row and Bank and CS           ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 8;
endcase

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

m0.wb_wr1(`REG_BASE + `TMS1,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

m0.wb_wr1(`REG_BASE + `TMS2,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21 | (bas[0]<<9));
m0.wb_wr1(`REG_BASE + `CSC1,	4'hf, 32'h0020_0c21 | (bas[0]<<9));
m0.wb_wr1(`REG_BASE + `CSC2,	4'hf, 32'h0040_0c21 | (bas[0]<<9));

size = 2;
del = 3;
mode = 0;
write = 1;
if(0)
   begin
	force sdram0.Debug = 1;
	force sdram1.Debug = 1;
	force sdram2.Debug = 1;
   end

for(mode=0;mode<10;mode=mode+1)
for(mode=0;mode<10;mode=mode+1)
begin
	//sdram0.mem_fill(1024);
	//sdram1.mem_fill(1024);
	//sdram2.mem_fill(1024);

	fill_mem(1024);
	fill_mem1(1024);
	fill_mem2(1024);

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

	m0.wb_wr1(`REG_BASE + `TMS1,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

	m0.wb_wr1(`REG_BASE + `TMS2,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,		// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd3-mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});


if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*0*4) + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*0*4) + size*1*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*0*4) + size*1*4, 4'hf, del, size);

	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*1*4) + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*1*4) + size*3*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*1*4) + size*3*4, 4'hf, del, size);

	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*2*4) + size*5*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*2*4) + size*5*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*2*4) + size*5*4, 4'hf, del, size);

	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE1 + (page_size*3*4) + size*7*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE1 + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(write)
	m0.wb_wr_mult(`MEM_BASE2 + (page_size*3*4) + size*7*4, 4'hf, del, size);
	m0.wb_rd_mult(`MEM_BASE2 + (page_size*3*4) + size*7*4, 4'hf, del, size);

	for(m=0;m<4;m=m+1)
	for(s=0;s<3;s=s+1)
	for(n=0;n<(size*2);n=n+1)
	   begin
		adr = (m * page_size) + (m*(size*2)) + n;

		case(s)
		   0:	if(bas[0])	data = sdram0.Bank0[adr];
			else
			case(m)
			   0: data = sdram0.Bank0[n];
			   1: data = sdram0.Bank1[n+1*size*2];
			   2: data = sdram0.Bank2[n+2*size*2];
			   3: data = sdram0.Bank3[n+3*size*2];
			endcase
		   1:	if(bas[0])	data = sdram1.Bank0[adr];
			else
			case(m)
			   0: data = sdram1.Bank0[n];
			   1: data = sdram1.Bank1[n+1*size*2];
			   2: data = sdram1.Bank2[n+2*size*2];
			   3: data = sdram1.Bank3[n+3*size*2];
			endcase
		   2:	if(bas[0])	data = sdram2.Bank0[adr];
			else
			case(m)
			   0: data = sdram2.Bank0[n];
			   1: data = sdram2.Bank1[n+1*size*2];
			   2: data = sdram2.Bank2[n+2*size*2];
			   3: data = sdram2.Bank3[n+3*size*2];
			endcase
		endcase

		if((data !== m0.rd_mem[(m*size*6)+(s*size*2)+n]) | (|data === 1'bx) |
			(|m0.rd_mem[(m*size*6)+(s*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*6)+(s*size*2)+n, data, m0.rd_mem[(m*size*6)+(s*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
			if(error_cnt > 25)	$finish;
		   end

	   end
   end
end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask




task sdram_wr5;
input		quick;

integer		quick;
integer		s,n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data;
integer		page_size;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode Write test 5 ...     ***");
$display("*** KRO & Different Row and Bank and CS           ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0000);
m0.wb_wr1(`REG_BASE + `CSC1,	4'hf, 32'h0000_0000);
m0.wb_wr1(`REG_BASE + `CSC2,	4'hf, 32'h0000_0000);
repeat(10)	@(posedge clk);

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

m0.wb_wr1(`REG_BASE + `TMS1,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

m0.wb_wr1(`REG_BASE + `TMS2,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

bas = 0;
for(bas=0;bas<2;bas=bas+1)
begin

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0c21 | (bas[0]<<9));
m0.wb_wr1(`REG_BASE + `CSC1,	4'hf, 32'h0020_0c21 | (bas[0]<<9));
m0.wb_wr1(`REG_BASE + `CSC2,	4'hf, 32'h0040_0c21 | (bas[0]<<9));

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 8;
endcase

size = 5;
del = 0;
mode = 0;
read = 1;

if(0)
   begin
	force sdram0.Debug = 1;
	force sdram1.Debug = 1;
	force sdram2.Debug = 1;
   end

for(mode=0;mode<20;mode=mode+1)
begin

	//sdram0.mem_fill(1024);
	//sdram1.mem_fill(1024);
	//sdram2.mem_fill(1024);

	fill_mem(1024);
	fill_mem1(1024);
	fill_mem2(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	if(mode[1])
	   sz_inc = 1;
	else
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});


	m0.wb_wr1(`REG_BASE + `TMS1,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd3-mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});


	m0.wb_wr1(`REG_BASE + `TMS2,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("BAS: %0d, Mode: %b", bas, mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	if(verbose)	$display("BAS: %0d, Mode: %b, Size: %0d, Delay: %0d",
				bas, mode,  size, del);

			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*0*4) + size*0*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*0*4) + size*1*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*0*4) + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*0*4) + size*0*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*0*4) + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*0*4) + size*1*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*1*4) + size*2*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*1*4) + size*3*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*1*4) + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*1*4) + size*2*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*1*4) + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*1*4) + size*3*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*2*4) + size*4*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*2*4) + size*5*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*2*4) + size*4*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*2*4) + size*4*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*2*4) + size*5*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*2*4) + size*5*4, 4'hf, del, size);

			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*3*4) + size*6*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE1 + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE1 + (page_size*3*4) + size*7*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*3*4) + size*6*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*3*4) + size*6*4, 4'hf, del, size);
			m0.wb_wr_mult(`MEM_BASE2 + (page_size*3*4) + size*7*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE2 + (page_size*3*4) + size*7*4, 4'hf, del, size);



	repeat(20)	@(posedge clk);

	for(m=0;m<4;m=m+1)
	for(s=0;s<3;s=s+1)
	for(n=0;n<(size*2);n=n+1)
	   begin
		adr = (m * page_size) + (m*size*2) + n;

		case(s)
		   0:	if(bas[0])	data = sdram0.Bank0[adr];
			else
			case(m)
			   0: data = sdram0.Bank0[n];
			   1: data = sdram0.Bank1[n+1*size*2];
			   2: data = sdram0.Bank2[n+2*size*2];
			   3: data = sdram0.Bank3[n+3*size*2];
			endcase
		   1:	if(bas[0])	data = sdram1.Bank0[adr];
			else
			case(m)
			   0: data = sdram1.Bank0[n];
			   1: data = sdram1.Bank1[n+1*size*2];
			   2: data = sdram1.Bank2[n+2*size*2];
			   3: data = sdram1.Bank3[n+3*size*2];
			endcase
		   2:	if(bas[0])	data = sdram2.Bank0[adr];
			else
			case(m)
			   0: data = sdram2.Bank0[n];
			   1: data = sdram2.Bank1[n+1*size*2];
			   2: data = sdram2.Bank2[n+2*size*2];
			   3: data = sdram2.Bank3[n+3*size*2];
			endcase
		endcase

		if((data !== m0.wr_mem[(m*size*6)+(s*size*2)+n]) | (|data === 1'bx) |
			(|m0.wr_mem[(m*size*6)+(s*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: WR Data[%0d-%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			s, (m*size*2)+n, data, m0.wr_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask

`endif


task	rmw_cross1;
input		quick;

integer		quick;
integer		x,s,n,m,adr;
integer		del, size;
reg	[7:0]	mode, a_mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data, exp;
integer		page_size;
integer		cycle;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** RMW CS Cross Test 1 ...                       ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS3,	4'hf, 32'hffff_f40c);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821);

case(quick)
 0: sz_max = 32;
 1: sz_max = 16;
 2: sz_max = 8;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 16;
del = 0;
mode = 4;
a_mode = 0;
read = 1;
write = 1;
cycle = 1;

for(cycle=0;cycle<7;cycle = cycle + 1)
for(mode=0;mode<19;mode=mode+1)
for(a_mode=0;a_mode<3;a_mode=a_mode+1)
begin

repeat(1)	@(posedge clk);

	sdram0.mem_fill(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[4:2])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase


	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

case(a_mode)
   0:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0025);	// 32 bit bus
   1:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0005);	// 8 bit bus
   2:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0015);	// 16 bit bus
endcase

repeat(10)	@(posedge clk);
if(!verbose)	$display("Mode: %b, Bus Width: %0d, Cycle Delay: %0d", mode, a_mode, cycle);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	for(n=0;n<1024;n=n+1)
		m0.wr_mem[n] = {n[15:0],n[15:0]};

	if(verbose)	$display("Mode: %0d, A_mode: %0d, Size: %0d, Delay: %0d, Cyc. Delay: %0d", mode, a_mode,  size, del, cycle);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*0*4,
		`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*1*4,
		`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*2*4,
		`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*3*4,
		`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*4*4,
		`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*5*4,
		`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*6*4,
		`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw2(`MEM_BASE3 + size*7*4,
		`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size, size);

	repeat(10)	@(posedge clk);

	x = 0;
	for(n=0;n<(size*8);n=n+1)
	   begin

		case(a_mode)
		   0:	data = {16'hxxxx, n[15:0]};
		   1:
			begin
				data[31:24] = x[7:0]+3;
				data[23:16] = x[7:0]+2;
				data[15:08] = x[7:0]+1;
				data[07:00] = x[7:0]+0;
			end
		   2:	begin
				data[31:16] = x[15:0]+1;
				data[15:00] = x[15:0]+0;
			end
		endcase

		case(a_mode)
		   0:	x = x + 1;
		   1:	x = x + 4;
		   2:	x = x + 2;
		endcase

		exp = m0.rd_mem[n];
		if(a_mode==0)	exp[31:16] = data[31:16];

		if(data !== exp)
		   begin
			$display("ERROR: RD[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, data, exp,  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

	for(m=0;m<4;m=m+1)
	for(n=0;n<size*2;n=n+1)
	   begin

		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.wr_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.wr_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.wr_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


task	asc_rdwr1;
input		quick;

integer		quick;
integer		x,s,n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data, exp;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** ASC Read/Write Test 1 ...                     ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS3,	4'hf, 32'hffff_f40b);

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 16;
del = 0;
mode = 0;
read = 1;
write = 1;

sz_max = 6;
for(mode=0;mode<3;mode=mode+1)
begin

repeat(1)	@(posedge clk);

case(mode)
   0:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0025);	// 32 bit bus
   1:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0005);	// 8 bit bus
   2:	m0.wb_wr1(`REG_BASE + `CSC3,	4'hf, 32'h0060_0015);	// 16 bit bus
endcase

repeat(10)	@(posedge clk);
if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=1;size<sz_max;size=size+1)
   begin
	m0.mem_fill;
	for(n=0;n<1024;n=n+1)
		m0.wr_mem[n] = 32'hffff_ffff;
		
	if(verbose)	$display("Mode: %0d, Size: %0d, Delay: %0d", mode,  size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE3 + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE3 + size*0*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE3 + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE3 + size*1*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE3 + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE3 + size*2*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE3 + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE3 + size*3*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	x = 0;
	for(n=0;n<(size*4);n=n+1)
	   begin

		case(mode)
		   0:	data = {16'hxxxx, n[15:0]};
		   1:
			begin
				data[31:24] = x[7:0]+3;
				data[23:16] = x[7:0]+2;
				data[15:08] = x[7:0]+1;
				data[07:00] = x[7:0]+0;
			end
		   2:	begin
				data[31:16] = x[15:0]+1;
				data[15:00] = x[15:0]+0;
			end
		endcase

		case(mode)
		   0:	x = x + 1;
		   1:	x = x + 4;
		   2:	x = x + 2;
		endcase

		exp = m0.rd_mem[n];
		if(mode==0)	exp[31:16] = data[31:16];

		if(data !== exp)
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, data, exp,  $time);
			error_cnt = error_cnt + 1;
		   end
	   end

   end

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask

task	boot;
input		quick;

integer		quick;
integer		x,s,n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data, exp;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** ASC Boot Test 1 ...                           ***");
$display("*****************************************************\n");

case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 1;
del = 0;
mode = 0;
read = 1;
write = 1;

for(mode=0;mode<3;mode=mode+1)
begin

repeat(1)	@(posedge clk);

case(mode)
   0: begin
	poc_mode = 2;
	mc_reset;
      end
   1: begin
	poc_mode = 0;
	mc_reset;
      end
   2: begin
	poc_mode = 1;
	mc_reset;
      end
endcase

repeat(5)	@(posedge clk);
if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=1;size<sz_max;size=size+1)
   begin
	m0.mem_fill;
	for(n=0;n<1024;n=n+1)
		m0.wr_mem[n] = 32'hffff_ffff;
		
	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*0*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	x = 0;
	for(n=0;n<(size*4);n=n+1)
	   begin

		case(mode)
		   0:	data = {16'hxxxx, n[15:0]};
		   1:
			begin
				data[31:24] = x[7:0]+3;
				data[23:16] = x[7:0]+2;
				data[15:08] = x[7:0]+1;
				data[07:00] = x[7:0]+0;
			end

		   2:	begin
				data[31:16] = x[15:0]+1;
				data[15:00] = x[15:0]+0;
			end
		endcase

		case(mode)
		   0:	x = x + 1;
		   1:	x = x + 4;
		   2:	x = x + 2;
		endcase

		exp = m0.rd_mem[n];
		if(mode==0)	exp[31:16] = data[31:16];

		if(data !== exp)
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, data, exp,  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end
end
show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


`ifdef SRAM
task sram_rd1;

integer		n,m,read,write;
integer		d2, del, size;
reg	[31:0]	data;
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SRAM Size & Delay Read Test 1 ...             ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS4,	4'hf, 32'hffff_ffff);

// Parity Enabled !
	m0.wb_wr1(`REG_BASE + `CSC4,	4'hf, 32'h0080_0803);

size = 5;
del = 0;
read = 1;
write = 1;

sram0a.mem_fill( 1024 );
sram0b.mem_fill( 1024 );

repeat(1)	@(posedge clk);

for(del=0;del<16;del=del+1)
for(size=1;size<18;size=size+1)
   begin
	m0.mem_fill;

	$display("Size: %0d, Delay: %0d", size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE4 + size * 0 * 16, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + size * 0 * 16, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + size * 1 * 16, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + size * 1 * 16, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + size * 2 * 16, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + size * 2 * 16, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + size * 3 * 16, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + size * 3 * 16, 4'hf, del, size);

	for(m=0;m< 4;m=m+1)
	for(n=0;n< size;n=n+1)
	   begin

`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*size*4)+n];
		data[15:08] = sram0a.bank1[(m*size*4)+n];
		data[23:16] = sram0b.bank0[(m*size*4)+n];
		data[31:24] = sram0b.bank1[(m*size*4)+n];

`else
		data[07:00] = sram0a.memb1[(m*4)+n];
		data[15:08] = sram0a.memb2[(m*4)+n];
		data[23:16] = sram0b.memb1[(m*4)+n];
		data[31:24] = sram0b.memb2[(m*4)+n];
`endif


		if(data !== m0.rd_mem[(m*size)+n])
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*4)+n, data, m0.rd_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask

task sram_wr1;

integer		n,m,read,write;
integer		del, size;
reg	[31:0]	data;
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SRAM Size & Delay Write Test 1 ...            ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS4,	4'hf, 32'hffff_ffff);
// Parity Enabled !
	m0.wb_wr1(`REG_BASE + `CSC4,	4'hf, 32'h0080_0803);

size = 4;
del = 4;
mode = 0;
read = 1;
write = 1;

sram0a.mem_fill( 256 );
sram0b.mem_fill( 256 );

repeat(1)	@(posedge clk);

for(del=0;del<16;del=del+1)
for(size=1;size<18;size=size+1)
   begin
	m0.mem_fill;

	$display("Size: %0d, Delay: %0d", size, del);
//bw_clear;

	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 0*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 32*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 32*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 64*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 64*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 96*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 96*4, 4'hf, del, size);

//bw_report;

repeat(10)	@(posedge clk);

for(m=0;m< 4;m=m+1)
   for(n=0;n< size;n=n+1)
	   begin

`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*32)+n];
		data[15:08] = sram0a.bank1[(m*32)+n];
		data[23:16] = sram0b.bank0[(m*32)+n];
		data[31:24] = sram0b.bank1[(m*32)+n];
`else
		data[07:00] = sram0a.memb1[(m*32)+n];
		data[15:08] = sram0a.memb2[(m*32)+n];
		data[23:16] = sram0b.memb1[(m*32)+n];
		data[31:24] = sram0b.memb2[(m*32)+n];
`endif

		if(data !== m0.wr_mem[(m*size)+n])
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*32)+n, data, m0.wr_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end


   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask
`endif


task	scs_rdwr1;
input		quick;

integer		quick;
integer		x,s,n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;
reg	[2:0]	bas;
reg	[31:0]	data;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SCS Read/Write Test 1 ...                     ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS5,	4'hf, 32'hf03f_4105);
   	m0.wb_wr1(`REG_BASE + `CSC5,	4'hf, 32'h00a0_0027);


case(quick)
 0: sz_max = 32;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 1;
del = 0;
mode = 1;
read = 1;
write = 0;

s0.mem_fill;

repeat(5)	@(posedge clk);

for(del=0;del<del_max;del=del+1)
for(size=1;size<sz_max;size=size+1)
   begin
	m0.mem_fill;
		
	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	if(write)	m0.wb_wr_mult(`MEM_BASE5 + size*0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE5 + size*0*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE5 + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE5 + size*1*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE5 + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE5 + size*2*4, 4'hf, del, size);

	if(write)	m0.wb_wr_mult(`MEM_BASE5 + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE5 + size*3*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	x = 0;
	for(n=0;n<(size*4);n=n+1)
	   begin

		data = s0.mem[n];

		if(data !== m0.rd_mem[n])
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, data, m0.rd_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end

   end


show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


task sdram_wp;
input		quick;

integer		quick;
integer		n;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
integer		read;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Write Protect Test 1 ...                ***");
$display("*****************************************************\n");

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6020_0200);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

// Parity Enabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0921);

wb_err_check_dis=1;
case(quick)
 0: sz_max = 64;
 1: sz_max = 32;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 4;
endcase

size = 4;
del = 1;
mode = 0;
read = 1;
//force sdram0.Debug = 1;

for(mode=0;mode<20;mode=mode+1)
begin
	fill_mem(1024);

	case(mode[4:2])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase

	if(mode[1])
	   sz_inc = 1;
	else
		case(mode[4:2])
		   0: sz_inc = 1;
		   1: sz_inc = 2;
		   2: sz_inc = 4;
		   3: sz_inc = 8;
		   4: sz_inc = 1;
		endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[1],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2+mode[0],	// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

if(!verbose)	$display("Mode: %b", mode);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;

	if(verbose)	$display("Mode: %b, Size: %0d, Delay: %0d", mode,  size, del);

	m0.wb_wr_mult(`MEM_BASE +        0, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE +        0, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*1*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*1*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*2*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*2*4, 4'hf, del, size);

	m0.wb_wr_mult(`MEM_BASE + size*3*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE + size*3*4, 4'hf, del, size);

	repeat(10)	@(posedge clk);

	for(n=0;n< (size*4);n=n+1)
	   begin
		if((sdram0.Bank0[n] == m0.wr_mem[n]) |
			(|sdram0.Bank0[n] === 1'bx) |
			(|m0.wr_mem[n] === 1'bx)	 )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, sdram0.Bank0[n], m0.wr_mem[n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end

wb_err_check_dis=0;
show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


`ifdef SRAM
task sram_wp;

integer		n,m,read,write;
integer		del, size;
reg	[31:0]	data;
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SRAM Write Protect Test 1 ...                 ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS4,	4'hf, 32'hffff_ffff);
// Parity Enabled !
	m0.wb_wr1(`REG_BASE + `CSC4,	4'hf, 32'h0080_0903);

size = 17;
del = 15;
mode = 0;
read = 1;
write = 1;

sram0a.mem_fill( 256 );
sram0b.mem_fill( 256 );

wb_err_check_dis=1;
repeat(1)	@(posedge clk);

for(del=0;del<16;del=del+1)
for(size=1;size<18;size=size+1)
   begin
	m0.mem_fill;

	$display("Size: %0d, Delay: %0d", size, del);
//bw_clear;

	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 0*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 0*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 32*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 32*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 64*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 64*4, 4'hf, del, size);
	if(write)	m0.wb_wr_mult(`MEM_BASE4 + 96*4, 4'hf, del, size);
	if(read)	m0.wb_rd_mult(`MEM_BASE4 + 96*4, 4'hf, del, size);

//bw_report;

repeat(10)	@(posedge clk);

for(m=0;m< 4;m=m+1)
   for(n=0;n< size;n=n+1)
	   begin

`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*32)+n];
		data[15:08] = sram0a.bank1[(m*32)+n];
		data[23:16] = sram0b.bank0[(m*32)+n];
		data[31:24] = sram0b.bank1[(m*32)+n];
`else
		data[07:00] = sram0a.memb1[(m*32)+n];
		data[15:08] = sram0a.memb2[(m*32)+n];
		data[23:16] = sram0b.memb1[(m*32)+n];
		data[31:24] = sram0b.memb2[(m*32)+n];
`endif

		if(data == m0.wr_mem[(m*size)+n])
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*32)+n, data, m0.wr_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end


   end

wb_err_check_dis=0;
show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask
`endif


task sdram_rmw1;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
reg	[2:0]	kro;
reg	[31:0]	data;
integer		page_size;
reg	[31:0]	mem0[0:1024];
reg	[31:0]	mem1[0:1024];
reg	[31:0]	mem2[0:1024];
reg	[31:0]	mem3[0:1024];
integer		cycle;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode RMW test 1 ...       ***");
$display("*** Different Row and Bank                        ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

case(quick)
 0: sz_max = 32;
 1: sz_max = 16;
 2: sz_max = 16;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 8;
endcase

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

kro = 1;
cycle=3;
for(cycle=0;cycle<8;cycle=cycle+1)
for(kro=0;kro<2;kro=kro+1)	// Don't Need this for this test
begin

// Parity nabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821 | (kro[0]<<10));

size = 2;
del = 5;
mode = 2;

//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]
					1'd0+mode[0],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2,		// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

repeat(50)	@(posedge clk);

if(!verbose)	$display("KRO: %0d, Mode: %b, Cyc. Delay: %0d", kro, mode, cycle);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	fill_mem(1024);
	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2)+1;n=n+1)
		case(m)
		   0: mem0[n] = sdram0.Bank0[n];
		   1: mem1[n] = sdram0.Bank1[n+1*size*2];
		   2: mem2[n] = sdram0.Bank2[n+2*size*2];
		   3: mem3[n] = sdram0.Bank3[n+3*size*2];
		endcase

	if(verbose)	$display("KRO: %0d, Mode: %b, Size: %0d, Delay: %0d, Cyc. Delay: %0d (%t)",
				kro, mode,  size, del, cycle, $time);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_rmw(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);

	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2);n=n+1)
	   begin
		case(m)
		   0: data = mem0[n];
		   1: data = mem1[n];
		   2: data = mem2[n];
		   3: data = mem3[n];
		endcase

		if((data !== m0.rd_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.rd_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: RD Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.rd_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end

	repeat(10)	@(posedge clk);

	for(m=0;m<4;m=m+1)
	for(n=0;n<size*2;n=n+1)
	   begin

		case(m)
		   0: data = sdram0.Bank0[n];
		   1: data = sdram0.Bank1[n+1*size*2];
		   2: data = sdram0.Bank2[n+2*size*2];
		   3: data = sdram0.Bank3[n+3*size*2];
		endcase

		if((data !== m0.wr_mem[(m*size*2)+n]) | (|data === 1'bx) |
			(|m0.wr_mem[(m*size*2)+n] === 1'bx) )
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.wr_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask




task sdram_rmw2;
input		quick;

integer		quick;
integer		n,m,adr;
integer		del, size;
reg	[7:0]	mode;
reg	[2:0]	bs;
integer		sz_inc;
integer		sz_max, del_max;
reg	[2:0]	kro;
reg	[31:0]	data, data1;
integer		page_size;
integer		cycle;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** SDRAM Size, Delay & Mode RMW test 2 ...       ***");
$display("*** Different Row and Bank                        ***");
$display("*****************************************************\n");

page_size = 256; // 64 mbit x 32 SDRAM

case(quick)
 0: sz_max = 32;
 1: sz_max = 16;
 2: sz_max = 10;
endcase

case(quick)
 0: del_max = 16;
 1: del_max = 8;
 2: del_max = 8;
endcase

m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {
					4'd0,	// RESERVED [31:28]
					4'd7,	// Trfc [27:24]
					4'd2,	// Trp [23:20]
					3'd2,	// Trcd [19:17]
					2'd1,	// Twr [16:15]
					5'd0,	// RESERVED [14:10]
					1'd0,	// Wr. Burst Len (1=Single)
					2'd0,	// Op Mode
					3'd2,	// CL
					1'b0,	// Burst Type (0=Seq;1=Inter)
					3'd3	// Burst Length
					});

kro = 1;
for(cycle=0;cycle<8;cycle=cycle+1)
for(kro=0;kro<2;kro=kro+1)	// Don't Need this for this test
begin

// Parity nabled !
m0.wb_wr1(`REG_BASE + `CSC0,	4'hf, 32'h0000_0821 | (kro[0]<<10));

size = 1;
del = 0;
mode = 0;

//force sdram0.Debug = 1;

for(mode=0;mode<10;mode=mode+1)
begin

	case(mode[3:1])
	   0: bs = 0;
	   1: bs = 1;
	   2: bs = 2;
	   3: bs = 3;
	   4: bs = 7;
	endcase
	
	case(mode[3:1])
	   0: sz_inc = 1;
	   1: sz_inc = 2;
	   2: sz_inc = 4;
	   3: sz_inc = 8;
	   4: sz_inc = 1;
	endcase

	m0.wb_wr1(`REG_BASE + `TMS0,	4'hf, {

					4'd0,		// RESERVED [31:28]
					4'd7,		// Trfc [27:24]
					4'd2,		// Trp [23:20]
					3'd2,		// Trcd [19:17]
					2'd1,		// Twr [16:15]
					5'd0,		// RESERVED [14:10]

					1'd0+mode[0],	// Wr. Burst Len (1=Single)
					2'd0,		// Op Mode
					3'd2,		// CL
					1'b0,		// Burst Type (0=Seq;1=Inter)
					3'd0+bs		// Burst Length
					});

repeat(50)	@(posedge clk);

if(!verbose)	$display("KRO: %0d, Mode: %b, Cyc.Del: %0d", kro, mode, cycle);

for(del=0;del<del_max;del=del+1)
for(size=sz_inc;size<sz_max;size=size+sz_inc)
   begin
	m0.mem_fill;
	fill_mem(1024);

	if(verbose)	$display("KRO: %0d, Mode: %b, Size: %0d, Delay: %0d, Cyc.Del: %0d (%t)",
				kro, mode,  size, del, cycle, $time);

	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*0*4) + size*0*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*0*4) + size*1*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*1*4) + size*2*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*1*4) + size*3*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*2*4) + size*4*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*2*4) + size*5*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*3*4) + size*6*4, 4'hf, del, size, size);
	repeat(cycle)	@(posedge clk);
	m0.wb_wmr(`MEM_BASE + (page_size*3*4) + size*7*4, 4'hf, del, size, size);

	repeat(cycle)	@(posedge clk);
	for(n=0;n<(size*2);n=n+1)
	   begin

		data = m0.wr_mem[n];
		data1 = m0.rd_mem[n];

		if((data !== data1) | (|data === 1'bx) |
			(|data1 === 1'bx) )
		   begin
			$display("ERROR: WMR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*size*2)+n, data, m0.rd_mem[(m*size*2)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


`ifdef SRAM
task sram_rmw1;

integer		n,m,read,write;
integer		del, size;
reg	[31:0]	data;
reg	[31:0]	mem[0:1024];
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SRAM Size & Delay RMW Test 1 ...              ***");
$display("*** Time: %t", $time);
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS4,	4'hf, 32'hffff_ffff);
// Parity Enabled !
	m0.wb_wr1(`REG_BASE + `CSC4,	4'hf, 32'h0080_0003);

size = 1;
del = 0;

repeat(1)	@(posedge clk);

for(del=0;del<16;del=del+1)
for(size=1;size<18;size=size+1)
   begin
	m0.mem_fill;
	sram0a.mem_fill( 256 );
	sram0b.mem_fill( 256 );
	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2)+1;n=n+1)
	   begin
`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*32)+n];
		data[15:08] = sram0a.bank1[(m*32)+n];
		data[23:16] = sram0b.bank0[(m*32)+n];
		data[31:24] = sram0b.bank1[(m*32)+n];
`else
		data[07:00] = sram0a.memb1[(m*32)+n];
		data[15:08] = sram0a.memb2[(m*32)+n];
		data[23:16] = sram0b.memb1[(m*32)+n];
		data[31:24] = sram0b.memb2[(m*32)+n];
`endif
		mem[(m*32)+n] = data;
	   end


	$display("Size: %0d, Delay: %0d", size, del);
//bw_clear;

	m0.wb_rmw(`MEM_BASE4 + 00*4, 4'hf, del, size, size);
	m0.wb_rmw(`MEM_BASE4 + 32*4, 4'hf, del, size, size);
	m0.wb_rmw(`MEM_BASE4 + 64*4, 4'hf, del, size, size);
	m0.wb_rmw(`MEM_BASE4 + 96*4, 4'hf, del, size, size);

//bw_report;

repeat(10)	@(posedge clk);

for(m=0;m< 4;m=m+1)
   for(n=0;n< size;n=n+1)
	   begin

		data = mem[(m*32)+n];

		if(data !== m0.rd_mem[(m*size)+n])
		   begin
			$display("ERROR: RD Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*32)+n, data, m0.rd_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
			if(error_cnt > 10)	$finish;
		   end

`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*32)+n];
		data[15:08] = sram0a.bank1[(m*32)+n];
		data[23:16] = sram0b.bank0[(m*32)+n];
		data[31:24] = sram0b.bank1[(m*32)+n];
`else
		data[07:00] = sram0a.memb1[(m*32)+n];
		data[15:08] = sram0a.memb2[(m*32)+n];
		data[23:16] = sram0b.memb1[(m*32)+n];
		data[31:24] = sram0b.memb2[(m*32)+n];
`endif

		if(data !== m0.wr_mem[(m*size)+n])
		   begin
			$display("ERROR: WR Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*32)+n, data, m0.wr_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
			if(error_cnt > 10)	$finish;
		   end

	   end

   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask



task sram_rmw2;

integer		n,m,read,write;
integer		del, size;
reg	[31:0]	data;
reg	[31:0]	mem[0:1024];
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SRAM Size & Delay RMW Test 2 ...              ***");
$display("*****************************************************\n");

	m0.wb_wr1(`REG_BASE + `CSR,	4'hf, 32'h6030_0300);
	m0.wb_wr1(`REG_BASE + `BA_MASK, 4'hf, 32'h0000_00f0);

	m0.wb_wr1(`REG_BASE + `TMS4,	4'hf, 32'hffff_ffff);
// Parity Enabled !
	m0.wb_wr1(`REG_BASE + `CSC4,	4'hf, 32'h0080_0803);

size = 4;
del = 4;

repeat(1)	@(posedge clk);

for(del=0;del<16;del=del+1)
for(size=1;size<18;size=size+1)
   begin
	m0.mem_fill;
	sram0a.mem_fill( 256 );
	sram0b.mem_fill( 256 );
	for(m=0;m<4;m=m+1)
	for(n=0;n<(size*2)+1;n=n+1)
	   begin
`ifdef MICRON
		data[07:00] = sram0a.bank0[(m*32)+n];
		data[15:08] = sram0a.bank1[(m*32)+n];
		data[23:16] = sram0b.bank0[(m*32)+n];
		data[31:24] = sram0b.bank1[(m*32)+n];
`else
		data[07:00] = sram0a.memb1[(m*32)+n];
		data[15:08] = sram0a.memb2[(m*32)+n];
		data[23:16] = sram0b.memb1[(m*32)+n];
		data[31:24] = sram0b.memb2[(m*32)+n];
`endif
		mem[(m*32)+n] = data;
	   end


	$display("Size: %0d, Delay: %0d", size, del);
//bw_clear;

	m0.wb_wmr(`MEM_BASE4 + 00*4, 4'hf, del, size, size);
	m0.wb_wmr(`MEM_BASE4 + 32*4, 4'hf, del, size, size);
	m0.wb_wmr(`MEM_BASE4 + 64*4, 4'hf, del, size, size);
	m0.wb_wmr(`MEM_BASE4 + 96*4, 4'hf, del, size, size);

//bw_report;

repeat(10)	@(posedge clk);


for(m=0;m< 4;m=m+1)
   for(n=0;n< size;n=n+1)
	   begin

		data = m0.wr_mem[(m*size)+n];

		if(data !== m0.rd_mem[(m*size)+n])
		   begin
			$display("ERROR: RD Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			(m*32)+n, data, m0.rd_mem[(m*size)+n],  $time);
			error_cnt = error_cnt + 1;
		   end

	   end

   end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask

`endif

