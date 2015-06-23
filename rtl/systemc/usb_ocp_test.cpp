/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Level Test Bench                               ////
////                                                             ////
////  SystemC Version: usb_test.cpp                              ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: test_bench_top.v + tests.v + tests_lib.v   ////
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

#include <stdlib.h>
#include <time.h>
#include "systemc.h"
#include "usb_defines.h"
#include "usb_phy.h"
#include "usb_ocp.h"

#define VCD_OUTPUT_ENABLE
//#define WIF_OUTPUT_ENABLE

SC_MODULE(test) {
	sc_in<bool>			clk, clk2;
	sc_out<bool>		rst;
	sc_in<bool>			txdp;
	sc_in<bool>			txdn;
	sc_out<bool>		rxdp;
	sc_out<bool>		rxdn;
	sc_out<sc_uint<8> >	dout;
	sc_out<bool>		tx_valid;
	sc_in<bool>			tx_ready;
	sc_in<sc_uint<8> >	din;
	sc_in<bool>			rx_valid;
	sc_in<bool>			rx_active;
	sc_in<bool>			rx_error;

	sc_in<bool>			txdp2;
	sc_in<bool>			txdn2;
	sc_out<bool>		rxdp2;
	sc_out<bool>		rxdn2;
	sc_in<bool>			s_int;
	sc_in<sc_uint<8> >	s_flag;
	sc_in<bool>			s_error;
	sc_out<sc_uint<32> >m_addr;
	sc_out<sc_uint<3> >	m_cmd;
	sc_out<sc_uint<8> >	m_data;
	sc_in<bool>			s_cmd_accept;
	sc_in<sc_uint<8> >	s_data;
	sc_in<sc_uint<2> >	s_resp;

	// Signals

	sc_signal<bool>			usb_reset;
	sc_signal<sc_uint<32> >	wd_cnt;
	sc_signal<bool> setup_pid;

	// Local Vars

	sc_uint<8> txmem[2049];
	sc_uint<8> buffer0[16385];
	sc_uint<8> buffer1[16385];
	sc_uint<8> buffer1_last;
	int error_cnt;
	int i;

/////////////////////////////////////////////////////////////////////
////                                                             ////
////              Test Bench Library                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

void show_errors(void) {
	cout << "+----------------------+" << endl;
	cout << "| TOTAL ERRORS: " << error_cnt << endl;
	cout << "+----------------------+" << endl << endl;
}

sc_uint<5> crc5(sc_uint<5> crc_in, sc_uint<11> din) {
	sc_uint<5> crc_out;

	crc_out[0] = din[10] ^ din[9] ^ din[6] ^ din[5] ^ din[3] ^
			din[0] ^ crc_in[0] ^ crc_in[3] ^ crc_in[4];
	crc_out[1] = din[10] ^ din[7] ^ din[6] ^ din[4] ^ din[1] ^
			crc_in[0] ^ crc_in[1] ^ crc_in[4];
	crc_out[2] = din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[6] ^
			din[3] ^ din[2] ^ din[0] ^ crc_in[0] ^
			crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4];
	crc_out[3] = din[10] ^ din[9] ^ din[8] ^ din[7] ^ din[4] ^
			din[3] ^ din[1] ^ crc_in[1] ^ crc_in[2] ^
			crc_in[3] ^ crc_in[4];
	crc_out[4] = din[10] ^ din[9] ^ din[8] ^ din[5] ^ din[4] ^
			din[2] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4];

	return crc_out;
}

sc_uint<16> crc16(sc_uint<16> crc_in, sc_uint<8> din) {
	sc_uint<16> crc_out;

	crc_out[0] = din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^
			din[1] ^ din[0] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^
			crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^
			crc_in[15];
	crc_out[1] = din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^ din[2] ^
			din[1] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^
			crc_in[13] ^ crc_in[14] ^ crc_in[15];
	crc_out[2] = din[1] ^ din[0] ^ crc_in[8] ^ crc_in[9];
	crc_out[3] = din[2] ^ din[1] ^ crc_in[9] ^ crc_in[10];
	crc_out[4] = din[3] ^ din[2] ^ crc_in[10] ^ crc_in[11];
	crc_out[5] = din[4] ^ din[3] ^ crc_in[11] ^ crc_in[12];
	crc_out[6] = din[5] ^ din[4] ^ crc_in[12] ^ crc_in[13];
	crc_out[7] = din[6] ^ din[5] ^ crc_in[13] ^ crc_in[14];
	crc_out[8] = din[7] ^ din[6] ^ crc_in[0] ^ crc_in[14] ^ crc_in[15];
	crc_out[9] = din[7] ^ crc_in[1] ^ crc_in[15];
	crc_out[10] = crc_in[2];
	crc_out[11] = crc_in[3];
	crc_out[12] = crc_in[4];
	crc_out[13] = crc_in[5];
	crc_out[14] = crc_in[6];
	crc_out[15] = din[7] ^ din[6] ^ din[5] ^ din[4] ^ din[3] ^
			din[2] ^ din[1] ^ din[0] ^ crc_in[7] ^ crc_in[8] ^
			crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^
			crc_in[13] ^ crc_in[14] ^ crc_in[15];

	return crc_out;
}

void utmi_send_pack(int size) {
	int n;

	wait(clk.posedge_event());
	tx_valid.write(true);
	for (n = 0; n < size; n++) {
		dout.write(txmem[n]);
		wait(clk.posedge_event());
		while (!tx_ready.read())
			wait(clk.posedge_event());
	}
	tx_valid.write(false);
	wait(clk.posedge_event());
}

