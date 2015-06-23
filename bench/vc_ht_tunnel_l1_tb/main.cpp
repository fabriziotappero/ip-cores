//main.cpp for vc_ht_tunnel_l1 testbench

/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is HyperTransport Tunnel IP Core.
 *
 * The Initial Developer of the Original Code is
 * Ecole Polytechnique de Montreal.
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Ami Castonguay <acastong@grm.polymtl.ca>
 *
 * Alternatively, the contents of this file may be used under the terms
 * of the Polytechnique HyperTransport Tunnel IP Core Source Code License 
 * (the  "PHTICSCL License", see the file PHTICSCL.txt), in which case the
 * provisions of PHTICSCL License are applicable instead of those
 * above. If you wish to allow use of your version of this file only
 * under the terms of the PHTICSCL License and not to allow others to use
 * your version of this file under the MPL, indicate your decision by
 * deleting the provisions above and replace them with the notice and
 * other provisions required by the PHTICSCL License. If you do not delete
 * the provisions above, a recipient may use your version of this file
 * under either the MPL or the PHTICSCL License."
 *
 * ***** END LICENSE BLOCK ***** */

#ifdef MTI_SYSTEMC
//For ModelSim simulation, top simulation must be contained within
//a module instanciated in a .h
#include "main.h"
//Directive to mark the top level of the simulated design
SC_MODULE_EXPORT(top);

//MTI_SYSTEMC does not work on all version of ModelSim, this is a fallback
#elif MTI2_SYSTEMC

//For ModelSim simulation, top simulation must be contained within
//a module instanciated in a .h
#include "main.h"
//Directive to mark the top level of the simulated design
SC_MODULE_EXPORT(top);

//If not in ModelSim simulation, proceed with the standard procedure
#else

#include "../../rtl/systemc/core_synth/synth_datatypes.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <ctime>

#include "../../rtl/systemc/vc_ht_tunnel_l1/vc_ht_tunnel_l1.h"
#include "../../rtl/systemc/flow_control_l2/user_fifo_l3.h"
#include "../../rtl/systemc/flow_control_l2/history_buffer_l3.h"
#include "vc_ht_tunnel_l1_tb.h"

using namespace std;

