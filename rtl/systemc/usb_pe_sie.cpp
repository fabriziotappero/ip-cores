/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Protocol Engine                                        ////
////  Performs automatic protocol functions                      ////
////                                                             ////
////  SystemC Version: usb_pe_sie.cpp                            ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_pe.v                                  ////
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

#include "systemc.h"
#include "usb_pe_sie.h"

// Endpoint/CSR Decoding
void usb_pe_sie::csr_decoder(void) {
	IN_ep.write(csr.read()[9]);
	OUT_ep.write(csr.read()[10]);
	CTRL_ep.write(csr.read()[11]);
	txfr_iso.write(csr.read()[12]);
	txfr_bulk.write(csr.read()[13]);
	txfr_int.write(!csr.read()[12] && !csr.read()[13]);
	ep_type.write(csr.read().range(10, 9));
	txfr_type.write(csr.read().range(13, 12));
}

void usb_pe_sie::match_up(void) {
	match_r.write(match.read() && fsel.read());
}

// No such endpoint indicator
void usb_pe_sie::nse_err_up(void) {
	nse_err.write(token_valid.read() && (pid_OUT.read() || pid_IN.read() || pid_SETUP.read()) && !match.read());
}

void usb_pe_sie::send_token_up(void) {
	send_token.write(send_token_d.read());
}

void usb_pe_sie::token_pid_sel_up(void) {
	token_pid_sel.write(token_pid_sel_d.read());
}

// Data PID storage
void usb_pe_sie::ep0_dpid_up(void) {
	if (!rst.read())
		ep0_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 0))
		ep0_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep1_dpid_up(void) {
	if (!rst.read())
		ep1_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 1))
		ep1_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep2_dpid_up(void) {
	if (!rst.read())
		ep2_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 2))
		ep2_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep3_dpid_up(void) {
	if (!rst.read())
		ep3_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 3))
		ep3_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep4_dpid_up(void) {
	if (!rst.read())
		ep4_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 4))
		ep4_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep5_dpid_up(void) {
	if (!rst.read())
		ep5_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 5))
		ep5_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep6_dpid_up(void) {
	if (!rst.read())
		ep6_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 6))
		ep6_dpid.write(next_dpid.read());
}

void usb_pe_sie::ep7_dpid_up(void) {
	if (!rst.read())
		ep7_dpid.write(0);
	else if (uc_dpd_set.read() && (ep_sel.read() == 7))
		ep7_dpid.write(next_dpid.read());
}

void usb_pe_sie::uc_dpd_up(void) {
	switch (ep_sel.read()) {
		case 0:	uc_dpd.write(ep0_dpid.read()); break;
		case 1:	uc_dpd.write(ep1_dpid.read()); break;
		case 2:	uc_dpd.write(ep2_dpid.read()); break;
		case 3:	uc_dpd.write(ep3_dpid.read()); break;
		case 4:	uc_dpd.write(ep4_dpid.read()); break;
		case 5:	uc_dpd.write(ep5_dpid.read()); break;
		case 6:	uc_dpd.write(ep6_dpid.read()); break;
		case 7:	uc_dpd.write(ep7_dpid.read()); break;
	}
}

