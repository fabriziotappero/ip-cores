//main_synth.h for vc_ht_tunnel_l1 testbench in ModelSim

/*==========================================================================
  HyperTransport Tunnel IP Core Source Code

  Copyright (C) 2005 by École Polytechnique de Montréal, All rights 
  reserved.
 
  No part of this file may be duplicated, revised, translated, localized or
  modified in any manner or compiled, synthetized, linked or uploaded or
  downloaded to or from any computer system without the prior written 
  consent of École Polytechnique de Montréal.

==========================================================================*/

#ifndef MTI2_SYSTEMC
#error The file main_synth.h must not be included in a normal compilation
#endif

/**
	@file main_synth.h
	@author Ami Castonguay
	@description This file is to be used exclusively to do simulation with
		ModelSim.  It should not be included in normal compilation.
		More specifically, main_synth.h is for post synthesis simulation
*/

#include "../../core_synth/synth_datatypes.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>

#include "vc_ht_tunnel_l1_synth.h"
#include "vc_ht_tunnel_l1_tb.h"

using namespace std;

///Top simulation module for Tunnel simulation with ModelSim
class top : public sc_module{

public:

	sc_clock clk;
	
	//------------------------------------------
	// Instanciation de FLOW CONTROL
	//------------------------------------------
	vc_ht_tunnel_l1 the_ht_tunnel;
	vc_ht_tunnel_l1_tb tb;
	
	// ***************************************************
	//  Signals
	// ***************************************************	
	/// The Clock, LDTSTOP and reset signals
	sc_signal<bool>			resetx;
	sc_signal<bool>			pwrok;
	sc_signal<bool>			ldtstopx;

	//Link0 signals
	//sc_signal<bool >		receive_clk0;
	sc_signal<bool>						phy0_available_lk0;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_ctl_lk0;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__0;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__2;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__3;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__4;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__5;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__6;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0__7;

	//sc_signal< bool >	transmit_clk0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_ctl_phy0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__1;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__2;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__3;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__4;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__5;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__6;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0__7;

	sc_signal<bool>						phy0_consume_lk0;
	
	sc_signal<bool> 		lk0_disable_drivers_phy0;
	sc_signal<bool> 		lk0_disable_receivers_phy0;

	//Link1 signals
	//sc_signal<bool >		receive_clk1;
	sc_signal<bool>						phy1_available_lk1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_ctl_lk1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__0;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__2;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__3;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__4;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__5;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__6;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1__7;

	//sc_signal< bool >	transmit_clk0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_ctl_phy1;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__1;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__2;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__3;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__4;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__5;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__6;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1__7;

	sc_signal<bool>						phy1_consume_lk1;
	
	sc_signal<bool> 		lk1_disable_drivers_phy1;
	sc_signal<bool> 		lk1_disable_receivers_phy1;

	/////////////////////////////////////////////////////
	// Interface to UserInterface memory - synchronous
	/////////////////////////////////////////////////////

	sc_signal<bool> ui_memory_write0;
	sc_signal<bool> ui_memory_write1;//20
	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;
	sc_signal<sc_bv<32> > ui_memory_write_data;

	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;
	sc_signal<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;
	sc_signal<sc_bv<32> > ui_memory_read_data0;
	sc_signal<sc_bv<32> > ui_memory_read_data1;

#ifdef RETRY_MODE_ENABLED
	//////////////////////////////////////////
	//	Memory interface flowcontrol0- synchronous
	/////////////////////////////////////////
	sc_signal<bool> history_memory_write0;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address0;
	sc_signal<sc_bv<32> > history_memory_write_data0;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address0;//30
	sc_signal<sc_bv<32> > history_memory_output0;
	
	//////////////////////////////////////////
	//	Memory interface flowcontrol1- synchronous
	/////////////////////////////////////////
	sc_signal<bool> history_memory_write1;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address1;
	sc_signal<sc_bv<32> > history_memory_write_data1;
	sc_signal<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address1;
	sc_signal<sc_bv<32> > history_memory_output1;

#endif
	
	////////////////////////////////////
	// Memory interface databuffer0 - synchronous
	////////////////////////////////////
	
	sc_signal<bool> memory_write0;
	sc_signal<sc_uint<2> > memory_write_address_vc0;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer0;
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_write_address_pos0;//40
	sc_signal<sc_bv<32> > memory_write_data0;
	
