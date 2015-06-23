/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Control Endpoint (Endpoint Zero)                       ////
////  Internal Setup Engine                                      ////
////                                                             ////
////  SystemC Version: usb_ep0.cpp                               ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_ctrl.v                                ////
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
#include "usb_ep0.h"

void usb_ep0::ep0_re_up(void) {
	ep0_re.write(fifo_re1.read());
}

void usb_ep0::fifo_empty_up(void) {
	fifo_empty.write(ep0_stat.read()[1]);
}

void usb_ep0::fifo_full_up(void) {
	fifo_full.write(ep0_stat.read()[2]);
}

// For this implementation we do not implement HALT for the
// device nor for any of the endpoints. This is useless for
// this device, but can be added here later ...
// FYI, we report device/endpoint errors via interrupts,
// instead of halting the entire or part of the device, much
// nicer for non-critical errors
void usb_ep0::clr_halt_up(void) {
	clr_halt.write(ctrl_setup.read());
}

void usb_ep0::addressed_up(void) {
	if (!rst.read())
		addressed.write(false);
	else if (set_address.read())
		addressed.write(true);
}

void usb_ep0::configured_up(void) {
	if (!rst.read())
		configured.write(false);
	else if (set_config.read())
		configured.write(true);
}

void usb_ep0::halt_up(void) {
	if (!rst.read())
		halt.write(false);
	else if (clr_halt.read())
		halt.write(false);
	else if (set_halt.read())
		halt.write(true);
}

void usb_ep0::rom_adr_up1(void) {
	sc_uint<4> sel1, sel2;

	sel1 = wValue.read().range(11, 8);
	sel2 = wValue.read().range(3, 0);

	switch (sel1) {// synopsys full_case parallel_case
		case 1:	rom_start_d.write(ROM_START0); break;
		case 2:	rom_start_d.write(ROM_START1); break;
		case 3:	switch (sel2) {// synopsys full_case parallel_case
					case 0:	rom_start_d.write(ROM_START2A); break;
					case 1:	rom_start_d.write(ROM_START2B); break;
					case 2:	rom_start_d.write(ROM_START2C); break;
					case 3:	rom_start_d.write(ROM_START2D); break;
					default:rom_start_d.write(ROM_START2A); break;
				}
				break;
		default:rom_start_d.write(0); break;
	}
}

void usb_ep0::rom_adr_up2(void) {
	if (!rst.read())
		rom_adr.write(0);
	else if (rom_sel.read() && !rom_sel_r.read())
		rom_adr.write(rom_start_d.read());
	else if (rom_sel.read() && !fifo_full.read())
		rom_adr.write(rom_adr.read() + 1);
}

void usb_ep0::rom_size_up1(void) {
	sc_uint<4> sel1, sel2;

	sel1 = wValue.read().range(11, 8);
	sel2 = wValue.read().range(3, 0);

	switch (sel1) {// synopsys full_case parallel_case
		case 1:	rom_size_dd.write(ROM_SIZE0); break;
		case 2:	rom_size_dd.write(ROM_SIZE1); break;
		case 3:	switch (sel2) {// synopsys full_case parallel_case
					case 0:	rom_size_dd.write(ROM_SIZE2A); break;
					case 1:	rom_size_dd.write(ROM_SIZE2B); break;
					case 2:	rom_size_dd.write(ROM_SIZE2C); break;
					case 3:	rom_size_dd.write(ROM_SIZE2D); break;
					default:rom_size_dd.write(ROM_SIZE2A); break;
				}
				break;
		default:rom_size_dd.write(1); break;
	}
}

void usb_ep0::rom_size_up2(void) {
	rom_size_d.write(((rom_size_dd.read() > wLength.read().range(6, 0)) ?
			wLength.read().range(6, 0) : rom_size_dd.read()));
}

void usb_ep0::rom_size_up3(void) {
	if (!rst.read())
		rom_size.write(0);
	else if (rom_sel.read() && !rom_sel_r.read())
		rom_size.write(rom_size_d.read());
	else if (rom_sel.read() && !fifo_full.read())
		rom_size.write(rom_size.read() - 1);
}

