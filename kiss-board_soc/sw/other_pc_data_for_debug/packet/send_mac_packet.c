
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/ioctl.h>
//#include <net/if.h>

#include <sys/socket.h>
//#include <netpacket/packet.h>
#include <net/ethernet.h>

#include <linux/if_arp.h>
//#include <linux/if_ether.h>
//#include <netinet/in.h>
//#include <netinet/ip.h>

unsigned char tmp[256];

int main(int argc, char *argv[]){
	int	s;
	struct sockaddr_ll to;
	struct ifreq ifr;

// socket
	{
		s = socket(PF_PACKET,SOCK_DGRAM,htons(1000));
		if(0>s){
			fprintf(stderr, "socket error\n");
			exit(-1);
		}
	}

//
        memset(&ifr,0,sizeof(ifr));
        strncpy(ifr.ifr_name,"eth0",IFNAMSIZ);
        ioctl(s,SIOCGIFINDEX,&ifr);

//
        memset(&to,0,sizeof(to));
        to.sll_family           = AF_PACKET;
        to.sll_protocol         = htons(0x1000);
        to.sll_ifindex          = ifr.ifr_ifindex;
        to.sll_hatype           = ARPHRD_ETHER;
        to.sll_pkttype          = PACKET_HOST;
        to.sll_halen            = ETH_ALEN;
        to.sll_addr[0]          = 0x00;
        to.sll_addr[1]          = 0x22;
        to.sll_addr[2]          = 0x33;
        to.sll_addr[3]          = 0x44;
        to.sll_addr[4]          = 0x55;
        to.sll_addr[5]          = 0x00;
        to.sll_addr[6]          = 0x00;
        to.sll_addr[7]          = 0x00;

// send
	{
		unsigned char buff[256];
		unsigned int i;
		for(i=0;i<256;i++) buff[i]=(unsigned char)i;
		while(1)
		{
			unsigned int count;
			//sleep(1);
			count = sendto(s,buff,256,0,(struct sockaddr *)&to,sizeof(to));
			fprintf(stderr,"send:%d\n",count);
		}
	}
}
