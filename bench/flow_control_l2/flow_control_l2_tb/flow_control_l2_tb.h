//flow_control_l2_tb.h
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

#ifndef FLOW_CONTROL_L2_TB_H
#define FLOW_CONTROL_L2_TB_H

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"	
#include "../../../rtl/systemc/core_synth/constants.h"
#include <deque>
#include <string>

#define NOP_COUNTER_DELAY 20

///Testbench for the complete flow_control_l2 module
/** The flow_control_l2 module is BIG, so testing it is a HUGE job.
    This testbench covers a couple of simple cases but in no way
	covers all the functionality.
*/
class flow_control_l2_tb : public sc_module
{
public:
	///Delay before nop frees buffers
	/**
	   The testbench simulates the flow control credits, so when packets are received,
	   flow control credits are eventually freed and sent to the flow control module.
	   This is number of cycles of delay there is between the time packets are received
	   and the moment credit are freed
	*/
	static const int nop_counter_delay;

	///Maximum number of data buffers there are in the simulated next node
	static const unsigned next_node_databuffers_maximum[3];

	///Maximum number of command buffers there are in the simulated next node
	static const unsigned next_node_buffers_maximum[3];


	///A structure that represents a packet of data
	struct PacketData{
		int size;///< Size (number of dwords), from 1 to 16
		int dwords[16];///< actual data
		sc_bv<64> associated_control_pkt;///< The command packet associated with this data
	};

	///A structure to identify an entry in the data buffers
	struct DataBufferEntry{
		sc_uint<BUFFERS_ADDRESS_WIDTH> address;///<Unique address of the entry
		VirtualChannel vc;///<Virtual channel of the entry
		int size;///< Size (number of dwords), from 1 to 16
		int dwords[16];///< actual data
	};

	///From what source is the flow control currently sending a packet
	enum FlowControlStatus{
		FC_SENDING_CSR,
		FC_SENDING_EH,
		FC_SENDING_FWD,
		FC_SENDING_UI,
		FC_NONE	
	};

	///An output value of the flow control module, contains 32 bits dword and CTL values
	struct OutputDword{
		sc_bv<32> dword;
		bool lctl;
		bool hctl;
	};

	///Flow control informatino contained in a nop packet
	struct NopInfo{
		sc_bv<12> nop_information;
		sc_uint<8> nop_ack_value;
		bool nop_received;
	};

	///Structure representing a history entry
	struct HistoryEntry{
		sc_bv<64> pkt;///<The command packet
		sc_uint<8> nop_ack_value;///<Ack value of the entry (part of HT spec!)
		unsigned data_size;///<Number of dwords of data
		unsigned data[16];///<The actual data
		unsigned crc;///Per packet CRC of the entry
	};

	///Exception that can be thrown
	struct TestbenchError{
		std::string message;
	};

	/// The Clock
	sc_in<bool> clk;
	/// Reset signal
	sc_out<bool> resetx;
	///LDTSTOP# signal
	sc_out<bool> ldtstopx;
	
    // USER_FIFO
	///The packet the user interface wants to send
    sc_out <sc_bv<64> >			ui_packet_fc;
	///If it there is a packet available to be sent
	sc_out <bool>				ui_available_fc;
	///The VC's that can accept packets currently
	sc_in <sc_bv<3> >			fc_user_fifo_ge2_ui;
	
	///The VC in which the flow control wants to read data from the UI data buffer
	sc_in <VirtualChannel>		fc_data_vc_ui;
	///The data from the UI buffers
	sc_out <sc_bv<32> >			ui_data_fc; 
	///To consume the data from the UI buffers
	sc_in <bool>				fc_consume_data_ui;
     
	// Forward -- FC
    //If there is a packet to be sent from the reordering from the other side
    sc_out <bool> ro_available_fwd;
	///The packet to send
    sc_out <syn_ControlPacketComplete > ro_packet_fwd;
	///The VirtualChannel of the packet to send
	sc_out <VirtualChannel > ro_packet_vc_fwd;
	///To acknoledge that the packet has been consumed
    sc_in <bool> fwd_ack_ro;

   	//LINK
	///The dword to send to the other link
    sc_in <sc_bv<32> > fc_dword_lk;
	///The LCTL control signal to send along with the data
    sc_in <bool> fc_lctl_lk;
	///The HCTL control signal to send along with the data
    sc_in <bool> fc_hctl_lk;
	///The link consumes the data we are sending
    sc_out  <bool> lk_consume_fc;
#ifdef RETRY_MODE_ENABLED
	///Force the link to disconnect
    sc_in <bool> fc_disconnect_lk;
	///This signal is active when the RX side of the link is connected
	sc_out  <bool> lk_rx_connected;
	///If the link wants to initiate a retry disconnect
	sc_out  <bool> lk_initiate_retry_disconnect;
	///If we are in the mode retry
	sc_out <bool> csr_retry;
	//Command decoder
	/**Turns on when a disconnect sequence is initiated
	All buffer counts are zeroed and we must replay all packets
	that have not been acked*/
	sc_out <bool>	cd_initiate_retry_disconnect;
#endif
    		