void usb_ep0::rom_sel_up(void) {
	rom_sel_r.write(rom_sel.read());
}

void usb_ep0::fifo_we_rom_up1(void) {
	fifo_we_rom_r.write(rom_sel.read());
}

void usb_ep0::fifo_we_rom_up2(void) {
	fifo_we_rom_r2.write(fifo_we_rom_r.read());
}

void usb_ep0::fifo_we_rom_up3(void) {
	fifo_we_rom.write(rom_sel.read() && fifo_we_rom_r2.read());
}

void usb_ep0::rom_done_up(void) {
	rom_done.write((rom_size.read() == 0) && !(rom_sel.read() && !rom_sel_r.read()));
}

void usb_ep0::fifo_re_up(void) {
	fifo_re1.write(get_hdr.read() && !fifo_empty.read());
}

void usb_ep0::adv_up(void) {
	adv.write(get_hdr.read() && !fifo_empty.read() && !adv.read());
}

void usb_ep0::le_up(void) {
	if (!rst.read())
		le.write(0);
	else if (!get_hdr.read())
		le.write(0);
	#ifdef USB_SIMULATION
		else if (!le.read().or_reduce())
	#else
		else if (!(le.read()[7] || le.read()[6] || le.read()[5] || le.read()[4] ||
				le.read()[3] || le.read()[2] || le.read()[1] || le.read()[0]))
	#endif
		le.write(1);
	else if (adv.read())
		le.write(((sc_uint<7>)le.read().range(6, 0), (sc_uint<1>)0));
}

void usb_ep0::hdr_deco0(void) {
	if (le.read()[0])
		hdr0.write(ep0_din.read());
}

void usb_ep0::hdr_deco1(void) {
	if (le.read()[1])
		hdr1.write(ep0_din.read());
}

void usb_ep0::hdr_deco2(void) {
	if (le.read()[2])
		hdr2.write(ep0_din.read());
}

void usb_ep0::hdr_deco3(void) {
	if (le.read()[3])
		hdr3.write(ep0_din.read());
}

void usb_ep0::hdr_deco4(void) {
	if (le.read()[4])
		hdr4.write(ep0_din.read());
}

void usb_ep0::hdr_deco5(void) {
	if (le.read()[5])
		hdr5.write(ep0_din.read());
}

void usb_ep0::hdr_deco6(void) {
	if (le.read()[6])
		hdr6.write(ep0_din.read());
}

void usb_ep0::hdr_deco7(void) {
	if (le.read()[7])
		hdr7.write(ep0_din.read());
}

void usb_ep0::hdr_done_up(void) {
	hdr_done.write(le.read()[7] && adv.read());
}

void usb_ep0::high_sel_up(void) {
	high_sel.write(write_done_r.read());
}

void usb_ep0::ep0_dout_up(void) {
	switch (data_sel.read()) {// synopsys full_case parallel_case
		case ZERO_DATA:			ep0_dout.write(((rom_sel.read()) ? rom_data.read() : (sc_uint<8>)0)); break;
		case ZERO_ONE_DATA:		ep0_dout.write(((high_sel.read()) ? (sc_uint<8>)1 : (sc_uint<8>)0)); break;
		case CONFIG_DATA:		ep0_dout.write(((sc_uint<7>)0, (sc_uint<1>)configured.read())); break;	// Is configured?
		case SYNC_FRAME_DATA:	ep0_dout.write((high_sel.read()) ?
								((sc_uint<5>)0, (sc_uint<3>)frame_no.read().range(10, 8)) :
								frame_no.read().range(7, 0)); break;
		case VEND_DATA:			ep0_dout.write(((high_sel.read()) ?
								vendor_data.read().range(15, 8) :
								vendor_data.read().range(7, 0))); break;
	}
}

void usb_ep0::ep0_we_up(void) {
	ep0_we.write(fifo_we_d.read() || fifo_we_rom.read());
}

