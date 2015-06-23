/*
 * @file   hpd_config.c
 * @author Lasse Lehtonen
 * @date   2012-02-17
 *
 * @brief Implements HIBI_PE_DMA interface configuration information
 * structures.
 *  
 */

#include "hpd_config.h"
#include "system.h" /* NIOS specific - for others get the information
                       from somewhere ... */

HPD_rx_stream hpd_rx_streams_0[4] = 
  {
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x200, 0x100, 0x0000000, 0},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x300, 0x018, 0x0000001, 0},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x400, 0x100, 0x0000002, 0},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x500, 0x100, 0x0000003, 0}
  };

HPD_rx_packet hpd_rx_packets_0[4] = 
  {
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x600, 0x100, 0x0000004},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x700, 0x100, 0x0000005},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x800, 0x100, 0x0000006},
    {(0x80000000 | SHARED_MEM_0_BASE) + 0x900, 0x100, 0x0000007}
  };


HPD_iface hpd_ifaces[NUM_OF_HIBI_PE_DMAS] = {
  {(0x80000000 | HIBI_PE_DMA_0_BASE), (0x80000000 | SHARED_MEM_0_BASE), 
   0x200, 0x00000207, 2, 4, 4, hpd_rx_streams_0, hpd_rx_packets_0}
};
