//flow_control_l3.h
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
 *   Jean-Francois Belanger
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
#include "../core_synth/constants.h"

#ifndef FLOW_CONTROL_L3_H
#define FLOW_CONTROL_L3_H

  	///State machine possible state list
	enum fc_state { 
		NOP_SENT, ///< Sending a nop
		FWD_CMD32_SENT,/**< Sending the first dword of command packet from the 
					 	  reordering of the other side of the tunnel*/
		FWD_CMD64_FIRST_SENT,///< Sending first dword packet (of a quad word packet) from reordering
		FWD_CMD64_SECOND_SENT,///< Sending second dword packet (of a quad word packet) from reordering
		NOP_SENT_IN_FWD,/**< Sending nop in the middle of transmission of data from
							reordering of the other side of the tunnel*/
		FWD_DATA_SENT, ///< Sending data from reordering of the other side of the tunnel
		CSR_CMD_SENT, ///< Sending a packet from CSR
		EH_CMD_SENT, ///< Sending a packet from the error handler
		USER_CMD32_SENT, ///< Sending a dword packet from user fifo
		USER_CMD64_FIRST_SENT,///< Sending first dword packet (of a quad word packet) from user fifo
		USER_CMD64_SECOND_SENT,///< Sending second dword packet (of a quad word packet) from user fifo
		USER_DATA_SENT, ///< Sending data from the User Interface data buffers
		CSR_DATA_SENT, ///< Sending data from the CSR
		ERROR_DATA_SENT, ///< Sending data from the Error Handler
		NOP_SENT_IN_USER,///< Sending nop in the middle of transmission of data from UI
		NOP_SENT_IN_CSR,///< Sending nop in the middle of transmission of data from CSR
		NOP_SENT_IN_EH,///< Sending nop in the middle of transmission of data from EH
		LDTSTOP_DISCONNECT,///< State where we end up when the link is stopped through LDTSTOP, *not retry mode*
#ifdef RETRY_MODE_ENABLED
		RETRY_SEND_DISCONNECT,///< Send disconnects NOP to initiate the retry sequence
		RETRY_WAIT_FOR_ACK,/**< After a retry disconnect, wait for the next node to send
			the it's RxNextPacketToAck value so that we know were to start the histor
			playback*/ 
		RETRY_CMD32_SENT,///< Sending a dword packet from history buffer
		RETRY_CMD64_FIRST_SENT,///< Sending first dword packet (of a quad word packet) from history buffer
		RETRY_CMD64_SECOND_SENT,///< Sending second dword packet (of a quad word packet) from history buffer
		RETRY_DATA_SENT,///< Sending data payload of a history packet
		RETRY_SEND_DISCONNECT_CRC,///< Sends the CRC associated with the disconnect nop
		RETRY_WAIT_FOR_RX_DISCONNECT,/**< Wait for RX to disconnect before attempting to
			reconnect TX */
		RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT,/**< After a retry disconnect, wait for
			the next node to send the it's RxNextPacketToAck value so that we know were
			to start the history playback.
			
			Retry also requires that we advertise at least the same amount of buffers then 
			we had before the retry sequence, so we also wait until all our free buffers
			have been advertised as free*/ 
		RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT_CRC,/**< When in the state
			RETRY_WAIT_FOR_ACK_AND_BUFFER_COUNT_SENT, we send nop.  Since we are in
			retry mode, we are also required to send the CRC's of the nop */
		RETRY_SEND_CMD_CRC,///< Send CRC of a history packet
		SEND_CMD_CRC,///< Send the CRC of a packet with no data associated
		SEND_NOP_CRC,///<Send the crc of a nop packet
		SEND_DATA_CRC,///< Send the CRC of a packet with data associated 
		NOP_CRC_SENT_IN_FWD,///< Send the CRC of a nop inserted in a FWD data transfer
		NOP_CRC_SENT_IN_USER,///<Send the CRC of a nop inserted in a UI data transfer
		NOP_CRC_SENT_IN_CSR,///< Send the CRC of a nop inserted in a CSR data transfer
		NOP_CRC_SENT_IN_EH,///< Send the CRC of a nop inserted in a EH data transfer
		RETRY_NOP_SENT,///< Send a nop while playing back history
		RETRY_NOP_CRC_SENT,///< Sending the CRC of a nop packet while playing back history
		RETRY_NOP_SENT_IN_DATA,/**< Send a nop while playing back history,
							   in the middle of a data packet*/
		RETRY_NOP_CRC_SENT_IN_DATA/**< Sending the CRC of a nop packet while 
								  playing back history, in the middle of a data packet*/
#endif
		};               
	
	//State values for storing if we are sending a chain
	enum fc_chain_state { NO_CHAIN_STATE,FWD_CHAIN_STATE,USER_CHAIN_STATE};


  	 
