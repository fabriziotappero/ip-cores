//UserInterface.h

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

#ifndef USERINTERFACE_L2_H
#define USERINTERFACE_L2_H


#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"


/**
	States to manage receiving packets from the chain
*/
enum InterfaceRxState {
	rx_idle_pref0_st,	/**<Waiting to receive a control packet, preference given to side 0 */
	rx_idle_pref1_st,	/**<Waiting to receive a control packet, preference given to side 1 */
	rx_idle_chain0_st,	/**<Waiting to receive a control packet, only from side 0 (because of a chain) */
	rx_idle_chain1_st,	/**<Waiting to receive a control packet, only from side 1 (because of a chain) */
	data0_st,			/**<Fetching data from side 0, will go to rx_idle_pref1_st once done */
	data1_st,			/**<Fetching data from side 1, will go to rx_idle_pref0_st once done */
	data0_chain_st,		/**<Fetching data from side 0, will go to rx_idle_chain0_st once done */
	data1_chain_st		/**<Fetching data from side 0, will go to rx_idle_chain1_st once done */
};



/**
	States to manage then user sending packets to the chain
*/
enum InterfaceTxWriteState {
	tx_wridle_st,tx_wrposted0_st,tx_wrnposted0_st,tx_wrresponse0_st,
		tx_wrposted1_st,tx_wrnposted1_st,tx_wrresponse1_st
};


/**
	States to manage the send scheduler accessing our data buffer when
	sending data packets that came from the user.
*/
enum InterfaceTxReadState {
	tx_rdidle_st,tx_rdposted_st,tx_rdnposted_st,tx_rdresponse_st
};


#ifdef SYSTEMC_SIM
/**
	To display the value of the different possible states to the
	output stream
*/
//@{
ostream& operator<<(ostream& out, const InterfaceRxState & o);
ostream& operator<<(ostream& out, const InterfaceTxWriteState & o);
ostream& operator<<(ostream& out, const InterfaceTxReadState & o);
//@}
#endif

/**Temporary buffer size of the UserInterface3.  There is
space for one full data packet(16 dwords) for every VC(3),
for a total of 48 dwords of memory.
*/
//@{
#define DATA_POSTED_BUFFER_START 0
#define DATA_NPOSTED_BUFFER_START USER_MEMORY_SIZE_PER_VC
#define DATA_RESPONSE_BUFFER_START 2 * USER_MEMORY_SIZE_PER_VC
//@}

///Interface to communicate with the Hypertransport module 
/**
	This module represents the interface from the two links
	to the user.  It allows the user to receive and send data
	on the HyperTransport chain in a way that is somewhat transparent
	to which side the Host actually resides

	@author Ami Castonguay

	Interface to send scheduler
	---------------------------

	The send scheduler has a buffer for control packets
	that is 6 register deep.  It can contain two packet
	of each Virtual Channel (VC), one that has no data
	associated to it and on with data associated.
	3VC * 2 = 6.
  
	Contrary to the control packets, the data packets
	are buffered in the user interface and the user interface
	comes fetch the data when it needs it.


	Interface to user
	-----------------

	When a control packet is available, ui_available_usr
	is at '1'.	ui_output_64bits_usr is on if it is a 64 bit
	packet.  If usr_consume_ui is at '1', it means that the
	user has read the packet.
	
	Control and data packets are concatenated together.  The
	last bit time of the concatenated packets is when
	ui_eop_usr is on.	If there is no data packet, ui_eop_usr is '1'
	at the same time as ui_available_usr.
		  
	While receiving, the user can pause reception of a data packet
	by deasserting usr_consume_ui.  This is only allowed when
	reading a packet, when sending a packet, all data must be
	sent in one burst to avoid then need to buffer the entire
	data packet before sending it, to reduce latency.
			
*/
class userinterface_l2 : public sc_module {

	public :
	//*******************************
	// Internal signals
	//*******************************

	//-------------------------------
	//   rx signals
	//-------------------------------

	///Next value of ::rx_current_state
	sc_signal<InterfaceRxState> rx_next_state;
	///Register that maintains the reception of packet (from tunnel to UI)
	sc_signal<InterfaceRxState> rx_current_state;

	///Register that stores last value of ::ui_vctype_db0
	sc_signal<VirtualChannel> ui_vctype_db0_reg;
	///Register that stores last value of ::ui_vctype_db1
	sc_signal<VirtualChannel> ui_vctype_db1_reg;
	///Register that stores last value of ::ui_address_db0_reg
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > ui_address_db0_reg;
	///Register that stores last value of ::ui_address_db1_reg
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > ui_address_db1_reg;