void utmi_recv_pack(int *size) {
	*size = 0;
	while (!rx_active.read())
		wait(clk.posedge_event());
	while (rx_active.read()) {
		while (!rx_valid.read() && rx_active.read())
			wait(clk.posedge_event());
		if (rx_valid.read() && rx_active.read()) {
			txmem[*size] = din.read();
			(*size)++;
		}
		wait(clk.posedge_event());
	}
}

void recv_packet(sc_uint<4> *pid, int *size) {
	int n;
	sc_uint<16> crc16r;
	sc_uint<8> x, y;

	crc16r = 0xffff;
	utmi_recv_pack(size);

	if (*size != 1) {
		for (n = 1; n < *size - 2; n++) {
			y = txmem[n];
			x = (	(sc_uint<1>)y[0],
					(sc_uint<1>)y[1],
					(sc_uint<1>)y[2],
					(sc_uint<1>)y[3],
						(sc_uint<1>)y[4],
					(sc_uint<1>)y[5],
					(sc_uint<1>)y[6],
					(sc_uint<1>)y[7]);
			crc16r = crc16(crc16r, x);
		}

		crc16r = (	(sc_uint<1>)!crc16r[8],
					(sc_uint<1>)!crc16r[9],
					(sc_uint<1>)!crc16r[10],
					(sc_uint<1>)!crc16r[11],
					(sc_uint<1>)!crc16r[12],
					(sc_uint<1>)!crc16r[13],
					(sc_uint<1>)!crc16r[14],
					(sc_uint<1>)!crc16r[15],
					(sc_uint<1>)!crc16r[0],
					(sc_uint<1>)!crc16r[1],
					(sc_uint<1>)!crc16r[2],
					(sc_uint<1>)!crc16r[3],
					(sc_uint<1>)!crc16r[4],
					(sc_uint<1>)!crc16r[5],
					(sc_uint<1>)!crc16r[6],
					(sc_uint<1>)!crc16r[7]);

		if (crc16r != (sc_uint<16>)(txmem[n], txmem[n + 1]))
			cout << "ERROR: CRC Mismatch: Expected: " << crc16r << ", Got: " <<
					txmem[n] << txmem[n + 1] << " (" << sc_simulation_time() << ")" << endl << endl;

		for (n = 0; n < *size - 3; n++)
			buffer1[buffer1_last + n] = txmem[n + 1];
		buffer1_last = buffer1_last + n;
	} else {
		*size = 3;
	}

	x = txmem[0];

	if ((sc_uint<4>)x.range(7, 4) != (sc_uint<4>)~x.range(3, 0))
		cout << "ERROR: Pid Checksum mismatch: Top: " << (sc_uint<4>)x.range(7, 4) <<
				" Bottom: " << (sc_uint<4>)x.range(3, 0) << " (" << sc_simulation_time() << ")" << endl << endl;

	*pid = (sc_uint<4>)x.range(3, 0);
	*size = *size - 3;
}

void send_token(sc_uint<7> fa, sc_uint<4> ep, sc_uint<4> pid) {
	sc_uint<16> tmp_data;
	sc_uint<11> x, y;
	int len;

	tmp_data = ((sc_uint<7>)fa, (sc_uint<4>)ep, (sc_uint<5>)0);
	if (pid == USBF_T_PID_ACK)
		len = 1;
	else
		len = 3;

	y = ((sc_uint<7>)fa, (sc_uint<4>)ep);
	x = (	(sc_uint<1>)y[4],
			(sc_uint<1>)y[5],
			(sc_uint<1>)y[6],
			(sc_uint<1>)y[7],
			(sc_uint<1>)y[8],
			(sc_uint<1>)y[9],
			(sc_uint<1>)y[10],
			(sc_uint<1>)y[0],
			(sc_uint<1>)y[1],
			(sc_uint<1>)y[2],
			(sc_uint<1>)y[3]);

	y = ((sc_uint<6>)0, (sc_uint<5>)crc5(0x1f, x));
	tmp_data = ((sc_uint<11>)x, (sc_uint<5>)~y.range(4, 0));
	txmem[0] = ((sc_uint<4>)~pid, (sc_uint<4>)pid);
	txmem[1] = (	(sc_uint<1>)tmp_data[8],
					(sc_uint<1>)tmp_data[9],
					(sc_uint<1>)tmp_data[10],
					(sc_uint<1>)tmp_data[11],
					(sc_uint<1>)tmp_data[12],
					(sc_uint<1>)tmp_data[13],
					(sc_uint<1>)tmp_data[14],
					(sc_uint<1>)tmp_data[15]);
	txmem[2] = (	(sc_uint<1>)tmp_data[0],
					(sc_uint<1>)tmp_data[1],
					(sc_uint<1>)tmp_data[2],
					(sc_uint<1>)tmp_data[3],
					(sc_uint<1>)tmp_data[4],
					(sc_uint<1>)tmp_data[5],
					(sc_uint<1>)tmp_data[6],
					(sc_uint<1>)tmp_data[7]);

	utmi_send_pack(len);
}