/// Finite state machine of the flow control
/**see flow_control_l2.h for explanation of the role of the flow_control*/
class flow_control_l3 : public sc_module
{
	public:
	

	//Signals to internal FIFO
	///If there is a packet that can be sent from the internal user fifo
    sc_in <bool> fifo_user_available ;
	///The packet to be sent from the user fifo
	sc_in <sc_bv<64> > fifo_user_packet;
	///The packet fifo_user_packet is being consumed
	sc_out<bool> consume_user_fifo;
	///Hold the packet so it doesn't change after sending the first dword
	sc_out<bool> hold_user_fifo;

	/**
		These signals are not necessary, but they are registered in the
		user_fifo to accelerate the combinatorial path of this module.
	*/
	//@{
	///Virtual channel of the ::fifo_user_packet
 	sc_in<VirtualChannel> fifo_user_packet_vc;
	///If ::fifo_user_packet is a double word packet (as opposed to a quad word, word = 16 bits)
	sc_in<bool> fifo_user_packet_dword;
	///If ::fifo_user_packet has any data associated
	sc_in<bool> fifo_user_packet_data_asociated;
#ifdef RETRY_MODE_ENABLED
    ///The command of fifo_user_packet
	sc_in<PacketCommand > fifo_user_packet_command;
#endif
    ///Size of ::fifo_user_packet data in dwords minus 1
	sc_in<bool> fifo_user_packet_isChain; 
    ///If ::fifo_user_packet has the chain bit on (also checks if it's a posted packet)
	sc_in<sc_uint<4> > fifo_user_packet_data_count_m1;
    //@}

	//Signals to error handler

	///If the error handler has a packet available to send
    sc_in <bool> eh_available_fc ;
	///Acknowledge that the packet from the error handler has been read
    sc_out <bool> fc_ack_eh;
	///The dword to be sent from the errorhandler
    sc_in <sc_bv<32> > eh_cmd_data_fc;


	//Signals to CSR

	///CSR has a packet to be sent
    sc_in <bool> csr_available_fc;
	///Acknowledge that the packet from the CSR has been read
    sc_out <bool> fc_ack_csr;		
	///The dword to be sent from the CSR
	sc_in <sc_bv<32> > csr_dword_fc;


	//Signals to Reordering

	///Reordering has a packet to be sent
    sc_in <bool> ro_available_fwd;
	///Reordering requests that a nop be sent to notify of free buffers
    sc_in <bool> ro_nop_req_fc;
	///Packt to send from reordering
    sc_in <syn_ControlPacketComplete> ro_packet_fwd;
	sc_in<VirtualChannel> ro_packet_vc_fwd;
	///To consume the data from the reordering_l2 module
	sc_out<bool> fwd_ack_ro;

	//Signals to User Interface

	///To read data from the userinterface buffers
	sc_out <bool> fc_consume_data_ui;
	///The virtual channel of the data to fetch from the user interface buffers
	sc_out<VirtualChannel> 		fc_data_vc_ui;

  

    //Signals from databuffer from other side  

	///Databuffer requests that a nop be sent to notify of free buffers
    sc_in <bool> db_nop_req_fc;
	///The address to read data from the databuffer from the other side
    sc_out <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd_address_db;
	///Read the data from the databuffer of the other side
    sc_out <bool> fwd_read_db;
	///The virtual channel to read data from the databuffer from the other side
    sc_out<VirtualChannel>  fwd_vctype_db;
 	///To erase the data packet
    sc_out <bool> fwd_erase_db;
  
	//Signals from nop_framer

	///The next packet to send should be a nop
    sc_in <bool> nop_next_to_send;
	///nophandler should generate disconnect nops
	sc_out<bool> generate_disconnect_nop;
	///If there are buffer to be notified as free with a nop
	sc_in<bool> has_nop_buffers_to_send;