void usb_ep0::ep0_size_up(void) {
	if (in_size_0.read())
		ep0_size.write(0);
	else if (in_size_1.read())
		ep0_size.write(1);
	else if (in_size_2.read())
		ep0_size.write(2);
	else if (rom_sel.read())
		ep0_size.write(((sc_uint<1>)0, (sc_uint<7>)rom_size_d.read()));
}

void usb_ep0::write_done_up1(void) {
	write_done_r.write(in_size_2.read() && !fifo_full.read() && fifo_we_d.read() &&
			!write_done_r.read() && !write_done.read());
}

void usb_ep0::write_done_up2(void) {
	write_done.write(in_size_2.read() && !fifo_full.read() && fifo_we_d.read() &&
			write_done_r.read() && !write_done.read());
}

void usb_ep0::bmReqType_up(void) {
	bmReqType.write(hdr0.read());
}

void usb_ep0::bmReqType_Decoder(void) {
	bm_req_dir.write(bmReqType.read()[7]);				// 0: Host to device; 1: Device to host
	bm_req_type.write(bmReqType.read().range(6, 5));	// 0: Standard; 1: Class; 2: Vendor; 3: RESERVED
	bm_req_recp.write(bmReqType.read().range(4, 0));	// 0: Device; 1: Interface; 2: Endpoint; 3: Other
														// 4..31: RESERVED
}

void usb_ep0::bRequest_up(void) {
	bRequest.write(hdr1.read());
}

void usb_ep0::wValue_up(void) {
	wValue.write(((sc_uint<8>)hdr3.read(), (sc_uint<8>)hdr2.read()));
}

void usb_ep0::wIndex_up(void) {
	wIndex.write(((sc_uint<8>)hdr5.read(), (sc_uint<8>)hdr4.read()));
}

void usb_ep0::wLength_up(void) {
	wLength.write(((sc_uint<8>)hdr7.read(), (sc_uint<8>)hdr6.read()));
}

void usb_ep0::hdr_done_r_up(void) {
	hdr_done_r.write(hdr_done.read());
}

// Standard commands that MUST support
void usb_ep0::get_status_up(void) {
	get_status.write(hdr_done.read() && (bRequest.read() == GET_STATUS) && (bm_req_type.read() == 0));
}

void usb_ep0::clear_feature_up(void) {
	clear_feature.write(hdr_done.read() && (bRequest.read() == CLEAR_FEATURE) && (bm_req_type.read() == 0));
}

void usb_ep0::set_feature_up(void) {
	set_feature.write(hdr_done.read() && (bRequest.read() == SET_FEATURE) && (bm_req_type.read() == 0));
}

void usb_ep0::set_address_up(void) {
	set_address.write(hdr_done.read() && (bRequest.read() == SET_ADDRESS) && (bm_req_type.read() == 0));
}

void usb_ep0::get_descriptor_up(void) {
	get_descriptor.write(hdr_done.read() && (bRequest.read() == GET_DESCRIPTOR) && (bm_req_type.read() == 0));
}

void usb_ep0::set_descriptor_up(void) {
	set_descriptor.write(hdr_done.read() && (bRequest.read() == SET_DESCRIPTOR) && (bm_req_type.read() == 0));
}

void usb_ep0::get_config_up(void) {
	get_config.write(hdr_done.read() && (bRequest.read() == GET_CONFIG) && (bm_req_type.read() == 0));
}

void usb_ep0::set_config_up(void) {
	set_config.write(hdr_done.read() && (bRequest.read() == SET_CONFIG) && (bm_req_type.read() == 0));
}

void usb_ep0::get_interface_up(void) {
	get_interface.write(hdr_done.read() && (bRequest.read() == GET_INTERFACE) && (bm_req_type.read() == 0));
}

void usb_ep0::set_interface_up(void) {
	set_interface.write(hdr_done.read() && (bRequest.read() == SET_INTERFACE) && (bm_req_type.read() == 0));
}

