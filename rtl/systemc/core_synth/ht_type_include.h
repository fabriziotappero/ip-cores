//ht_type_include.h
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

///Include file for enum types mostly and small definitions.
/** 
	@file ht_type_include.h
	@author Ami Castonguay
*/

#ifndef HT_TYPE_INCLUDE_H
#define HT_TYPE_INCLUDE_H

#ifndef SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_USER_DEFINED_MAX_NUMBER_OF_PROCESSES
#define SC_VC6_MAX_NUMBER_OF_PROCESSES 20
#endif
#include <systemc.h>

/**
	The general role of a packet is defined by it's command.  This represents
	all the possible types of control packets
*/
#ifdef SYSTEMC_SIM
enum PacketCommand
#else
typedef sc_uint<4> PacketCommand ;
enum PacketCommand_values 
#endif

{FLUSH,WRITE,READ,RD_RESPONSE,EXTENDED_FLOW,ADDR_EXT,
			BROADCAST,FENCE,ATOMIC,TGTDONE, NOP,SYNC,RESERVED_CMD};

/**
	All packets except INFO packets travel in a virtual channel.  This
	represents the diffent virtual channels available.
*/

//Even in simulation use a "typedef" because it makes tracing much easier
//#ifdef SYSTEMC_SIM
//enum VirtualChannel
//#else
typedef sc_uint<2> VirtualChannel ;
enum VirtualChannel_values 
//#endif
{VC_POSTED = 0,VC_NON_POSTED = 1,VC_RESPONSE = 2,VC_NONE = 3};


/**
	Packets can be categorized by their functions.  This represents
	all those possible categories
*/
#ifdef SYSTEMC_SIM
enum PacketType
#else
typedef sc_uint<3> PacketType ;
enum PacketType_values 
#endif

{INFO,REQUEST,RESPONSE,ADDR_EXT_TYPE,RESERVED_TYPE};

///Type of response errors
/**
	When returning a response, an error bit is also sent to warn if an
	error occured when sending or treating the packets.  This represents
	all the available errors.
*/
#ifdef SYSTEMC_SIM
enum ResponseError
#else
typedef sc_uint<2> ResponseError ;
enum ResponseError_values 
#endif
{RE_NORMAL,RE_TARGET_ABORT,RE_DATA_ERROR,RE_MASTER_ABORT};

//@{ @name FREE_VC Position
/**  These are the positions of the bits that advertise wether sending
* packets to the virtual channels is allowed*/
///Bit position for posted vc
const unsigned FREE_VC_POSTED_POS = 5;
///Bit position for posted vc with data
const unsigned FREE_VC_POSTED_DATA_POS = 4;
///Bit position for posted vc
const unsigned FREE_VC_NPOSTED_POS = 3;
///Bit position for nposted vc with data
const unsigned FREE_VC_NPOSTED_DATA_POS = 2;
///Bit position for response vc
const unsigned FREE_VC_RESPONSE_POS = 1;
///Bit position for response vc with data
const unsigned FREE_VC_RESPONSE_DATA_POS = 0;
//@}

///Possible destination of a packet
/** There are two use for this : UI_DEST,FWD_DEST and CSR_DEST or
	ACCEPTED_DEST and FWD_DEST
	This is why UI_DEST and ACCEPTED_DEST both have same value
*/
enum packetDestination {UI_DEST = 0, ACCEPTED_DEST = 0, FWD_DEST = 1, CSR_DEST = 2};

#ifdef SYSTEMC_SIM
///To output a command
ostream &operator<<(ostream &out,const PacketCommand &cmd);

///To output a packet type
ostream &operator<<(ostream &out,const PacketType &type);

///To output a packet virtual channel
ostream &operator<<(ostream &out,const VirtualChannel &vc);

///To output a packet response error
ostream &operator<<(ostream &out,const ResponseError &re);
#endif


#endif
