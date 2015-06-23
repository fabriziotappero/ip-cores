/*
 * GMAC Software Loop Back.
 * Software continously check the Rx Q counter, If the RX Q counter is not zero,
 * Then it read the Rx descriptor and copy the information back to tx descriptor
 */

/*---------------------------------------------------------------------------*/

#include <8051.h>

char cErrCnt;
/*---------------------------------------------------------------------------*/

__xdata __at (0xA030) unsigned int read_data;
__xdata unsigned long *rx_des_base;
__xdata unsigned long *tx_des_base;

void main() {
    
    unsigned int cFrameCnt = 0;
    unsigned int desc_ptr   =0;

    while(1) {
       if((read_data & 0xF) != 0) { // Check the Rx Q Counter
          // Read the Receive Descriptor
          // tb_top.cpu_read('h4,{desc_rx_qbase,desc_ptr},read_data); 
          // Write the Tx Descriptor
          rx_des_base = (__xdata unsigned long *) (0x7000 | desc_ptr);
          tx_des_base = (__xdata unsigned long *) (0x7040 | desc_ptr);
          //rx_des_base = (__xdata unsigned int *) (0x7000+desc_ptr);
          //tx_des_base = (__xdata unsigned int *) (0x7040+desc_ptr);
          //__xdata (int *) (0x7040+desc_ptr) = __xdata (int *)(0x7000+desc_ptr);
          // tb_top.cpu_write('h4,{desc_tx_qbase,desc_ptr},read_data); 
          *tx_des_base = *rx_des_base;
          desc_ptr = (desc_ptr+4) & 0x3F;
          cFrameCnt  = cFrameCnt+1;
         }
    }
}
