/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB TX PHY                                                 ////
////                                                             ////
////  SystemC Version: usb_tx_phy.cpp                            ////
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

#include "systemc.h"
#include "usb_tx_phy.h"

void usb_tx_phy::misc_logic_up1(void) {
	tx_ready.write(tx_ready_d.read());
	ld_data.write(ld_data_d.read());
}

void usb_tx_phy::misc_logic_up2(void) {
	if (!rst.read())
		TxReady_o.write(false);
	else
		TxReady_o.write(tx_ready_d.read() && TxValid_i.read());
}

void usb_tx_phy::tpi_up1(void) {
	if (!rst.read())
		tx_ip.write(false);
	else if (ld_sop_d.read())
		tx_ip.write(true);
	else if (eop_done.read())
		tx_ip.write(false);
}

void usb_tx_phy::tpi_up2(void) {
	if (!rst.read())
		tx_ip_sync.write(false);
	else if (fs_ce.read())
		tx_ip_sync.write(tx_ip.read());
}

// data_done helps us to catch cases where TxValid drops due to
// packet end and then gets re-asserted as a new packet starts.
// We might not see this because we are still transmitting.
// data_done should solve those cases ...
void usb_tx_phy::tpi_up3(void) {
	if (!rst.read())
		data_done.write(false);
	else if (TxValid_i.read() && !tx_ip.read())
		data_done.write(true);
	else if (!TxValid_i.read())
		data_done.write(false);
}

void usb_tx_phy::sr_up1(void) {
	if (!rst.read())
		bit_cnt.write(0);
	else if (!tx_ip_sync.read())
		bit_cnt.write(0);
	else if (fs_ce.read() && !hold.read())
		bit_cnt.write(bit_cnt.read() + 1);
}

void usb_tx_phy::sr_up2(void) {
	if (!tx_ip_sync.read())
		sd_raw_o.write(false);
	else
		switch (bit_cnt.read()) {// synopsys full_case parallel_case
			case 0: sd_raw_o.write(hold_reg.read()[0]); break;
			case 1: sd_raw_o.write(hold_reg.read()[1]); break;
			case 2: sd_raw_o.write(hold_reg.read()[2]); break;
			case 3: sd_raw_o.write(hold_reg.read()[3]); break;
			case 4: sd_raw_o.write(hold_reg.read()[4]); break;
			case 5: sd_raw_o.write(hold_reg.read()[5]); break;
			case 6: sd_raw_o.write(hold_reg.read()[6]); break;
			case 7: sd_raw_o.write(hold_reg.read()[7]); break;
		}
}

void usb_tx_phy::sr_up3(void) {
	sft_done.write(!hold.read() && (bit_cnt.read() == 7));
}

void usb_tx_phy::sr_up4(void) {
	sft_done_r.write(sft_done.read());
}

// Out Data Hold Register
void usb_tx_phy::sr_up5(void) {
	if (ld_sop_d.read())
		hold_reg.write(0x80);	// 0x80 -> Sync Pattern
	else if (ld_data.read())
		hold_reg.write(DataOut_i.read());
}

void usb_tx_phy::sr_hold_up(void) {
	hold.write(stuff.read());
}

void usb_tx_phy::sr_sft_done_e_up(void) {
	sft_done_e.write(sft_done.read() && !sft_done_r.read());
}

void usb_tx_phy::bs_up1(void) {
	if (!rst.read())
		one_cnt.write(0);
	else if (!tx_ip_sync.read())
		one_cnt.write(0);
	else if (fs_ce.read())
		if (!sd_raw_o.read() || stuff.read())
			one_cnt.write(0);
		else
			one_cnt.write(one_cnt.read() + 1);
}

void usb_tx_phy::bs_up2(void) {
	if (!rst.read())
		sd_bs_o.write(false);
	else if (fs_ce.read())
		sd_bs_o.write((!tx_ip_sync.read()) ? false : ((stuff.read()) ? false : sd_raw_o.read()));
}

