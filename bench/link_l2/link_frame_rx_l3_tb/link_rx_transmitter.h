//link_rx_transmitter.h
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

#ifndef LINK_RX_TRANSMITTER_H
#define LINK_RX_TRANSMITTER_H

#include "../../../rtl/systemc/core_synth/synth_datatypes.h"

///Allows to transmit data to the link in order to test it
/**
	@class link_rx_transmitter
	@author Ami Castonguay
	@description
	This is a module that takes care of transmitting data to the
	link in order to test it.  It takes care of sending an initial
	sequence and afterwards transmitting valid data.  It does not
	take care of CRC's.

	The transmitter can run at various bit-widths and also at
	different offsets.  What is meant by offset is that when data
	is received by the HT tunnel, it is deserialized to 32 bits from
	its original bit-width.  Because of this deserialization, the 
	final data might not be alligned naturally (the received 32-bit
	might contain the end of a dword and the beggining of another
	dword).  The transmitter takes care of simulating this.


	Natural allignment (offset of 0) is this for a 4 bit link:
	output0:  28 ... 9  5 1
	output1:  29 ... 10 6 2
	output2:  30 ... 11 7 3
	output3:  31 ... 12 8 4

	Offset of 2 is this for a 4 bit link:
	output0:  20 ... 9  5 1 + 28 24
	output1:  21 ... 10 6 2 + 29 25
	output2:  22 ... 11 7 3 + 30 26 
	output3:  23 ... 12 8 4 + 31 27

	The (+) marks a change in data dword, even if it's received in the same
	phy_cad_lk.
*/
class link_rx_transmitter : public sc_module{

public:

	sc_in<bool > clk;

	///CTL value sent to the HT tunnel
	sc_out<sc_bv<CAD_IN_DEPTH> >	phy_ctl_lk;
	///CAD value sent to the tunnel
	/** Every element of the array represent one input of the tunnel
		that was deserialized to a factor of CAD_IN_DEPTH*/
	sc_out<sc_bv<CAD_IN_DEPTH> >	phy_cad_lk[CAD_IN_WIDTH];
	///If CAD and CTL values are available to be consumed
	/** True when a dword is sent through the transmitter, false
		otherwise*/
	sc_out<bool>					phy_available_lk;

	///The bit-width of the link
	int bit_width;
	///The offset : how the data is offset from its natural allignment
	int transmission_offset;
	///The last data sent, so that it can be used when sending the data with offset
	sc_bv<32>	last_sent_dword;
	///The last lctl sent, so that it can be used when sending the data with offset
	bool		last_sent_lctl;
	///The last hctl sent, so that it can be used when sending the data with offset
	bool		last_sent_hctl;

#ifndef INTERNAL_SHIFTER_ALIGNMENT
	///High speed deserializer should stall shifting bits for lk_deser_stall_cycles_phy cycles
	/** Cannot be asserted with a lk_deser_stall_cycles_phy value of 0*/
	sc_in<bool > lk_deser_stall_phy;
	///Number of bit times to stall deserializing incoming data when lk_deser_stall_phy is asserted
	sc_in<sc_uint<LOG2_CAD_IN_DEPTH> > lk_deser_stall_cycles_phy;

	void realign();

	SC_HAS_PROCESS(link_rx_transmitter);
#endif


	///Constructor
	link_rx_transmitter(sc_module_name name);

	///Sends the correct CAD and CTL values to initialize the link
	/**
		@param offset1 Offset at the beggining of the init sequence
		@param offset2 Offset at the end of the init sequence.  It does not
			have to be the same as offset1.  offset2 will be the final offset
			that will be kept after the init sequence is done
	*/
	void send_init_sequence(int offset1, int offset2);
	///Sends a dword on the link
	/**
		@param dword The dword to send
		@param lctl The CTL value sent with the dword for first half of transmission
		@param hctl The CTL value sent with the dword for last half of transmission
		@param ctl_error If a CTL transition error should be introduced.  A
			transition at another moment than the half of the transmission will
			be made (which is illegal in HT)
	*/
	void send_dword_link(const sc_bv<32> & dword, 
				 bool lctl, bool hctl, bool ctl_error = false);
	///Send reset signaling
	void send_initial_value(int nb_cyles);
};

#endif