	//-------------------------------
	//   tx signals
	//-------------------------------

	///Next value of ::tx_next_wrstate
	sc_signal<InterfaceTxWriteState> tx_next_wrstate;
	///Register that maintains the transmission of packet (from  UI to tunnel)
	sc_signal<InterfaceTxWriteState> tx_wrstate;


	///////////////////////////////////////
	// DATA FIFO REGISTERS
	///////////////////////////////////////
	///Register the position to write in the user data packet buffers for side 0
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > tx_wr0pointer[3];
	///Register the position to write in the user data packet buffers for side 1
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > tx_wr1pointer[3];

	///Register the number of space taken in the buffers side 0
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC+1> > tx_count0[3];
	///Register the number of space taken in the buffers side 1
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC+1> > tx_count1[3];

	///Next value of ::tx_rd0pointer
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > next_tx_rd0pointer[3];
	///Register the position to read in the user data packet buffers for side 0
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > tx_rd0pointer[3];
	///Next value of ::tx_rd1pointer
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > next_tx_rd1pointer[3];
	///Register the position to read in the user data packet buffers for side 1
	sc_signal<sc_uint<USER_MEMORY_ADDRESS_WIDTH_PER_VC> > tx_rd1pointer[3];

	///If the write pointers for ui data packets buffers side 0 should be increased
	sc_signal<bool> tx_increase_wrpointer_side;
	sc_signal<VirtualChannel> tx_increase_wrpointer_vc;
	sc_signal<bool> tx_increase_wrpointer;

	///Next value of ::tx_wrcount_left
	sc_signal<sc_uint<4> > next_tx_wrcount_left;
	///The number of writes that are left to do int the ui data packet buffers
	sc_signal<sc_uint<4> > tx_wrcount_left;
	
	///Next value of ::rx_rdcount_left
	sc_signal<sc_uint<4> > next_rx_rdcount_left;
	///The number of reads left to do to the databuffer before erasing the packet
	sc_signal<sc_uint<4> > rx_rdcount_left;

	//Internal signal to know if the packet the user wants to write is valid
	sc_signal< bool >		tx_valid_wr;

	//The side for where the packet previous packet went
	sc_signal< bool >		tx_previous_side_wr;


	//*******************************
	//	General signals
	//*******************************

	/**Clock to synchronize module*/
	sc_in< bool >			clk;

	/**Reset to initialize module*/
	sc_in< bool	>			resetx;


	//*******************************
	//	Signals from CSR
	//*******************************

#ifdef ENABLE_DIRECTROUTE
	/**If packet addresed to the DirectConnect address range should go
	in the direction opposite to the default direction*/
	sc_in< bool >			csr_direct_route_oppposite_dir[DirectRoute_NumberDirectRouteSpaces];
	/**The lower limits of the DirectConnect address ranges*/
	sc_in<sc_bv<32>	>		csr_direct_route_base[DirectRoute_NumberDirectRouteSpaces];
	/**The higher limits of the DirectConnect address ranges*/
	sc_in<sc_bv<32>	>		csr_direct_route_limit[DirectRoute_NumberDirectRouteSpaces];
	/** Indicates which unitID enables DirectRoute*/
	sc_in<sc_bv<32> >		csr_direct_route_enable;
#endif

	/**The direction (side) packets should take under normal conditions (true goes to master host)*/
	sc_in< bool >			csr_default_dir;
	/** Which direction is the master (or only) host of the system*/
	sc_in< bool >			csr_master_host;
	/**Side 0 is the end of chain*/
	sc_in< bool >			csr_end_of_chain0;
	/**Side 1 is the end of chain*/
	sc_in< bool >			csr_end_of_chain1;
	/**Must be activated for this node to be able to issue requests*/
	sc_in<bool>				csr_bus_master_enable;

	//******************************
	//Signals from link 0
	//******************************

	//----------------------------
	// Signal from data buffers 0
	//----------------------------

	/**The address of the buffer where to fetch the data*/
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db0;

	/**If the data from the buffers was read and
	can be deleted*/
	sc_out<bool>				ui_read_db0;

	/**In which virt channel to go fetch the data.  This
	could be seen as part of the adresse to the data*/
	sc_out<VirtualChannel>		 ui_vctype_db0;

	/**The actual data coming from the data buffers*/
	sc_in< sc_bv<32> >			db0_data_ui;

	/**End of data transmission fro data buffer*/
	sc_out< bool >				ui_erase_db0;

	//----------------------------
	//Signals from ctl buffers 0
	//----------------------------

	/**The control packet from the link with the
	user as a destination*/
	sc_in<syn_ControlPacketComplete>	ro0_packet_ui;

