//main.cpp for vc_ht_tunnel_l1

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

#include "../core_synth/synth_datatypes.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <ctime>

#include "vc_ht_tunnel_l1.h"

using namespace std;

// Main Function
/**
  This main file has not purpose other than to test if the design compiles
  and runs properly.
*/
int sc_main( int argc, char* argv[] )
{

    sc_clock clk("CLOCK",5,SC_NS);
	
	//------------------------------------------
	// Instanciation de FLOW CONTROL
	//------------------------------------------
	vc_ht_tunnel_l1* the_ht_tunnel = new vc_ht_tunnel_l1("the_ht_tunnel");
	
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
	

	//------------------------------------------
	// start the simulation
	//------------------------------------------
	
	cout << "Starting simulation" << endl;

	sc_start(10);

	printf("end of simulation");
	
	delete the_ht_tunnel;
	return 0;
}

