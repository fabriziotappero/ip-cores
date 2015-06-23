// cd_state_machine_l3.h

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

#ifndef CD_STATE_MACHINE_L3_H
#define CD_STATE_MACHINE_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"

/**
	States of the state machine
*/
enum vm_state { 
	CONTROL_st,		/**<Reception of a control command*/
	ADD_st,			/**<Reception of an address for a command*/
	ADD_WDATA_st,	/**<Reception of an address for a command
						with data associated*/
	FC64_st,		/**<Waiting for the second part of a 64 bit flow control
						control packet*/

	DATA1_st,		/**<Reception of data, inserted control command
						or CRC of data */ 
	INS2_st,		/**<Reception of address for a packet inserted in a data stream*/
	INS2_FC64_st,	/**<Reception of second dword of a 64 bit flow control packet*/

	CONTROL_EXT_st, /**<64 bit address extension received, waiting for the following
						standard control packet */
	CONTROL_EXT2_st, /**<64 bit address extension received, waiting for the following
						standard control packet, after which we go back to waiting
						for data*/
#ifdef RETRY_MODE_ENABLED
	CRC_st,			/**<Reception of a CRC check word for non data control packet
						that is stored in the buffers*/
	DATACRC_st,			/**<Reception of a CRC check word for data packet*/
	CRC_NOP_st,		/**<Reception of a CRC check word for a NOP*/
	CRC_EXTFC_st,	/**<Reception of a CRC check word for an extended flow control*/

	DATA2_st,		/**< Reception of CRC or request (wihout data)inserted inside
						a data packet*/ 
	DATA2_NOP_st,	/**< Reception of CRC of NOP packet inserted inside
						a data packet*/
	DATA2_FC_st,	/**< Reception of CRC of extended flow control packet inserted inside
						a data packet*/ 
	SEND_DISC_st,	/**< Send a disconnect to the failed link */
#endif

	PRTCL_ERR_st,	/**< A protocol error was detected */
	PRTCL_ERR_CLR_DATA_st,	/** <A protocol error was detected, and the partial
	                    (or corrupted) data in the buffers has to be dropped before
						we keep on going*/
	SYNC_st			/**< Chain is in a SYNC state */

};

///State machine sub-module for the decoder module

/**
	@class cd_state_machine_l3
	@description State machine that controls the decoder.  This is the core
		of the decoder module.  The role of the decoder is to properly direct
		received packets : the state machine keeps track of what is received
		and where it should go.  The state machine becomes complex because
		packets can arrive in many different orders.  Some packets can also
		be malformed and errors must be generated.
		
	@author Ami Castonguay

  */
class cd_state_machine_l3 : public sc_module

{
	//*******************************
	// Internal signals
	//*******************************
	///Next state of the machine
	sc_signal<vm_state> nextState;
	///State of the machine
	sc_signal<vm_state> currentState;
	///Next packet to be selected
	sc_signal< bool >	nextSelCtlPckt;
	///Next value of a packet being available in the output register
	sc_signal< bool >	next_controlEnable;
	///Packet being available in the CTL output register
	/**
		This is not equivalent to cd_available_ro because in non retry
		mode, a packet must wait until another control packet is received
		before being commited, because of the possibility of a reset
		corrupting a packet in transmission
	*/
	sc_signal< bool >	controlEnable;
	///Packet being available in the CTL with data output register
	sc_signal< bool >	controlDataEnable;
	///Shows current state in console for debugging
	//bool smComments;
	

#ifdef RETRY_MODE_ENABLED
	//Counter for number of sync receveid
	sc_signal<sc_uint<3> >	sync_count;
	//next value of counter for number of sync receveid
	sc_signal<sc_uint<3> >	next_sync_count;
#endif

public:

	//*******************************
	//	Inputs
	//*******************************

	///Clock to synchronize module	
	sc_in<bool> clk;
	///Input bit vector
	sc_in< sc_bv<32> >	dWordIn;

#ifdef RETRY_MODE_ENABLED
	///Retry mode or not
	sc_in< bool >		csr_retry;
	sc_in< bool >		lk_initiate_retry_disconnect;
#endif

	///Control bit
	sc_in< bool >		lk_lctl_cd;
	///Control bit
	sc_in< bool >		lk_hctl_cd;
	/// Data available from the fifo
	sc_in< bool >		lk_available_cd;

#ifdef RETRY_MODE_ENABLED
	///If the signal on the input matches the calculated CRC1
	sc_in< bool >		crc1_good;
	///If the signal on the input matches the calculated CRC2
	sc_in< bool >		crc2_good;
	///If the signal on the input is the inverse of the calculated CRC1
	sc_in< bool >		crc1_stomped;
	///If the signal on the input is the inverse of the calculated CRC2
	sc_in< bool >		crc2_stomped;
#endif


