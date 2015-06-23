/*
 *
 * Author            : Lasse Lehtonen
 * Last modification : 29.03.2011 
 *
 * HPD support functions for handling initialization, sending, receiving and
 *  ISR stuff (needs that funky hpd_isr_fifo)
 *
 */

/* NB
 *
 *  Remember to modify below
 *     #define HIBI_PE_DMA_BASE
 *     #define HIBI_PE_DMA_IRQ_INTERRUPT_CONTROLLER_ID
 *     #define HIBI_PE_DMA_IRQ
 *
 */

#ifndef SUPPORT_H
#define SUPPORT_H

#include "hpd_isr_fifo.h"
#include "system.h"
#include "hpd_registers_conf.h"
#include "hpd_macros.h"


#define HIBI_PE_DMA_BASE (0x80000000 | HIBI_PE_DMA_0_BASE)
#define HIBI_PE_DMA_IRQ_INTERRUPT_CONTROLLER_ID HIBI_PE_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID
#define HIBI_PE_DMA_IRQ HIBI_PE_DMA_0_IRQ


/*            where to read      how much    target address */             
void hpd_send(int data_src_addr, int words, int hibi_addr);

/*               which channel  where to store,    amount   address to match*/
void hpd_init_rx(int rx_channel, int rx_addr, int rx_words, int hibi_addr);

/* Returns the position of the first occurrence of '1' from LSB (rigth)*/
int onehot2int(int num);

/* ISR handler*/
void hpd_isr(void* context);

/* Init interrupt service */
void hpd_isr_init(Hpd_isr_fifo* hpd_isr_fifo);


#endif

