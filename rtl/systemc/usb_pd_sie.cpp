/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Packet Disassembler                                    ////
////                                                             ////
////  SystemC Version: usb_pd_sie.cpp                            ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_pd.v                                  ////
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
#include "usb_pd_sie.h"

void usb_pd_sie::rx_busy_up1(void) {
	if (!rst.read())
		rx_busy_d.write(false);
	else if (rx_valid.read() && (state.read() == PD_DATA))
		rx_busy_d.write(true);
	else if (state.read() != PD_DATA)
		rx_busy_d.write(false);
}

void usb_pd_sie::rx_busy_up2(void) {
	rx_busy.write(rx_busy_d.read());
}

void usb_pd_sie::pid_ld_up(void) {
	pid_ld_en.write(pid_le_sm.read() && rx_active.read() && rx_valid.read());
}

void usb_pd_sie::pid_up(void) {
	if (!rst.read())
		pid.write(0xf0);
	else if (pid_ld_en.read())
		pid.write(rx_data.read());
}

void usb_pd_sie::pid_cks_err_up(void) {
	pid_cks_err.write(pid.read().range(3, 0) != ~pid.read().range(7, 4));
}

void usb_pd_sie::pid_decoder(void) {
	pid_OUT.write(pid.read().range(3, 0) == USBF_T_PID_OUT);
	pid_IN.write(pid.read().range(3, 0) == USBF_T_PID_IN);
	pid_SOF.write(pid.read().range(3, 0) == USBF_T_PID_SOF);
	pid_SETUP.write(pid.read().range(3, 0) == USBF_T_PID_SETUP);
	pid_DATA0.write(pid.read().range(3, 0) == USBF_T_PID_DATA0);
	pid_DATA1.write(pid.read().range(3, 0) == USBF_T_PID_DATA1);
	pid_DATA2.write(pid.read().range(3, 0) == USBF_T_PID_DATA2);
	pid_MDATA.write(pid.read().range(3, 0) == USBF_T_PID_MDATA);
	pid_ACK.write(pid.read().range(3, 0) == USBF_T_PID_ACK);
	pid_NACK.write(pid.read().range(3, 0) == USBF_T_PID_NACK);
	pid_STALL.write(pid.read().range(3, 0) == USBF_T_PID_STALL);
	pid_NYET.write(pid.read().range(3, 0) == USBF_T_PID_NYET);
	pid_PRE.write(pid.read().range(3, 0) == USBF_T_PID_PRE);
	pid_ERR.write(pid.read().range(3, 0) == USBF_T_PID_ERR);
	pid_SPLIT.write(pid.read().range(3, 0) == USBF_T_PID_SPLIT);
	pid_PING.write(pid.read().range(3, 0) == USBF_T_PID_PING);
	pid_RES.write(pid.read().range(3, 0) == USBF_T_PID_RES);
}

void usb_pd_sie::pid_token_up(void) {
	pid_TOKEN.write(pid_OUT.read() || pid_IN.read() || pid_SOF.read() || pid_SETUP.read() || pid_PING.read());
}

void usb_pd_sie::pid_data_up(void) {
	pid_DATA.write(pid_DATA0.read() || pid_DATA1.read() || pid_DATA2.read() || pid_MDATA.read());
}

void usb_pd_sie::token_decoder(void) {
	if (token_le_1.read())
		token0.write(rx_data.read());

	if (token_le_2.read())
		token1.write(rx_data.read());
}

void usb_pd_sie::token_valid_up1(void) {
	token_valid_r1.write(token_le_2.read());
}

void usb_pd_sie::token_valid_up2(void) {
	token_valid_str1.write(token_valid_r1.read() || pid_ack.read());
}

void usb_pd_sie::token_valid_up3(void) {
	token_valid.write(token_valid_str1.read());
}

void usb_pd_sie::token_up(void) {
	frame_no.write(((sc_uint<3>)token1.read().range(2, 0), token0.read()));
	token_fadr.write((sc_uint<7>)token0.read().range(6, 0));
	token_endp.write(((sc_uint<3>)token1.read().range(2, 0), (sc_uint<1>)token0.read()[7]));
	token_crc5.write((sc_uint<5>)token1.read().range(7, 3));
}

// CRC5 should perform the check in one cycle (flow through logic)
// 11 bits and crc5 input, 1 bit output
void usb_pd_sie::crc5_din_up(void) {
	#ifdef USB_SIMULATION
		crc5_din.write((	(sc_uint<1>)token_fadr.read()[0],
							(sc_uint<1>)token_fadr.read()[1],
							(sc_uint<1>)token_fadr.read()[2],
							(sc_uint<1>)token_fadr.read()[3],
							(sc_uint<1>)token_fadr.read()[4],
							(sc_uint<1>)token_fadr.read()[5],
							(sc_uint<1>)token_fadr.read()[6],
							(sc_uint<1>)token_endp.read()[0],
							(sc_uint<1>)token_endp.read()[1],
							(sc_uint<1>)token_endp.read()[2],
							(sc_uint<1>)token_endp.read()[3]));
	#else
		crc5_din.write(((sc_uint<7>)token_fadr.read().range(0, 6), (sc_uint<4>)token_endp.read().range(0, 3)));
	#endif
}

void usb_pd_sie::crc5_err_up(void) {
	crc5_err.write(token_valid.read() && (crc5_out2.read() != token_crc5.read()));
}