// Main fonction
int sc_main( int argc, char* argv[] )
{

    sc_clock clk("CLOCK",1,SC_NS);
	
	//------------------------------------------
	// Instanciation de FLOW CONTROL
	//------------------------------------------
	vc_ht_tunnel_l1* the_ht_tunnel = new vc_ht_tunnel_l1("the_ht_tunnel");
	vc_ht_tunnel_l1_tb * tb = new vc_ht_tunnel_l1_tb("vc_ht_tunnel_l1_tb");
	
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
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0[CAD_IN_WIDTH];

	//sc_signal< bool >	transmit_clk0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_ctl_phy0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0[CAD_OUT_WIDTH];
	sc_signal<bool>						phy0_consume_lk0;
	
	sc_signal<bool> 		lk0_disable_drivers_phy0;
	sc_signal<bool> 		lk0_disable_receivers_phy0;

	sc_signal<sc_bv<4> > link_frequency0_phy;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_signal<bool > lk0_deser_stall_phy0;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> > lk0_deser_stall_cycles_phy0;
#endif

	//Link1 signals
	//sc_signal<bool >		receive_clk1;
	sc_signal<bool>						phy1_available_lk1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_ctl_lk1;
	sc_signal<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1[CAD_IN_WIDTH];

	//sc_signal< bool >	transmit_clk0;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_ctl_phy1;
	sc_signal<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1[CAD_OUT_WIDTH];
	sc_signal<bool>						phy1_consume_lk1;
	
	sc_signal<bool> 		lk1_disable_drivers_phy1;
	sc_signal<bool> 		lk1_disable_receivers_phy1;

	sc_signal<sc_bv<4> > link_frequency1_phy;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_signal<bool > lk1_deser_stall_phy1;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_signal<sc_uint<LOG2_CAD_IN_DEPTH> > lk1_deser_stall_cycles_phy1;
#endif

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
	sc_signal<sc_uint<4> > memory_write_address_pos0;//40
	sc_signal<sc_bv<32> > memory_write_data0;
	
	sc_signal<sc_uint<2> > memory_read_address_vc0[2];
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer0[2];
	sc_signal<sc_uint<4> > memory_read_address_pos0[2];//50

	sc_signal<sc_bv<32> > memory_output0[2];
	
	//////////////////////////////////////
	// Memory interface databuffer1 - synchronous
	////////////////////////////////////
	
	sc_signal<bool> memory_write1;
	sc_signal<sc_uint<2> > memory_write_address_vc1;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer1;
	sc_signal<sc_uint<4> > memory_write_address_pos1;
	sc_signal<sc_bv<32> > memory_write_data1;
	
	sc_signal<sc_uint<2> > memory_read_address_vc1[2];
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer1[2];
	sc_signal<sc_uint<4> > memory_read_address_pos1[2];

	sc_signal<sc_bv<32> > memory_output1[2];

	
	///////////////////////////////////////
	// Interface to command memory 0
	///////////////////////////////////////
	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro0_command_packet_wr_data;
	sc_signal<bool > ro0_command_packet_write;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_wr_addr;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_rd_addr[2];
	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro0[2];

	///////////////////////////////////////
	// Interface to command memory 1
	///////////////////////////////////////
	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro1_command_packet_wr_data;
	sc_signal<bool > ro1_command_packet_write;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_wr_addr;
	sc_signal<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_rd_addr[2];
	sc_signal<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro1[2];

	
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
	sc_signal<sc_bv<40> > csr_bar[NbRegsBars];
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

	// ***************************************************
	//  LINKING DUT
	// ***************************************************	
    
	the_ht_tunnel->clk(clk);
	the_ht_tunnel->resetx(resetx);
	the_ht_tunnel->pwrok(pwrok);
	the_ht_tunnel->ldtstopx(ldtstopx);

	the_ht_tunnel->phy0_available_lk0(phy0_available_lk0);
	the_ht_tunnel->phy0_ctl_lk0(phy0_ctl_lk0);
	
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		the_ht_tunnel->phy0_cad_lk0[n](phy0_cad_lk0[n]);
		the_ht_tunnel->lk0_cad_phy0[n](lk0_cad_phy0[n]);
		the_ht_tunnel->phy1_cad_lk1[n](phy1_cad_lk1[n]);
		the_ht_tunnel->lk1_cad_phy1[n](lk1_cad_phy1[n]);
	}

	the_ht_tunnel->lk0_ctl_phy0(lk0_ctl_phy0);
	the_ht_tunnel->phy0_consume_lk0(phy0_consume_lk0);
	
	the_ht_tunnel->lk0_disable_drivers_phy0(lk0_disable_drivers_phy0);
	the_ht_tunnel->lk0_disable_receivers_phy0(lk0_disable_receivers_phy0);
	the_ht_tunnel->link_frequency0_phy(link_frequency0_phy);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	the_ht_tunnel->lk0_deser_stall_phy0(lk0_deser_stall_phy0);
	the_ht_tunnel->lk0_deser_stall_cycles_phy0(lk0_deser_stall_cycles_phy0);
#endif

	the_ht_tunnel->phy1_available_lk1(phy1_available_lk1);
	the_ht_tunnel->phy1_ctl_lk1(phy1_ctl_lk1);

	the_ht_tunnel->lk1_ctl_phy1(lk1_ctl_phy1);
	the_ht_tunnel->phy1_consume_lk1(phy1_consume_lk1);
	
	the_ht_tunnel->lk1_disable_drivers_phy1(lk1_disable_drivers_phy1);
	the_ht_tunnel->lk1_disable_receivers_phy1(lk1_disable_receivers_phy1);
	the_ht_tunnel->link_frequency1_phy(link_frequency1_phy);

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	the_ht_tunnel->lk1_deser_stall_phy1(lk1_deser_stall_phy1);
	the_ht_tunnel->lk1_deser_stall_cycles_phy1(lk1_deser_stall_cycles_phy1);
#endif

	the_ht_tunnel->ui_memory_write0(ui_memory_write0);
	the_ht_tunnel->ui_memory_write1(ui_memory_write1);//20
	the_ht_tunnel->ui_memory_write_address(ui_memory_write_address);
	the_ht_tunnel->ui_memory_write_data(ui_memory_write_data);

	the_ht_tunnel->ui_memory_read_address0(ui_memory_read_address0);
	the_ht_tunnel->ui_memory_read_address1(ui_memory_read_address1);
	the_ht_tunnel->ui_memory_read_data0(ui_memory_read_data0);
	the_ht_tunnel->ui_memory_read_data1(ui_memory_read_data1);

