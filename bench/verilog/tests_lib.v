/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Test Bench Library                                         ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_funct/////
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
//  $Id: tests_lib.v,v 1.1 2002-09-25 06:10:10 rudi Exp $
//
//  $Date: 2002-09-25 06:10:10 $
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

task recv_packet;
output	[3:0]	pid;
output		size;

integer		del, size,n;
reg	[15:0]	crc16r;
reg	[7:0]	x,y;

begin
crc16r = 16'hffff;
utmi_recv_pack(size);
for(n=1;n<size-2;n=n+1)
   begin
	y = txmem[n];
	x[7] = y[0];
	x[6] = y[1];
	x[5] = y[2];
	x[4] = y[3];
	x[3] = y[4];
	x[2] = y[5];
	x[1] = y[6];
	x[0] = y[7];
	crc16r = crc16(crc16r, x);
   end

y = crc16r[15:8];
x[7] = y[0];
x[6] = y[1];
x[5] = y[2];
x[4] = y[3];
x[3] = y[4];
x[2] = y[5];
x[1] = y[6];
x[0] = y[7];
crc16r[15:8] = ~x;

y = crc16r[7:0];
x[7] = y[0];
x[6] = y[1];
x[5] = y[2];
x[4] = y[3];
x[3] = y[4];
x[2] = y[5];
x[1] = y[6];
x[0] = y[7];
crc16r[7:0] = ~x;

if(crc16r !== {txmem[n], txmem[n+1]})
$display("ERROR: CRC Mismatch: Expected: %h, Got: %h%h (%t)",
		crc16r, txmem[n], txmem[n+1], $time);

for(n=0;n<size-3;n=n+1)
	buffer1[buffer1_last+n] = txmem[n+1];
buffer1_last = buffer1_last+n;

// Check PID
x = txmem[0];

if(x[7:4] !== ~x[3:0])
$display("ERROR: Pid Checksum mismatch: Top: %h Bottom: %h (%t)",
		x[7:4], x[3:0], $time);
pid = x[3:0];
size=size-3;
end
endtask



task send_token;
input	[6:0]	fa;
input	[3:0]	ep;
input	[3:0]	pid;

reg	[15:0]	tmp_data;
reg	[10:0]	x,y;
integer		len;

begin

