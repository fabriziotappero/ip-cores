/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Packet Disassembler                                    ////
////                                                             ////
////  SystemC Version: usb_pd_sie.h                              ////
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

#ifndef USB_PD_SIE_H
#define USB_PD_SIE_H

#include "usb_defines.h"
#include "usb_crc5.h"
#include "usb_crc16.h"

enum PD_STATE {	PD_IDLE = 1,
				PD_ACTIVE = 2,
				PD_TOKEN = 4,
				PD_DATA = 8};

SC_MODULE(usb_pd_sie) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;

	// RX Interface
	sc_in<sc_uint<8> >	rx_data;
	sc_in<bool>			rx_valid, rx_active, rx_err;

	// PID Information
	// Decoded PIDs (used when token_valid is asserted)
	sc_out<bool>		pid_OUT, pid_IN, pid_SOF, pid_SETUP;
	sc_out<bool>		pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
	sc_out<bool>		pid_ACK, pid_NACK, pid_STALL, pid_NYET;
	sc_out<bool>		pid_PRE, pid_ERR, pid_SPLIT, pid_PING;
	sc_out<bool>		pid_cks_err;								// Indicates a PID checksum error

	// Token Information
	sc_out<sc_uint<7> >	token_fadr;									// Function address from token
	sc_out<sc_uint<4> >	token_endp;									// Endpoint number from token
	sc_out<bool>		token_valid;								// Token is valid
	sc_out<bool>		crc5_err;									// Token CRC5 error
	sc_out<sc_uint<11> >frame_no;									// Frame number for SOF tokens

	// Receive Data Output
	sc_out<sc_uint<8> >	rx_data_st;									// Data to memory store unit
	sc_out<bool>		rx_data_valid;								// Data on rx_data_st is valid
	sc_out<bool>		rx_data_done;								// Indicates end of a transfer
	sc_out<bool>		crc16_err;									// Data packet CRC16 error

	// Misc
	sc_out<bool>		seq_err;									// State Machine Sequence Error
	sc_out<bool>		rx_busy;									// Receiving Data Packet

	// Local Signals
	sc_signal<sc_uint<4> >	state, next_state;// synopsys state_vector state
	sc_signal<sc_uint<8> >	pid;									// Packet PID
	sc_signal<bool>			pid_le_sm;								// PID load enable from State Machine
	sc_signal<bool>			pid_ld_en;								// Enable loading of PID (all conditions)
	sc_signal<bool>			pid_RES;
	sc_signal<bool>			pid_TOKEN;								// All TOKEN packet that we recognize
	sc_signal<bool>			pid_DATA;								// All DATA packet that we recognize
	sc_signal<sc_uint<8> >	token0, token1;							// Token registers
	sc_signal<bool>			token_le_1, token_le_2;					// Latch enables for token storage registers
	sc_signal<sc_uint<5> >	token_crc5;
	sc_signal<sc_uint<8> >	d0, d1, d2;								// Data path delay line (used to filter out crcs)
	sc_signal<bool>			data_valid_d;							// Data valid output from State Machine
	sc_signal<bool>			data_done;								// Data cycle complete output from State Machine
	sc_signal<bool>			data_valid0;							// Data valid delay line
	sc_signal<bool>			rxv1, rxv2;
	sc_signal<bool>			pid_ack;
	sc_signal<bool>			token_valid_r1;
	sc_signal<bool>			token_valid_str1;
	sc_signal<bool>			rx_active_r;
	sc_signal<bool>			rx_busy_d;
	sc_signal<sc_uint<5> >	crc5_out, crc5_out2;
	sc_signal<sc_uint<5> >	crc5_pol;
	sc_signal<sc_uint<11> >	crc5_din;
	sc_signal<bool>			crc16_clr;
	sc_signal<sc_uint<16> >	crc16_sum, crc16_out;
	sc_signal<sc_uint<8> >	crc16_din;

	usb_crc5				*i_crc5;								// CRC5 Calculator
	usb_crc16				*i_crc16;								// CRC16 Calculator

	// Busy Logic Functions
	void rx_busy_up1(void);
	void rx_busy_up2(void);

	// PID Decoding Logic Functions
	void pid_ld_up(void);
	void pid_up(void);
	void pid_cks_err_up(void);
	void pid_decoder(void);
	void pid_token_up(void);
	void pid_data_up(void);

	// Token Decoding Logic Functions
	void token_decoder(void);
	void token_valid_up1(void);
	void token_valid_up2(void);
	void token_valid_up3(void);
	void token_up(void);

	// CRC5 Logic Functions
	void crc5_din_up(void);
	void crc5_err_up(void);
	void crc5_out2_up(void);

	// Data Receiving Logic Functions
	void rxv1_up(void);
	void rxv2_up(void);
	void data_valid0_up(void);
	void d_up(void);
	void rx_data_st_up(void);
	void rx_data_valid_up(void);
	void rx_data_done_up(void);

	// CRC16 Logic Functions
	void rx_active_r_up(void);
	void crc16_din_up(void);
	void crc16_clr_up(void);
	void crc16_sum_up(void);
	void crc16_err_up(void);

	// Receive/Decode State Machine Functions
	void state_up(void);
	void pd_statemachine(void);

	// Destructor