#ifdef RETRY_MODE_ENABLED
	the_ht_tunnel->history_memory_write0(history_memory_write0);
	the_ht_tunnel->history_memory_write_address0(history_memory_write_address0);
	the_ht_tunnel->history_memory_write_data0(history_memory_write_data0);
	the_ht_tunnel->history_memory_read_address0(history_memory_read_address0);//30
	the_ht_tunnel->history_memory_output0(history_memory_output0);
	
	the_ht_tunnel->history_memory_write1(history_memory_write1);
	the_ht_tunnel->history_memory_write_address1(history_memory_write_address1);
	the_ht_tunnel->history_memory_write_data1(history_memory_write_data1);
	the_ht_tunnel->history_memory_read_address1(history_memory_read_address1);
	the_ht_tunnel->history_memory_output1(history_memory_output1);

#endif
	
	
	the_ht_tunnel->memory_write0(memory_write0);
	the_ht_tunnel->memory_write_address_vc0(memory_write_address_vc0);
	the_ht_tunnel->memory_write_address_buffer0(memory_write_address_buffer0);
	the_ht_tunnel->memory_write_address_pos0(memory_write_address_pos0);//40
	the_ht_tunnel->memory_write_data0(memory_write_data0);
	
	the_ht_tunnel->memory_read_address_vc0[0](memory_read_address_vc0[0]);
	the_ht_tunnel->memory_read_address_buffer0[0](memory_read_address_buffer0[0]);
	the_ht_tunnel->memory_read_address_pos0[0](memory_read_address_pos0[0]);//50
	the_ht_tunnel->memory_output0[0](memory_output0[0]);
	
	the_ht_tunnel->memory_read_address_vc0[1](memory_read_address_vc0[1]);
	the_ht_tunnel->memory_read_address_buffer0[1](memory_read_address_buffer0[1]);
	the_ht_tunnel->memory_read_address_pos0[1](memory_read_address_pos0[1]);//50
	the_ht_tunnel->memory_output0[1](memory_output0[1]);
	
	
	the_ht_tunnel->memory_write1(memory_write1);
	the_ht_tunnel->memory_write_address_vc1(memory_write_address_vc1);
	the_ht_tunnel->memory_write_address_buffer1(memory_write_address_buffer1);
	the_ht_tunnel->memory_write_address_pos1(memory_write_address_pos1);
	the_ht_tunnel->memory_write_data1(memory_write_data1);
	
	the_ht_tunnel->memory_read_address_vc1[0](memory_read_address_vc1[0]);
	the_ht_tunnel->memory_read_address_buffer1[0](memory_read_address_buffer1[0]);
	the_ht_tunnel->memory_read_address_pos1[0](memory_read_address_pos1[0]);
	the_ht_tunnel->memory_output1[0](memory_output1[0]);

	the_ht_tunnel->memory_read_address_vc1[1](memory_read_address_vc1[1]);
	the_ht_tunnel->memory_read_address_buffer1[1](memory_read_address_buffer1[1]);
	the_ht_tunnel->memory_read_address_pos1[1](memory_read_address_pos1[1]);
	the_ht_tunnel->memory_output1[1](memory_output1[1]);

	the_ht_tunnel->ro0_command_packet_wr_data(ro0_command_packet_wr_data);
	the_ht_tunnel->ro0_command_packet_write(ro0_command_packet_write);
	the_ht_tunnel->ro0_command_packet_wr_addr(ro0_command_packet_wr_addr);
	the_ht_tunnel->ro0_command_packet_rd_addr[0](ro0_command_packet_rd_addr[0]);
	the_ht_tunnel->command_packet_rd_data_ro0[0](command_packet_rd_data_ro0[0]);
	the_ht_tunnel->ro0_command_packet_rd_addr[1](ro0_command_packet_rd_addr[1]);
	the_ht_tunnel->command_packet_rd_data_ro0[1](command_packet_rd_data_ro0[1]);

	the_ht_tunnel->ro1_command_packet_wr_data(ro1_command_packet_wr_data);
	the_ht_tunnel->ro1_command_packet_write(ro1_command_packet_write);
	the_ht_tunnel->ro1_command_packet_wr_addr(ro1_command_packet_wr_addr);
	the_ht_tunnel->ro1_command_packet_rd_addr[0](ro1_command_packet_rd_addr[0]);
	the_ht_tunnel->command_packet_rd_data_ro1[0](command_packet_rd_data_ro1[0]);
	the_ht_tunnel->ro1_command_packet_rd_addr[1](ro1_command_packet_rd_addr[1]);
	the_ht_tunnel->command_packet_rd_data_ro1[1](command_packet_rd_data_ro1[1]);
	
	the_ht_tunnel->ui_packet_usr(ui_packet_usr);
	the_ht_tunnel->ui_vc_usr(ui_vc_usr);
	the_ht_tunnel->ui_side_usr(ui_side_usr);
#ifdef ENABLE_DIRECTROUTE
	the_ht_tunnel->ui_directroute_usr(ui_directroute_usr);
