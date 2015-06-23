//flow_control_l2.h
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

#ifndef FLOW_CONTROL_L2_H
#define FLOW_CONTROL_L2_H

#include "../core_synth/synth_datatypes.h"	
#include "../core_synth/constants.h"

//Forward declaration
class flow_control_l3;
class nop_framer_l3;
class multiplexer_l3;
class rx_farend_cnt_l3;
class user_fifo_l3;
class fairness_l3;

#ifdef RETRY_MODE_ENABLED
class history_buffer_l3;
class fc_packet_crc_l3;
#endif

/// Top module of the flow control
/**
	The flow control is the module that frames the packets to be sent out.
	In the HyperTransport tunnel, there are multiple sources of outgoing
	packets.  The flow control decides which packet must be sent.
	
	It keeps track of the buffers available in the next HT node.  It is
	also responsible for sending nop flow control packets when the databuffer
	or reordering requests it.  It will also send nops when there si nothing else
	to send.
	
	The module is also called the forward module, because it is responsible for
	sending packets that arrived from the other side of the tunnel but that
	wasn't for this node.
	
	In retry mode, the flow control keeps a history buffer of all the packets
	sent until they are acked, so they can be replayed if there is a transmission
	error.  It also add the CRC to every packet.
	
	Dwords are sent to the link, when the link is not busy.
	
	When the user interface requests that a packet that has data associated be sent,
	there is an two input buffers for every VC, one for packets with data and one for
	packets without data.  The command packet is sent directly to the flow control,
	so the input buffers for the user are actually located in the flow control so
	that it can decide from which VC it is best to send.  The data payload of the
	packet with data is kept in the user interface, so the flow control must request
	that data when sending a packet with data associated.
*/
class flow_control_l2 : public sc_module
{
	public:
	//***********************************
	// Ports definition
	//***********************************

	/// The Clock
	sc_in<bool> clk;
	/// Reset signal
	sc_in<bool> resetx;
	///LDTSTOP# signal
	sc_in<bool> ldtstopx;
	
    // USER_FIFO
	///The packet the user interface wants to send
    sc_in <sc_bv<64> >			ui_packet_fc;
	///If it there is a packet available to be sent
	sc_in <bool>				ui_available_fc;
	///The VC's that can accept packets currently
	sc_out <sc_bv<3> >			fc_user_fifo_ge2_ui;
	
	///The VC in which the flow control wants to read data from the UI data buffer
	sc_out <VirtualChannel>		fc_data_vc_ui;
	///The data from the UI buffers
	sc_in <sc_bv<32> >			ui_data_fc; 
	///To consume the data from the UI buffers
	sc_out <bool>				fc_consume_data_ui;
     
	// Forward -- FC
    ///If there is a packet to be sent from the reordering from the other side
    sc_in <bool> ro_available_fwd;
	///The packet to sent
    sc_in <syn_ControlPacketComplete > ro_packet_fwd;
	sc_in<VirtualChannel> ro_packet_vc_fwd;
	///To acknoledge that the packet has been consumed
    sc_out <bool> fwd_ack_ro;

   	//LINK
	///The dword to send to the other link
    sc_out <sc_bv<32> > fc_dword_lk;
	///The LCTL control signal to send along with the data
    sc_out <bool> fc_lctl_lk;
	///The HCTL control signal to send along with the data
    sc_out <bool> fc_hctl_lk;
	///The link consumes the data we are sending
    sc_in  <bool> lk_consume_fc;
#ifdef RETRY_MODE_ENABLED
	///Force the link to disconnect
	/**Disconnect will occur after the current dword is done sending*/
    sc_out <bool> fc_disconnect_lk;
	///This signal is active when the RX side of the link is connected
	sc_in  <bool> lk_rx_connected;
	///If the link wants to initiate a retry disconnect
	sc_in  <bool> lk_initiate_retry_disconnect;
	///If we are in the mode retry
	sc_in <bool> csr_retry;
	//Command decoder
	/**Turns on when a disconnect sequence is initiated
	All buffer counts are zeroed and we must replay all packets
	that have not been acked*/
	sc_in <bool>	cd_initiate_retry_disconnect;
#endif
    		
