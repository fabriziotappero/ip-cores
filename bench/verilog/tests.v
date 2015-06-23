/////////////////////////////////////////////////////////////////////
////                                                             ////
////  DMA Test Cases                                             ////
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
//  $Id: tests.v,v 1.3 2001-09-07 15:34:36 rudi Exp $
//
//  $Date: 2001-09-07 15:34:36 $
//  $Revision: 1.3 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2001/08/15 05:40:29  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Added Section 3.10, describing DMA restart.
//
//               Revision 1.1  2001/07/29 08:57:02  rudi
//
//
//               1) Changed Directory Structure
//               2) Added restart signal (REST)
//
//               Revision 1.1.1.1  2001/03/19 13:12:39  rudi
//               Initial Release
//
//
//                        

task sw_ext_desc1;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max, del_max;

reg	[7:0]	mode;
reg	[15:0]	tot_sz;
reg	[15:0]	chunk_sz;
integer		ii, n,del;
reg	[31:0]	int_src, d0, d1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SW DMA No Buffer Ext. Descr LL ...            ***");
$display("*****************************************************\n");

rst = 1;
repeat(10)	@(posedge clk);
rst = 0;
repeat(10)	@(posedge clk);

if(quick)
   begin
	tot_sz_max = 32;
	del_max = 2;
	chunk_sz_max = 4;
   end
else
   begin
	tot_sz_max = 128;
	del_max = 6;
	chunk_sz_max = 8;
   end


mode = 1;
tot_sz = 64;
chunk_sz=3;
del = 0;

for(del=0;del<del_max;del=del+1)
for(mode=0;mode<4;mode=mode+1)
for(tot_sz=1;tot_sz<tot_sz_max;tot_sz=tot_sz + 1)
begin

if(tot_sz>8)	tot_sz = tot_sz + 2;
if(tot_sz>16)	tot_sz = tot_sz + 2;
if(tot_sz>32)	tot_sz = tot_sz + 12;