#endif
	the_ht_tunnel->ui_eop_usr(ui_eop_usr);
	the_ht_tunnel->ui_available_usr(ui_available_usr);
	the_ht_tunnel->ui_output_64bits_usr(ui_output_64bits_usr);
	the_ht_tunnel->usr_consume_ui(usr_consume_ui);
	the_ht_tunnel->usr_packet_ui(usr_packet_ui);
	the_ht_tunnel->usr_available_ui(usr_available_ui);
	the_ht_tunnel->usr_side_ui(usr_side_ui);
	the_ht_tunnel->ui_freevc0_usr(ui_freevc0_usr);
	the_ht_tunnel->ui_freevc1_usr(ui_freevc1_usr);
	for(int n = 0; n < NbRegsBars; n++)
		the_ht_tunnel->csr_bar[n](csr_bar[n]);
	the_ht_tunnel->csr_unit_id(csr_unit_id);
	the_ht_tunnel->usr_receivedResponseError_csr(usr_receivedResponseError_csr);

	the_ht_tunnel->csr_read_addr_usr(csr_read_addr_usr);
	the_ht_tunnel->usr_read_data_csr(usr_read_data_csr);
	the_ht_tunnel->csr_write_usr(csr_write_usr);
	the_ht_tunnel->csr_write_addr_usr(csr_write_addr_usr);
	the_ht_tunnel->csr_write_data_usr(csr_write_data_usr);
	the_ht_tunnel->csr_write_mask_usr(csr_write_mask_usr);

	// ***************************************************
	//  LINKING TB
	// ***************************************************	

	tb->clk(clk);
	tb->resetx(resetx);
	tb->pwrok(pwrok);
	tb->ldtstopx(ldtstopx);

	tb->phy0_available_lk0(phy0_available_lk0);
	tb->phy0_ctl_lk0(phy0_ctl_lk0);
	
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		tb->phy0_cad_lk0[n](phy0_cad_lk0[n]);
		tb->lk0_cad_phy0[n](lk0_cad_phy0[n]);
		tb->phy1_cad_lk1[n](phy1_cad_lk1[n]);
		tb->lk1_cad_phy1[n](lk1_cad_phy1[n]);
	}

	tb->lk0_ctl_phy0(lk0_ctl_phy0);
	tb->phy0_consume_lk0(phy0_consume_lk0);
	
	tb->lk0_disable_drivers_phy0(lk0_disable_drivers_phy0);
	tb->lk0_disable_receivers_phy0(lk0_disable_receivers_phy0);

	tb->phy1_available_lk1(phy1_available_lk1);
	tb->phy1_ctl_lk1(phy1_ctl_lk1);

	tb->lk1_ctl_phy1(lk1_ctl_phy1);
	tb->phy1_consume_lk1(phy1_consume_lk1);
	
	tb->lk1_disable_drivers_phy1(lk1_disable_drivers_phy1);
	tb->lk1_disable_receivers_phy1(lk1_disable_receivers_phy1);

	tb->ui_memory_write0(ui_memory_write0);
	tb->ui_memory_write1(ui_memory_write1);//20
	tb->ui_memory_write_address(ui_memory_write_address);
	tb->ui_memory_write_data(ui_memory_write_data);

	tb->ui_memory_read_address0(ui_memory_read_address0);
	tb->ui_memory_read_address1(ui_memory_read_address1);
	tb->ui_memory_read_data0(ui_memory_read_data0);
	tb->ui_memory_read_data1(ui_memory_read_data1);

#ifdef RETRY_MODE_ENABLED
	tb->history_memory_write0(history_memory_write0);
	tb->history_memory_write_address0(history_memory_write_address0);
	tb->history_memory_write_data0(history_memory_write_data0);
	tb->history_memory_read_address0(history_memory_read_address0);//30
	tb->history_memory_output0(history_memory_output0);
	
	tb->history_memory_write1(history_memory_write1);
	tb->history_memory_write_address1(history_memory_write_address1);
	tb->history_memory_write_data1(history_memory_write_data1);
	tb->history_memory_read_address1(history_memory_read_address1);
	tb->history_memory_output1(history_memory_output1);

