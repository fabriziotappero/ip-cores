//constants.h
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
 *   Laurent Aubray
 *   Michel Morneau
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

///Includes all definitions to control optional features of the design
/** 
	@file constants.h
	@description This file holds configurable options of the tunnel.  Options
		include wether or not to have the retry mode.  Other options
		are about some fields in the CSR like the address space required
		by the application, frequency of the design supported and
		other identification numbers.  
		
		Some configuration are also about the interface with the user.
		Depending on the latency of the interface, additionnal buffers
		to buffer packets from the user might have to be used.

		The second part of file also describes constants for the design
		that are NOT configurable.
	@author Ami Castonguay
*/

///List of constants

#ifndef CONSTANTS_H
#define CONSTANTS_H

//////////////////////////////////////////////////////
///////////////////////////////////////////////////////
// Constants that CAN and SHOULD be configured!
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

///Comment this line to disable the retry mode
#define RETRY_MODE_ENABLED

///Comment this line to disable command packet reordering
#define ENABLE_REORDERING

///Comment this line to disable direct route feature
#define ENABLE_DIRECTROUTE

///If an internal shifter should be used to correct receive alignment
/**  If defined, the alignment will be corrected using an internal
     shifter.  This also requires two 32 bits registers (x2).  
	 
	 The alternative is to have the RX deserializer (outside of the design)
	 correct the aligment by stalling for a number of cycles.  When
	 not defined, outputs are sent to the deserializer to control
	 the re-alignment circuitry.
*/
//#define INTERNAL_SHIFTER_ALIGNMENT

///Define to register the input packet being transmitted by the user
/**	This controls the user interface for transmitting packets
	to the HT tunnel.  Depending on what is connected to the tunnel,
	it might be necessary or not that signals be registered at the 
	input and output of the interface to respect timing specifications.  
	These #define allow to adjust what is registered.

	The downside of registering is that the "full" signal is also
	delayed, meaning that the buffers must be larger to prevent overflows
*/
#define REGISTER_USER_TX_PACKET

///Define to register the freevc output to the user
#define REGISTER_USER_TX_FREEVC

/**
	-If defined, the user can use the value of freevc from the previous cycle.  This
	might be useful if the output of a connected module is registered
	-If not defined, the user must use the current value of freevc
*/
#define ALLOW_DELAY_USER_TX_FREEVC

#ifdef REGISTER_USER_TX_PACKET
#define REGISTER_USER_TX_PACKET_ADD 1
#else
#define REGISTER_USER_TX_PACKET_ADD 0
#endif

#ifdef REGISTER_USER_TX_FREEVC
#define REGISTER_USER_TX_FREEVC_ADD 1
#else
#define REGISTER_USER_TX_FREEVC_ADD 0
#endif

#ifdef ALLOW_DELAY_USER_TX_FREEVC
#define ALLOW_DELAY_USER_TX_FREEVC_ADD 1
#else
#define ALLOW_DELAY_USER_TX_FREEVC_ADD 0
#endif


/**
	The tunnel can only treat slices of 32 bits at the time.  So
	even if a dead time is inserted after the transmission of every
	64 bit packet, we still achieve maximum throughput.

	If the user always inserts a dead time between sending two control
	packet without data back to back, it means that we hide part of the
	latency of the "buffer full" signal to reach the user.  This way,
	the buffers can be smaller.
*/
#define FORCE_DEAD_CYCLE_BETWEEN_PACKETS

