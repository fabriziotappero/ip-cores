/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB TX PHY                                                 ////
////                                                             ////
////  SystemC Version: usb_tx_phy.h                              ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_tx_phy.v                               ////
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

#ifndef USB_TX_PHY_H
#define USB_TX_PHY_H

enum TX_STATE {TX_IDLE, TX_SOP, TX_DATA, TX_EOP1, TX_EOP2, TX_WAIT};

SC_MODULE(usb_tx_phy) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;
	sc_in<bool>			fs_ce;
	sc_in<bool>			phy_mode;
	sc_out<bool>		txdp, txdn, txoe;
	sc_in<sc_uint<8> >	DataOut_i;
	sc_in<bool>			TxValid_i;
	sc_out<bool>		TxReady_o;

	sc_signal<sc_uint<3> >	state, next_state;
	sc_signal<bool>			tx_ready, tx_ready_d;
	sc_signal<bool>			ld_sop_d, ld_data, ld_data_d, ld_eop_d;
	sc_signal<bool>			tx_ip, tx_ip_sync;
	sc_signal<sc_uint<3> >	bit_cnt;
	sc_signal<sc_uint<8> >	hold_reg;
	sc_signal<bool>			sd_raw_o;
	sc_signal<bool>			hold;
	sc_signal<bool>			data_done, sft_done, sft_done_r, sft_done_e, eop_done;
	sc_signal<sc_uint<3> >	one_cnt;
	sc_signal<bool>			stuff;
	sc_signal<bool>			sd_bs_o, sd_nrzi_o;
	sc_signal<bool>			append_eop, append_eop_sync1, append_eop_sync2, append_eop_sync3;
	sc_signal<bool>			txoe_r1, txoe_r2;

	void misc_logic_up1(void);
	void misc_logic_up2(void);
	void tpi_up1(void);			// Transmit in Progress Indicator
	void tpi_up2(void);
	void tpi_up3(void);
	void sr_up1(void);			// Shift Register
	void sr_up2(void);
	void sr_up3(void);
	void sr_up4(void);
	void sr_up5(void);
	void sr_hold_up(void);
	void sr_sft_done_e_up(void);
	void bs_up1(void);			// Bit Stuffer
	void bs_up2(void);
	void bs_stuff_up(void);
	void nrzi_up(void);			// NRZI Encoder
	void eop_up1(void);			// EOP Append Logic
	void eop_up2(void);
	void eop_up3(void);
	void eop_up4(void);
	void eop_done_up(void);
	void oel_up1(void);			// Output Enable Logic
	void oel_up2(void);
	void oel_up3(void);
	void or_up(void);			// Output Registers
	void tx_statemachine(void);
	void tx_state_up(void);

	SC_CTOR(usb_tx_phy) {
		SC_METHOD(misc_logic_up1);
		sensitive << clk.pos();
		SC_METHOD(misc_logic_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(tpi_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(tpi_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(tpi_up3);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(sr_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(sr_up2);
		sensitive << clk.pos();
		SC_METHOD(sr_up3);
		sensitive << clk.pos();
		SC_METHOD(sr_up4);
		sensitive << clk.pos();
		SC_METHOD(sr_up5);
		sensitive << clk.pos();
		SC_METHOD(sr_hold_up);
		sensitive << stuff;
		SC_METHOD(sr_sft_done_e_up);
		sensitive << sft_done << sft_done_r;
		SC_METHOD(bs_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(bs_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(bs_stuff_up);
		sensitive << one_cnt;
		SC_METHOD(nrzi_up);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(eop_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(eop_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(eop_up3);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(eop_up4);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(eop_done_up);
		sensitive << append_eop_sync3;
		SC_METHOD(oel_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(oel_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(oel_up3);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(or_up);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(tx_statemachine);
		sensitive << state << TxValid_i << data_done << sft_done_e << eop_done << fs_ce;
		SC_METHOD(tx_state_up);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
	}

};

#endif
