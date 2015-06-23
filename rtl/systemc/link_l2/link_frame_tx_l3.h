//link_fram_tx_l3.h
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

#ifndef LINK_FRAME_TX_L3_H
#define LINK_FRAME_TX_L3_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"
#include "link_l2.h"


///Initializes outgoing link and frames outgoing data
/**
	@author Ami Castonguay
*/
class link_frame_tx_l3 : public sc_module {
	/**
		Possible output selection for bits 1..0, depending on
		the physical link width, actually used link width and timing of the link
	*/
	enum OutputSelectionValues1_0
	{ LINK_OUTPUT1_0_INIT = 0, ///<Init value sent on the link (for initialization)
	LINK_OUTPUT1_0_2BIT_CYCLE1 = 1,///<First cycle of data sent out for 2-bit width

	LINK_OUTPUT1_0_4BIT_CYCLE1 = 2,///<First cycle of data sent out for 4-bit width (only if physical width > 2)
	LINK_OUTPUT1_0_2BIT_CYCLE2 = 3,///<Second cycle of data sent out for 2-bit width (only if physical width > 2)

	LINK_OUTPUT1_0_8BIT = 4,///<First (and only) cycle of data sent out for 8-bit width (only if physical width > 4)
	LINK_OUTPUT1_0_4BIT_CYCLE2 = 5,///<Second cycle of data sent out for 4-bit width (only if physical width > 4)
	LINK_OUTPUT1_0_2BIT_CYCLE3 = 6,///<Third cycle of data sent out for 2-bit width (only if physical width > 4)
	LINK_OUTPUT1_0_2BIT_CYCLE4 = 7///<Fourth cycle of data sent out for 2-bit width (only if physical width > 4)
	};

	/**
		Possible output selection for bits 3..2, depending on
		the physical link width, actually used link width and timing of the link

		This is only used if the physical width is > 2
	*/
	enum OutputSelectionValues3_2
	{ 
	LINK_OUTPUT3_2_INIT = 0,  //<Init value sent on the link (for initialization)
	LINK_OUTPUT3_2_4BIT_CYCLE1 = 1,///<First cycle of data sent out for 4-bit width

	LINK_OUTPUT3_2_8BIT = 3,///<First (and only) cycle of data sent out for 8-bit width (only if physical width > 4)
	LINK_OUTPUT3_2_4BIT_CYCLE2 = 2,///<Second cycle of data sent out for 4-bit width (only if physical width > 4)
	};

	/**
		Possible output selection for bits 7..4, depending on
		the physical link width, actually used link width and timing of the link

		This is only used if the physical width is > 4
	*/
	enum OutputSelectionValues7_4
	{ 
	LINK_OUTPUT7_4_INIT = 0,   //<Init value sent on the link (for initialization)
	LINK_OUTPUT7_4_8BIT = 1,///<First (and only) cycle of data sent out for 8-bit width

	};


	/**
		State of the state machine that connects the TX link.  
	*/
	enum tx_frame_state {
		TX_FRAME_INACTIVE_ST,///< Initial state, link is IDLE, sending warm reset signaling
		TX_FRAME_INIT_ACTIVATE_CTL_ST,///< Init sequence, activate CTL to say that we are read for init
		TX_FRAME_INIT_DISABLE_CTL_CAD_CT_ST,///< Init sequence phase 2
		TX_FRAME_INIT_ACTIVATE_CAD_ST,///< Init sequence phase 3
		TX_FRAME_ACTIVE_ST,///< Normal running operation
	#ifdef RETRY_MODE_ENABLED
		TX_FRAME_RETRY_DISCONNECT_ST,///< Retry disconnect
	#endif
		TX_FRAME_LDTSTOP_DISCONNECT_ST///< LDTSTOP disconnect
	};

public:

	///Main clock of the system
	sc_in<bool >		clk;

	///TX CTL Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///TX CAD Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///If the link consumes the data we output
	sc_in<bool>						phy_consume_lk;
	///To disable drivers to same power
	sc_out<bool >	disable_drivers;
	
