/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Control Endpoint (Endpoint Zero)                       ////
////  Internal Setup Engine                                      ////
////                                                             ////
////  SystemC Version: usb_ep0.h                                 ////
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

#ifndef USB_EP0_H
#define USB_EP0_H

#include "usb_defines.h"

// State Decoding
enum EP0_STATE {	EP0_IDLE = 1,
					EP0_GET_HDR = 2,
					EP0_GET_STATUS = 4,
					EP0_CLEAR_FEATURE = 8,
					EP0_SET_FEATURE = 16,
					EP0_SET_ADDRESS = 32,
					EP0_GET_DESCRIPTOR = 64,
					EP0_SET_DESCRIPTOR = 128,
					EP0_GET_CONFIG = 256,
					EP0_SET_CONFIG = 512,
					EP0_GET_INTERFACE = 1024,
					EP0_SET_INTERFACE = 2048,
					EP0_SYNCH_FRAME = 4096,
					EP0_WAIT_IN_DATA = 8192,
					EP0_STATUS_IN = 16384,
					EP0_STATUS_OUT = 32768,
					EP0_V_SET_INT = 65536,
					EP0_V_GET_STATUS = 131072};

// Data Source (To Send to Host)
enum EP0_DATA_SOURCE {	ZERO_DATA = 1,
						ZERO_ONE_DATA = 2,
						CONFIG_DATA = 4,
						SYNC_FRAME_DATA = 8,
						VEND_DATA = 16};

// Standard Request Codes
enum EP0_STD_REQUEST {	GET_STATUS = 0,
						CLEAR_FEATURE = 1,
						// Reserved for future use
						SET_FEATURE = 3,
						// Reserved for future use
						SET_ADDRESS = 5,
						GET_DESCRIPTOR = 6,
						SET_DESCRIPTOR = 7,
						GET_CONFIG = 8,
						SET_CONFIG = 9,
						GET_INTERFACE = 10,
						SET_INTERFACE = 11,
						SYNCH_FRAME = 12,
						V_SET_INT = 15};

