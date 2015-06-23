//decoder_l2.h

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
 *   Max-Elie Salomon
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


#ifndef DECODER_L2_H
#define DECODER_L2_H

//Forward declerations
class cd_state_machine_l3;
class cd_counter_l3;
class cd_cmd_buffer_l3;
class cd_cmdwdata_buffer_l3;
class cd_mux_l3;
class cd_nop_handler_l3;

#ifdef RETRY_MODE_ENABLED
class cd_packet_crc_l3;
class cd_history_rx_l3;
#endif

///Input decoder for the Hypertransport module

/**
	@class decoder_l2
	@description The decoder has the task of first analyzing what dwords
	are received from the link and to organize them in packets
	that can be stored in the command buffer (reordering) or
	data buffer.  It also takes care of sending flow control (nop)
	information to the flow control module.

	When malformed or invalid packets are received, an error in logged
	but most likely, everything that will follow will be completely
	corrupted...   
	
	If the retry mode is on, it verifies that the
	per-packet CRC's are valid.  If they are not, then the decoder
	initiates a retry sequence.  It also ignores stomped packet.  If
	a stomped packet that has data associated is received, the data
	that's already stored in the databuffers is dropped.

	This is basically just a big state machine that directs the received
	dwords.  There are a lot of states because it is possible to insert
	a command packet inside a data transfer.  Per packet CRC's also complicate
	things quite a bit because there is no garantee in which order they will
	arrive when a command packet is inserted in a data transfer.  *Note: per
	packet CRC was simplified with revision 2.0b of the spec : inserted
	command CRC must follow the packet CRC.

  
	Contains the following sub-modules:

  		-state_machine
		-counter
		-cmd_buffer
		-cmdwdata_buffer
		-mux	
		-NOP_handler
		-historyRxCnt

	@author Max-Elie Salomon
	        Ami Castonguay
  */

class decoder_l2 : public sc_module
{
public:
	//*******************************
	// Internal signals
	//*******************************

	//-------------------------------
	//   state machine / buffer 1
	//-------------------------------
	///Load the lower 32 bits of the buffer with no data
	sc_signal< bool >		enCtl1;
	///Load the upper 32 bits of the buffer with no data
	sc_signal< bool >		enCtl2;

	//----------------------------------------
	//   state machine / buffer 2 (with data)
	//----------------------------------------
	///Load the lower 32 bits of the buffer with data
	sc_signal< bool >		enCtlWdata1;
	///Load the upper 32 bits of the buffer with data
	sc_signal< bool >		enCtlWdata2;

	//----------------------------------------
	//   state machine / counter
	//----------------------------------------
	///Flag indicating the next valid data dword will be the last
	sc_signal< bool >		end_of_count;
	///Flag indicating the last data dword has been received
	//sc_signal< bool >		count_done;

#ifdef RETRY_MODE_ENABLED
	//----------------------------------------
	//   buffers / MUX
	//----------------------------------------
	///The buffer for the packet without data
	sc_signal< syn_ControlPacketComplete >	ctlPacket0;
	///The buffer for the packet with data
	sc_signal< syn_ControlPacketComplete >	ctlPacket1;
	///To select wich buffer is being outputed between ctlPacket0 and ctlPacket1
	sc_signal< bool >		selCtlPckt;
#endif

	//----------------------------------------
	//   state machine / NOP handler
	//----------------------------------------
	///A nop has been received, register the nop content
	sc_signal< bool >		setNopCnt;
	///Send a notification that a nop has been received/validated
	sc_signal< bool >		send_nop_notification;

#ifdef RETRY_MODE_ENABLED
	//----------------------------------------
	//   state machine / NOP handler
	//----------------------------------------
	//Signals for CRC
	///If the signal on the input matches the calculated CRC1
	sc_signal<bool>			crc1_good;
	///If the signal on the input is the inverse of the calculated CRC1
	sc_signal<bool>			crc1_stomped;
	///Add the input vector to the CRC1 calculation
	sc_signal<bool>			crc1_enable;
	///Reset the CRC1 value
	sc_signal<bool>			crc1_reset;

	///If the signal on the input matches the calculated CRC2
	sc_signal<bool>			crc2_good;
	///If the signal on the input is the inverse of the calculated CRC2
	sc_signal<bool>			crc2_stomped;
	///Add the input vector to the CRC2 calculation
	sc_signal<bool>			crc2_enable;
	///Reset the CRC1 value
	sc_signal<bool>			crc2_reset;
	///If CTL is activated, should CRC2 be calculated instead of CRC1
	sc_signal< bool >	crc2_if_ctl;
#endif

	//----------------------------------------
	//   other internal signals
	//----------------------------------------
	
	///Command of the packet received from the input fifo
	sc_signal< PacketCommand >	cmd;

#ifdef RETRY_MODE_ENABLED
	///error signal for extended 64 address
	sc_signal< bool >			error64Bits;
#endif
	///error signal for extended 64 address for packet that has data associated
	sc_signal< bool >			error64BitsCtlwData;

