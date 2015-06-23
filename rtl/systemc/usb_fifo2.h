/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Fast FIFO - 2 Entries Deep                             ////
////                                                             ////
////  SystemC Version: usb_fifo2.h                               ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_fifo2.v                               ////
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

#ifndef USB_FIFO2_H
#define USB_FIFO2_H

SC_MODULE(usb_fifo2) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;
	sc_in<bool>			clr;
	sc_in<sc_uint<8> >	din;
	sc_in<bool>			we;
	sc_out<sc_uint<8> >	dout;
	sc_in<bool>			re;

	// Local Signals
	sc_uint<8>		mem[2];
	sc_signal<bool>	wp;
	sc_signal<bool>	rp;

	// Write and Read Pointers Update Functions
	void wp_update(void);
	void rp_update(void);

	// Write and Read FIFO Functions
	void write(void);
	void read(void);

	SC_CTOR(usb_fifo2) {
		SC_METHOD(wp_update);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(rp_update);
		sensitive << clk.pos() << rst.neg();
		SC_METHOD(write);
		sensitive << clk.pos();
		SC_METHOD(read);
		sensitive << rp << wp;
	}

};

#endif

