/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Top Level Test Bench                                       ////
////  Task Library                                               ////
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
//  $Id: test_lib.v,v 1.4 2002-01-21 13:10:37 rudi Exp $
//
//  $Date: 2002-01-21 13:10:37 $
//  $Revision: 1.4 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2001/11/11 01:52:03  rudi
//
//               Minor fixes to testbench ...
//
//               Revision 1.2  2001/09/02 02:29:43  rudi
//
//               Fixed the TMS register setup to be tight and correct.
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


/////////////////////////////////////////////////////////////////////
//
// Bandwidth Monitor
//

always @(posedge clk)
	if(wb_cyc_i)	cyc_cnt = cyc_cnt + 1;

always @(posedge clk)
	if(wb_ack_o)	ack_cnt = ack_cnt + 1;

task bw_report;

integer	bytes;

begin

bytes = ack_cnt * 4;
$display("Last WB Bandwidth: %0d Mbytes/sec", bytes * 1000/(cyc_cnt * 10));
end
endtask

task bw_clear;

begin
cyc_cnt = 0;
ack_cnt = 0;
end
endtask

/////////////////////////////////////////////////////////////////////
//
// Suspend Resume Task
//

task susp_res;
begin

	#1;
	susp_req = 1;
	while(!suspended)	@(posedge clk);
	#1;
	susp_req = 0;
	repeat(20)		@(posedge clk);
	#1;
	resume_req = 1;
	while(suspended)	@(posedge clk);
	#1;
	resume_req = 0;
	repeat(1)		@(posedge clk);

end
endtask

/////////////////////////////////////////////////////////////////////
//
// Bus Request/Grant Task
//
task bus_req;
begin
	mc_br = 1;
	while(!mc_bg)	@(posedge clk);
	repeat(40)	@(posedge clk);
	mc_br = 0;
	repeat(2)	@(posedge clk);
end
endtask

/////////////////////////////////////////////////////////////////////
//
// Monitor CKE
//
time	cke_low;

always @(negedge mc_cke_)
	cke_low = $time;

always @(posedge mc_cke_)
	if(($time-cke_low) < 10)
	$display("WARNING: Cke low period was %t. (%t, %t)",($time-cke_low), cke_low, $time);

/////////////////////////////////////////////////////////////////////
//
// Monitor wb_err_o
//
always @(posedge clk)
	if(wb_err_o & !wb_err_check_dis)
		$display("WARNING: WB_ERR_O was asserted at time %0t",$time);

/////////////////////////////////////////////////////////////////////
//
// Watchdog Counter
//

always @(wb_ack_o or wb_stb_i)
	wd_cnt = 0;

always @(posedge clk)
	wd_cnt = wd_cnt + 1;

always @(wd_cnt)
	if(wd_cnt>6000)
	   begin
		$display("\n\n*************************************\n");
		$display("ERROR: Watch Dog Counter Expired\n");
		$display("*************************************\n\n\n");
		$finish;
	   end

/////////////////////////////////////////////////////////////////////
//
// Show Errors
//

task show_errors;

begin

$display("\n");
$display("     +--------------------+");
$display("     |  Total ERRORS: %0d   |", error_cnt);
$display("     +--------------------+");

end
endtask

/////////////////////////////////////////////////////////////////////
//
// Reset Memory Controller
//

task mc_reset;

begin
repeat(10)	@(posedge clk);
rst = 1;
repeat(10)	@(posedge clk);
rst = 0;
repeat(20)	@(posedge clk);
end
endtask

/////////////////////////////////////////////////////////////////////
//
// Fill SDRAMs
//

task fill_mem;
input	size;

integer		size, n;
reg	[31:0]	data;

begin
sdram0.mem_fill(size);

for(n=0;n<size;n=n+1)
   begin
	data = sdram0.Bank0[n];
	sdram0p.Bank0[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram0.Bank1[n];
	sdram0p.Bank1[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram0.Bank2[n];
	sdram0p.Bank2[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram0.Bank3[n];
	sdram0p.Bank3[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
   end

end
endtask


task fill_mem1;
input	size;

integer		size, n;
reg	[31:0]	data;

begin
sdram1.mem_fill(size);

for(n=0;n<size;n=n+1)
   begin
	data = sdram1.Bank0[n];
	sdram1p.Bank0[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram1.Bank1[n];
	sdram1p.Bank1[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram1.Bank2[n];
	sdram1p.Bank2[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram1.Bank3[n];
	sdram1p.Bank3[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
   end

end
endtask

task fill_mem2;
input	size;

integer		size, n;
reg	[31:0]	data;

begin
sdram2.mem_fill(size);

for(n=0;n<size;n=n+1)
   begin
	data = sdram2.Bank0[n];
	sdram2p.Bank0[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram2.Bank1[n];
	sdram2p.Bank1[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram2.Bank2[n];
	sdram2p.Bank2[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
	data = sdram2.Bank3[n];
	sdram2p.Bank3[n] = {28'h0, ^data[31:24], ^data[23:16], ^data[15:8], ^data[7:0] };
   end

end
endtask


