/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Test Case Collection                                       ////
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
//  $Id: tests.v,v 1.1 2002-09-25 06:10:10 rudi Exp $
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


task send_setup;
input	[7:0]	fa;
input	[7:0]	req_type;
input	[7:0]	request;
input	[15:0]	wValue;
input	[15:0]	wIndex;
input	[15:0]	wLength;

integer		len;
begin

buffer1[0] = req_type;
buffer1[1] = request;
buffer1[3] = wValue[15:8];
buffer1[2] = wValue[7:0];
buffer1[5] = wIndex[15:8];
buffer1[4] = wIndex[7:0];
buffer1[7] = wLength[15:8];
buffer1[6] = wLength[7:0];

buffer1_last = 0;
send_token(	fa,			// Function Address
		0,			// Logical Endpoint Number
		`USBF_T_PID_SETUP	// PID
		);

repeat(1)	@(posedge clk);

send_data(`USBF_T_PID_DATA0, 8, 1);

// Wait for ACK
utmi_recv_pack(len);

if(8'hd2 !== txmem[0])
   begin
	$display("ERROR: SETUP: ACK mismatch. Expected: %h, Got: %h (%t)",
	8'hd2, txmem[0], $time);
	error_cnt = error_cnt + 1;
   end

if(len !== 1)
   begin
	$display("ERROR: SETUP: Length mismatch. Expected: %h, Got: %h (%t)",
	8'h1, len, $time);
	error_cnt = error_cnt + 1;
   end

repeat(1)	@(posedge clk);
setup_pid = 1;
repeat(1)	@(posedge clk);
end

endtask



task data_in;
input	[7:0]	fa;
input	[7:0]	pl_size;

integer		rlen;
reg	[3:0]	pid, expect_pid;
begin

	buffer1_last = 0;
	repeat(5)	@(posedge clk);
	send_token(	fa,		// Function Address
			0,		// Logical Endpoint Number
			`USBF_T_PID_IN	// PID
			);

	recv_packet(pid,rlen);
	if(setup_pid)	expect_pid = 4'hb; // DATA 1
	else		expect_pid = 4'h3; // DATA 0

	if(pid !== expect_pid)
	   begin
		$display("ERROR: Data IN PID mismatch. Expected: %h, Got: %h (%t)",
			expect_pid, pid, $time);
		error_cnt = error_cnt + 1;
	   end

	setup_pid = ~setup_pid;
	if(rlen != pl_size)
	   begin
		$display("ERROR: Data IN Size mismatch. Expected: %d, Got: %d (%t)",
			pl_size, rlen, $time);
		error_cnt = error_cnt + 1;
	   end

	for(n=0;n<rlen;n=n+1)
		$display("RCV Data[%0d]: %h",n,buffer1[n]);

	repeat(5)	@(posedge clk);
	send_token(	fa,		// Function Address
			0,		// Logical Endpoint Number
			`USBF_T_PID_ACK	// PID
			);

	repeat(5)	@(posedge clk);

end
endtask



task data_out;
input	[7:0]	fa;
input	[7:0]	pl_size;

integer len;

begin
	send_token(	fa,		// Function Address
			0,		// Logical Endpoint Number
			`USBF_T_PID_OUT	// PID
			);

	repeat(1)	@(posedge clk);

	if(setup_pid==0)	send_data(`USBF_T_PID_DATA0, pl_size, 1);
	else			send_data(`USBF_T_PID_DATA1, pl_size, 1);

	setup_pid = ~setup_pid;

	// Wait for ACK
	utmi_recv_pack(len);

	if(8'hd2 !== txmem[0])
	   begin
		$display("ERROR: ACK mismatch. Expected: %h, Got: %h (%t)",
		8'hd2, txmem[0], $time);
		error_cnt = error_cnt + 1;
	   end

	if(len !== 1)
	   begin
		$display("ERROR: SETUP: Length mismatch. Expected: %h, Got: %h (%t)",
		8'h1, len, $time);
		error_cnt = error_cnt + 1;
	   end
	repeat(5)	@(posedge clk);

end
endtask


parameter	GET_STATUS	=	8'h0,
		CLEAR_FEATURE	=	8'h1,
		SET_FEATURE	=	8'h3,
		SET_ADDRESS	=	8'h5,
		GET_DESCRIPTOR	=	8'h6,
		SET_DESCRIPTOR	=	8'h7,
		GET_CONFIG	=	8'h8,
		SET_CONFIG	=	8'h9,
		GET_INTERFACE	=	8'ha,
		SET_INTERFACE	=	8'hb,
		SYNCH_FRAME	=	8'hc;


task setup1;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** CTRL ep test 1                                ***");
$display("*****************************************************\n");


$display("\n\nSetting Address ...");

send_setup(	8'h0, 		// Function Address
		8'h00,		// Request Type
		SET_ADDRESS,	// Request
		16'h012,	// wValue
		16'h0,		// wIndex
		16'h0		// wLength
		);

// Status OK
data_in(	8'h0,		// Function Address
		8'h0		// Expected payload size
	);


$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0100,	// wValue
		16'h0,		// wIndex
		16'h8		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd08		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);


$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0200,	// wValue
		16'h0,		// wIndex
		16'h8		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd08		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0200,	// wValue
		16'h0,		// wIndex
		16'd053		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd053		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0300,	// wValue
		16'h0,		// wIndex
		16'd04		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd04		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0301,	// wValue
		16'h0,		// wIndex
		16'd010		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd010		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0302,	// wValue
		16'h0,		// wIndex
		16'd08		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd08		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0303,	// wValue
		16'h0,		// wIndex
		16'd016		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd010		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

$display("\n\nGetting descriptor ...");
send_setup(	8'h12, 		// Function Address
		8'h80,		// Request Type
		GET_DESCRIPTOR,	// Request
		16'h0203,	// wValue
		16'h0,		// wIndex
		16'd053		// wLength
		);

data_in(	8'h12,		// Function Address
		8'd053		// Expected payload size
	);

// Status OK
data_out(	8'h12,		// Function Address
		8'h0		// Expected payload size
	);

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end
endtask


task in0;

reg	[6:0]	my_fa;
integer		quick, n, m, rlen,fc;
reg	[7:0]	fd;
integer		pack_cnt, pack_cnt_max;
reg	[7:0]	x;
reg	[3:0]	pid;
reg	[3:0]	expect_pid;
reg	[31:0]	data;
reg		pid_cnt;

begin

$display("\n\n");
$display("*****************************************************");
$display("*** IN ep test 0                                  ***");
$display("*****************************************************\n");

send_sof(11'h000 );	// Send SOF

pack_sz_max = 64;
pack_cnt_max = 4;

pid_cnt = 0;
my_fa = 7'h12;

for(pack_sz=0;pack_sz<pack_sz_max;pack_sz=pack_sz+1)
begin

$display("PL size: %0d", pack_sz);

for(pack_cnt=0;pack_cnt<pack_cnt_max;pack_cnt=pack_cnt+1)
   begin

	// Fill Buffer
	buffer1_last = 0;
	for(fc=0;fc<pack_sz;fc=fc+1)
	   begin
		#2;
		while(ep1_f_full)	@(posedge clk);
	
		#1;
		//x = fc[7:0];
		x = $random;
		ep1_f_din = x;
		buffer0[fc] = x;
		ep1_f_we = 1;
		@(posedge clk);
		#1;
		ep1_f_we = 0;
		@(posedge clk);
	   end
	#1;
	ep1_f_we = 0;
	@(posedge clk);

	// Send Data
	repeat(1)	@(posedge clk);
	send_sof(11'h000 );	// Send SOF
	repeat(1)	@(posedge clk);
	send_token(	my_fa,		// Function Address
			1,		// Logical Endpoint Number
			`USBF_T_PID_IN	// PID
			);

	repeat(1)	@(posedge clk);

	recv_packet(pid,rlen);

	if(pid_cnt)	expect_pid = 4'hb;
	else		expect_pid = 4'h3;
	expect_pid = 4'h3;

	if(pid !== expect_pid)
	   begin
		$display("ERROR: PID mismatch. Expected: %h, Got: %h (%t)",
			expect_pid, pid, $time);
		error_cnt = error_cnt + 1;
	   end
	pid_cnt = ~pid_cnt;

	if(rlen != pack_sz)
	   begin
		$display("ERROR: Size mismatch. Expected: %d, Got: %d (%t)",
			pack_sz, rlen, $time);
		error_cnt = error_cnt + 1;
	   end

	repeat(4)	@(posedge clk);
	send_token(	my_fa,		// Function Address
			1,		// Logical Endpoint Number
			`USBF_T_PID_ACK	// PID
			);
	repeat(5)	@(posedge clk);

	// Verify Data
	for(fc=0;fc<pack_sz;fc=fc+1)
	   begin
		x =  buffer0[fc];
		if( (buffer1[fc] !== x) | ( (^buffer1[fc] ^ ^x) === 1'hx) )
		   begin
			$display("ERROR: Data (%0d) mismatch. Expected: %h, Got: %h (%t)",
			fc, buffer1[fc], x, $time);
			error_cnt = error_cnt + 1;
		   end
	   end
   end

repeat(50)	@(posedge clk);
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");

end

endtask

task out0;
reg	[6:0]	my_fa;
reg	[31:0]	data;
integer		len, n, no_pack, pl_sz;
integer		no_pack_max, pl_sz_max;
reg		pid;

reg	[7:0]	x;

begin
$display("\n\n");
$display("*****************************************************");
$display("*** OUT ep test 0                                 ***");
$display("*****************************************************\n");


no_pack_max = 4;	// Number Of packets to transfer
pl_sz_max   = 128;	// Payload Size

no_pack = 4;		// Number Of packets to transfer
pl_sz = 0;
my_fa = 7'h12;


for(pl_sz=0;pl_sz<pl_sz_max;pl_sz=pl_sz+4)
begin
pid = 0;

$display("PL size: %0d", pl_sz);

for(n=0;n<4096;n=n+1)
	//buffer1[n] = $random;
	buffer1[n] = n;

buffer1_last = 0;

fork
for(no_pack=0;no_pack<no_pack_max;no_pack=no_pack+1)	// Send no_pack Out packets
   begin
	repeat(1)	@(posedge clk);
	send_sof(11'h000 );	// Send SOF
	repeat(1)	@(posedge clk);

	send_token(	my_fa,		// Function Address
			4,		// Logical Endpoint Number
			`USBF_T_PID_OUT	// PID
			);

	repeat(1)	@(posedge clk);

	if(pid==0)	send_data(`USBF_T_PID_DATA0, pl_sz, 1);
	else		send_data(`USBF_T_PID_DATA1, pl_sz, 1);

	pid = ~pid;

	// Wait for ACK
	utmi_recv_pack(len);

	if(8'hd2 !== txmem[0])
	   begin
		$display("ERROR: ACK mismatch. Expected: %h, Got: %h (%t)",
		8'hd2, txmem[0], $time);
		error_cnt = error_cnt + 1;
	   end
	
	repeat(1)	@(posedge clk);
   end

   begin
	repeat(10)	@(posedge clk2);
	for(n=0;n<(no_pack_max*pl_sz);n=n+1)	// Compare Buffers
	   begin
	
		#4;
		ep4_f_re = 0;
		repeat(1)	@(posedge clk2);

		while(ep4_f_empty)
		   begin
			ep4_f_re = 0;
			repeat(2)	@(posedge clk2);
		   end

		#2;
		if(buffer1[n] !== ep4_f_dout)
		   begin
			$display("ERROR: DATA mismatch. Expected: %h, Got: %h (%t)",
				buffer1[n], ep4_f_dout, $time);
			error_cnt = error_cnt + 1;
		   end
	
		ep4_f_re = 1;
		@(posedge clk2);
	   end
	#1;
	ep4_f_re = 0;
	@(posedge clk2);
    end

join

repeat(1)	@(posedge clk);
end

show_errors;
$display("*****************************************************");
$display("*** Test DONE ...                                 ***");
$display("*****************************************************\n\n");
end
endtask