	//Signals to fairness

	///If the local side has priority
	sc_in<bool> local_priority;
	///If a local packet is issued (can be sent or reserved to send when buffers available)
	sc_out<bool> local_packet_issued;

       
    //Signals to rx_farend_cnt

	///The VC of the packet currenlty being sent and if it has data (one hot encoding)
    sc_out <sc_bv<6> > current_sent_type; 
	///Status of the buffers of every VC's for command and data buffers
	/**Set if it has free buffer (one hot encoding)
		ResponseData	bit 0
		Response		bit 1
		NonPostData		bit 2
		NonPostCmd		bit 3
		PostData		bit 4	
		PostCmd			bit 5
	*/
    sc_in<sc_bv<6> > fwd_next_node_buffer_status_ro;

#ifdef RETRY_MODE_ENABLED
	///Clear the count of buffers for the next HT node to zero
	sc_out <bool>	clear_farend_count;

	//Misc signals

	///Link requests that we start a retry disconnect sequence
	sc_in  <bool> lk_initiate_retry_disconnect;
	///Force the link to disconnect
	/**Disconnect will occur after the current dword is done sending*/
    sc_out <bool> fc_disconnect_lk;
	///Command decoder requests that we start a retry disconnect sequence
	sc_in <bool> cd_initiate_retry_disconnect;
	
#endif
	//Signal to multiplexer

    ///Select which signal to send to link
    sc_out <sc_uint<4> > fc_ctr_mux;

	
	//Signals to link

	///LCTL output signal
    sc_out <bool> fc_lctl_lk;
	///HCTL output signal
    sc_out <bool> fc_hctl_lk;
	///For the link to consume data we send to it
    sc_in  <bool> lk_consume_fc;
#ifdef RETRY_MODE_ENABLED
	///If the RX part of the link is connected
	sc_in  <bool> lk_rx_connected;
#endif


	//Misc signals

	///If a nop is being sent to the link
    sc_out <bool> fc_nop_sent;
	///Reset
    sc_in <bool> resetx;
	///LDTSTOP# - Stop the transfer of data to save power
    sc_in <bool> ldtstopx;
	///Clock
    sc_in_clk clock;
    
	///Configuration register bit to turn the transmitter off
    //sc_in <bool> csr_transmitteroff;
	///A nop was just received - new ack value and new freed buffers value
	sc_in<bool>			nop_received;

#ifdef RETRY_MODE_ENABLED
	///If we are in retry mode
	sc_in<bool>			csr_retry;

  
	//History signals

	///Packet from the output of the history buffers
	sc_in <sc_bv<32> > history_packet;

	///Everything in the history buffers has bee played back
	sc_in <bool > history_playback_done;
	///When the history is ready to begin playback
	sc_in <bool > history_playback_ready;
	///Start to replay the content of the history buffer
	sc_out <bool > begin_history_playback;
	///Interrupt the replay of the content of the history buffer
	sc_out <bool > stop_history_playback;
	///To read the data from the history buffer
	sc_out <bool > consume_history;

	///The amount of dwords left in the history
	sc_in <bool > room_available_in_history;

	///Add a dword to the current history entry
	/**
		You must have created an history entry before entering dwords in it...
	*/
	sc_out <bool > add_to_history;
	///Start a new history entry (packet) of size new_history_entry_size_m1
	sc_out <bool > new_history_entry;
	///Size of the new history entry
	sc_out<sc_uint<5> > new_history_entry_size_m1;


	//Signals to CRC unit

	///Calculate the CRC on the current output to the link
	sc_out<bool>	calculate_crc;
	///Clear the current calculated CRC value
	sc_out<bool>	clear_crc;
	///Calculate the CRC on the current output to the link for nop packets
	sc_out<bool>	calculate_nop_crc;
	///Calculate the CRC on the current output to the link for nop packets
	sc_out<bool>	clear_nop_crc;

	///If we should output the current calculated CRC
	sc_out<bool>	select_crc_output;
	///If we should output the current calculated nop CRC
	sc_out<bool>	select_nop_crc_output;


