/*
* History:
*    10/08/2005 by ollil
*        + Copied minor modifications implemented by Ari.
*          This fixed a crash bug in DCT HW based system
*    03/10/2008 by tapiok
*       fixed N2H_RX_IRQ_DIS
*    08/2009 kojo2
*       Added following functions: N2H_INIT_ISR, N2H_RX_DONE, 
*                                  N2H_PUT_TX_BUFFER, N2H_GET_RX_BUFFER
*/
#ifndef __tut_n2h_regs_h_
#define __tut_n2h_regs_h_

#ifdef NIOS_II
#include "io.h"

#define N2H_CHAN_HIBI_ADDR(chan, hibi_addr, base) IOWR(base, ((chan) << 4) + 1, hibi_addr)
#define N2H_CHAN_MEM_ADDR(chan, addr, base) IOWR(base, ((chan) << 4), addr)
#define N2H_CHAN_AMOUNT(chan, amount, base) IOWR(base, ((chan) << 4) + 2, amount)
#define N2H_CHAN_INIT(chan, base) IOWR(base, 5 , 1 << (chan))
#define N2H_RX_IRQ_ENA(base) IOWR(base, 4, (2 | (IORD(base,4))))
#define N2H_RX_IRQ_DIS(base) IOWR(base, 4, (0xfffffffd & (IORD(base,4))))
#define N2H_GET_STAT_REG(var, base) var = (IORD(base, 4) >> 16)
#define N2H_GET_CONF_REG(var, base) var = (IORD(base, 4) & 0x0000ffff)
#define N2H_GET_INIT_REG(var, base) var = IORD(base, 5)
#define N2H_GET_IRQ_REG(var, base) var = IORD(base, 7)
#define N2H_TX_MEM_ADDR(addr, base) IOWR(base, 8, addr)
#define N2H_TX_AMOUNT(amount, base) IOWR(base, 9, amount)
#define N2H_TX_COMM(comm, base) IOWR(base,10,comm)
#define N2H_TX_COMM_WRITE(base) IOWR(base,10,2)
#define N2H_TX_COMM_READ(base) IOWR(base,10,4)
#define N2H_TX_COMM_WRITE_MSG(base) IOWR(base,10,3)
#define N2H_TX_HIBI_ADDR(addr, base) IOWR(base, 11, addr)
#define N2H_TX_START(base) IOWR(base, 4, (0x1 | (IORD(base,4))))
#define N2H_GET_TX_DONE(var, base) var = ((IORD(base, 4) >> 16) & 0x1)
#define N2H_GET_CURR_PTR(var, chan, base) var = (IORD(base,((chan) << 4) + 3))
#define N2H_RX_CLEAR_IRQ(chan, base) IOWR(base, 7, (1 << (chan)))


#else 

#define N2H_CHAN_HIBI_ADDR(chan, hibi_addr, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4) + 1;		\
    *apu=hibi_addr;				\
  }

#define N2H_CHAN_MEM_ADDR(chan, addr, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4);			\
    *apu=addr;					\
  }

#define N2H_CHAN_AMOUNT(chan, amount, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4) + 2;		\
    *apu=amount;				\
  }

#define N2H_CHAN_INIT(chan, base)		\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu=1 << (chan);				\
  }

#define N2H_RX_IRQ_ENA(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu= *apu | 0x2;				\
  }

#define N2H_RX_IRQ_DIS(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu= *apu & 0xfffffffd;			\
  }

#define N2H_GET_STAT_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    var = *apu >> 16;				\
  }
  
#define N2H_GET_CONF_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    var = *apu & 0x0000ffff;			\
  }

#define N2H_GET_INIT_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 5;	\
    var = *apu;					\
  }

#define N2H_GET_IRQ_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 7;	\
    var = *apu;					\
  }

#define N2H_GET_CURR_PTR(var, chan, base)	\
  {						\
    volatile int * apu = (int*)base + 3;	\
    apu = apu + ((chan) << 4);			\
    var = *apu;					\
  }

#define N2H_TX_MEM_ADDR(addr, base)		\
  {						\
    volatile int * apu = (int*)base + 8;	\
    *apu = addr;				\
  }

#define N2H_TX_AMOUNT(amount, base)		\
  {						\
    volatile int * apu = (int*)base + 9;	\
    *apu = amount;				\
  }

#define N2H_TX_HIBI_ADDR(haddr, base)		\
  {						\
    volatile int * apu = (int*)base + 11;	\
    *apu = haddr;				\
  }

#define N2H_TX_COMM(comm, base)			\
  {						\
    volatile int * apu = (int*)base +10;	\
    *apu = comm;				\
  }

#define N2H_TX_COMM_WRITE(base)			\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 2;					\
  }

#define N2H_TX_COMM_READ(base)			\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 4;					\
  }

#define N2H_TX_COMM_WRITE_MSG(base)		\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 3;					\
  }

#define N2H_TX_START(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu = *apu | 0x1;				\
    *apu = *apu & 0xfffffffe;			\
  }
#define N2H_GET_TX_DONE(y, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    y = *apu >> 16;				\
    y = y & 0x1;				\
  }

#define N2H_RX_CLEAR_IRQ(chan, base)		\
  {						\
    volatile int * apu = (int*)base + 7;	\
    *apu = 1 << (chan);				\
  }



#endif


#ifdef API
extern void N2H_INIT_ISR();
extern void N2H_RX_DONE( int chan, int mem_addr, int amount );
extern void N2H_GET_RX_BUFFER( int* dst, int src, int amount );
extern void N2H_PUT_TX_BUFFER( int dst, int* src, int amount );
#endif


/*
* DMA engine configuration
*/

extern void N2H_CHAN_CONF( int channel, 
			   int mem_addr, 
			   int rx_addr, 
			   int amount, 
			   int* base );

extern void N2H_SEND(int mem_addr, int amount, int haddr, int* base);

extern void N2H_READ(int mem_addr, int amount, int haddr, int* base);

extern void N2H_SEND_MSG(int mem_addr, int amount, int haddr, int* base);

extern int N2H_TX_DONE(int* base);

extern void N2H_CLEAR_IRQ(int chan, int* base);

extern int N2H_GET_IRQ_CHAN(int* base);

#endif