/**
	To have an uninterrupted flow of packets, a minimum of a size of two
	is required.  This brings us to a base of 2 packets in the buffer
	
	The userinterface has a intrisec one cycle of latency,
	After that, the additional options increase the latency of the signal 
	reaching the user, meaning that the buffer must aborb packets because 
	of the latency.

	If the force dead cycle is used, the latency can be cut in two
	(integer division).

	When the user_fifo depth is changed, consider modifying
	USER_FIFO_SHIFT_PRIORITY_MAX_COUNT and USER_FIFO_SHIFT_PRIORITY_LOG2_COUNT
	to reflect this change
*/
#ifdef FORCE_DEAD_CYCLE_BETWEEN_PACKETS
#define USER_FIFO_DEPTH 2 + (1 + REGISTER_USER_TX_PACKET_ADD + REGISTER_USER_TX_FREEVC_ADD + ALLOW_DELAY_USER_TX_FREEVC_ADD)/2
#else
#define USER_FIFO_DEPTH 3 + REGISTER_USER_TX_PACKET_ADD + REGISTER_USER_TX_FREEVC_ADD + ALLOW_DELAY_USER_TX_FREEVC_ADD
#endif

//Used to address the element in the user fifo, log2(width)
#if USER_FIFO_DEPTH <= 4
#define USER_FIFO_ADDRESS_WIDTH 2
#else
#define USER_FIFO_ADDRESS_WIDTH 3
#endif

//Used to count the number of element in the fifo, log2(width+1)
#if USER_FIFO_DEPTH < 4
#define USER_FIFO_COUNT_WIDTH 2
#else
#define USER_FIFO_COUNT_WIDTH 3
#endif


#define USER_MEMORY_SIZE 128
///128 memory space for every space
#define USER_MEMORY_ADDRESS_WIDTH 7
///Every vc takes 1/3 of the memory 42 * 3 = 126  (< 128)
#define USER_MEMORY_SIZE_PER_VC 42
///42 can be represented with 6 bits
#define USER_MEMORY_ADDRESS_WIDTH_PER_VC 6

/**
	We need to warn the user when there is no room left for 
	packets in the memory.  We warn when there we do not have
	space left for a data packet (16).  
	
	We also need to consider that because of pipelining, there is
	a delay before the user	receives the message.  We use the
	calculated FIFO depth to determine how many cycles of latency
	there might be.  There is a base number of two buffers in the
	USER_FIFO_DEPTH, which are not counted.

*/
#define USER_MEMORY_WARN_FULL_SIZE USER_MEMORY_SIZE_PER_VC - 15 - (USER_FIFO_DEPTH - 2)

//Not in constants because the buffers width is used
//in the ControlPacketComplete

// Should reside in the makefile for configurability
/// Define the number of physical buffer units per channel
#define DATABUFFER_NB_BUFFERS 8
#define DATABUFFER_LOG2_NB_BUFFERS 3
/**
	The size of the address that represents buffers
*/
#define BUFFERS_ADDRESS_WIDTH DATABUFFER_LOG2_NB_BUFFERS

/// Indicates the number of buffers in decimal (minimum 3)
#define NB_OF_BUFFERS 7
#define LOG2_NB_OF_BUFFERS 3

/**
	Those two variables is used for the maximum number of times
	a packet without PassPW can be passed by a packet with passPW
	wihtin it's same VirtualChannel.  Once that count is reached,
	passing is not allowed anymore.

	At the time of writing this comment, this is also used for the
	number of time the final_reordering can send a packet from a vc type
	while ignoring another VC type before priority is shifted to the
	packet type being ignored.
*/
#define MAX_PASSPW_COUNT 7
#define MAX_PASSPW_P1_LOG2_COUNT 3

/*	Number of time the user_fifo can send a packet from a vc type
	while ignoring another VC type before priority is shifted to the
	packet type being ignored.
*/#define USER_FIFO_SHIFT_PRIORITY_MAX_COUNT 7
#define USER_FIFO_SHIFT_PRIORITY_LOG2_COUNT 3

//See entrance_reordering to see how bits are used
#ifdef ENABLE_REORDERING
	#if DATABUFFER_LOG2_NB_BUFFERS < 5
		#define CMD_BUFFER_MEM_WIDTH (66 + LOG2_NB_OF_BUFFERS)
	#else
		#define CMD_BUFFER_MEM_WIDTH (62 + LOG2_NB_OF_BUFFERS + DATABUFFER_LOG2_NB_BUFFERS)
	#endif