void usb_ep0::synch_frame_up(void) {
	synch_frame.write(hdr_done.read() && (bRequest.read() == SYNCH_FRAME) && (bm_req_type.read() == 0));
}

void usb_ep0::v_set_int_up(void) {
	v_set_int.write(hdr_done.read() && (bRequest.read() == V_SET_INT) && (bm_req_type.read() == 2));
}

void usb_ep0::v_set_feature_up(void) {
	v_set_feature.write(hdr_done.read() && (bRequest.read() == SET_FEATURE) && (bm_req_type.read() == 2));
}

void usb_ep0::v_get_status_up(void) {
	v_get_status.write(hdr_done.read() && (bRequest.read() == GET_STATUS) && (bm_req_type.read() == 2));
}

// A config err must cause the device to send a STALL for an ACK
void usb_ep0::config_err_up(void) {
	config_err.write(hdr_done_r.read() && !(get_status.read() || clear_feature.read() ||
			set_feature.read() || set_address.read() || get_descriptor.read() ||
			set_descriptor.read() || get_config.read() || set_config.read() ||
			get_interface.read() || set_interface.read() || synch_frame.read() ||
			v_set_int.read() || v_set_feature.read() || v_get_status.read()));
}

void usb_ep0::send_stall_up(void) {
	send_stall.write(config_err.read());
}

// Set address
void usb_ep0::set_adr_pending_up(void) {
	if (!rst.read())
		set_adr_pending.write(false);
	else if (ctrl_in.read() || ctrl_out.read() || ctrl_setup.read())
		set_adr_pending.write(false);
	else if (set_address.read())
		set_adr_pending.write(true);

}

void usb_ep0::funct_adr_tmp_up(void) {
	if (!rst.read())
		funct_adr_tmp.write(0);
	else if (set_address.read())
		funct_adr_tmp.write(wValue.read().range(6, 0));
}

void usb_ep0::funct_adr_up(void) {
	if (!rst.read())
		funct_adr.write(0);
	else if (set_adr_pending.read() && ctrl_in.read())
		funct_adr.write(funct_adr_tmp.read());
}

// Main FSM
void usb_ep0::state_up(void) {
	if (!rst.read())
		state.write(EP0_IDLE);
	else
		state.write(next_state.read());
}

