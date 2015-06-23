//link_l2.h
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

#ifndef LINK_L2_H
#define LINK_L2_H

#include "../core_synth/synth_datatypes.h"
#include "../core_synth/constants.h"


#define CRC_POLY 0x04C11DB7

///Values to represent the link with detected
enum LinkWidthEncoded 
{ LINK_8_BIT = 0, LINK_4_BIT = 1, LINK_2_BIT = 2, INVALID_LINK_WIDTH = 3};

//Forward declaration
class link_frame_rx_l3;
class link_frame_tx_l3;

///Handles low level communicatino of the HyperTransport Tunnel
/**
	@class link_l2	
	@author Ami Castonguay
	@description Handles initialization of the link, framing of incoming
		and outgoing data and also of periodic CRC calculations
*/
class link_l2 : public sc_module {



	/**
		States for the reception part of the link
	*/
	enum rx_crc_state {
		RX_FIRST_CRC_WINDOW_ST,///< First CRC windows (no CRC sent after 64 dwords 
		RX_CRC_WINDOW_BEGIN_ST,///< First 16 dword of the CRC windows
		RX_RECEIVE_CRC_ST,///< Receiving the CRC
		RX_CRC_WINDOW_END_ST,///< Last 112 dword of the CRC windows

		RX_FIRST_CRC_WINDOW_LDTSTOP_ST,///< First CRC window, stop the link after next CRC sent
		RX_CRC_WINDOW_BEGIN_LDTSTOP_ST,///< Beginning of the CRC window, stop the link after next CRC sent
		RX_RECEIVE_CRC_LDTSTOP_ST,///< Receiving the CRC, stop the link after next CRC received
		RX_CRC_WINDOW_END_LDTSTOP_ST,///< End of the CRC window, stop the link after next CRC sent
		RX_CRC_WINDOW_LAST_LDTSTOP_ST,///< Last beginning of the CRC window before stopping the link
		RX_RECEIVE_LAST_CRC_LDTSTOP_ST,///< Receiving the last CRC, stop the link after CRC received
		RX_DISCONNECTED///< Link is stopped
	};

	/**
		States for the transmission part of the link
	*/
	enum tx_crc_state {
		TX_FIRST_CRC_WINDOW_ST,/**First CRC windows (no CRC sent after 64 dwords) */
		TX_CRC_WINDOW_BEGIN_ST,/**<First 64 dword of the CRC windows*/
		TX_SEND_CRC_ST,/**< Sending the CRC */
		TX_CRC_WINDOW_END_ST,/**<Last 448 dword of the CRC windows*/
		TX_INACTIVE_ST,/**<If no link is detected or we are end of chain, 
							put the link in inactive mode.  Only reset can bring
							out of this state. */
		TX_SYNC_ST,/**< If a sync was detected, we go in this mode and only reset can bring
						out of this state.  Syncs are sent out continuously*/

		TX_FIRST_CRC_WINDOW_LDTSTOP_ST,///< First CRC window, stop the link after next CRC sent
		TX_CRC_WINDOW_BEGIN_LDTSTOP_ST,///< Beginning of the CRC window, stop the link after next CRC sent
		TX_SEND_CRC_LDTSTOP_ST,///< Transmit the CRC, stop the link after next CRC transmitted
		TX_CRC_WINDOW_END_LDTSTOP_ST,///< End of the CRC window, stop the link after next CRC sent
		TX_CRC_WINDOW_LAST_LDTSTOP_ST,///< Last beginning of the CRC window before stopping the link
		TX_SEND_LAST_CRC_LDTSTOP_ST,///< Transmit the last CRC, stop the link after CRC transmitted
		TX_LDTSTOP_M64,///< After last CRC, must keep transmitting discon nops for at least 64 bit times
		TX_LDTSTOP///< Link is stopped
	};

	/**
		To select what must be transmitted
	*/
	enum tx_output_selection {
		TX_SELECT_DATA = 0,///< Select data received from the flow_control
		TX_SELECT_CRC = 1,///< Select calculated CRC
		TX_SELECT_DISCON = 2,///< Select disconnect NOP's
		TX_SELECT_SYNC = 3,///< Select SYN packets
	};

public:

	///RX CTL Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CTL bit on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy_ctl_lk;
	///RX CAD Higher is received later (MSB), lower is received first (LSB)
	/** This is the content of a shift register that stored the value
	of the CAD bits on the input.  CAD_IN_DEPTH depends on the PHY to core
	clock ratio.*/
	sc_in<sc_bv<CAD_IN_DEPTH> >		phy_cad_lk[CAD_IN_WIDTH];
	///If there is data available for the core from the link
	/** If the core runs at a frequency higher than the physical link, sometime
	the link will not have data available for the core.  This does not
	cause problem*/
	sc_in<bool>						phy_available_lk;

