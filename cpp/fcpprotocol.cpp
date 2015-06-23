// fcpprotocol.cpp

#include "fcpprotocol.hpp"
#include "rawethernet.hpp"

#include <iostream>
#include <cstring>
#include <arpa/inet.h>

using namespace std;

FCPProtocol::FCPProtocol()
{
	this->snd_cur = 0;
	this->last_ack = 0;
	this->enet = new RawEthernet();
}

FCPProtocol::~FCPProtocol()
{
	delete this->enet;
}

bool FCPProtocol::connect(byte mac[], byte ip[])
{
	if (!this->enet->connect(mac)) return false;
	memcpy((void*)this->ip, (void*)ip, 4);
	// send connection request
	memcpy((void*)this->buffer, (void*)this->packet_con, 34);
	memcpy((void*)(this->buffer+16), (void*)ip, 4);
	if (!this->enet->sendData(this->buffer, 34)) return false;
	// receive conack
	if (!this->receiveFcpUdpIp(1500, this->buffer)) return false;
	if (this->buffer[28] != (byte)0x1) return false;
	memcpy((void*)(this->sendbuf+16), (void*)this->ip, 4);
	this->snd_cur = 1;
	this->last_ack = 0;
	return true;
}

void FCPProtocol::disconnect()
{
	this->enet->disconnect();
	this->snd_cur = 0;
	this->last_ack = 0;
}

bool FCPProtocol::sendData(int channel, byte data[], int len)
{
	// wrap in packet
	this->wrapFcpUdpIp(FCP_DATA_SND, channel, data, len);
	// send packet
	if (!this->enet->sendData(this->buffer, len+34)) return false;
	// receive ack
	if (!this->receiveFcpUdpIp(1500, this->buffer)) return false;
	int seq = (int) ntohs(*((short*)&this->buffer[30]));
	if ((seq != this->snd_cur) || (this->buffer[28] != 1)) return false;
	this->last_ack = seq;
	this->snd_cur = seq+1;
	//this->snd_cur++;
	return true;
}

bool FCPProtocol::requestData(int channel, int len, byte *data)
{
	// send data request
	wrapFcpUdpIp(FCP_DATA_REQ, channel, NULL, len);
	if (!this->enet->sendData(this->buffer, 34)) return false;
	// receive data response
	if (!this->receiveFcpUdpIp(1500, this->buffer)) return false;
	int seq = (int) ntohs(*((short*)&this->buffer[30]));
	if ((seq != this->snd_cur) || (this->buffer[28] != 5)) return false;
	this->last_ack = seq;
	this->snd_cur = seq+1;
	memcpy((void*)data, (void*)(&this->buffer[34]), len);
	return true;
}

bool FCPProtocol::connected()
{
	return (this->snd_cur > 0);
}

void FCPProtocol::wrapFcpUdpIp(byte command, int channel, byte *data, int len)
{
	memcpy((void*)(this->buffer), (void*)this->ip_header, 20);
	memcpy((void*)(this->buffer+16), (void*)ip, 4);
	*((short*)&buffer[2]) = htons(34+len);
	//*** insert IP header checksum
	memcpy((void*)(this->buffer+20), (void*)this->udp_header, 8);
	*((short*)&buffer[24]) = htons(len+14);
	buffer[26] = 0;
	buffer[27] = 0;
	buffer[28] = command;
	buffer[29] = (byte)channel;
	*((short*)&(this->buffer[30])) = htons(this->snd_cur);
	*((short*)&(this->buffer[32])) = htons(len);
	if (len > 0 && data != NULL)
		memcpy((void*)(this->buffer+34), (void*)data, len);
	this->insertIPChecksum();
}

void FCPProtocol::insertIPChecksum()
{
	int sum = 0;
	short* buf = (short*)this->buffer;
	for (int i=0; i<20; i++)
	{
		sum += (int) ntohs(buf[i]);
		if (sum > 0xffff)
		{
			sum = (sum & 0xffff) + 1;
		}
	}
	buf[5] = ~htons((short)sum&0xffff);
}

bool FCPProtocol::receiveFcpUdpIp(int len, byte *data)
{
	for (int i=0; i<20; i++)
	{
		if (!this->enet->requestData(len, data)) return false;
		if (data[9] != 0x11) continue;
		if (ntohs(*((short*)(data+20))) != 0x3001) continue;
		if (ntohs(*((short*)(data+22))) != 0x3000) continue;
		return true;
	}
	return false;
}

const byte FCPProtocol::packet_con[] = {//0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
								0x45, 0, 0, 34/*len*/, 0, 0, 0, 0, 0x80, 0x11, 0, 0, 0xc0, 0xa8, 1, 0x66, 0, 0, 0, 0,
								0x30, 0, 0x30, 1, 0, 0x0e, 0, 0, 
								0x02, 0, 0, 0, 0, 0};// len=34
const byte FCPProtocol::ip_header[] = {0x45, 0, 0, 34, 0, 0, 0, 0, 0x80, 0x11, 0, 0, 0xc0, 0xa8, 1, 0x66, 0, 0, 0, 0};// len=20
const byte FCPProtocol::udp_header[] = {0x30, 0, 0x30, 1, 0, 0x06, 0, 0};// len=8