	//DATA BUFFER
	///The address where to read the data
    sc_in <sc_uint<BUFFERS_ADDRESS_WIDTH> > fwd_address_db;
	///The VC in which to read the data
    sc_in <VirtualChannel>  fwd_vctype_db;
	///To read (consume) the data at the address specified
    sc_in <bool> fwd_read_db;
	///The data received from the data buffer
    sc_out <sc_bv<32> > db_data_fwd;
  
	
    ///Buffer count information from RO and DB for sending nop's
	///The buffers the ro can notify as being free to the HT node we are connected to
    sc_out <sc_bv<6> > ro_buffer_cnt_fc;
	///The buffers the ro can notify as being free to the HT node we are connected to
    sc_out <sc_bv<6> > db_buffer_cnt_fc;
    
    //Connexion Error handler FLOW control
	///Acknoledge that the dword has been read
	sc_in <bool> fc_ack_eh;
	///The dword to send (command packet or data payload)
	sc_out <sc_bv<32> > eh_cmd_data_fc;
	///If there is a dword to send
	sc_out <bool> eh_available_fc;
    
	//Connexion CSR -- FLOW control
	///Acknoledge that the dword has been read
	sc_in <bool> fc_ack_csr;	
	///If there is a dword to send
	sc_out <bool> csr_available_fc;
	///The dword to send (command packet or data payload)
	sc_out <sc_bv<32> > csr_dword_fc;
	
	///If we are to turn the transmitter off
	sc_out <bool> csr_transmitteroff;
	
	///This bit forces a single stomp to be sent
	sc_out<bool>			csr_force_single_stomp_fc;
	///This bit forces a single CRC error to be sent
	sc_out<bool>			csr_force_single_error_fc;
	///Once a stomp is sent, we clear the signal to send the stomp
	sc_in<bool>		fc_clear_single_error_csr;
	///Once a CRC error is sent, we clear the signal to send the error
	sc_in<bool>		fc_clear_single_stomp_csr;

		

	//Connexion pour les NOP request
	///Databuffer requests that a nop be sent.
	sc_out <bool> db_nop_req_fc;
	///Reordering requests that a nop be sent.
	sc_out <bool> ro_nop_req_fc;
	///A nop was just sent
	sc_in <bool> fc_nop_sent;
	
	// NOP info packet
	///The buffer information received in a nop
	sc_out<sc_bv<12> > cd_nopinfo_fc;
	///If a nop was just received
    sc_out<bool> cd_nop_received_fc;

    ///Let the reordering know which buffers are free in the next node
	sc_in <sc_bv<6> > fwd_next_node_buffer_status_ro;

#ifdef RETRY_MODE_ENABLED
	///The packet that is acked in the nop (for retry mode)
	/**
		When we receive this ack value, we can erase the packet associated with
		that number (and all the previous ones) from our buffers.
	*/
	sc_out<sc_uint<8> > cd_nop_ack_value_fc;

	///CD maitains a count of valid packet received, that count is then sent in nops
	sc_out<sc_uint<8> > cd_rx_next_pkt_to_ack_fc;

	//////////////////////////////////////////
	//	Memory interface - synchronous
	/////////////////////////////////////////
	sc_in<bool> history_memory_write;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_write_address;
	sc_in<sc_bv<32> > history_memory_write_data;
	sc_in<sc_uint<LOG2_HISTORY_MEMORY_SIZE> > history_memory_read_address;
	sc_out<sc_bv<32> > history_memory_output;

	///Actual content of the simulated memory
	unsigned	history_memory[HISTORY_MEMORY_SIZE];
#endif

	///This containes packets sent to the user fifo
	/** The TB does not strictly test that the user fifo extracts the correct
	    packet (the user_fifo testbench is there for that), but it does keep 
		track of all packet sent and extracted from the user_fifo to make sure
		they are valid
	*/
	std::deque<sc_bv<64> > user_packets;
	///Data associated with the user packets
	/**This will be used to generate inputs to the flow_control when it wants
	   to access the data associated with the packets read from the user_fifo*/
	std::deque<PacketData> user_data[3];
	///VC of the data being read by the flow_control
	VirtualChannel current_user_data_vc;
	///VC of the data currently being received by the UI
	/** UI takes a cycle to update it's output, so this variable keeps track of
	    what is currently on the ouput (what was requested last cycle)
	*/
	VirtualChannel current_user_data_vc_output;
	///Packet that are expected to be outputed
	/**Most packet are read from various sources, so once they are read, we
	   can expect what it is going to be outputed.  This does not cover all
	   packets though : for example user packets are internal to the
	   flow_control_2 module so there is no way to predict that it will
	   be output, at least with black box testing.*/
	std::deque<OutputDword> expected_output;

