/**
    @file light52.h
    @brief SFR definitions for the light52 core.
    
    This file uses the SCDD compiler MCS51 C extensions and will not be
    directly compatible with other compilers.
*/

#ifndef LIGHT52_H_INCLUDED
#define LIGHT52_H_INCLUDED

/* Interrupt Enable register */
__sfr __at  0xa8 IE;      /**< Interrupt enable register */
__sbit __at 0xaf EA;      /**< Global Interrupt Enable flag */
__sbit __at 0xac ES;      /**< Serial port Interrupt Enable flag */
__sbit __at 0xa9 ET0;     /**< Timer 0 Interrupt Enable flag */
__sbit __at 0xa8 EEX;     /**< External Interrupt Enable flag */

/* Serial port */
__sfr __at  0x98 SCON;      /**< UART control register */
__sbit __at 0x9c TXIRQ;     /**< UART TX interrupt flag */
__sbit __at 0x9d RXIRQ;     /**< UART RX interrupt flag */
__sbit __at 0x9c TXRDY;     /**< UART TxRdy flag */
__sbit __at 0x9d RXRDY;     /**< UART RxRdy flag */
__sfr __at  0x99 SBUF;      /**< UART tx/rx data buffer */
__sfr __at  0x9a SBPL;      /**< UART Baud period register, Low byte */
__sfr __at  0x9b SBPH;      /**< UART Baud Period register, High byte  */

/* Timer T0 -- 16-bit timer not compatible to original */
__sfr __at  0x88 TCON;      /**< Timer 0 control register */
__sbit __at 0x88 T0IRQ;     /**< Timer 0 interrupt flag */
__sbit __at 0x8c T0ARL;     /**< Timer 0 Auto ReLoad flag */
__sbit __at 0x8d T0CEN;     /**< Timer 0 Count ENable flag */
__sfr __at  0x8c T0L;       /**< Timer 0 counter register, Low byte */
__sfr __at  0x8d T0H;       /**< Timer 0 counter register, High byte */
__sfr __at  0x8e T0CL;      /**< Timer 0 reload register, Low byte */
__sfr __at  0x8f T0CH;      /**< Timer 0 reload register, High byte */

/* External interrupts */
__sfr __at  0xc0 EXTINT;    /**< EXTernal INTerrupt flag register */
__sbit __at 0xc0 EIRQ0;
__sbit __at 0xc1 EIRQ1;
__sbit __at 0xc2 EIRQ2;
__sbit __at 0xc3 EIRQ3;
__sbit __at 0xc4 EIRQ4;
__sbit __at 0xc5 EIRQ5;
__sbit __at 0xc6 EIRQ6;
__sbit __at 0xc7 EIRQ7;

/* I/O ports */
__sfr __at  0x80 P0;        /**< Port 0 register (hardwired output) */
__sbit __at 0x80 P0_0;
__sbit __at 0x81 P0_1;
__sbit __at 0x82 P0_2;
__sbit __at 0x83 P0_3;
__sbit __at 0x84 P0_4;
__sbit __at 0x85 P0_5;
__sbit __at 0x86 P0_6;
__sbit __at 0x87 P0_7;
__sfr __at  0x90 P1;        /**< Port 1 register (hardwired output) */
__sbit __at 0x90 P1_0;
__sbit __at 0x91 P1_1;
__sbit __at 0x92 P1_2;
__sbit __at 0x93 P1_3;
__sbit __at 0x94 P1_4;
__sbit __at 0x95 P1_5;
__sbit __at 0x96 P1_6;
__sbit __at 0x97 P1_7;
__sfr __at  0xa0 P2;        /**< Port 2 register (hardwired input) */
__sbit __at 0xa0 P2_0;
__sbit __at 0xa1 P2_1;
__sbit __at 0xa2 P2_2;
__sbit __at 0xa3 P2_3;
__sbit __at 0xa4 P2_4;
__sbit __at 0xa5 P2_5;
__sbit __at 0xa6 P2_6;
__sbit __at 0xa7 P2_7;
__sfr __at  0xb0 P3;        /**< Port 3 register (hardwired input) */
__sbit __at 0xb0 P3_0;
__sbit __at 0xb1 P3_1;
__sbit __at 0xb2 P3_2;
__sbit __at 0xb3 P3_3;
__sbit __at 0xb4 P3_4;
__sbit __at 0xb5 P3_5;
__sbit __at 0xb6 P3_6;
__sbit __at 0xb7 P3_7;

#endif