// Data PID sequencer
void usb_pe_sie::sq_statemachine(void) {
	sc_uint<8> sel1;
	sc_uint<5> sel2;
	sc_uint<2> sel_d1, sel_d2;

	// tr/mf:ep/type:tr/type:last dpd
	sel1 = ((sc_uint<2>)tr_fr_d.read(), (sc_uint<2>)ep_type.read(), (sc_uint<2>)txfr_type.read(), (sc_uint<2>)uc_dpd.read());

	// CTRL Endpoint Selector
	sel2 = ((sc_uint<1>)setup_token.read(), (sc_uint<1>)in_op.read(), (sc_uint<1>)out_op.read(), (sc_uint<2>)uc_dpd.read());

	// Sync1 Selector
	sel_d1 = ((sc_uint<1>)pid_MDATA.read(), (sc_uint<1>)pid_DATA1.read());

	// Sync2 Selector
	sel_d2 = ((sc_uint<1>)pid_MDATA.read(), (sc_uint<1>)pid_DATA2.read());

	switch (sel1) {// synopsys full_case parallel_case

		// 0X_01_01_XX -> ISO txfr. IN, 1 tr/mf
		case 0x14:
		case 0x15:
		case 0x16:
		case 0x17:
		case 0x54:
		case 0x55:
		case 0x56:
		case 0x57:	next_dpid.write(0);
					break;

		// 10_01_01_X0 -> ISO txfr. IN, 2 tr/mf
		case 0x94:
		case 0x96:	next_dpid.write(1);
					break;

		// 10_01_01_X1 -> ISO txfr. IN, 2 tr/mf
		case 0x95:
		case 0x97:	next_dpid.write(0);
					break;

		// 11_01_01_00 -> ISO txfr. IN, 3 tr/mf
		case 0xd4:	next_dpid.write(1);
					break;

		// 11_01_01_01 -> ISO txfr. IN, 3 tr/mf
		case 0xd5:	next_dpid.write(2);
					break;

		// 11_01_01_10 -> ISO txfr. IN, 3 tr/mf
		case 0xd6:	next_dpid.write(0);
					break;

		// 0X_10_01_XX -> ISO txfr. OUT, 1 tr/mf
		case 0x24:
		case 0x25:
		case 0x26:
		case 0x27:
		case 0x64:
		case 0x65:
		case 0x66:
		case 0x67:	next_dpid.write(0);
					break;

		// 10_10_01_XX -> ISO txfr. OUT, 2 tr/mf
		case 0xa4:
		case 0xa5:
		case 0xa6:	// Resynchronize in case of PID error
		case 0xa7:	switch (sel_d1) {// synopsys full_case parallel_case
						case 2:	next_dpid.write(1); break;
						case 1: next_dpid.write(0); break;
					}
					break;

		// 11_10_01_00 -> ISO txfr. OUT, 3 tr/mf
		case 0xe4:	// Resynchronize in case of PID error
					switch (sel_d2) {// synopsys full_case parallel_case
						case 2:	next_dpid.write(1); break;
						case 1: next_dpid.write(0); break;
					}
					break;

		// 11_10_01_01 -> ISO txfr. OUT, 3 tr/mf
		case 0xe5:	// Resynchronize in case of PID error
					switch (sel_d2) {// synopsys full_case parallel_case
						case 2:	next_dpid.write(2); break;
						case 1: next_dpid.write(0); break;
					}
					break;

		// 11_10_01_10 -> ISO txfr. OUT, 3 tr/mf
		case 0xe6:	// Resynchronize in case of PID error
					switch (sel_d2) {// synopsys full_case parallel_case
						case 2:	next_dpid.write(1); break;
						case 1: next_dpid.write(0); break;
					}
					break;

		// XX_01_00_X0 or XX_10_00_X0 -> IN/OUT endpoint only
		case 0x10:
		case 0x12:
		case 0x50:
		case 0x52:
		case 0x90:
		case 0x92:
		case 0xd0:
		case 0xd2:
		case 0x20:
		case 0x22:
		case 0x60:
		case 0x62:
		case 0xa0:
		case 0xa2:
		case 0xe0:
		case 0xe2:	next_dpid.write(1);	// INT transfers
					break;

		// XX_01_00_X1 or XX_10_00_X1 -> IN/OUT endpoint only
		case 0x11:
		case 0x13:
		case 0x51:
		case 0x53:
		case 0x91:
		case 0x93:
		case 0xd1:
		case 0xd3:
		case 0x21:
		case 0x23:
		case 0x61:
		case 0x63:
		case 0xa1:
		case 0xa3:
		case 0xe1:
		case 0xe3:	next_dpid.write(0);	// INT transfers
					break;

		// XX_01_10_X0 or XX_10_10_X0 -> IN/OUT endpoint only
		case 0x18:
		case 0x1a:
		case 0x58:
		case 0x5a:
		case 0x98:
		case 0x9a:
		case 0xd8:
		case 0xda:
		case 0x28:
		case 0x2a:
		case 0x68:
		case 0x6a:
		case 0xa8:
		case 0xaa:
		case 0xe8:
		case 0xea:	next_dpid.write(1);	// BULK transfers
					break;

		// XX_01_10_X1 or XX_10_10_X1 -> IN/OUT endpoint only
		case 0x19:
		case 0x1b:
		case 0x59:
		case 0x5b:
		case 0x99:
		case 0x9b:
		case 0xd9:
		case 0xdb:
		case 0x29:
		case 0x2b:
		case 0x69:
		case 0x6b:
		case 0xa9:
		case 0xab:
		case 0xe9:
		case 0xeb:	next_dpid.write(0);	// BULK transfers
					break;

		// XX_00_XX_XX -> CTRL Endpoint
		case 0x00: case 0x01: case 0x02: case 0x03: case 0x04: case 0x05: case 0x06: case 0x07:
		case 0x08: case 0x09: case 0x0a: case 0x0b: case 0x0c: case 0x0d: case 0x0e: case 0x0f:
		case 0x40: case 0x41: case 0x42: case 0x43: case 0x44: case 0x45: case 0x46: case 0x47:
		case 0x48: case 0x49: case 0x4a: case 0x4b: case 0x4c: case 0x4d: case 0x4e: case 0x4f:
		case 0x80: case 0x81: case 0x82: case 0x83: case 0x84: case 0x85: case 0x86: case 0x87:
		case 0x88: case 0x89: case 0x8a: case 0x8b: case 0x8c: case 0x8d: case 0x8e: case 0x8f:
		case 0xc0: case 0xc1: case 0xc2: case 0xc3: case 0xc4: case 0xc5: case 0xc6: case 0xc7:
		case 0xc8: case 0xc9: case 0xca: case 0xcb: case 0xcc: case 0xcd: case 0xce: case 0xcf:
					switch (sel2) {// synopsys full_case parallel_case

						// 1_XX_XX -> SETUP operation
						case 0x10:
						case 0x11:
						case 0x12:
						case 0x13:
						case 0x14:
						case 0x15:
						case 0x16:
						case 0x17:
						case 0x18:
						case 0x19:
						case 0x1a:
						case 0x1b:
						case 0x1c:
						case 0x1d:
						case 0x1e:
						case 0x1f:	next_dpid.write(3);
									break;

						// 0_10_0X -> IN operation
						case 0x08:
						case 0x09:	next_dpid.write(3);
									break;

						// 0_10_1X -> IN operation
						case 0x0a:
						case 0x0b:	next_dpid.write(1);
									break;

						// 0_01_X0 -> OUT operation
						case 0x04:
						case 0x06:	next_dpid.write(3);
									break;

						// 0_01_X1 -> OUT operation
						case 0x05:
						case 0x07:	next_dpid.write(2);
									break;
					}
					break;
	}
}