#else
	#define CMD_BUFFER_MEM_WIDTH (69 + 4 * LOG2_NB_OF_BUFFERS + DATABUFFER_LOG2_NB_BUFFERS)
#endif
	


// Interface constant registers values

// Header constant registers values
const sc_uint<16> Header_VendorID = 0xF0F0;
const sc_uint<16> Header_DeviceID = 0xF0F0;
const sc_uint<24> Header_ClassCode = 0x000000;
const sc_uint<8> Header_HeaderType = 0x00;

const sc_uint<16> Header_SubsystemVendorID = 0x0000;
const sc_uint<16> Header_SubsystemID = 0x0000;
const sc_uint<8> Header_InterruptLine = 0x00;// Reset value of InterruptLine register

const sc_uint<8> Header_RevisionID = 0x40;

/** @name Header BARs constants - First section
There are two sections to configure BAR's. It is the
responsibility of whoever configures those options to make
sure that the two sections are compatible with each other!!!
There is no check to validate you choices! 

The first section is to configure those six slots for 
read/write operations from the exterior world;

The second section is to configure how the BAR's are used
internally.  

  FIRST SECTION

The arrays have size 6 for the 6 slots. The value will be ignored if the 
slot is the second part of a 64 bits BAR.
*/
//@{
/**if the bar slot is for a 64 bit memory space.  If yes, this means that the
	BAR will take this slot and the next slot.  The configuration for the next 
	BAR (X+1) slot will be simply ignored.  This array has only a size of 5 
	because the last slot cannot be 64 bit (every slot is 32 bit and there is 
	no following slotto allow a 64 bit total BAR)
	WARNING : DO NOT SET TWO SLOTS AS 64 BITS BESIDE EACH OTHER!!!*/
const bool Header_BarSlotIOSpace[] = {false,false,
							false,false,
							false,false};

/**allows to choose if it is a memory space (false) or an IO space (true)*/
 const bool Header_BarSlot64b[] = {false,false,
							false,false,
							false};
/** if the memory can be read without side effects */
const bool Header_BarSlotPrefetchable[] = {false,false,
							false,false,
							false,false};

/**The size of the memory or IO space you require.  It is also the number
	of bits that will be hardwired to 0 in that BAR (minus the lowest 3 bits for 
	memory and 2 bits for IO, )
	WARNING : MINIMUM OF 4 FOR MEMORY BAR, 2 FOR IO BAR*/
const int Header_BarSlotSize[] = {10,10,
										10,10,
										10,10};

//const bool Header_BarSlotHardwireZeroes[] = {true,true,
//							true,true,
//							true,true};

//const int Header_BarSlotHarwireSize_m1[] = {9 , 9,
//9,9,
//9,9
//};

const bool Header_BarSlotHardwireZeroes0 = true;
const bool Header_BarSlotHardwireZeroes1 = true;
const bool Header_BarSlotHardwireZeroes2 = true;
const bool Header_BarSlotHardwireZeroes3 = true;
const bool Header_BarSlotHardwireZeroes4 = true;
const bool Header_BarSlotHardwireZeroes5 = true;

const int Header_BarSlotHarwireSize5_m1 = 9;
const int Header_BarSlotHarwireSize4_m1 = 9;
const int Header_BarSlotHarwireSize3_m1 = 9;
const int Header_BarSlotHarwireSize2_m1 = 9;
const int Header_BarSlotHarwireSize1_m1 = 9;
const int Header_BarSlotHarwireSize0_m1 = 9;


//@}

/** @name Header BARs constants - Second section*/
//@{
/**The number of 64 bits bars that you have set.  Most
	of this could be calculated on the fly but since we are doing
	hardware, it is simpler to hard code it, even though it is a bit
	more arduous to manually configure.  */
#define Header_Nb64bits 0
/**DO NOT SET: calculated from Header_Nb64bits to know
	the final total number of bars*/
#define NbRegsBars 6-Header_Nb64bits
/**If the bar is a 64 bit of 32 bit bar*/
const int Header_Bar64b[NbRegsBars] = {false,false,
										false,false,
										false,false};
