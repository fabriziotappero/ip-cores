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
//    MacAddress localMac = {0xD3, 0x36, 0x41, 0xC0, 0x00, 0x00};

    char buf[256];

    struct sockaddr_ll my_addr;

    struct ifreq ethreq;

    int if_index;

    //create packet socket from type sock_dgram where headers are automatically thrown out
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

    //bind to interface goten from ioctl SIOCGIFHWADDR directive (otherwise all packets are recved)
    if ( bind( socket_id, (struct sockaddr *) &my_addr, sizeof(my_addr) ) )
    {
        perror("bind");
        exit(1);
    }

    struct sockaddr_ll from;
    int fromlen;

    fromlen = sizeof(from);

    for (;;)
    {
        iRet = recvfrom(socket_id, buf, 256, 0, &from, &fromlen);
        if ( iRet == -1 )
        {
            perror("recvfrom");
            exit(1);
        }
        else
        {
            printf("Received %d bytes of data.\n", iRet);
            printf("This is the received data:\n");
            for ( i = 0; i < iRet; i++)
                printf("Byte %d: %X\n", i, (int)buf[i]);
            printf("End of transmission!\n");
        }
    }

    return 0;
}