	///TX CTL Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///TX CAD Higher is sent later (MSB), lower is sent first (LSB)
	sc_out<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///If the physical layer can consume the data we produce
	/** If the core runs at a frequency higher than the link, sometime
	the link will not be able to consume data produced from the core.  This does not
	cause problem*/
#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_out<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_out<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif
	sc_in<bool>						phy_consume_lk;

	///To disable the drivers to save power
	sc_out<bool>					lk_disable_drivers_phy;
	///To disable the receivers to save power
	sc_out<bool>					lk_disable_receivers_phy;

	///When the link is completely disconnected for LDTSTOP
	sc_out<bool>					lk_ldtstop_disconnected;

	///Register to keep the current calculated RX CRC
	sc_signal<sc_uint<32> >		rx_crc;
	///Register to keep the calculated CRC value of the last CRC window
	sc_signal<sc_uint<32> >		rx_last_crc;

	///Register to keep the current calculated TX CRC
	sc_signal<sc_uint<32> >		tx_crc;
	///Register to keep the calculated CRC value of the last CRC window
	sc_signal<sc_uint<32> >		tx_last_crc;


	///To store that a CRC error was encountered.
	/**
		The CRC error is not actually outputed before a sync error can
		be ruled out.
	*/
	sc_signal<bool>			crc_error;
	///Delay time to know if a sync error has been ruled out.
	sc_signal<sc_uint<4> >	crc_error_delay;


	///State of the tx side of the link
	sc_signal<tx_crc_state>	tx_state;
	///State of the rx side of the link
	sc_signal<rx_crc_state>	rx_state;

	///Count to know where we are in the RX CRC windows
	sc_signal<sc_uint<7> > rx_crc_count;

	///Count to know where we are in the TX CRC windows
	sc_signal<sc_uint<7> > tx_crc_count;

	///Selects what is transmitted on the link.  See ::tx_output_selection for possible values
	sc_signal<sc_uint<2> > transmit_select;

	//How many frames of all 1's have been detected, after 16, it is a sync error
	// - Not used anymore, sync only detected through standard decode logic
	//sc_signal<sc_uint<6> > sync_count;
	
	
	///Core clk
	sc_in<bool>			clk;
	///4x Core clk, the link clk
	
	/**
		External global system signals
	*/
	//@{
	///Link is stoped (halted or paused) for power savings
	sc_in<bool>			ldtstopx;
	///Reset the system
	sc_in<bool>			resetx;
	///If power is stabilized - defines wether resetx represents a cold or warm reset
	sc_in<bool>			pwrok;
	///@}

	/**
		Data to be sent to the next link
		This data comes from the flow control
	*/
	//@{
	///Dword to send
	sc_in<sc_bv<32> > 	fc_dword_lk;
	///The LCTL value associated with the dword to send
	sc_in<bool>			fc_lctl_lk;
	///The HCTL value associated with the dword to send
	sc_in<bool>			fc_hctl_lk;
	///To consume the data from the flow control
	sc_out<bool>		lk_consume_fc;
	//@}


	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector output for command decoder 
	sc_out< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_out< bool > 			lk_hctl_cd;
	///Control bit
	sc_out< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_out< bool > 			lk_available_cd;

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	//@{
	///The link width for the RX side
	sc_in<sc_bv<3> >	csr_rx_link_width_lk;
	///The link width for the TX side
	sc_in<sc_bv<3> >	csr_tx_link_width_lk;
	//@}

#ifdef RETRY_MODE_ENABLED
	///If we are in the retry mode
	sc_in<bool >		csr_retry;
#endif
	///If the chain is being synched
	sc_in<bool>			csr_sync;

	///If this link should be inactive because it is the end of chain
	sc_in<bool>			csr_end_of_chain;
	///Stop the transmitter
	sc_in<bool> csr_transmitter_off_lk;

	///To update the link width registered in the CSR with the new value
	sc_out<bool>		lk_update_link_width_csr;
	///The link width that is being sampled
	sc_out<sc_bv<3> >	lk_sampled_link_width_csr;
	///A protocol error has been detected
	sc_out<bool>		lk_protocol_error_csr;


	///Force CRC errors to be generated
	sc_in<bool>			csr_crc_force_error_lk;
	///Hold CTL longer in the init sequence
	sc_in<bool>			csr_extented_ctl_lk;
	///The timeout for CTL being low too long is extended
	sc_in<bool>			csr_extended_ctl_timeout_lk;
	///If we are enabled to tristate the drivers when in ldtstop
	sc_in<bool>			csr_ldtstop_tristate_enable_lk;
	