void usb_ep0::ep0_statemachine(void) {
	next_state.write(state.read());
	get_hdr.write(false);
	data_sel.write(ZERO_DATA);
	fifo_we_d.write(false);
	in_size_0.write(false);
	in_size_1.write(false);
	in_size_2.write(false);
	rom_sel.write(false);

	switch (state.read()) {// synopsys full_case parallel_case
		case EP0_IDLE:	// Wait for setup token

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state IDLE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						if (ctrl_setup.read())
							next_state.write(EP0_GET_HDR);
						if (get_status.read())
							next_state.write(EP0_GET_STATUS);
						if (clear_feature.read())
							next_state.write(EP0_CLEAR_FEATURE);
						if (set_feature.read())
							next_state.write(EP0_SET_FEATURE);
						if (set_address.read())
							next_state.write(EP0_SET_ADDRESS);
						if (get_descriptor.read())
							next_state.write(EP0_GET_DESCRIPTOR);
						if (set_descriptor.read())
							next_state.write(EP0_SET_DESCRIPTOR);
						if (get_config.read())
							next_state.write(EP0_GET_CONFIG);
						if (set_config.read())
							next_state.write(EP0_SET_CONFIG);
						if (get_interface.read())
							next_state.write(EP0_GET_INTERFACE);
						if (set_interface.read())
							next_state.write(EP0_SET_INTERFACE);
						if (synch_frame.read())
							next_state.write(EP0_SYNCH_FRAME);
						if (v_set_int.read())
							next_state.write(EP0_V_SET_INT);
						if (v_set_feature.read())
							next_state.write(EP0_V_SET_INT);
						if (v_get_status.read())
							next_state.write(EP0_V_GET_STATUS);
						break;

		case EP0_GET_HDR:	// Retrieve setup header

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state GET_HDR (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						get_hdr.write(true);
						if (hdr_done.read())
							next_state.write(EP0_IDLE);
						break;

		case EP0_GET_STATUS:	// Actions for supported commands

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state GET_STATUS (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Return to host
						// 1 for device
						// 0 for interface
						// 0 for endpoint
						if (bm_req_recp.read() == 0)
							data_sel.write(ZERO_ONE_DATA);
						else
							data_sel.write(ZERO_DATA);

						in_size_2.write(true);
						if (!fifo_full.read()) {
							fifo_we_d.write(true);
							if (write_done_r.read())
								next_state.write(EP0_WAIT_IN_DATA);
						}
						break;

		case EP0_V_GET_STATUS:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state V_GET_STATUS (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						data_sel.write(VEND_DATA);
						in_size_2.write(true);
						if (!fifo_full.read()) {
							fifo_we_d.write(true);
							if (write_done_r.read())
								next_state.write(EP0_WAIT_IN_DATA);
						}
						break;

		case EP0_CLEAR_FEATURE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state CLEAR_FEATURE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Just ignore this for now
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_SET_FEATURE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SET_FEATURE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Just ignore this for now
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_SET_ADDRESS:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SET_ADDRESS (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Done elsewhere
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_GET_DESCRIPTOR:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state GET_DESCRIPTOR (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						if ((wValue.read().range(15, 8) == 1) ||
								(wValue.read().range(15, 8) == 2) ||
								(wValue.read().range(15, 8) == 3))
							rom_sel.write(true);
						else
							next_state.write(EP0_IDLE);

						if (rom_done.read())
							next_state.write(EP0_IDLE);
						break;

		case EP0_SET_DESCRIPTOR:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SET_DESCRIPTOR (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// This doesn't do anything since we do not support
						// setting the descriptor
						next_state.write(EP0_IDLE);
						break;

		case EP0_GET_CONFIG:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state GET_CONFIG (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Send one byte back that indicates current status
						in_size_1.write(true);
						data_sel.write(CONFIG_DATA);
						if (!fifo_full.read()) {
							fifo_we_d.write(true);
							next_state.write(EP0_WAIT_IN_DATA);
						}
						break;

		case EP0_SET_CONFIG:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SET_CONFIG (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Done elsewhere
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_GET_INTERFACE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state GET_INTERFACE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Return interface 0
						in_size_1.write(true);
						if (!fifo_full.read()) {
							fifo_we_d.write(true);
							next_state.write(EP0_WAIT_IN_DATA);
						}
						break;

		case EP0_SET_INTERFACE:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SET_INTERFACE (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Just ignore this for now
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_SYNCH_FRAME:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state SYNCH_FRAME (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Return Frame current frame number
						data_sel.write(SYNC_FRAME_DATA);
						in_size_2.write(true);
						if (!fifo_full.read()) {
							fifo_we_d.write(true);
							if (write_done_r.read())
								next_state.write(EP0_WAIT_IN_DATA);
						}
						break;

		case EP0_V_SET_INT:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state V_SET_INT (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						// Done elsewhere
						next_state.write(EP0_STATUS_IN);
						break;

		case EP0_WAIT_IN_DATA:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state WAIT_IN_DATA (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						if (ctrl_in.read())
							next_state.write(EP0_STATUS_OUT);
						break;

		case EP0_STATUS_IN:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state STATUS_IN (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						in_size_0.write(true);
						if (ctrl_in.read())
							next_state.write(EP0_IDLE);
						break;

		case EP0_STATUS_OUT:

///////////////////////////////////////////////////////////////////////
//
// DEBUG INFORMATIONS
//
///////////////////////////////////////////////////////////////////////

#ifdef USBF_VERBOSE_DEBUG
	cout << "EP0: Entered state STATUS_OUT (" << sc_simulation_time() << ")" << endl;
#endif

///////////////////////////////////////////////////////////////////////

						if (ctrl_out.read())
							next_state.write(EP0_IDLE);
						break;
	}
}