	// /get an address from data buffer and set data count
	sc_signal< bool >			getAddressSetCnt;

	//----------------------------------------
	//   sub-module instanciation
	//----------------------------------------

	cd_state_machine_l3		*SM;///<The controler of the decoder
	cd_counter_l3			*CNT;///<A simple counter
	cd_cmdwdata_buffer_l3	*CMDWDATA_BUF;///<A command buffer for packets that contain data
	cd_nop_handler_l3		*NOP_HANDLER;///<Module that handles received nop packets

#ifdef RETRY_MODE_ENABLED
	cd_cmd_buffer_l3		*CMD_BUF;///<A command buffer
	cd_mux_l3				*MUX;///<A simple multiplexer
	cd_history_rx_l3		*HISTORY;///<Counts the number of received packets for history (retry mode) purpose
	cd_packet_crc_l3		*packet_crc_unit;///<Calcultates and checks per-packet CRC
#endif
	
	//*******************************
	//	General signals
	//*******************************

	///Clock to synchronize module
	sc_in < bool >			clk;
	///Warm Reset to initialize module
	sc_in < bool >			resetx;
	
	//*******************************
	//	Signals for Control Buffer
	//*******************************
	
	/**Packet to be transmitted to control buffer module*/
    sc_out< syn_ControlPacketComplete > 	cd_packet_ro;
	/**Enables control buffer module to read cd_packet_ro port*/
	sc_out< bool > 						cd_available_ro;
	/**If we're currently receiving data.  This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_out<bool>						cd_data_pending_ro;
	/**Where we are storing data.   This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_out<sc_uint<BUFFERS_ADDRESS_WIDTH> >	cd_data_pending_addr_ro;

	//*******************************
	//	Signals for Data Buffer
	//*******************************	

	///ddress of data in data buffer module
	sc_in< sc_uint<BUFFERS_ADDRESS_WIDTH> >		db_address_cd;
	///Get an address form data buffer module
	sc_out< bool >				cd_getaddr_db;
	///Size of data packet to be written
	sc_out< sc_uint<4> >		cd_datalen_db;
	///Virtual channel where data will be written
	sc_out< VirtualChannel >	cd_vctype_db;
	///Data to be written in data buffer module
	sc_out< sc_bv<32> > 		cd_data_db;
	///Enables data buffer to read cd_data_db port
	sc_out< bool > 				cd_write_db;

#ifdef RETRY_MODE_ENABLED
	///Erase signal for packet stomping
	sc_out< bool >				cd_drop_db;
#endif

	
	//*************************************
	// Signals to CSR
	//*************************************
	
	///A protocol error has been detected
	sc_out< bool >			cd_protocol_error_csr;
	///A sync packet has been received
	sc_out< bool >			cd_sync_detected_csr;
#ifdef RETRY_MODE_ENABLED
	///If retry mode is active
	sc_in< bool >			csr_retry;
#endif
	
	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector input from the FIFO 
	sc_in< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_in< bool > 			lk_hctl_cd;
	///Control bit
	sc_in< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_in< bool > 			lk_available_cd;

#ifdef RETRY_MODE_ENABLED
	///If a retry sequence is initiated by link
	sc_in< bool > 			lk_initiate_retry_disconnect;
#endif
	//*******************************
	//	Signals for Forwarding module
	//*******************************

#ifdef RETRY_MODE_ENABLED
	///History count
	sc_out< sc_uint<8> > 		cd_rx_next_pkt_to_ack_fc;
	///rxPacketToAck (retry mode)
	sc_out< sc_uint<8> > 	cd_nop_ack_value_fc;
#endif

	///Info registered from NOP word
	sc_out< sc_bv<12> > 	cd_nopinfo_fc;
	///Signal that new nop info are available
	sc_out< bool >			cd_nop_received_fc;

#ifdef RETRY_MODE_ENABLED
	///Start the sequence for a retry disconnect
	sc_out< bool >			cd_initiate_retry_disconnect;
	///A stomped packet has been received
	sc_out<bool>			cd_received_stomped_csr;
	///Let the reordering know we received a non flow control stomped packet
	/**  When this situation happens, packet available bit does not become
		 asserted but the correct packet is sent, which can be used to know
		 from which VC to free a flow control credit.
	*/
	sc_out<bool> cd_received_non_flow_stomped_ro;
#endif
	///The link can start a sequence for a ldtstop disconnect
	sc_out< bool >			cd_initiate_nonretry_disconnect_lk;


	/**
		This process sets outputs that need to become
		available by the end of the clock time where an
		input bit vector is received:

			cd_data_db
			cd_getaddr_db
			cd_datalen_db
			cd_vctype_db
			erasedAddress
	*/	
	void set_outputs();

	///SystemC macro
	SC_HAS_PROCESS(decoder_l2);

	/**
		Module constructor

	*/
	decoder_l2( sc_module_name name);

#ifdef SYSTEMC_SIM
	~decoder_l2();
#endif

};

#endif

