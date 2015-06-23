// rawethernet.hpp

#ifndef RAWETHERNET_HPP
#define RAWETHERNET_HPP

#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>

typedef unsigned char byte;

class RawEthernet
{
private:
	byte buffer[1514];
	static const byte src_mac[];
	int socketid;
	struct sockaddr_ll socket_address;
	
public:
	RawEthernet ();
	~RawEthernet ();
	bool connect(byte addr[]);
	bool connect(struct sockaddr_ll *socket_address);
	void disconnect(void);
	bool sendData(byte data[], int len);
	bool requestData(int len, byte *data);
	short protocol;
};

#endif
