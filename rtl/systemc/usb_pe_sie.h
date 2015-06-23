/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Protocol Engine                                        ////
////  Performs automatic protocol functions                      ////
////                                                             ////
////  SystemC Version: usb_pe_sie.h                              ////
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

#ifndef USB_PE_SIE_H
#define USB_PE_SIE_H

#include "usb_defines.h"

// TX Token Decoding
enum PE_TX_TOKEN {PE_ACK, PE_NACK, PE_STALL, PE_NYET};

// State Decoding
enum PE_STATE {	PE_IDLE = 1,
				PE_TOKEN = 2,
				PE_IN = 4,
				PE_IN2 = 8,
				PE_OUT = 16,
				PE_OUT2A = 32,
				PE_OUT2B = 64,
				PE_UPDATEW = 128,
				PE_UPDATE = 256,
				PE_UPDATE2 = 512};

SC_MODULE(usb_pe_sie) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;

	// PL Interface
	sc_in<bool>			tx_valid;
	sc_in<bool>			rx_active;

	// PD Interface
	// Decoded PIDs (used when token_valid is asserted)
	sc_in<bool>			pid_OUT, pid_IN, pid_SOF, pid_SETUP;
	sc_in<bool>			pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
	sc_in<bool>			pid_ACK, pid_PING;
	sc_in<bool>			token_valid;				// Token is valid
	sc_in<bool>			rx_data_done;				// Indicates end of a transfer
	sc_in<bool>			crc16_err;					// Data packet CRC16 error

	// PA Interface
	sc_out<bool>		send_token;
	sc_out<sc_uint<2> >	token_pid_sel;
	sc_out<sc_uint<2> >	data_pid_sel;

	// IDMA Interface
	sc_out<bool>		rx_dma_en;					// Allows the data to be stored
	sc_out<bool>		tx_dma_en;					// Allows for data to be retrieved
	sc_out<bool>		abort;						// Abort transfer (time out, CRC error or RX error)
	sc_in<bool>			idma_done;					// DMA is done indicator
	sc_in<bool>			ep_full;					// Indicates the endpoints FIFOs is full
	sc_in<bool>			ep_empty;					// Indicates the endpoints FIFOs is empty

	// Register File Interface
	sc_in<bool>			fsel;						// This function is selected
	sc_in<sc_uint<4> >	ep_sel;						// Endpoint Number Input
	sc_in<bool>			match;						// Endpoint Matched
	sc_out<bool>		nse_err;					// No such endpoint error
	sc_out<bool>		int_upid_set;				// Set unsupported PID interrupt
	sc_out<bool>		int_crc16_set;				// Set CRC16 error interrupt
	sc_out<bool>		int_to_set;					// Set time out interrupt
	sc_out<bool>		int_seqerr_set;				// Set PID sequence error interrupt
	sc_in<sc_uint<14> >	csr;						// Internal CSR Output
	sc_in<bool>			send_stall;					// Force sending a STALL during setup

	// Local Signals
	sc_signal<sc_uint<2> >	token_pid_sel_d;
	sc_signal<bool>			send_token_d;
	sc_signal<bool>			int_seqerr_set_d;
	sc_signal<bool>			match_r;

	// Endpoint Decoding
	sc_signal<bool>			IN_ep, OUT_ep, CTRL_ep;			// Endpoint Types
	sc_signal<bool>			txfr_iso, txfr_bulk, txfr_int;	// Transfer Types

	sc_signal<sc_uint<2> >	uc_dpd;

	// Buffer checks
	sc_signal<sc_uint<10> >	state, next_state;// synopsys state_vector state

	// PID next and current decoders
	sc_signal<sc_uint<2> >	next_dpid;
	sc_signal<sc_uint<2> >	this_dpid;
	sc_signal<bool>			pid_seq_err;
	sc_signal<sc_uint<2> >	tr_fr_d;

	sc_signal<sc_uint<14> >	size_next;
	sc_signal<bool>			buf_smaller;

	// After sending data in response to an IN token from host, the
	// host must reply with an ack. The host has XXXnS to reply.
	// "rx_ack_to" indicates when this time has expired.
	// rx_ack_to_clr, clears the timer
	sc_signal<bool>			rx_ack_to_clr;
	sc_signal<bool>			rx_ack_to_clr_d;
	sc_signal<bool>			rx_ack_to;
	sc_signal<sc_uint<8> >	rx_ack_to_cnt;

	// After sending a OUT token the host must send a data packet,
	// the host has XXXnS to send the packet. "tx_data_to" indicates
	// when this time has expired.
	// tx_data_to_clr, clears the timer
	sc_signal<bool>			tx_data_to_clr;
	sc_signal<bool>			tx_data_to;
	sc_signal<sc_uint<8> >	tx_data_to_cnt;

	sc_signal<sc_uint<8> >	rx_ack_to_val, tx_data_to_val;
	sc_signal<sc_uint<2> >	next_bsel;
	sc_signal<bool>			uc_stat_set_d;
	sc_signal<bool>			uc_dpd_set;
	sc_signal<bool>			in_token;
	sc_signal<bool>			out_token;
	sc_signal<bool>			setup_token;
	sc_signal<bool>			in_op, out_op;				// Indicate a IN or OUT operation
	sc_signal<sc_uint<2> >	allow_pid;
	sc_signal<sc_uint<2> >	ep_type, txfr_type;

	sc_signal<sc_uint<2> >	ep0_dpid, ep1_dpid, ep2_dpid, ep3_dpid;
	sc_signal<sc_uint<2> >	ep4_dpid, ep5_dpid, ep6_dpid, ep7_dpid;
	sc_signal<bool>			pid_OUT_r, pid_IN_r, pid_PING_r, pid_SETUP_r;
	sc_signal<bool>			send_stall_r;

	// Misc Functions
	void csr_decoder(void);
	void match_up(void);
	void nse_err_up(void);
	void send_token_up(void);
	void token_pid_sel_up(void);

	// Data PID Storage Functions
	void ep0_dpid_up(void);
	void ep1_dpid_up(void);
	void ep2_dpid_up(void);
	void ep3_dpid_up(void);
	void ep4_dpid_up(void);
	void ep5_dpid_up(void);
	void ep6_dpid_up(void);
	void ep7_dpid_up(void);
	void uc_dpd_up(void);

	// Data PID Sequencer Function
	void sq_statemachine(void);

	// Current PID Decoder Functions
	void allow_pid_up(void);
	void this_dpid_up(void);
	void data_pid_sel_up(void);
	void pid_seq_err_up(void);

	// IDMA Setup and Buffer Select Functions
	void in_token_up(void);
	void out_token_up(void);
	void setup_token_up(void);
	void in_op_up(void);
	void out_op_up(void);

	// Register File Update Logic Functions
	void uc_dpd_set_up(void);
	void abort_up(void);

	// Time Out Functions
	void rx_ack_up1(void);
	void rx_ack_up2(void);
	void rx_ack_up3(void);

	void tx_data_up1(void);
	void tx_data_up2(void);
	void tx_data_up3(void);

	// Interrupts Functions
	void pid_OUT_up(void);
	void pid_IN_up(void);
	void pid_PING_up(void);
	void pid_SETUP_up(void);
	void int_upid_up(void);
	void int_to_up(void);
	void int_crc16_up(void);
	void int_seqerr_up(void);

	void send_stall_up(void);

	// Main Protocol State Machine Functions
	void state_up(void);
	void pe_statemachine(void);

	SC_CTOR(usb_pe_sie) {
		tr_fr_d.write(0);
		rx_ack_to_val.write(USBF_RX_ACK_TO_VAL_FS);
		tx_data_to_val.write(USBF_TX_DATA_TO_VAL_FS);

		SC_METHOD(csr_decoder);
		sensitive << csr;
		SC_METHOD(match_up);
		sensitive << clk.pos();
		SC_METHOD(nse_err_up);
		sensitive << clk.pos();
		SC_METHOD(send_token_up);
		sensitive << clk.pos();
		SC_METHOD(token_pid_sel_up);
		sensitive << clk.pos();

		SC_METHOD(ep0_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep1_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep2_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep3_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep4_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep5_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep6_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(ep7_dpid_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(uc_dpd_up);
		sensitive << clk.pos();

		SC_METHOD(sq_statemachine);
		sensitive << clk.pos();

		SC_METHOD(allow_pid_up);
		sensitive << pid_DATA0 << pid_DATA1 << pid_DATA2 << pid_MDATA;
		SC_METHOD(this_dpid_up);
		sensitive << clk.pos();
		SC_METHOD(data_pid_sel_up);
		sensitive << this_dpid;
		SC_METHOD(pid_seq_err_up);
		sensitive << clk.pos();

		SC_METHOD(in_token_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(out_token_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(setup_token_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(in_op_up);
		sensitive << IN_ep << CTRL_ep << in_token;
		SC_METHOD(out_op_up);
		sensitive << OUT_ep << CTRL_ep << out_token;

		SC_METHOD(uc_dpd_set_up);
		sensitive << clk.pos();
		SC_METHOD(abort_up);
		sensitive << clk.pos();

		SC_METHOD(rx_ack_up1);
		sensitive << clk.pos();
		SC_METHOD(rx_ack_up2);
		sensitive << clk.pos();
		SC_METHOD(rx_ack_up3);
		sensitive << clk.pos();

		SC_METHOD(tx_data_up1);
		sensitive << rx_active;
		SC_METHOD(tx_data_up2);
		sensitive << clk.pos();
		SC_METHOD(tx_data_up3);
		sensitive << clk.pos();

		SC_METHOD(pid_OUT_up);
		sensitive << clk.pos();
		SC_METHOD(pid_IN_up);
		sensitive << clk.pos();
		SC_METHOD(pid_PING_up);
		sensitive << clk.pos();
		SC_METHOD(pid_SETUP_up);
		sensitive << clk.pos();
		SC_METHOD(int_upid_up);
		sensitive << clk.pos();
		SC_METHOD(int_to_up);
		sensitive << state << rx_ack_to << tx_data_to;
		SC_METHOD(int_crc16_up);
		sensitive << rx_data_done << crc16_err;
		SC_METHOD(int_seqerr_up);
		sensitive << clk.pos();

		SC_METHOD(send_stall_up);
		sensitive << clk.pos() << rst.neg();

		SC_METHOD(state_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(pe_statemachine);
		sensitive << state << pid_seq_err << idma_done << ep_full << ep_empty;
		sensitive << token_valid << pid_ACK << rx_data_done << tx_data_to << crc16_err;
		sensitive << rx_ack_to << pid_PING << txfr_iso << txfr_int << CTRL_ep;
		sensitive << pid_IN << pid_OUT << IN_ep << OUT_ep << pid_SETUP << pid_SOF;
		sensitive << match_r << abort << send_stall_r << send_stall;
	}

};

#endif

