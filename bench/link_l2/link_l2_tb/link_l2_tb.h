//link_l2_tb.h
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

#ifndef LINK_L2_TB_H
#define LINK_L2_TB_H

#include <queue>
#include "../../../rtl/systemc/core_synth/synth_datatypes.h"
#include "../../../rtl/systemc/core_synth/constants.h"

const int poly = 0x04C11DB7; /* The HT periodic CRC polynomial */

/** struct regrouping a dword, it's LCTL and HCTL values and
	if there is a ctl transition error during the transmission*/
struct LinkTransmission{
	sc_bv<32>	dword;
	bool		lctl;
	bool		hctl;
	bool		error;
};

//Forward decleration
class link_rx_transmitter;
class link_tx_validator;

///Testbench for the link_l2 module
/**
	@class link_l2_tb
	@author Ami Castonguay
	@description This is a module to test the link module in it's
		whole.  It will test for the different retry and ldtstop
		sequences, for periodic CRC corectness, etc.
*/
class link_l2_tb : public sc_module {

public:
	
	///Main system clock
	sc_in<bool >		clk;
	///Reset of the system
	sc_out<bool>			resetx;
	///If the power of the system is ok, for link width sampling
	sc_out<bool>			pwrok;
	///If in a LDTSTOP sequence (power saving mode)
	sc_out<bool>			ldtstopx;


	///CTL going to RX part of the link
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy_ctl_lk;
	///CAD going to RX part of the link
	sc_out<sc_bv<CAD_IN_DEPTH> >		phy_cad_lk[CAD_IN_WIDTH];
	///If there is CTL and CAD available for the RX part of the link
	sc_out<bool>						phy_available_lk;

	///CTL from TX part of the link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_ctl_phy;
	///CAD from TX part of the link
	sc_in<sc_bv<CAD_OUT_DEPTH> >	lk_cad_phy[CAD_OUT_WIDTH];
	///To consume data coming from TX part of the link
	sc_out<bool>						phy_consume_lk;

	///If the link disables drivers
	sc_in<bool>					lk_disable_drivers_phy;
	///If the link disables receivers
	sc_in<bool>					lk_disable_receivers_phy;

	/**
		Data to be sent to the next link
		This data comes from the flow control
	*/
	//@{
	///Dword to send
	sc_out<sc_bv<32> > 	fc_dword_lk;
	///The LCTL value associated with the dword to send
	sc_out<bool>			fc_lctl_lk;
	///The HCTL value associated with the dword to send
	sc_out<bool>			fc_hctl_lk;
	///To consume the data from the flow control
	sc_in<bool>		lk_consume_fc;
	//@}


	//*******************************
	//	Signals from link
	//*******************************
	
	///Bit vector output for command decoder 
	sc_in< sc_bv<32> > 		lk_dword_cd;
	///Control bit
	sc_in< bool > 			lk_hctl_cd;
	///Control bit
	sc_in< bool > 			lk_lctl_cd;
	///FIFO is ready to be read from
	sc_in< bool > 			lk_available_cd;

	/**
	Link widths
	
	000 8 bits 
	100 2 bits 
	101 4 bits 
	111  Link physically not connected 
	*/
	//@{
	///The link width for the RX side
	sc_out<sc_bv<3> >	csr_rx_link_width_lk;
	///The link width for the TX side
	sc_out<sc_bv<3> >	csr_tx_link_width_lk;
	//@}

	//If the chain is being synched
	sc_out<bool>			csr_sync;

	///If this link should be inactive because it is the end of chain
	sc_out<bool>			csr_end_of_chain;

	///To update the link width registered in the CSR with the new value
	sc_in<bool>		lk_update_link_width_csr;
	///The link width that is being sampled
	sc_in<sc_bv<3> >	lk_sampled_link_width_csr;
	///A protocol error has been detected
	sc_in<bool>		lk_protocol_error_csr;


	///Force CRC errors to be generated
	sc_out<bool>			csr_crc_force_error_lk;
	///To turn off the transmitter
	sc_out<bool>			csr_transmitter_off_lk;
	///Hold CTL longer in the ini sequemce
	sc_out<bool>			csr_extented_ctl_lk;
	///The timeout for CTL being low too long is extended
	sc_out<bool>			csr_extended_ctl_timeout_lk;
	///If we are enabled to tristated the drivers when in ldtstop
	sc_out<bool>			csr_ldtstop_tristate_enable_lk;
	
	///CRC error detected on link
	sc_in<bool>		lk_crc_error_csr;
	///Update the link failure flag in CSR with the lk_link_failure_csr signal
	sc_in<bool>		lk_update_link_failure_property_csr;

#ifdef RETRY_MODE_ENABLED
	///Start a retry sequence
	sc_in<bool>		lk_initiate_retry_disconnect;
	///Command decoder commands a retry disconnect
	sc_out<bool>			cd_initiate_retry_disconnect;

