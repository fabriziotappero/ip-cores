#include <stdio.h>

#include <string.h>

//packet socket
#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>

//protocol
#include <linux/if_ether.h>

//netdevice stuff
#include <sys/ioctl.h>
#include <net/if.h>

//file open stuff
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

//arp stuff
//#include <linux/if_arp.h>

#define MAC_ADDR_LEN 6
typedef unsigned char MacAddress[MAC_ADDR_LEN];

int main()
{
    int socket_id, new_sock, iRet = -1;
    int addrlen, bytesread, nfound =0;

    int i = 0;

    MacAddress localMac = {0x00, 0x00, 0xC0, 0x41, 0x36, 0xD3};
    MacAddress extMac = {0x55, 0x47, 0x34, 0x22, 0x88, 0x92};
//    MacAddress extMac = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    char buf[256];

    struct sockaddr_ll my_addr;

    struct ifreq ethreq;

    int if_index;

    if ( ( socket_id = socket(PF_PACKET, SOCK_DGRAM, htons(ETH_P_ALL) ) ) < 0  )
    {
        perror("socket");
        exit(1);
    }
    else
    {
        printf("Socket has been created: socket_number %d\n", socket_id);
    }


    //GET ethreq for if "eth1"
    strncpy(ethreq.ifr_name,"eth1",IFNAMSIZ);
    ioctl(socket_id, SIOCGIFFLAGS, &ethreq);
    //SET promisc mode for if ethreq
//    ethreq.ifr_flags |= IFF_PROMISC;
//    ioctl(socket_id, SIOCSIFFLAGS, &ethreq);
    //request index
    ioctl(socket_id, SIOCGIFINDEX, &ethreq);
    if_index = ethreq.ifr_ifindex;

    printf("This is the index of the interface: %d\n", if_index );

    memset(&my_addr, '0', sizeof(my_addr) );

    my_addr.sll_family = AF_PACKET;
    my_addr.sll_protocol = htons(ETH_P_ALL);  //defaults to socket protocol
    my_addr.sll_ifindex = if_index;
//    my_addr.sll_hatype = htons(ARPHRD_ETHER);
//    my_addr.sll_pkttype = PACKET_OTHERHOST;
    my_addr.sll_halen = 6;
    memcpy( &(my_addr.sll_addr), localMac, MAC_ADDR_LEN );

     //request hw_addres
    ioctl(socket_id, SIOCGIFHWADDR, &ethreq);
 
    printf("This is the address of my card: %d\n", my_addr.sll_addr[5] );

    if ( bind( socket_id, (struct sockaddr *) &my_addr, sizeof(my_addr) ) )
    {
        perror("bind");
        exit(1);
    }

    struct sockaddr_ll addr_to;
    int addr_toLen;

    addr_toLen = sizeof(addr_to);

    memset(&addr_to, '0', sizeof(addr_to) );

    addr_to.sll_family = AF_PACKET;
    addr_to.sll_ifindex = if_index;
    addr_to.sll_halen = 6;
    memcpy( &(addr_to.sll_addr), extMac, MAC_ADDR_LEN );

    for (i=0; i<256 ; i++ )
	    buf[i] = 0;

    //first 2 bytes are gathered with length and are ignored
    buf[0] = 0xAA;
    buf[1] = 0xAA;
    //now it gets to fpga: send opcode 0xBA8
    buf[2] = 0xBA;
    buf[3] = 0x87;
    //opcode sent
    buf[4] = 0xAA;
    buf[5] = 0xAA;
    buf[6] = 0xAA;
    buf[7] = 0xAA;
    buf[8] = 0xAA;
    buf[9] = 0xAA;
    buf[10] = 0xAA;
    buf[11] = 0xAA;

//    for (;;)
//    {
        iRet = sendto(socket_id, buf, 46, 0, (struct sockaddr *) &addr_to, addr_toLen);
        if ( iRet == -1 )
        {
            perror("sendto");
            exit(1);
        }
        else
        {
//            printf("%s\n", buf);
              printf("Data sent!\nExiting...\n");
        }
//    }

    return 0;
}