#endif
	
	
	tb->memory_write0(memory_write0);
	tb->memory_write_address_vc0(memory_write_address_vc0);
	tb->memory_write_address_buffer0(memory_write_address_buffer0);
	tb->memory_write_address_pos0(memory_write_address_pos0);//40
	tb->memory_write_data0(memory_write_data0);
	
	tb->memory_read_address_vc0[0](memory_read_address_vc0[0]);
	tb->memory_read_address_buffer0[0](memory_read_address_buffer0[0]);
	tb->memory_read_address_pos0[0](memory_read_address_pos0[0]);//50
	tb->memory_output0[0](memory_output0[0]);
	
	tb->memory_read_address_vc0[1](memory_read_address_vc0[1]);
	tb->memory_read_address_buffer0[1](memory_read_address_buffer0[1]);
	tb->memory_read_address_pos0[1](memory_read_address_pos0[1]);//50
	tb->memory_output0[1](memory_output0[1]);
	
	
	tb->memory_write1(memory_write1);
	tb->memory_write_address_vc1(memory_write_address_vc1);
	tb->memory_write_address_buffer1(memory_write_address_buffer1);
	tb->memory_write_address_pos1(memory_write_address_pos1);
	tb->memory_write_data1(memory_write_data1);
	
	tb->memory_read_address_vc1[0](memory_read_address_vc1[0]);
	tb->memory_read_address_buffer1[0](memory_read_address_buffer1[0]);
	tb->memory_read_address_pos1[0](memory_read_address_pos1[0]);
	tb->memory_output1[0](memory_output1[0]);

	tb->memory_read_address_vc1[1](memory_read_address_vc1[1]);
	tb->memory_read_address_buffer1[1](memory_read_address_buffer1[1]);
	tb->memory_read_address_pos1[1](memory_read_address_pos1[1]);
	tb->memory_output1[1](memory_output1[1]);

	tb->ro0_command_packet_wr_data(ro0_command_packet_wr_data);
	tb->ro0_command_packet_write(ro0_command_packet_write);
	tb->ro0_command_packet_wr_addr(ro0_command_packet_wr_addr);
	tb->ro0_command_packet_rd_addr[0](ro0_command_packet_rd_addr[0]);
	tb->command_packet_rd_data_ro0[0](command_packet_rd_data_ro0[0]);
	tb->ro0_command_packet_rd_addr[1](ro0_command_packet_rd_addr[1]);
	tb->command_packet_rd_data_ro0[1](command_packet_rd_data_ro0[1]);

	tb->ro1_command_packet_wr_data(ro1_command_packet_wr_data);
	tb->ro1_command_packet_write(ro1_command_packet_write);
	tb->ro1_command_packet_wr_addr(ro1_command_packet_wr_addr);
	tb->ro1_command_packet_rd_addr[0](ro1_command_packet_rd_addr[0]);
	tb->command_packet_rd_data_ro1[0](command_packet_rd_data_ro1[0]);
	tb->ro1_command_packet_rd_addr[1](ro1_command_packet_rd_addr[1]);
	tb->command_packet_rd_data_ro1[1](command_packet_rd_data_ro1[1]);
	
	tb->ui_packet_usr(ui_packet_usr);
	tb->ui_vc_usr(ui_vc_usr);
	tb->ui_side_usr(ui_side_usr);
	tb->ui_directroute_usr(ui_directroute_usr);
	tb->ui_eop_usr(ui_eop_usr);
	tb->ui_available_usr(ui_available_usr);
	tb->ui_output_64bits_usr(ui_output_64bits_usr);
	tb->usr_consume_ui(usr_consume_ui);
	tb->usr_packet_ui(usr_packet_ui);
	tb->usr_available_ui(usr_available_ui);
	tb->usr_side_ui(usr_side_ui);
	tb->ui_freevc0_usr(ui_freevc0_usr);
	tb->ui_freevc1_usr(ui_freevc1_usr);
	tb->usr_receivedResponseError_csr(usr_receivedResponseError_csr);


	// ***************************************************
	//  Tracing signals
	// ***************************************************	

	sc_trace_file *tf = sc_create_vcd_trace_file("sim_vc_ht_tunnel_l1");

	sc_trace(tf,clk,"clk");
	sc_trace(tf,resetx,"resetx");
	sc_trace(tf,pwrok,"pwrok");
	sc_trace(tf,ldtstopx,"ldtstopx");

	sc_trace(tf,phy0_available_lk0,"phy0_available_lk0");
	sc_trace(tf,phy0_ctl_lk0,"phy0_ctl_lk0");
	
	for(int n = 0; n < CAD_IN_WIDTH; n++){
		ostringstream o;
		o << "phy0_cad_lk0(" << n << ")";
		sc_trace(tf,phy0_cad_lk0[n],o.str().c_str());
		o.str("");
		o << "lk0_cad_phy0(" << n << ")";
		sc_trace(tf,lk0_cad_phy0[n],o.str().c_str());
		o.str("");
		o << "phy1_cad_lk1(" << n << ")";
		sc_trace(tf,phy1_cad_lk1[n],o.str().c_str());
		o.str("");
		o << "lk1_cad_phy1(" << n << ")";
		sc_trace(tf,lk1_cad_phy1[n],o.str().c_str());
	}

	sc_trace(tf,lk0_ctl_phy0,"lk0_ctl_phy0");
	sc_trace(tf,phy0_consume_lk0,"phy0_consume_lk0");
	
	sc_trace(tf,lk0_disable_drivers_phy0,"lk0_disable_drivers_phy0");
	sc_trace(tf,lk0_disable_receivers_phy0,"lk0_disable_receivers_phy0");

	sc_trace(tf,phy1_available_lk1,"phy1_available_lk1");
	sc_trace(tf,phy1_ctl_lk1,"phy1_ctl_lk1");

	sc_trace(tf,lk1_ctl_phy1,"lk1_ctl_phy1");
	sc_trace(tf,phy1_consume_lk1,"phy1_consume_lk1");
	
	sc_trace(tf,lk1_disable_drivers_phy1,"lk1_disable_drivers_phy1");
	sc_trace(tf,lk1_disable_receivers_phy1,"lk1_disable_receivers_phy1");

	
