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
/*                          MEMORY DEFINITION FILE                           */
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

.set    PER_LENGTH,     PER_SIZE_HEX

/*---------------------------------------------------------------------------*/
/*                                   SFR                                     */
/*---------------------------------------------------------------------------*/
.set    IE1,       0x0000
.set    IE1_HI,    0x0001
.set    IFG1,      0x0002
.set    IFG1_HI,   0x0003
.set    CPU_ID_LO, 0x0004
.set    CPU_ID_HI, 0x0006
.set    CPU_NR,    0x0008

/*---------------------------------------------------------------------------*/
/*                                    GPIOs                                  */
/*---------------------------------------------------------------------------*/
.set    P1IN,      0x0020
.set    P1OUT,     0x0021
.set    P1DIR,     0x0022
.set    P1IFG,     0x0023
.set    P1IES,     0x0024
.set    P1IE,      0x0025
.set    P1SEL,     0x0026

.set    P2IN,      0x0028
.set    P2OUT,     0x0029
.set    P2DIR,     0x002A
.set    P2IFG,     0x002B
.set    P2IES,     0x002C
.set    P2IE,      0x002D
.set    P2SEL,     0x002E

.set    P3IN,      0x0018
.set    P3OUT,     0x0019
.set    P3DIR,     0x001A
.set    P3SEL,     0x001B

.set    P4IN,      0x001C
.set    P4OUT,     0x001D
.set    P4DIR,     0x001E
.set    P4SEL,     0x001F

.set    P5IN,      0x0030
.set    P5OUT,     0x0031
.set    P5DIR,     0x0032
.set    P5SEL,     0x0033

.set    P6IN,      0x0034
.set    P6OUT,     0x0035
.set    P6DIR,     0x0036
.set    P6SEL,     0x0037

/*---------------------------------------------------------------------------*/
/*                           BASIC CLOCK MODULE                              */
/*---------------------------------------------------------------------------*/
.set    BCSCTL1,   0x0057
.set    BCSCTL2,   0x0058

/*---------------------------------------------------------------------------*/
/*                             WATCHDOG TIMER                                */
/*---------------------------------------------------------------------------*/
.set    WDTCTL,    0x0120

/*---------------------------------------------------------------------------*/
/*                           HARDWARE MULTIPLIER                             */
/*---------------------------------------------------------------------------*/
.set    MPY,       0x0130
.set    MPYS,      0x0132
.set    MAC,       0x0134
.set    MACS,      0x0136
.set    OP2,       0x0138
.set    RESLO,     0x013A
.set    RESHI,     0x013C
.set    SUMEXT,    0x013E

/*---------------------------------------------------------------------------*/
/*                                 TIMER A                                   */
/*---------------------------------------------------------------------------*/
.set    TACTL,     0x0160
.set    TAR,       0x0170
.set    TACCTL0,   0x0162
.set    TACCR0,    0x0172
.set    TACCTL1,   0x0164
.set    TACCR1,    0x0174
.set    TACCTL2,   0x0166
.set    TACCR2,    0x0176
.set    TAIV,      0x012E

/*---------------------------------------------------------------------------*/
/*                          DATA MEMORY MAPPING                              */
/*---------------------------------------------------------------------------*/
.set    DMEM_BASE, PER_SIZE

.set    DMEM_200,  (DMEM_BASE+0x00)
.set    DMEM_201,  (DMEM_BASE+0x01)
.set    DMEM_202,  (DMEM_BASE+0x02)
.set    DMEM_203,  (DMEM_BASE+0x03)
.set    DMEM_204,  (DMEM_BASE+0x04)
.set    DMEM_205,  (DMEM_BASE+0x05)
.set    DMEM_206,  (DMEM_BASE+0x06)
.set    DMEM_207,  (DMEM_BASE+0x07)
.set    DMEM_208,  (DMEM_BASE+0x08)
.set    DMEM_209,  (DMEM_BASE+0x09)
.set    DMEM_20A,  (DMEM_BASE+0x0A)
.set    DMEM_20B,  (DMEM_BASE+0x0B)
.set    DMEM_20C,  (DMEM_BASE+0x0C)
.set    DMEM_20D,  (DMEM_BASE+0x0D)
.set    DMEM_20E,  (DMEM_BASE+0x0E)
.set    DMEM_20F,  (DMEM_BASE+0x0F)

.set    DMEM_210,  (DMEM_BASE+0x10)
.set    DMEM_211,  (DMEM_BASE+0x11)
.set    DMEM_212,  (DMEM_BASE+0x12)
.set    DMEM_213,  (DMEM_BASE+0x13)
.set    DMEM_214,  (DMEM_BASE+0x14)
.set    DMEM_215,  (DMEM_BASE+0x15)
.set    DMEM_216,  (DMEM_BASE+0x16)
.set    DMEM_217,  (DMEM_BASE+0x17)
.set    DMEM_218,  (DMEM_BASE+0x18)
.set    DMEM_219,  (DMEM_BASE+0x19)
.set    DMEM_21A,  (DMEM_BASE+0x1A)
.set    DMEM_21B,  (DMEM_BASE+0x1B)
.set    DMEM_21C,  (DMEM_BASE+0x1C)
.set    DMEM_21D,  (DMEM_BASE+0x1D)
.set    DMEM_21E,  (DMEM_BASE+0x1E)
.set    DMEM_21F,  (DMEM_BASE+0x1F)