	///CRC error detected on link
	sc_out<bool>		lk_crc_error_csr;
	///Update the link failure flag in CSR with the lk_link_failure_csr signal
	sc_out<bool>		lk_update_link_failure_property_csr;

#ifdef RETRY_MODE_ENABLED
	///Start a retry sequence
	sc_out<bool>		lk_initiate_retry_disconnect;

	///The flow control asks us to disconnect the link
	/** In retry mode, the link will wait for this signal
		to disconnect, even in a ldtstopx sequence.  Disconnect 
		will occur after the dword is done sending*/
	sc_in<bool>			fc_disconnect_lk;
#endif
	///RX link is connected (identical to lk_initialization_complete_csr)
	sc_out<bool>		lk_rx_connected;
	///This signal should only be evaluated at lk_update_link_failure_property_csr
	sc_out<bool>		lk_link_failure_csr;

	//A sync error has been detected
	// - Not used anymore, sync only detected through standard decode logic
	//sc_out<bool>		lk_sync_detected_csr;

#ifdef RETRY_MODE_ENABLED
	///Command decoder commands a retry disconnect
	sc_in<bool>			cd_initiate_retry_disconnect;
#endif
	///Command decoder commands a ltdstop disconnect
	sc_in<bool>			cd_initiate_nonretry_disconnect_lk;

	///Signal from RX framer - a dword is available
	sc_signal<bool>			framed_data_available;
	///If the framed data can be made available for output
	/** It will be false when receiving periodic CRC for examble */
	sc_signal<bool>			framed_data_ready;

	///CAD signal  send to TX framer to be sent on the link
	sc_signal<sc_bv<32> >	cad_to_frame;
	///LCTL signal send to TX framer to be sent on the link
	sc_signal<bool >		lctl_to_frame;
	///HCTL signal send to TX framer to be sent on the link
	sc_signal<bool >		hctl_to_frame;
	///If the TX framer consumes the data
	sc_signal<bool >		tx_consume_data;

	///Signal to make the TX side disconnect
	/** Disables drivers.  Once deasserted, will begin init sequence*/
	sc_signal<bool>			ldtstop_disconnect_tx;
	///Signal to make the RX side disconnect
	/** Disables receivers.  Once deasserted, will begin init sequence*/
	sc_signal<bool>			ldtstop_disconnect_rx;

	///Asserted when the RX side is waiting for CTL to be activated
	/** TX cannot start it's init sequence until RX has asserted CTL, this
	assures that the next HT node is ready to listen to the init sequence*/
	sc_signal<bool>			rx_waiting_for_ctl_tx;

	///Asserted when a new RX CRC window begins. 
	/**Save CRC as "last" crc and clear current CRC*/
	sc_signal<bool>			new_rx_crc_window;
	///Asserted when a new TX CRC window begins. 
	/**Save CRC as "last" crc and clear current CRC*/
	sc_signal<bool>			new_tx_crc_window;

#ifdef RETRY_MODE_ENABLED
	///Signal to RX and TX to initiate a retry disconnect
	/**Usually equivalent to fc_disconnect_lk, except when sending CRC and SYN flood*/
	sc_signal<bool>			tx_retry_disconnect;
#endif

	///RX framing and initialization module
	link_frame_rx_l3 * frame_rx;
	///TX framing and initialization module
	link_frame_tx_l3 * frame_tx;



	/**
		Keep track of the state for the reception of data, initialization of the
		link, CRC calculation, etc.
	*/
	
	void rx_crc_state_machine();
	
	/**
		Keep track of the state for the transmission of data, initialization of the
		link, CRC calculation, etc.
	*/
	void tx_crc_state_machine();
	
	/**
		Process that calculates the periodic CRC of data that arrives from the link
		so it can be compared with the sent CRC.  If the CRC's do not match, it means
		there was an error in the last CRC window.
	*/
	void evaluate_rx_crc_process();
	
	/**
		Process that calculates the periodic CRC of data that is sent on the link
		so the other side can detect if an error occured during the transmission.
		there was an error in the last CRC window.
	*/
	void evaluate_tx_crc_process();
	
	/**
		Selects what to send to the TX frame module using the ::transmit_select signal.
		See ::tx_output_selection for possible values of ::transmit_select
	*/
	void select_output();

	/**
		Output the signal ldtstop_disconnect_tx signal to the output lk_ldtstop_disconnected.
		Yes, a process that ONLY does that!
	*/
	void output_ldtstop_disconnected();

	///AND gate betweem ::framed_data_available and ::framed_data_ready
	void output_framed_data();

	///SystemC Macro
	SC_HAS_PROCESS(link_l2);

	/** 
	@description Module/class constructor
	@param name The name of the instance of the module
	*/
	link_l2( sc_module_name name);
};

#endif

