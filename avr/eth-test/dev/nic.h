/*! \file nic.h \brief Network Interface Card (NIC) software definition. */
//*****************************************************************************
//
// File Name	: 'nic.h'
// Title		: Network Interface Card (NIC) software definition
// Author		: Pascal Stang
// Created		: 8/22/2004
// Revised		: 7/3/2005
// Version		: 0.1
// Target MCU	: Atmel AVR series
// Editor Tabs	: 4
//
///	\ingroup network
/// \defgroup nic Network Interface Card (NIC) software definition (nic.h)
///	\code #include "net/nic.h" \endcode
///	\par Description
///		This is the software interface standard for network interface hardware
///		as used by AVRlib.  Drivers for network hardware must implement these
///		functions to allow upper network layers to initialize the interface,
///		and send and receive net traffic.
//
//	This code is distributed under the GNU Public License
//		which can be found at http://www.gnu.org/licenses/gpl.txt
//*****************************************************************************
//@{

#ifndef NIC_H
#define NIC_H

#include <inttypes.h>

//! Initialize network interface hardware.
/// Reset and bring up network interface hardware. This function should leave
/// the network interface ready to handle \c nicSend() and \c nicPoll() requests.
/// \note For some hardware, this command will take a non-negligible amount of
/// time (1-2 seconds).
void nicInit(void);

//! Send packet on network interface.
/// Function accepts the length (in bytes) of the data to be sent, and a pointer
///	to the data.  This send command may assume an ethernet-like 802.3 header is at the
/// beginning of the packet, and contains the packet addressing information.
///	See net.h documentation for ethernet header format.
void nicSend(unsigned int len, unsigned char* packet);

//! Check network interface; return next received packet if avaialable.
/// Function accepts the maximum allowable packet length (in bytes), and a
///	pointer to the received packet buffer.  Return value is the length
///	(in bytes) of the packet recevied, or zero if no packet is available.
/// Upper network layers may assume that an ethernet-like 802.3 header is at
/// the beginning of the packet, and contains the packet addressing information.
/// See net.h documentation for ethernet header format.
unsigned int nicPoll(unsigned int maxlen, unsigned char* packet);

//! Return the 48-bit hardware node (MAC) address of this network interface.
///	This function can return a MAC address read from the NIC hardware, if available.
///	If the hardware does not provide a MAC address, a software-defined address may be
///	returned.  It may be acceptable to return an address that is less than 48-bits.
void nicGetMacAddress(uint8_t* macaddr);

//! Set the 48-bit hardware node (MAC) address of this network interface.
///	This function may not be supported on all hardware.
void nicSetMacAddress(uint8_t* macaddr);

//! Print network interface hardware registers.
/// Prints a formatted list of names and values of NIC registers for debugging
/// purposes.
inline void nicRegDump(void);

#endif
//@}
