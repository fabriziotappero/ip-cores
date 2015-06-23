/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB SIE                                                    ////
////                                                             ////
////  SystemC Version: usb_sie.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_utmi_if.v + usb1_pl.v                 ////
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

#ifndef USB_SIE_H
#define USB_SIE_H

#include "usb_defines.h"

#include "usb_pa_sie.h"
#include "usb_pd_sie.h"
#include "usb_pe_sie.h"
#include "usb_dma.h"

SC_MODULE(usb_sie) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;

	// PHY Interface
	sc_out<sc_uint<8> >	DataOut;
	sc_out<bool>		TxValid;
	sc_in<bool>			TxReady;
	sc_in<sc_uint<8> >	DataIn;
	sc_in<bool>			RxValid;
	sc_in<bool>			RxActive;
	sc_in<bool>			RxError;

	sc_out<bool>		token_valid;

	// Register File Interface
	sc_in<sc_uint<7> >	fa;				// Function Address (as set by the controller)
	sc_out<sc_uint<4> >	ep_sel;			// Endpoint Number Input
	sc_out<bool>		x_busy;			// Indicates USB is busy

	sc_out<bool>		int_crc16_set;	// Set CRC16 Error Interrupt
	sc_out<bool>		int_to_set;		// Set Time Out Interrupt
	sc_out<bool>		int_seqerr_set;	// Set PID Sequence Error Interrupt

	// Misc and Control Interface
	sc_out<bool>		pid_cs_err;		// PID Checksum error
	sc_out<bool>		crc5_err;		// CRC5 Error
	sc_out<sc_uint<32> >frm_nat;
	sc_out<bool>		nse_err;		// No such endpoint error
	sc_out<sc_uint<8> >	rx_size;
	sc_out<bool>		rx_done;
	sc_out<bool>		ctrl_setup;
	sc_out<bool>		ctrl_in;
	sc_out<bool>		ctrl_out;

	// Endpoint Interface
	sc_in<sc_uint<14> >	csr;
	sc_in<sc_uint<8> >	tx_data_st;
	sc_out<sc_uint<8> >	rx_data_st;
	sc_out<bool>		idma_re, idma_we;
	sc_in<bool>			ep_empty, ep_full;
	sc_in<bool>			send_stall;

	// Signals

	// PHY Interface
	sc_signal<sc_uint<8> >	tx_data;
	sc_signal<bool>			TxValid_s, tx_valid, tx_valid_last, tx_ready, tx_first;
	sc_signal<sc_uint<8> >	rx_data;
	sc_signal<bool>			rx_valid, rx_active, rx_err;

	// Packet Disassembler Interface
	sc_signal<bool>			pid_OUT, pid_IN, pid_SOF, pid_SETUP;
	sc_signal<bool>			pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
	sc_signal<bool>			pid_ACK, pid_NACK, pid_STALL, pid_NYET;
	sc_signal<bool>			pid_PRE, pid_ERR, pid_SPLIT, pid_PING;
	sc_signal<sc_uint<7> >	token_fadr;
	sc_signal<sc_uint<11> >	frame_no;
	sc_signal<sc_uint<8> >	rx_data_st_d;
	sc_signal<bool>			rx_data_valid, rx_data_done;
	sc_signal<bool>			crc16_err, rx_seq_err;

	// Packet Assembler Interface
	sc_signal<bool>			send_token;
	sc_signal<sc_uint<2> >	token_pid_sel;
	sc_signal<bool>			send_data;
	sc_signal<sc_uint<2> >	data_pid_sel;
	sc_signal<sc_uint<8> >	tx_data_st_o;
	sc_signal<bool>			rd_next;

	// IDMA Interface
	sc_signal<bool>			rx_dma_en, tx_dma_en;
	sc_signal<bool>			abort, idma_done;

	// Local Signals
	sc_signal<sc_uint<9> >	csr9;
	sc_signal<bool>			pid_bad;
	sc_signal<bool>			hms_clk;		// 0.5 Micro Seconds Clock
	sc_signal<sc_uint<5> >	hms_cnt;
	sc_signal<sc_uint<11> >	frame_no_r;		// Current Frame Number Register
	sc_signal<bool>			frame_no_we;
	sc_signal<sc_uint<12> >	sof_time;		// Time since last SOF
	sc_signal<bool>			clr_sof_time;
	sc_signal<bool>			fsel;			// This function is selected
	sc_signal<bool>			match_o;

	sc_signal<bool>			frame_no_we_r;
	sc_signal<bool>			idma_we_d;
	sc_signal<bool>			ep_empty_int;
	sc_signal<bool>			tx_busy, rx_busy;
	sc_signal<bool>			int_upid_set;

	usb_pa_sie				*i_pa_sie;		// Packet Assembler
	usb_pd_sie				*i_pd_sie;		// Packet Disassembler
	usb_pe_sie				*i_pe_sie;		// Protocol Engine
	usb_dma					*i_dma;			// Internal DMA

	// PHY Functions
	void tx_interface1(void);
	void tx_interface2(void);
	void tx_interface3(void);
	void rx_interface1(void);
	void rx_interface2(void);

	// Misc Functions
	void csr9_up(void);
	void x_busy_up(void);
	void pid_bad_up(void);
	void match_o_up(void);
	void rx_data_st_up(void);

	// Receive Packet Decoder Function
	void decoder_pk(void);

	// Frame Number Update Functions
	void frame_no_up1(void);
	void frame_no_up2(void);
	void frame_no_up3(void);

	// SOF Delay Counter Functions
	void frm_nat_up1(void);
	void frm_nat_up2(void);
	void frm_nat_up3(void);

	// 0.5 Micro Seconds Clock Generator Functions
	void hms_clk_up1(void);
	void hms_clk_up2(void);

	// "Is function addressed?" Functions
	void fsel_up(void);
	void idma_we_up(void);

	// Destructor
