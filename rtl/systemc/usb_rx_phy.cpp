/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB RX PHY                                                 ////
////                                                             ////
////  SystemC Version: usb_rx_phy.cpp                            ////
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

#include "systemc.h"
#include "usb_rx_phy.h"

#ifdef USB_SIMULATION
	void usb_rx_phy::rx_error_init(void) {
		RxError_o.write(false);
	}
#endif

void usb_rx_phy::misc_logic_up(void) {
	rx_en.write(RxEn_i.read());
}

void usb_rx_phy::misc_logic_RxActive_up(void) {
	RxActive_o.write(rx_active.read());
}

void usb_rx_phy::misc_logic_RxValid_up(void) {
	RxValid_o.write(rx_valid.read());
}

void usb_rx_phy::misc_logic_DataIn_up(void) {
	DataIn_o.write(hold_reg.read());
}

void usb_rx_phy::misc_logic_LineState_up(void) {
	LineState.write(((sc_uint<1>)rxdp_s1.read(), (sc_uint<1>)rxdn_s1.read()));
}

// First synchronize to the local system clock to
// avoid metastability outside the sync block (*_s1)
// Second synchronise to the internal bit clock (*_s)
void usb_rx_phy::si_up1(void) {
	rxd_t1.write(rxd.read());
	rxdp_t1.write(rxdp.read());
	rxdn_t1.write(rxdn.read());
}

void usb_rx_phy::si_up2(void) {
	rxd_s1.write(rxd_t1.read());
	rxdp_s1.write(rxdp_t1.read());
	rxdn_s1.write(rxdn_t1.read());
}

void usb_rx_phy::si_up3(void) {
	rxd_s.write(rxd_s1.read());
	rxdp_s.write(rxdp_s1.read());
	rxdn_s.write(rxdn_s1.read());
}

void usb_rx_phy::si_up4(void) {
	k.write(!rxdp_s.read() &&  rxdn_s.read());
	j.write(rxdp_s.read() && !rxdn_s.read());
	se0.write(!rxdp_s.read() && !rxdn_s.read());
}

// This design uses a clock enable to do 12Mhz timing and not a
// real 12Mhz clock. Everything always runs at 48Mhz. We want to
// make sure however, that the clock enable is always exactly in
// the middle between two virtual 12Mhz rising edges.
// We monitor rxdp and rxdn for any changes and do the appropiate
// adjustments.
// In addition to the locking done in the dpll FSM, we adjust the
// final latch enable to compensate for various sync registers ...

// Allow lockinf only when we are receiving
void usb_rx_phy::dpll_up1(void) {
	lock_en.write(rx_en.read());
}

// Edge detector
void usb_rx_phy::dpll_up2(void) {
	rxdp_s1r.write(rxdp_s1.read());
	rxdn_s1r.write(rxdn_s1.read());
}

void usb_rx_phy::dpll_up3(void) {
	change.write((rxdp_s1r.read() != rxdp_s1.read()) || (rxdn_s1r.read() != rxdn_s1.read()));
}

// DPLL FSM
void usb_rx_phy::dpll_up4(void) {
	if (!rst.read())
		dpll_state.write(1);
	else
		dpll_state.write(dpll_next_state.read());
}

// Compensate for sync registers at the input - allign full speed
// clock enable to be in the middle between two bit changes ...
void usb_rx_phy::dpll_up5(void) {
	fs_ce_r1.write(fs_ce_d.read());
}

void usb_rx_phy::dpll_up6(void) {
	fs_ce_r2.write(fs_ce_r1.read());
}

void usb_rx_phy::dpll_up7(void) {
	fs_ce_r3.write(fs_ce_r2.read());
}

void usb_rx_phy::dpll_up8(void) {
	fs_ce.write(fs_ce_r3.read());
}

void usb_rx_phy::dpll_statemachine(void) {
	fs_ce_d.write(false);
	switch (dpll_state.read()) {// synopsys full_case parallel_case
		case 0:	if (lock_en.read() && change.read())
					dpll_next_state.write(0);
				else
					dpll_next_state.write(1);
				break;
		case 1:	fs_ce_d.write(true);
				if (lock_en.read() && change.read())
					//dpll_next_state.write(0);
					dpll_next_state.write(3);
				else
					dpll_next_state.write(2);
				break;
		case 2:	if (lock_en.read() && change.read())
					dpll_next_state = 0;
				else
					dpll_next_state = 3;
				break;
		case 3:	//if (lock_en.read() && change.read())
					dpll_next_state.write(0);
				//else
					//dpll_next_state.write(0);
				break;
	}
}

