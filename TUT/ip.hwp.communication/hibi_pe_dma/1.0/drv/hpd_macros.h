/**
 * @file   hpd_macros.h
 * @author Lasse Lehtonen
 * @date   2012-02-28
 *
 * @brief Platform independent C macros. 
 *
 * @details This file introduces necessary platform independed macros
 * for configuring HIBI_PE_DMA.
 *
 * @par Copyright 
 * Funbase IP library Copyright (C) 2012 TUT Department of
 * Computer Systems
 * @par
 * This file is part of HIBI_PE_DMA
 * @par
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 * @par
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * @par
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.opencores.org/lgpl.shtml
 *
 */


#ifndef HPD_MACROS_H
#define HPD_MACROS_H


/**
 * @def HPD_RX_HIBI_ADDR(chan, haddr, base)
 * Set channel chan to receive from HIBI address haddr.
 * @hideinitializer
 */

/**
 * @def HPD_RX_MEM_ADDR(chan, addr, base)
 * Set channel chan to write received data to memory starting from addr.
 * @hideinitializer
 */

/**
 * @def HPD_RX_WORDS(chan, words, base)
 * Set channel chan to receive words amount of words.
 * @hideinitializer
 */

/**
 * @def HPD_RX_INIT(chan, base)
 * Set channel chan to receive data with previously set configuration
 * @hideinitializer
 */


/**
 * @def HPD_IRQ_ENA(base)
 * Enable interrupts.
 * @hideinitializer
 */

/**
 * @def HPD_IRQ_DIS(base)
 * Disable interrupts.
 * @hideinitializer
 */

/**
 * @def HPD_GET_CONF_REG(var, base)
 * Return configuration register in var.
 * @hideinitializer
 */

/**
 * @def HPD_RX_GET_WORDS(var, chan, base) 
 * Return the amount of words stream channel has received since last 
 * acknowledge in var.
 * @hideinitializer
 */

/**
 * @def HPD_GET_IRQ_REG(var, base)
 * Return interrupt register in var.
 * @hideinitializer
 */

/**
 * @def HPD_CLEAR_IRQ_CHAN(chan, base)
 * Clear interrupts for channel chan.
 * @hideinitializer
 */

/**
 * @def HPD_CLEAR_IRQ_REG(mask, base)
 * Clear interrupts for high bits in mask.
 * @hideinitializer
 */

/**
 * @def HPD_TX_MEM_ADDR(addr, base)
 * Set memory address where the packet to be sent begins.
 * @hideinitializer
 */

/**
 * @def HPD_TX_WORDS(words, base)
 * Set amount of words to be sent.
 * @hideinitializer
 */

/**
 * @def HPD_TX_HIBI_ADDR(haddr, base)
 * Set target HIBI address.
 * @hideinitializer
 */

/**
 * @def HPD_TX_CMD(comm, base)
 * Set HIBI command to use for the transaction
 * @hideinitializer
 */

/**
 * @def HPD_TX_CMD_WRITE(base)
 * Use normal WRITE HIBI command for sending.
 * @hideinitializer
 */

/**
 * @def HPD_TX_CMD_READ(base)
 * Use normal READ HIBI command for sending.
 * @hideinitializer
 */

/**
 * @def HPD_TX_CMD_WRITE_MSG(base)
 * Use message priority WRITE HIBI command for sending.
 * @hideinitializer
 */

/**
 * @def HPD_TX_START(base)
 * Start the transfer with previously set configuration.
 * @hideinitializer
 */

/**
 * @def HPD_TX_GET_DONE(var, base)
 * Poll if previous transfer has completed, var is 1 if true.
 * @hideinitializer
 */

/**
 * @def HPD_RX_HIBI_DATA(var, base)
 * Returns current value on hibi bus in \e var.
 * @hideinitializer
 */


#define HPD_RX_INIT(chan, base)			\
  {						\
    volatile int * apu = (int*)base + 0;	\
    *apu = 1 << (chan);				\
  }


#define HPD_GET_CONF_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 1;	\
    var = *apu;					\
  }

#define HPD_IRQ_ENA(base)			\
  {						\
    volatile int * apu = (int*)base + 1;	\
    *apu = *apu | 0x2;				\
  }

#define HPD_IRQ_DIS(base)			\
  {						\
    volatile int * apu = (int*)base + 1;	\
    *apu = *apu & 0xfffffffd;			\
  }

#define HPD_TX_START(base)			\
  {						\
    volatile int * apu = (int*)base + 1;	\
    *apu = *apu | 0x1;				\
  }

#define HPD_TX_GET_DONE(var, base)		\
  {						\
    volatile int * apu = (int*)(base) + 1;	\
    var = *apu >> 16;				\
    var = var & 0x1;				\
  }


#define HPD_GET_IRQ_REG(var, base)		\
  {						\
    volatile int * apu = (int*)base + 2;	\
    var = *apu;					\
  }

#define HPD_CLEAR_IRQ_CHAN(chan, base)		\
  {						\
  volatile int * apu = (int*)base + 2;          \
    *apu = 1 << (chan);				\
  }


#define HPD_CLEAR_IRQ_REG(mask, base)		\
  {						\
  volatile int * apu = (int*)base + 2;          \
    *apu = mask;				\
  }


#define HPD_TX_MEM_ADDR(addr, base)		\
  {						\
    volatile int * apu = (int*)base + 3;	\
    *apu = addr;				\
  }


#define HPD_TX_WORDS(words, base)		\
  {						\
    volatile int * apu = (int*)base + 4;	\
    *apu = words;				\
  }


#define HPD_TX_CMD(comm, base)			\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu = comm;				\
  }

#define HPD_TX_CMD_WRITE(base)			\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu = 2;					\
  }

#define HPD_TX_CMD_READ(base)			\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu = 4;					\
  }

#define HPD_TX_CMD_WRITE_MSG(base)		\
  {						\
    volatile int * apu = (int*)base + 5;	\
    *apu = 3;					\
  }


#define HPD_TX_HIBI_ADDR(haddr, base)		\
  {						\
    volatile int * apu = (int*)base + 6;	\
    *apu = haddr;				\
  }


#define HPD_RX_HIBI_DATA(var, base)		\
  {                                             \
    volatile int* apu = (int*)base + 7;		\
    var = *apu;					\
  }


#define HPD_RX_MEM_ADDR(chan, addr, base)	\
  {						\
    volatile int * apu = (int*)base + 8;	\
    apu = apu + ((chan) << 4);			\
    *apu = addr;				\
  }



#define HPD_RX_GET_WORDS(var, chan, base)	\
  {                                             \
  volatile int* apu = (int*)base + 9		\
    + ((chan) << 4);				\
  var = *apu;                                   \
  }


#define HPD_RX_WORDS(chan, words, base)		\
  {						\
    volatile int * apu = (int*)base + 9;	\
    apu = apu + ((chan) << 4);			\
    *apu = words;				\
  }


#define HPD_RX_HIBI_ADDR(chan, haddr, base)	\
  {						\
    volatile int * apu = (int*)base + 10;	\
    apu = apu + ((chan) << 4);			\
    *apu = haddr;				\
  }

#endif