// Current PID decoder
// Allow any PID for ISO transfers when mode full speed or tr_fr is zero
void usb_pe_sie::allow_pid_up(void) {
	sc_uint<4> sel;

	sel = ((sc_uint<1>)pid_DATA0.read(), (sc_uint<1>)pid_DATA1.read(), (sc_uint<1>)pid_DATA2.read(), (sc_uint<1>)pid_MDATA.read());

	switch (sel) {// synopsys full_case parallel_case
		// 1000
		case 8:	allow_pid.write(0); break;
		// 0100
		case 4:	allow_pid.write(1); break;
		// 0010
		case 2:	allow_pid.write(2); break;
		// 0001
		case 1:	allow_pid.write(3); break;
	}
}

void usb_pe_sie::this_dpid_up(void) {
	sc_uint<8> sel1;
	sc_uint<5> sel2;

	// tr/mf:ep/type:tr/type:last dpd
	sel1 = ((sc_uint<2>)tr_fr_d.read(), (sc_uint<2>)ep_type.read(), (sc_uint<2>)txfr_type.read(), (sc_uint<2>)uc_dpd.read());

	// CTRL Endpoint Selector
	sel2 = ((sc_uint<1>)setup_token.read(), (sc_uint<1>)in_op.read(), (sc_uint<1>)out_op.read(), (sc_uint<2>)uc_dpd.read());

	switch (sel1) {// synopsys full_case parallel_case

		// 0X_01_01_XX -> ISO txfr. IN, 1 tr/mf
		case 0x14:
		case 0x15:
		case 0x16:
		case 0x17:
		case 0x54:
		case 0x55:
		case 0x56:
		case 0x57:	this_dpid.write(0);
					break;

		// 10_01_01_X0 -> ISO txfr. IN, 2 tr/mf
		case 0x94:
		case 0x96:	this_dpid.write(1);
					break;

		// 10_01_01_X1 -> ISO txfr. IN, 2 tr/mf
		case 0x95:
		case 0x97:	this_dpid.write(0);
					break;

		// 11_01_01_00 -> ISO txfr. IN, 3 tr/mf
		case 0xd4:	this_dpid.write(2);
					break;

		// 11_01_01_01 -> ISO txfr. IN, 3 tr/mf
		case 0xd5:	this_dpid.write(1);
					break;

		// 11_01_01_10 -> ISO txfr. IN, 3 tr/mf
		case 0xd6:	this_dpid.write(0);
					break;

		// 00_10_01_XX -> ISO txfr. OUT, 0 tr/mf
		case 0x24:
		case 0x25:
		case 0x26:
		case 0x27:	this_dpid.write(allow_pid.read());
					break;

		// 01_10_01_XX -> ISO txfr. OUT, 1 tr/mf
		case 0x64:
		case 0x65:
		case 0x66:
		case 0x67:	this_dpid.write(0);
					break;

		// 10_10_01_X0 -> ISO txfr. OUT, 2 tr/mf
		case 0xa4:
		case 0xa6:	this_dpid.write(3);
					break;

		// 10_10_01_X1 -> ISO txfr. OUT, 2 tr/mf
		case 0xa5:
		case 0xa7:	this_dpid.write(1);
					break;

		// 11_10_01_00 -> ISO txfr. OUT, 3 tr/mf
		case 0xe4:	this_dpid.write(3);
					break;

		// 11_10_01_01 -> ISO txfr. OUT, 3 tr/mf
		case 0xe5:	this_dpid.write(3);
					break;

		// 11_10_01_10 -> ISO txfr. OUT, 3 tr/mf
		case 0xe6:	this_dpid.write(2);
					break;

		// XX_01_00_X0 or XX_10_00_X0 -> IN/OUT endpoint only
		case 0x10:
		case 0x12:
		case 0x50:
		case 0x52:
		case 0x90:
		case 0x92:
		case 0xd0:
		case 0xd2:
		case 0x20:
		case 0x22:
		case 0x60:
		case 0x62:
		case 0xa0:
		case 0xa2:
		case 0xe0:
		case 0xe2:	this_dpid.write(0);	// INT transfers
					break;

		// XX_01_00_X1 or XX_10_00_X1 -> IN/OUT endpoint only
		case 0x11:
		case 0x13:
		case 0x51:
		case 0x53:
		case 0x91:
		case 0x93:
		case 0xd1:
		case 0xd3:
		case 0x21:
		case 0x23:
		case 0x61:
		case 0x63:
		case 0xa1:
		case 0xa3:
		case 0xe1:
		case 0xe3:	this_dpid.write(1);	// INT transfers
					break;

		// XX_01_10_X0 or XX_10_10_X0 -> IN/OUT endpoint only
		case 0x18:
		case 0x1a:
		case 0x58:
		case 0x5a:
		case 0x98:
		case 0x9a:
		case 0xd8:
		case 0xda:
		case 0x28:
		case 0x2a:
		case 0x68:
		case 0x6a:
		case 0xa8:
		case 0xaa:
		case 0xe8:
		case 0xea:	this_dpid.write(0);	// BULK transfers
					break;

		// XX_01_10_X1 or XX_10_10_X1 -> IN/OUT endpoint only
		case 0x19:
		case 0x1b:
		case 0x59:
		case 0x5b:
		case 0x99:
		case 0x9b:
		case 0xd9:
		case 0xdb:
		case 0x29:
		case 0x2b:
		case 0x69:
		case 0x6b:
		case 0xa9:
		case 0xab:
		case 0xe9:
		case 0xeb:	this_dpid.write(1);	// BULK transfers
					break;

		// XX_00_XX_XX -> CTRL Endpoint
		case 0x00: case 0x01: case 0x02: case 0x03: case 0x04: case 0x05: case 0x06: case 0x07:
		case 0x08: case 0x09: case 0x0a: case 0x0b: case 0x0c: case 0x0d: case 0x0e: case 0x0f:
		case 0x40: case 0x41: case 0x42: case 0x43: case 0x44: case 0x45: case 0x46: case 0x47:
		case 0x48: case 0x49: case 0x4a: case 0x4b: case 0x4c: case 0x4d: case 0x4e: case 0x4f:
		case 0x80: case 0x81: case 0x82: case 0x83: case 0x84: case 0x85: case 0x86: case 0x87:
		case 0x88: case 0x89: case 0x8a: case 0x8b: case 0x8c: case 0x8d: case 0x8e: case 0x8f:
		case 0xc0: case 0xc1: case 0xc2: case 0xc3: case 0xc4: case 0xc5: case 0xc6: case 0xc7:
		case 0xc8: case 0xc9: case 0xca: case 0xcb: case 0xcc: case 0xcd: case 0xce: case 0xcf:
					switch (sel2) {// synopsys full_case parallel_case

						// 1_XX_XX -> SETUP operation
						case 0x10:
						case 0x11:
						case 0x12:
						case 0x13:
						case 0x14:
						case 0x15:
						case 0x16:
						case 0x17:
						case 0x18:
						case 0x19:
						case 0x1a:
						case 0x1b:
						case 0x1c:
						case 0x1d:
						case 0x1e:
						case 0x1f:	this_dpid.write(0);
									break;

						// 0_10_0X -> IN operation
						case 0x08:
						case 0x09:	this_dpid.write(0);
									break;

						// 0_10_1X -> IN operation
						case 0x0a:
						case 0x0b:	this_dpid.write(1);
									break;

						// 0_01_X0 -> OUT operation
						case 0x04:
						case 0x06:	this_dpid.write(0);
									break;

						// 0_01_X1 -> OUT operation
						case 0x05:
						case 0x07:	this_dpid.write(1);
									break;
					}
					break;
	}
}