tmp_data = {fa, ep, 5'h0};
if(pid == `USBF_T_PID_ACK)	len = 1;
else				len = 3;

y = {fa, ep};
x[10] = y[4];
x[9] = y[5];
x[8] = y[6];
x[7] = y[7];
x[6] = y[8];
x[5] = y[9];
x[4] = y[10];
x[3] = y[0];
x[2] = y[1];
x[1] = y[2];
x[0] = y[3];

y[4:0]  = crc5( 5'h1f, x );
tmp_data[4:0]  = ~y[4:0];
tmp_data[15:5] = x;
txmem[0] = {~pid, pid};	// PID
txmem[1] = {	tmp_data[8],tmp_data[9],tmp_data[10],tmp_data[11],
		tmp_data[12],tmp_data[13],tmp_data[14],tmp_data[15]};
txmem[2] = {	tmp_data[0],tmp_data[1],tmp_data[2],tmp_data[3],
		tmp_data[4],tmp_data[5],tmp_data[6],tmp_data[7]};
utmi_send_pack(len);
end
endtask


task send_sof;
input	[10:0]	frmn;

reg	[15:0]	tmp_data;
reg	[10:0]	x,y;
begin

y = frmn;
x[10] = y[0];
x[9] = y[1];
x[8] = y[2];
x[7] = y[3];
x[6] = y[4];
x[5] = y[5];
x[4] = y[6];
x[3] = y[7];
x[2] = y[8];
x[1] = y[9];
x[0] = y[10];

tmp_data[15:5] = x;
y[4:0]  = crc5( 5'h1f, x );
tmp_data[4:0]  = ~y[4:0];
txmem[0] = {~`USBF_T_PID_SOF, `USBF_T_PID_SOF};	// PID
txmem[1] = {	tmp_data[8],tmp_data[9],tmp_data[10],tmp_data[11],
		tmp_data[12],tmp_data[13],tmp_data[14],tmp_data[15]};
txmem[2] = {	tmp_data[0],tmp_data[1],tmp_data[2],tmp_data[3],
		tmp_data[4],tmp_data[5],tmp_data[6],tmp_data[7]};
txmem[1] = 	frmn[7:0];
txmem[2] = {	tmp_data[0],tmp_data[1],tmp_data[2],tmp_data[3],
		tmp_data[4], frmn[10:8] };
utmi_send_pack(3);
end
endtask


function [4:0] crc5;
input	[4:0]	crc_in;
input	[10:0]	din;
reg	[4:0]	crc_out;

begin

crc5[0] =	din[10] ^ din[9] ^ din[6] ^ din[5] ^ din[3] ^
		din[0] ^ crc_in[0] ^ crc_in[3] ^ crc_in[4];
crc5[1] =	din[10] ^ din[7] ^ din[6] ^ din[4] ^ din[1] ^
		crc_in[0] ^ crc_in[1] ^ crc_in[4];
crc5[2] =	din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[6] ^
		din[3] ^ din[2] ^ din[0] ^ crc_in[0] ^ crc_in[1] ^
		crc_in[2] ^ crc_in[3] ^ crc_in[4];
crc5[3] =	din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[4] ^ din[3] ^
		din[1] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4];
crc5[4] =	din[10] ^ din[9] ^ din[8] ^ din[5] ^ din[4] ^ din[2] ^
		crc_in[2] ^ crc_in[3] ^ crc_in[4];
end
endfunction


task send_data;
input	[3:0]	pid;
input		len;
input		mode;
integer		n, len, mode, delay;
reg	[15:0]	crc16r;
reg	[7:0]	x,y;

begin
txmem[0] = {~pid, pid};	// PID
crc16r = 16'hffff;
for(n=0;n<len;n=n+1)
   begin
	if(mode==1)	y = buffer1[buffer1_last+n];
	else		y = n;
	x[7] = y[0];
	x[6] = y[1];
	x[5] = y[2];
	x[4] = y[3];
	x[3] = y[4];
	x[2] = y[5];
	x[1] = y[6];
	x[0] = y[7];
	txmem[n+1] = y;
	crc16r = crc16(crc16r, x);
   end

buffer1_last = buffer1_last + n;
y = crc16r[15:8];
x[7] = y[0];
x[6] = y[1];
x[5] = y[2];
x[4] = y[3];
x[3] = y[4];
x[2] = y[5];
x[1] = y[6];
x[0] = y[7];
txmem[n+1] = ~x;

y = crc16r[7:0];
x[7] = y[0];
x[6] = y[1];
x[5] = y[2];
x[4] = y[3];
x[3] = y[4];
x[2] = y[5];
x[1] = y[6];
x[0] = y[7];
txmem[n+2] = ~x;
utmi_send_pack(len+3);
end
endtask


function [15:0] crc16;
input	[15:0]	crc_in;
input	[7:0]	din;
reg	[15:0]	crc_out;

begin
crc_out[0] =	din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^
		din[2] ^ din[1] ^ din[0] ^ crc_in[8] ^ crc_in[9] ^
		crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^
		crc_in[14] ^ crc_in[15];
crc_out[1] =	din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^
		din[1] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^
		crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15];
crc_out[2] =	din[1] ^ din[0] ^ crc_in[8] ^ crc_in[9];
crc_out[3] =	din[2] ^ din[1] ^ crc_in[9] ^ crc_in[10];
crc_out[4] =	din[3] ^ din[2] ^ crc_in[10] ^ crc_in[11];
crc_out[5] =	din[4] ^ din[3] ^ crc_in[11] ^ crc_in[12];
crc_out[6] =	din[5] ^ din[4] ^ crc_in[12] ^ crc_in[13];
crc_out[7] =	din[6] ^ din[5] ^ crc_in[13] ^ crc_in[14];
crc_out[8] =	din[7] ^ din[6] ^ crc_in[0] ^ crc_in[14] ^ crc_in[15];
crc_out[9] =	din[7] ^ crc_in[1] ^ crc_in[15];
crc_out[10] =	crc_in[2];
crc_out[11] =	crc_in[3];
crc_out[12] =	crc_in[4];
crc_out[13] =	crc_in[5];
crc_out[14] =	crc_in[6];
crc_out[15] =	din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^
		din[1] ^ din[0] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^
		crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^
		crc_in[14] ^ crc_in[15];
crc16 = crc_out;
end
endfunction

///////////////////////////////////////////////////////////////////
//
// UTMI Low level Tasks
//

task utmi_send_pack;
input	size;
integer n,size;

begin
@(posedge clk);
#1;
tb_tx_valid = 1'b1;
for(n=0;n<size;n=n+1)
   begin
	tb_txdata = txmem[n];
	@(posedge clk);
	#2;
	while(!tb_tx_ready)	@(posedge clk);
	#1;
   end
tb_tx_valid = 1'b0;
@(posedge clk);
end
endtask

task utmi_recv_pack;
output	size;
integer	size;

begin
size = 0;
while(!tb_rx_active)	@(posedge clk);
while(tb_rx_active)
   begin
	#1;
	while(!tb_rx_valid & tb_rx_active)	@(posedge clk);
	
	if(tb_rx_valid & tb_rx_active)
	   begin
		txmem[size] = tb_rxdata;
		size = size + 1;
	   end
	@(posedge clk);
   end
end
endtask