/** The slot that represents this bar's lsb*/
const int Header_BarLsbPos[NbRegsBars] = 
	{0,1,
	 2,3,
	 4,5};
/**The slot that represents this bar's msb, if it is
	not a 64 bit bar, then this is simply ignored.*/
const int Header_BarMsbPos[NbRegsBars] = 
	{0,0,
	 0,0,
	 0,0};

/**If the bar is an IOspace or a memory space*/
const int Header_BarIOSpace[NbRegsBars] = 
							{false,false,
							false,false,
							false,false};

/**The lenght of the bars.  If a bar slot has a size of 10,
	it means that it request 2^10 bytes = 1024 bytes.  The higher bits of the
	bar is the address of that memory.  So the size of the adress of that memory
	is 40 - 10 = 30.  We can generlize this with the expression :

		Header_BarLength[pos] = 40 - Header_BarSlotSize[Header_BarLsbPos[pos]]

  You simply need to keep this array of the right length*/
const int Header_BarLength[NbRegsBars] = 
	{40 - Header_BarSlotSize[Header_BarLsbPos[0]],
	 40 - Header_BarSlotSize[Header_BarLsbPos[1]],
	 40 - Header_BarSlotSize[Header_BarLsbPos[2]],
	 40 - Header_BarSlotSize[Header_BarLsbPos[3]],
	 40 - Header_BarSlotSize[Header_BarLsbPos[4]],
	 40 - Header_BarSlotSize[Header_BarLsbPos[5]]};

//@}

/** @name Header_BarLowerPos
Because of a limitation of SystemC compiler,
the next values must be filled in manually as
follows :

const int Header_BarLowerPos[NbRegsBars] = {
	39-Header_BarLength[0]+1,
	39-Header_BarLength[1]+1,
	39-Header_BarLength[2]+1,
	39-Header_BarLength[3]+1,
	39-Header_BarLength[4]+1,
	39-Header_BarLength[5]+1 };

The next 6 values must be defined
*/
//@{
const int Header_BarLowerPos0 = 10;
const int Header_BarLowerPos1 = 10;
const int Header_BarLowerPos2 = 10;
const int Header_BarLowerPos3 = 10;
const int Header_BarLowerPos4 = 10;
const int Header_BarLowerPos5 = 10;
//@}


//Link configuration register
//To change link width, just change it here and everything will be configured properly
#define CAD_IN_WIDTH 8
#define CAD_OUT_WIDTH 8


// Interface constant registers values
//Revision ID is 0x40 version 2.0 of HyperTransport
const int Interface_RevisionID = 0x40;

//Max support frequency of the design, check spec section 7.5.7 for possible
//values and 7.5.9 for how to fill out the mask below
const sc_uint<16> Interface_LinkFrequencyCapability0 = 0x0001;      // Mask of supported frequencies link0
const sc_uint<16> Interface_LinkFrequencyCapability1 = 0x0001;      // Mask of supported frequencies link1


// Direct route constant registers values
const int DirectRoute_NumberDirectRouteSpaces = 2;      // Number of address ranges -> minimum=2; maximum=8


// Revision ID constant registers values
const int RevisionID_RevisionID = 0x2A;                 // HyperTransport revision

//This is the maximum number of buffers that we can track in another link
//If the connected has more than 2^(the number), the we ignore the extra
//number of buffers
#define FAREND_BUFFER_COUNT_SIZE 7
#define FAREND_BUFFER_COUNT_MAX_VALUE 127

#define HISTORY_NUMBER_OF_ENTRIES 32
#define LOG2_HISTORY_NUMBER_OF_ENTRIES 5
#define HISTORY_MEMORY_SIZE 128
#define LOG2_HISTORY_MEMORY_SIZE 7