// Assign PID for outgoing packets
void usb_pe_sie::data_pid_sel_up(void) {
	data_pid_sel.write(this_dpid.read());
}

// Verify PID for incoming data packets
void usb_pe_sie::pid_seq_err_up(void) {
	pid_seq_err.write(!(((this_dpid.read() == 0) && pid_DATA0.read()) ||
			((this_dpid.read() == 1) && pid_DATA1.read()) ||
			((this_dpid.read() == 2) && pid_DATA2.read()) ||
			((this_dpid.read() == 3) && pid_MDATA.read())));
}

// IDMA Setup and SRC/DEST Buffer Select
// For Control Endpoint things are different:
// buffer0 is used for OUT (incoming) data packets
// buffer1 is used for IN (outgoing) data packets

// Keep track of last token for control endpoints
void usb_pe_sie::in_token_up(void) {
	if (!rst.read())
		in_token.write(false);
	else if (pid_IN.read())
		in_token.write(true);
	else if (pid_OUT.read() || pid_SETUP.read())
		in_token.write(false);
}

void usb_pe_sie::out_token_up(void) {
	if (!rst.read())
		out_token.write(false);
	else if (pid_OUT.read() || pid_SETUP.read())
		out_token.write(true);
	else if (pid_IN.read())
		out_token.write(false);
}