void send_sof(sc_uint<11> frmn) {
	sc_uint<16> tmp_data;
	sc_uint<11> x;

	x = (	(sc_uint<1>)frmn[0],
			(sc_uint<1>)frmn[1],
			(sc_uint<1>)frmn[2],
			(sc_uint<1>)frmn[3],
			(sc_uint<1>)frmn[4],
			(sc_uint<1>)frmn[5],
			(sc_uint<1>)frmn[6],
			(sc_uint<1>)frmn[7],
			(sc_uint<1>)frmn[8],
			(sc_uint<1>)frmn[9],
			(sc_uint<1>)frmn[10]);

	tmp_data = ((sc_uint<11>)x, (sc_uint<5>)~crc5(0x1f, x));
	txmem[0] = ((sc_uint<4>)~USBF_T_PID_SOF, (sc_uint<4>)USBF_T_PID_SOF);
//	txmem[1] = (	(sc_uint<1>)tmp_data[8],
//					(sc_uint<1>)tmp_data[9],
//					(sc_uint<1>)tmp_data[10],
//					(sc_uint<1>)tmp_data[11],
//					(sc_uint<1>)tmp_data[12],
//					(sc_uint<1>)tmp_data[13],
//					(sc_uint<1>)tmp_data[14],
//					(sc_uint<1>)tmp_data[15]);
//	txmem[2] = (	(sc_uint<1>)tmp_data[0],
//					(sc_uint<1>)tmp_data[1],
//					(sc_uint<1>)tmp_data[2],
//					(sc_uint<1>)tmp_data[3],
//					(sc_uint<1>)tmp_data[4],
//					(sc_uint<1>)tmp_data[5],
//					(sc_uint<1>)tmp_data[6],
//					(sc_uint<1>)tmp_data[7]);
	txmem[1] = (sc_uint<8>)frmn.range(7, 0);
	txmem[2] = (	(sc_uint<1>)tmp_data[0],
					(sc_uint<1>)tmp_data[1],
					(sc_uint<1>)tmp_data[2],
					(sc_uint<1>)tmp_data[3],
					(sc_uint<1>)tmp_data[4],
					(sc_uint<3>)frmn.range(10, 8));

	utmi_send_pack(3);
}

void send_data(sc_uint<4> pid, int len, int mode) {
	int n;
	sc_uint<16> crc16r;
	sc_uint<8> x, y;

	txmem[0] = ((sc_uint<4>)~pid, (sc_uint<4>)pid);
	crc16r = 0xffff;
	for (n = 0; n < len; n++) {
		if (mode == 1)
			y = buffer1[buffer1_last + n];
		else
			y = n;
		x = (	(sc_uint<1>)y[0],
				(sc_uint<1>)y[1],
				(sc_uint<1>)y[2],
				(sc_uint<1>)y[3],
				(sc_uint<1>)y[4],
				(sc_uint<1>)y[5],
				(sc_uint<1>)y[6],
				(sc_uint<1>)y[7]);
		txmem[n + 1] = y;
		crc16r = crc16(crc16r, x);
	}

	buffer1_last = buffer1_last + n;
	y = (sc_uint<8>)crc16r.range(15, 8);
	txmem[n + 1] = (	(sc_uint<1>)!y[0],
						(sc_uint<1>)!y[1],
						(sc_uint<1>)!y[2],
						(sc_uint<1>)!y[3],
						(sc_uint<1>)!y[4],
						(sc_uint<1>)!y[5],
						(sc_uint<1>)!y[6],
						(sc_uint<1>)!y[7]);
	y = (sc_uint<8>)crc16r.range(7, 0);
	txmem[n + 2] = (	(sc_uint<1>)!y[0],
						(sc_uint<1>)!y[1],
						(sc_uint<1>)!y[2],
						(sc_uint<1>)!y[3],
						(sc_uint<1>)!y[4],
						(sc_uint<1>)!y[5],
						(sc_uint<1>)!y[6],
						(sc_uint<1>)!y[7]);

	utmi_send_pack(len + 3);
}

/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
////                                                             ////
////              Test Case Collection                           ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