	///Next value of ::fc_disconnect_lk
    sc_signal <bool> next_fc_disconnect_lk;
	///Next value of ::calculate_nop_crc
	sc_signal<bool>	next_calculate_nop_crc;
	///Next value of ::calculate_crc
	sc_signal<bool>	next_calculate_crc;
	///Next value of ::select_crc_output
	sc_signal<bool> next_select_crc_output;
	///Next value of ::select_nop_crc_output
	sc_signal<bool> next_select_nop_crc_output;
#endif


 	///Saved value of fwd_vctype_db
    sc_signal<VirtualChannel>  buffered_fwd_vctype_db;
 	///Saved value of fwd_address_db
    sc_signal <sc_uint<BUFFERS_ADDRESS_WIDTH> > buffered_fwd_address_db;
	///The next value fc_data_vc_ui will take
	sc_signal<VirtualChannel> 		buffered_fc_data_vc_ui;
	///Registered value of ::lk_rx_connected
	sc_signal<bool> registered_lk_rx_connected;
	///Registered value of ::registered_lk_initiate_retry_disconnect
	sc_signal<bool> registered_lk_initiate_retry_disconnect;

	//Buffer signals to link

	///LCTL output signal
    sc_signal<bool> next_fc_lctl_lk;
	///HCTL output signal
    sc_signal <bool> next_fc_hctl_lk;

	///Next value of next_data_cnt
    sc_signal<sc_uint<4> > next_data_cnt;
	///The number of dwords left to send all the data payload of a packet
    sc_signal<sc_uint<4> > data_cnt;
      	
	///Next value of ::has_data
    sc_signal<bool > next_has_data;
	///If there is still data to be sent for the current packet
    sc_signal<bool > has_data;

	///Next value of chain_current_state
	sc_signal<fc_chain_state> next_chain_current_state;
	///The current state for sending posted packets that have chain bits
	/**	When sending a posted packet that has chain bit set, it means it is
		a chain of packets that cannot be seperated by inserting other posted
		packets, so we remember it by going in a chain state*/
    sc_signal<fc_chain_state> chain_current_state;
    
	///The next value curr_state will take (at rising edge of the clock)
    sc_signal <fc_state> next_state;
	///The current state of the flow_control_l3
    sc_signal <fc_state> curr_state;

#ifdef RETRY_MODE_ENABLED
	///Register to store that a retry disconnect has been initiated
	sc_signal<bool>		retry_disconnect_initiated;
	///To clear the retry_disconnect_initiated signal
	sc_signal<bool>		clear_retry_disconnect_initiated;

	///Register to store if we have received at least one ack (a nop packet) from
	//the other link
	/** It is important to wait for this to be set before replaying the history in
	a retry sequence, to be sure that we start playing back the history at the right
	position*/
	sc_signal<bool>		received_ack;

#endif

	///Register to reserve a local fairness spot for a VC
    sc_signal<bool> fairness_vc_reserved[3];
 	///next value of fairness_vc_reserved
    sc_signal<bool> next_fairness_vc_reserved[3];

	///Signals calculated by ::find_next_state()
	//@{
    sc_signal <fc_state> found_next_state;
	sc_signal<bool> found_load_fwd_pkt;
	sc_signal<bool> found_load_eh_pkt;
	sc_signal<bool> found_load_csr_pkt;
	sc_signal<bool> found_load_user_fifo_pkt;
	sc_signal<bool> found_hold_user_fifo_pkt;
	sc_signal<fc_chain_state> found_next_chain_current_state;
	sc_signal<sc_bv<6> > found_current_sent_type;
	sc_signal<sc_uint<4> > found_fc_ctr_mux;
	sc_signal<bool> found_generate_disconnect_nop;
	sc_signal<bool> found_fc_nop_sent;
	sc_signal<VirtualChannel> found_fwd_vctype_db;
	sc_signal<sc_uint<BUFFERS_ADDRESS_WIDTH> > found_fwd_address_db;
	sc_signal<sc_uint<4> > found_next_data_cnt;
	sc_signal<bool> found_next_has_data;
	sc_signal<VirtualChannel> found_fc_data_vc_ui;
	sc_signal<bool> found_local_packet_issued;
	sc_signal<bool> found_next_fairness_vc_reserved[3];

#ifdef RETRY_MODE_ENABLED
	sc_signal<sc_uint<5> > found_new_history_entry_size_m1;
	sc_signal<bool > found_new_history_entry;
	sc_signal<bool>	found_next_calculate_crc;
	sc_signal<bool>	found_next_calculate_nop_crc;
#endif
	//@}

#ifdef RETRY_MODE_ENABLED

