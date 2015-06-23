/*
 * File:   hpd_macros.h
 * Author: Lasse Lehtonen
 * Date:   2012-01-13
 * Brief:  Macros to help using HIBI PE DMA component
 *
 * 
 *
 */




#ifndef HPD_MACROS_H
#define HPD_MACROS_H


#define HPD_CHAN_HIBI_ADDR(chan, hibi_addr, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4) + 1;		\
    *apu = hibi_addr;				\
  }

#define HPD_CHAN_MEM_ADDR(chan, addr, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4);			\
    *apu = addr;					\
  }

#define HPD_CHAN_WORDS(chan, words, base)	\
  {						\
    volatile int * apu = (int*)base;		\
    apu = apu + ((chan) << 4) + 2;		\
    *apu = words;				\
  }

#define HPD_CHAN_INIT(chan, base)		\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu = 1 << (chan);				\
  }

#define HPD_RX_IRQ_ENA(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu = *apu | 0x2;				\
  }

#define HPD_RX_IRQ_DIS(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu = *apu & 0xfffffffd;			\
  }

#define HPD_GET_STAT_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    var = *apu >> 16;				\
  }
  
#define HPD_GET_CONF_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    var = *apu & 0x0000ffff;			\
  }

#define HPD_GET_INIT_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 5;	\
    var = *apu;					\
  }

#define HPD_GET_IRQ_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 7;	\
    var = *apu;					\
  }

#define HPD_RX_CLEAR_IRQ(chan, base)		\
  {						\
    volatile int * apu = (int*)base + 7;	\
    *apu = 1 << (chan);				\
  }

#define HPD_GET_CURR_PTR(var, chan, base)	\
  {						\
    volatile int * apu = (int*)base + 3;	\
    apu = apu + ((chan) << 4);			\
    var = *apu;					\
  }

#define HPD_TX_MEM_ADDR(addr, base)		\
  {						\
    volatile int * apu = (int*)base + 8;	\
    *apu = addr;				\
  }

#define HPD_TX_WORDS(words, base)		\
  {						\
    volatile int * apu = (int*)base + 9;	\
    *apu = words;				\
  }

#define HPD_TX_HIBI_ADDR(haddr, base)		\
  {						\
    volatile int * apu = (int*)base + 11;	\
    *apu = haddr;				\
  }

#define HPD_TX_CMD(comm, base)			\
  {						\
    volatile int * apu = (int*)base +10;	\
    *apu = comm;				\
  }

#define HPD_TX_CMD_WRITE(base)			\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 2;					\
  }

#define HPD_TX_CMD_READ(base)			\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 4;					\
  }

#define HPD_TX_COMM_WRITE_MSG(base)		\
  {						\
    volatile int * apu = (int*)base + 10;	\
    *apu = 3;					\
  }

#define HPD_TX_START(base)			\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu = *apu | 0x1;				\
    *apu = *apu & 0xfffffffe;			\
  }
#define HPD_GET_TX_DONE(y, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    y = *apu >> 16;				\
    y = y & 0x1;				\
  }

#endif