void usb_rx_phy::fsp_up(void) {
	if(!rst.read())
		fs_state.write(FS_IDLE);
	else
		fs_state.write(fs_next_state.read());
}

void usb_rx_phy::fsp_statemachine(void) {
	synced_d.write(false);
	fs_next_state.write(fs_state.read());
	if (fs_ce.read())
		switch (fs_state.read()) {// synopsys full_case parallel_case
			case FS_IDLE:	if (k.read() && rx_en.read())
							fs_next_state.write(K1);
						break;
			case K1:		if (j.read() && rx_en.read())
							fs_next_state.write(J1);
						else
							fs_next_state.write(FS_IDLE);
						break;
			case J1:		if (k.read() && rx_en.read())
							fs_next_state.write(K2);
						else
							fs_next_state.write(FS_IDLE);
						break;
			case K2:		if (j.read() && rx_en.read())
							fs_next_state.write(J2);
						else
							fs_next_state.write(FS_IDLE);
						break;
			case J2:		if (k.read() && rx_en.read())
							fs_next_state.write(K3);
						else
							fs_next_state.write(FS_IDLE);
						break;
			case K3:		if (j.read() && rx_en.read())
							fs_next_state.write(J3);
						else if (k.read() && rx_en.read())
							fs_next_state.write(K4);		// Allow missing one J
						else
							fs_next_state.write(FS_IDLE);
						break;
			case J3:		if (k.read() && rx_en.read())
							fs_next_state.write(K4);
						else
							fs_next_state.write(FS_IDLE);
						break;
			case K4:		if (k.read())
								synced_d.write(true);
						fs_next_state.write(FS_IDLE);
						break;
		}
}

void usb_rx_phy::gra_up1(void) {
	if (!rst.read())
		rx_active.write(false);
	else if (synced_d.read() && rx_en.read())
		rx_active.write(true);
	else if (se0.read() && rx_valid_r.read())
		rx_active.write(false);
}

void usb_rx_phy::gra_up2(void) {
	if (rx_valid.read())
		rx_valid_r.write(true);
	else if (fs_ce.read())
		rx_valid_r.write(false);
}

void usb_rx_phy::nrzi_up1(void) {
	if (fs_ce.read())
		sd_r.write(rxd_s.read());
}

void usb_rx_phy::nrzi_up2(void) {
	if (!rst.read())
		sd_nrzi.write(false);
	else if (rx_active.read() && fs_ce.read())
		sd_nrzi.write(!(rxd_s.read() ^ sd_r.read()));
}

void usb_rx_phy::bsd_up1(void) {
	if (!rst.read())
		one_cnt.write(0);
	else if (!shift_en.read())
		one_cnt.write(0);
	else if (fs_ce.read())
		if (!sd_nrzi.read() || drop_bit.read())
			one_cnt.write(0);
		else
			one_cnt.write(one_cnt.read() + 1);
}

void usb_rx_phy::bsd_up2(void) {
	drop_bit.write((one_cnt.read() == 6));
}

void usb_rx_phy::spc_up1(void) {
	if (fs_ce.read())
		shift_en.write(synced_d.read() || rx_active.read());
}

void usb_rx_phy::spc_up2(void) {
	if (fs_ce.read() && shift_en.read() && !drop_bit.read())
		hold_reg.write(((sc_uint<1>)sd_nrzi.read(), hold_reg.read().range(7, 1)));
}

void usb_rx_phy::grv_up1(void) {
	if (!rst.read())
		bit_cnt.write(0);
	else if (!shift_en.read())
		bit_cnt.write(0);
	else if (fs_ce.read() && !drop_bit.read())
		bit_cnt.write(bit_cnt.read() + 1);
}

void usb_rx_phy::grv_up2(void) {
	if (!rst.read())
		rx_valid1.write(false);
	else if (fs_ce.read() && !drop_bit.read() && (bit_cnt.read() == 7))
		rx_valid1.write(true);
	else if (rx_valid1.read() && fs_ce.read() && !drop_bit.read())
		rx_valid1.write(false);
}

void usb_rx_phy::grv_up3(void) {
	rx_valid.write(!drop_bit.read() && rx_valid1.read() && fs_ce.read());
}