void usb_pe_sie::setup_token_up(void) {
	if (!rst.read())
		setup_token.write(false);
	else if (pid_SETUP.read())
		setup_token.write(true);
	else if (pid_OUT.read() || pid_IN.read())
		setup_token.write(false);
}

// Indicates if we are performing an IN operation
void usb_pe_sie::in_op_up(void) {
	in_op.write(IN_ep.read() || (CTRL_ep.read() && in_token.read()));
}

// Indicates if we are performing an OUT operation
void usb_pe_sie::out_op_up(void) {
	out_op.write(OUT_ep.read() || (CTRL_ep.read() && out_token.read()));
}

// Determine if packet is to small or to large
// This is used to NACK and ignore packet for OUT endpoints

// Register File Update Logic

void usb_pe_sie::uc_dpd_set_up(void) {
	uc_dpd_set.write(uc_stat_set_d.read());
}

// Abort signal
void usb_pe_sie::abort_up(void) {
	abort.write(match.read() && fsel.read() && (state.read() != PE_IDLE));
}

// Time Out Timers

// After sending data in response to an IN token from host, the
// host must reply with an ack. The host has 622nS in Full Speed
// mode and 400nS in High Speed mode to reply.
// "rx_ack_to" indicates when this time has expired and
// rx_ack_to_clr clears the timer
void usb_pe_sie::rx_ack_up1(void) {
	rx_ack_to_clr.write(tx_valid.read() || rx_ack_to_clr_d.read());
}

