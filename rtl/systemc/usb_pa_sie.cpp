/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Packet Assembler                                       ////
////                                                             ////
////  SystemC Version: usb_pa_sie.cpp                            ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_pa.v                                  ////
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
#include "usb_pa_sie.h"

void usb_pa_sie::zl_up(void) {
	zero_length.write(ep_empty.read());
}

void usb_pa_sie::zl_r_up(void) {
	if (!rst.read())
		zero_length_r.write(false);
	else if (last.read())
		zero_length_r.write(false);
	else if (crc16_clr.read())
		zero_length_r.write(zero_length.read());
}

void usb_pa_sie::tx_valid_r_up1(void) {
	tx_valid_r1.write(tx_valid.read());
}

void usb_pa_sie::tx_valid_r_up2(void) {
	tx_valid_r.write(tx_valid_r1.read());
}

void usb_pa_sie::send_token_up(void) {
	if (!rst.read())
		send_token_r.write(false);
	else if (send_token.read())
		send_token_r.write(true);
	else if (tx_ready.read())
		send_token_r.write(false);
}

// TOKEN PID Select
void usb_pa_sie::token_pid_up(void) {
	switch (token_pid_sel.read()) {// synopsys full_case parallel_case
		case 0: token_pid.write(((sc_uint<4>)(~USBF_T_PID_ACK), (sc_uint<4>)USBF_T_PID_ACK));
				break;
		case 1: token_pid.write(((sc_uint<4>)(~USBF_T_PID_NACK), (sc_uint<4>)USBF_T_PID_NACK));
				break;
		case 2: token_pid.write(((sc_uint<4>)(~USBF_T_PID_STALL), (sc_uint<4>)USBF_T_PID_STALL));
				break;
		case 3: token_pid.write(((sc_uint<4>)(~USBF_T_PID_NYET), (sc_uint<4>)USBF_T_PID_NYET));
				break;
	}
}

// DATA PID Select
void usb_pa_sie::data_pid_up(void) {
	switch (data_pid_sel.read()) {// synopsys full_case parallel_case
		case 0: data_pid.write(((sc_uint<4>)(~USBF_T_PID_DATA0), (sc_uint<4>)USBF_T_PID_DATA0));
				break;
		case 1: data_pid.write(((sc_uint<4>)(~USBF_T_PID_DATA1), (sc_uint<4>)USBF_T_PID_DATA1));
				break;
		case 2: data_pid.write(((sc_uint<4>)(~USBF_T_PID_DATA2), (sc_uint<4>)USBF_T_PID_DATA2));
				break;
		case 3: data_pid.write(((sc_uint<4>)(~USBF_T_PID_MDATA), (sc_uint<4>)USBF_T_PID_MDATA));
				break;
	}
}

// Data Path Muxes
void usb_pa_sie::tx_data_up1(void) {
	if (dsel.read())
		tx_data_data.write(tx_spec_data.read());
	else
		tx_data_data.write(tx_data_st.read());
}

void usb_pa_sie::tx_data_up2(void) {
	if (send_token.read() || send_token_r.read())
		tx_data_d.write(token_pid.read());
	else
		tx_data_d.write(tx_data_data.read());
}

void usb_pa_sie::tx_data_up3(void) {
	tx_data.write(tx_data_d.read());
}

void usb_pa_sie::tx_spec_up(void) {
	if (!crc_sel1.read() && !crc_sel2.read())
		tx_spec_data.write(data_pid.read());
	else if (crc_sel1.read())
		tx_spec_data.write(crc16_rev.read().range(15, 8));	// CRC 1
	else
		tx_spec_data.write(crc16_rev.read().range(7, 0));	// CRC 2
}

// TX Valid Assignment
void usb_pa_sie::tx_valid_up1(void) {
	tx_valid_last.write(send_token.read() || last.read());
}

void usb_pa_sie::tx_valid_up2(void) {
	tx_valid.write(tx_valid_d.read());
}

void usb_pa_sie::tx_first_up1(void) {
	tx_first_r.write(send_token.read() || send_data.read());
}

void usb_pa_sie::tx_first_up2(void) {
	tx_first.write((send_token.read() || send_data.read()) && !tx_first_r.read());
}

// CRC Logic
void usb_pa_sie::send_data_up1(void) {
	send_data_r.write(send_data.read());
}