//	~usb_sie(void);

	SC_CTOR(usb_sie) {
		SC_METHOD(tx_interface1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(tx_interface2);
		sensitive << clk.pos();
		SC_METHOD(tx_interface3);
		sensitive << TxValid_s;
		SC_METHOD(rx_interface1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rx_interface2);
		sensitive << clk.pos();

		SC_METHOD(csr9_up);
		sensitive << csr;
		SC_METHOD(x_busy_up);
		sensitive << tx_busy << rx_busy;
		SC_METHOD(pid_bad_up);
		sensitive << pid_ACK << pid_NACK << pid_STALL << pid_NYET;
		sensitive << pid_PRE << pid_ERR << pid_SPLIT << pid_PING;
		SC_METHOD(match_o_up);
		sensitive << pid_bad << token_valid << crc5_err;
		SC_METHOD(rx_data_st_up);
		sensitive << clk.pos();

		SC_METHOD(decoder_pk);
		sensitive << clk.pos();

		SC_METHOD(frame_no_up1);
		sensitive << token_valid << crc5_err << pid_SOF;
		SC_METHOD(frame_no_up2);
		sensitive << clk.pos();
		SC_METHOD(frame_no_up3);
		sensitive << clk.pos() << rst.neg();

		SC_METHOD(frm_nat_up1);
		sensitive << clk.pos();
		SC_METHOD(frm_nat_up2);
		sensitive << clk.pos();
		SC_METHOD(frm_nat_up3);
		sensitive << frame_no_r << sof_time;

		SC_METHOD(hms_clk_up1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(hms_clk_up2);
		sensitive << clk.pos();

		SC_METHOD(fsel_up);
		sensitive << token_fadr << fa;
		SC_METHOD(idma_we_up);
		sensitive << idma_we_d << fsel;

		// Packet Assembler Instantiation and Binding
		i_pa_sie = new usb_pa_sie("PA_SIE");
		i_pa_sie->clk(clk);
		i_pa_sie->rst(rst);
		i_pa_sie->tx_data(tx_data);
		i_pa_sie->tx_valid(tx_valid);
		i_pa_sie->tx_valid_last(tx_valid_last);
		i_pa_sie->tx_ready(tx_ready);
		i_pa_sie->tx_first(tx_first);
		i_pa_sie->send_token(send_token);
		i_pa_sie->token_pid_sel(token_pid_sel);
		i_pa_sie->send_data(send_data);
		i_pa_sie->data_pid_sel(data_pid_sel);
		i_pa_sie->tx_data_st(tx_data_st_o);
		i_pa_sie->rd_next(rd_next);
		i_pa_sie->ep_empty(ep_empty_int);

		// Packet Disassembler Instantiation and Binding
		i_pd_sie = new usb_pd_sie("PD_SIE");
		i_pd_sie->clk(clk);
		i_pd_sie->rst(rst);
		i_pd_sie->rx_data(rx_data);
		i_pd_sie->rx_valid(rx_valid);
		i_pd_sie->rx_active(rx_active);
		i_pd_sie->rx_err(rx_err);
		i_pd_sie->pid_OUT(pid_OUT);
		i_pd_sie->pid_IN(pid_IN);
		i_pd_sie->pid_SOF(pid_SOF);
		i_pd_sie->pid_SETUP(pid_SETUP);
		i_pd_sie->pid_DATA0(pid_DATA0);
		i_pd_sie->pid_DATA1(pid_DATA1);
		i_pd_sie->pid_DATA2(pid_DATA2);
		i_pd_sie->pid_MDATA(pid_MDATA);
		i_pd_sie->pid_ACK(pid_ACK);
		i_pd_sie->pid_NACK(pid_NACK);
		i_pd_sie->pid_STALL(pid_STALL);
		i_pd_sie->pid_NYET(pid_NYET);
		i_pd_sie->pid_PRE(pid_PRE);
		i_pd_sie->pid_ERR(pid_ERR);
		i_pd_sie->pid_SPLIT(pid_SPLIT);
		i_pd_sie->pid_PING(pid_PING);
		i_pd_sie->pid_cks_err(pid_cs_err);
		i_pd_sie->token_fadr(token_fadr);
		i_pd_sie->token_endp(ep_sel);
		i_pd_sie->token_valid(token_valid);
		i_pd_sie->crc5_err(crc5_err);
		i_pd_sie->frame_no(frame_no);
		i_pd_sie->rx_data_st(rx_data_st_d);
		i_pd_sie->rx_data_valid(rx_data_valid);
		i_pd_sie->rx_data_done(rx_data_done);
		i_pd_sie->crc16_err(crc16_err);
		i_pd_sie->seq_err(rx_seq_err);
		i_pd_sie->rx_busy(rx_busy);

		// Protocol Engine Instantiation and Binding
		i_pe_sie = new usb_pe_sie("PE_SIE");
		i_pe_sie->clk(clk);
		i_pe_sie->rst(rst);
		i_pe_sie->tx_valid(TxValid_s);
		i_pe_sie->rx_active(rx_active);
		i_pe_sie->pid_OUT(pid_OUT);
		i_pe_sie->pid_IN(pid_IN);
		i_pe_sie->pid_SOF(pid_SOF);
		i_pe_sie->pid_SETUP(pid_SETUP);
		i_pe_sie->pid_DATA0(pid_DATA0);
		i_pe_sie->pid_DATA1(pid_DATA1);
		i_pe_sie->pid_DATA2(pid_DATA2);
		i_pe_sie->pid_MDATA(pid_MDATA);
		i_pe_sie->pid_ACK(pid_ACK);
		i_pe_sie->pid_PING(pid_PING);
		i_pe_sie->token_valid(token_valid);
		i_pe_sie->rx_data_done(rx_data_done);
		i_pe_sie->crc16_err(crc16_err);
		i_pe_sie->send_token(send_token);
		i_pe_sie->token_pid_sel(token_pid_sel);
		i_pe_sie->data_pid_sel(data_pid_sel);
		i_pe_sie->rx_dma_en(rx_dma_en);
		i_pe_sie->tx_dma_en(tx_dma_en);
		i_pe_sie->abort(abort);
		i_pe_sie->idma_done(idma_done);
		i_pe_sie->fsel(fsel);
		i_pe_sie->ep_sel(ep_sel);
		i_pe_sie->ep_full(ep_full);
		i_pe_sie->ep_empty(ep_empty);
		i_pe_sie->match(match_o);
		i_pe_sie->nse_err(nse_err);
		i_pe_sie->int_upid_set(int_upid_set);
		i_pe_sie->int_crc16_set(int_crc16_set);
		i_pe_sie->int_to_set(int_to_set);
		i_pe_sie->int_seqerr_set(int_seqerr_set);
		i_pe_sie->csr(csr);
		i_pe_sie->send_stall(send_stall);

		// Internal DMA / Memory Arbiter Interface Instantiation and Binding
		i_dma = new usb_dma("DMA");
		i_dma->clk(clk);
		i_dma->rst(rst);
		i_dma->tx_valid(tx_valid);
		i_dma->rx_data_valid(rx_data_valid);
		i_dma->rx_data_done(rx_data_done);
		i_dma->send_data(send_data);
		i_dma->rd_next(rd_next);
		i_dma->tx_data_st_i(tx_data_st);
		i_dma->tx_data_st_o(tx_data_st_o);
		i_dma->ep_sel(ep_sel);
		i_dma->tx_busy(tx_busy);
		i_dma->tx_dma_en(tx_dma_en);
		i_dma->rx_dma_en(rx_dma_en);
		i_dma->idma_done(idma_done);
		i_dma->size(csr9);
		i_dma->rx_cnt(rx_size);
		i_dma->rx_done(rx_done);
		i_dma->mwe(idma_we_d);
		i_dma->mre(idma_re);
		i_dma->ep_empty(ep_empty);
		i_dma->ep_empty_int(ep_empty_int);
		i_dma->ep_full(ep_full);
	}

};

#endif

