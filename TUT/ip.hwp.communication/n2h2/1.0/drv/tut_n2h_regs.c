#include "tut_n2h_regs.h"
#include "N2H_registers_and_macros.h"


#if defined(API)
struct Channel_reservation {
 
    int mem_addr;
    int amount;
    
};

static struct Channel_reservation 
    channel_reservations[N2H_NUMBER_OF_CHANNELS] = {};


// Common interrupt service routine. Clear IRQ and call N2H_RX_DONE.
void isr() {
  
    int chan = N2H_GET_IRQ_CHAN(N2H_REGISTERS_BASE_ADDRESS);
    N2H_RX_DONE( chan, channel_reservations[chan].mem_addr, channel_reservations[chan].amount );
    channel_reservations[chan].mem_addr = 0;
    channel_reservations[chan].amount = 0;
    N2H_RX_CLEAR_IRQ(chan,N2H_REGISTERS_BASE_ADDRESS);
}



// eCos specific interrupt handling
#if defined(ECOS)
#include <cyg/kernel/kapi.h>
#include <cyg/hal/hal_intr.h>
#include <cyg/hal/hal_cache.h>

static cyg_interrupt l_rxIrq;
static cyg_handle_t l_rxIrqHandle;
extern void cyg_interrupt_post_dsr(CYG_ADDRWORD intr_handle);

cyg_uint32 RxIrqIsr(cyg_vector_t vector, cyg_addrword_t data) { 
    cyg_interrupt_mask(vector);
    cyg_interrupt_post_dsr(l_rxIrqHandle);
    return (CYG_ISR_HANDLED);
}

void RxIrqDsr(cyg_vector_t vector, cyg_ucount32 count, cyg_addrword_t data) {
    isr();
    cyg_interrupt_unmask(vector);
    
}


// NIOSII specific interrupt handling
#else
void n2h_isr( void* context, int id ) {
    isr();
}
#endif

void N2H_INIT_ISR() {

// eCos specific interrupt init    
#if defined(ECOS)
    cyg_interrupt_create(
			 N2H_RX_IRQ,
			 N2H_RX_IRQ_PRI,
			 0,
			 &RxIrqIsr,
			 &RxIrqDsr,
			 &l_rxIrqHandle,
			 &l_rxIrq);
    cyg_interrupt_attach(l_rxIrqHandle);
    cyg_interrupt_unmask(N2H_RX_IRQ);
    N2H_RX_IRQ_ENA( N2H_REGISTERS_BASE_ADDRESS );

// NIOSII specific interrupt init
#else
    alt_irq_register( N2H_RX_IRQ, 0, n2h_isr );
    N2H_RX_IRQ_ENA( N2H_REGISTERS_BASE_ADDRESS );
#endif
}

void N2H_GET_RX_BUFFER( int* dst, int src, int amount ) {
 
    // TODO: check that src is inside RX buffer
    // TODO: if src and dst are same, do nothing    
    int i;
    for( i = 0; i < amount; ++i ) {
    
	*(dst + i) = *((int*)src + i);
    }
}

void N2H_PUT_TX_BUFFER( int dst, int* src, int amount ) {
    
    // TODO: check that dst is inside TX buffer
    // TODO: if src and dst are same, do nothing   
    
    int i;
    for( i = 0; i < amount; ++i ) {
	
	*((int*)dst + i) = *(src + i);
    }
    
}
#endif // API

/*
* DMA engine configuration functions (Updated on 27/04/2005)
*/

// Prepare channel for receiving data.
void N2H_CHAN_CONF(int channel, int dst_mem_addr, int rx_haddr, int amount, 
		   int* base)
{
#ifdef API
  channel_reservations[channel].mem_addr = dst_mem_addr;
  channel_reservations[channel].amount = amount; 
#endif
  N2H_CHAN_MEM_ADDR(channel, dst_mem_addr, base);
  N2H_CHAN_HIBI_ADDR(channel, rx_haddr, base);
  N2H_CHAN_AMOUNT(channel, amount, base);
  N2H_CHAN_INIT(channel, base);
}

void N2H_SEND(int src_mem_addr, int amount, int dst_haddr, int* base) {
  while( !N2H_TX_DONE(base) );
  N2H_TX_MEM_ADDR(src_mem_addr, base);
  N2H_TX_AMOUNT(amount, base);
  N2H_TX_HIBI_ADDR(dst_haddr, base);
  N2H_TX_COMM_WRITE(base);
  N2H_TX_START(base);
}

// Parameter types were uint32. Int works in other places, so why not here?
void N2H_SEND_READ(int mem_addr, int amount, int haddr, int* base) {
  while( !N2H_TX_DONE(base) );
  N2H_TX_MEM_ADDR(mem_addr, base);
  N2H_TX_AMOUNT(amount, base);
  N2H_TX_HIBI_ADDR(haddr, base);
  N2H_TX_COMM_READ(base);
  N2H_TX_START(base);
}

void N2H_SEND_MSG(int src_mem_addr, int amount, int dst_haddr, int* base) {
  while( !N2H_TX_DONE(base) );
  N2H_TX_MEM_ADDR(src_mem_addr, base);
  N2H_TX_AMOUNT(amount, base);
  N2H_TX_HIBI_ADDR(dst_haddr, base);
  N2H_TX_COMM_WRITE_MSG(base);
  N2H_TX_START(base);
}

// Return 0 if transmission is not done yet, 1 otherwise.
int N2H_TX_DONE(int* base) {
  int y = 0;
  N2H_GET_TX_DONE(y, base);
  return y;  
}

void N2H_CLEAR_IRQ(int chan, int* base) {
  N2H_RX_CLEAR_IRQ(chan, base);
}

// Returns first channel number which has IRQ flag up.
// If no interrupts have been received -1 is returned.
int N2H_GET_IRQ_CHAN(int* base)
{
  volatile int * apu = base + 7;
  int irq_reg = *apu;
  int mask = 1;
  int shift = 0;
  for (shift = 0; shift < 32; shift++) {
    if ((irq_reg & (mask << shift)) != 0) {
      return shift;
    }
  }
  return -1;
}

