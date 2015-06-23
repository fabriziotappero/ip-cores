/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Packet Assembler                                       ////
////                                                             ////
////  SystemC Version: usb_pa_sie.h                              ////
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

#ifndef USB_PA_SIE_H
#define USB_PA_SIE_H

#include "usb_defines.h"
#include "usb_crc16.h"

enum PA_STATE {	PA_IDLE = 1,
				PA_DATA = 2,
				PA_CRC1 = 4,
				PA_CRC2 = 8};

SC_MODULE(usb_pa_sie) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;

	// TX Interface
	sc_out<sc_uint<8> >	tx_data;
	sc_out<bool>		tx_valid, tx_valid_last;
	sc_in<bool>			tx_ready;
	sc_out<bool>		tx_first;

	// Protocol Engine Interface
	sc_in<bool>			send_token;
	sc_in<sc_uint<2> >	token_pid_sel;
	sc_in<bool>			send_data;
	sc_in<sc_uint<2> >	data_pid_sel;

	// IDMA Interface
	sc_in<sc_uint<8> >	tx_data_st;
	sc_out<bool>		rd_next;

	sc_in<bool>			ep_empty;

	// Local Signals
	sc_signal<sc_uint<4> >	state, next_state;// synopsys state_vector state
	sc_signal<bool>			last;
	sc_signal<sc_uint<8> >	token_pid, data_pid;		// PIDs from selectors
	sc_signal<sc_uint<8> >	tx_data_d, tx_data_data;
	sc_signal<bool>			dsel;
	sc_signal<bool>			tx_valid_d;
	sc_signal<bool>			send_token_r;
	sc_signal<sc_uint<8> >	tx_spec_data;
	sc_signal<bool>			crc_sel1, crc_sel2;
	sc_signal<bool>			tx_first_r;
	sc_signal<bool>			send_data_r;
	sc_signal<bool>			crc16_clr;
	sc_signal<sc_uint<8> >	crc16_din;
	sc_signal<sc_uint<16> >	crc16;
	sc_signal<sc_uint<16> >	crc16_next;
	sc_signal<sc_uint<16> >	crc16_rev;
	sc_signal<bool>			crc16_add;
	sc_signal<bool>			send_data_r2;
	sc_signal<bool>			tx_valid_r;
	sc_signal<bool>			tx_valid_r1;
	sc_signal<bool>			zero_length;
	sc_signal<bool>			zero_length_r;

	usb_crc16				*i_crc16;					// CRC16 Calculator

	// Zero Length Functions
	void zl_up(void);
	void zl_r_up(void);

	// Misc Functions
	void tx_valid_r_up1(void);
	void tx_valid_r_up2(void);
	void send_token_up(void);

	// PID Select Functions
	void token_pid_up(void);
	void data_pid_up(void);

	// Data Path Muxes Functions
	void tx_data_up1(void);
	void tx_data_up2(void);
	void tx_data_up3(void);
	void tx_spec_up(void);

	// TX Valid Assignment Functions
	void tx_valid_up1(void);
	void tx_valid_up2(void);
	void tx_first_up1(void);
	void tx_first_up2(void);

	// CRC Logic Functions
	void send_data_up1(void);
	void send_data_up2(void);
	void crc16_clr_up(void);
	void crc16_din_up(void);
	void crc16_add_up(void);
	void crc16_up(void);
	void crc16_rev_up(void);

	// Transmit/Encode State Machine Functions
	void state_up(void);
	void pa_statemachine(void);

	// Destructor
//	~usb_pa_sie(void);

	SC_CTOR(usb_pa_sie) {
		SC_METHOD(zl_up);
		sensitive << ep_empty;
		SC_METHOD(zl_r_up);
		sensitive << clk.pos() << rst.neg();

		SC_METHOD(tx_valid_r_up1);
		sensitive << clk.pos();
		SC_METHOD(tx_valid_r_up2);
		sensitive << clk.pos();
		SC_METHOD(send_token_up);
		sensitive << clk.pos() << rst.neg();

		SC_METHOD(token_pid_up);
		sensitive << token_pid_sel;
		SC_METHOD(data_pid_up);
		sensitive << data_pid_sel;

		SC_METHOD(tx_data_up1);
		sensitive << dsel << tx_data_st << tx_spec_data;
		SC_METHOD(tx_data_up2);
		sensitive << send_token << send_token_r << token_pid << tx_data_data;
		SC_METHOD(tx_data_up3);
		sensitive << tx_data_d;
		SC_METHOD(tx_spec_up);
		sensitive << crc_sel1 << crc_sel2 << data_pid << crc16_rev;

		SC_METHOD(tx_valid_up1);
		sensitive << send_token << last;
		SC_METHOD(tx_valid_up2);
		sensitive << tx_valid_d;
		SC_METHOD(tx_first_up1);
		sensitive << clk.pos();
		SC_METHOD(tx_first_up2);
		sensitive << send_token << send_data << tx_first_r;

		SC_METHOD(send_data_up1);
		sensitive << clk.pos();
		SC_METHOD(send_data_up2);
		sensitive << clk.pos();
		SC_METHOD(crc16_clr_up);
		sensitive << send_data << send_data_r;
		SC_METHOD(crc16_din_up);
		sensitive << tx_data_st;
		SC_METHOD(crc16_add_up);
		sensitive << clk.pos();
		SC_METHOD(crc16_up);
		sensitive << clk.pos();
		SC_METHOD(crc16_rev_up);
		sensitive << crc16;

		SC_METHOD(state_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(pa_statemachine);
		sensitive << state << send_data << tx_ready << tx_valid_r << zero_length;

		// CRC16 Calculator Instantiation and Binding
		i_crc16 = new usb_crc16("CRC16");
		i_crc16->crc_in(crc16);
		i_crc16->din(crc16_din);
		i_crc16->crc_out(crc16_next);
	}

};

#endif

