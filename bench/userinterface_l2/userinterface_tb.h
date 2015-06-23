//UserInterfaceTest.h
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

#ifndef USERINTERFACE_TB_H
#define USERINTERFACE_TB_H

#include <deque>
#include <iostream>

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

#include "../core/ht_datatypes.h"


///Module to test the user interface
/**
	@class userinterface_tb
	@author Ami Castonguay
*/
class userinterface_tb : public sc_module {

	public :

	/** Static compile time constant to know if we should output debug info*/
	enum { outputRdMessages = true};
	/** Static compile time constant to know if we should output debug info*/
	enum { outputTxMessages = true};
	/** Static compile time constant to know if we should output debug info*/
	enum { outputSide0 = true};
	/** Static compile time constant to know if we should output debug info*/
	enum { outputSide1 = true};

	//************************************
	//Internal signals to keep internal 
	//integrity of the testing system to
	//test the interface
	//************************************

	//****** Section for user that sends packets

	///Keep track of all the VC's that are free in the send scheduler side 0
	sc_bv<6> freeVirtualChannel0;
	///Keep track of all the VC's that are free in the send scheduler side 1
	sc_bv<6> freeVirtualChannel1;

	///Queue of packet to send to the chain (simulated the user)
	std::deque<PacketContainer> userPacketQueue;

	//****** Section for the user that receives packets

	///The returned data is a simple count
	int rxDataValue;
	/**The maximum address where the data can be : ex, if the address width
	is 3, then maxDataAddresse will be 8 after initialization*/
	int maxDataAddress;

	/** To assert that the interface
	is reading the right side*/
	bool sideFromWhereSendData;
	/** To assert that the interface
	is reading the right vc*/
	VirtualChannel channelToAccess;
	/** To assert that the interface
	is reading the right address*/
	int dataAddress;
	/** To assert that the interface
	is reading the right amount of data*/
	int  dataLeftToSend;

	/**An internal buffer of the packet to send to the user from side 0*/
	ControlPacketComplete packetSendBuffer0;
	/**An internal buffer of the packet to send to the user from side 0*/
	ControlPacketComplete packetSendBuffer1;

	/** Data to send is simply initially placed
	in a queue
	
	Index 0 is for side 0
	Index 1 is for side 1
	*/
	std::deque<ControlPacketComplete> sendPackets[2];
	

	//*******************************
	//	General signals
	//*******************************

	/**Clock to synchronize module*/
	sc_in< bool >			clk;

	/**Reset to initialize module*/
	sc_in< bool	>		resetx;


	//*******************************
	//	Signals from CSR
	//*******************************