	/**Allows to know when there is a valid packet*/
	sc_in<bool> 				ro0_available_ui;

	/**To consume the packet from the buffers so that
	the register can be freed*/
	sc_out< bool >				ui_ack_ro0;


	//--------------------------
	//Signals to send scheduler
	//--------------------------


	/**To send a control packet to the link*/
	sc_out<sc_bv<64> >		ui_packet_fc0;

	/**The control packet to send scheduler is valid*/
	sc_out<bool>				ui_available_fc0;

	/**	Which what type of ctl packets can be sent*/
	sc_in<sc_bv<3> >			fc0_user_fifo_ge2_ui;


	/**Link to send data packets*/
	sc_out<sc_bv<32> >			ui_data_fc0;

	/**Signal to know from which VC data was read*/
	sc_in<VirtualChannel> 		fc0_data_vc_ui;

	/**To say the the data has been read*/
	sc_in< bool >				fc0_consume_data_ui;

	//******************************
	//Signals from link 1
	//******************************

	//----------------------------
	// Signal from data buffers 1
	//----------------------------

	/**The address of the buffer where to fetch the data*/
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >	ui_address_db1;

	/**If the data from the buffers was read and
	can be deleted*/
	sc_out<bool>				ui_read_db1;

	/**In which virt channel to go fetch the data.  This
	could be seen as part of the adresse to the data*/
	sc_out<VirtualChannel>		 ui_vctype_db1;

	/**The actual data coming from the data buffers*/
	sc_in< sc_bv<32> >			db1_data_ui;

	/**End of data transmission fro data buffer*/
	sc_out< bool >				ui_erase_db1;

	//----------------------------
	//Signals from ctl buffers 1
	//----------------------------

	/**The control packet from the link with the
	user as a destination*/
	sc_in<syn_ControlPacketComplete>	ro1_packet_ui;

	/**Allows to know when there is a valid packet*/
	sc_in<bool> 				ro1_available_ui;

	/**To consume the packet from the buffers so that
	the register can be freed*/
	sc_out< bool >				ui_ack_ro1;


	//--------------------------
	//Signals to send scheduler
	//--------------------------

	/**To send a control packet to the link*/
	sc_out<sc_bv<64> >		ui_packet_fc1;

	/**The control packet to send scheduler is valid*/
	sc_out<bool>				ui_available_fc1;

	/**	Which what type of ctl packets can be sent*/
	sc_in<sc_bv<3> >			fc1_user_fifo_ge2_ui;


	/**Link to send data packets*/
	sc_out<sc_bv<32> >			ui_data_fc1;

	/**Signal to know from which VC data was read*/
	sc_in<VirtualChannel> 		fc1_data_vc_ui;

	/**To say the the data has been read*/
	sc_in< bool >				fc1_consume_data_ui;


	//******************************************
	//			Signals to User
	//******************************************

	//------------------------------------------
	// Signals to send received packets to User
	//------------------------------------------


	/**The actual control/data packet to the user*/
	sc_out<sc_bv<64> >		ui_packet_usr;
	/**Registered value of ::ui_packet_usr*/
	sc_signal<sc_bv<64> >	ui_packet_usr_buf;

	/**The virtual channel of the ctl/data packet*/
	sc_out<VirtualChannel>		ui_vc_usr;
	/**Registered value of ::ui_vc_usr*/
	sc_signal<VirtualChannel>	ui_vc_usr_buf;

#ifdef ENABLE_DIRECTROUTE
	/**If the packet is a direct_route packet - only valid for
	   requests (posted and non-posted) */
	sc_out<bool>			ui_directroute_usr;
	/**Registered value of ::ui_directroute_usr*/
	sc_signal<bool>			ui_directroute_usr_buf;
#endif

	/**The side from which came the packet*/
	sc_out< bool >			ui_side_usr;
	/**Registered value of ::ui_side_usr*/
	sc_signal< bool >		ui_side_usr_buf;

	/**If this is the last part of the packet*/
	sc_out< bool >			ui_eop_usr;
	/**Registered value of ::ui_eop_usr*/
	sc_signal< bool >		ui_eop_usr_buf;
	
	/**If there is another packet available*/
	sc_out< bool >			ui_available_usr;
	/**Registered value of ::ui_available_usr*/
	sc_signal< bool >		ui_available_usr_buf;

	/**If what is read is 64 bits or 32 bits*/
	sc_out< bool >			ui_output_64bits_usr;
	/**Registered value of ::ui_output_64bits_usr*/
	sc_signal< bool >		ui_output_64bits_usr_buf;

