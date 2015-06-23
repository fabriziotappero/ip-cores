/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB IDMA Engine                                            ////
////                                                             ////
////  SystemC Version: usb_dma.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_idma.v                                ////
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

#ifndef USB_DMA_H
#define USB_DMA_H

#include "usb_defines.h"
#include "usb_fifo2.h"

SC_MODULE(usb_dma) {

  public:

	sc_in<bool>		clk;
	sc_in<bool>		rst;

	// PA/PD Interface
	sc_in<bool>			rx_data_valid;
	sc_in<bool>			rx_data_done;
	sc_out<bool>		send_data;
	sc_in<bool>			rd_next;
	sc_in<bool>			tx_valid;
	sc_in<sc_uint<8> >	tx_data_st_i;
	sc_out<sc_uint<8> >	tx_data_st_o;

	// PE Interface
	sc_in<bool>			tx_dma_en;
	sc_in<bool>			rx_dma_en;
	sc_out<bool>		idma_done;		// DMA is done
	sc_in<sc_uint<4> >	ep_sel;

	// Register File Manager Interface
	sc_in<sc_uint<9> >	size;			// Max PL size in bytes
	sc_out<sc_uint<8> >	rx_cnt;
	sc_out<bool>		rx_done;
	sc_out<bool>		tx_busy;

	// Memory Arbiter Interface
	sc_out<bool>		mwe;			// Memory Write Enable
	sc_out<bool>		mre;			// Memory Read Enable
	sc_in<bool>			ep_empty;
	sc_out<bool>		ep_empty_int;
	sc_in<bool>			ep_full;

	// Local Signals
	sc_signal<bool>			tx_dma_en_r;
	sc_signal<sc_uint<9> >	sizd_c;	// Internal Size Counter
	sc_signal<bool>			adr_incw;
	sc_signal<bool>			adr_incb;
	sc_signal<bool>			siz_dec;
	sc_signal<bool>			mwe_r;
	sc_signal<bool>			sizd_is_zero;	// Indicates when all bytes have been transferred
	sc_signal<bool>			sizd_is_zero_d;
	sc_signal<bool>			rx_data_done_r;
	sc_signal<bool>			rx_data_valid_r;
	sc_signal<bool>			ff_re, ff_full, ff_empty;
	sc_signal<bool>			ff_we, ff_we1;
	sc_signal<bool>			tx_dma_en_r1;
	sc_signal<bool>			tx_dma_en_r2;
	sc_signal<bool>			tx_dma_en_r3;
	sc_signal<bool>			send_data_r;
	sc_signal<bool>			ff_clr;
	sc_signal<sc_uint<8> >	rx_cnt_r;
	sc_signal<bool>			ep_empty_r;
	sc_signal<bool>			ep_full_int;
	sc_signal<bool>			tx_valid_r;
	sc_signal<bool>			tx_valid_e;

	usb_fifo2		*i_ff2;			// IDMA fast prefetch FIFO

	// Empty/Full Logic Functions
	void empty_int_up(void);
	void full_int_up(void);

	// FIFO Interface Functions
	void mwe_up1(void);
	void mwe_up2(void);

	// Misc Logic Functions
	void data_valid_up(void);
	void data_done_up(void);

	// TX DMA Enable Functions
	void tx_dma_en_up1(void);
	void tx_dma_en_up2(void);
	void tx_dma_en_up3(void);

	// DMA Done Indicator Function
	void idma_done_up(void);

	// RX DMA Done Indicator Functions
	void rx_cnt_up1(void);
	void rx_cnt_up2(void);
	void rx_done_up(void);

	// TX DMA Done Indicator Functions
	void sizd_cnt_up(void);
	void is_zero_up1(void);
	void is_zero_up2(void);
	void siz_dec_up(void);

	// TX DMA Logic Functions
	void tx_busy_up(void);
	void tx_valid_up1(void);
	void tx_valid_up2(void);
	void empty_up(void);
	void send_data_up1(void);
	void send_data_up2(void);
	void mre_up(void);
	void ff_we_up1(void);
	void ff_we_up2(void);
	void ff_re_up(void);
	void ff_clr_up(void);

	// Destructor
//	~usb_dma(void);

	SC_CTOR(usb_dma) {
		SC_METHOD(empty_int_up);
		sensitive << ep_empty;
		SC_METHOD(full_int_up);
		sensitive << ep_full;

		SC_METHOD(mwe_up1);
		sensitive << clk.pos();
		SC_METHOD(mwe_up2);
		sensitive << mwe_r << ep_full_int;

		SC_METHOD(data_valid_up);
		sensitive << clk.pos();
		SC_METHOD(data_done_up);
		sensitive << clk.pos();

		SC_METHOD(tx_dma_en_up1);
		sensitive << clk.pos();
		SC_METHOD(tx_dma_en_up2);
		sensitive << clk.pos();
		SC_METHOD(tx_dma_en_up3);
		sensitive << clk.pos();

		SC_METHOD(idma_done_up);
		sensitive << clk.pos();

		SC_METHOD(rx_cnt_up1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rx_cnt_up2);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rx_done_up);
		sensitive << rx_data_done_r;

		SC_METHOD(sizd_cnt_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(is_zero_up1);
		sensitive << sizd_c;
		SC_METHOD(is_zero_up2);
		sensitive << clk.pos();
		SC_METHOD(siz_dec_up);
		sensitive << tx_dma_en_r << tx_dma_en_r1 << rd_next << sizd_is_zero_d;

		SC_METHOD(tx_busy_up);
		sensitive << send_data << tx_dma_en_r << tx_dma_en;
		SC_METHOD(tx_valid_up1);
		sensitive << clk.pos();
		SC_METHOD(tx_valid_up2);
		sensitive << tx_valid_r << tx_valid;
		SC_METHOD(empty_up);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(send_data_up1);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(send_data_up2);
		sensitive << send_data_r << ep_empty_r << sizd_is_zero << size << tx_dma_en_r1;
		SC_METHOD(mre_up);
		sensitive << tx_dma_en_r1 << tx_dma_en_r << rd_next << sizd_is_zero_d << ep_empty_int << send_data;
		SC_METHOD(ff_we_up1);
		sensitive << clk.pos();
		SC_METHOD(ff_we_up2);
		sensitive << clk.pos();
		SC_METHOD(ff_re_up);
		sensitive << rd_next;
		SC_METHOD(ff_clr_up);
		sensitive << tx_valid;

		// IDMA FIFO Instantiation and Binding
		i_ff2 = new usb_fifo2("FIFO2");
		i_ff2->clk(clk);
		i_ff2->rst(rst);
		i_ff2->clr(ff_clr);
		i_ff2->din(tx_data_st_i);
		i_ff2->we(ff_we);
		i_ff2->dout(tx_data_st_o);
		i_ff2->re(ff_re);
	}

};

#endif

