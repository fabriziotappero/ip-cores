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
#include "system.h"


HPD_rx_stream hpd_rx_streams_0[4] = 
  {
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x200, 0x100, 0x0000400, 0},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x300, 0x100, 0x0000401, 0},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x400, 0x100, 0x0000402, 0},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x500, 0x100, 0x0000403, 0}
  };

HPD_rx_packet hpd_rx_packets_0[4] =
  {
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x600, 0x100, 0x0000404},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x700, 0x100, 0x0000405},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x800, 0x010, 0x0000406},
    {(0x80000000 | SHARED_MEM_2_BASE) + 0x900, 0x100, 0x0000407}
  };



HPD_iface hpd_ifaces[NUM_OF_HIBI_PE_DMAS] = {
  {(0x80000000 | HIBI_PE_DMA_2_BASE), (0x80000000 | SHARED_MEM_2_BASE), 
   0x20, 0x00000001, 2, 4, 4, hpd_rx_streams_0, hpd_rx_packets_0}
};