//	~usb_pd_sie(void);

	SC_CTOR(usb_pd_sie) {
		crc5_pol.write(31);

		SC_METHOD(rx_busy_up1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rx_busy_up2);
		sensitive << clk.pos();

		SC_METHOD(pid_ld_up);
		sensitive << pid_le_sm << rx_active << rx_valid;
		SC_METHOD(pid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(pid_cks_err_up);
		sensitive << pid;
		SC_METHOD(pid_decoder);
		sensitive << pid;
		SC_METHOD(pid_token_up);
		sensitive << pid_OUT << pid_IN << pid_SOF << pid_SETUP << pid_PING;
		SC_METHOD(pid_data_up);
		sensitive << pid_DATA0 << pid_DATA1 << pid_DATA2 << pid_MDATA;

		SC_METHOD(token_decoder);
		sensitive << clk.pos();
		SC_METHOD(token_valid_up1);
		sensitive << clk.pos();
		SC_METHOD(token_valid_up2);
		sensitive << clk.pos();
		SC_METHOD(token_valid_up3);
		sensitive << token_valid_str1;
		SC_METHOD(token_up);
		sensitive << token0 << token1;

		SC_METHOD(crc5_din_up);
		sensitive << token_fadr << token_endp;
		SC_METHOD(crc5_err_up);
		sensitive << token_valid << crc5_out2 << token_crc5;
		SC_METHOD(crc5_out2_up);
		sensitive << crc5_out;

		SC_METHOD(rxv1_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rxv2_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(data_valid0_up);
		sensitive << clk.pos();
		SC_METHOD(d_up);
		sensitive << clk.pos();
		SC_METHOD(rx_data_st_up);
		sensitive << d2;
		SC_METHOD(rx_data_valid_up);
		sensitive << data_valid0;
		SC_METHOD(rx_data_done_up);
		sensitive << data_done;

		SC_METHOD(rx_active_r_up);
		sensitive << clk.pos();
		SC_METHOD(crc16_din_up);
		sensitive << rx_data;
		SC_METHOD(crc16_clr_up);
		sensitive << rx_active << rx_active_r;
		SC_METHOD(crc16_sum_up);
		sensitive << clk.pos();
		SC_METHOD(crc16_err_up);
		sensitive << data_done << crc16_sum;

		SC_METHOD(state_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(pd_statemachine);
		sensitive << state << rx_valid << rx_active << rx_err << pid_ACK << pid_TOKEN << pid_DATA;

		// CRC5 Calculator Instantiation and Binding
		i_crc5 = new usb_crc5("CRC5");
		i_crc5->crc_in(crc5_pol);
		i_crc5->din(crc5_din);
		i_crc5->crc_out(crc5_out);

		// CRC16 Calculator Instantiation and Binding
		i_crc16 = new usb_crc16("CRC16");
		i_crc16->crc_in(crc16_sum);
		i_crc16->din(crc16_din);
		i_crc16->crc_out(crc16_out);
	}

};

#endif