	///History structure of the design
	std::deque<HistoryEntry> history;

	///Status of the design : what it is currently sending
	FlowControlStatus fc_status;

	///Data of the databuffer entry
	/**
		A real databuffer is not simulated.  When a packet is sent from the
		command buffers, the address is noted and stored and checking when
		the flow control module tries to check the data.  This variable
		stores the data of the entry
	*/
	DataBufferEntry databuffer_data;
	///Virtual channel of the databuffer entry currently being output
	/** Databuffer has a latency of 1 cycle before data is correct on the output.
	    This variable store information about what is currently being output (what
		was requested last cycle)*/
	VirtualChannel databuffer_output_vc;
	///Address of the databuffer entry currently being output
	/** Databuffer has a latency of 1 cycle before data is correct on the output.
	    This variable store information about what is currently being output (what
		was requested last cycle)*/
	unsigned	databuffer_output_addr;

	///SystemC Macro
	SC_HAS_PROCESS(flow_control_l2_tb);

	///Module constructor
	flow_control_l2_tb(sc_module_name name);

	///Controls percentage of change of generating packet from different sources
	/**
		Will vary throughout different stages of the testbench
	*/
	//@{
	int percent_chance_from_eh;
	int percent_chance_from_csr;
	int percent_chance_from_fwd;
	int percent_chance_from_ui;
	//@{

	///Number of dwords of data left to send (or sent) from the different sources
	//@{
	unsigned data_left_eh;
	unsigned data_left_csr;
	unsigned data_sent_ui;
	unsigned data_sent_db;
	//@{

	///Controls percentage of change of requesting nop packet to be sent
	/**
		Will vary throughout different stages of the testbench
	*/
	//@{
	int percent_chance_nop_req_db;
	int percent_chance_nop_req_ro;
	//@{

	///Controls percentage of change of requesting nop packet to received
	/**
		Will vary throughout different stages of the testbench
	*/
	int percent_chance_nop_received;

	///Per packet CRC calcualted for packets with no data associated
	unsigned crc1;
	///Per packet CRC calcualted for packets with data associated
	unsigned crc2;

	//This is the number of buffers that are free (command and data)
	unsigned next_node_buffers_free[3];
	unsigned next_node_databuffers_free[3];

	//This is the number of buffers that have been advertised as being free through
	//nops as seen by the next node (does not take into account the nop delay)
	unsigned next_node_buffers_advertised[3];
	unsigned next_node_databuffers_advertised[3];

	//This is the number of buffers that have been advertised as being free through
	//nops as seen by the current node (takes into account the nop delay)
	unsigned buffers_available[3];
	unsigned databuffers_available[3];

	/**  verify_output() MUST run after produce_inputs, 
	     so when produce_inputs is done, do a notification
	*/
	sc_event input_produced;

	///Nop delay is done simply be shifting data inside an array
	NopInfo nop_delay[NOP_COUNTER_DELAY];

	///<Variable used to track the construction of the history structure
	/** The history structure is build from reading the output of the
		flow_control module.  All these variables are used to build up
		the current_history_entry which is then stored in the history\
		structure
	*/
	HistoryEntry current_history_entry;
	bool history_second_dword_next;
	bool history_crc_next;
	int history_data_count;
	bool history_ignore_nop_crc;
	int history_ack_value;

	///The count of packet received (for the retry mode)
	sc_uint<8>	next_node_ack_value_pending;
	sc_uint<8>	next_node_ack_value;

	///If the dword of the flow control should be ignored when calculating the ack valeu
	/** For the history structure, every entry has an ack value.  This value is updated
		by observing the control packets sent from flow_control output.  When the first
		dword of a quad word packet is sent, ignore_next_dword_for_ack is set so that the
		second dword is simply ignored.
	*/
	bool ignore_next_dword_for_ack;

	///If we are in a retry sequence (set by start retry sequence)
	bool retry_sequence;
	///The simulated history structure
	std::deque<HistoryEntry> retry_playback_history;
	///Next dword will be second dword of command packet
	bool retry_second_dword_next;
	///CRC of entry is next
	bool retry_crc_next;
	///Nop can be inserted in stream, after a nop, we expect a Nop CRC
	/**Nop crc will be contained in expected dword structure*/
	bool retry_expect_nop_crc;
	///The amount of data that has been received for an entry
	int retry_data_count;
	///Set after a command packet, if it has data associated to it (in retry sequence)
	/**Cleared when all data is received*/
	bool retry_receive_data;

