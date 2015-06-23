/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                          OMSP_SYSTEM HEADER FILE                          */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

//=============================================================================
// PERIPHERALS REGISTER DEFINITIONS
//=============================================================================

//----------------------------------------------------------
// SPECIAL FUNCTION REGISTERS
//----------------------------------------------------------
#define  IE1         (*(volatile unsigned char *) 0x0000)
#define  IFG1        (*(volatile unsigned char *) 0x0002)

#define  CPU_ID_LO   (*(volatile unsigned char *) 0x0004)
#define  CPU_ID_HI   (*(volatile unsigned char *) 0x0006)


//----------------------------------------------------------
// GPIOs
//----------------------------------------------------------
#define  P1IN        (*(volatile unsigned char *) 0x0020)
#define  P1OUT       (*(volatile unsigned char *) 0x0021)
#define  P1DIR       (*(volatile unsigned char *) 0x0022)
#define  P1IFG       (*(volatile unsigned char *) 0x0023)
#define  P1IES       (*(volatile unsigned char *) 0x0024)
#define  P1IE        (*(volatile unsigned char *) 0x0025)
#define  P1SEL       (*(volatile unsigned char *) 0x0026)

#define  P2IN        (*(volatile unsigned char *) 0x0028)
#define  P2OUT       (*(volatile unsigned char *) 0x0029)
#define  P2DIR       (*(volatile unsigned char *) 0x002A)
#define  P2IFG       (*(volatile unsigned char *) 0x002B)
#define  P2IES       (*(volatile unsigned char *) 0x002C)
#define  P2IE        (*(volatile unsigned char *) 0x002D)
#define  P2SEL       (*(volatile unsigned char *) 0x002E)

#define  P3IN        (*(volatile unsigned char *) 0x0018)
#define  P3OUT       (*(volatile unsigned char *) 0x0019)
#define  P3DIR       (*(volatile unsigned char *) 0x001A)
#define  P3SEL       (*(volatile unsigned char *) 0x001B)

#define  P4IN        (*(volatile unsigned char *) 0x001C)
#define  P4OUT       (*(volatile unsigned char *) 0x001D)
#define  P4DIR       (*(volatile unsigned char *) 0x001E)
#define  P4SEL       (*(volatile unsigned char *) 0x001F)

#define  P5IN        (*(volatile unsigned char *) 0x0030)
#define  P5OUT       (*(volatile unsigned char *) 0x0031)
#define  P5DIR       (*(volatile unsigned char *) 0x0032)
#define  P5SEL       (*(volatile unsigned char *) 0x0033)

#define  P6IN        (*(volatile unsigned char *) 0x0034)
#define  P6OUT       (*(volatile unsigned char *) 0x0035)
#define  P6DIR       (*(volatile unsigned char *) 0x0036)
#define  P6SEL       (*(volatile unsigned char *) 0x0037)


//----------------------------------------------------------
// BASIC CLOCK MODULE
//----------------------------------------------------------
#define  BCSCTL1     (*(volatile unsigned char *) 0x0057)
#define  BCSCTL2     (*(volatile unsigned char *) 0x0058)


//----------------------------------------------------------
// WATCHDOG TIMER
//----------------------------------------------------------

// Addresses
#define  WDTCTL      (*(volatile unsigned int  *) 0x0120)

// Bit masks
#define  WDTIS0      (0x0001)
#define  WDTIS1      (0x0002)
#define  WDTSSEL     (0x0004)
#define  WDTCNTCL    (0x0008)
#define  WDTTMSEL    (0x0010)
#define  WDTNMI      (0x0020)
#define  WDTNMIES    (0x0040)
#define  WDTHOLD     (0x0080)
#define  WDTPW       (0x5A00)


//----------------------------------------------------------
// HARDWARE MULTIPLIER
//----------------------------------------------------------
#define  OP1_MPY     (*(volatile unsigned int  *) 0x0130)
#define  OP1_MPYS    (*(volatile unsigned int  *) 0x0132)
#define  OP1_MAC     (*(volatile unsigned int  *) 0x0134)
#define  OP1_MACS    (*(volatile unsigned int  *) 0x0136)
#define  OP2         (*(volatile unsigned int  *) 0x0138)

#define  RESLO       (*(volatile unsigned int  *) 0x013A)
#define  RESHI       (*(volatile unsigned int  *) 0x013C)
#define  SUMEXT      (*(volatile unsigned int  *) 0x013E)


//----------------------------------------------------------
// TIMER A
//----------------------------------------------------------
#define  TACTL       (*(volatile unsigned int  *) 0x0160)
#define  TAR         (*(volatile unsigned int  *) 0x0170)
#define  TACCTL0     (*(volatile unsigned int  *) 0x0162)
#define  TACCR0      (*(volatile unsigned int  *) 0x0172)
#define  TACCTL1     (*(volatile unsigned int  *) 0x0164)
#define  TACCR1      (*(volatile unsigned int  *) 0x0174)
#define  TACCTL2     (*(volatile unsigned int  *) 0x0166)
#define  TACCR2      (*(volatile unsigned int  *) 0x0176)
#define  TAIV        (*(volatile unsigned int  *) 0x012E)


//=============================================================================
// INTERRUPT VECTORS
//=============================================================================
#define interrupt(x) void __attribute__((interrupt (x)))
#define eint()            __asm__ __volatile__ ("eint { nop")
#define dint()            __asm__ __volatile__ ("dint")

// Vector definition for RedHat/TI toolchain
#ifdef PFX_MSP430_ELF
   #define RESET_VECTOR        ("reset")   // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (15)        // Vector 14  (0xFFFC) - Non-maskable       -
   #define UNUSED_13_VECTOR    (14)        // Vector 13  (0xFFFA) -                    -
   #define UNUSED_12_VECTOR    (13)        // Vector 12  (0xFFF8) -                    -
   #define UNUSED_11_VECTOR    (12)        // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (11)        // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define TIMERA0_VECTOR      (10)        // Vector  9  (0xFFF2) - Timer A CC0        -
   #define TIMERA1_VECTOR      (9)         // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (8)         // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (7)         // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (6)         // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (5)         // Vector  4  (0xFFE8) -                    -
   #define PORT2_VECTOR        (4)         // Vector  3  (0xFFE6) - Port 1             -
   #define PORT1_VECTOR        (3)         // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (2)         // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (1)         // Vector  0  (0xFFE0) -                    -  [Lowest Priority]

// Vector definition for MSPGCC toolchain
#else
   #define RESET_VECTOR        (0x001E)    // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (0x001C)    // Vector 14  (0xFFFC) - Non-maskable       -
   #define UNUSED_13_VECTOR    (0x001A)    // Vector 13  (0xFFFA) -                    -
   #define UNUSED_12_VECTOR    (0x0018)    // Vector 12  (0xFFF8) -                    -
   #define UNUSED_11_VECTOR    (0x0016)    // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (0x0014)    // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define TIMERA0_VECTOR      (0x0012)    // Vector  9  (0xFFF2) - Timer A CC0        -
   #define TIMERA1_VECTOR      (0x0010)    // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (0x000E)    // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (0x000C)    // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (0x000A)    // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (0x0008)    // Vector  4  (0xFFE8) -                    -
   #define PORT2_VECTOR        (0x0006)    // Vector  3  (0xFFE6) - Port 1             -
   #define PORT1_VECTOR        (0x0004)    // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (0x0002)    // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (0x0000)    // Vector  0  (0xFFE0) -                    -  [Lowest Priority]
#endif
