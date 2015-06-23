/*
 *
 * Author            : Lasse Lehtonen
 * Last modification : 29.03.2011 
 *
 * N2H support functions
 *
 */

/* NB
 *
 *  Remember to #define N2H2_CHAN_BASE as N2H's base address
 *  Also #define N2H2_CHAN_IRQ_INTERRUPT_CONTROLLER_ID and
 *  #define N2H2_CHAN_IRQ
 *
 */

#ifndef SUPPORT_H
#define SUPPORT_H

#include "n2h_isr_fifo.h"
#include "system.h"
#include "N2H_registers_and_macros.h"
#include "tut_n2h_regs.h"

#define N2H2_CHAN_BASE N2H2_CHAN_0_BASE
#define N2H2_CHAN_IRQ_INTERRUPT_CONTROLLER_ID N2H2_CHAN_0_IRQ_INTERRUPT_CONTROLLER_ID
#define N2H2_CHAN_IRQ N2H2_CHAN_0_IRQ


/*            where to read      how much    target address */             
void n2h_send(int data_src_addr, int amount, int hibi_addr);

/*               which channel  where to store,    amount   address to match*/
void n2h_init_rx(int rx_channel, int rx_addr, int rx_amount, int hibi_addr);

/* Returns the position of the first occurrence of '1' from LSB (rigth)*/
int onehot2int(int num);

/* ISR handler */
void n2h2_isr(void* context);

/* Init interrupt service */
void n2h_isr_init(N2H_isr_fifo* n2h_isr_fifo);


#endif