SC_MODULE(usb_ep0) {

  public:

	sc_in<bool>			clk;
	sc_in<bool>			rst;

	// ROM Interface
	sc_out<sc_uint<8> >	rom_adr;
	sc_in<sc_uint<8> >	rom_data;

	// From PL
	sc_in<bool>			ctrl_setup;
	sc_in<bool>			ctrl_in;
	sc_in<bool>			ctrl_out;
	sc_in<sc_uint<11> >	frame_no;

	// To PL
	sc_out<bool>		send_stall;
	sc_out<sc_uint<7> >	funct_adr;
	sc_out<bool>		addressed;
	sc_out<bool>		configured;
	sc_out<bool>		halt;

	// FIFOs Interface
	sc_in<sc_uint<8> >	ep0_din;
	sc_out<sc_uint<8> >	ep0_dout;
	sc_out<bool>		ep0_re, ep0_we;
	sc_in<sc_uint<4> >	ep0_stat;
	sc_out<sc_uint<8> >	ep0_size;

	// Function Interface
	sc_out<bool>		v_set_int;
	sc_out<bool>		v_set_feature;
	sc_out<sc_uint<16> >wValue;
	sc_out<sc_uint<16> >wIndex;
	sc_in<sc_uint<16> >	vendor_data;

	// Local Signals

	// Setup Data Fields
	sc_signal<sc_uint<8> >	bmReqType, bRequest;
	sc_signal<sc_uint<16> >	wLength;
	sc_signal<bool>			bm_req_dir;
	sc_signal<sc_uint<2> >	bm_req_type;
	sc_signal<sc_uint<5> >	bm_req_recp;

	// Standard Device Requests - Status Registers
	sc_signal<bool>			get_status, clear_feature, set_feature, set_address;
	sc_signal<bool>			get_descriptor, set_descriptor, get_config, set_config;
	sc_signal<bool>			get_interface, set_interface, synch_frame;
	sc_signal<bool>			hdr_done_r, config_err;
	sc_signal<bool>			v_get_status;

	// FIFOs Signals
	sc_signal<bool>			fifo_re1, fifo_full, fifo_empty;
	sc_signal<bool>			fifo_we_d;
	sc_signal<sc_uint<5> >	data_sel;

	// EP0 FSM Signals
	sc_signal<sc_uint<20> >	state, next_state;
	sc_signal<bool>			get_hdr;
	sc_signal<sc_uint<8> >	le;
	sc_signal<bool>			hdr_done;
	sc_signal<bool>			adv;
	sc_signal<sc_uint<8> >	hdr0, hdr1, hdr2, hdr3, hdr4, hdr5, hdr6, hdr7;
	sc_signal<bool>			set_adr_pending;
	sc_signal<sc_uint<7> >	funct_adr_tmp;
	sc_signal<bool>			in_size_0, in_size_1, in_size_2;
	sc_signal<bool>			high_sel;
	sc_signal<bool>			write_done, write_done_r;

	// Halt Signals
	sc_signal<bool>			clr_halt;
	sc_signal<bool>			set_halt;

	// ROM Signals
	sc_signal<bool>			rom_sel, rom_sel_r;
	sc_signal<bool>			rom_done;
	sc_signal<sc_uint<7> >	rom_size, rom_size_d, rom_size_dd;
	sc_signal<bool>			fifo_we_rom, fifo_we_rom_r, fifo_we_rom_r2;
	sc_signal<sc_uint<8> >	rom_start_d;

	// FIFOs Functions
	void ep0_re_up(void);
	void fifo_empty_up(void);
	void fifo_full_up(void);

	// Current State Functions
	void clr_halt_up(void);
	void addressed_up(void);
	void configured_up(void);
	void halt_up(void);

	// ROM Functions
	void rom_adr_up1(void);
	void rom_adr_up2(void);
	void rom_size_up1(void);
	void rom_size_up2(void);
	void rom_size_up3(void);
	void rom_sel_up(void);
	void fifo_we_rom_up1(void);
	void fifo_we_rom_up2(void);
	void fifo_we_rom_up3(void);
	void rom_done_up(void);

	// Get Header Functions
	void fifo_re_up(void);
	void adv_up(void);
	void le_up(void);
	void hdr_deco0(void);
	void hdr_deco1(void);
	void hdr_deco2(void);
	void hdr_deco3(void);
	void hdr_deco4(void);
	void hdr_deco5(void);
	void hdr_deco6(void);
	void hdr_deco7(void);
	void hdr_done_up(void);

	// Send Data to Host Functions
	void high_sel_up(void);
	void ep0_dout_up(void);
	void ep0_we_up(void);
	void ep0_size_up(void);
	void write_done_up1(void);
	void write_done_up2(void);

	// Header Decoder Functions
	void bmReqType_up(void);
	void bmReqType_Decoder(void);
	void bRequest_up(void);
	void wValue_up(void);
	void wIndex_up(void);
	void wLength_up(void);
	void hdr_done_r_up(void);
	void get_status_up(void);
	void clear_feature_up(void);
	void set_feature_up(void);
	void set_address_up(void);
	void get_descriptor_up(void);
	void set_descriptor_up(void);
	void get_config_up(void);
	void set_config_up(void);
	void get_interface_up(void);
	void set_interface_up(void);
	void synch_frame_up(void);
	void v_set_int_up(void);
	void v_set_feature_up(void);
	void v_get_status_up(void);
	void config_err_up(void);
	void send_stall_up(void);

	// Set Address Functions
	void set_adr_pending_up(void);
	void funct_adr_tmp_up(void);
	void funct_adr_up(void);

	// Control Pipe FSM Functions
	void state_up(void);
	void ep0_statemachine(void);

	SC_CTOR(usb_ep0) {
		set_halt.write(false);

		SC_METHOD(ep0_re_up);
		sensitive << fifo_re1;
		SC_METHOD(fifo_empty_up);
		sensitive << ep0_stat;
		SC_METHOD(fifo_full_up);
		sensitive << ep0_stat;

		SC_METHOD(clr_halt_up);
		sensitive << ctrl_setup;
		SC_METHOD(addressed_up);
		sensitive << clk.pos();
		SC_METHOD(configured_up);
		sensitive << clk.pos();
		SC_METHOD(halt_up);
		sensitive << clk.pos();

		SC_METHOD(rom_adr_up1);
		sensitive << wValue;
		SC_METHOD(rom_adr_up2);
		sensitive << clk.pos();
		SC_METHOD(rom_size_up1);
		sensitive << wValue;
		SC_METHOD(rom_size_up2);
		sensitive << rom_size_dd << wLength;
		SC_METHOD(rom_size_up3);
		sensitive << clk.pos();
		SC_METHOD(rom_sel_up);
		sensitive << clk.pos();
		SC_METHOD(fifo_we_rom_up1);
		sensitive << clk.pos();
		SC_METHOD(fifo_we_rom_up2);
		sensitive << clk.pos();
		SC_METHOD(fifo_we_rom_up3);
		sensitive << rom_sel << fifo_we_rom_r2;
		SC_METHOD(rom_done_up);
		sensitive << rom_size << rom_sel << rom_sel_r;

		SC_METHOD(fifo_re_up);
		sensitive << get_hdr << fifo_empty;
		SC_METHOD(adv_up);
		sensitive << clk.pos();
		SC_METHOD(le_up);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco0);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco1);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco2);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco3);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco4);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco5);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco6);
		sensitive << clk.pos();
		SC_METHOD(hdr_deco7);
		sensitive << clk.pos();
		SC_METHOD(hdr_done_up);
		sensitive << le << adv;

		SC_METHOD(high_sel_up);
		sensitive << write_done_r;
		SC_METHOD(ep0_dout_up);
		sensitive << clk.pos();
		SC_METHOD(ep0_we_up);
		sensitive << clk.pos();
		SC_METHOD(ep0_size_up);
		sensitive << clk.pos();
		SC_METHOD(write_done_up1);
		sensitive << clk.pos();
		SC_METHOD(write_done_up2);
		sensitive << clk.pos();

		SC_METHOD(bmReqType_up);
		sensitive << hdr0;
		SC_METHOD(bmReqType_Decoder);
		sensitive << bmReqType;
		SC_METHOD(bRequest_up);
		sensitive << hdr1;
		SC_METHOD(wValue_up);
		sensitive << hdr2 << hdr3;
		SC_METHOD(wIndex_up);
		sensitive << hdr4 << hdr5;
		SC_METHOD(wLength_up);
		sensitive << hdr6 << hdr7;
		SC_METHOD(hdr_done_r_up);
		sensitive << clk.pos();
		SC_METHOD(get_status_up);
		sensitive << clk.pos();
		SC_METHOD(clear_feature_up);
		sensitive << clk.pos();
		SC_METHOD(set_feature_up);
		sensitive << clk.pos();
		SC_METHOD(set_address_up);
		sensitive << clk.pos();
		SC_METHOD(get_descriptor_up);
		sensitive << clk.pos();
		SC_METHOD(set_descriptor_up);
		sensitive << clk.pos();
		SC_METHOD(get_config_up);
		sensitive << clk.pos();
		SC_METHOD(set_config_up);
		sensitive << clk.pos();
		SC_METHOD(set_interface_up);
		sensitive << clk.pos();
		SC_METHOD(get_interface_up);
		sensitive << clk.pos();
		SC_METHOD(synch_frame_up);
		sensitive << clk.pos();
		SC_METHOD(v_set_int_up);
		sensitive << clk.pos();
		SC_METHOD(v_set_feature_up);
		sensitive << clk.pos();
		SC_METHOD(v_get_status_up);
		sensitive << clk.pos();
		SC_METHOD(config_err_up);
		sensitive << clk.pos();
		SC_METHOD(send_stall_up);
		sensitive << clk.pos();

		SC_METHOD(set_adr_pending_up);
		sensitive << clk.pos();
		SC_METHOD(funct_adr_tmp_up);
		sensitive << clk.pos();
		SC_METHOD(funct_adr_up);
		sensitive << clk.pos();

		SC_METHOD(state_up);
		sensitive << clk.pos();
		SC_METHOD(ep0_statemachine);
		sensitive << state << ctrl_setup << ctrl_in << ctrl_out;
		sensitive << hdr_done << fifo_full << rom_done << write_done_r;
		sensitive << wValue << bm_req_recp << get_status << clear_feature;
		sensitive << set_feature << set_address << get_descriptor << set_descriptor;
		sensitive << get_config << set_config << get_interface << set_interface;
		sensitive << synch_frame << v_set_int << v_set_feature << v_get_status;
	}

};

#endif