void usb_pe_sie::rx_ack_up2(void) {
	if (rx_ack_to_clr.read())
		rx_ack_to_cnt.write(0);
	else
		rx_ack_to_cnt.write(rx_ack_to_cnt.read() + 1);
}

void usb_pe_sie::rx_ack_up3(void) {
	rx_ack_to.write(rx_ack_to_cnt.read() == rx_ack_to_val.read());
}

// After sending a OUT token the host must send a data packet.
// The host has 622nS in Full Speed mode and 400nS in High Speed
// mode to send the data packet.
// "tx_data_to" indicates when this time has expired and
// "tx_data_to_clr" clears the timer
void usb_pe_sie::tx_data_up1(void) {
	tx_data_to_clr.write(rx_active.read());
}

void usb_pe_sie::tx_data_up2(void) {
	if (tx_data_to_clr.read())
		tx_data_to_cnt.write(0);
	else
		tx_data_to_cnt.write(tx_data_to_cnt.read() + 1);
}

void usb_pe_sie::tx_data_up3(void) {
	tx_data_to.write(tx_data_to_cnt.read() == tx_data_to_val.read());
}

// Interrupts
void usb_pe_sie::pid_OUT_up(void) {
	pid_OUT_r.write(pid_OUT.read());
}

void usb_pe_sie::pid_IN_up(void) {
	pid_IN_r.write(pid_IN.read());
}

void usb_pe_sie::pid_PING_up(void) {
	pid_PING_r.write(pid_PING.read());
}

void usb_pe_sie::pid_SETUP_up(void) {
	pid_SETUP_r.write(pid_SETUP.read());
}

void usb_pe_sie::int_upid_up(void) {
	int_upid_set.write(match_r.read() && !pid_SOF.read() &&
			((OUT_ep.read() && !(pid_OUT_r.read() || pid_PING_r.read())) ||
			(IN_ep.read() && !pid_IN_r.read()) ||
			(CTRL_ep.read() && !(pid_IN_r.read() || pid_OUT_r.read() || pid_PING_r.read() || pid_SETUP_r.read()))));
}

void usb_pe_sie::int_to_up(void) {
	int_to_set.write(((state.read() == PE_IN2) && rx_ack_to.read()) ||
			((state.read() == PE_OUT) && tx_data_to.read()));
}

void usb_pe_sie::int_crc16_up(void) {
	int_crc16_set.write(rx_data_done.read() && crc16_err.read());
}

void usb_pe_sie::int_seqerr_up(void) {
	int_seqerr_set.write(int_seqerr_set_d.read());
}