/*	sc_trace(tf,ui_memory_write0,"ui_memory_write0");
	sc_trace(tf,ui_memory_write1,"ui_memory_write1");
	sc_trace(tf,ui_memory_write_address,"ui_memory_write_address");
	sc_trace(tf,ui_memory_write_data,"ui_memory_write_data");

	sc_trace(tf,ui_memory_read_address0,"ui_memory_read_address0");
	sc_trace(tf,ui_memory_read_address1,"ui_memory_read_address1");
	sc_trace(tf,ui_memory_read_data0,"ui_memory_read_data0");
	sc_trace(tf,ui_memory_read_data1,"ui_memory_read_data1");
	*/

#ifdef RETRY_MODE_ENABLED
	/*
	sc_trace(tf,history_memory_write0,"history_memory_write0");
	sc_trace(tf,history_memory_write_address0,"history_memory_write_address0");
	sc_trace(tf,history_memory_write_data0,"history_memory_write_data0");
	sc_trace(tf,history_memory_read_address0,"history_memory_read_address0");
	sc_trace(tf,history_memory_output0,"history_memory_output0");*/
	
/*	sc_trace(tf,history_memory_write1,"history_memory_write1");
	sc_trace(tf,history_memory_write_address1,"history_memory_write_address1");
	sc_trace(tf,history_memory_write_data1,"history_memory_write_data1");
	sc_trace(tf,history_memory_read_address1,"history_memory_read_address1");
	sc_trace(tf,history_memory_output1,"history_memory_output1");
*/
#endif
	
	sc_trace(tf,memory_write0,"memory_write0");
	sc_trace(tf,memory_write_address_vc0,"memory_write_address_vc0");
	sc_trace(tf,memory_write_address_buffer0,"memory_write_address_buffer0");
	sc_trace(tf,memory_write_address_pos0,"memory_write_address_pos0");
	sc_trace(tf,memory_write_data0,"memory_write_data0");
	
	sc_trace(tf,memory_read_address_vc0[0],"memory_read_address_vc0(0)");
	sc_trace(tf,memory_read_address_buffer0[0],"memory_read_address_buffer0(0)");
	sc_trace(tf,memory_read_address_pos0[0],"memory_read_address_pos0(0)");
	sc_trace(tf,memory_output0[0],"memory_output0(0)");
	
	/*
	sc_trace(tf,memory_read_address_vc0[1],"memory_read_address_vc0(1)");
	sc_trace(tf,memory_read_address_buffer0[1],"memory_read_address_buffer0(1)");
	sc_trace(tf,memory_read_address_pos0[1],"memory_read_address_pos0(1)");
	sc_trace(tf,memory_output0[1],"memory_output0(1)");
	
	
	sc_trace(tf,memory_write1,"memory_write1");
	sc_trace(tf,memory_write_address_vc1,"memory_write_address_vc1");
	sc_trace(tf,memory_write_address_buffer1,"memory_write_address_buffer1");
	sc_trace(tf,memory_write_address_pos1,"memory_write_address_pos1");
	sc_trace(tf,memory_write_data1,"memory_write_data1");
	
	sc_trace(tf,memory_read_address_vc1[0],"memory_read_address_vc1(0)");
	sc_trace(tf,memory_read_address_buffer1[0],"memory_read_address_buffer1(0)");
	sc_trace(tf,memory_read_address_pos1[0],"memory_read_address_pos1(0)");
	sc_trace(tf,memory_output1[0],"memory_output1(0)");

	sc_trace(tf,memory_read_address_vc1[1],"memory_read_address_vc1(1)");
	sc_trace(tf,memory_read_address_buffer1[1],"memory_read_address_buffer1(1)");
	sc_trace(tf,memory_read_address_pos1[1],"memory_read_address_pos1(1)");
	sc_trace(tf,memory_output1[1],"memory_output1(1)");

	*/
	sc_trace(tf,ui_packet_usr,"ui_packet_usr");
	sc_trace(tf,ui_vc_usr,"ui_vc_usr");
	sc_trace(tf,ui_side_usr,"ui_side_usr");
	sc_trace(tf,ui_directroute_usr,"ui_directroute_usr");
	sc_trace(tf,ui_eop_usr,"ui_eop_usr");
	sc_trace(tf,ui_available_usr,"ui_available_usr");
	sc_trace(tf,ui_output_64bits_usr,"ui_output_64bits_usr");
	sc_trace(tf,usr_consume_ui,"usr_consume_ui");
	sc_trace(tf,usr_packet_ui,"usr_packet_ui");
	sc_trace(tf,usr_available_ui,"usr_available_ui");
	sc_trace(tf,usr_side_ui,"usr_side_ui");
	sc_trace(tf,ui_freevc0_usr,"ui_freevc0_usr");
	sc_trace(tf,ui_freevc1_usr,"ui_freevc1_usr");
	sc_trace(tf,usr_receivedResponseError_csr,"usr_receivedResponseError_csr");

	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_datalen_db,"DECODER.cd_datalen_db");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_data_db,"DECODER.cd_data_db");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_drop_db,"DECODER.cd_drop_db");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->csr_retry,"DECODER.csr_retry");
