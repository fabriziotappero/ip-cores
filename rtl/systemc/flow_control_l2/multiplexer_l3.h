//multiplexer_l3.h

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

#ifndef MULTIPLEXER_L3_H
#define MULTIPLEXER_L3_H

///Selects next data to send to link from the multiple sources
/**
	@class multiplexer_l3
	@author Jean-Francois Belanger
	@description There is multiple possible sources of data to be sent
		to the link.  Once the flow_control_l3 has decided what to send,
		this multiplexer actually selects the right data and registers it.

		A second multiplexer then selects between that registered output
		and the calculated CRC's
*/
class multiplexer_l3 : public sc_module
{
	public:
	/// Clock for registered output
	sc_in <bool > clk;			//FC_MUX_CSR
	
	/// Signal from CSR
	sc_in <sc_bv<32> > csr_dword_fc;			//FC_MUX_CSR
	/// Signal from Error handler
	sc_in <sc_bv<32> > eh_cmd_data_fc;			//FC_MUX_EH
	/// Signal from Data buffer	
	sc_in <sc_bv<32> > db_data_fwd;				//FC_MUX_DB_DATA
	/// Signal from user (DATA)
	sc_in<sc_bv<32> >  ui_data_fc;				//FC_MUX_UI_DATA
	/// Signal from nop_framer( nop information)	
	sc_in <sc_bv<32> > ht_nop_pkt;				//FC_MUX_NOP
	/// Signal from cmd buffer
	sc_in <syn_ControlPacketComplete > fwd_packet; 	//FC_MUX_FWD_LSB-FC_MUX_FWD_MSB
	/// Signal from user_fifo
	sc_in <sc_bv<64> > user_packet;	//FC_MUX_UI_LSB-FC_MUX_UI_MSB
	/// Signal from history buffer
#ifdef RETRY_MODE_ENABLED
	sc_in <sc_bv<32> > history_packet;	//FC_MUX_HISTORY
	/// Signal from CRC unit for non-nop packets
#endif


	/// Control signal of the multiplexer
	sc_in<sc_uint<4> > fc_ctr_mux;
	/// Reset outputs 0
    sc_in <bool> resetx;
	
#ifdef RETRY_MODE_ENABLED
	///To select the normal standard calculated CRC as output
 	sc_in <bool> select_crc_output;
	///To select the nop CRC as output
	sc_in <bool> select_nop_crc_output;
	///The normal CRC calculated by the CRC unit
	sc_in<sc_uint<32> > crc_output;
	///The nop CRC calculated by the CRC unit
	sc_in<sc_uint<32> > nop_crc_output;

#endif

#ifdef RETRY_MODE_ENABLED
	///The registered output of the main multiplexer.  
	/**It is an output to go to CRC unit*/
	sc_out<sc_bv<32> > registered_output;
#else
	///The registered output of the main multiplexer. 
	/**No need to output in non retry mode since there is no CRC */
	sc_signal<sc_bv<32> > registered_output;
#endif

    /// Output of the multiplexer
    sc_out <sc_bv<32> > fc_dword_lk;

	/// 32 bits output multiplexing
	void mux( void );

	///Outputs the correct dword to the link 
	/** Outputs either the data from the main mux or the crc (in retry mode)*/
	void output();

	///SystemC Macro
	SC_HAS_PROCESS(multiplexer_l3);

	///Constructor
	multiplexer_l3(sc_module_name name);
};

#endif