void usb_pe_sie::send_stall_up(void) {
	if (!rst.read())
		send_stall_r.write(false);
	else if (send_stall.read())
		send_stall_r.write(true);
	else if (send_token.read())
		send_stall_r.write(false);
}

void usb_pe_sie::state_up(void) {
	if (!rst.read())
		state.write(PE_IDLE);
	else if (match.read())
		state.write(PE_IDLE);
	else
		state.write(next_state.read());
}

void usb_pe_sie::pe_statemachine(void) {
	next_state.write(state.read());
	token_pid_sel_d.write(PE_ACK);
	send_token_d.write(false);
	rx_dma_en.write(false);
	tx_dma_en.write(false);
	uc_stat_set_d.write(false);
	rx_ack_to_clr_d.write(true);
	int_seqerr_set_d.write(false);

	switch (state.read()) {// synopsys full_case parallel_case
		case PE_IDLE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state IDLE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					if (match_r.read() && !pid_SOF.read()) {
						if (send_stall.read()) {				// Halt Forced send STALL
							token_pid_sel_d.write(PE_STALL);
							send_token_d.write(true);
							next_state.write(PE_TOKEN);
						} else if (IN_ep.read() || (CTRL_ep.read() && pid_IN.read())) {
							if (txfr_int.read() && ep_empty.read()) {
								token_pid_sel_d.write(PE_NACK);
								send_token_d.write(true);
								next_state.write(PE_TOKEN);
							} else {
								tx_dma_en.write(true);
								next_state.write(PE_IN);
							}
						} else if (OUT_ep.read() || (CTRL_ep.read() && (pid_OUT.read() || pid_SETUP.read()))) {
							rx_dma_en.write(true);
							next_state.write(PE_OUT);
						}
					}
					break;

		case PE_TOKEN:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state TOKEN (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					next_state.write(PE_IDLE);
					break;

		case PE_IN:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state IN (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					rx_ack_to_clr_d.write(false);
					if (idma_done.read())
						if (txfr_iso.read())
							next_state.write(PE_UPDATE);
						else
							next_state.write(PE_IN2);
					break;

		case PE_IN2:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state IN2 (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					rx_ack_to_clr_d.write(false);
					// Wait for ACK from host or time out
					if (rx_ack_to.read())
						next_state.write(PE_IDLE);
					else if (token_valid.read() && pid_ACK.read())
						next_state.write(PE_UPDATE);
					break;

		case PE_OUT:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state OUT (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					if (tx_data_to.read() || crc16_err.read() || abort.read())
						next_state.write(PE_IDLE);
					else if (rx_data_done.read()) {	// Send ACK
						if (txfr_iso.read()) {
							if (pid_seq_err.read())
								int_seqerr_set_d.write(true);
							next_state.write(PE_UPDATEW);
						} else {
							next_state.write(PE_OUT2A);
						}
					}
					break;

		case PE_OUT2B:	// This is a delay state to NACK to small or
						// to large packets. This state could be skipped

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state OUT2B (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					if (abort.read())
						next_state.write(PE_IDLE);
					else
						next_state.write(PE_OUT2B);
					break;

		case PE_OUT2A:	// Send ACK/NACK/NYET

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state OUT2A (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					if (abort.read())
						next_state.write(PE_IDLE);
					else if (send_stall_r.read()) {
						token_pid_sel_d.write(PE_STALL);
						send_token_d.write(true);
						next_state.write(PE_IDLE);
					} else if (ep_full.read()) {
						token_pid_sel_d.write(PE_NACK);
						send_token_d.write(true);
						next_state.write(PE_IDLE);
					} else {
						token_pid_sel_d.write(PE_ACK);
						send_token_d.write(true);
						if (pid_seq_err.read())
							next_state.write(PE_IDLE);
						else
							next_state.write(PE_UPDATE);
					}
					break;

		case PE_UPDATEW:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state UPDATEW (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					next_state.write(PE_UPDATE);
					break;

		case PE_UPDATE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "SIE -> PE: Entered state UPDATE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

					uc_stat_set_d.write(true);
					next_state.write(PE_IDLE);
					break;
	}
}

