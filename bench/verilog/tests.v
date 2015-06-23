/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE Connection Matrix Test Cases                      ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/wb_dma/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
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
//  $Id: tests.v,v 1.1.1.1 2001-10-19 11:04:27 rudi Exp $
//
//  $Date: 2001-10-19 11:04:27 $
//  $Revision: 1.1.1.1 $
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
//                        


task show_errors;

begin

$display("\n");
$display("     +--------------------+");
$display("     |  Total ERRORS: %0d   |", error_cnt);
$display("     +--------------------+");

end
endtask


task init_all_mem;

begin
	s0.fill_mem(1);
	s1.fill_mem(1);
	s2.fill_mem(1);
	s3.fill_mem(1);
	s4.fill_mem(1);
	s5.fill_mem(1);
	s6.fill_mem(1);
	s7.fill_mem(1);
	s8.fill_mem(1);
	s9.fill_mem(1);
	s10.fill_mem(1);
	s11.fill_mem(1);
	s12.fill_mem(1);
	s13.fill_mem(1);
	s14.fill_mem(1);
	s15.fill_mem(1);

	m0.mem_fill;
	m1.mem_fill;
	m2.mem_fill;
	m3.mem_fill;
	m4.mem_fill;
	m5.mem_fill;
	m6.mem_fill;
	m7.mem_fill;

end
endtask


task verify;
input	master;
input	slave;
input	count;

integer		master, slave, count;
begin
verify_sub(master,slave,count,0,0);
end
endtask


task verify_sub;
input	master;
input	slave;
input	count;
input	mo;
input	so;

integer		master, slave, count;
integer		mo, so;
integer		o;
integer		n;
reg	[31:0]	mdata, sdata;

begin

//$display("V2: %0d %0d %0d %0d %0d",master, slave, count, mo,so);

for(n=0;n<count;n=n+1)
   begin
	case(master)
	   0: mdata = m0.mem[n+mo];
	   1: mdata = m1.mem[n+mo];
	   2: mdata = m2.mem[n+mo];
	   3: mdata = m3.mem[n+mo];
	   4: mdata = m4.mem[n+mo];
	   5: mdata = m5.mem[n+mo];
	   6: mdata = m6.mem[n+mo];
	   7: mdata = m7.mem[n+mo];
	   default:
		begin
		$display("ERROR: Illegal Master %0d", master);
		$finish;
		end
	endcase

	o = 0;
	case(master)
	   0: o = 16'h000;
	   1: o = 16'h040;
	   2: o = 16'h080;
	   3: o = 16'h0c0;
	   4: o = 16'h100;
	   5: o = 16'h140;
	   6: o = 16'h180;
	   7: o = 16'h1c0;
	endcase

	case(slave)
	   0: sdata = s0.mem[n+o+so];
	   1: sdata = s1.mem[n+o+so];
	   2: sdata = s2.mem[n+o+so];
	   3: sdata = s3.mem[n+o+so];
	   4: sdata = s4.mem[n+o+so];
	   5: sdata = s5.mem[n+o+so];
	   6: sdata = s6.mem[n+o+so];
	   7: sdata = s7.mem[n+o+so];
	   8: sdata = s8.mem[n+o+so];
	   9: sdata = s9.mem[n+o+so];
	   10: sdata = s10.mem[n+o+so];
	   11: sdata = s11.mem[n+o+so];
	   12: sdata = s12.mem[n+o+so];
	   13: sdata = s13.mem[n+o+so];
	   14: sdata = s14.mem[n+o+so];
	   15: sdata = s15.mem[n+o+so];
	   default:
		begin
		$display("ERROR: Illegal Slave %0d", slave);
		$finish;
		end
	endcase

	//$display("INFO: Master[%0d]: %h - Slave[%0d]: %h (%0t)",
	//	master, mdata, slave, sdata, $time);

	if(mdata !== sdata)
	   begin
		$display("ERROR: Master[%0d][%0d]: %h - Slave[%0d]: %h (%0t)",
		master, n, mdata, slave, sdata, $time);
		error_cnt = error_cnt + 1;
	   end
   end
end

endtask


task test_arb1;

integer	n, del;
reg	[31:0]	data;

begin

	$display("\n\n");
	$display("*****************************************************");
	$display("*** Arb. 1 Test ...                               ***");
	$display("*****************************************************\n");

