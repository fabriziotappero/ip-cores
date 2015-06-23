/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1                                                    ////
////  Function IP Core                                           ////
////                                                             ////
////  SystemC Version: usb_core.cpp                              ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_core.v                                ////
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
#include "usb_core.h"

void usb_core::rst_local_up(void) {
	rst_local.write(rst_i.read() && !usb_rst.read());
}

void usb_core::stat_up(void) {
	ep0_ctrl_stat.write(((sc_uint<1>)0, (sc_uint<1>)stat2.read(), (sc_uint<1>)stat1.read(), (sc_uint<1>)0));
}

void usb_core::frame_no_up(void) {
	frame_no.write(frm_nat.read().range(26, 16));
}

void usb_core::cfg_mux(void) {
	switch (ep_sel.read()) {// synopsys full_case parallel_case
		case 0:	cfg.write(ep0_size.read() | CTRL); break;
		case 1:	cfg.write(ep1_cfg.read()); break;
		case 2:	cfg.write(ep2_cfg.read()); break;
		case 3:	cfg.write(ep3_cfg.read()); break;
		case 4:	cfg.write(ep4_cfg.read()); break;
		case 5:	cfg.write(ep5_cfg.read()); break;
		case 6:	cfg.write(ep6_cfg.read()); break;
		case 7:	cfg.write(ep7_cfg.read()); break;
	}
}

void usb_core::tx_data_mux(void) {
	switch (ep_sel.read()) {// synopsys full_case parallel_case
		case 0:	tx_data_st.write(ep0_dout.read()); break;
		case 1:	tx_data_st.write(ep1_din.read()); break;
		case 2:	tx_data_st.write(ep2_din.read()); break;
		case 3:	tx_data_st.write(ep3_din.read()); break;
		case 4:	tx_data_st.write(ep4_din.read()); break;
		case 5:	tx_data_st.write(ep5_din.read()); break;
		case 6:	tx_data_st.write(ep6_din.read()); break;
		case 7:	tx_data_st.write(ep7_din.read()); break;
	}
}

void usb_core::ep_empty_mux(void) {
	switch (ep_sel.read()) {// synopsys full_case parallel_case
		case 0:	ep_empty.write(ep0_empty.read()); break;
		case 1:	ep_empty.write(ep1_empty.read()); break;
		case 2:	ep_empty.write(ep2_empty.read()); break;
		case 3:	ep_empty.write(ep3_empty.read()); break;
		case 4:	ep_empty.write(ep4_empty.read()); break;
		case 5:	ep_empty.write(ep5_empty.read()); break;
		case 6:	ep_empty.write(ep6_empty.read()); break;
		case 7:	ep_empty.write(ep7_empty.read()); break;
	}
}

void usb_core::ep_full_mux(void) {
	switch (ep_sel.read()) {// synopsys full_case parallel_case
		case 0:	ep_full.write(ep0_full.read()); break;
		case 1:	ep_full.write(ep1_full.read()); break;
		case 2:	ep_full.write(ep2_full.read()); break;
		case 3:	ep_full.write(ep3_full.read()); break;
		case 4:	ep_full.write(ep4_full.read()); break;
		case 5:	ep_full.write(ep5_full.read()); break;
		case 6:	ep_full.write(ep6_full.read()); break;
		case 7:	ep_full.write(ep7_full.read()); break;
	}
}

void usb_core::ep_dout_deco(void) {
	ep1_dout.write(rx_data_st.read());
	ep2_dout.write(rx_data_st.read());
	ep3_dout.write(rx_data_st.read());
	ep4_dout.write(rx_data_st.read());
	ep5_dout.write(rx_data_st.read());
	ep6_dout.write(rx_data_st.read());
	ep7_dout.write(rx_data_st.read());
}

void usb_core::ep_re_deco(void) {
	ep0_re.write(idma_re.read() && (ep_sel.read() == 0));
	ep1_re.write(idma_re.read() && (ep_sel.read() == 1) && !ep1_empty.read());
	ep2_re.write(idma_re.read() && (ep_sel.read() == 2) && !ep2_empty.read());
	ep3_re.write(idma_re.read() && (ep_sel.read() == 3) && !ep3_empty.read());
	ep4_re.write(idma_re.read() && (ep_sel.read() == 4) && !ep4_empty.read());
	ep5_re.write(idma_re.read() && (ep_sel.read() == 5) && !ep5_empty.read());
	ep6_re.write(idma_re.read() && (ep_sel.read() == 6) && !ep6_empty.read());
	ep7_re.write(idma_re.read() && (ep_sel.read() == 7) && !ep7_empty.read());
}

void usb_core::ep_we_deco(void) {
	ep0_we.write(idma_we.read() && (ep_sel.read() == 0));
	ep1_we.write(idma_we.read() && (ep_sel.read() == 1) && !ep1_full.read());
	ep2_we.write(idma_we.read() && (ep_sel.read() == 2) && !ep2_full.read());
	ep3_we.write(idma_we.read() && (ep_sel.read() == 3) && !ep3_full.read());
	ep4_we.write(idma_we.read() && (ep_sel.read() == 4) && !ep4_full.read());
	ep5_we.write(idma_we.read() && (ep_sel.read() == 5) && !ep5_full.read());
	ep6_we.write(idma_we.read() && (ep_sel.read() == 6) && !ep6_full.read());
	ep7_we.write(idma_we.read() && (ep_sel.read() == 7) && !ep7_full.read());
}
/*
usb_core::~usb_core(void) {
	if (i_phy)
		delete i_phy;
	if (i_sie)
		delete i_sie;
	if (i_ep0)
		delete i_ep0;
	if (i_rom)
		delete i_rom;
	if (i_ff_in)
		delete i_ff_in;
	if (i_ff_out)
		delete i_ff_out;
}
*/