// Invert and reverse result bits
void usb_pd_sie::crc5_out2_up(void) {
	#ifdef USB_SIMULATION
		crc5_out2.write((	(sc_uint<1>)!crc5_out.read()[0],
							(sc_uint<1>)!crc5_out.read()[1],
							(sc_uint<1>)!crc5_out.read()[2],
							(sc_uint<1>)!crc5_out.read()[3],
							(sc_uint<1>)!crc5_out.read()[4]));
	#else
		crc5_out2.write((sc_uint<5>)~crc5_out.read().range(0, 4));
	#endif
}

// Data receiving logic
// Build a delay line and stop when we are about to get crc
void usb_pd_sie::rxv1_up(void) {
	if (!rst.read())
		rxv1.write(false);
	else if (data_valid_d.read())
		rxv1.write(true);
	else if (data_done.read())
		rxv1.write(false);
}

void usb_pd_sie::rxv2_up(void) {
	if (!rst.read())
		rxv2.write(false);
	else if (rxv1.read() && data_valid_d.read())
		rxv2.write(true);
	else if (data_done.read())
		rxv2.write(false);
}

void usb_pd_sie::data_valid0_up(void) {
	data_valid0.write(rxv2.read() && data_valid_d.read());
}

void usb_pd_sie::d_up(void) {
	if (data_valid_d.read())
		d0.write(rx_data.read());

	if (data_valid_d.read())
		d1.write(d0.read());

	if (data_valid_d.read())
		d2.write(d1.read());
}

void usb_pd_sie::rx_data_st_up(void) {
	rx_data_st.write(d2.read());
}

void usb_pd_sie::rx_data_valid_up(void) {
	rx_data_valid.write(data_valid0.read());
}

void usb_pd_sie::rx_data_done_up(void) {
	rx_data_done.write(data_done.read());
}

// CRC16 accumulates rx_data as long as data_valid_d is asserted.
// When data_done is asserted, CRC16 reports status, and resets itself
// next cycle
void usb_pd_sie::rx_active_r_up(void) {
	rx_active_r.write(rx_active.read());
}

void usb_pd_sie::crc16_din_up(void) {
	#ifdef USB_SIMULATION
		crc16_din.write((	(sc_uint<1>)rx_data.read()[0],
							(sc_uint<1>)rx_data.read()[1],
							(sc_uint<1>)rx_data.read()[2],
							(sc_uint<1>)rx_data.read()[3],
							(sc_uint<1>)rx_data.read()[4],
							(sc_uint<1>)rx_data.read()[5],
							(sc_uint<1>)rx_data.read()[6],
							(sc_uint<1>)rx_data.read()[7]));
	#else
		crc16_din.write((sc_uint<8>)rx_data.read().range(0, 7));
	#endif
}

void usb_pd_sie::crc16_clr_up(void) {
	crc16_clr.write(rx_active.read() && !rx_active_r.read());
}

void usb_pd_sie::crc16_sum_up(void) {
	if (crc16_clr.read())
		crc16_sum.write(0xffff);
	else if (data_valid_d.read())
		crc16_sum.write(crc16_out.read());
}

void usb_pd_sie::crc16_err_up(void) {
	crc16_err.write(data_done.read() && (crc16_sum.read() != 0x800d));
}

// Receive and Decode FSM
void usb_pd_sie::state_up(void) {
	if (!rst.read())
		state.write(PD_IDLE);
	else
		state.write(next_state.read());
}

void usb_pd_sie::pd_statemachine(void) {
	next_state.write(state.read());			// Default don't change current state
	pid_le_sm.write(false);
	token_le_1.write(false);
	token_le_2.write(false);
	data_valid_d.write(false);
	data_done.write(false);
	seq_err.write(false);
	pid_ack.write(false);

	switch (state.read()) {// synopsys full_case parallel_case
		case PD_IDLE:	pid_le_sm.write(true);
						if (rx_valid.read() && rx_active.read())
							next_state.write(PD_ACTIVE);
						break;
		case PD_ACTIVE:	// Received a ACK from host
						if (pid_ACK.read() && !rx_err.read()) {
							pid_ack.write(true);
							if (!rx_active.read())
								next_state.write(PD_IDLE);

						// Receiving a TOKEN
						} else if (pid_TOKEN.read() && rx_valid.read() && rx_active.read() &&
								!rx_err.read()) {
							token_le_1.write(true);
							next_state.write(PD_TOKEN);

						// Receiving DATA
						} else if (pid_DATA.read() && rx_valid.read() && rx_active.read() &&
								!rx_err.read()) {
							data_valid_d.write(true);
							next_state.write(PD_DATA);

						// ERROR
						} else if (!rx_active.read() || rx_err.read() ||
								(rx_valid.read() && !(pid_TOKEN.read() || pid_DATA.read()))) {
							seq_err.write(!rx_err.read());
							if (!rx_active.read())
								next_state.write(PD_IDLE);
						}
						break;
		case PD_TOKEN:	if (rx_valid.read() && rx_active.read() && !rx_err.read()) {
							token_le_2.write(true);
							next_state.write(PD_IDLE);

						// ERROR
						} else if (!rx_active.read() || rx_err.read()) {
							seq_err.write(!rx_err.read());
							if (!rx_active.read())
								next_state.write(PD_IDLE);
						}
						break;
		case PD_DATA:	if (rx_valid.read() && rx_active.read() && !rx_err.read())
							data_valid_d.write(true);
						if (!rx_active.read() || rx_err.read()) {
							data_done.write(true);
							if (!rx_active.read())
								next_state.write(PD_IDLE);
						}
						break;
	}
}
/*
usb_pd_sie::~usb_pd_sie(void) {
	if (i_crc5)
		delete i_crc5;
	if (i_crc16)
		delete i_crc16;
}
*/