#endif
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_getaddr_db,"DECODER.cd_getaddr_db");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_vctype_db,"DECODER.cd_vctype_db");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_write_db,"DECODER.cd_write_db");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_protocol_error_csr,"DECODER.cd_protocol_error_csr");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->lk_available_cd,"DECODER.lk_available_cd");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->lk_dword_cd,"DECODER.lk_dword_cd");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->lk_lctl_cd,"DECODER.lk_lctl_cd");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->lk_hctl_cd,"DECODER.lk_hctl_cd");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_available_ro,"DECODER.cd_available_ro");
	sc_trace(tf,the_ht_tunnel->the_decoder0_l2->cd_packet_ro,"DECODER.cd_packet_ro");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,the_ht_tunnel->the_link0_l2->cd_initiate_retry_disconnect,"LINK.cd_initiate_retry_disconnect");
	sc_trace(tf,the_ht_tunnel->the_link0_l2->lk_initiate_retry_disconnect,"LINK.lk_initiate_retry_disconnect");
#endif
	sc_trace(tf,the_ht_tunnel->the_link0_l2->cd_initiate_nonretry_disconnect_lk,"LINK.cd_initiate_nonretry_disconnect_lk");
	sc_trace(tf,the_ht_tunnel->the_link0_l2->tx_crc_count,"LINK.tx_crc_count");

	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_unit_id,"CSR.csr_unit_id");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_bar[0],"CSR.csr_bar0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_io_space_enable,"CSR.csr_io_space_enable");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_memory_space_enable,"CSR.csr_memory_space_enable");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_request_databuffer0_access_ui,"CSR.csr_request_databuffer0_access_ui");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->ro0_available_csr,"CSR.ro0_available_csr");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_ack_ro0,"CSR.csr_ack_ro0");