	///Flag indicating the next valid data dword will be the last
	sc_in< bool >		end_of_count;
	///Flag indicating the last data dword has been received
	//sc_in< bool >		count_done;

	///Reset signal (active low)
	sc_in< bool >		resetx;

	//*******************************
	//	Outputs
	//*******************************
#ifdef RETRY_MODE_ENABLED
	///To add the input vector to the calculation of CRC1
	sc_out< bool >	crc1_enable;
	///To add the input vector to the calculation of CRC2
	sc_out< bool >	crc2_enable;
	///Reset the CRC1 value
	sc_out< bool >	crc1_reset;
	///Reset the CRC2 value
	sc_out< bool >	crc2_reset;
	///If CTL is activated, should CRC2 be calculated instead of CRC1
	sc_out< bool >	crc2_if_ctl;
#endif

	///Get an address from data buffer and set data count
	sc_out< bool >	getAddressSetCnt;
	///Enable data to be read by data buffer
	sc_out< bool >	cd_write_db;
#ifdef RETRY_MODE_ENABLED
	///Erase data from data buffer (stomp)
	sc_out< bool >	cd_drop_db;
#endif

	///Enable control command to be read by control buffer
	sc_out< bool >	cd_available_ro;
	///Enable first half of a control word, that will have data if retry mode enabled or any otherwise
	sc_out< bool >	enCtlwData1;
	///Enable second half of a control word, that will have data if retry mode enabled or any otherwise
	sc_out< bool >	enCtlwData2;
#ifdef RETRY_MODE_ENABLED
	///Select which control packet will drive the output (the one with data or the one without)
	sc_out< bool >	selCtlPckt;
	///Enable first half of a control word that will NOT have data
	sc_out< bool >	enCtl1;
	///Enable second half of a control word that will NOT have data
	sc_out< bool >	enCtl2;
	///Flag to be activated following reception of an address extension
	sc_out< bool >	error64Bits;
#endif
	///Enable the NOP count to be set
	sc_out< bool >	setNopCnt;
	///Flag to be activated following reception of an address extension
	sc_out< bool >	error64BitsCtlwData;

	///Flag to be activated upon detection of a protocol error
	sc_out< bool >	cd_protocol_error_csr;
	///Flag to be activated upon detection of a sync error/packet
	sc_out< bool >	cd_sync_detected_csr;
	///Notify that the nop has been received
	/**
		This is not always the same as setNopCnt because in the retry mode,
		the nop CRC has to be received and validated before we notify that we
		have new data.
	*/
	sc_out<bool> send_nop_notification;


	/**When not in retry mode and we receive a disconnect nop, the link simply
	turns off it's receivers until LDTSTOP stops.  This signal CANNOT be activated
	when csr_retry is asserted*/
	sc_out<bool> cd_initiate_nonretry_disconnect_lk;

#ifdef RETRY_MODE_ENABLED
	///Let the CSR know we received a stomped packet
	sc_out<bool> cd_received_stomped_csr;

	///Let the CSR know we received a non flow control stomped packet
	sc_out<bool> cd_received_non_flow_stomped_ro;

	/**When in retry mode, we immediately go to reset mode for both
	receiver and transmitter.  This signal cannot be activated when
	csr_retry is not asserted*/
	sc_out<bool> cd_initiate_retry_disconnect;
	sc_signal<bool> next_cd_initiate_retry_disconnect;
#endif
	/**If we're currently receiving data.  This is used by the ro to know
	if we have finished receiving the data of a packet, so it can know if
	it can send it.*/
	sc_signal<bool>						cd_data_pending_ro_buf;
	/**
		It is also used to know if a data packet has been commited to prevent
		data corruption because of reset
	*/
	sc_out<bool>						cd_data_pending_ro;
	
	
	
	/**
			This combinational process is responsible with calculating the
			next state based on the current state and/or the value received
			as a doubleword bit vector input.
	*/	
	void getnextst();
	/**
			This sequential process is responsible with updating the current
			state of the machine and other sequential outputs, as well as
			processing the reset (nClear) signal.
	*/	
	void setstate();
	/**
			This combinational process is responsible with setting the outputs
			of the state machine according to the current state and/or the value
			received as a doubleword bit vector input.
	
	*/
	void stateoutputs();

	/**
		Because not all nodes of a HyperTransport chain receive a reset
		simultaneously, we only commit data once a new control packet
		has been received.  Data packets work a bit differently : in non-retry
		mode, they must be sent to the RO immediately for ordering reasons.  In
		their case, before sending out a Data packet, the RO checks with the
		decoder to see if it had been commited so we don't need to hold it out.
	*/
	void output_packet_selection();

	///SystemC Macro
	SC_HAS_PROCESS(cd_state_machine_l3);

	///	Module constructor
	cd_state_machine_l3(sc_module_name name);
};

#endif
