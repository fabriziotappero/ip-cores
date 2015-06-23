/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB FIFO                                                   ////
////                                                             ////
////  SystemC Version: usb_fifo64x8.h                            ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: generic_fifo_sc_a.v                        ////
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

#ifndef USB_FIFO64X8_H
#define USB_FIFO64X8_H

#include "usb_ram64x8.h"

#define FIFO_ASYNC_RESET
//#define FIFO_ASYNC_RESET << rst.neg()

SC_MODULE(usb_fifo64x8) {

  private:

	sc_signal<bool> vcc;

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;
	sc_in<bool>			clr;
	sc_in<bool>			we;
	sc_in<sc_uint<8> >	din;
	sc_in<bool>			re;
	sc_out<sc_uint<8> >	dout;
	sc_out<bool>		empty;
	sc_out<bool>		full;

	sc_signal<sc_uint<6> >	wp, wp_pl1, wp_pl2;
	sc_signal<sc_uint<6> >	rp, rp_pl1;
	sc_signal<bool>			gb, n_rst;

	usb_ram64x8	*i_ram;

	void write_pointer_update(void);
	void read_pointer_update(void);
	void future_pointers_update(void);
	void fe_gb_update(void);
	void fe_full_update(void);
	void fe_empty_update(void);
	void reset_update(void);
//	~usb_fifo64x8(void);

	SC_CTOR(usb_fifo64x8) {
		vcc.write(true);

		SC_METHOD(write_pointer_update);
		sensitive << clk.pos() FIFO_ASYNC_RESET;
		SC_METHOD(read_pointer_update);
		sensitive << clk.pos() FIFO_ASYNC_RESET;
		SC_METHOD(future_pointers_update);
		sensitive << wp << rp;
		SC_METHOD(fe_gb_update);
		sensitive << clk.pos() FIFO_ASYNC_RESET;
		SC_METHOD(fe_full_update);
		sensitive << clk.pos() FIFO_ASYNC_RESET;
		SC_METHOD(fe_empty_update);
		sensitive << clk.pos() FIFO_ASYNC_RESET;
		SC_METHOD(reset_update);
		sensitive << rst;

		i_ram = new usb_ram64x8("RAM64X8");
		i_ram->rclk(clk);
		i_ram->rrst(n_rst);
		i_ram->rce(vcc);
		i_ram->oe(vcc);
		i_ram->raddr(rp);
		i_ram->dout(dout);
		i_ram->wclk(clk);
		i_ram->wrst(n_rst);
		i_ram->wce(vcc);
		i_ram->we(we);
		i_ram->waddr(wp);
		i_ram->din(din);
	}

};

#endif