	/**To allow the user to consume the packets*/
	sc_in< bool >			usr_consume_ui;


	//------------------------------------------
	// Signals to allow the User to send packets
	//------------------------------------------

	/**The actual control/data packet from the user*/
	sc_in<sc_bv<64> >		usr_packet_ui;

	/**If there is another packet available*/
	sc_in< bool >			usr_available_ui;

	/**
	The side to send the packet if it is a response
	This bit is ignored if the packet is not a response
	since the side to send a request is determined automatically
	taking in acount DirectRoute functionnality.
	*/
	sc_in< bool >			usr_side_ui;

	/**Which what type of ctl packets can be sent to side0*/
	sc_out<sc_bv<6> >		ui_freevc0_usr;
	/**Which what type of ctl packets can be sent to side0*/
	sc_out<sc_bv<6> >		ui_freevc1_usr;

#ifdef REGISTER_USER_TX_FREEVC
	//If REGISTER_USER_TX_FREEVC is defined, register the free_vc variables
	/**Which what type of ctl packets can be sent to side0*/
	sc_signal<sc_bv<6> >		ui_freevc0_usr_buf;
	/**Which what type of ctl packets can be sent to side0*/
	sc_signal<sc_bv<6> >		ui_freevc1_usr_buf;
#endif

	/////////////////////////////////////////
	//Signals for the CSR to affect registers
	/////////////////////////////////////////
	
	/**A posted packet with DataError bit set is being sent*/
	sc_out<bool> ui_sendingPostedDataError_csr;
	/**A response packet with TargetAbort bit set is being sent*/
	sc_out<bool> ui_sendingTargetAbort_csr;

	/**A response packet with DataError bit was received*/
	sc_out<bool> ui_receivedResponseDataError_csr;
	/**A posted packet with DataError bit was received*/
	sc_out<bool> ui_receivedPostedDataError_csr;
	/**A packet with TargetAbort bit was received*/
	sc_out<bool> ui_receivedTargetAbort_csr;
	/**A packet with MasterAbort bit was received*/
	sc_out<bool> ui_receivedMasterAbort_csr;

	/////////////////////////////
	// Misc IO
	////////////////////////////

	/**CSR is requesting to have access to the databuffer on side 0
		The access to the databuffer is shared between the UI and the CSR*/
	sc_in<bool> csr_request_databuffer0_access_ui;
	/**CSR is requesting to have access to the databuffer on side 1
		The access to the databuffer is shared between the UI and the CSR*/
	sc_in<bool> csr_request_databuffer1_access_ui;
	/**We grant the CSR access to the requested databuffer*/
	sc_out<bool> ui_databuffer_access_granted_csr;
	/**Next value of ::ui_databuffer_access_granted_csr*/
	sc_signal<bool> next_ui_databuffer_access_granted_csr;
	/**Let the databuffer know that it is the CSR accessing it*/
	sc_out<bool> ui_grant_csr_access_db0;
	/**Let the databuffer know that it is the CSR accessing it*/
	sc_out<bool> ui_grant_csr_access_db1;
	/**Next value of ::ui_grant_csr_access_db0*/
	sc_signal<bool> next_ui_grant_csr_access_db0;
	/**Next value of ::ui_grant_csr_access_db1*/
	sc_signal<bool> next_ui_grant_csr_access_db1;


	/** Registered value of the packet being analyzed from UI
		It is normally usr_packet_ui that is registered, but it might
		also be one clock late if the input from the user is registered (option)
	*/
	sc_signal<sc_bv<64> >		registered_usr_packet_ui;
	/**The side we are currently writing to*/
	sc_signal<bool >			tx_side_wr;
	/** Registered value of if a packet is available from UI
		It is normally usr_available_ui that is registered, but it might
		also be one clock late if the input from the user is registered (option)
	*/
	sc_signal<bool >			registered_usr_available_ui;
#ifdef REGISTER_USER_TX_PACKET
	/** Registered input usr_packet_ui to minimize combinatory delay*/
	sc_signal<sc_bv<64> >		registeredx_usr_packet_ui;
	/** Registered input usr_side_ui to minimize combinatory delay*/
	sc_signal<bool >			registeredx_usr_side_ui;
	/** Registered input usr_available_ui to minimize combinatory delay*/
	sc_signal<bool >			registeredx_usr_available_ui;
#endif

	/**If the output to the user is loaded (register contains valid data or command)*/
	sc_signal<bool >			output_loaded;
	/**Next value of ::output_loaded*/
	sc_signal<bool >			next_output_loaded;

	//Methods/processes in the module

	/**
		Not much functionnality here.  Does the work of
		flip-flops.  For more explications of the actual registers,
		go see the functions that modify them.
	*/
	void clocked_process();

