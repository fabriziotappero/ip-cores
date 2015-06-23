/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Module                                         ////
////  Function Interface                                         ////
////                                                             ////
////  SystemC Version: usb_top.cpp                               ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_8051_if.v                              ////
//// Copyright (C) 2003      Alfredo Luiz Foltran Fialho         ////
////                         alfoltran@ig.com.br                 ////
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
#include "usb_top.h"

void usb_top::mux(void) {
	sc_uint<9> sel;

	dout.write("ZZZZZZZZ");
	empty.write(false);
	full.write(false);
	ep1_f_we.write(false);
	ep2_f_re.write(false);
	ep3_f_we.write(false);
	ep4_f_re.write(false);
	ep5_f_we.write(false);
	ep6_f_re.write(false);

	sel = ((sc_uint<1>)cs.read(), (sc_uint<8>)adr.read());

	switch (sel) {// synopsys full_case parallel_case
		case 0:	dout.write("00000000");
				full.write(false);
				empty.write(false);
				break;
		case 1:	ep1_f_din.write(din.read());
				ep1_f_we.write(we.read());
				full.write(ep1_f_full.read());
				break;
		case 2:	dout.write((sc_lv<8>)ep2_f_dout.read());
				ep2_f_re.write(re.read());
				empty.write(ep2_f_empty.read());
				break;
		case 3:	ep3_f_din.write(din.read());
				ep3_f_we.write(we.read());
				full.write(ep3_f_full.read());
				break;
		case 4:	dout.write((sc_lv<8>)ep4_f_dout.read());
				ep4_f_re.write(re.read());
				empty.write(ep4_f_empty.read());
				break;
		case 5:	ep5_f_din.write(din.read());
				ep5_f_we.write(we.read());
				full.write(ep5_f_full.read());
				break;
		case 6:	dout.write((sc_lv<8>)ep6_f_dout.read());
				ep6_f_re.write(re.read());
				empty.write(ep6_f_empty.read());
				break;
		case 8:	dout.write("00000000");
				full.write(false);
				empty.write(false);
				break;
		case 16:dout.write((sc_lv<8>)wValue.read().range(7, 0));
				break;
		case 17:dout.write((sc_lv<8>)wValue.read().range(15, 8));
				break;
		case 18:dout.write((sc_lv<8>)wIndex.read().range(7, 0));
				break;
		case 19:dout.write((sc_lv<8>)wIndex.read().range(15, 8));
				break;
		case 20:vendor_data.write((vendor_data.read().range(15, 8), din.read()));
				break;
		case 21:vendor_data.write((din.read(), vendor_data.read().range(7, 0)));
				break;
	}
}
/*
usb_top::~usb_top(void) {
	if (i_usb)
		delete i_usb;
}
*/