void usb_tx_phy::bs_stuff_up(void) {
	stuff.write((one_cnt.read() == 6));
}

void usb_tx_phy::nrzi_up(void) {
	if (!rst.read())
		sd_nrzi_o.write(true);
	else if (!tx_ip_sync.read() || !txoe_r1.read())
		sd_nrzi_o.write(true);
	else if (fs_ce.read())
		sd_nrzi_o.write((sd_bs_o.read()) ? sd_nrzi_o.read() : !sd_nrzi_o.read());
}

void usb_tx_phy::eop_up1(void) {
	if (!rst.read())
		append_eop.write(false);
	else if (ld_eop_d.read())
		append_eop.write(true);
	else if (append_eop_sync2.read())
		append_eop.write(false);
}

void usb_tx_phy::eop_up2(void) {
	if (!rst.read())
		append_eop_sync1.write(false);
	else if (fs_ce.read())
		append_eop_sync1.write(append_eop.read());
}

void usb_tx_phy::eop_up3(void) {
	if (!rst.read())
		append_eop_sync2.write(false);
	else if (fs_ce.read())
		append_eop_sync2.write(append_eop_sync1.read());
}

void usb_tx_phy::eop_up4(void) {
	if (!rst.read())
		append_eop_sync3.write(false);
	else if (fs_ce.read())
		append_eop_sync3.write(append_eop_sync2.read());
}

void usb_tx_phy::eop_done_up(void) {
	eop_done.write(append_eop_sync3.read());
}

void usb_tx_phy::oel_up1(void) {
	if (!rst.read())
		txoe_r1.write(false);
	else if (fs_ce.read())
		txoe_r1.write(tx_ip_sync.read());
}

void usb_tx_phy::oel_up2(void) {
	if (!rst.read())
		txoe_r2.write(false);
	else if (fs_ce.read())
		txoe_r2.write(txoe_r1.read());
}

void usb_tx_phy::oel_up3(void) {
	if (!rst.read())
		txoe.write(true);
	else if (fs_ce.read())
		txoe.write(!(txoe_r1.read() || txoe_r2.read()));
}

void usb_tx_phy::or_up(void) {
	if (!rst.read()) {
		txdp.write(true);
		txdn.write(false);
	} else if (fs_ce.read()) {
		txdp.write((phy_mode.read()) ? (!append_eop_sync3.read() && sd_nrzi_o.read()) : sd_nrzi_o.read());
		txdn.write((phy_mode.read()) ? (!append_eop_sync3.read() && !sd_nrzi_o.read()) : append_eop_sync3.read());
	}
}

void usb_tx_phy::tx_statemachine(void) {
	next_state.write(state.read());
	tx_ready_d.write(false);
	ld_sop_d.write(false);
	ld_data_d.write(false);
	ld_eop_d.write(false);

	switch (state.read()) {// synopsys full_case parallel_case
		case TX_IDLE:	if (TxValid_i.read()) {
							ld_sop_d.write(true);
							next_state.write(TX_SOP);
						}
						break;
		case TX_SOP:	if (sft_done_e.read()) {
							tx_ready_d.write(true);
							ld_data_d.write(true);
							next_state.write(TX_DATA);
						}
						break;
		case TX_DATA:	if (!data_done.read() && sft_done_e.read()) {
							ld_eop_d.write(true);
							next_state.write(TX_EOP1);
						}
						if (data_done.read() && sft_done_e.read()) {
							tx_ready_d.write(true);
							ld_data_d.write(true);
						}
						break;
		case TX_EOP1:	if (eop_done.read())
							next_state.write(TX_EOP2);
						break;
		case TX_EOP2:	if (!eop_done.read() && fs_ce.read())
							next_state.write(TX_WAIT);
						break;
		case TX_WAIT:	if (fs_ce.read())
							next_state.write(TX_IDLE);
						break;
	}
}

void usb_tx_phy::tx_state_up(void) {
	if (!rst.read())
		state.write(TX_IDLE);
	else
		state.write(next_state.read());
}

