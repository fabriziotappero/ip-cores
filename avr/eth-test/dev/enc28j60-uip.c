#include "enc28j60.h"
#include <avr/io.h>
#include <util/delay.h>
#include "../uip/uipopt.h"
#include "../uip/uip.h"

/*
* This is the interface between the ENC28J60 driver and the uIP TCP/IP stack.
* The code was lifted from http://code.google.com/p/avr-uip/
*/

unsigned int network_read(void){
	uint16_t len;
	len=enc28j60PacketReceive(UIP_BUFSIZE, (uint8_t *)uip_buf);
	return len;
}

void network_send(void){
	if(uip_len <= UIP_LLH_LEN + 40){
		enc28j60PacketSendTwo(uip_len, (uint8_t *)uip_buf, 0, 0);
	}else{
		enc28j60PacketSendTwo(54, (uint8_t *)uip_buf , uip_len - UIP_LLH_LEN - 40, (uint8_t*)uip_appdata);
	}
}

void network_init(void)
{
	//Initialise the device
	enc28j60Init();

	//Configure leds
	enc28j60PhyWrite(PHLCON,0x476);
}

void network_get_MAC(uint8_t* macaddr)
{
	// read MAC address registers
	// NOTE: MAC address in ENC28J60 is byte-backward
	*macaddr++ = enc28j60Read(MAADR5);
	*macaddr++ = enc28j60Read(MAADR4);
	*macaddr++ = enc28j60Read(MAADR3);
	*macaddr++ = enc28j60Read(MAADR2);
	*macaddr++ = enc28j60Read(MAADR1);
	*macaddr++ = enc28j60Read(MAADR0);
}

void network_set_MAC(uint8_t* macaddr)
{
	// write MAC address
	// NOTE: MAC address in ENC28J60 is byte-backward
	enc28j60Write(MAADR5, *macaddr++);
	enc28j60Write(MAADR4, *macaddr++);
	enc28j60Write(MAADR3, *macaddr++);
	enc28j60Write(MAADR2, *macaddr++);
	enc28j60Write(MAADR1, *macaddr++);
	enc28j60Write(MAADR0, *macaddr++);
}

