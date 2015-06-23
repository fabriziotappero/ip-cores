// **************************************************************************
// File             : sdram_drv.h
// Authors          : Antti Kojo
// Date             : 12.06.2009
// Decription       : SDRAM contoller driver for eCos
// Version history  : 12.06.2009    ank    Original version
// **************************************************************************

#ifndef SDRAM_H
#define SDRAM_H

#include "types.h"

/* CPU uses these HIBI addresses when receiving mem_ctrl_offset or data from
   SDRAM. Offset is added to CPU's HIBI base address. */
#define HIBI_ADDRESS_OFFSET_FOR_SDRAM  (0x600)
#define SDRAM_CONF_CHANNEL_ADDR        (HIBI_ADDRESS_OFFSET_FOR_SDRAM + 1)
#define SDRAM_DATA_CHANNEL_ADDR        (HIBI_ADDRESS_OFFSET_FOR_SDRAM + 2)

/* parameters used with configuration function */
#define SDRAM_READ_OPERATION           (0)
#define SDRAM_WRITE_OPERATION          (1)


/* Call this init-function before using other functions. */
void sdram_init(const uint32 sdram_hibi_addr);






/* This function, sdram_config, configures SDRAM controller 
   for read and write operations. 
 
 * Parameters:
 
   sdram_byte_addr:      SDRAM byte address for read and write operations
 
   words:                Amount of words to read/write

   operation:            Use parameter SDRAM_WRITE_OPERATION when writing and 
                         SDRAM_READ_OPERATION when reading.
   
   read_chn_addr:        In case of read operation, data from SDRAM will be
                         written to this hibi address. In case of write
                         operation, this parameter is not used.
  
   row_count_and_stride: This parameter is used when reading/writing
                         rectangular memory areas.

 
 * Return:
 
   In case of write operation, this function returns HIBI address where 
   the data should be written.
  
*/
uint32 sdram_config( const uint32 sdram_byte_addr,
		     const uint32 words,
		     const uint8  operation,
		     const uint32 read_chn_addr,
		     const uint32 row_count_and_stride );




/* This function, sdram_write, writes data to SDRAM 
  
 * Parameters:
  
   src:           Pointer to source data 
   sdram_addr:    SDRAM target address
   words:         Amount of data words

*/
bool sdram_write( uint32* const src, 
		  const uint32 sdram_addr,
		  const uint32 words );






/* This function, sdram_read, reads data from SDRAM.
   This is non-blocking read. After function returns,
   reading from SDRAM is in progress. User of this
   function has to declare sdram_rx_end-function
   which is called after data has been received.
 
 * Parameters:
  
   sdram_addr:    SDRAM source address
   words:         Amount of data words

*/
void sdram_read( const uint32 sdram_addr,
		 const uint32 words );



#endif



