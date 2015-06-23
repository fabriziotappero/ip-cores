//vc_ht_tunnel_l1_tb.cpp

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

#ifndef VC_HT_TUNNEL_L1_TB_H
#define VC_HT_TUNNEL_L1_TB_H

#include "../core/ht_datatypes.h"
#include "LogicalLayer.h"
#include "InterfaceLayer.h"

///Testbench to test the entire tunnel (vc_ht_tunnel_l1)
/**
	@class vc_ht_tunnel_l1_tb
	@author Ami Castonguay
	@description Testbench to test the entire tunnel.  This is not an
		extensive test.  More extensive tests are done on individual
		modules.  This testbench is only to test if the design works
		for common types of traffic and operations.  It is also not
		an assertive testbench, so the output must be examined by hand.

		The testbench uses different layer classes to interact with the
		tunnel in an efficient way (InterfaceLayer, PhysicalLayer,
		LogicalLayer)
*/
class vc_ht_tunnel_l1_tb : public sc_module , public LogicalLayerInterface,
	public InterfaceLayerEventHandler{
public:

	///vc_ht_tunnel_l1 IO to test
	//@{

	/// The Clock, LDTSTOP and reset signals
	sc_in<bool>			clk;
	sc_out<bool>			resetx;
	sc_out<bool>			pwrok;
	sc_out<bool>			ldtstopx;

	//Link0 signals
	//sc_out<bool >		receive_clk0;
	sc_out<bool>						phy0_available_lk0;
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy0_ctl_lk0;
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy0_cad_lk0[CAD_IN_WIDTH];

	//sc_in< bool >	transmit_clk0;
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk0_ctl_phy0;
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk0_cad_phy0[CAD_OUT_WIDTH];
	sc_out<bool>						phy0_consume_lk0;
	
	sc_in<bool> 		lk0_disable_drivers_phy0;
	sc_in<bool> 		lk0_disable_receivers_phy0;

	//Link1 signals
	//sc_out<bool >		receive_clk1;
	sc_out<bool>						phy1_available_lk1;
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy1_ctl_lk1;
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy1_cad_lk1[CAD_IN_WIDTH];

	//sc_in< bool >	transmit_clk0;
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk1_ctl_phy1;
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk1_cad_phy1[CAD_OUT_WIDTH];
	sc_out<bool>						phy1_consume_lk1;
	
	sc_in<bool> 		lk1_disable_drivers_phy1;
	sc_in<bool> 		lk1_disable_receivers_phy1;

	/////////////////////////////////////////////////////
	// Interface to UserInterface memory - synchronous
	/////////////////////////////////////////////////////

	sc_in<bool> ui_memory_write0;
	sc_in<bool> ui_memory_write1;//20
	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;
	sc_in<sc_bv<32> > ui_memory_write_data;

	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;
	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;
	sc_out<sc_bv<32> > ui_memory_read_data0;
	sc_out<sc_bv<32> > ui_memory_read_data1;

#ifdef RETRY_MODE_ENABLED
	//////////////////////////////////////////
	//	Memory interface flowcontrol0- synchronous
	/////////////////////////////////////////
	sc_in<bool> history_memory_write0;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address0;
	sc_in<sc_bv<32> > history_memory_write_data0;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address0;//30
	sc_out<sc_bv<32> > history_memory_output0;
	
	//////////////////////////////////////////
	//	Memory interface flowcontrol1- synchronous
	/////////////////////////////////////////
	sc_in<bool> history_memory_write1;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address1;
	sc_in<sc_bv<32> > history_memory_write_data1;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address1;
	sc_out<sc_bv<32> > history_memory_output1;

#endif
	
	////////////////////////////////////
	// Memory interface databuffer0 - synchronous
	////////////////////////////////////
	
	sc_in<bool> memory_write0;
	sc_in<sc_uint<2> > memory_write_address_vc0;
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer0;
	sc_in<sc_uint<4> > memory_write_address_pos0;//40
	sc_in<sc_bv<32> > memory_write_data0;
	
	sc_in<sc_uint<2> > memory_read_address_vc0[2];
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer0[2];
	sc_in<sc_uint<4> > memory_read_address_pos0[2];//50

	sc_out<sc_bv<32> > memory_output0[2];
	
	//////////////////////////////////////
	// Memory interface databuffer1 - synchronous
	////////////////////////////////////
	
	sc_in<bool> memory_write1;
	sc_in<sc_uint<2> > memory_write_address_vc1;
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> > memory_write_address_buffer1;
	sc_in<sc_uint<4> > memory_write_address_pos1;
	sc_in<sc_bv<32> > memory_write_data1;
	
	sc_in<sc_uint<2> > memory_read_address_vc1[2];
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >memory_read_address_buffer1[2];
	sc_in<sc_uint<4> > memory_read_address_pos1[2];

	sc_out<sc_bv<32> > memory_output1[2];

	
	///////////////////////////////////////
	// Interface to command memory 0
	///////////////////////////////////////
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro0_command_packet_wr_data;
	sc_in<bool > ro0_command_packet_write;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_wr_addr;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro0_command_packet_rd_addr[2];
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro0[2];

	///////////////////////////////////////
	// Interface to command memory 1
	///////////////////////////////////////
	sc_in<sc_bv<CMD_BUFFER_MEM_WIDTH> > ro1_command_packet_wr_data;
	sc_in<bool > ro1_command_packet_write;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_wr_addr;
	sc_in<sc_uint<LOG2_NB_OF_BUFFERS+2> > ro1_command_packet_rd_addr[2];
	sc_out<sc_bv<CMD_BUFFER_MEM_WIDTH> > command_packet_rd_data_ro1[2];

	//******************************************
	//			Signals to User
	//******************************************
	//------------------------------------------
	// Signals to send received packets to User
	//------------------------------------------


	/**The actual control/data packet to the user*/
	sc_in<sc_bv<64> >		ui_packet_usr;

	/**The virtual channel of the ctl/data packet*/
	sc_in<VirtualChannel>	ui_vc_usr;

	/**The side from which came the packet*/
	sc_in< bool >			ui_side_usr;

	/**If the packet is a direct_route packet - only valid for
	   requests (posted and non-posted) */
	sc_in<bool>			ui_directroute_usr;

	/**If this is the last part of the packet*/
	sc_in< bool >			ui_eop_usr;
	
	/**If there is another packet available*/
	sc_in< bool >			ui_available_usr;

	/**If what is read is 64 bits or 32 bits*/
	sc_in< bool >			ui_output_64bits_usr;

	/**To allow the user to consume the packets*/
	sc_out< bool >			usr_consume_ui;


	//------------------------------------------
	// Signals to allow the User to send packets
	//------------------------------------------

	/**The actual control/data packet from the user*/
	sc_out<sc_bv<64> >		usr_packet_ui;

	/**If there is another packet available*/
	sc_out< bool >			usr_available_ui;

	/**
	The side to send the packet if it is a response
	This bit is ignored if the packet is not a response
	since the side to send a request is determined automatically
	taking in acount DirectRoute functionnality.
	*/
	sc_out< bool >			usr_side_ui;


	/**Which what type of ctl packets can be sent to side0*/
	sc_in<sc_bv<6> >		ui_freevc0_usr;
	/**Which what type of ctl packets can be sent to side0*/
	sc_in<sc_bv<6> >		ui_freevc1_usr;


	//------------------------------------------
	// Signals to affect CSR
	//------------------------------------------
	sc_out<bool> usr_receivedResponseError_csr;

	//@}

	/////////////////////////////////////////
	// Methods
	/////////////////////////////////////////

	///Physical layer for the side 0
	PhysicalLayer * physicalLayer0;
	///Logical layer for the side 0
	LogicalLayer * logicalLayer0;
	///Physical layer for the side 1
	PhysicalLayer * physicalLayer1;
	///Logical layer for the side 1
	LogicalLayer * logicalLayer1;
	///Interface layer for the HT user interface
	InterfaceLayer * interfaceLayer;

	///Handles read and write to the design's memories
	void manage_memories();
	///Main testbench control process
	void run();

	sc_signal<bool> resetx_buf;
	sc_signal<bool> pwrok_buf;
	sc_signal<bool> ldtstopx_buf;
	sc_signal<bool>  usr_consume_ui_buf;
	sc_signal<sc_bv<64> > usr_packet_ui_buf;
	sc_signal<bool>  usr_available_ui_buf;
	sc_signal<bool>  usr_side_ui_buf;
	sc_signal<bool>  usr_receivedResponseError_csr_buf;

	sc_signal<bool>  phy0_available_lk0_buf;
	sc_signal<sc_bv<CAD_IN_DEPTH> > phy0_ctl_lk0_buf;
	sc_signal<sc_bv<CAD_IN_DEPTH> > phy0_cad_lk0_buf[CAD_IN_WIDTH];
	sc_signal<bool>  phy0_consume_lk0_buf;

	sc_signal<bool>  phy1_available_lk1_buf;
	sc_signal<sc_bv<CAD_IN_DEPTH> > phy1_ctl_lk1_buf;
	sc_signal<sc_bv<CAD_IN_DEPTH> > phy1_cad_lk1_buf[CAD_IN_WIDTH];
	sc_signal<bool>  phy1_consume_lk1_buf;

	void drive_async_outputs();

	///SystemC macro
	SC_HAS_PROCESS(vc_ht_tunnel_l1_tb);

	///Constructor
	vc_ht_tunnel_l1_tb(sc_module_name name);
	//Destructor
	virtual ~vc_ht_tunnel_l1_tb();

	///Communication to HT Logical Interface, see LogicalLayerInterface
	virtual void receivedHtPacketEvent(const ControlPacket * packet,
		const int * data,const LogicalLayer* origin);
	///Communication to HT Logical Interface, see LogicalLayerInterface
    virtual void crcErrorDetected();

	///Communication to HT Interface Layer, see InterfaceLayerEventHandler
	virtual void receivedInterfacePacketEvent(const ControlPacket * packet,const int * data,
		bool directRoute,bool side,InterfaceLayer* origin);

	///A count of packets received from side 0
	int count_side0;
	///A count of packets received from side 1
	int count_side1;
	///A count of packets received from the interface
	int count_interface;
	///If a packet has been received from the interface
	bool received_side0;

	///User interface memory side 0
	int ui_memory0[USER_MEMORY_SIZE];
	///User interface memory side 1
	int ui_memory1[USER_MEMORY_SIZE];

	///History memory side 0
	int history_memory0[HISTORY_MEMORY_SIZE];
	///History memory side 1
	int history_memory1[HISTORY_MEMORY_SIZE];

	///Databuffer memory side 0
	int databuffer_memory0[3][DATABUFFER_NB_BUFFERS][16];
	///Databuffer memory side 1
	int databuffer_memory1[3][DATABUFFER_NB_BUFFERS][16];


	///Command memory side 0
	sc_bv<CMD_BUFFER_MEM_WIDTH> command_memory0[4*NB_OF_BUFFERS];
	///Command memory side 1
	sc_bv<CMD_BUFFER_MEM_WIDTH> command_memory1[4*NB_OF_BUFFERS];
};

#endif