del = 4;
for(del = 0;del < 5; del=del+1 )
   begin
	$display("Delay: %0d", del);
	init_all_mem;
	m1.wb_wr1( 32'hff00_0000, 4'hf, 32'h0000_a5ff);

	fork
	   begin
		m0.wb_rd_mult( 32'h0000_0000 + (0 << 28), 4'hf, del, 4);
		m0.wb_rd1( 32'hff00_0000, 4'hf, data);
		if(data !== 32'h0000_a5ff)
		   begin
			$display("ERROR: RF read mismatch: Exp. 0, Got %h", data);
			error_cnt = error_cnt + 1;
		   end
		m0.wb_wr_mult( 32'h0000_0010 + (0 << 28), 4'hf, del, 4);
		m0.wb_rd_mult( 32'h0000_0020 + (0 << 28), 4'hf, del, 4);
		m0.wb_wr_mult( 32'h0000_0030 + (0 << 28), 4'hf, del, 4);
	   end

	   begin
		m1.wb_wr_mult( 32'h0000_0100 + (0 << 28), 4'hf, del, 4);
		m1.wb_rd_mult( 32'h0000_0110 + (0 << 28), 4'hf, del, 4);
		m1.wb_rd1( 32'hff00_0000, 4'hf, data);
		if(data !== 32'h0000_a5ff)
		   begin
			$display("ERROR: RF read mismatch: Exp. 0, Got %h", data);
			error_cnt = error_cnt + 1;
		   end
		m1.wb_wr_mult( 32'h0000_0120 + (0 << 28), 4'hf, del, 4);
		m1.wb_rd_mult( 32'h0000_0130 + (0 << 28), 4'hf, del, 4);
	   end

	   begin
		m2.wb_rd_mult( 32'h0000_0200 + (0 << 28), 4'hf, del, 4);
		m2.wb_wr_mult( 32'h0000_0210 + (0 << 28), 4'hf, del, 4);
		m2.wb_rd_mult( 32'h0000_0220 + (0 << 28), 4'hf, del, 4);
		m2.wb_rd1( 32'hff00_0000, 4'hf, data);
		if(data !== 32'h0000_a5ff)
		   begin
			$display("ERROR: RF read mismatch: Exp. 0, Got %h", data);
			error_cnt = error_cnt + 1;
		   end
		m2.wb_wr_mult( 32'h0000_0230 + (0 << 28), 4'hf, del, 4);
	   end

	   begin
		m3.wb_wr_mult( 32'h0000_0300 + (0 << 28), 4'hf, del, 4);
		m3.wb_rd_mult( 32'h0000_0310 + (0 << 28), 4'hf, del, 4);
		m3.wb_wr_mult( 32'h0000_0320 + (0 << 28), 4'hf, del, 4);
		m3.wb_rd_mult( 32'h0000_0330 + (0 << 28), 4'hf, del, 4);
		m3.wb_rd1( 32'hff00_0000, 4'hf, data);
		if(data !== 32'h0000_a5ff)
		   begin
			$display("ERROR: RF read mismatch: Exp. a5ff, Got %h", data);
			error_cnt = error_cnt + 1;
		   end
	   end

	   begin
		m4.wb_rd_mult( 32'h0000_0400 + (1 << 28), 4'hf, del, 4);
		m4.wb_wr_mult( 32'h0000_0410 + (1 << 28), 4'hf, del, 4);
		m4.wb_rd_mult( 32'h0000_0420 + (1 << 28), 4'hf, del, 4);
		m4.wb_wr_mult( 32'h0000_0430 + (1 << 28), 4'hf, del, 4);
	   end

	   begin
		m5.wb_rd_mult( 32'h0000_0500 + (1 << 28), 4'hf, del, 4);
		m5.wb_wr_mult( 32'h0000_0510 + (1 << 28), 4'hf, del, 4);
		m5.wb_rd_mult( 32'h0000_0520 + (1 << 28), 4'hf, del, 4);
		m5.wb_wr_mult( 32'h0000_0530 + (1 << 28), 4'hf, del, 4);
	   end

	   begin
		m6.wb_wr_mult( 32'h0000_0600 + (15 << 28), 4'hf, del, 4);
		m6.wb_rd_mult( 32'h0000_0610 + (15 << 28), 4'hf, del, 4);
		m6.wb_wr_mult( 32'h0000_0620 + (15 << 28), 4'hf, del, 4);
		m6.wb_rd_mult( 32'h0000_0630 + (15 << 28), 4'hf, del, 4);
	   end

	   begin
		m7.wb_wr_mult( 32'h0000_0700 + (15 << 28), 4'hf, del, 4);
		m7.wb_rd_mult( 32'h0000_0710 + (15 << 28), 4'hf, del, 4);
		m7.wb_wr_mult( 32'h0000_0720 + (15 << 28), 4'hf, del, 4);
		m7.wb_rd_mult( 32'h0000_0730 + (15 << 28), 4'hf, del, 4);
	   end
	join

	verify(0,0,16);
	verify(1,0,16);
	verify(2,0,16);
	verify(3,0,16);
	verify(4,1,16);
	verify(5,1,16);
	verify(6,15,16);
	verify(7,15,16);
   end
	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");

end
endtask


task test_arb2;

integer		m, del, siz;
integer		n, a, b;
time		t[0:7];
reg	[1:0]	p[0:7];

begin

	$display("\n\n");
	$display("*****************************************************");
	$display("*** Arb. 2 Test ...                               ***");
	$display("*****************************************************\n");


siz = 4;
del = 0;
m=0;
for(m=0;m<32;m=m+1)
for(del=0;del<7;del=del+1)
for(siz=1;siz<5;siz=siz+1)
   begin

	init_all_mem;
	$display("Mode: %0d del: %0d, siz: %0d", m, del, siz);

	case(m)
	   0:
		begin
		p[7] = 2'd3;	// M 7
		p[6] = 2'd1;	// M 6
		p[5] = 2'd2;	// M 5
		p[4] = 2'd3;	// M 4
		p[3] = 2'd0;	// M 3
		p[2] = 2'd1;	// M 2
		p[1] = 2'd0;	// M 1
		p[0] = 2'd2;	// M 0
		end

	    4:
		begin
		p[7] = 2'd0;	// M 7
		p[6] = 2'd1;	// M 6
		p[5] = 2'd2;	// M 5
		p[4] = 2'd3;	// M 4
		p[3] = 2'd3;	// M 3
		p[2] = 2'd2;	// M 2
		p[1] = 2'd1;	// M 1
		p[0] = 2'd0;	// M 0
		end

	    8:
		begin
		p[7] = 2'd3;	// M 7
		p[6] = 2'd2;	// M 6
		p[5] = 2'd1;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd0;	// M 3
		p[2] = 2'd1;	// M 2
		p[1] = 2'd2;	// M 1
		p[0] = 2'd3;	// M 0
		end

	    12:
		begin
		p[7] = 2'd3;	// M 7
		p[6] = 2'd3;	// M 6
		p[5] = 2'd3;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd0;	// M 3
		p[2] = 2'd0;	// M 2
		p[1] = 2'd1;	// M 1
		p[0] = 2'd1;	// M 0
		end

	    16:
		begin
		p[7] = 2'd0;	// M 7
		p[6] = 2'd0;	// M 6
		p[5] = 2'd0;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd1;	// M 3
		p[2] = 2'd1;	// M 2
		p[1] = 2'd3;	// M 1
		p[0] = 2'd3;	// M 0
		end

	    20:
		begin
		p[7] = 2'd3;	// M 7
		p[6] = 2'd0;	// M 6
		p[5] = 2'd2;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd1;	// M 3
		p[2] = 2'd0;	// M 2
		p[1] = 2'd0;	// M 1
		p[0] = 2'd0;	// M 0
		end

	    24:
		begin
		p[7] = 2'd0;	// M 7
		p[6] = 2'd0;	// M 6
		p[5] = 2'd1;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd0;	// M 3
		p[2] = 2'd2;	// M 2
		p[1] = 2'd0;	// M 1
		p[0] = 2'd3;	// M 0
		end

	    28:
		begin
		p[7] = 2'd0;	// M 7
		p[6] = 2'd0;	// M 6
		p[5] = 2'd1;	// M 5
		p[4] = 2'd0;	// M 4
		p[3] = 2'd0;	// M 3
		p[2] = 2'd0;	// M 2
		p[1] = 2'd0;	// M 1
		p[0] = 2'd3;	// M 0
		end

	    default:
		begin
		p[7] = p[7] + 1;// M 7
		p[6] = p[6] + 1;// M 6
		p[5] = p[5] + 1;// M 5
		p[4] = p[4] + 1;// M 4
		p[3] = p[3] + 1;// M 3
		p[2] = p[2] + 1;// M 2
		p[1] = p[1] + 1;// M 1
		p[0] = p[0] + 1;// M 0
		end
	endcase

	m1.wb_wr1( 32'hff00_0000, 4'hf, {16'h0000, p[7], p[6], p[5],
			p[4], p[3], p[2], p[1], p[0]} );

	@(posedge clk);
	fork
	   begin
		repeat(del)	@(posedge clk);
		m0.wb_wr_mult( 32'h0000_0000             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m0.wb_rd_mult( 32'h0000_0000 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m0.wb_wr_mult( 32'h0000_0000 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m0.wb_rd_mult( 32'h0000_0000 + (siz * 12), 4'hf, del, siz);
		t[0] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m1.wb_rd_mult( 32'h0000_0100             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m1.wb_wr_mult( 32'h0000_0100 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m1.wb_rd_mult( 32'h0000_0100 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m1.wb_wr_mult( 32'h0000_0100 + (siz * 12), 4'hf, del, siz);
		t[1] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m2.wb_wr_mult( 32'h0000_0200             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m2.wb_rd_mult( 32'h0000_0200 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m2.wb_wr_mult( 32'h0000_0200 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m2.wb_rd_mult( 32'h0000_0200 + (siz * 12), 4'hf, del, siz);
		t[2] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m3.wb_rd_mult( 32'h0000_0300             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m3.wb_wr_mult( 32'h0000_0300 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m3.wb_rd_mult( 32'h0000_0300 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m3.wb_wr_mult( 32'h0000_0300 + (siz * 12), 4'hf, del, siz);
		t[3] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m4.wb_wr_mult( 32'h0000_0400             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m4.wb_rd_mult( 32'h0000_0400 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m4.wb_wr_mult( 32'h0000_0400 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m4.wb_rd_mult( 32'h0000_0400 + (siz * 12), 4'hf, del, siz);
		t[4] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m5.wb_rd_mult( 32'h0000_0500             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m5.wb_wr_mult( 32'h0000_0500 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m5.wb_rd_mult( 32'h0000_0500 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m5.wb_wr_mult( 32'h0000_0500 + (siz * 12), 4'hf, del, siz);
		t[5] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m6.wb_wr_mult( 32'h0000_0600             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m6.wb_rd_mult( 32'h0000_0600 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m6.wb_wr_mult( 32'h0000_0600 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m6.wb_rd_mult( 32'h0000_0600 + (siz * 12), 4'hf, del, siz);
		t[6] = $time;
	   end

	   begin
		repeat(del)	@(posedge clk);
		m7.wb_wr_mult( 32'h0000_0700             , 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m7.wb_rd_mult( 32'h0000_0700 + (siz *  4), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m7.wb_wr_mult( 32'h0000_0700 + (siz *  8), 4'hf, del, siz);
		repeat(del)	@(posedge clk);
		m7.wb_rd_mult( 32'h0000_0700 + (siz * 12), 4'hf, del, siz);
		t[7] = $time;
	   end

	join

	verify(0,0,siz*4);
	verify(1,0,siz*4);
	verify(2,0,siz*4);
	verify(3,0,siz*4);
	verify(4,0,siz*4);
	verify(5,0,siz*4);
	verify(6,0,siz*4);
	verify(7,0,siz*4);

	for(a=0;a<8;a=a+1)
	for(b=0;b<8;b=b+1)
		if((t[a] < t[b]) & (p[a] <= p[b]) & (p[a] != p[b]) )
		   begin
			$display("ERROR: Master %0d compleated before Master %0d", a, b);
			$display("       M[%0d] pri: %0d (t: %0t)", a, p[a], t[a]);
			$display("       M[%0d] pri: %0d (t: %0t)", b, p[b], t[b]);
			error_cnt = error_cnt + 1;
		   end
   end

	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");

end
endtask



task test_dp1;

integer	n;
reg	[3:0]	s0, s1, s2, s3, s4, s5, s6, s7;

begin

	$display("\n\n");
	$display("*****************************************************");
	$display("*** Datapath 1 Test ...                           ***");
	$display("*****************************************************\n");

s0 = 0;
s1 = 1;
s2 = 2;
s3 = 3;
s4 = 4;
s5 = 5;
s6 = 6;
s7 = 7;

for(n=0;n<16;n=n+1)
   begin
	init_all_mem;
	$display("Mode: %0d", n);

	fork

	begin
		m0.wb_wr_mult( 32'h0000_0000 + (s0 << 28), 4'hf, 0, 4);
		m0.wb_rd_mult( 32'h0000_0010 + (s0 << 28), 4'hf, 0, 4);
		m0.wb_wr_mult( 32'h0000_0020 + (s0 << 28), 4'hf, 0, 4);
		m0.wb_rd_mult( 32'h0000_0030 + (s0 << 28), 4'hf, 0, 4);
	end

	begin
		m1.wb_wr_mult( 32'h0000_0100 + (s1 << 28), 4'hf, 0, 4);
		m1.wb_rd_mult( 32'h0000_0110 + (s1 << 28), 4'hf, 0, 4);
		m1.wb_wr_mult( 32'h0000_0120 + (s1 << 28), 4'hf, 0, 4);
		m1.wb_rd_mult( 32'h0000_0130 + (s1 << 28), 4'hf, 0, 4);
	end

	begin
		m2.wb_wr_mult( 32'h0000_0200 + (s2 << 28), 4'hf, 0, 4);
		m2.wb_rd_mult( 32'h0000_0210 + (s2 << 28), 4'hf, 0, 4);
		m2.wb_wr_mult( 32'h0000_0220 + (s2 << 28), 4'hf, 0, 4);
		m2.wb_rd_mult( 32'h0000_0230 + (s2 << 28), 4'hf, 0, 4);
	end

	begin
		m3.wb_wr_mult( 32'h0000_0300 + (s3 << 28), 4'hf, 0, 4);
		m3.wb_rd_mult( 32'h0000_0310 + (s3 << 28), 4'hf, 0, 4);
		m3.wb_wr_mult( 32'h0000_0320 + (s3 << 28), 4'hf, 0, 4);
		m3.wb_rd_mult( 32'h0000_0330 + (s3 << 28), 4'hf, 0, 4);
	end

	begin
		m4.wb_wr_mult( 32'h0000_0400 + (s4 << 28), 4'hf, 0, 4);
		m4.wb_rd_mult( 32'h0000_0410 + (s4 << 28), 4'hf, 0, 4);
		m4.wb_wr_mult( 32'h0000_0420 + (s4 << 28), 4'hf, 0, 4);
		m4.wb_rd_mult( 32'h0000_0430 + (s4 << 28), 4'hf, 0, 4);
	end

	begin
		m5.wb_wr_mult( 32'h0000_0500 + (s5 << 28), 4'hf, 0, 4);
		m5.wb_rd_mult( 32'h0000_0510 + (s5 << 28), 4'hf, 0, 4);
		m5.wb_wr_mult( 32'h0000_0520 + (s5 << 28), 4'hf, 0, 4);
		m5.wb_rd_mult( 32'h0000_0530 + (s5 << 28), 4'hf, 0, 4);
	end

	begin
		m6.wb_wr_mult( 32'h0000_0600 + (s6 << 28), 4'hf, 0, 4);
		m6.wb_rd_mult( 32'h0000_0610 + (s6 << 28), 4'hf, 0, 4);
		m6.wb_wr_mult( 32'h0000_0620 + (s6 << 28), 4'hf, 0, 4);
		m6.wb_rd_mult( 32'h0000_0630 + (s6 << 28), 4'hf, 0, 4);
	end

	begin
		m7.wb_wr_mult( 32'h0000_0700 + (s7 << 28), 4'hf, 0, 4);
		m7.wb_rd_mult( 32'h0000_0710 + (s7 << 28), 4'hf, 0, 4);
		m7.wb_wr_mult( 32'h0000_0720 + (s7 << 28), 4'hf, 0, 4);
		m7.wb_rd_mult( 32'h0000_0730 + (s7 << 28), 4'hf, 0, 4);
	end

	join

	verify(0,s0,16);
	verify(1,s1,16);
	verify(2,s2,16);
	verify(3,s3,16);
	verify(4,s4,16);
	verify(5,s5,16);
	verify(6,s6,16);
	verify(7,s7,16);

	@(posedge clk);

	s0 = s0 + 1;
	s1 = s1 + 1;
	s2 = s2 + 1;
	s3 = s3 + 1;
	s4 = s4 + 1;
	s5 = s5 + 1;
	s6 = s6 + 1;
	s7 = s7 + 1;

	@(posedge clk);

   end

	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");

end
endtask

task test_dp2;

integer	del;
integer	x0, x1, x2, x3, x4, x5, x6, x7;
reg	[3:0]	m;

begin

	$display("\n\n");
	$display("*****************************************************");
	$display("*** Datapath 2 Test ...                           ***");
	$display("*****************************************************\n");

del=0;
for(del=0;del<5;del=del+1)
   begin
	init_all_mem;
	$display("Delay: %0d", del);

	fork

	begin
		for(x0=0;x0<16;x0=x0+1)
			m0.wb_rd_mult( 32'h0000_0000 + ((0+x0) << 28) + (x0<<4), 4'hf, del, 4);
	end

	begin
		for(x1=0;x1<16;x1=x1+1)
			m1.wb_rd_mult( 32'h0000_0100 + ((1+x1) << 28) + (x1<<4), 4'hf, del, 4);
	end

	begin
		for(x2=0;x2<16;x2=x2+1)
			m2.wb_rd_mult( 32'h0000_0200 + ((2+x2) << 28) + (x2<<4), 4'hf, del, 4);

	end

	begin
		for(x3=0;x3<16;x3=x3+1)
			m3.wb_rd_mult( 32'h0000_0300 + ((3+x3) << 28) + (x3<<4), 4'hf, del, 4);
	end

	begin
		for(x4=0;x4<16;x4=x4+1)
			m4.wb_rd_mult( 32'h0000_0400 + ((4+x4) << 28) + (x4<<4), 4'hf, del, 4);
	end

	begin
		for(x5=0;x5<16;x5=x5+1)
			m5.wb_rd_mult( 32'h0000_0500 + ((5+x5) << 28) + (x5<<4), 4'hf, del, 4);
	end

	begin
		for(x6=0;x6<16;x6=x6+1)
			m6.wb_rd_mult( 32'h0000_0600 + ((6+x6) << 28) + (x6<<4), 4'hf, del, 4);
	end

	begin
		for(x7=0;x7<16;x7=x7+1)
			m7.wb_rd_mult( 32'h0000_0700 + ((7+x7) << 28) + (x7<<4), 4'hf, del, 4);
	end
	join

	for(x1=0;x1<8;x1=x1+1)
	for(x0=0;x0<16;x0=x0+1)
	   begin
		m = x0+x1;
		verify_sub(x1,m,4,(x0*4),(x0*4));
	   end

   end

	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");

end
endtask


task test_rf;

integer	n, m;
reg	[31:0]	wdata[0:15];
reg	[31:0]	rdata[0:15];
reg	[15:0]	rtmp, wtmp;

begin

	$display("\n\n");
	$display("*****************************************************");
	$display("*** Register File Test ...                        ***");
	$display("*****************************************************\n");

for(m=0;m<5;m=m+1)
   begin
	$display("Mode: %0d", m);

	for(n=0;n<16;n=n+1)
		wdata[n] = $random;

	for(n=0;n<16;n=n+1)
		case(m)
		   0: m0.wb_wr1(32'hff00_0000 + (n << 2), 4'hf, wdata[n]);
		   1: m3.wb_wr1(32'hff00_0000 + (n << 2), 4'hf, wdata[n]);
		   2: m5.wb_wr1(32'hff00_0000 + (n << 2), 4'hf, wdata[n]);
		   3: m7.wb_wr1(32'hff00_0000 + (n << 2), 4'hf, wdata[n]);
		   4: m7.wb_wr1(32'hff00_0000 + (n << 2), 4'hf, wdata[n]);
		endcase

	for(n=0;n<16;n=n+1)
		case(m)
		   0: m7.wb_rd1(32'hff00_0000 + (n << 2), 4'hf, rdata[n]);
		   1: m3.wb_rd1(32'hff00_0000 + (n << 2), 4'hf, rdata[n]);
		   2: m6.wb_rd1(32'hff00_0000 + (n << 2), 4'hf, rdata[n]);
		   3: m0.wb_rd1(32'hff00_0000 + (n << 2), 4'hf, rdata[n]);
		   4: m7.wb_rd1(32'hff00_0000 + (n << 2), 4'hf, rdata[n]);
		endcase

	for(n=0;n<16;n=n+1)
	   begin
		rtmp = rdata[n];
		wtmp = wdata[n];
		if(rtmp !== wtmp)
		   begin
			$display("ERROR: RF[%0d] Mismatch. Expected: %h, Got: %h (%0t)",
			n, wtmp, rtmp, $time);
		   end
	   end
   end

	show_errors;
	$display("*****************************************************");
	$display("*** Test DONE ...                                 ***");
	$display("*****************************************************\n\n");


end
endtask

