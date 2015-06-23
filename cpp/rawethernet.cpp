// rawethernet.cpp

#include "rawethernet.hpp"

#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <arpa/inet.h>

#include <iostream>
#include <cstring>

using namespace std;

RawEthernet::RawEthernet()
{
	this->protocol = 0x0800;
}

RawEthernet::~RawEthernet()
{
	
}

bool RawEthernet::connect(byte addr[])
{
	struct sockaddr_ll socket_address;
	socket_address.sll_family = AF_PACKET;
	socket_address.sll_protocol = 0;//htons(ETH_P_IP); //0
	socket_address.sll_ifindex = if_nametoindex("eth0");
	socket_address.sll_hatype = 0;//ARPHRD_ETHER; //0
	socket_address.sll_pkttype = 0;//PACKET_OTHERHOST; //0
	socket_address.sll_halen = ETH_ALEN;

	/*MAC - begin*/
	socket_address.sll_addr[0]  = addr[0];
	socket_address.sll_addr[1]  = addr[1];
	socket_address.sll_addr[2]  = addr[2];
	socket_address.sll_addr[3]  = addr[3];
	socket_address.sll_addr[4]  = addr[4];
	socket_address.sll_addr[5]  = addr[5];
	/*MAC - end*/
	socket_address.sll_addr[6]  = 0x00;/*not used*/
	socket_address.sll_addr[7]  = 0x00;/*not used*/
	
	return this->connect(&socket_address);
}

bool RawEthernet::connect(struct sockaddr_ll *socket_address)
{
	this->socketid = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	if (this->socketid < 0)
	{
		cout << "Socket Error!" << endl;
		perror("socket");
		return false;
	}
	memcpy((void*)&(this->socket_address), socket_address, sizeof(struct sockaddr_ll));
	
	if (bind(this->socketid, (struct sockaddr*)socket_address, sizeof(struct sockaddr_ll))<0)
	{
		cout << "Binding Error!" << endl;
		perror("bind");
		return false;
	}
	return true;
}

void RawEthernet::disconnect()
{
	
}

bool RawEthernet::sendData(byte data[], int len)
{
	memcpy((void*)this->buffer, (void*)(this->socket_address.sll_addr), ETH_ALEN);
	memcpy((void*)(this->buffer+ETH_ALEN), (void*)(this->src_mac), ETH_ALEN);
	*((short*)&(this->buffer[ETH_ALEN+ETH_ALEN])) = htons(this->protocol);
	memcpy((void*)(this->buffer+ETH_HLEN), (void*)data, len);
	if (len < ETH_DATA_LEN)
	{
		memset((void*)(this->buffer+ETH_HLEN+len), 0, ETH_DATA_LEN-len);
	}
	int send_result = sendto(this->socketid, this->buffer, ETH_FRAME_LEN, 0,
							(struct sockaddr*)&(this->socket_address), sizeof(struct sockaddr_ll));
	if (send_result == -1)
	{
		cout << "Send Errer!" << endl;
		perror("sendto");
		return false;
	}
	return true;
}

bool RawEthernet::requestData(int len, byte *data)
{
	int length = recvfrom(this->socketid, this->buffer, ETH_FRAME_LEN, 0, NULL, NULL);
	if (length == -1)
	{
		cout << "Receive Error!" << endl;
		perror("recvfrom");
		return false;
	}
	if (ntohs(*((short*)(&this->buffer[12]))) != this->protocol) return false;
	memcpy((void*)data, (void*)(this->buffer+14), len);
	return true;
}

const byte RawEthernet::src_mac[] = {0x0, 0x1b, 0x21, 0x82, 0xaf, 0xad};// len=8