///Number of cycles in 1 us
#define NUMBER_CYCLES_1_US 200
///Number of cycles in 50 us
#define NUMBER_CYCLES_50_US 10000
///Number of bits to count up to NUMBER_CYCLES_1_US, but minimu of 9
#define NUMBER_BITS_REPRESENT_1US_MIN9 9
///This is the number of bits to count up to NUMBER_CYCLES_1_US minus one
/**The following is for less than 1us for the receiver ignore count because
the receiver must ignore the input less time than the full 1 us of link init
or it will miss the beginning of the init sequence*/
#define NUMBER_BITS_REPRESENT_1US_M1 7
///Number of bits to count to 2us
#define NUMBER_BITS_REPRESENT_2US 9
///The number of cycles inside a ms
#define NUMBER_CYCLES_1_MS 200000
///The number of cycles inside a s
#define NUMBER_CYCLES_1_S 200000000
///The number of bits neede to count up to NUMBER_CYCLES_1_S
#define NUMBER_BITS_REPRESENT_1S 28


//////////////////////////////////////////////////////
///////////////////////////////////////////////////////
// Constants that can't be configured, simply internal
// constants of the design
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

//Adjust CSR size in function of what features are activates
#ifdef RETRY_MODE_ENABLED
	#ifdef ENABLE_DIRECTROUTE
		#define CSR_SIZE 132
		#define CSR_DWORD_SIZE 43
	#else
		#define CSR_SIZE 120
		#define CSR_DWORD_SIZE 40
	#endif
#else
	#ifdef ENABLE_DIRECTROUTE
		#define CSR_SIZE 120
		#define CSR_DWORD_SIZE 40
	#else
		#define CSR_SIZE 108
		#define CSR_DWORD_SIZE 37
	#endif
#endif

// Bloc address constants   (Used to set CapabilitiesPointer value of each bloc)
const int DeviceHeader_Pointer = 0x00;       // Bloc requires 0x40 size
const int Interface_Pointer = 0x40;          // Bloc requires 0x1C size
const int RevisionID_Pointer = 0x5C;         // Bloc Requires 0x04 size
const int UnitIDClumping_Pointer = 0x60;     // Bloc requires 0x0C size
#ifdef ENABLE_DIRECTROUTE
	const int DirectRoute_Pointer = 0x6C;        // Bloc requires 0x0C size
	#ifdef RETRY_MODE_ENABLED
		const int ErrorRetry_Pointer = 0x78;         // Bloc requires 0x0C size
	#endif
#else
	#ifdef RETRY_MODE_ENABLED
		const int ErrorRetry_Pointer = 0x6C;         // Bloc requires 0x0C size
	#endif
#endif

const sc_uint<8> DeviceHeader_NextPointer = Interface_Pointer;
const sc_uint<8> Interface_NextPointer = RevisionID_Pointer;
const sc_uint<8> RevisionID_NextPointer = UnitIDClumping_Pointer;

#ifdef ENABLE_DIRECTROUTE
	const sc_uint<8> UnitIDClumping_NextPointer = DirectRoute_Pointer;
#else
	#ifdef RETRY_MODE_ENABLED
		const sc_uint<8> UnitIDClumping_NextPointer = ErrorRetry_Pointer;
	#else
		const sc_uint<8> UnitIDClumping_NextPointer = 0x00;
	#endif
#endif

#ifdef ENABLE_DIRECTROUTE
	#ifdef RETRY_MODE_ENABLED
		const sc_uint<8> DirectRoute_NextPointer = ErrorRetry_Pointer;
	#else
		const sc_uint<8> DirectRoute_NextPointer = 0x00;
	#endif
#endif

#ifdef RETRY_MODE_ENABLED
	const sc_uint<8> ErrorRetry_NextPointer = 0x00;
#endif

//////////////////////////////////////
// Interface constant registers values
//////////////////////////////////////

/** We do NOT support double word flow control so don't modify this unless you modify
    significant part of the decoder and also modify the CSR to properly handle
	configuring this mode*/
