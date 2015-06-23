// fcpprotocol.hpp

#ifndef FCPPROTOCOL_HPP
#define FCPPROTOCOL_HPP

#include "rawethernet.hpp"

typedef unsigned char byte;

// FCP Commands
#define FCP_DATA_SND		0
#define FCP_ACK			1
#define FCP_CONNECT		2
#define FCP_CON_ACK		3
#define FCP_DATA_REQ		4
#define FCP_DATA_ACK		5

class FCPProtocol
{
private:
	int snd_cur;
	int last_ack;
	RawEthernet *enet;
	byte ip[4];
	void wrapFCPUDPIP(byte *buffer, byte *data);
	static const byte packet_con[];
	static const byte ip_header[];
	static const byte udp_header[];
	byte buffer[1500];
	byte sendbuf[1500];
	void insertIPChecksum();
	bool receiveFcpUdpIp(int len, byte *data);
	
public:
	FCPProtocol ();
	~FCPProtocol ();
	bool connect(byte mac[], byte ip[]);
	void disconnect(void);
	bool sendData(int channel, byte data[], int len);
	bool requestData(int channel, int len, byte *data);
	bool connected();
	void wrapFcpUdpIp(byte command, int channel, byte *data, int len);
};

#endif
