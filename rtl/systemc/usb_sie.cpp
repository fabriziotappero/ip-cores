/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB SIE                                                    ////
////                                                             ////
////  SystemC Version: usb_sie.cpp                               ////
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

#include "systemc.h"
#include "usb_sie.h"

void usb_sie::tx_interface1(void) {
	if (!rst.read())
		TxValid_s.write(false);
	else
		TxValid_s.write(tx_valid.read() || tx_valid_last.read() ||
				(TxValid_s.read() && !TxReady.read()));
}

void usb_sie::tx_interface2(void) {
	tx_ready.write(TxReady.read());

	if (TxReady.read() || tx_first.read())
		DataOut.write(tx_data.read());
}

void usb_sie::tx_interface3(void) {
	TxValid.write(TxValid_s.read());
}

void usb_sie::rx_interface1(void) {
	if (!rst.read()) {
		rx_valid.write(false);
		rx_active.write(false);
		rx_err.write(false);
	} else {
		rx_valid.write(RxValid.read());
		rx_active.write(RxActive.read());
		rx_err.write(RxError.read());
	}
}

void usb_sie::rx_interface2(void) {
	rx_data.write(DataIn.read());
}

void usb_sie::csr9_up(void) {
	csr9.write(csr.read().range(8, 0));
}

void usb_sie::x_busy_up(void) {
	x_busy.write(tx_busy.read() || rx_busy.read());
}

// PIDs we should never receive
void usb_sie::pid_bad_up(void) {
	pid_bad.write(pid_ACK.read() || pid_NACK.read() ||
			pid_STALL.read() || pid_NYET.read() ||
			pid_PRE.read() || pid_ERR.read() ||
			pid_SPLIT.read() || pid_PING.read());
}

void usb_sie::match_o_up(void) {
	match_o.write(!pid_bad.read() && token_valid.read() && !crc5_err.read());
}

void usb_sie::rx_data_st_up(void) {
	rx_data_st.write(rx_data_st_d.read());
}

void usb_sie::decoder_pk(void) {
	ctrl_setup.write(token_valid.read() && pid_SETUP.read() && (ep_sel.read() == 0));
	ctrl_in.write(token_valid.read() && pid_IN.read() && (ep_sel.read() == 0));
	ctrl_out.write(token_valid.read() && pid_OUT.read() && (ep_sel.read() == 0));
}

// Frame Number (from SOF token)
void usb_sie::frame_no_up1(void) {
	frame_no_we.write(token_valid.read() && !crc5_err.read() && pid_SOF.read());
}

void usb_sie::frame_no_up2(void) {
	frame_no_we_r.write(frame_no_we.read());
}

void usb_sie::frame_no_up3(void) {
	if (!rst.read())
		frame_no_r.write(0);
	else if (frame_no_we_r.read())
		frame_no_r.write(frame_no.read());
}

void usb_sie::frm_nat_up1(void) {
	clr_sof_time.write(frame_no_we.read());
}

void usb_sie::frm_nat_up2(void) {
	if (clr_sof_time.read())
		sof_time.write(0);
	else if (hms_clk.read())
		sof_time.write(sof_time.read() + 1);
}

void usb_sie::frm_nat_up3(void) {
	frm_nat.write(((sc_uint<5>)0, (sc_uint<11>)frame_no_r.read(), (sc_uint<4>)0, (sc_uint<12>)sof_time.read()));
}

void usb_sie::hms_clk_up1(void) {
	if (!rst.read())
		hms_cnt.write(0);
	else if (hms_clk.read() || frame_no_we_r.read())
		hms_cnt.write(0);
	else
		hms_cnt.write(hms_cnt.read() + 1);
}

void usb_sie::hms_clk_up2(void) {
	hms_clk.write((hms_cnt.read() == USBF_HMS_DEL));
}

// This function is addressed
void usb_sie::fsel_up(void) {
	fsel.write((token_fadr.read() == fa.read()));
}

// Only write when we are addressed
void usb_sie::idma_we_up(void) {
	idma_we.write(idma_we_d.read() && fsel.read());	// moved full check to idma... && !ep_full.read());
}
/*
usb_sie::~usb_sie(void) {
	if (i_pa_sie)
		delete i_pa_sie;
	if (i_pd_sie)
		delete i_pd_sie;
	if (i_pe_sie)
		delete i_pe_sie;
	if (i_dma)
		delete i_dma;
}
*/