	//DATA BUFFER
	///The address where to read the data
    sc_out <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd_address_db;
	///The VC in which to read the data
    sc_out <VirtualChannel>  fwd_vctype_db;
	///To read (consume) the data at the address specified
    sc_out <bool> fwd_read_db;
	///To erase the data packet
    sc_out <bool> fwd_erase_db;
	///The data received from the data buffer
    sc_in <sc_bv<32> > db_data_fwd;
  
	
    ///Buffer count information from RO and DB for sending nop's
	///The buffers the ro can notify as being free to the HT node we are connected to
	//Bits 1..0 : PC, Bits 3..2 : RC. Bits 5..4 : NPC
    sc_in <sc_bv<6> > ro_buffer_cnt_fc;
	///The buffers the ro can notify as being free to the HT node we are connected to
 	//Bits 1..0 : PC, Bits 3..2 : RC. Bits 5..4 : NPC
    sc_in <sc_bv<6> > db_buffer_cnt_fc;
    
    //Connexion Error handler FLOW control
	///Acknoledge that the dword has been read
	sc_out <bool> fc_ack_eh;
	///The dword to send (command packet or data payload)
	sc_in <sc_bv<32> > eh_cmd_data_fc;
	///If there is a dword to send
	sc_in <bool> eh_available_fc;
    
	//Connexion CSR -- FLOW control
	///Acknoledge that the dword has been read
	sc_out <bool> fc_ack_csr;	
	///If there is a dword to send
	sc_in <bool> csr_available_fc;
	///The dword to send (command packet or data payload)
	sc_in <sc_bv<32> > csr_dword_fc;
	
	///If we are to turn the transmitter off
	///Now ignored since reset is necessary to reactivate link.  transmitter off is taken care
	//of in the link only
	//sc_in <bool> csr_transmitteroff;
	
#ifdef RETRY_MODE_ENABLED
	///This bit forces a single stomp to be sent
	sc_in<bool>			csr_force_single_stomp_fc;
	///This bit forces a single CRC error to be sent
	sc_in<bool>			csr_force_single_error_fc;
	///Once a CRC error is sent, we clear the signal to send the error
	sc_out<bool>		fc_clear_single_error_csr;
	///Once a stomp is sent, we clear the signal to send the stomp
	sc_out<bool>		fc_clear_single_stomp_csr;
#endif
		

	//Connexion pour les NOP request
	///Databuffer requests that a nop be sent.
	sc_in <bool> db_nop_req_fc;
	///Reordering requests that a nop be sent.
	sc_in <bool> ro_nop_req_fc;
	///A nop was just sent
	sc_out <bool> fc_nop_sent;
	
	// NOP info packet
	///The buffer information received in a nop
	sc_in<sc_bv<12> > cd_nopinfo_fc;
	///If a nop was just received
    sc_in<bool> cd_nop_received_fc;

    ///Let the reordering know which buffers are free in the next node
	sc_out <sc_bv<6> > fwd_next_node_buffer_status_ro;

#ifdef RETRY_MODE_ENABLED
	///The packet that is acked in the nop (for retry mode)
	/**
		When we receive this ack value, we can erase the packet associated with
		that number (and all the previous ones) from our buffers.
	*/
	sc_in<sc_uint<8> > cd_nop_ack_value_fc;

	///CD maitains a count of valid packet received, that count is then sent in nops
	sc_in<sc_uint<8> > cd_rx_next_pkt_to_ack_fc;

	//////////////////////////////////////////
	//	Memory interface - synchronous
	/////////////////////////////////////////
	sc_out<bool> history_memory_write;///<Write to history memory
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;///<Address where to write in history memory
	sc_out<sc_bv<32> > history_memory_write_data;///<Data to write to history memory
	sc_out<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;///<Address where to read in history memory
	sc_in<sc_bv<32> > history_memory_output;///<Data read in history memory


	///To clear the farent count (like for when we initiate a retry sequence)
	sc_signal <bool>	clear_farend_count;

	//Connection to History buffers
	///The packet from the history buffer
	sc_signal <sc_bv<32> >	history_packet;
	///Signal from history buffers to tell that the playback is done
	sc_signal <bool >		history_playback_done;
	///Activate to make the history play back it's history
	sc_signal <bool >		begin_history_playback;
	///Activate to interrupt the history playback
	sc_signal <bool >		stop_history_playback;
	///When the history is ready to begin a playback sequence
	sc_signal <bool >		history_playback_ready;
	///To consume the dword from the history
	sc_signal <bool >		consume_history;

	///Signal from the history buffer to say how much room is available in the buffers
	sc_signal <bool > room_available_in_history;

	///To tell the history buffers to add to it's history the buffer being outputed to the link
	sc_signal <bool >		add_to_history;
	///Prepare a new entry in the history buffers
	sc_signal <bool >		new_history_entry;
	///The size of the entry to prepare
	sc_signal <sc_uint<5> > new_history_entry_size_m1;


