//decoder_l2_tb.h
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

#ifndef DECODER_L2_TB_H
#define DECODER_L2_TB_H

#include "../../rtl/systemc/core_synth/synth_datatypes.h"
#include <deque>


///Testbench for the decoder_l2 module
class decoder_l2_tb : public sc_module{
public:
	///Contains all data important to check validity of what is sent to databuffer
	/** An instance of the struct is added to the queue when a data packet is
		sent to the databuffer and is checked when the packet is sent to the
		databuffer.  The variable address_requested is false at the beggining and
		is set to be true when the packet address is requested (it is modified
		in the queue).
	*/
	struct DataBufferEntry{
		int size;///<Size in dwords of the data packet (minus 1)
		int data[16];///<Content of the data packet
		bool badcrc;///<If a bad CRC accompanies the data packet
					///<Currently not used but potentially there to check if the
					///<data packet is dropped in case of bad per packet CRC
		bool address_requested;///<Set to true when decoder asks for address from Databuffer
		VirtualChannel vc;///<The virtual channel this data packet belongs to
	};

	///A packet to be sent to the reordering module
	struct ReorderingEntry{
		syn_ControlPacketComplete pkt;
		bool has_data;
	};

	///Information contained in a nop
	struct NopEntry{
		sc_uint<8> 	cd_nop_ack_value_fc;
		sc_bv<12>	cd_nopinfo_fc;
	};

	///clk signal
	sc_in<bool> clk;
	///Warm Reset to initialize module
	sc_out < bool >			resetx;
	
	//*******************************
	//	Signals for Control Buffer
	//*******************************
	
	/**Packet to be transmitted to control buffer module*/
    sc_in< syn_ControlPacketComplete > 	cd_packet_ro;
	/**Enables control buffer module to read cd_packet_ro port*/
	sc_in< bool > 						cd_available_ro;
	/**If we're currently receiving data.  This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_in<bool>						cd_data_pending_ro;
	/**Where we are storing data.   This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_in<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;

	//*******************************
	//	Signals for Data Buffer
	//*******************************	

	///ddress of data in data buffer module
	sc_out< sc_uint<BUFFERS_ADDRESS_WIDTH> >		db_address_cd;
	///Get an address form data buffer module
	sc_in< bool >				cd_getaddr_db;
	///Size of data packet to be written
	sc_in< sc_uint<4> >		cd_datalen_db;
	///Virtual channel where data will be written
	sc_in< VirtualChannel >	cd_vctype_db;
	///Data to be written in data buffer module
	sc_in< sc_bv<32> > 		cd_data_db;
	///Enables data buffer to read cd_data_db port
	sc_in< bool > 				cd_write_db;

#ifdef RETRY_MODE_ENABLED
	///Erase signal for packet stomping
	sc_in< bool >				cd_drop_db;
#endif

	
	//*************************************
	// Signals to CSR
	//*************************************
	
	///A protocol error has been detected
	sc_in< bool >			cd_protocol_error_csr;
	///A sync packet has been received
	sc_in< bool >			cd_sync_detected_csr;
#ifdef RETRY_MODE_ENABLED
	///If retry mode is active
	sc_out< bool >			csr_retry;
#endif
	
	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector input from the FIFO 
	sc_out< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_out< bool > 			lk_hctl_cd;
	///Control bit
	sc_out< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_out< bool > 			lk_available_cd;

#ifdef RETRY_MODE_ENABLED
	///If a retry sequence is initiated by link
	sc_out< bool > 			lk_initiate_retry_disconnect;
#endif
	//*******************************
	//	Signals for Forwarding module
	//*******************************

#ifdef RETRY_MODE_ENABLED
	///History count
	sc_in< sc_uint<8> > 		cd_rx_next_pkt_to_ack_fc;
	///rxPacketToAck (retry mode)
	sc_in< sc_uint<8> > 	cd_nop_ack_value_fc;
#endif

	///Info registered from NOP word
	sc_in< sc_bv<12> > 	cd_nopinfo_fc;
	///Signal that new nop info are available
	sc_in< bool >			cd_nop_received_fc;

#ifdef RETRY_MODE_ENABLED
	///Start the sequence for a retry disconnect
	sc_in< bool >			cd_initiate_retry_disconnect;
	///A stomped packet has been received
	sc_in<bool>			cd_received_stomped_csr;
	///Let the reordering know we received a non flow control stomped packet
	/**  When this situation happens, packet available bit does not become
		 asserted but the correct packet is sent, which can be used to know
		 from which VC to free a flow control credit.
	*/
	sc_in<bool> cd_received_non_flow_stomped_ro;
#endif
	///The link can start a sequence for a ldtstop disconnect
	sc_in< bool >			cd_initiate_nonretry_disconnect_lk;


	///SystemC Macro
	SC_HAS_PROCESS(decoder_l2_tb);

