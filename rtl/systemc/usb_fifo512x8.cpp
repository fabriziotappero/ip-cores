/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB FIFO                                                   ////
////                                                             ////
////  SystemC Version: usb_fifo512x8.cpp                         ////
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

#include "systemc.h"
#include "usb_fifo512x8.h"

void usb_fifo512x8::write_pointer_update(void) {
	if (!rst.read()) {
		wp.write(0);
	} else if (clr.read()) {
		wp.write(0);
	} else if (we.read()) {
		wp.write(wp_pl1.read());
	}
}

void usb_fifo512x8::read_pointer_update(void) {
	if (!rst.read()) {
		rp.write(0);
	} else if (clr.read()) {
		rp.write(0);
	} else if (re.read()) {
		rp.write(rp_pl1.read());
	}
}

void usb_fifo512x8::future_pointers_update(void) {
	wp_pl1.write(wp.read() + 1);
	wp_pl2.write(wp.read() + 2);
	rp_pl1.write(rp.read() + 1);
}

// Full & Empty Logic
// Guard Bit ...
void usb_fifo512x8::fe_gb_update(void) {
	if (!rst.read())
		gb.write(false);
	else if (clr.read())
		gb.write(false);
	else if ((wp_pl2.read() == rp.read()) && we.read())
		gb.write(true);
	else if ((wp.read() != rp.read()) && re.read())
		gb.write(false);
}

void usb_fifo512x8::fe_full_update(void) {
	if (!rst.read())
		full.write(false);
	else if (clr.read())
		full.write(false);
	else if (we.read() && ((wp_pl1.read() == rp.read()) && gb.read()) && !re.read())
		full.write(true);
	else if (re.read() && ((wp_pl1.read() != rp.read()) || !gb.read()) && !we.read())
		full.write(false);
}

void usb_fifo512x8::fe_empty_update(void) {
	if (!rst.read())
		empty.write(true);
	else if (clr.read())
		empty.write(true);
	else if (we.read() && ((wp.read() != rp_pl1.read()) || gb.read()) && !re.read())
		empty.write(false);
	else if (re.read() && ((wp.read() == rp_pl1.read()) && !gb.read()) && !we.read())
		empty.write(true);
}

void usb_fifo512x8::reset_update(void) {
	n_rst.write(!rst.read());
}
/*
usb_fifo512x8::~usb_fifo512x8(void) {
	if (i_ram)
		delete i_ram;
}
*/