	//Connection to CRC unit
	///To calculate the CRC from the current output
	sc_signal<bool>			calculate_crc;
	///Reset the value of the CRC
	sc_signal<bool>			clear_crc;
	///To calculate the CRC from the current output in and store in the alternate nop CRC register
	sc_signal<bool>			calculate_nop_crc;
	///Reset the value of the alternate nop CRC register
	sc_signal<bool>			clear_nop_crc;
	///The CRC register value
	sc_signal<sc_uint<32> >	crc_output;
	///The nop CRC register value
	sc_signal<sc_uint<32> >	nop_crc_output;


#endif

	
	///Controls the output mux which selects what is sent to the TX link
    sc_signal <sc_uint<4> > fc_ctr_mux;



	//------------------------------------------
	// Instanciation
	//------------------------------------------
	flow_control_l3* the_flow_control; ///>("the_flow_control");
    nop_framer_l3* the_nop_framer; ///>("the_nop_framer");
    multiplexer_l3* the_multiplexer; ///>("the_multiplexer");
	rx_farend_cnt_l3* the_rx_farend_cnt; ///>("the_rx_farend_cnt");
	user_fifo_l3* the_user_fifo; ///>("the_user_fifo");
	fairness_l3* the_fairness; ///>("the_fairness");
#ifdef RETRY_MODE_ENABLED
	history_buffer_l3* the_history_buffer;///>("the_history_buffer");
	fc_packet_crc_l3* the_fc_packet_crc;///>("the_fc_packet_crc");
#endif

    //***********************************
	// Intern Signals
	//***********************************
	
	    //FIFO --FC
	///packet coming from the user fifo
	sc_signal <sc_bv<64> > fifo_user_packet;
	///if there is packet available from the user fifo
	sc_signal<bool> fifo_user_available;
	///consume the data from the user fifo
    sc_signal <bool> consume_user_fifo;			//acknowledge
	///flow control (l3) is currently reading output, do not change it!
    sc_signal <bool> hold_user_fifo;

	/** @name Fifo registered modules
		These signals are not necessary, but they are registered in fifo
		module to accelerate the combinatorial path of the next module.
	*/
	//@{
	///Virtual channel of the ::fifo_user_packet
 	sc_signal<VirtualChannel> fifo_user_packet_vc;
	///If ::fifo_user_packet is a double word packet (as opposed to a quad word, word = 16 bits)
	sc_signal<bool> fifo_user_packet_dword;
	///If ::fifo_user_packet has any data associated
	sc_signal<bool> fifo_user_packet_data_asociated;
#ifdef RETRY_MODE_ENABLED
    ///
	sc_signal<PacketCommand > fifo_user_packet_command;
#endif
    ///Size of ::fifo_user_packet data in dwords minus 1
	sc_signal<sc_uint<4> > fifo_user_packet_data_count_m1;
    ///If ::fifo_user_packet has the chain bit on (also checks if it's a posted packet)
	sc_signal<bool> fifo_user_packet_isChain;
    //@}
    
    ///Dword coming from the nop generator    
	sc_signal <sc_bv<32> > ht_nop_pkt;

	//Fairness Algorithm

	///If the local side has priority
	sc_signal<bool> local_priority;

	///If a local packet is issued (can be sent or reserved to send when buffers available)
	sc_signal<bool> local_packet_issued;

 

	//NOP 
	///A nop is the next packet that must be sent after the current on has been sent
	sc_signal <bool> nop_next_to_send;
	///Disconnect nops must be generated
    sc_signal <bool> generate_disconnect_nop;
	///If the RO and DB have buffers to notify as being free to the next node
	sc_signal <bool> has_nop_buffers_to_send;
	
	///To select the CRC as output to the link
	sc_signal <bool> select_crc_output;
	///To select the nop CRC as output to the link
	sc_signal <bool> select_nop_crc_output;
	       
    /// indicate the packet type that is sent. 
	//one hot encoding, meaning of bits :
	//0 - response data
	//1 - response command
	//2 - non-posted data
	//3 - non-posted command
	//4 - posted data
	//5 - posted command
	sc_signal <sc_bv<6> > current_sent_type;

	///The output of the registered MUX (selection of data source before per-packet CRC)
	sc_signal <sc_bv<32> > mux_registered_output;

	///SystemC macro
	SC_HAS_PROCESS(flow_control_l2);

	///constructor, instanciates sub-modules and links them
	flow_control_l2(sc_module_name name);
	
#ifdef RETRY_MODE_ENABLED
	///Takes care of sending the clear_single error and clear single stomp to the CSR
	void send_clear_single_error_and_stomp();
#endif

#ifdef SYSTEMC_SIM
	///class destructor in simulation, to free the instanciated sub-modules
	virtual ~flow_control_l2();
#endif
};
	

#endif	
