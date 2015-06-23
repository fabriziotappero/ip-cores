/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB RAM                                                    ////
////                                                             ////
////  SystemC Version: usb_ram128x8.h                            ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: generic_dpram.v                            ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                ////
////                         www.opencores.org                   ////
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

#ifndef USB_RAM128X8_H
#define USB_RAM128X8_H

SC_MODULE(usb_ram128x8) {

  public:

	sc_in<bool>			rclk, rrst, rce;
	sc_in<bool>			oe;
	sc_in<sc_uint<7> >	raddr;
	sc_out<sc_uint<8> >	dout;

	sc_in<bool>			wclk, wrst, wce;
	sc_in<bool>			we;
	sc_in<sc_uint<7> >	waddr;
	sc_in<sc_uint<8> >	din;

	sc_signal<sc_uint<8> > 	dout_reg;

	sc_uint<8>				mem[128];

	void dout_update(void);
	void read(void);
	void write(void);

	SC_CTOR(usb_ram128x8) {
		SC_METHOD(dout_update);
		sensitive << oe << rce << dout_reg;
		SC_METHOD(read);
		sensitive << rclk.pos();
		SC_METHOD(write);
		sensitive << wclk.pos();
	}

};

#endif