const bool Interface_DoubleWordFlowControlIn0 = false;  // 1 = Receiver capable of doubleword based data buffer flow control
const bool Interface_DoubleWordFlowControlIn1 = false;  // 1 = Receiver capable of doubleword based data buffer flow control
const bool Interface_DoubleWordFlowControlOut0 = false; // 1 = Emitter capable of doubleword based data buffer flow control
const bool Interface_DoubleWordFlowControlOut1 = false; // 1 = Emitter capable of doubleword based data buffer flow control

//No need to change anything here, just adjust CAD_IN_WIDTH
#if CAD_IN_WIDTH==8
const int Interface_MaxLinkWidthIn0 = 0x0;              // Maximum width of input line
const int Interface_MaxLinkWidthIn1 = 0x0;              // Maximum width of input line
#elif CAD_IN_WIDTH==4
const int Interface_MaxLinkWidthIn0 = 0x5;              // Maximum width of input line
const int Interface_MaxLinkWidthIn1 = 0x5;              // Maximum width of input line
#elif CAD_IN_WIDTH==2
const int Interface_MaxLinkWidthIn0 = 0x4;              // Maximum width of input line
const int Interface_MaxLinkWidthIn1 = 0x4;              // Maximum width of input line
#else
#error Invalid CAD_IN_WIDTH value
#endif

//No need to change anything here, just adjust CAD_OUT_WIDTH
#if CAD_OUT_WIDTH==8
const int Interface_MaxLinkWidthOut0 = 0x0;              // Maximum width of input line
const int Interface_MaxLinkWidthOut1 = 0x0;              // Maximum width of input line
#elif CAD_OUT_WIDTH==4
const int Interface_MaxLinkWidthOut0 = 0x5;              // Maximum width of input line
const int Interface_MaxLinkWidthOut1 = 0x5;              // Maximum width of input line
#elif CAD_OUT_WIDTH==2
const int Interface_MaxLinkWidthOut0 = 0x4;              // Maximum width of input line
const int Interface_MaxLinkWidthOut1 = 0x4;              // Maximum width of input line
#else
#error Invalid CAD_IN_WIDTH value
#endif


#if CAD_IN_WIDTH == 8
	#define CAD_IN_DEPTH 4
	#define LOG2_CAD_IN_DEPTH 2
#elif CAD_IN_WIDTH == 4
	#define CAD_IN_DEPTH 8
	#define LOG2_CAD_IN_DEPTH 3
#elif CAD_IN_WIDTH == 2
	#define CAD_IN_DEPTH 16
	#define LOG2_CAD_IN_DEPTH 4
#else
	#error INVALID_CA_OUT_WIDTH
#endif

#if CAD_OUT_WIDTH == 8
	#define CAD_OUT_DEPTH 4
#elif CAD_OUT_WIDTH == 4
	#define CAD_OUT_DEPTH 8
#elif CAD_OUT_WIDTH == 2
	#define CAD_OUT_DEPTH 16
#else
	#error INVALID_lk_cad_phy_WIDTH
#endif

//Meaning of bits in vector that identify buffer status
//0 - response data
//1 - response command
//2 - non-posted data
//3 - non-posted command
//4 - posted data
//5 - posted command
#define BUF_STATUS_R_DATA 0
#define BUF_STATUS_R_CMD 1
#define BUF_STATUS_NP_DATA 2
#define BUF_STATUS_NP_CMD 3
#define BUF_STATUS_P_DATA 4
#define BUF_STATUS_P_CMD 5

//Values that can be sent to flow control multiplexer to select output
#define FC_MUX_NOP 0
#define FC_MUX_FWD_LSB 1
#define FC_MUX_FWD_MSB 2
#define FC_MUX_DB_DATA 3
#define FC_MUX_EH 4
#define FC_MUX_CSR 5
#define FC_MUX_UI_LSB 6
#define FC_MUX_UI_MSB 7
#define FC_MUX_UI_DATA 8

#ifdef RETRY_MODE_ENABLED
#define FC_MUX_HISTORY 9
#endif

#define FC_MUX_FEEDBACK 10

#endif