	sc_signal<sc_uint<2> > memory_read_address_vc0__0;
	sc_signal<sc_uint<2> > memory_read_address_vc0__1;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer0__0;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer0__1;
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_read_address_pos0__0;//50
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_read_address_pos0__1;//50

	sc_signal<sc_bv<32> > memory_output0__0;
	sc_signal<sc_bv<32> > memory_output0__1;
	
	//////////////////////////////////////
	// Memory interface databuffer1 - synchronous
	////////////////////////////////////
	
	sc_signal<bool> memory_write1;
	sc_signal<sc_uint<2> > memory_write_address_vc1;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer1;
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_write_address_pos1;
	sc_signal<sc_bv<32> > memory_write_data1;
	
	sc_signal<sc_uint<2> > memory_read_address_vc1__0;
	sc_signal<sc_uint<2> > memory_read_address_vc1__1;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer1__0;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer1__1;
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_read_address_pos1__0;
	sc_signal<sc_uint<DATABUFFER_LOG2_MAX_DATA_PER_BUFFER> > memory_read_address_pos1__1;

	sc_signal<sc_bv<32> > memory_output1__0;
	sc_signal<sc_bv<32> > memory_output1__1;

	
	//************************************
	// Reset generated by link
	//************************************
	//sc_signal<bool>		warmrstx;
	//sc_signal<bool>		coldrstx;

	//sc_signal<bool>		dummy_warmrstx;
	//sc_signal<bool>		dummy_coldrstx;

	//******************************************
	//			Signals to User
	//******************************************
	//------------------------------------------
	// Signals to send received packets to User
	//------------------------------------------


	/**The actual control/data packet to the user*/
	sc_signal<sc_bv<64> >		ui_packet_usr;

	/**The virtual channel of the ctl/data packet*/
	sc_signal<VirtualChannel>	ui_vc_usr;

	/**The side from which came the packet*/
	sc_signal< bool >			ui_side_usr;

	/**If the packet is a direct_route packet - only valid for
	   requests (posted and non-posted) */
	sc_signal<bool>			ui_directroute_usr;

	/**If this is the last part of the packet*/
	sc_signal< bool >			ui_eop_usr;
	
	/**If there is another packet available*/
	sc_signal< bool >			ui_available_usr;

	/**If what is read is 64 bits or 32 bits*/
	sc_signal< bool >			ui_output_64bits_usr;

	/**To allow the user to consume the packets*/
	sc_signal< bool >			usr_consume_ui;


	//------------------------------------------
	// Signals to allow the User to send packets
	//------------------------------------------

	/**The actual control/data packet from the user*/
	sc_signal<sc_bv<64> >		usr_packet_ui;

	/**If there is another packet available*/
	sc_signal< bool >			usr_available_ui;

	/**
	The side to send the packet if it is a response
	This bit is ignored if the packet is not a response
	since the side to send a request is determined automatically
	taking in acount DirectRoute functionnality.
	*/
	sc_signal< bool >			usr_side_ui;

	/**If the packet is trying to be sent to a VC that is full,
	We let the user know that he is doing something illegal
	Packet is not consumed if this is 1
	*/
	//sc_signal < bool > 		ui_invalid_usr;

	/**Which what type of ctl packets can be sent to side0*/
	sc_signal<sc_bv<6> >		ui_freevc0_usr;
	/**Which what type of ctl packets can be sent to side0*/
	sc_signal<sc_bv<6> >		ui_freevc1_usr;

	//-----------------------------------------------
	// Content of CSR that might be useful to user
	//-----------------------------------------------
	/** Signals table containing all 40 bits Base Addresses from BARs implemented */
	sc_signal<sc_bv<40> > csr_bar__0;
	sc_signal<sc_bv<40> > csr_bar__1;
	sc_signal<sc_bv<40> > csr_bar__2;
	sc_signal<sc_bv<40> > csr_bar__3;
	sc_signal<sc_bv<40> > csr_bar__4;
	sc_signal<sc_bv<40> > csr_bar__5;
	/** Signal from register Interface->Command->csr_unit_id */
	sc_signal<sc_bv<5> > csr_unit_id;

	//------------------------------------------
	// Signals to affect CSR
	//------------------------------------------
	sc_signal<bool> usr_receivedResponseError_csr;

	//--------------------------------------------------------
	// Interface for having registers outside CSR if necessary
	//--------------------------------------------------------

