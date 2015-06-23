/*
 * File:   hpd_registers_conf.h
 * Author: Lasse Lehtonen
 * Date:   2012-01-13
 * Brief:  Defines the memory mapped address for HIBI PE DMA component
 *
 * Modify following addresses according to the SOPC configuration.
 * Following code assumes that tx buffer is first in the memory and rx buffer
 * follows that directly.
 *
 * Copy this file for every NIOS processor. Assumes only one HIBI PE
 * DMA component per avalon-MM bus.
 *
 */
 
#ifndef HPD_REGISTERS_CONF_H
#define HPD_REGISTERS_CONF_H


// HPD Avalon slave base address
#define HPD_REGISTERS_BASE_ADDRESS            ((void*) (0x80000000 | HIBI_PE_DMA_1_BASE))              

// Buffer start address in cpu's memory
#define HPD_REGISTERS_BUFFER_START            (0x80000000 | SHARED_MEM_1_BASE)

// Writeable tx buffer
#define HPD_REGISTERS_TX_BUFFER_START         (HPD_REGISTERS_BUFFER_START)
#define HPD_REGISTERS_TX_BUFFER_BYTE_LENGTH   (0x00000400)
#define HPD_REGISTERS_TX_BUFFER_END (HPD_REGISTERS_TX_BUFFER_START + \
                                     HPD_REGISTERS_TX_BUFFER_BYTE_LENGTH - 1)
                       
// Readable rx buffer
#define HPD_REGISTERS_RX_BUFFER_START (HPD_REGISTERS_TX_BUFFER_START + \
				       HPD_REGISTERS_TX_BUFFER_BYTE_LENGTH)
#define HPD_REGISTERS_RX_BUFFER_BYTE_LENGTH (0x00000C00)
#define HPD_REGISTERS_RX_BUFFER_END   (HPD_REGISTERS_RX_BUFFER_START + \
				       HPD_REGISTERS_RX_BUFFER_BYTE_LENGTH - 1)

// HPD Interrupt registers, numbers and priorities
#define HPD_RX_IRQ             (2)
#define HPD_RX_IRQ_PRI         (3)

// HPD number of channels
#define HPD_NUMBER_OF_CHANNELS (8)

#endif