	///Signals calculated by ::find_next_retry_state()
	//@{
	sc_signal<sc_uint<4> > foundh_fc_ctr_mux;
	sc_signal<bool>	foundh_fc_nop_sent;
	sc_signal<fc_state> foundh_next_state;
	sc_signal<bool>	foundh_next_fc_lctl_lk;
	sc_signal<bool>	foundh_next_fc_hctl_lk;
	sc_signal<bool>	foundh_next_calculate_nop_crc;
	sc_signal<bool>	foundh_next_calculate_crc;
	sc_signal<sc_uint<4> > foundh_next_data_cnt;
	sc_signal<bool>	foundh_next_has_data;
	sc_signal<sc_bv<6> > foundh_current_sent_type;
	sc_signal<bool>	foundh_consume_history;
	sc_signal<bool>	foundh_generate_disconnect_nop;
	//@}

#endif


   	///The clocked process for the state machine
   	void fc_fsm_state( void );
	///Finds the next state of the flow_control_l3
	void fc_fsm( void );
	///Verify that that type of packet can be sent to the other link
	/**
		@param vc The virtual channel to verify
		@param data If we are looking at the data buffers.  false for command buffers
		@return If a packet of VirtulChannel vc and that does (data==true) or 
			does not(data==false) can be sent to the next HT node.  The next HT node
			must have enough free buffers to accept the packet
	*/
  	bool verify_buffer_status (VirtualChannel vc , bool data);
	///Find the one hot encoded value of what packet type is being sent
	void set_found_sent_type (VirtualChannel vc , bool data);
	///Find the next state to go in when a new packet has to be sent (combinatory process)
	/** @description
		This part needs a bit of explaining.  The method find_next_state finds
		what is the next thing we need to do when not in a retry sequence and
		also finds the different outputs of the design.  It is called after a
		packet has finished being sent : we are ready so send a new packet.

		This needs to be done at multiple places in the code.  If the function
		is called directly from the state machine, during synthesis, the function
		will be embeded multiple times in the states machines.  Since the method
		is quite big, it really blows up the size of the final verilog or vhdl
		code, making it VERY long to synthesize afterwards.

		To cut back on this time, the method find_next_state is a combinatory process
		which set signals named found_*, then the state machine can calls ::set_next_state()
		to set the outputs to what was found in the next state.  This way, only the
		assignation is placed in the state machine during synthesis.
	*/
	void find_next_state();
	///Set what ::find_next_state() has found
	void set_next_state();


	///Methods to go to specific state while also setting correct outputs
	//@{
	void go_NOP_SENT();
	void go_NOP_SENT_IN_FWD();
	void go_NOP_SENT_IN_USER();
	void go_NOP_SENT_IN_EH();
	void go_NOP_SENT_IN_CSR();
	void go_FWD_DATA_SENT();
	void go_USER_DATA_SENT();
	void go_ERROR_DATA_SENT();
	void go_CSR_DATA_SENT();
	void go_LDTSTOP_DISCONNECT();

#ifdef RETRY_MODE_ENABLED
	void go_RETRY_NOP_SENT();
	void go_SEND_DATA_CRC();
	void go_RETRY_NOP_SENT_IN_DATA();
	void go_SEND_CMD_CRC();
	void go_RETRY_SEND_CMD_CRC_DATA();
	void go_RETRY_SEND_CMD_CRC();
	void go_RETRY_DATA_SENT();
	void go_RETRY_SEND_DISCONNECT();
	void go_NOP_CRC_SENT_IN_FWD();
#endif
	//@}

#ifdef RETRY_MODE_ENABLED
	///Find the next state during retry mode(combinatory process)
	/**
		@description This is the equivalent of the ::find_next_state() , 
		except that it is for when we are in a retry sequence
	*/
	void find_next_retry_state();
	///Set what ::find_next_retry_state() has found
	void go_next_retry_state();
	///Find the one hot encoded value of what packet type is being sent
	void set_foundh_sent_type (VirtualChannel vc , bool data);
#endif

	///SystemC Macro
	SC_HAS_PROCESS(flow_control_l3);

	///Macro CTOR SystemC - flow_control_l3 constructor
	flow_control_l3(sc_module_name name);
};

#endif