	///Signals to allow external registers with minimal logic
	/**
		Connect usr_read_data_csr to zeroes if not used!
	*/
	//@{
	sc_signal<sc_uint<6> >	csr_read_addr_usr;
	sc_signal<sc_bv<32> >	usr_read_data_csr;
	sc_signal<bool >	csr_write_usr;
	sc_signal<sc_uint<6> >	csr_write_addr_usr;
	sc_signal<sc_bv<32> >	csr_write_data_usr;
	/**Every bit is a byte mask for the dword to write*/
	sc_signal<sc_bv<4> >	csr_write_mask_usr;
	//@}




	top(sc_module_name name) : sc_module(name), 
			clk("clk",100,SC_NS,0.5),the_ht_tunnel("dut","vc_ht_tunnel_l1"),
			tb("tb"),
       resetx("resetx"),
       pwrok("pwrok"),
       ldtstopx("ldtstopx"),
       phy0_available_lk0("phy0_available_lk0"),
       phy0_ctl_lk0("phy0_ctl_lk0"),
       phy0_cad_lk0__0("phy0_cad_lk0__0"),
       phy0_cad_lk0__1("phy0_cad_lk0__1"),
       phy0_cad_lk0__2("phy0_cad_lk0__2"),
       phy0_cad_lk0__3("phy0_cad_lk0__3"),
       phy0_cad_lk0__4("phy0_cad_lk0__4"),
       phy0_cad_lk0__5("phy0_cad_lk0__5"),
       phy0_cad_lk0__6("phy0_cad_lk0__6"),
       phy0_cad_lk0__7("phy0_cad_lk0__7"),
       lk0_ctl_phy0("lk0_ctl_phy0"),
       lk0_cad_phy0__0("lk0_cad_phy0__0"),
       lk0_cad_phy0__1("lk0_cad_phy0__1"),
       lk0_cad_phy0__2("lk0_cad_phy0__2"),
       lk0_cad_phy0__3("lk0_cad_phy0__3"),
       lk0_cad_phy0__4("lk0_cad_phy0__4"),
       lk0_cad_phy0__5("lk0_cad_phy0__5"),
       lk0_cad_phy0__6("lk0_cad_phy0__6"),
       lk0_cad_phy0__7("lk0_cad_phy0__7"),
       phy0_consume_lk0("phy0_consume_lk0"),
       lk0_disable_drivers_phy0("lk0_disable_drivers_phy0"),
       lk0_disable_receivers_phy0("lk0_disable_receivers_phy0"),
       phy1_available_lk1("phy1_available_lk1"),
       phy1_ctl_lk1("phy1_ctl_lk1"),
       phy1_cad_lk1__0("phy1_cad_lk1__0"),
       phy1_cad_lk1__1("phy1_cad_lk1__1"),
       phy1_cad_lk1__2("phy1_cad_lk1__2"),
       phy1_cad_lk1__3("phy1_cad_lk1__3"),
       phy1_cad_lk1__4("phy1_cad_lk1__4"),
       phy1_cad_lk1__5("phy1_cad_lk1__5"),
       phy1_cad_lk1__6("phy1_cad_lk1__6"),
       phy1_cad_lk1__7("phy1_cad_lk1__7"),
       lk1_ctl_phy1("lk1_ctl_phy1"),
       lk1_cad_phy1__0("lk1_cad_phy1__0"),
       lk1_cad_phy1__1("lk1_cad_phy1__1"),
       lk1_cad_phy1__2("lk1_cad_phy1__2"),
       lk1_cad_phy1__3("lk1_cad_phy1__3"),
       lk1_cad_phy1__4("lk1_cad_phy1__4"),
       lk1_cad_phy1__5("lk1_cad_phy1__5"),
       lk1_cad_phy1__6("lk1_cad_phy1__6"),
       lk1_cad_phy1__7("lk1_cad_phy1__7"),
       phy1_consume_lk1("phy1_consume_lk1"),
       lk1_disable_drivers_phy1("lk1_disable_drivers_phy1"),
       lk1_disable_receivers_phy1("lk1_disable_receivers_phy1"),
       ui_memory_write0("ui_memory_write0"),
       ui_memory_write1("ui_memory_write1"),
       ui_memory_write_address("ui_memory_write_address"),
       ui_memory_write_data("ui_memory_write_data"),
       ui_memory_read_address0("ui_memory_read_address0"),
       ui_memory_read_address1("ui_memory_read_address1"),
       ui_memory_read_data0("ui_memory_read_data0"),
       ui_memory_read_data1("ui_memory_read_data1"),
       history_memory_write0("history_memory_write0"),
       history_memory_write_address0("history_memory_write_address0"),
       history_memory_write_data0("history_memory_write_data0"),
       history_memory_read_address0("history_memory_read_address0"),
       history_memory_output0("history_memory_output0"),
       history_memory_write1("history_memory_write1"),
       history_memory_write_address1("history_memory_write_address1"),
       history_memory_write_data1("history_memory_write_data1"),
       history_memory_read_address1("history_memory_read_address1"),
       history_memory_output1("history_memory_output1"),
       memory_write0("memory_write0"),
       memory_write_address_vc0("memory_write_address_vc0"),
       memory_write_address_buffer0("memory_write_address_buffer0"),
       memory_write_address_pos0("memory_write_address_pos0"),
       memory_write_data0("memory_write_data0"),
       memory_read_address_vc0__0("memory_read_address_vc0__0"),
       memory_read_address_vc0__1("memory_read_address_vc0__1"),
       memory_read_address_buffer0__0("memory_read_address_buffer0__0"),
       memory_read_address_buffer0__1("memory_read_address_buffer0__1"),
       memory_read_address_pos0__0("memory_read_address_pos0__0"),
       memory_read_address_pos0__1("memory_read_address_pos0__1"),
       memory_output0__0("memory_output0__0"),
       memory_output0__1("memory_output0__1"),
       memory_write1("memory_write1"),
       memory_write_address_vc1("memory_write_address_vc1"),
       memory_write_address_buffer1("memory_write_address_buffer1"),
       memory_write_address_pos1("memory_write_address_pos1"),
       memory_write_data1("memory_write_data1"),
       memory_read_address_vc1__0("memory_read_address_vc1__0"),
       memory_read_address_vc1__1("memory_read_address_vc1__1"),
       memory_read_address_buffer1__0("memory_read_address_buffer1__0"),
       memory_read_address_buffer1__1("memory_read_address_buffer1__1"),
       memory_read_address_pos1__0("memory_read_address_pos1__0"),
       memory_read_address_pos1__1("memory_read_address_pos1__1"),
       memory_output1__0("memory_output1__0"),
       memory_output1__1("memory_output1__1"),
       ui_packet_usr("ui_packet_usr"),
       ui_vc_usr("ui_vc_usr"),
       ui_side_usr("ui_side_usr"),
       ui_directroute_usr("ui_directroute_usr"),
       ui_eop_usr("ui_eop_usr"),
       ui_available_usr("ui_available_usr"),
       ui_output_64bits_usr("ui_output_64bits_usr"),
       usr_consume_ui("usr_consume_ui"),
       usr_packet_ui("usr_packet_ui"),
       usr_available_ui("usr_available_ui"),
       usr_side_ui("usr_side_ui"),
       ui_freevc0_usr("ui_freevc0_usr"),
       ui_freevc1_usr("ui_freevc1_usr"),
       csr_bar__0("csr_bar__0"),
       csr_bar__1("csr_bar__1"),
       csr_bar__2("csr_bar__2"),
       csr_bar__3("csr_bar__3"),
       csr_bar__4("csr_bar__4"),
       csr_bar__5("csr_bar__5"),
       csr_unit_id("csr_unit_id"),
       usr_receivedResponseError_csr("usr_receivedResponseError_csr"),
       csr_read_addr_usr("csr_read_addr_usr"),
       usr_read_data_csr("usr_read_data_csr"),
       csr_write_usr("csr_write_usr"),
       csr_write_addr_usr("csr_write_addr_usr"),
       csr_write_data_usr("csr_write_data_usr"),
       csr_write_mask_usr("csr_write_mask_usr")
	{

		// ***************************************************
		//  LINKING DUT
		// ***************************************************	
		the_ht_tunnel.clk(clk);
		the_ht_tunnel.resetx(resetx);
		the_ht_tunnel.pwrok(pwrok);
		the_ht_tunnel.ldtstopx(ldtstopx);

		the_ht_tunnel.phy0_available_lk0(phy0_available_lk0);
		the_ht_tunnel.phy0_ctl_lk0(phy0_ctl_lk0);
		
#if CAD_IN_WIDTH != 8
#error Not right input width
#endif
#if CAD_OUT_WIDTH != 8
#error Not right output width
#endif

		the_ht_tunnel.phy0_cad_lk0__0(phy0_cad_lk0__0);
		the_ht_tunnel.lk0_cad_phy0__0(lk0_cad_phy0__0);
		the_ht_tunnel.phy1_cad_lk1__0(phy1_cad_lk1__0);
		the_ht_tunnel.lk1_cad_phy1__0(lk1_cad_phy1__0);

		the_ht_tunnel.phy0_cad_lk0__1(phy0_cad_lk0__1);
		the_ht_tunnel.lk0_cad_phy0__1(lk0_cad_phy0__1);
		the_ht_tunnel.phy1_cad_lk1__1(phy1_cad_lk1__1);
		the_ht_tunnel.lk1_cad_phy1__1(lk1_cad_phy1__1);

		the_ht_tunnel.phy0_cad_lk0__2(phy0_cad_lk0__2);
		the_ht_tunnel.lk0_cad_phy0__2(lk0_cad_phy0__2);
		the_ht_tunnel.phy1_cad_lk1__2(phy1_cad_lk1__2);
		the_ht_tunnel.lk1_cad_phy1__2(lk1_cad_phy1__2);

		the_ht_tunnel.phy0_cad_lk0__3(phy0_cad_lk0__3);
		the_ht_tunnel.lk0_cad_phy0__3(lk0_cad_phy0__3);
		the_ht_tunnel.phy1_cad_lk1__3(phy1_cad_lk1__3);
		the_ht_tunnel.lk1_cad_phy1__3(lk1_cad_phy1__3);

		the_ht_tunnel.phy0_cad_lk0__4(phy0_cad_lk0__4);
		the_ht_tunnel.lk0_cad_phy0__4(lk0_cad_phy0__4);
		the_ht_tunnel.phy1_cad_lk1__4(phy1_cad_lk1__4);
		the_ht_tunnel.lk1_cad_phy1__4(lk1_cad_phy1__4);

		the_ht_tunnel.phy0_cad_lk0__5(phy0_cad_lk0__5);
		the_ht_tunnel.lk0_cad_phy0__5(lk0_cad_phy0__5);
		the_ht_tunnel.phy1_cad_lk1__5(phy1_cad_lk1__5);
		the_ht_tunnel.lk1_cad_phy1__5(lk1_cad_phy1__5);

		the_ht_tunnel.phy0_cad_lk0__6(phy0_cad_lk0__6);
		the_ht_tunnel.lk0_cad_phy0__6(lk0_cad_phy0__6);
		the_ht_tunnel.phy1_cad_lk1__6(phy1_cad_lk1__6);
		the_ht_tunnel.lk1_cad_phy1__6(lk1_cad_phy1__6);

		the_ht_tunnel.phy0_cad_lk0__7(phy0_cad_lk0__7);
		the_ht_tunnel.lk0_cad_phy0__7(lk0_cad_phy0__7);
		the_ht_tunnel.phy1_cad_lk1__7(phy1_cad_lk1__7);
		the_ht_tunnel.lk1_cad_phy1__7(lk1_cad_phy1__7);

		the_ht_tunnel.lk0_ctl_phy0(lk0_ctl_phy0);
		the_ht_tunnel.phy0_consume_lk0(phy0_consume_lk0);
		
		the_ht_tunnel.lk0_disable_drivers_phy0(lk0_disable_drivers_phy0);
		the_ht_tunnel.lk0_disable_receivers_phy0(lk0_disable_receivers_phy0);

		the_ht_tunnel.phy1_available_lk1(phy1_available_lk1);
		the_ht_tunnel.phy1_ctl_lk1(phy1_ctl_lk1);

		the_ht_tunnel.lk1_ctl_phy1(lk1_ctl_phy1);
		the_ht_tunnel.phy1_consume_lk1(phy1_consume_lk1);
		
		the_ht_tunnel.lk1_disable_drivers_phy1(lk1_disable_drivers_phy1);
		the_ht_tunnel.lk1_disable_receivers_phy1(lk1_disable_receivers_phy1);

		the_ht_tunnel.ui_memory_write0(ui_memory_write0);
		the_ht_tunnel.ui_memory_write1(ui_memory_write1);//20
		the_ht_tunnel.ui_memory_write_address(ui_memory_write_address);
		the_ht_tunnel.ui_memory_write_data(ui_memory_write_data);

		the_ht_tunnel.ui_memory_read_address0(ui_memory_read_address0);
		the_ht_tunnel.ui_memory_read_address1(ui_memory_read_address1);
		the_ht_tunnel.ui_memory_read_data0(ui_memory_read_data0);
		the_ht_tunnel.ui_memory_read_data1(ui_memory_read_data1);

	#ifdef RETRY_MODE_ENABLED
		the_ht_tunnel.history_memory_write0(history_memory_write0);
		the_ht_tunnel.history_memory_write_address0(history_memory_write_address0);
		the_ht_tunnel.history_memory_write_data0(history_memory_write_data0);
		the_ht_tunnel.history_memory_read_address0(history_memory_read_address0);//30
		the_ht_tunnel.history_memory_output0(history_memory_output0);
		
		the_ht_tunnel.history_memory_write1(history_memory_write1);
		the_ht_tunnel.history_memory_write_address1(history_memory_write_address1);
		the_ht_tunnel.history_memory_write_data1(history_memory_write_data1);
		the_ht_tunnel.history_memory_read_address1(history_memory_read_address1);
		the_ht_tunnel.history_memory_output1(history_memory_output1);

	#endif
		
		
		the_ht_tunnel.memory_write0(memory_write0);
		the_ht_tunnel.memory_write_address_vc0(memory_write_address_vc0);
		the_ht_tunnel.memory_write_address_buffer0(memory_write_address_buffer0);
		the_ht_tunnel.memory_write_address_pos0(memory_write_address_pos0);//40
		the_ht_tunnel.memory_write_data0(memory_write_data0);
		
		the_ht_tunnel.memory_read_address_vc0__0(memory_read_address_vc0__0);
		the_ht_tunnel.memory_read_address_buffer0__0(memory_read_address_buffer0__0);
		the_ht_tunnel.memory_read_address_pos0__0(memory_read_address_pos0__0);//50
		the_ht_tunnel.memory_output0__0(memory_output0__0);
		
		the_ht_tunnel.memory_read_address_vc0__1(memory_read_address_vc0__1);
		the_ht_tunnel.memory_read_address_buffer0__1(memory_read_address_buffer0__1);
		the_ht_tunnel.memory_read_address_pos0__1(memory_read_address_pos0__1);//50
		the_ht_tunnel.memory_output0__1(memory_output0__1);
		
		
		the_ht_tunnel.memory_write1(memory_write1);
		the_ht_tunnel.memory_write_address_vc1(memory_write_address_vc1);
		the_ht_tunnel.memory_write_address_buffer1(memory_write_address_buffer1);
		the_ht_tunnel.memory_write_address_pos1(memory_write_address_pos1);
		the_ht_tunnel.memory_write_data1(memory_write_data1);
		
		the_ht_tunnel.memory_read_address_vc1__0(memory_read_address_vc1__0);
		the_ht_tunnel.memory_read_address_buffer1__0(memory_read_address_buffer1__0);
		the_ht_tunnel.memory_read_address_pos1__0(memory_read_address_pos1__0);
		the_ht_tunnel.memory_output1__0(memory_output1__0);

		the_ht_tunnel.memory_read_address_vc1__1(memory_read_address_vc1__1);
		the_ht_tunnel.memory_read_address_buffer1__1(memory_read_address_buffer1__1);
		the_ht_tunnel.memory_read_address_pos1__1(memory_read_address_pos1__1);
		the_ht_tunnel.memory_output1__1(memory_output1__1);

		
		the_ht_tunnel.ui_packet_usr(ui_packet_usr);
		the_ht_tunnel.ui_vc_usr(ui_vc_usr);
		the_ht_tunnel.ui_side_usr(ui_side_usr);
		the_ht_tunnel.ui_directroute_usr(ui_directroute_usr);
		the_ht_tunnel.ui_eop_usr(ui_eop_usr);
		the_ht_tunnel.ui_available_usr(ui_available_usr);
		the_ht_tunnel.ui_output_64bits_usr(ui_output_64bits_usr);
		the_ht_tunnel.usr_consume_ui(usr_consume_ui);
		the_ht_tunnel.usr_packet_ui(usr_packet_ui);
		the_ht_tunnel.usr_available_ui(usr_available_ui);
		the_ht_tunnel.usr_side_ui(usr_side_ui);
		the_ht_tunnel.ui_freevc0_usr(ui_freevc0_usr);
		the_ht_tunnel.ui_freevc1_usr(ui_freevc1_usr);
#if NbRegsBars != 6
#error Not correct number of BARs
#endif
		the_ht_tunnel.csr_bar__0(csr_bar__0);
		the_ht_tunnel.csr_bar__1(csr_bar__1);
		the_ht_tunnel.csr_bar__2(csr_bar__2);
		the_ht_tunnel.csr_bar__3(csr_bar__3);
		the_ht_tunnel.csr_bar__4(csr_bar__4);
		the_ht_tunnel.csr_bar__5(csr_bar__5);

		the_ht_tunnel.csr_unit_id(csr_unit_id);
		the_ht_tunnel.usr_receivedResponseError_csr(usr_receivedResponseError_csr);

		the_ht_tunnel.csr_read_addr_usr(csr_read_addr_usr);
		the_ht_tunnel.usr_read_data_csr(usr_read_data_csr);
		the_ht_tunnel.csr_write_usr(csr_write_usr);
		the_ht_tunnel.csr_write_addr_usr(csr_write_addr_usr);
		the_ht_tunnel.csr_write_data_usr(csr_write_data_usr);
		the_ht_tunnel.csr_write_mask_usr(csr_write_mask_usr);
		
		// ***************************************************
		//  LINKING TB
		// ***************************************************	

		tb.clk(clk);
		tb.resetx(resetx);
		tb.pwrok(pwrok);
		tb.ldtstopx(ldtstopx);

		tb.phy0_available_lk0(phy0_available_lk0);
		tb.phy0_ctl_lk0(phy0_ctl_lk0);
		
		tb.phy0_cad_lk0[0](phy0_cad_lk0__0);
		tb.lk0_cad_phy0[0](lk0_cad_phy0__0);
		tb.phy1_cad_lk1[0](phy1_cad_lk1__0);
		tb.lk1_cad_phy1[0](lk1_cad_phy1__0);

		tb.phy0_cad_lk0[1](phy0_cad_lk0__1);
		tb.lk0_cad_phy0[1](lk0_cad_phy0__1);
		tb.phy1_cad_lk1[1](phy1_cad_lk1__1);
		tb.lk1_cad_phy1[1](lk1_cad_phy1__1);

		tb.phy0_cad_lk0[2](phy0_cad_lk0__2);
		tb.lk0_cad_phy0[2](lk0_cad_phy0__2);
		tb.phy1_cad_lk1[2](phy1_cad_lk1__2);
		tb.lk1_cad_phy1[2](lk1_cad_phy1__2);

		tb.phy0_cad_lk0[3](phy0_cad_lk0__3);
		tb.lk0_cad_phy0[3](lk0_cad_phy0__3);
		tb.phy1_cad_lk1[3](phy1_cad_lk1__3);
		tb.lk1_cad_phy1[3](lk1_cad_phy1__3);

		tb.phy0_cad_lk0[4](phy0_cad_lk0__4);
		tb.lk0_cad_phy0[4](lk0_cad_phy0__4);
		tb.phy1_cad_lk1[4](phy1_cad_lk1__4);
		tb.lk1_cad_phy1[4](lk1_cad_phy1__4);

		tb.phy0_cad_lk0[5](phy0_cad_lk0__5);
		tb.lk0_cad_phy0[5](lk0_cad_phy0__5);
		tb.phy1_cad_lk1[5](phy1_cad_lk1__5);
		tb.lk1_cad_phy1[5](lk1_cad_phy1__5);

		tb.phy0_cad_lk0[6](phy0_cad_lk0__6);
		tb.lk0_cad_phy0[6](lk0_cad_phy0__6);
		tb.phy1_cad_lk1[6](phy1_cad_lk1__6);
		tb.lk1_cad_phy1[6](lk1_cad_phy1__6);

		tb.phy0_cad_lk0[7](phy0_cad_lk0__7);
		tb.lk0_cad_phy0[7](lk0_cad_phy0__7);
		tb.phy1_cad_lk1[7](phy1_cad_lk1__7);
		tb.lk1_cad_phy1[7](lk1_cad_phy1__7);

		tb.lk0_ctl_phy0(lk0_ctl_phy0);
		tb.phy0_consume_lk0(phy0_consume_lk0);
		
		tb.lk0_disable_drivers_phy0(lk0_disable_drivers_phy0);
		tb.lk0_disable_receivers_phy0(lk0_disable_receivers_phy0);

		tb.phy1_available_lk1(phy1_available_lk1);
		tb.phy1_ctl_lk1(phy1_ctl_lk1);

		tb.lk1_ctl_phy1(lk1_ctl_phy1);
		tb.phy1_consume_lk1(phy1_consume_lk1);
		
		tb.lk1_disable_drivers_phy1(lk1_disable_drivers_phy1);
		tb.lk1_disable_receivers_phy1(lk1_disable_receivers_phy1);

		tb.ui_memory_write0(ui_memory_write0);
		tb.ui_memory_write1(ui_memory_write1);//20
		tb.ui_memory_write_address(ui_memory_write_address);
		tb.ui_memory_write_data(ui_memory_write_data);

		tb.ui_memory_read_address0(ui_memory_read_address0);
		tb.ui_memory_read_address1(ui_memory_read_address1);
		tb.ui_memory_read_data0(ui_memory_read_data0);
		tb.ui_memory_read_data1(ui_memory_read_data1);

	#ifdef RETRY_MODE_ENABLED
		tb.history_memory_write0(history_memory_write0);
		tb.history_memory_write_address0(history_memory_write_address0);
		tb.history_memory_write_data0(history_memory_write_data0);
		tb.history_memory_read_address0(history_memory_read_address0);//30
		tb.history_memory_output0(history_memory_output0);
		
		tb.history_memory_write1(history_memory_write1);
		tb.history_memory_write_address1(history_memory_write_address1);
		tb.history_memory_write_data1(history_memory_write_data1);
		tb.history_memory_read_address1(history_memory_read_address1);
		tb.history_memory_output1(history_memory_output1);

	#endif
		
		
		tb.memory_write0(memory_write0);
		tb.memory_write_address_vc0(memory_write_address_vc0);
		tb.memory_write_address_buffer0(memory_write_address_buffer0);
		tb.memory_write_address_pos0(memory_write_address_pos0);//40
		tb.memory_write_data0(memory_write_data0);
		
		tb.memory_read_address_vc0[0](memory_read_address_vc0__0);
		tb.memory_read_address_buffer0[0](memory_read_address_buffer0__0);
		tb.memory_read_address_pos0[0](memory_read_address_pos0__0);//50
		tb.memory_output0[0](memory_output0__0);
		
		tb.memory_read_address_vc0[1](memory_read_address_vc0__1);
		tb.memory_read_address_buffer0[1](memory_read_address_buffer0__1);
		tb.memory_read_address_pos0[1](memory_read_address_pos0__1);//50
		tb.memory_output0[1](memory_output0__1);
		
		
		tb.memory_write1(memory_write1);
		tb.memory_write_address_vc1(memory_write_address_vc1);
		tb.memory_write_address_buffer1(memory_write_address_buffer1);
		tb.memory_write_address_pos1(memory_write_address_pos1);
		tb.memory_write_data1(memory_write_data1);
		
		tb.memory_read_address_vc1[0](memory_read_address_vc1__0);
		tb.memory_read_address_buffer1[0](memory_read_address_buffer1__0);
		tb.memory_read_address_pos1[0](memory_read_address_pos1__0);
		tb.memory_output1[0](memory_output1__0);

		tb.memory_read_address_vc1[1](memory_read_address_vc1__1);
		tb.memory_read_address_buffer1[1](memory_read_address_buffer1__1);
		tb.memory_read_address_pos1[1](memory_read_address_pos1__1);
		tb.memory_output1[1](memory_output1__1);

		
		tb.ui_packet_usr(ui_packet_usr);
		tb.ui_vc_usr(ui_vc_usr);
		tb.ui_side_usr(ui_side_usr);
		tb.ui_directroute_usr(ui_directroute_usr);
		tb.ui_eop_usr(ui_eop_usr);
		tb.ui_available_usr(ui_available_usr);
		tb.ui_output_64bits_usr(ui_output_64bits_usr);
		tb.usr_consume_ui(usr_consume_ui);
		tb.usr_packet_ui(usr_packet_ui);
		tb.usr_available_ui(usr_available_ui);
		tb.usr_side_ui(usr_side_ui);
		tb.ui_freevc0_usr(ui_freevc0_usr);
		tb.ui_freevc1_usr(ui_freevc1_usr);
		tb.usr_receivedResponseError_csr(usr_receivedResponseError_csr);
	}
};

