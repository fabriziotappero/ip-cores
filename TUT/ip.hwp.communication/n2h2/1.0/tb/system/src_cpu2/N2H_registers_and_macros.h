// *****************************************************************************
// File             : N2H_registers_and_macros.h
// Author           : Tero Arpinen
// Date             : 22.12.2004
// Decription       : This file contains customizable register address 
//                    definitions
//                    for N2H interface and some needed macros
// 
// Version history  : 22.12.2004    tar    Original version 
//                  : 06.07.2005    tar    Modified to work with N2H2
//                  : 02.10.2009    tko    Removed unneeded macros
// *****************************************************************************
 
#ifndef N2H_REGISTERS_AND_MACROS_H
#define N2H_REGISTERS_AND_MACROS_H

// DEFINE FOLLOWING REGISTERS ACCORDING TO NIOS OR NIOS II HARDWARE 
// CONFIGURATION

// N2H2 Avalon slave base address
#define N2H_REGISTERS_BASE_ADDRESS            ((void*) N2H2_CHAN_2_BASE)

// Buffer start address in cpu's memory
#define N2H_REGISTERS_BUFFER_START            (SHARED_MEM_2_BASE)

// Writeable registers
// set bit 31 to 1 so that writes and reads bypass cache
#define N2H_REGISTERS_TX_BUFFER_START         (0x80000000 | SHARED_MEM_2_BASE)

#define N2H_REGISTERS_TX_BUFFER_BYTE_LENGTH (0x00000400)
#define N2H_REGISTERS_TX_BUFFER_END (N2H_REGISTERS_TX_BUFFER_START + \
                                     N2H_REGISTERS_TX_BUFFER_BYTE_LENGTH - 1)
                       
// Readable registers
#define N2H_REGISTERS_RX_BUFFER_START       (N2H_REGISTERS_TX_BUFFER_START + N2H_REGISTERS_TX_BUFFER_BYTE_LENGTH)
#define N2H_REGISTERS_RX_BUFFER_BYTE_LENGTH (0x00000C00)
#define N2H_REGISTERS_RX_BUFFER_END         (N2H_REGISTERS_RX_BUFFER_START + \
					   N2H_REGISTERS_RX_BUFFER_BYTE_LENGTH \
					   - 1)
// N2H Interrupt registers, numbers and priorities
#define N2H_RX_IRQ                      (2)
#define N2H_RX_IRQ_PRI                  (3)

// N2H Channels
#define N2H_NUMBER_OF_CHANNELS              (8)

#endif // N2H_REGISTERS_AND_MACROS_H