.set    DMEM_220,  (DMEM_BASE+0x20)
.set    DMEM_221,  (DMEM_BASE+0x21)
.set    DMEM_222,  (DMEM_BASE+0x22)
.set    DMEM_223,  (DMEM_BASE+0x23)
.set    DMEM_224,  (DMEM_BASE+0x24)
.set    DMEM_225,  (DMEM_BASE+0x25)
.set    DMEM_226,  (DMEM_BASE+0x26)
.set    DMEM_227,  (DMEM_BASE+0x27)
.set    DMEM_228,  (DMEM_BASE+0x28)
.set    DMEM_229,  (DMEM_BASE+0x29)
.set    DMEM_22A,  (DMEM_BASE+0x2A)
.set    DMEM_22B,  (DMEM_BASE+0x2B)
.set    DMEM_22C,  (DMEM_BASE+0x2C)
.set    DMEM_22D,  (DMEM_BASE+0x2D)
.set    DMEM_22E,  (DMEM_BASE+0x2E)
.set    DMEM_22F,  (DMEM_BASE+0x2F)

.set    DMEM_230,  (DMEM_BASE+0x30)
.set    DMEM_231,  (DMEM_BASE+0x31)
.set    DMEM_232,  (DMEM_BASE+0x32)
.set    DMEM_233,  (DMEM_BASE+0x33)
.set    DMEM_234,  (DMEM_BASE+0x34)
.set    DMEM_235,  (DMEM_BASE+0x35)
.set    DMEM_236,  (DMEM_BASE+0x36)
.set    DMEM_237,  (DMEM_BASE+0x37)
.set    DMEM_238,  (DMEM_BASE+0x38)
.set    DMEM_239,  (DMEM_BASE+0x39)
.set    DMEM_23A,  (DMEM_BASE+0x3A)
.set    DMEM_23B,  (DMEM_BASE+0x3B)
.set    DMEM_23C,  (DMEM_BASE+0x3C)
.set    DMEM_23D,  (DMEM_BASE+0x3D)
.set    DMEM_23E,  (DMEM_BASE+0x3E)
.set    DMEM_23F,  (DMEM_BASE+0x3F)

.set    DMEM_240,  (DMEM_BASE+0x40)
.set    DMEM_241,  (DMEM_BASE+0x41)
.set    DMEM_242,  (DMEM_BASE+0x42)
.set    DMEM_243,  (DMEM_BASE+0x43)
.set    DMEM_244,  (DMEM_BASE+0x44)
.set    DMEM_245,  (DMEM_BASE+0x45)
.set    DMEM_246,  (DMEM_BASE+0x46)
.set    DMEM_247,  (DMEM_BASE+0x47)
.set    DMEM_248,  (DMEM_BASE+0x48)
.set    DMEM_249,  (DMEM_BASE+0x49)
.set    DMEM_24A,  (DMEM_BASE+0x4A)
.set    DMEM_24B,  (DMEM_BASE+0x4B)
.set    DMEM_24C,  (DMEM_BASE+0x4C)
.set    DMEM_24D,  (DMEM_BASE+0x4D)
.set    DMEM_24E,  (DMEM_BASE+0x4E)
.set    DMEM_24F,  (DMEM_BASE+0x4F)

.set    DMEM_250,  (DMEM_BASE+0x50)
.set    DMEM_251,  (DMEM_BASE+0x51)
.set    DMEM_252,  (DMEM_BASE+0x52)
.set    DMEM_253,  (DMEM_BASE+0x53)
.set    DMEM_254,  (DMEM_BASE+0x54)
.set    DMEM_255,  (DMEM_BASE+0x55)
.set    DMEM_256,  (DMEM_BASE+0x56)
.set    DMEM_257,  (DMEM_BASE+0x57)
.set    DMEM_258,  (DMEM_BASE+0x58)
.set    DMEM_259,  (DMEM_BASE+0x59)
.set    DMEM_25A,  (DMEM_BASE+0x5A)
.set    DMEM_25B,  (DMEM_BASE+0x5B)
.set    DMEM_25C,  (DMEM_BASE+0x5C)
.set    DMEM_25D,  (DMEM_BASE+0x5D)
.set    DMEM_25E,  (DMEM_BASE+0x5E)
.set    DMEM_25F,  (DMEM_BASE+0x5F)

.set    DMEM_260,  (DMEM_BASE+0x60)
.set    DMEM_261,  (DMEM_BASE+0x61)
.set    DMEM_262,  (DMEM_BASE+0x62)
.set    DMEM_263,  (DMEM_BASE+0x63)
.set    DMEM_264,  (DMEM_BASE+0x64)
.set    DMEM_265,  (DMEM_BASE+0x65)
.set    DMEM_266,  (DMEM_BASE+0x66)
.set    DMEM_267,  (DMEM_BASE+0x67)
.set    DMEM_268,  (DMEM_BASE+0x68)
.set    DMEM_269,  (DMEM_BASE+0x69)
.set    DMEM_26A,  (DMEM_BASE+0x6A)
.set    DMEM_26B,  (DMEM_BASE+0x6B)
.set    DMEM_26C,  (DMEM_BASE+0x6C)
.set    DMEM_26D,  (DMEM_BASE+0x6D)
.set    DMEM_26E,  (DMEM_BASE+0x6E)
.set    DMEM_26F,  (DMEM_BASE+0x6F)

.set    DMEM_300,  (DMEM_BASE+0x100)

/*---------------------------------------------------------------------------*/
/*                        PROGRAM MEMORY MAPPING                             */
/*---------------------------------------------------------------------------*/
.set    PMEM_LENGTH,     PMEM_SIZE
.set    PMEM_EDE_LENGTH, PMEM_EDE_SIZE