	/**
		To handle reception of packets from the chain to the user
	
		This is the sate machine.  "idle" states wait to send
		new control packets to the user.  There are 4 of those
		idle states : prefer0, prefer1, chain0 and chain1.

		Some packets come in chains that must not be broken, that
		is why there is a specific state for that.  When in the state
		chainX, we must wait for a packet for the side X.  If it's not
		in a chain, we can pick from whichever side.  To allow access
		from both sides fairly, it alternates both sides by alternating
		prefer0 and prefer1.  If we are in prefer0 and there is not packet
		from side0 and one from side1, the one from side1 will be sent.

		When data follows a control packet, we go into a data0 or data1
		state until the date has all been reveived.  If the packet is part
		of a chain, it is data0_chain or data1_chain instead so thate we
		know to fall back to the chain_idle state after.

		If we receive a packet with a chain bit on, we automatically fall
		in chain mode.  As soon as we receive a packet with the chain bit
		off, we go back to normal mode.
	*/
	void rx_process();


	/**
		Calculate on which side to send a packet sent by the user
		We start by reading the packet sent by the user and analysing it.

		The signals read for this is usr_packet_ui and the DirectConnect
		attributes.
	*/
	void tx_calculate_wrside();


	/**
		This validates if what the user is trying to send can actually be sent.
		A first condition that is checked is if the buffers to send it are
		available.

		Also, when the user sends a packet, it might not be a valid legal packet type
		To avoid any problems down the road, we first validate if what is
		being sent is correct.

		It will set two things : 
		-tx_valid_wr Internal signal to know if it is valid
		-ui_invalid_usr The external signal going to user to warn him that his control
			packet will not be read
	*/
	//Currently commented because it took too long to calculate...  So there is currently
	//no check that what the user sends is valid.
	//void tx_validate();

	/**
		Process to send to the user which FREE VC's are
		available to the user
	*/
	void send_freevc_user();

	/**
		This is the process that handle when the user sends packets/data
		It will send the control packets received to the buffers of the
		appropriate forward module.  If there is data, it stores it in
		an internal buffer.
	*/
	void tx_wr_process();

	/**
		To handle when the send scheduler from side 0 reads
		data from the buffer
	*/
	void tx_rd0_process();

	/**
		To handle when the send scheduler from side 1 reads
		data from the buffer
	*/
	void tx_rd1_process();

	/**
		@description
		Finds from which side we want to receive a packet

		The module will read the packet from the side chosen by this
		module and will send if to the user.

		If we are in a "chain" state, we will wait until a packet from the side
		of the chain is available.

		@param ro0_packet_ui_data_associated If the packet from side 0 has data associated
		@param ro0_packet_ui_vc Virtual channel of packet from side 0
		@param ro1_packet_ui_data_associated If the packet from side 1 has data associated
		@param ro1_packet_ui_vc Virtual channel of packet from side 1
		@return
		0  - Side 0
		1  - Side 1
		2 -  No side
	**/
	sc_uint<2> findRxSide(
			bool ro0_packet_ui_data_associated,
			VirtualChannel ro0_packet_ui_vc,
			bool ro1_packet_ui_data_associated,
			VirtualChannel ro1_packet_ui_vc);
	
	/**
		The CSR is required to know when packet with errors are received or sent.
		This process simply looks at the packets delivered and sent by the user to
		see if they have errors and if yes, notify the CSR.
	*/
	void analyzePacketErrors();
	
	///Redirects data from memories to the flow control
	void output_read_data();

	///Register inputs from user and other misc registered tasks
	void register_input();

	///SystemC Macro
	SC_HAS_PROCESS(userinterface_l2);

	///Module constructor
	userinterface_l2(sc_module_name name);
	
	/////////////////////////////////////
	// Interface to memory - synchronous
	/////////////////////////////////////

	sc_out<bool> ui_memory_write0;///< To write to UI data packet memory 0
	sc_out<bool> ui_memory_write1;///< To write to UI data packet memory 1
	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_write_address;///< Write address for UI data packet memories
	sc_out<sc_bv<32> > ui_memory_write_data;///< Write data for UI data packet memories

	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address0;///< Read address for UI data packet memory 0
	sc_out<sc_bv<USER_MEMORY_ADDRESS_WIDTH> > ui_memory_read_address1;///< Read address for UI data packet memory 1
	sc_in<sc_bv<32> > ui_memory_read_data0;///< Read data for UI data packet memory 0
	sc_in<sc_bv<32> > ui_memory_read_data1;///< Read data for UI data packet memory 1
};

#endif