	///Queue of data packet that will be sent to databuffer
	std::deque<DataBufferEntry> databuffer_queue;
	///Qeue of command packet that will be sent to reordering
	std::deque<ReorderingEntry> reordering_queue;
	///Queue of information that will be sent out when nops are received
	std::deque<NopEntry> nop_queue;
	///List of ack values associated with packet sent to databuffer
	std::deque<sc_uint<8> > ack_value;

	///Stores the latest data address given out by the databuffer
	sc_uint<BUFFERS_ADDRESS_WIDTH> last_databuffer_address;

	///If an error was detected by the testbench
	bool error;
	/** Stores with various degrees of delay when the decoder request to
		get an address from the databuffer.  Used to calculate when the
		decoder should start to say that there is data pending.
	*/
	//@{
	sc_signal<bool> delayed_start_writing_data;
	sc_signal<bool> delayed_start_writing_data2;
	sc_signal<bool> delayed_start_writing_data3;
	//@}

	///Asserted while the decoder is writing data to databuffer
	sc_signal<bool> writing_data;

	/**
		Expected values of different control signals from the decoder
		The value is the maximum number of cycles before it should be
		asserted.  Set to zero when it is asserted
	*/
	//@{
	int	expect_cd_initiate_retry_disconnect;
	int expect_cd_received_stomped_csr;
	int expect_cd_initiate_nonretry_disconnect_lk;
	//@}

	///Calculated CRC as testbench sends a packet to decoder that has no data
	unsigned crc1;
	///Calculated CRC as testbench sends a packet to decoder with data
	unsigned crc2;
	///Module constructor
	decoder_l2_tb(sc_module_name name);
	///Module desctructor
	virtual ~decoder_l2_tb(){}
	
	///Main control thread of the testbench
	void stimulate_input();
	///Validates that nop_received is correct, along with freed buffers and ack values
	void nop_info_validation();
	///Validates that what is sent to the databuffer is correct
	void databuffer_validation();
	///Validates that disconnect (retry or not) and stomped signals are good
	void disconnect_retry_validation();
	///Validates that whas is sent to the reordering is correct
	void reordering_validation();
	///Display the message and set that an error was received
	void displayError(const char * error_message);

	///Sends a dword to the databuffer (contains wait)
	void send_dword(sc_bv<32> dword,bool lctl, bool hctl);
	///Send random nop to decoder
	void send_nop();
	///Send target done packet to decoder
	void send_tgtdone();
	///Send read packet to decoder
	void send_read();
	///Send write packet to decoder
	void send_write();
	///Takes care of sending a random write header packet
	/**@param datalength_m1 The number minus one of dwords 
			  of data that will follow the header
	*/
	void send_write_header(int datalength_m1);
	///Creates a databuffer entry: random dword to send for databuffer
	/**@param datalength_m1 The number minus one of dwords of data
	   @param vc The virtual channel the data belongs to
	   @return The generated databuffer entry
	*/
	DataBufferEntry generate_data_packet(int datalength_m1,
										VirtualChannel vc);
	///Sends a data packet
	/**@description Allows to sent part of a datapacket at a time with
			the offset and last parameters
	   @param entry The datapacket to send
       @param offset From where to start the datapacket
	   @param last What is the last position to send
	*/
	void send_data_packet(DataBufferEntry &entry,
						int offset,int last);
	///Send a packet with a 64 bit extension
	void send_ext();
	///Send an extended flow control packet
	void send_ext_fc();
	///Send an extended flow control packet (64 bit version)
	void send_ext_fc64();
	///Send a packet with data and a targetdone inserted inside it
	void send_tgtdone_in_data();
	///Send a packet with data and a flow control packet inserted inside it
	void send_fc_in_data();
	///Send a packet with data and a 64 bit flow control packet inserted inside it
	void send_fc64_in_data();
	///Send a packet with data and a nop packet inserted inside it
	void send_nop_in_data();
	///Send a disconnect nop
	void send_discon_nop();

	///Get a random 32-bit vector
	void getRandomVector(sc_bv<32> &vector);
	///Get a random 64-bit vector
	void getRandomVector(sc_bv<64> &vector);
	///Add a reordering entry to the queue for a dword packet
	void addReorderingEntry(sc_bv<32> &vector,bool hasData);
	///Add a reordering entry to the queue for a qword packet
	void addReorderingEntry(sc_bv<64> &vector,bool hasData);
	///Update the CRC1 value
	/**
		@param dword The dword to use for per packet CRC calculation
		@param lctl The lctl to use for per packet CRC calculation
		@param hctl The hctl to use for per packet CRC calculation
	*/
	void calculate_crc1(sc_bv<32> dword,bool lctl, bool hctl);
	///Update the CRC2 value
	/**
		@param dword The dword to use for per packet CRC calculation
		@param lctl The lctl to use for per packet CRC calculation
		@param hctl The hctl to use for per packet CRC calculation
	*/
	void calculate_crc2(sc_bv<32> dword,bool lctl, bool hctl);
	///Update per packet CRC with the data
	/**
		@param crc The crc value to update
		@param data The combined dword and CTL vector to use for calculations
	*/
	void calculate_crc(unsigned &crc,sc_bv<34> &data);

};

#endif

