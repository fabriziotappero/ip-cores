// **************************************************************************
// File             : sdram_drv.c
// Authors          : Antti Kojo
// Date             : 12.06.2009
// Decription       : SDRAM contoller driver for eCos
// Version history  : 12.06.2009    ank    Original version
// **************************************************************************

#include <cyg/kernel/kapi.h>
#include <cyg/hal/hal_intr.h>
#include <assert.h>
#include "tut_n2h_regs.h"
#include "sdram_drv.h"
#include "N2H_registers_and_macros.h"
#include "types.h"
#include "comm.h"

#define SDRAM_CONFIG_SENDBUF_SIZE      (4)
#define SDRAM_READ_CONFIG_WORDS        (4)
#define SDRAM_WRITE_CONFIG_WORDS       (3)

/* config word positions */
#define SDRAM_ADDR_CONFIG              (0)
#define DATA_AMOUNT_CONFIG             (1)
#define RCV_HIBI_ADDR_CONFIG           (2)

/* This function must be provided by the application.
   Function is called when data has been received. */
extern void sdram_rx_end(uint32* data, uint32 data_length);


/* Semaphore for SDRAM configuration */
cyg_sem_t sdram_conf_sem;

// CPU's base address
static uint32 own_hibi_base_address;
static uint32 mem_ctrl_offset;
static uint32 sdram_hibi_address;

// channels for receiving data from SDRAM
struct sN2H_ChannelInfo* sdram_conf_channel;
struct sN2H_ChannelInfo* sdram_data_channel;

/* This function is called after interrupt when mem_ctrl_offset 
   or data has been received from SDRAM */
void sdram_rx_handler(uint32* data, uint32 data_length, uint32 received_address) {

    if( received_address == own_hibi_base_address + SDRAM_CONF_CHANNEL_ADDR ) {
	
	mem_ctrl_offset = data[0];
	cyg_semaphore_post(&sdram_conf_sem);

    } else if ( received_address == own_hibi_base_address + SDRAM_DATA_CHANNEL_ADDR ) {

	sdram_rx_end( data, data_length/AMOUNT_UNIT_IN_BYTES );
    }
}


/* Init semaphore and reserve N2H channels for HIBI addresses */
void sdram_init(const uint32 sdram_hibi_addr) {
    
    printf("[sdram] Initializing..\n");
    sdram_hibi_address = sdram_hibi_addr;
    cyg_semaphore_init(&sdram_conf_sem, 0);
    own_hibi_base_address = GetHibiBaseAddr();
    
    sdram_conf_channel = N2H_ReserveChannel(AMOUNT_UNIT_IN_BYTES, sdram_rx_handler, 
					    false, false, SDRAM_CONF_CHANNEL_ADDR);

    sdram_data_channel = N2H_ReserveChannel(AMOUNT_UNIT_IN_BYTES, sdram_rx_handler, 
					    false, false, SDRAM_DATA_CHANNEL_ADDR);
    
    printf("[sdram] Initialization done!\n");
}


/* Send configuration words to SDRAM controller. */
uint32 sdram_config( const uint32 sdram_byte_addr,
		     const uint32 words,
		     const uint8  operation,
		     const uint32 read_chn_addr,
		     const uint32 row_count_and_stride) {

    const uint32 sdram_word_addr = ( sdram_byte_addr / AMOUNT_UNIT_IN_BYTES );

    uint32 cnf_addr;
    uint32 snd_amount;
    uint32 sendbuf[ SDRAM_CONFIG_SENDBUF_SIZE ];

    /* Adapt to read/write request */
    cnf_addr = sdram_hibi_address;
    if( operation == SDRAM_WRITE_OPERATION ) {

	cnf_addr = sdram_hibi_address + 1;
    }
    
    do {

	/* Send request (own hibi address) */
	sendbuf[ 0 ] = (own_hibi_base_address+SDRAM_CONF_CHANNEL_ADDR);
	HIBI_TX((uint8*)sendbuf, AMOUNT_UNIT_IN_BYTES, cnf_addr, HIBI_TRANSFER_TYPE_MESSAGE);
	
	/* Wait for an answer (interrupt) */
	cyg_semaphore_wait(&sdram_conf_sem);

    } while( mem_ctrl_offset == 0 ); /* Keep sending requests until we get 
				        legal mem_ctrl_offset value */

    /* Compute SDRAM configuration register base
    Base address is the same as read request address*/
    cnf_addr = sdram_hibi_address + mem_ctrl_offset;

    /* The two first words are always the same for reads and writes
       (SDRAM address and word count) */
    sendbuf[ SDRAM_ADDR_CONFIG ] = sdram_word_addr;
    sendbuf[ DATA_AMOUNT_CONFIG ] = words;

    /* Three in default, but +1 for reads */
    snd_amount = SDRAM_WRITE_CONFIG_WORDS;

    /* Send own hibi channel addr for read */
    if( operation == SDRAM_READ_OPERATION ) {
	
	sendbuf[ RCV_HIBI_ADDR_CONFIG ] = read_chn_addr;
	snd_amount = SDRAM_READ_CONFIG_WORDS; 
    }
    
    /* row_count_and_stride is used when reading/writing rectangular areas in memory */
    sendbuf[ snd_amount-1 ] = row_count_and_stride;

    /* Send config words to SDRAM controller */
    HIBI_TX((uint8*)sendbuf, snd_amount*AMOUNT_UNIT_IN_BYTES, cnf_addr, HIBI_TRANSFER_TYPE_MESSAGE);
    
    /* Return valid write address to caller */
    return cnf_addr;

}

/* This function writes data to SDRAM */
bool sdram_write( uint32* const src,
		  const uint32 sdram_addr,
		  const uint32 words ) {

    uint32 write_addr = 0;
    
    /* config SDRAM controller for writing */
    write_addr = sdram_config( sdram_addr, 
			       words,      
			       SDRAM_WRITE_OPERATION, 
			       0,    /* Not used when writing */
			       0 );  /* writing linear memory area */

    /* SDRAM configuration failed? */
    if( write_addr == 0 ) {
	return FALSE;
    }

    /* Send data to SDRAM controller */
    HIBI_TX((uint8*)src, words*AMOUNT_UNIT_IN_BYTES, write_addr, HIBI_TRANSFER_TYPE_DATA);
    
    return TRUE;
}



/* This function reads data from SDRAM (non-blocking) */
void sdram_read( const uint32 sdram_addr,
		 const uint32 words ) {

    /* Resize N2H channel to match the amount of data to be received */
    N2H_ResizeChannel(sdram_data_channel, words*AMOUNT_UNIT_IN_BYTES);
            
    /* configure SDRAM controller for reading */
    sdram_config( sdram_addr,
		  words,
		  SDRAM_READ_OPERATION,
		  (own_hibi_base_address+SDRAM_DATA_CHANNEL_ADDR),
		  0);            /* Reading linear memory area */
		  

		 
    /* Reading has started */
    return;
}