	///Data that needs to be framed
	sc_in<sc_bv<32> >	cad_to_frame;
	///LCTL value
	sc_in<bool>	lctl_to_frame;
	///HCTL value
	sc_in<bool >	hctl_to_frame;
	///To consume the data to frame at the input
	sc_out<bool>		tx_consume_data;
	///A signal sent to a combinatory process that will activate tx_consume_data if phy_consume_lk is asserted
	sc_signal<bool>		consume_if_can_output;

	/**
		External global system signals
	*/
	//@{
	///Reset the system
	sc_in<bool>			resetx;
	///LDTSTOP sequence (power saving mode)
	sc_in<bool>			ldtstopx;
	//@}

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	///The link width for the RX side
	sc_in<sc_bv<3> >	csr_tx_link_width_lk;

	///If it is an end of chain and the link can be deactivated
	sc_in<bool >		csr_end_of_chain;

	///Stop the transmitter
	sc_in<bool> csr_transmitter_off_lk;

	///Stop the transmitter if in ldtstop mode
	sc_in<bool> csr_ldtstop_tristate_enable_lk;

	///Hold CTL longer in the init sequence
	sc_in<bool>			csr_extented_ctl_lk;

	///Encoded value of tx link width from CSR.  See ::LinkWidthEncoded
	sc_signal<sc_uint<2> >		tx_link_width_encoded;

	///Link commands a ltdstop disconnect
	sc_in<bool>			ldtstop_disconnect_tx;
#ifdef RETRY_MODE_ENABLED
	///The flow control asks us to disconnect the link
	/**Disconnect will occur after the dword is done sending*/
	sc_in<bool>			tx_retry_disconnect;
#endif

	///RX side is waiting for CTL to be activated in the retry sequence
	/** The TX init sequence cannot be started until RX CTL has been received*/
	sc_in<bool>		rx_waiting_for_ctl_tx;
		
	///Multi-purpose couner
	sc_signal<sc_uint<NUMBER_BITS_REPRESENT_1US_MIN9> > counter;

	///State of the state machine
	sc_signal<tx_frame_state>	state;

	///Value to send on the CAD bits while init
	sc_signal<bool>		init_cad_value;
	///Value to send on the CTL bit while init
	sc_signal<bool>		init_ctl_value;

#if CAD_OUT_WIDTH == 8
	///What to output on CAD bits 1..0
	sc_signal<sc_uint<3> >	select_value_1_0;
	///What to output on CAD bits 3..2
	sc_signal<sc_uint<2> >	select_value_3_2;
	///What to output on CAD bits 7..4
	sc_signal<sc_uint<1> >	select_value_7_4;
#elif CAD_OUT_WIDTH == 4
	///What to output on CAD bits 1..0
	sc_signal<sc_uint<2> >	select_value_1_0;
	///What to output on CAD bits 3..2
	sc_signal<sc_uint<1> >	select_value_3_2;
#else
	///What to output on CAD bits 1..0
	sc_signal<sc_uint<1> >	select_value_1_0;
#endif

	sc_signal<bool> ldtstop_sequence_detected;

	///SystemC Macro
	SC_HAS_PROCESS(link_frame_tx_l3);

	/** 
	@description Module/class constructor
	@param name The name of the instance of the module
	*/
	link_frame_tx_l3( sc_module_name name);

	/**
		Takes the input dword and reorders it so that it can easily
		be sent out to the link easily with shift registers on each
		CAD bit.
	*/
	void reorder_output();

	/**
		Takes the link width sent from the CSR and encodes in a easy to use
		internal format.
	*/
	void encode_link_width();

	/**
		State machine that controls the state of the TX state machine.  It controls
		things such as the init sequence, ldtstopx sequence, retry reconnect.
	*/
	void state_machine();


	/**
		Combinatory process to consume the data if there is available
	*/
	void generate_consume_data();
};

#endif
