#include "testmod.h"
#include "../greth/greth_api.h"

#define SRC_MAC0  0xDE
#define SRC_MAC1  0xAD
#define SRC_MAC2  0xBE
#define SRC_MAC3  0xEF
#define SRC_MAC4  0x00
#define SRC_MAC5  0x20 

static int snoopen;

static inline int load(int addr)
{
    int tmp;        
    asm(" lda [%1]1, %0 "
        : "=r"(tmp)
        : "r"(addr)
        );
    return tmp;
}

static inline char loadb(int addr)
{
  char tmp;        
  asm volatile (" lduba [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}

struct greth_info greth;


static void build_arp(unsigned int source_addr_msb, 
                      unsigned int source_addr_lsb, 
                      unsigned int sender_ip, 
                      unsigned int target_ip, 
                      unsigned char *buf,          
                      unsigned int *len) 
{
        *len = 42;
        buf[0] = 0xFF;
        buf[1] = 0xFF;
        buf[2] = 0xFF;
        buf[3] = 0xFF;
        buf[4] = 0xFF;
        buf[5] = 0xFF;
        buf[6] = (source_addr_msb >> 16) & 0xFF;
        buf[7] = (source_addr_msb >> 8) & 0xFF;
        buf[8] = source_addr_msb & 0xFF;
        buf[9] = (source_addr_lsb >> 16) & 0xFF;
        buf[10] = (source_addr_lsb >> 8) & 0xFF;
        buf[11] = source_addr_lsb & 0xFF;
        buf[12] = 0x08;
        buf[13] = 0x06;
        buf[14] = 0x00;
        buf[15] = 0x01;
        buf[16] = 0x08;
        buf[17] = 0x00;
        buf[18] = 0x06;
        buf[19] = 0x04;
        buf[20] = 0x00;
        buf[21] = 0x01;
        buf[22] = (source_addr_msb >> 16) & 0xFF;
        buf[23] = (source_addr_msb >> 8) & 0xFF;
        buf[24] = source_addr_msb & 0xFF;
        buf[25] = (source_addr_lsb >> 16) & 0xFF;
        buf[26] = (source_addr_lsb >> 8) & 0xFF;
        buf[27] = source_addr_lsb & 0xFF;
        buf[28] = (sender_ip >> 24) & 0xFF;
        buf[29] = (sender_ip >> 16) & 0xFF;
        buf[30] = (sender_ip >> 8) & 0xFF;
        buf[31] = (sender_ip) & 0xFF;
        buf[32] = 0;
        buf[33] = 0;
        buf[34] = 0;
        buf[35] = 0;
        buf[36] = 0;
        buf[37] = 0;
        buf[38] = (target_ip >> 24) & 0xFF;
        buf[39] = (target_ip >> 16) & 0xFF;
        buf[40] = (target_ip >> 8) & 0xFF;
        buf[41] = (target_ip) & 0xFF;

}

static void build_ip(
        unsigned int dest_addr_msb, 
        unsigned int dest_addr_lsb, 
        unsigned int source_addr_msb, 
        unsigned int source_addr_lsb, 
        unsigned int dest_ip, 
        unsigned int source_ip, 
        unsigned int rw,
        unsigned int seq, 
        unsigned int addr, 
        unsigned int dlen, 
        unsigned char *data,
        unsigned char *buf,
        unsigned int *len) 
{
        int i;
        int iplen;
        int udplen;
        int edclctrl;
        unsigned int crc;
        iplen = 38+dlen;
        udplen = 18+dlen;
        *len = 52+dlen;
        buf[0] = (dest_addr_msb >> 16) & 0xFF;
        buf[1] = (dest_addr_msb >> 8) & 0xFF;
        buf[2] = dest_addr_msb & 0xFF;
        buf[3] = (dest_addr_lsb >> 16) & 0xFF;
        buf[4] = (dest_addr_lsb >> 8) & 0xFF;
        buf[5] = dest_addr_lsb & 0xFF;
        buf[6] = (source_addr_msb >> 16) & 0xFF;
        buf[7] = (source_addr_msb >> 8) & 0xFF;
        buf[8] = source_addr_msb & 0xFF;
        buf[9] = (source_addr_lsb >> 16) & 0xFF;
        buf[10] = (source_addr_lsb >> 8) & 0xFF;
        buf[11] = source_addr_lsb & 0xFF;
        buf[12] = 0x08;
        buf[13] = 0x00;
        buf[14] = 0x45;
        buf[15] = 0x00;
        buf[16] = (iplen >> 8) & 0xFF;
        buf[17] = iplen & 0xFF;
        buf[18] = 0;
        buf[19] = 0;
        buf[20] = 0;
        buf[21] = 0;
        buf[22] = 0x40;
        buf[23] = 0x11;
        buf[26] = (source_ip >> 24) & 0xFF;
        buf[27] = (source_ip >> 16) & 0xFF;
        buf[28] = (source_ip >> 8) & 0xFF;
        buf[29] = (source_ip) & 0xFF;
        buf[30] = (dest_ip >> 24) & 0xFF;
        buf[31] = (dest_ip >> 16) & 0xFF;
        buf[32] = (dest_ip >> 8) & 0xFF;
        buf[33] = (dest_ip) & 0xFF;
        buf[34] = 0;
        buf[35] = 0;
        buf[36] = 0;
        buf[37] = 0;
        crc = 0x8511;
        crc = crc + (iplen & 0xFFFF);
        crc = crc + (source_ip >> 16) & 0xFFFF;
        crc = crc + source_ip & 0xFFFF;
        crc = crc + (dest_ip >> 16) & 0xFFFF;
        crc = crc + dest_ip & 0xFFFF;
        crc = (crc & 0xFFFF) + ((crc >> 16) & 0xFFFF);
        crc = (crc & 0xFFFF) + ((crc >> 16) & 0xFFFF);
        buf[24] = (crc >> 8) & 0xFF;
        buf[25] = crc & 0xFF;
        buf[38] = (udplen >> 8) & 0xFF;
        buf[39] = udplen & 0xFF;
        buf[40] = 0;
        buf[41] = 0;
        buf[42] = 0;
        buf[43] = 0;
        edclctrl = ((seq & 0x3FFF) << 18) | (rw << 17) | ((dlen & 0x3FF) << 7);
        buf[44] = (edclctrl >> 24) & 0xFF;
        buf[45] = (edclctrl >> 16) & 0xFF;
        buf[46] = (edclctrl >> 8) & 0xFF;
        buf[47] = edclctrl & 0xFF;
        buf[48] = (addr >> 24) & 0xFF;
        buf[49] = (addr >> 16) & 0xFF;
        buf[50] = (addr >> 8) & 0xFF;
        buf[51] = addr & 0xFF;
        if (rw) {
                for(i = 0; i < dlen; i++) {
                        buf[52+i] = data[i];
                }
        }
        
}

int greth_test(int apbaddr)
{
        int tmp, i;
        int *len;
        unsigned char tmp2;
        unsigned char txbuf[256];
        unsigned char rxbuf[256];
        unsigned char wrarea[100];
        unsigned char *buf;
        struct rxstatus *rxs = malloc(sizeof(struct rxstatus));
        
        unsigned int ipaddr;
        unsigned int emac_addr_msb;
        unsigned int emac_addr_lsb;
        int seq;
        
        len = malloc(sizeof(int));
        
        /* initialize */
        report_device(0x0101D000);
        greth.regs = (greth_regs *) apbaddr;
        greth.esa[0] = SRC_MAC0;
        greth.esa[1] = SRC_MAC1;
        greth.esa[2] = SRC_MAC2;
        greth.esa[3] = SRC_MAC3;
        greth.esa[4] = SRC_MAC4;
        greth.esa[5] = SRC_MAC5;
        greth_init(&greth);
        
        /* Put phy in loopback*/
        tmp = read_mii(greth.phyaddr, 0, greth.regs);
        
        if (tmp < 0) {
                /* Error in MDIO interface access */ 
                fail(0);
        }
        write_mii(greth.phyaddr, 0, tmp | (1 << 14), greth.regs);
        
        /* Dest. addr */
        txbuf[0] = SRC_MAC0;
        txbuf[1] = SRC_MAC1;
        txbuf[2] = SRC_MAC2;
        txbuf[3] = SRC_MAC3;
        txbuf[4] = SRC_MAC4;
        txbuf[5] = SRC_MAC5;
        
        /* Source addr */
        txbuf[6]  = SRC_MAC0;
        txbuf[7]  = SRC_MAC1;
        txbuf[8]  = SRC_MAC2;
        txbuf[9]  = SRC_MAC3;
        txbuf[10] = SRC_MAC4;
        txbuf[11] = SRC_MAC5;
        
        /* Length 242 (total length 256 incl. address, type) */
        txbuf[12] = 0x00;
        txbuf[13] = 0xF2;
        
        for (i = 14; i < 256; i++) {
                txbuf[i] = (i % 256);
        }
        
        while(!greth_rx(rxbuf, &greth));
              
        while(!greth_tx(256, txbuf, &greth));
        
        while(!greth_checkrx(len, rxs, &greth));
        
        if (*len != 256) {
                /* packet of incorrect length received */
                fail(1);
        }
        for (i = 0; i < 256; i++) {
                if ((i % 4) == 0) {
                        tmp = load((int)&rxbuf[i]);
                }
                switch(i % 4) {
                        case 0: tmp2 = (unsigned char)((tmp >> 24) & 0xFF);
                                break;
                        case 1: tmp2 = (unsigned char)((tmp >> 16) & 0xFF);
                                break;
                        case 2: tmp2 = (unsigned char)((tmp >> 8) & 0xFF);
                                break; 
                        case 3: tmp2 = (unsigned char)(tmp & 0xFF);
                                break;       
                }
                if (tmp2 != txbuf[i]) {
                        fail(2);
                }
        }
        /* Test EDCL if present */
        if (greth.edcl) {
                /* read ip address */ 
                ipaddr = load((int)&greth.regs->edclip);
                
                buf = malloc(256);
                /* send arp packet to acquire edcl mac address */
                build_arp(0xDEADBE, 0xEF0020, 0xC0A80016, ipaddr, buf, len);
                
                while(!greth_rx(rxbuf, &greth));
                while(!greth_tx(*len, buf, &greth));
                while(!greth_checkrx(len, rxs, &greth));
                
                emac_addr_msb = ((loadb((int)&rxbuf[22]) & 0xFF) << 16) | ((loadb((int)&rxbuf[23]) & 0xFF) << 8) | (loadb((int)&rxbuf[24]) & 0xFF);
                emac_addr_lsb = ((loadb((int)&rxbuf[25]) & 0xFF) << 16) | ((loadb((int)&rxbuf[26]) & 0xFF) << 8) | (loadb((int)&rxbuf[27]) & 0xFF);
                
                /* send zero length read to acquire sequence number */
                build_ip(emac_addr_msb, emac_addr_lsb, 0xDEADBE, 0xEF0020, ipaddr,
                         0xC0A80016, 0, 0, (unsigned int)wrarea, 0, (unsigned char *)0, buf, len);
        
                while(!greth_rx(rxbuf, &greth));
                while(!greth_tx(*len, buf, &greth));
                while(!greth_checkrx(len, rxs, &greth));
                
                tmp = ((loadb((int)&rxbuf[44]) & 0xFF) << 24) | ((loadb((int)&rxbuf[45]) & 0xFF) << 16) | ((loadb((int)&rxbuf[46]) & 0xFF) << 8) | (loadb((int)&rxbuf[47]) & 0xFF);
                
                if ((tmp >> 17) & 1) {
                        seq = (tmp >> 18) & 0x3FFF;
                } else {
                        seq = ((tmp >> 18) & 0x3FFF) + 1;
                }
                
                /* write 72 bytes to memory */
                build_ip(emac_addr_msb, emac_addr_lsb, 0xDEADBE, 0xEF0020, ipaddr,
                         0xC0A80016, 1, seq, (unsigned int)wrarea, 72, txbuf, buf, len);

                while(!greth_rx(rxbuf, &greth));
                while(!greth_tx(*len, buf, &greth));
                while(!greth_checkrx(len, rxs, &greth));
                
                if ((loadb((int)&rxbuf[45]) >> 1) & 1) { 
                        /* unexpected nak */
                        fail(3);
                }
                seq = seq + 1;
                
                /* read back 72 bytes */
                build_ip(emac_addr_msb, emac_addr_lsb, 0xDEADBE, 0xEF0020, ipaddr,
                         0xC0A80016, 0, seq, (unsigned int)wrarea, 72, (unsigned char *)0, buf, len);
                
                while(!greth_rx(rxbuf, &greth));
                while(!greth_tx(*len, buf, &greth));
                while(!greth_checkrx(len, rxs, &greth));
                
                if (*len != 124) {
                        /* unexpected length of reply packet */
                        fail(4);
                }
                for(i = 0; i < 72; i++) {
                        if ((i % 4) == 0) {
                                tmp = load((int)&rxbuf[52+i]);
                        }
                        switch(i % 4) {
                                case 0: tmp2 = (unsigned char)((tmp >> 24) & 0xFF);
                                        break;
                                case 1: tmp2 = (unsigned char)((tmp >> 16) & 0xFF);
                                        break;
                                case 2: tmp2 = (unsigned char)((tmp >> 8) & 0xFF);
                                        break; 
                                case 3: tmp2 = (unsigned char)(tmp & 0xFF);
                                        break;       
                        }
                        if (tmp2 != txbuf[i]) {
                                fail(5);
                        }
                        
                }
                free(buf);
        }
        
        return 0;
        
}