#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_retry0,"CSR.csr_retry0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_retry1,"CSR.csr_retry1");
#endif
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_erase_db0,"CSR.csr_erase_db0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_read_db0,"CSR.csr_read_db0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_address_db0,"CSR.csr_address_db0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_vctype_db0,"CSR.csr_vctype_db0");

	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_extented_ctl_lk0,"CSR.csr_extented_ctl_lk0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_available_fc0,"CSR.csr_available_fc0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_dword_fc0,"CSR.csr_dword_fc0");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->fc0_ack_csr,"CSR.fc0_ack_csr");

	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_extented_ctl_lk1,"CSR.csr_extented_ctl_lk1");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_available_fc1,"CSR.csr_available_fc1");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->csr_dword_fc1,"CSR.csr_dword_fc1");
	sc_trace(tf,the_ht_tunnel->the_csr_l2->fc1_ack_csr,"CSR.fc1_ack_csr");


	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ro0_available_ui,"UI.ro0_available_ui");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ro0_packet_ui,"UI.ro0_packet_ui");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_ack_ro0,"UI.ui_ack_ro0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_available_fc0,"UI.ui_available_fc0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->fc0_consume_data_ui,"UI.fc0_consume_data_ui");

	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_read_db0,"UI.ui_read_db0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_erase_db0,"UI.ui_erase_db0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_address_db0,"UI.ui_address_db0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->ui_vctype_db0,"UI.ui_vctype_db0");
	sc_trace(tf,the_ht_tunnel->the_userinterface_l2->db0_data_ui,"UI.db0_data_ui");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->history_playback_done,"HISTORY.history_playback_done");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->begin_history_playback,"HISTORY.begin_history_playback");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->stop_history_playback,"HISTORY.stop_history_playback");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->history_playback_ready,"HISTORY.history_playback_ready");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->consume_history,"HISTORY.consume_history");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->room_available_in_history,"HISTORY.room_available_in_history");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->add_to_history,"HISTORY.add_to_history");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->new_history_entry,"HISTORY.new_history_entry");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->new_history_entry_size_m1,"HISTORY.new_history_entry_size_m1");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->fc_dword_lk,"HISTORY.fc_dword_lk");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->nop_received,"HISTORY.nop_received");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_history_buffer->ack_value,"HISTORY.ack_value");
#endif

	sc_trace(tf,the_ht_tunnel->the_errorhandler0_l2->ro_available_fwd,"ERROR.ro_available_fwd");
	sc_trace(tf,the_ht_tunnel->the_errorhandler0_l2->ro_packet_fwd,"ERROR.ro_packet_fwd");
	sc_trace(tf,the_ht_tunnel->the_errorhandler0_l2->eh_ack_ro,"ERROR.eh_ack_ro");
	sc_trace(tf,the_ht_tunnel->the_errorhandler0_l2->eh_available_fc,"ERROR.eh_available_fc");

	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_user_fifo->fifo_user_available,
		"FIFO.fifo_user_available");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_user_fifo->ui_available_fc,
		"FIFO.ui_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_user_fifo->consume_user_fifo,
		"FIFO.consume_user_fifo");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_user_fifo->buffer_count_posted,
		"FIFO.buffer_count_posted");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->the_user_fifo->buffer_count_nposted,
		"FIFO.buffer_count_nposted");

	sc_trace(tf,the_ht_tunnel->the_reordering0_l2->ro_available_fwd,"REORDERING.ro_available_fwd");
	sc_trace(tf,the_ht_tunnel->the_reordering0_l2->ro_packet_fwd,"REORDERING.ro_packet_fwd");


	/*sc_trace(tf,the_ht_tunnel->the_flow_control1_l2->eh_available_fc,"FLOW1.eh_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control1_l2->ui_available_fc,"FLOW1.ui_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control1_l2->csr_available_fc,"FLOW1.csr_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control1_l2->ro_available_fwd,"FLOW1.ro_available_fwd");
	sc_trace(tf,the_ht_tunnel->the_flow_control1_l2->fc_dword_lk,"FLOW1.fc_dword_lk");*/
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->lk_consume_fc,"FLOW0.lk_consume_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fc_dword_lk,"FLOW0.fc_dword_lk");

	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->ro_available_fwd,"FLOW0.ro_available_fwd");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->ro_packet_fwd,"FLOW0.ro_packet_fwd");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fwd_ack_ro,"FLOW0.fwd_ack_ro");

	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->eh_available_fc,"FLOW0.eh_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fc_ack_eh,"FLOW0.fc_ack_eh");

	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->csr_available_fc,"FLOW0.csr_available_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fc_ack_csr,"FLOW0.fc_ack_csr");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->csr_dword_fc,"FLOW0.csr_dword_fc");

	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fc_nop_sent,"FLOW0.fc_nop_sent");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->db_nop_req_fc,"FLOW0.db_nop_req_fc");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->ro_nop_req_fc,"FLOW0.ro_nop_req_fc");

#ifdef RETRY_MODE_ENABLED
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->fc_disconnect_lk,"FLOW0.fc_disconnect_lk");
	sc_trace(tf,the_ht_tunnel->the_flow_control0_l2->lk_rx_connected,"FLOW0.lk_rx_connected");
#endif

	//------------------------------------------
	// start the simulation
	//------------------------------------------
	
	cout << "Starting simulation" << endl;

	int sim_time = 1200;

	sc_start(sim_time);

	printf("End of simulation\n");
	sc_close_vcd_trace_file(tf);

	delete the_ht_tunnel;
	return 0;
}

#endif