void send_setup(	sc_uint<7> fa,
					sc_uint<8> req_type,
					sc_uint<8> request,
					sc_uint<16> wValue,
					sc_uint<16> wIndex,
					sc_uint<16> wLength) {
	int len;

	buffer1[0] = req_type;
	buffer1[1] = request;
	buffer1[3] = (sc_uint<8>)wValue.range(15, 8);
	buffer1[2] = (sc_uint<8>)wValue.range(7, 0);
	buffer1[5] = (sc_uint<8>)wIndex.range(15, 8);
	buffer1[4] = (sc_uint<8>)wIndex.range(7, 0);
	buffer1[7] = (sc_uint<8>)wLength.range(15, 8);
	buffer1[6] = (sc_uint<8>)wLength.range(7, 0);

	buffer1_last = 0;

	send_token(fa, 0, USBF_T_PID_SETUP);

	wait(clk.posedge_event());

	send_data(USBF_T_PID_DATA0, 8, 1);

	utmi_recv_pack(&len);

	if (txmem[0] != 0xd2) {
		cout << "ERROR: SETUP: ACK mismatch. Expected: 0xD2, Got: " << txmem[0] <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	if (len != 1) {
		cout << "ERROR: SETUP: ACK mismatch. Expected: 1, Got: " << len <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	wait(clk.posedge_event());
	setup_pid.write(true);
	wait(clk.posedge_event());
}

void data_in(sc_uint<7> fa, int pl_size) {
	int rlen;
	sc_uint<4> pid, expect_pid;

	buffer1_last = 0;
	for (i = 0; i < 5; i++)
		wait(clk.posedge_event());
	send_token(fa, 0, USBF_T_PID_IN);

	recv_packet(&pid, &rlen);
	if (setup_pid.read())
		expect_pid = 0xb;	// DATA 1
	else
		expect_pid = 0x3;	// DATA 0

	if (pid != expect_pid) {
		cout << "ERROR: Data IN PID mismatch. Expected: " << expect_pid << ", Got: " << pid <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	setup_pid.write(!setup_pid.read());
	if (rlen != pl_size) {
		cout << "ERROR: Data IN Size mismatch. Expected: " << pl_size << ", Got: " << rlen <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	for (i = 0; i < rlen; i++) {
		cout << "RCV Data[" << i << "]: 0x";
		printf("%02x", (unsigned int)buffer1[i]);
		cout << endl;
	}
	cout << endl;

	for (i = 0; i < 5; i++)
		wait(clk.posedge_event());
	send_token(fa, 0, USBF_T_PID_ACK);

	for (i = 0; i < 5; i++)
		wait(clk.posedge_event());
}

void data_out(sc_uint<7> fa, int pl_size) {
	int len;

	send_token(fa, 0, USBF_T_PID_OUT);

	wait(clk.posedge_event());

	if (!setup_pid.read())
		send_data(USBF_T_PID_DATA0, pl_size, 1);
	else
		send_data(USBF_T_PID_DATA1, pl_size, 1);

	setup_pid.write(!setup_pid.read());

	utmi_recv_pack(&len);

	if (txmem[0] != 0xd2) {
		cout << "ERROR: Ack mismatch. Expected: 0xd2, Got: " << txmem[0] <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	if (len != 1) {
		cout << "ERROR: SETUP: Length mismatch. Expected: 1, Got: " << len <<
				" (" << sc_simulation_time() << ")" << endl << endl;
		error_cnt++;
	}

	for (i = 0; i < 5; i++)
		wait(clk.posedge_event());
}

// Enumeration Test -> Endpoint 0
void setup0(void) {
	cout << endl;

	cout << "The Default Time Unit is: " << sc_get_default_time_unit().to_string() << endl << endl;

	cout << "**************************************************" << endl;
	cout << "*** CONTROL EP TEST 0                          ***" << endl;
	cout << "**************************************************" << endl << endl;

	cout << "Setting Address ..." << endl << endl;

	send_setup(0x00, 0x00, SET_ADDRESS, 0x0012, 0x0000, 0x0000);
	data_in(0x00,0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0100, 0x0000, 0x0012);
	data_in(0x12, 18);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0200, 0x0000, 0x0009);
	data_in(0x12, 9);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0200, 0x0000, 0x003c);
	data_in(0x12, 60);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0300, 0x0000, 0x0008);
	data_in(0x12, 8);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0301, 0x0416, 0x001a);
	data_in(0x12, 26);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0302, 0x0416, 0x001c);
	data_in(0x12, 28);
	data_out(0x12, 0);

	cout << "Getting Descriptor ..." << endl << endl;

	send_setup(0x12, 0x80, GET_DESCRIPTOR, 0x0303, 0x0416, 0x0036);
	data_in(0x12, 54);
	data_out(0x12, 0);

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// ISO IN Test -> Endpoint 1
void in1(void) {
	sc_uint<7> my_fa;
	int rlen, fc;
	sc_uint<8> fd;
	int pack_cnt, pack_cnt_max, pack_sz, pack_sz_max;
	sc_uint<8> x;
	sc_uint<4> pid, expect_pid;
	sc_uint<32> data;
//	bool pid_cnt;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** ISOCHRONOUS IN EP TEST 1                   ***" << endl;
	cout << "**************************************************" << endl << endl;

	send_sof(0x000);

	pack_sz_max = 256;
	pack_cnt_max = 4;

//	pid_cnt = false;
	my_fa = 0x12;

	m_addr.write(0x00000001);
	m_cmd.write(0x0);

	for (pack_sz = 0; pack_sz <= pack_sz_max; pack_sz += 32) {
		cout << "PL Size: " << pack_sz << endl;

		for (pack_cnt = 0; pack_cnt < pack_cnt_max; pack_cnt++) {
			buffer1_last = 0;
			for (fc = 0; fc < pack_sz; fc++) {
				while (s_flag.read()[1])
					wait(clk.posedge_event());

				x = (sc_uint<8>)(255.0 * rand() / (RAND_MAX + 1.0));
				m_data.write(x);
				buffer0[fc] = x;
				m_cmd.write(0x1);
				wait(clk.posedge_event());
				m_cmd.write(0x0);
				wait(clk.posedge_event());
			}
			m_cmd.write(0x0);
			wait(clk.posedge_event());

			// Send Data
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());
			send_token(my_fa, 1, USBF_T_PID_IN);
			wait(clk.posedge_event());

			recv_packet(&pid, &rlen);

//			if (pid_cnt)
//				expect_pid = 0xb;
//			else
//				expect_pid = 0x3;
			expect_pid = 0x3;

			if (pid != expect_pid) {
				cout << "ERROR: PID mismatch. Expected: " << expect_pid << ", Got: " << pid <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}
//			pid_cnt = !pid_cnt;

			if (rlen != pack_sz) {
				cout << "ERROR: Size mismatch. Expected: " << pack_sz << ", Got: " << rlen <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			for (i = 0; i < 4; i++)
				wait(clk.posedge_event());

			// Verify Data
			for (fc = 0; fc < pack_sz; fc++) {
				x = buffer0[fc];
				if (buffer1[fc] != x) {
					cout << "ERROR: Data (" << fc << ") mismatch. Expected: " << x << ", Got: " << buffer1[fc] <<
							" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}
			}
		}
		for (i = 0; i < 50; i++)
			wait(clk.posedge_event());
	}
	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// ISO OUT Test -> Endpoint 2
void out2(void) {
	sc_uint<7> my_fa;
	sc_uint<32> data;
	int n, no_pack, no_pack_max, pl_sz, pl_sz_max;
	bool pid;
	sc_uint<8> x;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** ISOCHRONOUS OUT EP TEST 2                  ***" << endl;
	cout << "**************************************************" << endl << endl;

	no_pack_max = 4;
	pl_sz_max = 256;

	my_fa = 0x12;

	m_addr.write(0x00000002);
	m_cmd.write(0x0);

	for (pl_sz = 0; pl_sz <= pl_sz_max; pl_sz += 32) {
		pid = false;

		cout << "PL Size: " << pl_sz << endl;

		for (n = 0; n < 4096; n++)
			buffer1[n] = n;

		buffer1_last = 0;

		no_pack = 0;
		while (true) {
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());

			send_token(my_fa, 2, USBF_T_PID_OUT);
			wait(clk.posedge_event());

			if (!pid)
				send_data(USBF_T_PID_DATA0, pl_sz, 1);
			else
				send_data(USBF_T_PID_DATA1, pl_sz, 1);
			for (i = 0; i < 10; i++)
				wait(clk2.posedge_event());
			for (n = 0; n < pl_sz; n++) {
				m_cmd.write(0x0);
				wait(clk2.posedge_event());
				wait(clk2.posedge_event());

				while (s_flag.read()[0]) {
					m_cmd.write(0x0);
					wait(clk2.posedge_event());
					wait(clk2.posedge_event());
				}

				if (buffer1[n + (pl_sz * no_pack)] != s_data.read()) {
					cout << "ERROR: DATA mismatch. Expected: " << buffer1[n + (pl_sz * no_pack)] << ", Got: " << s_data.read() <<
						" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}

				m_cmd.write(0x2);
				wait(clk2.posedge_event());
				wait(clk2.negedge_event());
			}
			m_cmd.write(0x0);
			wait(clk2.posedge_event());

			no_pack++;
			if (no_pack == no_pack_max)
				break;
		}
		wait(clk.posedge_event());
	}

	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// BULK IN Test -> Endpoint 3
void in3(void) {
	sc_uint<7> my_fa;
	int rlen, fc;
	sc_uint<8> fd;
	int pack_cnt, pack_cnt_max, pack_sz, pack_sz_max;
	sc_uint<8> x;
	sc_uint<4> pid, expect_pid;
	sc_uint<32> data;
	bool pid_cnt;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** BULK IN EP TEST 3                          ***" << endl;
	cout << "**************************************************" << endl << endl;

	send_sof(0x000);

	pack_sz_max = 64;
	pack_cnt_max = 4;

	pid_cnt = false;
	my_fa = 0x12;

	m_addr.write(0x00000003);
	m_cmd.write(0x0);

	for (pack_sz = 0; pack_sz <= pack_sz_max; pack_sz += 8) {
		cout << "PL Size: " << pack_sz << endl;

		for (pack_cnt = 0; pack_cnt < pack_cnt_max; pack_cnt++) {
			buffer1_last = 0;
			for (fc = 0; fc < pack_sz; fc++) {
				while (s_flag.read()[1])
					wait(clk.posedge_event());

				x = (sc_uint<8>)(255.0 * rand() / (RAND_MAX + 1.0));
				m_data.write(x);
				buffer0[fc] = x;
				m_cmd.write(0x1);
				wait(clk.posedge_event());
				m_cmd.write(0x0);
				wait(clk.posedge_event());
			}
			m_cmd.write(0x0);
			wait(clk.posedge_event());

			// Send Data
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());
			send_token(my_fa, 3, USBF_T_PID_IN);
			wait(clk.posedge_event());

			recv_packet(&pid, &rlen);

			if (pid_cnt)
				expect_pid = 0xb;
			else
				expect_pid = 0x3;
//			expect_pid = 0x3;

			if (pid != expect_pid) {
				cout << "ERROR: PID mismatch. Expected: " << expect_pid << ", Got: " << pid <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}
			pid_cnt = !pid_cnt;

			if (rlen != pack_sz) {
				cout << "ERROR: Size mismatch. Expected: " << pack_sz << ", Got: " << rlen <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			for (i = 0; i < 4; i++)
				wait(clk.posedge_event());

			send_token(my_fa, 3, USBF_T_PID_ACK);

			for (i = 0; i < 5; i++)
				wait(clk.posedge_event());

			// Verify Data
			for (fc = 0; fc < pack_sz; fc++) {
				x = buffer0[fc];
				if (buffer1[fc] != x) {
					cout << "ERROR: Data (" << fc << ") mismatch. Expected: " << x << ", Got: " << buffer1[fc] <<
							" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}
			}
		}
		for (i = 0; i < 50; i++)
			wait(clk.posedge_event());
	}
	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// BULK OUT Test -> Endpoint 4
void out4(void) {
	sc_uint<7> my_fa;
	sc_uint<32> data;
	int n, len, no_pack, no_pack_max, pl_sz, pl_sz_max;
	bool pid;
	sc_uint<8> x;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** BULK OUT EP TEST 4                         ***" << endl;
	cout << "**************************************************" << endl << endl;

	no_pack_max = 4;
	pl_sz_max = 64;

	my_fa = 0x12;

	m_addr.write(0x00000004);
	m_cmd.write(0x0);

	for (pl_sz = 0; pl_sz <= pl_sz_max; pl_sz += 8) {
		pid = false;

		cout << "PL Size: " << pl_sz << endl;

		for (n = 0; n < 4096; n++)
			buffer1[n] = n;

		buffer1_last = 0;

		no_pack = 0;
		while (true) {
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());

			send_token(my_fa, 4, USBF_T_PID_OUT);
			wait(clk.posedge_event());

			if (!pid)
				send_data(USBF_T_PID_DATA0, pl_sz, 1);
			else
				send_data(USBF_T_PID_DATA1, pl_sz, 1);
			pid = !pid;

			utmi_recv_pack(&len);

			if (txmem[0] != 0xd2) {
				cout << "ERROR: ACK mismatch. Expected: 0xd2, Got: " << txmem[0] <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			if (len != 1) {
				cout << "ERROR: Size mismatch. Expected: 1, Got: " << len <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			wait(clk.posedge_event());

			for (i = 0; i < 10; i++)
				wait(clk2.posedge_event());
			for (n = 0; n < pl_sz; n++) {
				m_cmd.write(0x0);
				wait(clk2.posedge_event());
				wait(clk2.posedge_event());

				while (s_flag.read()[0]) {
					m_cmd.write(0x0);
					wait(clk2.posedge_event());
					wait(clk2.posedge_event());
				}

				if (buffer1[n + (pl_sz * no_pack)] != s_data.read()) {
					cout << "ERROR: DATA mismatch. Expected: " << buffer1[n + (pl_sz * no_pack)] << ", Got: " << s_data.read() <<
						" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}

				m_cmd.write(0x2);
				wait(clk2.posedge_event());
				wait(clk2.negedge_event());
			}
			m_cmd.write(0x0);
			wait(clk2.posedge_event());

			no_pack++;
			if (no_pack == no_pack_max)
				break;
		}
		wait(clk.posedge_event());
	}

	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// INT IN Test -> Endpoint 5
void in5(void) {
	sc_uint<7> my_fa;
	int rlen, fc;
	sc_uint<8> fd;
	int pack_cnt, pack_cnt_max, pack_sz, pack_sz_max;
	sc_uint<8> x;
	sc_uint<4> pid, expect_pid;
	sc_uint<32> data;
	bool pid_cnt;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** INTERRUPT IN EP TEST 5                     ***" << endl;
	cout << "**************************************************" << endl << endl;

	send_sof(0x000);

	pack_sz_max = 64;
	pack_cnt_max = 4;

	pid_cnt = false;
	my_fa = 0x12;

	m_addr.write(0x00000005);
		m_cmd.write(0x0);

	for (pack_sz = 0; pack_sz <= pack_sz_max; pack_sz += 8) {
		cout << "PL Size: " << pack_sz << endl;

		for (pack_cnt = 0; pack_cnt < pack_cnt_max; pack_cnt++) {
			buffer1_last = 0;
			for (fc = 0; fc < pack_sz; fc++) {
				while (s_flag.read()[1])
					wait(clk.posedge_event());

				x = (sc_uint<8>)(255.0 * rand() / (RAND_MAX + 1.0));
				m_data.write(x);
				buffer0[fc] = x;
				m_cmd.write(0x1);
				wait(clk.posedge_event());
				m_cmd.write(0x0);
				wait(clk.posedge_event());
			}
			m_cmd.write(0x0);
			wait(clk.posedge_event());

			// Send Data
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());
			send_token(my_fa, 5, USBF_T_PID_IN);
			wait(clk.posedge_event());

			recv_packet(&pid, &rlen);

			if (pack_sz == 0)
				expect_pid = 0xa;
			else if (pid_cnt)
				expect_pid = 0xb;
			else
				expect_pid = 0x3;
//			expect_pid = 0x3;

			if (pid != expect_pid) {
				cout << "ERROR: PID mismatch. Expected: " << expect_pid << ", Got: " << pid <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}
			pid_cnt = !pid_cnt;

			if (rlen != pack_sz) {
				cout << "ERROR: Size mismatch. Expected: " << pack_sz << ", Got: " << rlen <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			for (i = 0; i < 4; i++)
				wait(clk.posedge_event());

			if (pack_sz != 0) {
				send_token(my_fa, 5, USBF_T_PID_ACK);

				for (i = 0; i < 5; i++)
					wait(clk.posedge_event());
			}

			// Verify Data
			for (fc = 0; fc < pack_sz; fc++) {
				x = buffer0[fc];
				if (buffer1[fc] != x) {
					cout << "ERROR: Data (" << fc << ") mismatch. Expected: " << x << ", Got: " << buffer1[fc] <<
							" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}
			}
		}
		for (i = 0; i < 50; i++)
			wait(clk.posedge_event());
	}
	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

// INT OUT Test -> Endpoint 6
void out6(void) {
	sc_uint<7> my_fa;
	sc_uint<32> data;
	int n, len, no_pack, no_pack_max, pl_sz, pl_sz_max;
	bool pid;
	sc_uint<8> x;

	cout << endl;

	cout << "**************************************************" << endl;
	cout << "*** INTERRUPT OUT EP TEST 6                    ***" << endl;
	cout << "**************************************************" << endl << endl;

	no_pack_max = 4;
	pl_sz_max = 64;

	my_fa = 0x12;

	m_addr.write(0x00000006);
	m_cmd.write(0x0);

	for (pl_sz = 0; pl_sz <= pl_sz_max; pl_sz += 8) {
		pid = false;

		cout << "PL Size: " << pl_sz << endl;

		for (n = 0; n < 4096; n++)
			buffer1[n] = n;

		buffer1_last = 0;

		no_pack = 0;
		while (true) {
			wait(clk.posedge_event());
			send_sof(0x000);
			wait(clk.posedge_event());

			send_token(my_fa, 6, USBF_T_PID_OUT);
			wait(clk.posedge_event());

			if (!pid)
				send_data(USBF_T_PID_DATA0, pl_sz, 1);
			else
				send_data(USBF_T_PID_DATA1, pl_sz, 1);
			pid = !pid;

			utmi_recv_pack(&len);

			if (txmem[0] != 0xd2) {
				cout << "ERROR: ACK mismatch. Expected: 0xd2, Got: " << txmem[0] <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			if (len != 1) {
				cout << "ERROR: Size mismatch. Expected: 1, Got: " << len <<
						" (" << sc_simulation_time() << ")" << endl << endl;
				error_cnt++;
			}

			wait(clk.posedge_event());

			for (i = 0; i < 10; i++)
				wait(clk2.posedge_event());
			for (n = 0; n < pl_sz; n++) {
				m_cmd.write(0x0);
				wait(clk2.posedge_event());
				wait(clk2.posedge_event());

				while (s_flag.read()[0]) {
					m_cmd.write(0x0);
					wait(clk2.posedge_event());
					wait(clk2.posedge_event());
				}

				if (buffer1[n + (pl_sz * no_pack)] != s_data.read()) {
					cout << "ERROR: DATA mismatch. Expected: " << buffer1[n + (pl_sz * no_pack)] << ", Got: " << s_data.read() <<
						" (" << sc_simulation_time() << ")" << endl << endl;
					error_cnt++;
				}

				m_cmd.write(0x2);
				wait(clk2.posedge_event());
				wait(clk2.negedge_event());
			}
			m_cmd.write(0x0);
			wait(clk2.posedge_event());

			no_pack++;
			if (no_pack == no_pack_max)
				break;
		}
		wait(clk.posedge_event());
	}

	m_cmd.write(0x4);
	m_addr.write(0x00000000);

	cout << endl;

	show_errors();

	cout << "**************************************************" << endl;
	cout << "*** TEST DONE ...                              ***" << endl;
	cout << "**************************************************" << endl << endl;
}

/////////////////////////////////////////////////////////////////////

	void rx1_update(void) {
		rxdp.write(!usb_reset.read() && txdp2.read());
		rxdn.write(!usb_reset.read() && txdn2.read());
	}

	void rx2_update(void) {
		rxdp2.write(!usb_reset.read() && txdp.read());
		rxdn2.write(!usb_reset.read() && txdn.read());
	}

	void watchdog(void) {
		if (txdp.read() || txdp2.read())
			wd_cnt.write(0);
		else
			wd_cnt.write(wd_cnt.read() + 1);
	}

	void wd_cnt_mon(void) {
		if (wd_cnt.read() > 5000) {
			cout << "**********************************" << endl;
			cout << "ERROR: Watch Dog Counter Expired" << endl;
			cout << "**********************************" << endl << endl;
			sc_stop();
		}
	}

	void init(void) {
		usb_reset.write(false);
		tx_valid.write(false);
		error_cnt = 0;
		wd_cnt.write(0);
		rst.write(false);
		m_cmd.write(0x4);
		m_addr.write(0x00000000);

		for (i = 0; i < 10; i++) wait(clk.posedge_event());
		rst.write(true);

		for (i = 0; i < 50; i++) wait(clk.posedge_event());
		usb_reset.write(true);

		for (i = 0; i < 300; i++) wait(clk.posedge_event());
		usb_reset.write(false);

		for (i = 0; i < 10; i++) wait(clk.posedge_event());

		setup0();
		in1();
		out2();
		in3();
		out4();
		in5();
		out6();

		for (i = 0; i < 500; i++) wait(clk.posedge_event());
		sc_stop();
	}

	SC_CTOR(test) {
		SC_METHOD(rx1_update);
		sensitive << usb_reset << txdp2 << txdn2;
		SC_METHOD(rx2_update);
		sensitive << usb_reset << txdp << txdn;
		SC_METHOD(watchdog);
		sensitive << clk.pos();
		SC_METHOD(wd_cnt_mon);
		sensitive << wd_cnt;
		SC_THREAD(init);
		sensitive << clk.pos();
	}
};

int sc_main(int argc, char *argv[]) {

	sc_set_time_resolution(1.0, SC_NS);

	sc_clock clk("clock", 20.84, SC_NS);
	sc_clock clk2("clock2", 20.84, SC_NS);

	sc_signal<bool>	rst, vcc;

	sc_signal<bool>	rx_dp1, rx_dn1, tx_dp1, tx_dn1;
	sc_signal<bool>	tb_rx_valid, tb_rx_active, tb_rx_error;
	sc_signal<bool>	tb_tx_valid, tb_tx_ready;
	sc_signal<sc_uint<8> > tb_rx_data, tb_tx_data;

	sc_signal<bool>	rx_dp2, rx_dn2, tx_dp2, tx_dn2;
	sc_signal<sc_uint<8> >	SData, MData, SFlag;
	sc_signal<sc_uint<32> > MAddr;
	sc_signal<sc_uint<3> > MCmd;
	sc_signal<sc_uint<2> > SResp;
	sc_signal<bool> SInterrupt, SError, SCmdAccept;

	sc_signal<bool> usb_rst_nc, txoe_nc, tx_oe_nc;
	sc_signal<sc_uint<2> > line_nc;

	usb_phy			i_phy("HOST_PHY");
	usb_ocp			i_ocp("USB_OCP");
	test			i_test("TEST");

	i_phy.clk(clk);
	i_phy.rst(rst);
	i_phy.phy_tx_mode(vcc);
	i_phy.usb_rst(usb_rst_nc);
	i_phy.txdp(tx_dp1);
	i_phy.txdn(tx_dn1);
	i_phy.txoe(txoe_nc);
	i_phy.rxd(rx_dp1);
	i_phy.rxdp(rx_dp1);
	i_phy.rxdn(rx_dn1);
	i_phy.DataOut_i(tb_tx_data);
	i_phy.TxValid_i(tb_tx_valid);
	i_phy.TxReady_o(tb_tx_ready);
	i_phy.DataIn_o(tb_rx_data);
	i_phy.RxValid_o(tb_rx_valid);
	i_phy.RxActive_o(tb_rx_active);
	i_phy.RxError_o(tb_rx_error);
	i_phy.LineState_o(line_nc);

	i_ocp.Clk(clk2);
	i_ocp.Reset_n(rst);
	i_ocp.tx_dp(tx_dp2);
	i_ocp.tx_dn(tx_dn2);
	i_ocp.tx_oe(tx_oe_nc);
	i_ocp.rx_dp(rx_dp2);
	i_ocp.rx_dn(rx_dn2);
	i_ocp.rx_d(rx_dp2);
	i_ocp.SInterrupt(SInterrupt);
	i_ocp.SFlag(SFlag);
	i_ocp.SError(SError);
	i_ocp.MAddr(MAddr);
	i_ocp.MCmd(MCmd);
	i_ocp.MData(MData);
	i_ocp.SCmdAccept(SCmdAccept);
	i_ocp.SData(SData);
	i_ocp.SResp(SResp);

	i_test.clk(clk);
	i_test.rst(rst);
	i_test.txdp(tx_dp1);
	i_test.txdn(tx_dn1);
	i_test.rxdp(rx_dp1);
	i_test.rxdn(rx_dn1);
	i_test.dout(tb_tx_data);
	i_test.tx_valid(tb_tx_valid);
	i_test.tx_ready(tb_tx_ready);
	i_test.din(tb_rx_data);
	i_test.rx_valid(tb_rx_valid);
	i_test.rx_active(tb_rx_active);
	i_test.rx_error(tb_rx_error);

	i_test.clk2(clk2);
	i_test.txdp2(tx_dp2);
	i_test.txdn2(tx_dn2);
	i_test.rxdp2(rx_dp2);
	i_test.rxdn2(rx_dn2);
	i_test.s_int(SInterrupt);
	i_test.s_flag(SFlag);
	i_test.s_error(SError);
	i_test.m_addr(MAddr);
	i_test.m_cmd(MCmd);
	i_test.m_data(MData);
	i_test.s_cmd_accept(SCmdAccept);
	i_test.s_data(SData);
	i_test.s_resp(SResp);

	vcc.write(true);

#ifdef VCD_OUTPUT_ENABLE
	sc_trace_file *vcd_log = sc_create_vcd_trace_file("USB_TEST");
	sc_trace(vcd_log, clk2, "Clk");
	sc_trace(vcd_log, rst, "Reset_n");
	sc_trace(vcd_log, MAddr, "MAddr");
	sc_trace(vcd_log, MCmd, "MCmd");
	sc_trace(vcd_log, MData, "MData");
	sc_trace(vcd_log, SData, "SData");
	sc_trace(vcd_log, SCmdAccept, "SCmdAccept");
	sc_trace(vcd_log, SResp, "SResp");
#endif

#ifdef WIF_OUTPUT_ENABLE
	sc_trace_file *wif_log = sc_create_wif_trace_file("USB_TEST");
	sc_trace(wif_log, clk2, "Clk");
	sc_trace(wif_log, rst, "Reset_n");
	sc_trace(wif_log, MAddr, "MAddr");
	sc_trace(wif_log, MCmd, "MCmd");
	sc_trace(wif_log, MData, "MData");
	sc_trace(wif_log, SData, "SData");
	sc_trace(wif_log, SCmdAccept, "SCmdAccept");
	sc_trace(wif_log, SResp, "SResp");
#endif

	srand((unsigned int)(time(NULL) & 0xffffffff));
	sc_start();

#ifdef VCD_OUTPUT_ENABLE
	sc_close_vcd_trace_file(vcd_log);
#endif

#ifdef WIF_OUTPUT_ENABLE
	sc_close_wif_trace_file(wif_log);
#endif

	return 0;
}