for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
begin

	case(mode)
	   0: $write("Mode: 0->0, ");
	   1: $write("Mode: 0->1, ");
	   2: $write("Mode: 1->0, ");
	   3: $write("Mode: 1->1, ");
	endcase
	$display("Total Size: %0d, Chunk Size: %0d, Slave Delay: %0d",
		tot_sz, chunk_sz, del);

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	s0.delay = del;
	s1.delay = del;

	s0.fill_mem(1);
	s1.fill_mem(1);

	s0.mem[0] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[1] = 32'h0000_0100;
	s0.mem[2] = 32'h0000_0400;
	s0.mem[3] = 32'h0000_0010;

	s0.mem[4] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[5] = 32'h0000_0100 + (tot_sz * 4);
	s0.mem[6] = 32'h0000_0400 + (tot_sz * 4);
	s0.mem[7] = 32'h0000_0000;


	s0.mem[8] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[9] = 32'h0000_0800;
	s0.mem[10] = 32'h0000_0c00;
	s0.mem[11] = 32'h0000_0030;

	s0.mem[12] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[13] = 32'h0000_0800 + (tot_sz * 4);
	s0.mem[14] = 32'h0000_0c00 + (tot_sz * 4);
	s0.mem[15] = 32'h0000_0000;


	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `PTR0, 4'hf, 32'h0000_0020);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, 12'h0});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_0080);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_4000);

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
	{15'h0002, 3'b000, 1'b0, 6'h1, 4'b0011, 2'b00, 1'b1});


	m0.wb_wr1(`REG_BASE + `PTR1, 4'hf, 32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH1_TXSZ,4'hf, {chunk_sz, 12'h0});
	m0.wb_wr1(`REG_BASE + `CH1_ADR0,4'hf,32'h0000_0080);
	m0.wb_wr1(`REG_BASE + `CH1_ADR1,4'hf,32'h0000_4000);

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
	{15'h0002, 3'b000, 1'b0, 6'h1, 4'b0011, 2'b00, 1'b1});


for(ii=0;ii<2;ii=ii+1)
begin
	repeat(5)	@(posedge clk);
	while(!inta_o)	@(posedge clk);

	m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);

	if(int_src[0])
	begin
	for(n=0;n<tot_sz*2;n=n+1)
	   begin
		if(mode[1])	d0=s1.mem[(s0.mem[9]>>2) + n ];
		else		d0=s0.mem[(s0.mem[9]>>2) + n ];
		if(mode[0])	d1=s1.mem[(s0.mem[10]>>2) + n ];
		else		d1=s0.mem[(s0.mem[10]>>2) + n ];
	
		if( d1 !== d0 )
		   begin
			$display("ERROR: CH0: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, d0, d1, $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d1);
	d0 = {24'h0064_089, 1'b1, mode[1:0], 1'b0};
	if( d1 !== d0 )
	   begin
		$display("ERROR: CH0_CSR Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end
	end


	if(int_src[1])
	begin
	for(n=0;n<tot_sz*2;n=n+1)
	   begin
		if(mode[1])	d0=s1.mem[(s0.mem[1]>>2) + n ];
		else		d0=s0.mem[(s0.mem[1]>>2) + n ];
		if(mode[0])	d1=s1.mem[(s0.mem[2]>>2) + n ];
		else		d1=s0.mem[(s0.mem[2]>>2) + n ];
	
		if( d1 !== d0 )
		   begin
			$display("ERROR: CH1: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, d0, d1, $time);
			error_cnt = error_cnt + 1;
		   end
	   end
	m0.wb_rd1(`REG_BASE + `CH1_CSR, 4'hf, d1);
	d0 = {24'h0064_089, 1'b1, mode[1:0], 1'b0};
	if( d1 !== d0 )
	   begin
		$display("ERROR: CH1_CSR Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end
	end

end

	if(ack_cnt != ((tot_sz*4)+(4*2))*2 )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*4)+(4*2)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end

	repeat(5)	@(posedge clk);

end
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end


endtask



task arb_test1;

reg	[7:0]	mode;
reg	[15:0]	tot_sz;
reg	[15:0]	chunk_sz0;
reg	[15:0]	chunk_sz1;
reg	[15:0]	chunk_sz2;
reg	[15:0]	chunk_sz3;
integer		a,n,ptr;
reg	[31:0]	d0,d1;
reg	[7:0]	pri, order, finish;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SW DMA No Buffer 4 ch pri ...                 ***");
$display("*****************************************************\n");

mode = 0;
tot_sz = 32;
chunk_sz0=4;
chunk_sz1=4;
chunk_sz2=4;
chunk_sz3=4;
a=0;

m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf, 32'h0);

m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, d0);

for(mode=0;mode<4;mode=mode+1)
for(a=0;a<17;a=a+1)
begin

	chunk_sz0=4;
	chunk_sz1=4;
	chunk_sz2=4;
	chunk_sz3=4;

	s0.delay = 0;
	s1.delay = 0;

	case(a)		// ch3 ch2 ch1 ch0
	   0:
	     begin
		pri = 8'b10_10_10_10;	// All equal 0,1,2,3
		order = {2'd0, 2'd1, 2'd2, 2'd3};
	     end

		// One channel with High Priority
		// The other depend oon the ARB state
	   1:
	     begin
		pri = 8'b00_00_00_10;	// 3,1,0,2
		order = {2'b0, 2'd3, 2'd1, 2'd2};
	     end
	   2:
	     begin
		pri = 8'b00_00_10_00;	// 2,3,0,1
		order = {2'd1, 2'd0, 2'd2, 2'd3};
	     end
	   3:
	     begin
		pri = 8'b00_10_00_00;	// 1,0,2,3
		order = {2'd2, 2'd0, 2'd1, 2'd3};
	     end
	   4:
	     begin
		pri = 8'b10_00_00_00;	// 0,3,1,2
		order = {2'd3, 2'd0, 2'd1, 2'd2};
	     end

		// Specific order for all Channels
	   5:
	     begin
		pri = 8'b10_00_01_11;	// 3,0,2,1
		order = {2'd0, 2'd3, 2'd1, 2'd2};
	     end

	   6:
	     begin
		pri = 8'b00_10_11_01;	// 2,1,3,0
		order = {2'd1, 2'd2, 2'd0, 2'd3};
	     end

	   7:
	     begin
		pri = 8'b00_11_01_10;	// 1,3,2,0
		order = {2'd2, 2'd0, 2'd1, 2'd3};
	     end

	   8:
	     begin
		pri = 8'b00_01_10_11;	// 3,2,1,0
		order = {2'd0, 2'd1, 2'd2, 2'd3};
	     end

		// One channel with High Priority
		// The other depend oon the ARB state
		// Chunk Size varies
		// First channel small chunkc size
	   9:
	     begin
		pri = 8'b00_00_00_10;	// 3,1,0,2
		order = {2'd0, 2'd1, 2'd2, 2'd3};
		chunk_sz3=1;
	     end
	   10:
	     begin
		pri = 8'b00_00_10_00;	// 2,0,1,3
		order = {2'd1, 2'd0, 2'd3, 2'd2};
		chunk_sz2=1;
	     end
	   11:
	     begin
		pri = 8'b00_10_00_00;	// 1,0,2,3
		order = {2'd2, 2'd0, 2'd3, 2'd1};
		chunk_sz1=1;
	     end
	   12:
	     begin
		pri = 8'b10_00_00_00;	// 0,2,3,1
		order = {2'd3, 2'd1, 2'd2, 2'd0};
		chunk_sz0=1;
	     end

		// First channel large chunkc size
	   13:
	     begin
		pri = 8'b00_00_00_10;	// 3,0,2,1
		order = {2'd0, 2'd3, 2'd1, 2'd2};
		chunk_sz3=8;
	     end
	   14:
	     begin
		pri = 8'b00_00_10_00;	// 2,0,3,1
		order = {2'd1, 2'd2, 2'd0, 2'd3};
		chunk_sz2=8;
	     end
	   15:
	     begin
		pri = 8'b00_10_00_00;	// 1,0,3,2
		order = {2'd2, 2'd1, 2'd0, 2'd3};
		chunk_sz1=8;
	     end
	   16:
	     begin
		pri = 8'b10_00_00_00;	// 0,2,3,1
		order = {2'd3, 2'd0, 2'd1, 2'd2};
		chunk_sz0=8;
	     end

	endcase

case(mode)
   0: $write("Mode: 0->0, ");
   1: $write("Mode: 0->1, ");
   2: $write("Mode: 1->0, ");
   3: $write("Mode: 1->1, ");
endcase
$display("a: %0d", a);

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	s0.fill_mem(1);
	s1.fill_mem(1);

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
		{17'h00000, pri[1:0], 6'h0, 4'b0011, mode[1:0], 1'b0});

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
		{17'h00000, pri[3:2], 6'h0, 4'b0011, mode[1:0], 1'b0});

	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf,
		{17'h00000, pri[5:4], 6'h0, 4'b0011, mode[1:0], 1'b0});

	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf,
		{17'h00000, pri[7:6], 6'h0, 4'b0011, mode[1:0], 1'b0});

	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz0, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_4000);

	m0.wb_wr1(`REG_BASE + `CH1_TXSZ,4'hf, {chunk_sz1, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH1_ADR0,4'hf,32'h0000_0080);
	m0.wb_wr1(`REG_BASE + `CH1_ADR1,4'hf,32'h0000_4080);

	m0.wb_wr1(`REG_BASE + `CH2_TXSZ,4'hf, {chunk_sz2, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH2_ADR0,4'hf,32'h0000_0100);
	m0.wb_wr1(`REG_BASE + `CH2_ADR1,4'hf,32'h0000_4100);

	m0.wb_wr1(`REG_BASE + `CH3_TXSZ,4'hf, {chunk_sz3, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH3_ADR0,4'hf,32'h0000_0180);
	m0.wb_wr1(`REG_BASE + `CH3_ADR1,4'hf,32'h0000_4180);


	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
		{12'h000, 3'b010, 1'b0, 1'b0, pri[1:0], 6'h0, 4'b0011, mode[1:0], 1'b1});

	        //{15'h0002, 3'b000, 1'b0, 6'h1, 4'b0011, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
		{12'h000, 3'b010, 1'b0, 1'b0, pri[3:2], 6'h0, 4'b0011, mode[1:0], 1'b1});

	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf,
		{12'h000, 3'b010, 1'b0, 1'b0, pri[5:4], 6'h0, 4'b0011, mode[1:0], 1'b1});



	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf,
		{12'h0000, 3'b010, 1'b0, 1'b0, pri[7:6], 6'h0, 4'b0011, mode[1:0], 1'b1});

	repeat(1)	@(posedge clk);

	// Wait for interrupt, Check completion order

	ptr=0;
	finish = 8'hxx;

	while(ptr!=4)
	   begin
		while(!inta_o)	@(posedge clk);
		m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, d0);

		if(d0[0])	d0[1:0] = 0;
		else
		if(d0[1])	d0[1:0] = 1;
		else
		if(d0[2])	d0[1:0] = 2;
		else
		if(d0[3])	d0[1:0] = 3;

		case(ptr)
		   0: finish[7:6] = d0[1:0];
		   1: finish[5:4] = d0[1:0];
		   2: finish[3:2] = d0[1:0];
		   3: finish[1:0] = d0[1:0];
		endcase

		case(d0[1:0])
		   0: m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d0);
		   1: m0.wb_rd1(`REG_BASE + `CH1_CSR, 4'hf, d0);
		   2: m0.wb_rd1(`REG_BASE + `CH2_CSR, 4'hf, d0);
		   3: m0.wb_rd1(`REG_BASE + `CH3_CSR, 4'hf, d0);
		endcase

		ptr=ptr+1;
		repeat(4)	@(posedge clk);
	   end


	if(finish !== order)
	   begin
		$display("ERROR: Completion Order[%0d] Mismatch: Expected: %b, Got: %b (%0t)",
		a, order, finish, $time);
		error_cnt = error_cnt + 1;
	   end


	for(n=0;n<tot_sz*4;n=n+1)
	   begin
		if(mode[1])	d0=s1.mem[ n ];
		else		d0=s0.mem[ n ];
		if(mode[0])	d1=s1.mem[32'h0000_1000 + n ];
		else		d1=s0.mem[32'h0000_1000 + n ];
	
		if( d1 !== d0 )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, d0, d1, $time);
			error_cnt = error_cnt + 1;
		   end
	   end

	if(ack_cnt != ((tot_sz*4*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*4)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end


	repeat(5)	@(posedge clk);

end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end

endtask






task hw_dma1;
input	quick;

integer		quick, chunk_sz_max, del_max;

reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		n,m,k,rep,del;
reg	[31:0]	d0,d1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** HW DMA No Buffer ...                          ***");
$display("*****************************************************\n");

if(quick)
   begin
	tot_sz = 32;
	chunk_sz_max= 4;
	del_max = 3;
   end
else
   begin
	tot_sz = 64;
	chunk_sz_max= 8;
	del_max = 5;
   end

mode = 1;
chunk_sz=4;
del = 8;
for(mode=0;mode<4;mode=mode+1)
for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
for(del=0;del<del_max;del=del+1)
begin

	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_4000);
	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
		{25'h0000000, 4'b1111, mode[1:0], 1'b1});

$write("Delay: %0d ",del);
case(mode)
   0: $display("Mode: 0->0, chunk_size: %0d", chunk_sz);
   1: $display("Mode: 0->1, chunk_size: %0d", chunk_sz);
   2: $display("Mode: 1->0, chunk_size: %0d", chunk_sz);
   3: $display("Mode: 1->1, chunk_size: %0d", chunk_sz);
endcase

for(rep=0;rep<4;rep=rep+1)
   begin
	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	if(del==4)	del = 10;

	s0.delay = del;
	s1.delay = del;

	if(chunk_sz==0)		k = 1;
	else
	   begin
		k = tot_sz/chunk_sz;
		if((k*chunk_sz) != tot_sz)	k = k + 1;
	   end

	s0.fill_mem(1);
	s1.fill_mem(1);

	fork
	   begin

		for(m=0;m < k;m=m+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[0] = 1;
			while(!ack_o[0])	@(posedge clk);
			#1;
			req_i[0] = 0;
		   end

	   end

	   begin
		repeat(1)	@(posedge clk);
		while(!u0.dma_done_all)	@(posedge clk);

/*
	repeat(5)	@(posedge clk);
	while(!inta_o)	@(posedge clk);

	m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, d1);
	d0 = 32'h0000_0002;
	if( d1 !== d0 )
	   begin
		$display("ERROR: INT_SRC Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end

	m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d1);
	d0 = {24'h0000_081, 1'b1, mode[1:0], 1'b0};
	if( d1 !== d0 )
	   begin
		$display("ERROR: CH0_CSR Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end
*/

	
		for(n=0;n<tot_sz;n=n+1)
		   begin
			if(mode[1])	d0=s1.mem[ n ];
			else		d0=s0.mem[ n ];
			if(mode[0])	d1=s1.mem[32'h0000_1000 + n ];
			else		d1=s0.mem[32'h0000_1000 + n ];
		
			if( d1 !== d0 )
			   begin
				$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
				n, d0, d1, $time);
				error_cnt = error_cnt + 1;
			   end
		   end

	   end

	join

	if(ack_cnt != ((tot_sz*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*2)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end

   end
end

	s0.delay = 0;
	s1.delay = 0;

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end

endtask




task hw_dma2;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max, del_max;

reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		i, n,m0, m1, m2, m3, k,rep,del;
reg	[31:0]	int_src, d0,d1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** HW DMA No Buffer Ext Descr. 4 Channels ...    ***");
$display("*****************************************************\n");

case(quick)
	default:
	   begin
		del_max = 6;
		tot_sz_max = 200;
		chunk_sz_max = 8;
	   end
	 1:
	   begin
		del_max = 4;
		tot_sz_max = 128;
		chunk_sz_max = 4;
	   end
	 2:
	   begin
		del_max = 3;
		tot_sz_max = 32;
		chunk_sz_max = 4;
	   end
endcase

mode = 0;
tot_sz = 128;
chunk_sz=2;
del = 0;

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf, 32'h0);

	m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);

for(tot_sz=1;tot_sz<tot_sz_max;tot_sz=tot_sz+1)
begin

if(tot_sz>4)	tot_sz = tot_sz + 4;
if(tot_sz>16)	tot_sz = tot_sz + 12;
if(tot_sz>64)	tot_sz = tot_sz + 48;

for(del=0;del<del_max;del=del+1)
for(mode=0;mode<4;mode=mode+1)
for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
begin
	s0.delay = del;
	s1.delay = del;

	s0.fill_mem(1);
	s1.fill_mem(1);

	s0.mem[0] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[1] = 32'h0000_0100;
	s0.mem[2] = 32'h0000_0900;
	s0.mem[3] = 32'h0000_0010;

	s0.mem[4] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[5] = 32'h0000_0100 + (tot_sz * 4);
	s0.mem[6] = 32'h0000_0900 + (tot_sz * 4);
	s0.mem[7] = 32'h0000_0000;

	s0.mem[8] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[9] = 32'h0000_1100;
	s0.mem[10] = 32'h0000_1900;
	s0.mem[11] = 32'h0000_0030;

	s0.mem[12] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[13] = 32'h0000_1100 + (tot_sz * 4);
	s0.mem[14] = 32'h0000_1900 + (tot_sz * 4);
	s0.mem[15] = 32'h0000_0000;

	s0.mem[16] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[17] = 32'h0000_2100;
	s0.mem[18] = 32'h0000_2900;
	s0.mem[19] = 32'h0000_0050;

	s0.mem[20] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[21] = 32'h0000_2100 + (tot_sz * 4);
	s0.mem[22] = 32'h0000_2900 + (tot_sz * 4);
	s0.mem[23] = 32'h0000_0000;

	s0.mem[24] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[25] = 32'h0000_3100;
	s0.mem[26] = 32'h0000_3900;
	s0.mem[27] = 32'h0000_0070;

	s0.mem[28] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[29] = 32'h0000_3100 + (tot_sz * 4);
	s0.mem[30] = 32'h0000_3900 + (tot_sz * 4);
	s0.mem[31] = 32'h0000_0000;

	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `PTR0, 4'hf, 32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b0, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR1, 4'hf, 32'h0000_0020);
	m0.wb_wr1(`REG_BASE + `CH1_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH1_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH1_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b0, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR2, 4'hf, 32'h0000_0040);
	m0.wb_wr1(`REG_BASE + `CH2_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH2_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH2_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b0, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR3, 4'hf, 32'h0000_0060);
	m0.wb_wr1(`REG_BASE + `CH3_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH3_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH3_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b0, 9'h001, 4'b0111, 2'b00, 1'b1});


	$write("Total Size: %0d, Delay: %0d ",tot_sz, del);
	case(mode)
	   0: $display("Mode: 0->0, chunk_size: %0d", chunk_sz);
	   1: $display("Mode: 0->1, chunk_size: %0d", chunk_sz);
	   2: $display("Mode: 1->0, chunk_size: %0d", chunk_sz);
	   3: $display("Mode: 1->1, chunk_size: %0d", chunk_sz);
	endcase

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	if(chunk_sz==0)		k = 1;
	else
	   begin
		k = tot_sz/chunk_sz;
		if((k*chunk_sz) != tot_sz)	k = k + 1;
	   end

	k = k * 2;

	fork
	   begin
		repeat(5)	@(posedge clk);
		for(m0=0;m0 < k;m0=m0+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[0] = 1;
			while(!ack_o[0])	@(posedge clk);
			#1;
			req_i[0] = 0;
		   end
	   end

	   begin
		repeat(5)	@(posedge clk);
		for(m1=0;m1 < k;m1=m1+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[1] = 1;
			while(!ack_o[1])	@(posedge clk);
			#1;
			req_i[1] = 0;
		   end
	   end

	   begin
		repeat(5)	@(posedge clk);
		for(m2=0;m2 < k;m2=m2+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[2] = 1;
			while(!ack_o[2])	@(posedge clk);
			#1;
			req_i[2] = 0;
		   end
	   end

	   begin
		repeat(5)	@(posedge clk);
		for(m3=0;m3 < k;m3=m3+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[3] = 1;
			while(!ack_o[3])	@(posedge clk);
			#1;
			req_i[3] = 0;
		   end
	   end

	   for(i=0;i<4;i=i)
	   begin
		repeat(5)	@(posedge clk);
		while(!inta_o)	@(posedge clk);
		m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);
	
		if(int_src[0])
		   begin
			m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[1]>>2) + n ];
				else		d0=s0.mem[(s0.mem[1]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[2]>>2) + n ];
				else		d1=s0.mem[(s0.mem[2]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH0: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[1])
		   begin
			m0.wb_rd1(`REG_BASE + `CH1_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[9]>>2) + n ];
				else		d0=s0.mem[(s0.mem[9]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[10]>>2) + n ];
				else		d1=s0.mem[(s0.mem[10]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH1: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[2])
		   begin
			m0.wb_rd1(`REG_BASE + `CH2_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[17]>>2) + n ];
				else		d0=s0.mem[(s0.mem[17]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[18]>>2) + n ];
				else		d1=s0.mem[(s0.mem[18]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH2: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[3])
		   begin
			m0.wb_rd1(`REG_BASE + `CH3_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[25]>>2) + n ];
				else		d0=s0.mem[(s0.mem[25]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[26]>>2) + n ];
				else		d1=s0.mem[(s0.mem[26]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH3: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

	   end

	join


	if(ack_cnt != ((tot_sz*2*4*2)+(4*4*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*2*4*2)+(4*4*2)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end

	repeat(5)	@(posedge clk);

end
end

	s0.delay = 0;
	s1.delay = 0;

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end

endtask






task hw_dma3;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max, del_max;

reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		odd, i, iz, n,m0, m1, m2, m3, k, k1, rep,del;
reg	[31:0]	int_src, d0,d1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** HW DMA Ext Descr. 4 Channels ND Test ...      ***");
$display("*****************************************************\n");

case(quick)
	default:
	   begin
		del_max = 6;
		chunk_sz_max = 8;
	   end
	 1:
	   begin
		del_max = 4;
		chunk_sz_max = 4;
	   end
	 2:
	   begin
		del_max = 3;
		chunk_sz_max = 4;
	   end
endcase

mode = 0;
tot_sz = 64;
chunk_sz=4;
del = 0;

m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf, 32'h0);
m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf, 32'h0);

m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);


for(del=0;del<del_max;del=del+1)
for(mode=0;mode<4;mode=mode+1)
for(chunk_sz=1;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
begin
	repeat(50)	@(posedge clk);
	s0.delay = del;
	s1.delay = del;

	s0.fill_mem(1);
	s1.fill_mem(1);

	// Channel 0 Descriptors
	s0.mem[0] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[1] = 32'h0000_0400;
	s0.mem[2] = 32'h0000_0800;
	s0.mem[3] = 32'h0000_0010;

	s0.mem[4] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[5] = 32'h0000_0400 + (tot_sz * 4);
	s0.mem[6] = 32'h0000_0800 + (tot_sz * 4);
	s0.mem[7] = 32'h0000_0020;

	s0.mem[8] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[9] = 32'h0000_0400 + (tot_sz * 4);
	s0.mem[10] = 32'h0000_0800 + (tot_sz * 4);
	s0.mem[11] = 32'h0000_0030;

	s0.mem[12] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[13] = 32'h0000_0400 + (tot_sz * 4);
	s0.mem[14] = 32'h0000_0800 + (tot_sz * 4);
	s0.mem[15] = 32'h0000_0000;

	// Channel 1 Descriptors
	s0.mem[16] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[17] = 32'h0000_0c00;
	s0.mem[18] = 32'h0000_1000;
	s0.mem[19] = 32'h0000_0050;

	s0.mem[20] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[21] = 32'h0000_0c00 + (tot_sz * 4);
	s0.mem[22] = 32'h0000_1000 + (tot_sz * 4);
	s0.mem[23] = 32'h0000_0060;

	s0.mem[24] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[25] = 32'h0000_0c00 + (tot_sz * 4);
	s0.mem[26] = 32'h0000_1000 + (tot_sz * 4);
	s0.mem[27] = 32'h0000_0070;

	s0.mem[28] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[29] = 32'h0000_0c00 + (tot_sz * 4);
	s0.mem[30] = 32'h0000_1000 + (tot_sz * 4);
	s0.mem[31] = 32'h0000_0000;

	// Channel 2 Descriptors
	s0.mem[32] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[33] = 32'h0000_1400;
	s0.mem[34] = 32'h0000_1800;
	s0.mem[35] = 32'h0000_0090;

	s0.mem[36] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[37] = 32'h0000_1400 + (tot_sz * 4);
	s0.mem[38] = 32'h0000_1800 + (tot_sz * 4);
	s0.mem[39] = 32'h0000_00a0;

	s0.mem[40] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[41] = 32'h0000_1400 + (tot_sz * 4);
	s0.mem[42] = 32'h0000_1800 + (tot_sz * 4);
	s0.mem[43] = 32'h0000_00b0;

	s0.mem[44] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[45] = 32'h0000_1400 + (tot_sz * 4);
	s0.mem[46] = 32'h0000_1800 + (tot_sz * 4);
	s0.mem[47] = 32'h0000_0000;

	// Channel 3 Descriptors
	s0.mem[48] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[49] = 32'h0000_1c00;
	s0.mem[50] = 32'h0000_2000;
	s0.mem[51] = 32'h0000_00d0;

	s0.mem[52] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[53] = 32'h0000_1c00 + (tot_sz * 4);
	s0.mem[54] = 32'h0000_2000 + (tot_sz * 4);
	s0.mem[55] = 32'h0000_00e0;

	s0.mem[56] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[57] = 32'h0000_1c00 + (tot_sz * 4);
	s0.mem[58] = 32'h0000_2000 + (tot_sz * 4);
	s0.mem[59] = 32'h0000_00f0;

	s0.mem[60] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz*4;
	s0.mem[61] = 32'h0000_1c00 + (tot_sz * 4);
	s0.mem[62] = 32'h0000_2000 + (tot_sz * 4);
	s0.mem[63] = 32'h0000_0000;


	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `PTR0, 4'hf, 32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
			{12'h0000, 3'b010, 1'b0, 9'h003, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR1, 4'hf, 32'h0000_0040);
	m0.wb_wr1(`REG_BASE + `CH1_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH1_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH1_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
			{12'h0000, 3'b010, 1'b0, 9'h003, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR2, 4'hf, 32'h0000_0080);
	m0.wb_wr1(`REG_BASE + `CH2_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH2_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH2_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf,
			{12'h0000, 3'b010, 1'b0, 9'h003, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR3, 4'hf, 32'h0000_00c0);
	m0.wb_wr1(`REG_BASE + `CH3_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH3_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH3_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf,
			{12'h0000, 3'b010, 1'b0, 9'h003, 4'b0111, 2'b00, 1'b1});


	$write("Total Size: %0d, Delay: %0d ",tot_sz, del);
	case(mode)
	   0: $display("Mode: 0->0, chunk_size: %0d", chunk_sz);
	   1: $display("Mode: 0->1, chunk_size: %0d", chunk_sz);
	   2: $display("Mode: 1->0, chunk_size: %0d", chunk_sz);
	   3: $display("Mode: 1->1, chunk_size: %0d", chunk_sz);
	endcase

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	if(chunk_sz==0)		k = 1;
	else
	   begin
		k = tot_sz/chunk_sz;
		if((k*chunk_sz) != tot_sz)	k = k + 1;
		if((k*chunk_sz) != tot_sz)	odd = 1;
		else				odd = 0;
	   end

	if(chunk_sz==0)		k1 = 4;
	else
	   begin
		k1 = tot_sz/chunk_sz;
		if((k1*chunk_sz) != tot_sz)	k1 = k1 + 1;
		k1 = k1 * 4;
	   end

	k1 = k * 4;
	iz = k;

	fork
	   begin
		repeat(5)	@(posedge clk);
		for(m0=0;m0 < k1+1;m0=m0+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;

			if(m0==iz)	nd_i[0] = 1;
			else
			if(m0==(iz*2))	nd_i[0] = 1;
			else
			if(m0==(iz*3))	nd_i[0] = 1;
			else
			if(m0==(iz*4))	nd_i[0] = 1;
			else		req_i[0] = 1;

			if(nd_i[0]==1)
			   begin
				@(posedge clk);
				#1;
				nd_i[0] = 0;
				repeat(1)	@(posedge clk);
				#1;
				req_i[0] = 1;
			   end

			while(!ack_o[0] & (m0 < k1))	@(posedge clk);
			#1;
			req_i[0] = 0;
			nd_i[0] = 0;
		   end
	   end

	   begin
		repeat(5)	@(posedge clk);
		for(m1=0;m1 < k1;m1=m1+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			if(m1==k-1)	nd_i[1] = 1;
			if(m1==(k*2)-1)	nd_i[1] = 1;
			if(m1==(k*3)-1)	nd_i[1] = 1;
			if(m1==(k*4)-1)	nd_i[1] = 1;
			req_i[1] = 1;
			while(!ack_o[1])	@(posedge clk);
			#1;
			req_i[1] = 0;
			nd_i[1] = 0;
		   end
	   end

	   begin
		repeat(5)	@(posedge clk);
		for(m2=0;m2 < k1+1;m2=m2+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;

			if(m2==k)	nd_i[2] = 1;
			else
			if(m2==(k*2))	nd_i[2] = 1;
			else
			if(m2==(k*3))	nd_i[2] = 1;
			else
			if(m2==(k*4))	nd_i[2] = 1;
			else		req_i[2] = 1;

			if(nd_i[2]==1)
			   begin
				@(posedge clk);
				#1;
				nd_i[2] = 0;
				repeat(1)	@(posedge clk);
				#1;
				req_i[2] = 1;
			   end

			while(!ack_o[2] & (m2 < k1))	@(posedge clk);
			#1;
			req_i[2] = 0;
			nd_i[2] = 0;
		   end
	   end


	   begin
		repeat(5)	@(posedge clk);
		for(m3=0;m3 < k1;m3=m3+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			if(m3==k-1)	nd_i[3] = 1;
			if(m3==(k*2)-1)	nd_i[3] = 1;
			if(m3==(k*3)-1)	nd_i[3] = 1;
			if(m3==(k*4)-1)	nd_i[3] = 1;
			req_i[3] = 1;
			while(!ack_o[3])	@(posedge clk);
			#1;
			req_i[3] = 0;
			nd_i[3] = 0;
		   end
	   end


	   for(i=0;i<4;i=i)
	   begin
		repeat(5)	@(posedge clk);
		while(!inta_o)	@(posedge clk);
		m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);
	
		if(int_src[0])
		   begin
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[1]>>2) + n ];
				else		d0=s0.mem[(s0.mem[1]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[2]>>2) + n ];
				else		d1=s0.mem[(s0.mem[2]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH0: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
			repeat(1)	@(posedge clk);
			d1 = {28'h0064_09b, 1'b1, mode[1:0], 1'b0};
			m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d0);
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH0: CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end
		   end

		if(int_src[1])
		   begin
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[17]>>2) + n ];
				else		d0=s0.mem[(s0.mem[17]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[18]>>2) + n ];
				else		d1=s0.mem[(s0.mem[18]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH1: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
			repeat(1)	@(posedge clk);
			d1 = {28'h0064_09b, 1'b1, mode[1:0], 1'b0};
			m0.wb_rd1(`REG_BASE + `CH1_CSR, 4'hf, d0);
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH1: CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end
			repeat(1)	@(posedge clk);
			case(chunk_sz)
			   default:	d1 = 32'h0000_00c0;
				3:	d1 = 32'h0000_00be;
				5:	d1 = 32'h0000_00bf;
				6:	d1 = 32'h0000_00be;
				7:	d1 = 32'h0000_00ba;
			endcase
			d0 = s0.mem[16];
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH1: DESC_CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end
		   end

		if(int_src[2])
		   begin
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[33]>>2) + n ];
				else		d0=s0.mem[(s0.mem[33]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[34]>>2) + n ];
				else		d1=s0.mem[(s0.mem[34]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH2: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
			repeat(1)	@(posedge clk);
			d1 = {28'h0064_09b, 1'b1, mode[1:0], 1'b0};
			m0.wb_rd1(`REG_BASE + `CH2_CSR, 4'hf, d0);
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH2: CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end
		   end

		if(int_src[3])
		   begin
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[49]>>2) + n ];
				else		d0=s0.mem[(s0.mem[49]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[50]>>2) + n ];
				else		d1=s0.mem[(s0.mem[50]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH3: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
			repeat(1)	@(posedge clk);
			d1 = {28'h0064_09b, 1'b1, mode[1:0], 1'b0};
			m0.wb_rd1(`REG_BASE + `CH3_CSR, 4'hf, d0);
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH3: CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end
			repeat(1)	@(posedge clk);
			case(chunk_sz)
			   default:	d1 = 32'h0000_00c0;
				3:	d1 = 32'h0000_00be;
				5:	d1 = 32'h0000_00bf;
				6:	d1 = 32'h0000_00be;
				7:	d1 = 32'h0000_00ba;
			endcase
			d0 = s0.mem[48];
			repeat(1)	@(posedge clk);
			if( d1 !== d0 )
			   begin
				$display("ERROR: CH3: DESC_CSR Mismatch: Expected: %x, Got: %x (%0t)",
				d1, d0, $time);
				error_cnt = error_cnt + 1;
			   end

		   end

	   end
	join

	// CH0: 528 Acks
	// CH1: 532 Acks
	// CH2: 528 Acks
	// CH3: 532 Acks

	case(chunk_sz)
	   default:	k = 2120;
		3:	k = 2184;
		5:	k = 2152;
		6:	k = 2184;
		7:	k = 2312;
	endcase

	if(ack_cnt != k )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		k, ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end

	repeat(5)	@(posedge clk);

end

s0.delay = 0;
s1.delay = 0;

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end

endtask





task sw_dma1;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max;
reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		n;
reg	[31:0]	d0,d1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SW DMA No Buffer (tx & chunk size test) ...   ***");
$display("*****************************************************\n");

case(quick)
	default:
	   begin
		tot_sz_max = 1024;
		chunk_sz_max = 256;
	   end
	 1:
	   begin
		tot_sz_max = 128;
		chunk_sz_max = 64;
	   end
	 2:
	   begin
		tot_sz_max = 32;
		chunk_sz_max = 4;
	   end
endcase

mode = 1;
tot_sz = 2048;
tot_sz = 16;
chunk_sz=4;

for(mode=0;mode<4;mode=mode+1)
for(tot_sz=1;tot_sz<tot_sz_max;tot_sz=tot_sz+1)
begin

if(tot_sz>64)	tot_sz=tot_sz+4;
if(tot_sz>128)	tot_sz=tot_sz+12;
case(mode)
   0: $display("Mode: 0->0, tot_size: %0d", tot_sz);
   1: $display("Mode: 0->1, tot_size: %0d", tot_sz);
   2: $display("Mode: 1->0, tot_size: %0d", tot_sz);
   3: $display("Mode: 1->1, tot_size: %0d", tot_sz);
endcase

for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
   begin

	if(chunk_sz==17)	chunk_sz=128;
	if(chunk_sz==129)	chunk_sz=255;

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	s0.fill_mem(1);
	s1.fill_mem(1);

	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_4000);
	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
		{12'h0000, 3'b010, 1'b0, 11'h000, 2'b11, mode[1:0], 1'b1});

	repeat(5)	@(posedge clk);
	while(!inta_o)	@(posedge clk);

	m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, d1);
	d0 = 32'h0000_0001;
	if( d1 !== d0 )
	   begin
		$display("ERROR: INT_SRCA Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end

	m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d1);
	d0 = {24'h0064_081, 1'b1, mode[1:0], 1'b0};
	if( d1 !== d0 )
	   begin
		$display("ERROR: CH0_CSR Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end

	for(n=0;n<tot_sz;n=n+1)
	   begin
		if(mode[1])	d0=s1.mem[ n ];
		else		d0=s0.mem[ n ];
		if(mode[0])	d1=s1.mem[32'h0000_1000 + n ];
		else		d1=s0.mem[32'h0000_1000 + n ];

		if( d1 !== d0 )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, d0, d1, $time);
			error_cnt = error_cnt + 1;
		   end
	   end

	if(ack_cnt != ((tot_sz*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*2)), ack_cnt, $time);
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



task sw_dma2;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max, max_del;

reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		n;
reg	[31:0]	d0,d1;
integer		del0, del1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** SW DMA No Buffer (slave delay slide) ...      ***");
$display("*****************************************************\n");

case(quick)
	default:
	   begin
		max_del =  6;
		tot_sz_max = 256;
		chunk_sz_max = 16;
	   end
	 1:
	   begin
		max_del =  4;
		tot_sz_max = 128;
		chunk_sz_max = 8;
	   end
	 2:
	   begin
		max_del =  2;
		tot_sz_max = 32;
		chunk_sz_max = 4;
	   end
endcase

mode = 0;
tot_sz = 2048;
tot_sz = 16;
chunk_sz=4;

for(del0=0;del0<max_del;del0=del0+1)
for(del1=0;del1<max_del;del1=del1+1)
for(mode=0;mode<4;mode=mode+1)
for(tot_sz=1;tot_sz<tot_sz_max;tot_sz=tot_sz+4)
begin

if(del0==5)	del0=8;
if(del1==5)	del1=8;

if(tot_sz>128)			tot_sz=tot_sz+4;

$write("Slv 0 delay: %0d, Slv 1 Delay: %0d - ",del0, del1);
case(mode)
   0: $display("Mode: 0->0, tot_size: %0d", tot_sz);
   1: $display("Mode: 0->1, tot_size: %0d", tot_sz);
   2: $display("Mode: 1->0, tot_size: %0d", tot_sz);
   3: $display("Mode: 1->1, tot_size: %0d", tot_sz);
endcase

for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)

   begin

	if(quick & (chunk_sz > 4))	chunk_sz = chunk_sz + 1;

	s0.delay = del0;
	s1.delay = del1;

	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	s0.fill_mem(1);
	s1.fill_mem(1);
	m0.wb_wr1(`REG_BASE + `INT_MASKB,4'hf,32'hffff_ffff);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, tot_sz});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_4000);
	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
		{12'h0000, 3'b010, 1'b0, 11'h000, 2'b11, mode[1:0], 1'b1});

	repeat(5)	@(posedge clk);
	while(!intb_o)	@(posedge clk);

	m0.wb_rd1(`REG_BASE + `INT_SRCB, 4'hf, d1);
	d0 = 32'h0000_0001;
	if( d1 !== d0 )
	   begin
		$display("ERROR: INT_SRC Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end

	m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d1);
	d0 = {24'h0064_081, 1'b1, mode[1:0], 1'b0};
	if( d1 !== d0 )
	   begin
		$display("ERROR: CH0_CSR Mismatch: Expected: %x, Got: %x (%0t)",
			d0, d1, $time);
		error_cnt = error_cnt + 1;
	   end

	for(n=0;n<tot_sz;n=n+1)
	   begin
		if(mode[1])	d0=s1.mem[ n ];
		else		d0=s0.mem[ n ];
		if(mode[0])	d1=s1.mem[32'h0000_1000 + n ];
		else		d1=s0.mem[32'h0000_1000 + n ];

		if( d1 !== d0 )
		   begin
			$display("ERROR: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
			n, d0, d1, $time);
			error_cnt = error_cnt + 1;
		   end
	   end


	if(ack_cnt != ((tot_sz*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*2)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end


   end
end

s0.delay = 0;
s1.delay = 0;

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask



task pt10_rd;

// Misc Variables
reg	[31:0]	d0,d1,d2,d3;
integer		d,n;

begin
$display("\n");
$display("*****************************************************");
$display("*** Running Path Through 1->0 Read Test ....      ***");
$display("*****************************************************\n");

s0.fill_mem(1);
s1.fill_mem(1);
d=0;
n=16;

for(d=0;d<16;d=d+1)
 begin
   $display("INFO: PT10 RD4, delay %0d",d);
   for(n=0;n<512;n=n+4)
     begin
	m0.wb_rd4(n<<2,4'hf,d,d0,d1,d2,d3);

	if( (s1.mem[n+0] !== d0) | (s1.mem[n+1] !== d1) |
		(s1.mem[n+2] !== d2) | (s1.mem[n+3] !== d3) )
	   begin
		$display("ERROR: Memory Read Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s1.mem[n+0], d0);
		$display("D1: Expected: %x, Got %x", s1.mem[n+1], d1);
		$display("D2: Expected: %x, Got %x", s1.mem[n+2], d2);
		$display("D3: Expected: %x, Got %x", s1.mem[n+3], d3);
		error_cnt = error_cnt + 1;
	   end
      end
 end


$display("\nINFO: PT10 RD1");
   for(n=0;n<512;n=n+1)
     begin
	m0.wb_rd1(n<<2,4'hf,d0);

	if( s1.mem[n] !== d0 )
	   begin
		$display("ERROR: Memory Read Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s1.mem[n], d0);
		error_cnt = error_cnt + 1;
	   end
      end


show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n");
end
endtask


task pt01_rd;

// Misc Variables
reg	[31:0]	d0,d1,d2,d3;
integer		d,n;

begin
$display("\n");
$display("*****************************************************");
$display("*** Running Path Through 0->1 Read Test ....      ***");
$display("*****************************************************\n");

s0.fill_mem(1);
s1.fill_mem(1);

d=1;
n=0;
for(d=0;d<16;d=d+1)
 begin
   $display("INFO: PT01 RD4, delay %0d",d);
   for(n=0;n<512;n=n+4)
     begin
	m1.wb_rd4(n<<2,4'hf,d,d0,d1,d2,d3);
	@(posedge clk);

	if( (s0.mem[n+0] !== d0) | (s0.mem[n+1] !== d1) |
		(s0.mem[n+2] !== d2) | (s0.mem[n+3] !== d3) )
	   begin
		$display("ERROR: Memory Read Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s0.mem[n+0], d0);
		$display("D1: Expected: %x, Got %x", s0.mem[n+1], d1);
		$display("D2: Expected: %x, Got %x", s0.mem[n+2], d2);
		$display("D3: Expected: %x, Got %x", s0.mem[n+3], d3);
		error_cnt = error_cnt + 1;
	   end
      end
 end

$display("\nINFO: PT01 RD1");
   for(n=0;n<512;n=n+1)
     begin
	m1.wb_rd1(n<<2,4'hf,d0);

	if( s0.mem[n+0] !== d0 )
	   begin
		$display("ERROR: Memory Read Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s0.mem[n+0], d0);
		error_cnt = error_cnt + 1;
	   end
      end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n");
end
endtask




task pt10_wr;

// Misc Variables
reg	[31:0]	d0,d1,d2,d3;
integer		d,n;

begin

$display("\n");
$display("*****************************************************");
$display("*** Running Path Through 1->0 Write Test ....     ***");
$display("*****************************************************\n");


s0.fill_mem(1);
s1.fill_mem(1);
d=1;
n=0;
for(d=0;d<16;d=d+1)
 begin
   $display("INFO: PT10 WR4, delay %0d",d);
   for(n=0;n<512;n=n+4)
     begin

	d0 = $random;
	d1 = $random;
	d2 = $random;
	d3 = $random;
	m0.wb_wr4(n<<2,4'hf,d,d0,d1,d2,d3);
	@(posedge clk);

	if( (s1.mem[n+0] !== d0) | (s1.mem[n+1] !== d1) |
		(s1.mem[n+2] !== d2) | (s1.mem[n+3] !== d3) )
	   begin
		$display("ERROR: Memory Write Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s1.mem[n+0], d0);
		$display("D1: Expected: %x, Got %x", s1.mem[n+1], d1);
		$display("D2: Expected: %x, Got %x", s1.mem[n+2], d2);
		$display("D3: Expected: %x, Got %x", s1.mem[n+3], d3);
		error_cnt = error_cnt + 1;
	   end
      end
 end

$display("\nINFO: PT10 WR1");
   for(n=0;n<512;n=n+1)
     begin
	d0 = $random;
	m0.wb_wr1(n<<2,4'hf,d0);
	@(posedge clk);

	if( s1.mem[n+0] !== d0 )
	   begin
		$display("ERROR: Memory Write Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s1.mem[n+0], d0);
		error_cnt = error_cnt + 1;
	   end
      end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n");
end
endtask



task pt01_wr;

// Misc Variables
reg	[31:0]	d0,d1,d2,d3;
integer		d,n;

begin

$display("\n");
$display("*****************************************************");
$display("*** Running Path Through 0->1 Write Test ....     ***");
$display("*****************************************************\n");


s0.fill_mem(1);
s1.fill_mem(1);

d=1;
n=0;
for(d=0;d<16;d=d+1)
 begin
   $display("INFO: PT01 WR4, delay %0d",d);
   for(n=0;n<512;n=n+4)
     begin

	d0 = $random;
	d1 = $random;
	d2 = $random;
	d3 = $random;
	m1.wb_wr4(n<<2,4'hf,d,d0,d1,d2,d3);
	@(posedge clk);

	if( (s0.mem[n+0] !== d0) | (s0.mem[n+1] !== d1) |
		(s0.mem[n+2] !== d2) | (s0.mem[n+3] !== d3) )
	   begin
		$display("ERROR: Memory Write Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s0.mem[n+0], d0);
		$display("D1: Expected: %x, Got %x", s0.mem[n+1], d1);
		$display("D2: Expected: %x, Got %x", s0.mem[n+2], d2);
		$display("D3: Expected: %x, Got %x", s0.mem[n+3], d3);
		error_cnt = error_cnt + 1;
	   end
      end
 end

   $display("\nINFO: PT01 WR1");
   for(n=0;n<512;n=n+1)
     begin
	d0 = $random;
	m1.wb_wr1(n<<2,4'hf,d0);
	@(posedge clk);

	if( s0.mem[n+0] !== d0 )
	   begin
		$display("ERROR: Memory Write Data (%0d) Mismatch: (%0t)",n,$time);
		$display("D0: Expected: %x, Got %x", s0.mem[n+0], d0);
		error_cnt = error_cnt + 1;
	   end
      end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n");
end
endtask







task show_errors;

begin

$display("\n");
$display("     +--------------------+");
$display("     |  Total ERRORS: %0d   |", error_cnt);
$display("     +--------------------+");

end
endtask



task hw_dma4;
input		quick;

integer		quick, tot_sz_max, chunk_sz_max, del_max;

reg	[7:0]	mode;
reg	[15:0]	chunk_sz, tot_sz;
integer		i, n,m0, m1, m2, m3, k,rep,del;
reg	[31:0]	int_src, d0,d1;
reg		do_rest;
integer		rest_del;
integer		rest_del_t;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** HW DMA No Buffer Ext Descr. REST Test ...     ***");
$display("*****************************************************\n");

case(quick)
	default:
	   begin
		del_max = 6;
		tot_sz_max = 200;
		chunk_sz_max = 8;
	   end
	 1:
	   begin
		del_max = 4;
		tot_sz_max = 128;
		chunk_sz_max = 4;
	   end
	 2:
	   begin
		del_max = 3;
		tot_sz_max = 32;
		chunk_sz_max = 4;
	   end
endcase

mode = 1;
tot_sz = 32;
chunk_sz=7;
del = 0;
do_rest = 1;
rest_del = 7;

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf, 32'h0);
	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf, 32'h0);

	m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);

for(tot_sz=1;tot_sz<tot_sz_max;tot_sz=tot_sz+1)
begin

if(tot_sz>4)	tot_sz = tot_sz + 4;
if(tot_sz>16)	tot_sz = tot_sz + 12;
if(tot_sz>64)	tot_sz = tot_sz + 48;

for(del=0;del<del_max;del=del+1)
//for(mode=0;mode<4;mode=mode+1)
//for(chunk_sz=0;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)

for(rest_del=0;rest_del<16;rest_del=rest_del + 1)
for(chunk_sz=1;chunk_sz<chunk_sz_max;chunk_sz=chunk_sz+1)
begin
do_rest = 1;
	s0.delay = del;
	s1.delay = del;

	s0.fill_mem(1);
	s1.fill_mem(1);

	s0.mem[0] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[1] = 32'h0000_0100;
	s0.mem[2] = 32'h0000_0900;
	s0.mem[3] = 32'h0000_0010;

	s0.mem[4] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[5] = 32'h0000_0100 + (tot_sz * 4);
	s0.mem[6] = 32'h0000_0900 + (tot_sz * 4);
	s0.mem[7] = 32'h0000_0000;

	s0.mem[8] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[9] = 32'h0000_1100;
	s0.mem[10] = 32'h0000_1900;
	s0.mem[11] = 32'h0000_0030;

	s0.mem[12] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[13] = 32'h0000_1100 + (tot_sz * 4);
	s0.mem[14] = 32'h0000_1900 + (tot_sz * 4);
	s0.mem[15] = 32'h0000_0000;

	s0.mem[16] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[17] = 32'h0000_2100;
	s0.mem[18] = 32'h0000_2900;
	s0.mem[19] = 32'h0000_0050;

	s0.mem[20] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[21] = 32'h0000_2100 + (tot_sz * 4);
	s0.mem[22] = 32'h0000_2900 + (tot_sz * 4);
	s0.mem[23] = 32'h0000_0000;

	s0.mem[24] = (32'h000c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[25] = 32'h0000_3100;
	s0.mem[26] = 32'h0000_3900;
	s0.mem[27] = 32'h0000_0070;

	s0.mem[28] = (32'h001c_0000 | (mode[1:0]<<16)) + tot_sz;
	s0.mem[29] = 32'h0000_3100 + (tot_sz * 4);
	s0.mem[30] = 32'h0000_3900 + (tot_sz * 4);
	s0.mem[31] = 32'h0000_0000;

	m0.wb_wr1(`REG_BASE + `INT_MASKA,4'hf,32'hffff_ffff);

	m0.wb_wr1(`REG_BASE + `PTR0, 4'hf, 32'h0000_0000);
	m0.wb_wr1(`REG_BASE + `CH0_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH0_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH0_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH0_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b1, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR1, 4'hf, 32'h0000_0020);
	m0.wb_wr1(`REG_BASE + `CH1_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH1_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH1_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH1_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b1, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR2, 4'hf, 32'h0000_0040);
	m0.wb_wr1(`REG_BASE + `CH2_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH2_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH2_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH2_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b1, 9'h001, 4'b0111, 2'b00, 1'b1});

	m0.wb_wr1(`REG_BASE + `PTR3, 4'hf, 32'h0000_0060);
	m0.wb_wr1(`REG_BASE + `CH3_TXSZ,4'hf, {chunk_sz, 16'h0fff});
	m0.wb_wr1(`REG_BASE + `CH3_ADR0,4'hf,32'h0000_ffff);
	m0.wb_wr1(`REG_BASE + `CH3_ADR1,4'hf,32'h0000_ffff);

	m0.wb_wr1(`REG_BASE + `CH3_CSR,4'hf,
			//{25'h0000001, 4'b0111, 2'b00, 1'b1});
			{12'h0000, 3'b010, 1'b1, 9'h001, 4'b0111, 2'b00, 1'b1});


	ack_cnt_clr = 1;
	@(posedge clk);
	ack_cnt_clr = 0;

	if(chunk_sz==0)		k = 1;
	else
	   begin
		k = tot_sz/chunk_sz;
		if((k*chunk_sz) != tot_sz)	k = k + 1;
	   end

//$display("rest_del: %0d, k: %0d", rest_del, k);

	if(rest_del >= k)	rest_del_t = k - 1;
	else			rest_del_t = rest_del;

	k = k * 2;


	$write("Total Size: %0d, Delay: %0d REST_del: %0d ",tot_sz, del, rest_del_t);
	case(mode)
	   0: $display("Mode: 0->0, chunk_size: %0d", chunk_sz);
	   1: $display("Mode: 0->1, chunk_size: %0d", chunk_sz);
	   2: $display("Mode: 1->0, chunk_size: %0d", chunk_sz);
	   3: $display("Mode: 1->1, chunk_size: %0d", chunk_sz);
	endcase



//$display("k=%0d",k);

	fork
	   begin	// Hardware Handshake Channel 0
		repeat(5)	@(posedge clk);
		for(m0=0;m0 < k;m0=m0+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[0] = 1;
			while(!ack_o[0])	@(posedge clk);
			#1;
			req_i[0] = 0;
		   end
	   end

	   begin	// Hardware Handshake Channel 1
		repeat(5)	@(posedge clk);
		for(m1=0;m1 < (k + rest_del_t + 1);m1=m1+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[1] = 1;
			while(!ack_o[1])	@(posedge clk);
			#1;
			req_i[1] = 0;
//$display("m1=%0d",m1);
			if( (do_rest==1) & (m1==rest_del_t) )
			//if( do_rest==1 )
			   begin
//$display("Asserting Restart ...");
				@(posedge clk);
				#1;
				rest_i[1] = 1;
				@(posedge clk);
				#1;
				rest_i[1] = 0;
				do_rest = 0;
				@(posedge clk);
				@(posedge clk);
			   end

		   end
	   end

	   begin	// Hardware Handshake Channel 2
		repeat(5)	@(posedge clk);
		for(m2=0;m2 < k;m2=m2+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[2] = 1;
			while(!ack_o[2])	@(posedge clk);
			#1;
			req_i[2] = 0;
		   end
	   end

	   begin	// Hardware Handshake Channel 3
		repeat(5)	@(posedge clk);
		for(m3=0;m3 < k;m3=m3+1)
		   begin
			repeat(del)	@(posedge clk);
			#1;
			req_i[3] = 1;
			while(!ack_o[3])	@(posedge clk);
			#1;
			req_i[3] = 0;
		   end
	   end

	   for(i=0;i<4;i=i)
	   begin
		repeat(5)	@(posedge clk);
		while(!inta_o)	@(posedge clk);
		m0.wb_rd1(`REG_BASE + `INT_SRCA, 4'hf, int_src);
	
		if(int_src[0])
		   begin
			m0.wb_rd1(`REG_BASE + `CH0_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[1]>>2) + n ];
				else		d0=s0.mem[(s0.mem[1]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[2]>>2) + n ];
				else		d1=s0.mem[(s0.mem[2]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH0: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[1])
		   begin
			m0.wb_rd1(`REG_BASE + `CH1_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[9]>>2) + n ];
				else		d0=s0.mem[(s0.mem[9]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[10]>>2) + n ];
				else		d1=s0.mem[(s0.mem[10]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH1: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[2])
		   begin
			m0.wb_rd1(`REG_BASE + `CH2_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[17]>>2) + n ];
				else		d0=s0.mem[(s0.mem[17]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[18]>>2) + n ];
				else		d1=s0.mem[(s0.mem[18]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH2: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

		if(int_src[3])
		   begin
			m0.wb_rd1(`REG_BASE + `CH3_CSR, 4'hf, d0);
			i=i+1;
			for(n=0;n<tot_sz*2;n=n+1)
			   begin
				if(mode[1])	d0=s1.mem[(s0.mem[25]>>2) + n ];
				else		d0=s0.mem[(s0.mem[25]>>2) + n ];
				if(mode[0])	d1=s1.mem[(s0.mem[26]>>2) + n ];
				else		d1=s0.mem[(s0.mem[26]>>2) + n ];
			
				if( d1 !== d0 )
				   begin
					$display("ERROR: CH3: Data[%0d] Mismatch: Expected: %x, Got: %x (%0t)",
					n, d0, d1, $time);
					error_cnt = error_cnt + 1;
				   end
			   end
		   end

	   end

	join


/*
	if(ack_cnt != ((tot_sz*2*4*2)+(4*4*2)) )
	   begin
		$display("ERROR: ACK count Mismatch: Expected: %0d, Got: %0d (%0t)",
		((tot_sz*2*4*2)+(4*4*2)), ack_cnt, $time);
		error_cnt = error_cnt + 1;
	   end
*/

	repeat(5)	@(posedge clk);

end
end

	s0.delay = 0;
	s1.delay = 0;

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end

endtask




