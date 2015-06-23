/* Exception handling code for SCARTS.
 * Copyright (C) 2010, 2011 Embedded Computing Systems Group,
 * Department of Computer Engineering, Vienna University of Technology.
 * Contributed by Wolfgang Puffitsch <hausesn@gmx.at>
 *                Martin Walter <mwalter@opencores.org>
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */

#ifndef __SCARTS_INTERRUPTS_H__
#define __SCARTS_INTERRUPTS_H__

#include <stdint.h>
#include "modules.h"

/* Set sleep mode. */
#define SLEEP_MODE()   (PROC_CTRL_CONFIG_C |= (1 << (PROC_CTRL_CONFIG_C_SLEEP)))
#define sleep_mode     SLEEP_MODE

/* Set the Global Interrupt Flag. */
#define SEI()          (PROC_CTRL_CONFIG_C |= (1 << (PROC_CTRL_CONFIG_C_GIE)))
#define sei            SEI

/* Clear the Global Interrupt Flag. */
#define CLI()          (PROC_CTRL_CONFIG_C &= ~(1 << (PROC_CTRL_CONFIG_C_GIE)))
#define cli            CLI

/* Register function FUNC as SW trap NUM (0..15). */
#define REGISTER_TRAP(FUNC, NUM)   asm ("stvec %0, %1" : : "r" (&FUNC), "i" (NUM))
#define register_trap              REGISTER_TRAP

/* Register function FUNC as HW interrupt NUM (0..15). */
#define REGISTER_INTERRUPT(FUNC, NUM)   asm ("stvec %0, %1" : : "r" (&FUNC), "i" ((NUM)-16))
#define register_interrupt              REGISTER_INTERRUPT

/* Mask / unmask a single interrupt. */
#define MASKI(NUM)   (PROC_CTRL_INTMASK |= (1 << (NUM)))
#define maski        MASKI

#define UMASKI(NUM)   (PROC_CTRL_INTMASK &= ~(1 << (NUM)))
#define umaski        UMASKI

/* Mask / unmask multiple interrupts at once. */
#define MASKIL(NUMS)   (PROC_CTRL_INTMASK |= (NUMS))
#define maskil         MASKIL

#define UMASKIL(NUMS)   (PROC_CTRL_INTMASK &= ~(NUMS))
#define umaskil         UMASKIL

/* Protocol / unprotocol a single interrupt. */
#define PROTI(NUM)   (PROC_CTRL_INTPROT = (1 << (NUM)))
#define proti        PROTI

#define UPROTI(NUM)   (PROC_CTRL_INTPROT = (1 << (NUM)))
#define uproti        UPROTI

/* Protocol / unprotocol multiple interrupts at once (set corresponding bits in NUMS). */
#define PROTL(NUMS)   (PROC_CTRL_INTPROT = (uint16_t)(NUMS))
#define protl         PROTL 

#define UPROTL(NUMS)   (PROC_CTRL_INTPROT = (uint16_t)(NUMS))
#define uprotl         UPROTL

#endif

