/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB RX PHY                                                 ////
////                                                             ////
////  SystemC Version: usb_rx_phy.h                              ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_rx_phy.v                               ////
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

#ifndef USB_RX_PHY_H
#define USB_RX_PHY_H

enum RX_STATE {FS_IDLE, K1, J1, K2, J2, K3, J3, K4};

SC_MODULE(usb_rx_phy) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;
	sc_out<bool>		fs_ce;
	sc_in<bool>			rxd, rxdp, rxdn;
	sc_out<sc_uint<8> >	DataIn_o;
	sc_out<bool>		RxValid_o;
	sc_out<bool>		RxActive_o;
	sc_out<bool>		RxError_o;
	sc_in<bool>			RxEn_i;
	sc_out<sc_uint<2> >	LineState;

	sc_signal<bool>			rxd_t1, rxd_s1, rxd_s;
	sc_signal<bool>			rxdp_t1, rxdp_s1, rxdp_s;
	sc_signal<bool>			rxdn_t1, rxdn_s1, rxdn_s;
	sc_signal<bool>			synced_d;
	sc_signal<bool>			k, j, se0;
	sc_signal<bool>			rx_en, rx_active;
	sc_signal<sc_uint<3> >	bit_cnt;
	sc_signal<bool>			rx_valid, rx_valid1, rx_valid_r;
	sc_signal<bool>			shift_en;
	sc_signal<bool>			sd_r, sd_nrzi;
	sc_signal<sc_uint<8> >	hold_reg;
	sc_signal<bool>			drop_bit;
	sc_signal<sc_uint<3> >	one_cnt;
	sc_signal<sc_uint<2> >	dpll_state, dpll_next_state;
	sc_signal<bool>			fs_ce_d, change;
	sc_signal<bool>			rxdp_s1r, rxdn_s1r;
	sc_signal<bool>			lock_en;
	sc_signal<bool>			fs_ce_r1, fs_ce_r2, fs_ce_r3;
	sc_signal<sc_uint<3> >	fs_state, fs_next_state;

	void rx_error_init(void);
	void misc_logic_up(void);
	void misc_logic_RxActive_up(void);
	void misc_logic_RxValid_up(void);
	void misc_logic_DataIn_up(void);
	void misc_logic_LineState_up(void);
	void si_up1(void);				// Synchronize Inputs
	void si_up2(void);
	void si_up3(void);
	void si_up4(void);
	void dpll_up1(void);
	void dpll_up2(void);
	void dpll_up3(void);
	void dpll_up4(void);
	void dpll_up5(void);
	void dpll_up6(void);
	void dpll_up7(void);
	void dpll_up8(void);
	void dpll_statemachine(void);
	void fsp_up(void);				// Find Sync Pattern
	void fsp_statemachine(void);
	void gra_up1(void);				// Generate RxActive
	void gra_up2(void);
	void nrzi_up1(void);			// NRZI Decoder
	void nrzi_up2(void);
	void bsd_up1(void);				// Bit Stuff Detect
	void bsd_up2(void);
	void spc_up1(void);				// Serial/Parallel Converter
	void spc_up2(void);
	void grv_up1(void);				// Generate RxValid
	void grv_up2(void);
	void grv_up3(void);

	SC_CTOR(usb_rx_phy) {
		#ifdef USB_SIMULATION
			SC_METHOD(rx_error_init);
		#else
			RxError_o.write(false);
		#endif
		SC_METHOD(misc_logic_up);
		sensitive << clk.pos();
		SC_METHOD(misc_logic_RxActive_up);
		sensitive << rx_active;
		SC_METHOD(misc_logic_RxValid_up);
		sensitive << rx_valid;
		SC_METHOD(misc_logic_DataIn_up);
		sensitive << hold_reg;
		SC_METHOD(misc_logic_LineState_up);
		sensitive << rxdp_s1 << rxdn_s1;
		SC_METHOD(si_up1);
		sensitive << clk.pos();
		SC_METHOD(si_up2);
		sensitive << clk.pos();
		SC_METHOD(si_up3);
		sensitive << clk.pos();
		SC_METHOD(si_up4);
		sensitive << rxdp_s << rxdn_s;
		SC_METHOD(dpll_up1);
		sensitive << rx_en;
		SC_METHOD(dpll_up2);
		sensitive << clk.pos();
		SC_METHOD(dpll_up3);
		sensitive << rxdp_s1 << rxdp_s1r << rxdn_s1 << rxdn_s1r;
		SC_METHOD(dpll_up4);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(dpll_up5);
		sensitive << clk.pos();
		SC_METHOD(dpll_up6);
		sensitive << clk.pos();
		SC_METHOD(dpll_up7);
		sensitive << clk.pos();
		SC_METHOD(dpll_up8);
		sensitive << clk.pos();
		SC_METHOD(dpll_statemachine);
		sensitive << dpll_state << lock_en << change;
		SC_METHOD(fsp_up);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(fsp_statemachine);
		sensitive << fs_state << fs_ce << k << j << rx_en;
		SC_METHOD(gra_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(gra_up2);
		sensitive << clk.pos();
		SC_METHOD(nrzi_up1);
		sensitive << clk.pos();
		SC_METHOD(nrzi_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(bsd_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(bsd_up2);
		sensitive << one_cnt;
		SC_METHOD(spc_up1);
		sensitive << clk.pos();
		SC_METHOD(spc_up2);
		sensitive << clk.pos();
		SC_METHOD(grv_up1);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(grv_up2);
		sensitive << clk.pos();
		#ifdef USB_ASYNC_RESET
			sensitive << rst.neg();
		#endif
		SC_METHOD(grv_up3);
		sensitive << clk.pos();
	}

};

#endif