	/**If packet addresed to the DirectConnect address range should go
	in the direction opposite to the default direction*/
	sc_out< bool >			csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
	/**The lower limits of the DirectConnect address ranges*/
	sc_out<sc_bv<32>	>	csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	/**The higher limits of the DirectConnect address ranges*/
	sc_out<sc_bv<32>	>	csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];

	sc_out<sc_bv<32> >		csr_direct_route_enable;

	/**The direction (side) packets should take under normal conditions*/
	sc_out< bool >			csr_default_dir;
	/** Which direction is the master (or only) host of the system*/
	sc_out< bool >			csr_masterhost;
	/**Must be activated for this node to be able to issue requests*/
	sc_out< bool >			csr_bus_master_enable;
	/**Side 0 is the end of chain*/
	sc_out<bool>			csr_end_of_chain0;
	/**Side 1 is the end of chain*/
	sc_out<bool>			csr_end_of_chain1;

	//******************************
	//Signals from link 0
	//******************************

	//----------------------------
	// Signal from data buffers 0
	//----------------------------

	/**The address of the buffer where to fetch the data*/
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db0;

	/**If the data from the buffers was read and
	can be deleted*/
	sc_in<bool>				ui_consume_db0;

	/**In which virt channel to go fetch the data.  This
	could be seen as part of the adresse to the data*/
	sc_in<VirtualChannel>		 ui_vctype_db0;

	/**The actual data coming from the data buffers*/
	sc_out< sc_bv<32> >			db0_data_ui;

	/**End of data transmission fro data buffer*/
	sc_in< bool >				ui_erase_db0;

	//----------------------------
	//Signals from ctl buffers 0
	//----------------------------

	/**The control packet from the link with the
	user as a destination*/
	sc_out<syn_ControlPacketComplete>	ro0_packet_ui;

	/**Allows to know when there is a valid packet*/
	sc_out<bool> 				ro0_available_ui;

	/**To consume the packet from the buffers so that
	the register can be freed*/
	sc_in< bool >				ui_consume_ro0;


	//--------------------------
	//Signals to send scheduler
	//--------------------------


	/**To send a control packet to the link*/
	sc_in<sc_bv<64> >		ui_packet_fc0;

	/**The control packet to send scheduler is valid*/
	sc_in<bool>				ui_available_fc0;

	/**	Which what type of ctl packets can be sent*/
	sc_out<sc_bv<3> >			fc0_user_fifo_ge2_ui;


	/**Link to send data packets*/
	sc_in<sc_bv<32> >			ui_data_fc0;

	/**Signal to know from which VC data was read*/
	sc_out<VirtualChannel> 		fc0_datavc_ui;

	/**To say the the data has been read*/
	sc_out< bool >				fc0_consume_data_ui;

	//******************************
	//Signals from link 1
	//******************************

	//----------------------------
	// Signal from data buffers 1
	//----------------------------

	/**The address of the buffer where to fetch the data*/
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db1;

	/**If the data from the buffers was read and
	can be deleted*/
	sc_in<bool>				ui_consume_db1;

	/**In which virt channel to go fetch the data.  This
	could be seen as part of the adresse to the data*/
	sc_in<VirtualChannel>		 ui_vctype_db1;

	/**The actual data coming from the data buffers*/
	sc_out< sc_bv<32> >			db1_data_ui;

	/**End of data transmission fro data buffer*/
	sc_in< bool >				ui_erase_db1;

	//----------------------------
	//Signals from ctl buffers 1
	//----------------------------

	/**The control packet from the link with the
	user as a destination*/
	sc_out<syn_ControlPacketComplete>	ro1_packet_ui;

	/**Allows to know when there is a valid packet*/
	sc_out<bool> 				ro1_available_ui;

	/**To consume the packet from the buffers so that
	the register can be freed*/
	sc_in< bool >				ui_consume_ro1;


	//--------------------------
	//Signals to send scheduler
	//--------------------------

	/**To send a control packet to the link*/
	sc_in<sc_bv<64> >		ui_packet_fc1;

	/**The control packet to send scheduler is valid*/
	sc_in<bool>				ui_available_fc1;

	/**	Which what type of ctl packets can be sent*/
	sc_out<sc_bv<3> >			fc1_user_fifo_ge2_ui;


	/**Link to send data packets*/
	sc_in<sc_bv<32> >			ui_data_fc1;

	/**Signal to know from which VC data was read*/
	sc_out<VirtualChannel> 		fc1_datavc_ui;

	/**To say the the data has been read*/
	sc_out< bool >				fc1_consume_data_ui;


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
	sc_in<bool>				ui_directroute_usr;

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

	/**A posted packet with DataError bit set is being sent*/
	sc_in<bool> ui_sendingPostedDataError_csr;
	/**A response packet with TargetAbort bit set is being sent*/
	sc_in<bool> ui_sendingTargetAbort_csr;

	/**A response packet with DataError bit was received*/
	sc_in<bool> ui_receivedResponseDataError_csr;
	/**A posted packet with DataError bit was received*/
	sc_in<bool> ui_receivedPostedDataError_csr;
	/**A packet with TargetAbort bit was received*/
	sc_in<bool> ui_receivedTargetAbort_csr;
	/**A packet with MasterAbort bit was received*/
	sc_in<bool> ui_receivedMasterAbort_csr;

	/**CSR is requesting to have access to the databuffer on side 0
		The access to the databuffer is shared between the UI and the CSR*/
	sc_out<bool> csr_request_databuffer0_access_ui;
	/**CSR is requesting to have access to the databuffer on side 1
		The access to the databuffer is shared between the UI and the CSR*/
	sc_out<bool> csr_request_databuffer1_access_ui;
	/**We grant the CSR access to the requested databuffer*/
	sc_in<bool> ui_databuffer_access_granted_csr;
	/**Let the databuffer know that it is the CSR accessing it*/
	sc_in<bool> ui_grant_csr_access_db0;
	/**Let the databuffer know that it is the CSR accessing it*/
	sc_in<bool> ui_grant_csr_access_db1;

	/////////////////////////////////////
	// Interface to memory - synchronous
	/////////////////////////////////////

	sc_in<bool> ui_memory_write0;///< To write to UI data packet memory 0
	sc_in<bool> ui_memory_write1;///< To write to UI data packet memory 1
	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;///< Write address for UI data packet memories
	sc_in<sc_bv<32> > ui_memory_write_data;///< Write data for UI data packet memories

	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;///< Read address for UI data packet memory 0
	sc_in<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;///< Read address for UI data packet memory 1
	sc_out<sc_bv<32> > ui_memory_read_data0;///< Read data for UI data packet memory 0
	sc_out<sc_bv<32> > ui_memory_read_data1;///< Read data for UI data packet memory 1



	/**
		Thread to stimulate the UserInterface packet reception interface.
		It generates packets like the reordering module would
    */
	void testRxInterface();

	/**
		Thread to stimulate the UserInterface packet sending interface.
		It generates packet to send to the chain as the user would
    */
	void testTxUserWrInterface();

	/**
		Thread to stimulate the UserInterface interface to come read
		the internal buffers.  This function simulates the flow control
		that comes read the data in order to send it,
    */
	void testTxSendSchedulerRdInterface();

	/**
		Takes care of all the initial members initialization
	*/
	void generalInitialisation();

	/**
		When the UserInterface receives packets from the reordering modules that has data
		associated to it, it must go retrieve the data from the data buffers.  This simulates
		the data buffers and test that the access is correct.
	*/
	void testRxInterfaceSensitive();

	/**
		Allows to add random packets to a queue of ControlPacketComplete.  This only generates
		packets which are valid inside the HyperTransport module : it does not generate any
		InfoPacket.
		
		@param queue The Queue to add the packets to
		@param number The number of packets to add
		@param seed If we have to seed to random generator.  If left at -1, the random
			generator will not be seeded.
	*/
	void addPacketsToQueue(std::deque<ControlPacketComplete> &queue,int number, int seed = -1);

	/**
		Allows to add random packets to a queue of PacketContainer.  This only generates
		packets which are valid inside the HyperTransport module : it does not generate any
		InfoPacket.
		
		@param queue The Queue to add the packets to
		@param number The number of packets to add
		@param seed If we have to seed to random generator.  If left at -1, the random
			generator will not be seeded.
	*/
	void addPacketsToQueue(std::deque<PacketContainer> &queue,int number, int seed = -1);


	/**
		Generates a random packet.  It takes as a parameter the last packet generated
		with the length of chain left to be able to continue a chain if one was started

		@param lastPacketToUpdateWithNew As a parameter, this is the last packet that
		was generated.  It will be updated with the new packet.
		@param chainLengthLeft How many packets are left to the chain.  0 represents
		that this is not a chain
	*/
	void getRandomPacket(PacketContainer &lastPacketToUpdateWithNew,int &chainLengthLeft);

	///To display every clk cycle with it's number
	int clockCycleNumber;

	/** Memories to buffer data sent from the user.  They are pointers because we only
		know the logarithm2 of the size of the memory (the number of address bits), so
		the actual size must be calculated before allocating the memory.
	*/
	//@{
	int*	memory0;
	int*	memory1;
	//#}

	/**
		Displays the clk number in stdout at every negative edge
		of the clk.  It makes it easier to see what is going on when
		there is a lot of console output for debug
	*/
	void clockOutputSeparator(){
		std::cout << endl
			<< "===================================" << endl
			<< "Clock cycle number : " << clockCycleNumber++ << endl
			<< "===================================" << endl;
		//system("PAUSE");
		cout << endl;
	}
	
	///Handle writing and readin in the memory
	void manage_memories();

	/**Macro to allow the classe to be used as a SystemC module*/
	SC_HAS_PROCESS(userinterface_tb);

	/**Test module constructor*/
	userinterface_tb(sc_module_name name);

	///Desctructor
	virtual ~userinterface_tb();
};

#endif