	///Link is disconnected for retry reasons
	/**  When the flow_control says to the link to disconnect, it takes some cycles
	     before the output is correct again (the link would take some cycles to
		 correctly reconnect.  So when a retry sequence is started, retry_disconnect is
		 set until fc_disconnect_lk is false so that the flow_control output is ignored.
	*/
	bool retry_disconnect;

	///Becomes true when an error is detected
	bool error;

	///Simulates the history memory as if it was a real memory
	void simulate_memory();

	///Set some variables that control global behavious of Testbench over time
	/** It set the percentage of chance of all the */
	void control_testbench();
	///Produces random packets for all inputs of the flow_control
	void produce_inputs();
	///Verifies that the output of the design is correct
	void verify_output();
	///Generate a random response packet
	/**
		@param pkt The generated packet returned by address
		@param data_size The generated packet data size returned by address
	*/
	void generate_random_response(sc_bv<32> &pkt, unsigned &data_size);
	///Generate a random posted packet
	/**
		@param pkt The generated packet returned by address
		@param data_size The generated packet data size returned by address
	*/
	void generate_random_posted(sc_bv<64> &pkt, unsigned &data_size);
	///Generate a random non posted packet
	/**
		@param pkt The generated packet returned by address
		@param data_size The generated packet data size returned by address
	*/
	void generate_random_nposted(sc_bv<64> &pkt, unsigned &data_size);

	///Generate a random packet of any Virtual Channel
	/**
		@param pkt The generated packet returned by address
		@param data_size The generated packet data size returned by address
	*/
	VirtualChannel generate_random_packet(sc_bv<64> &pkt, unsigned &data_size);

	///Generate a random 32-bit vecgtor
	/**
		@param vector The random vector returned by address
	*/
	void getRandomVector(sc_bv<32> &vector);

	///Generate a random 64-bit vecgtor
	/**
		@param vector The random vector returned by address
	*/
	void getRandomVector(sc_bv<64> &vector);

	///Add data packet to the list of packet sent to FC from UI
	/**
		@param datalength The number of dwords of data
		@param ui_vc The virtual channel of the packet
		@param associated_control_packet The command packet associated to the data packet
	*/
	void add_ui_data_packet(unsigned datalength,
							VirtualChannel ui_vc,
							sc_bv<64> &associated_control_packet);

	///Sets the databuffer_data variable
	/**
		@param datalength The number of dwords of data
		@param ui_vc The virtual channel of the packet
		@param associated_control_packet The command packet associated to the data packet
	*/
	void update_databuffer_entry(unsigned datalength,
								VirtualChannel ui_vc,
								sc_uint<4> &data_address);

	///Update CRC1
	/**
		@param dword Dword to use to calculate the new value of CRC1
		@param dword LCTL value to use to calculate the new value of CRC1
		@param dword HCTL value to use to calculate the new value of CRC1
	*/
	void calculate_crc1(sc_bv<32> dword,bool lctl, bool hctl);

	///Update CRC2
	/**
		@param dword Dword to use to calculate the new value of CRC2
		@param dword LCTL value to use to calculate the new value of CRC2
		@param dword HCTL value to use to calculate the new value of CRC2
	*/
	void calculate_crc2(sc_bv<32> dword,bool lctl, bool hctl);

	///Updates a CRC with 34 bits of data
	/**
		@param crc The CRC to update (by address)
		@param data The 34 bits to calculate the CRC on
	*/
	void calculate_crc(unsigned &crc,sc_bv<34> &data);

	///Clears all next node buffer status
	/** This clears all information about the number of free buffers and
	    the number of advertised buffers
	*/
	void clear_next_node_information();

	///Adds the CRC of a data packet to the list of expected dwords
	/**@param data The data packet with it's associated command packet
	*/
	void add_expected_crc_for_packet(PacketData &data);

	///Takes care of everything necessary to verify when a retry sequence is start
	/** Should be called when a disconnect nop is received in retry mode : it will
	    take care of expecting the CRC that will follow the NOP*/
	void start_retry_sequence();

	///Checks correctness of what is sent in retry sequence
	/** Called by verify_output when in the retry sequence */
	void manage_retry_sequence();
	///Manages the history of packet sent
	/** From the output of the flow_control , a history of packet sent is build so 
	    that when a retry sequence occurs, what is resent by the flow control can
		be compared to what is stored in that history*/
	void manage_history();

	///Frees random number of buffers in the next node
	/** Flow control sends packets to the next node, which would fill buffers in a
	    real system.  These real packets would eventually be read and the buffers
		freed.  So this method randomly frees buffers*/
	void free_buffers();
	///Updates the buffers count and ack number on the other side when packets are received
	void manage_ack_buffer_count();
	///Generates nops from the next node (acks history and frees buffers)
	void send_next_node_nops();

};

///Function to allow to output the status to an outputstream
ostream &operator<<(ostream &out,const flow_control_l2_tb::FlowControlStatus fc_status);

#endif