	///The flow control asks us to disconnect the link
	sc_out<bool>			fc_disconnect_lk;
	///If we are in the retry mode
	sc_out<bool >		csr_retry;
#endif
	///RX link is connected (identical to lk_initialization_complete_csr)
	sc_in<bool>		lk_rx_connected;
	///This signal should only be evaluated at lk_update_link_failure_property_csr
	sc_in<bool>		lk_link_failure_csr;

	//A sync error has been detected
	// - Not used anymore, sync only detected through standard decode logic
	//sc_in<bool>		lk_sync_detected_csr;

	///Command decoder commands a ltdstop disconnect
	sc_out<bool>			cd_initiate_nonretry_disconnect_lk;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_in<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_in<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;
#endif

	///Queue of dwords to send to the RX side of the link
	std::queue<LinkTransmission>	transmit_rx_queue;
	///Queue of dwords expected to be received from the link
	std::queue<LinkTransmission>	expected_rx_queue;

	///Module that takes care of initializing the link and sending data to RX side
	link_rx_transmitter * transmitter;
	///Module that takes validates what is sent from the TX side
	link_tx_validator * validator;

	///When true, will send warm reset signaling and reinit the link
	/** Once the link is reconnected, reset_rx_connection goes to false*/
	bool reset_rx_connection;
	///Wether to check if what the rx receives is valid
	bool check_rx_dword_reception;

	///SystemC Macro
	SC_HAS_PROCESS(link_l2_tb);

	///Constructor
	link_l2_tb(sc_module_name name);
	///Desctructor
	virtual ~link_l2_tb();

	///Main control of the testbench (scripted events)
	void stimulus();
	///Brings the testbench and link to an initial state, then
	///start the reconnection sequence
	void init();

	///Takes care of starting initialization and feeding data from queue to RX
	void manage_rx_transmission();
	///Checks that framed data produced from the RX side is correct
	void validate_rx_reception();

	//Fills TX queue with random transmissions
	/**
		@description Will add random transmission to the queue of
			things for the TX to send.  CRC's are NOT inserted
			in the queue by this.
		@param quantity The number of transmissions to add to the queue
		@param updateCRC If the current CRC should be updated with
			the queued transmission
	*/
	void fill_tx_qeues(const unsigned quantity,bool updateCRC);
	///Empties the TX packet queue and resets crc if requested
	void empty_tx_queues(bool reset_crc);
	///Fill both RX and TX queues
	/**
		@description Will fill both RX and TX queues with random 
			transmissions.  Periodic CRC's will automatically be
			inserted in the stream of transmissions.  This is to
			be called only once to setup RX and TX queues as
			it will start to fill the queues as if it's in the
			first CRC window (first window is different from
			following CRC windows).
		@param quantity The number of packet to insert (does not
			take into account the periodic CRC's inserted in the
			stream)
		@param insertLastCrc If a CRC should be added to the stream
			if it's the last thing to add.  Example : if 128+16
			transmissions are added, should the CRC just following
			those transmission be added or not
	*/
	void init_fill_queues(const unsigned quantity,bool insertLastCrc);

	//Fills RX queue with random transmissions
	/**
		@description Will add random transmission to the queue of
			things for the RX to receive.  CRC's are NOT inserted
			in the queue by this.
		@param quantity The number of transmissions to add to the queue
		@param updateCRC If the current CRC should be updated with
			the queued transmission
	*/
	void fill_rx_qeues(const unsigned quantity,bool updateCRC);
	///Empties the RX packet queue and resets crc if requested
	void empty_rx_queues(bool reset_crc);


	///Creates a completely random transmission to send
	void generate_random_transmission(LinkTransmission & t);

	/**
		@description To update a CRC just like the HT tunnel calculates it
		@param crc Initially contains the current crc value.  It is updated
			with the new calculated value
		@param dword The dword to calculate the crc
		@param lctl The lctl value used to calculate the new CRC
		@param hctl The hctl value used to calculate the new CRC
	*/
	void update_crc(int & crc,const sc_bv<32> &dword, bool lctl, bool hctl);

	///CRC value for the last CRC window sent to RX side
	int last_rx_crc;
	///Current partial CRC value for in-progress window being sent to RX side
	int rx_crc;

	///CRC value for the last CRC window received from TX side
	int last_tx_crc;
	///Current partial CRC value for in-progress window being received from TX side
	int tx_crc;

	///Number of RX packet send : for debug only
	int rx_number;
	///If a CRC error is expected
	/** Contains the number of CRC errors that are expected, decremented every
		time the link assert that a CRC error was detected*/
	int expecting_rx_crc_error;

};

#endif