void usb_pa_sie::send_data_up2(void) {
	send_data_r2.write(send_data_r.read());
}

void usb_pa_sie::crc16_clr_up(void) {
	crc16_clr.write(send_data.read() && !send_data_r.read());
}

void usb_pa_sie::crc16_din_up(void) {
	#ifdef USB_SIMULATION
		crc16_din.write((	(sc_uint<1>)tx_data_st.read()[0],
							(sc_uint<1>)tx_data_st.read()[1],
							(sc_uint<1>)tx_data_st.read()[2],
							(sc_uint<1>)tx_data_st.read()[3],
							(sc_uint<1>)tx_data_st.read()[4],
							(sc_uint<1>)tx_data_st.read()[5],
							(sc_uint<1>)tx_data_st.read()[6],
							(sc_uint<1>)tx_data_st.read()[7]));
	#else
		crc16_din.write(tx_data_st.read().range(0, 7));
	#endif
}

void usb_pa_sie::crc16_add_up(void) {
	crc16_add.write(!zero_length_r.read() &&
			((send_data_r.read() && !send_data_r2.read()) || (rd_next.read() && !crc_sel1.read())));
}

void usb_pa_sie::crc16_up(void) {
	if (crc16_clr.read())
		crc16.write(65535);
	else if (crc16_add.read())
		crc16.write(crc16_next.read());
}

void usb_pa_sie::crc16_rev_up(void) {
	#ifdef USB_SIMULATION
		crc16_rev.write((	(sc_uint<1>)!crc16.read()[8],
							(sc_uint<1>)!crc16.read()[9],
							(sc_uint<1>)!crc16.read()[10],
							(sc_uint<1>)!crc16.read()[11],
							(sc_uint<1>)!crc16.read()[12],
							(sc_uint<1>)!crc16.read()[13],
							(sc_uint<1>)!crc16.read()[14],
							(sc_uint<1>)!crc16.read()[15],
							(sc_uint<1>)!crc16.read()[0],
							(sc_uint<1>)!crc16.read()[1],
							(sc_uint<1>)!crc16.read()[2],
							(sc_uint<1>)!crc16.read()[3],
							(sc_uint<1>)!crc16.read()[4],
							(sc_uint<1>)!crc16.read()[5],
							(sc_uint<1>)!crc16.read()[6],
							(sc_uint<1>)!crc16.read()[7]));
	#else
		crc16_rev.write(((sc_uint<8>)(~crc16.read().range(8, 15)), (sc_uint<8>)(~crc16.read().range(0, 7))));
	#endif
}

// Transmit and Encode FSM
void usb_pa_sie::state_up(void) {
	if (!rst.read())
		state.write(PA_IDLE);
	else
		state.write(next_state.read());
}

void usb_pa_sie::pa_statemachine(void) {
	next_state.write(state.read());			// Default don't change current state
	tx_valid_d.write(false);
	dsel.write(false);
	rd_next.write(false);
	last.write(false);
	crc_sel1.write(false);
	crc_sel2.write(false);

	switch (state.read()) {// synopsys full_case parallel_case
		case PA_IDLE:	if (zero_length.read() && send_data.read()) {
							tx_valid_d.write(true);
							dsel.write(true);
							next_state.write(PA_CRC1);

						// Send DATA packet
						} else if (send_data.read()) {
							tx_valid_d.write(true);
							dsel.write(true);
							next_state.write(PA_DATA);
						}
						break;
		case PA_DATA:	if (tx_ready.read() && tx_valid_r.read())
							rd_next.write(true);

						tx_valid_d.write(true);
						if (!send_data.read() && tx_ready.read() && tx_valid_r.read()) {
							dsel.write(true);
							crc_sel1.write(true);
							next_state.write(PA_CRC1);
						}
						break;
		case PA_CRC1:	dsel.write(true);
						tx_valid_d.write(true);
						if (tx_ready.read()) {
							last.write(true);
							crc_sel2.write(true);
							next_state.write(PA_CRC2);
						} else {
							tx_valid_d.write(true);
							crc_sel1.write(true);
						}
						break;
		case PA_CRC2:	dsel.write(true);
						crc_sel2.write(true);
						if (tx_ready.read())
							next_state.write(PA_IDLE);
						else
							last.write(true);
						break;
	}
}
/*
usb_pa_sie::~usb_pa_sie(void) {
	if (i_crc16)
		delete i_crc16;
}
*/
