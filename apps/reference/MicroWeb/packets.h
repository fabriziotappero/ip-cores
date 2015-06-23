// Copyright (C) 2002 Mason Kidd (mrkidd@nettaxi.com)
//
// This file is part of MicroWeb.
//
// MicroWeb is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// MicroWeb is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MicroWeb; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

// packets.h: definitions for packet structures

#ifndef H__PACKETS
#define H__PACKETS

#define MAC_ADDR_LEN 6
#define IP_ADDR_LEN 4

struct eth_hdr
{
  unsigned char dhost[MAC_ADDR_LEN];		// destination MAC address
  unsigned char shost[MAC_ADDR_LEN];		// source MAC address
  unsigned int type;				// packet type
};

#define ETHER_IP 0x0800
#define ETHER_ARP 0x0806

struct arp_hdr
{
	unsigned int ar_hrd;		// Hardware Address format
	unsigned int ar_pro;		// Protocol Address format
	unsigned char ar_hln;		// Byte length of each hardware address
	unsigned char ar_pln;		// Byte length of each protocol address
	unsigned int ar_op;		// Opcode 
};

#define ARP_REQUEST 0x01
#define ARP_REPLY 0x02
#define ARP_HRD_ETHER 0x01

struct eth_arp
{
	struct arp_hdr eth_arp_hdr;
	unsigned char ar_sha[MAC_ADDR_LEN];	// Sender's MAC address
	unsigned char ar_spa[4];		// Sender's protocol address
	unsigned char ar_tha[MAC_ADDR_LEN];	// Target's MAC address
	unsigned char ar_tpa[4];		// Target's protocol address
};

struct ip_hdr
{
	unsigned char verIHL;		// version - 4 bits, Internet Header Length - 4 bits
	unsigned char TOS;		// Type of Service - 8 bits
	unsigned int totlen;		// Total Length of the datagram - 16 bits
	unsigned int id;		// Identification of datagram - 16 bits
	unsigned int fragoff;		// Flags - 3 bits, Fragment Offset - 13 bits
	unsigned char TTL;		// Time to Live - 8 bits
	unsigned char proto;		// Protocol - 8 bits
	unsigned int hdrchksum;		// Header Checksum - 16 bits
	unsigned char srcIP[4];		// Source IP Address - 32 bits
	unsigned char destIP[4];	// Destination IP Address - 32 bits
};

#define IP_ICMP 0x0001
#define IP_TCP 0x0006
#define IP_UDP 0x0011

struct icmp_hdr
{
	unsigned char type;
	unsigned char icode;
	unsigned int checksum;
	unsigned int identifier;
	unsigned int sequence;
//	unsigned long icdata;
};

#define ICMP_ECHOREPLY          0       /* Echo Reply                   */
#define ICMP_DEST_UNREACH       3       /* Destination Unreachable      */
#define ICMP_SOURCE_QUENCH      4       /* Source Quench                */
#define ICMP_REDIRECT           5       /* Redirect (change route)      */
#define ICMP_ECHO               8       /* Echo Request                 */
#define ICMP_TIME_EXCEEDED      11      /* Time Exceeded                */
#define ICMP_PARAMETERPROB      12      /* Parameter Problem            */
#define ICMP_TIMESTAMP          13      /* Timestamp Request            */
#define ICMP_TIMESTAMPREPLY     14      /* Timestamp Reply              */
#define ICMP_INFO_REQUEST       15      /* Information Request          */
#define ICMP_INFO_REPLY         16      /* Information Reply            */
#define ICMP_ADDRESS            17      /* Address Mask Request         */
#define ICMP_ADDRESSREPLY       18      /* Address Mask Reply           */

struct udp_hdr
{
	unsigned int src_port;		// Source port, optional
	unsigned int dst_port;		// Destination port
	unsigned int length;		// Length of datagram in bytes, incl. header
	unsigned int checksum;		// Checksum of psuedo-header
};

#define MY_UDP_PORT 0x6969

struct tcp_hdr
{
	unsigned int src_port;		// Source port
	unsigned int dst_port;		// Destination port
	unsigned long seq;			// Sequence number
	unsigned long ack;			// Acknowledgement number
	unsigned char data_off;		// Data offset - upper 4 bits
	unsigned char cntrl_bits;	// Control bits - lower 6 bits
	unsigned int window;		// Window
	unsigned int checksum;		// Checksum
	unsigned int urgent;		// Urgent pointer
	// Options may additionally follow
};

#define BUF_LEN 1500

extern unsigned char myMAC[6];
extern unsigned char myIP[4];
extern unsigned char targetIP[4];
extern unsigned char targetMAC[6];
extern unsigned char srcMAC[6];
extern unsigned char srcIP[4];
extern unsigned char tmpMAC[6];
extern unsigned char tmpIP[4];
extern unsigned char myBCAST[4];
extern int mac_size;
extern int ip_size;

#endif
