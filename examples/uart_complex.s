/* 
 * RISE microprocessor - Test program for UART
 *
 * Copyright (c) 2006 Jakob Lechner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * File: $Id: uart_complex.s,v 1.1 2007-01-25 22:31:12 cwalter Exp $
 */

  .text
  .org    0x0000

  /* address for status register */
  ld      r8, #0x00
  ldhb    r8, #0x80 
  /* address for uart data register */
  ld      r9, #0x01
  ldhb    r9, #0x80
  /* address for data buffer */
  ld      r10, addrlo(buffer)
  ldhb    r10, addrhi(buffer)
  /* addresses for branch targets */
  ld      r7, addrlo(main)
  ldhb    r7, addrhi(main)
  ld      r11, addrlo(check_rdrf)
  ldhb    r11, addrhi(check_rdrf)
  ld      r12, addrlo(check_tdre)
  ldhb    r12, addrhi(check_tdre)

  /* wait for uart receiver data */
main:
  ld      r6, r10
check_rdrf: 
  ld      r2, [r8]
  ld      r3, #0x2
  and     r2, r3
  jmpz    r11

  /* data available, read data */
  ld      r4, [r9]
  /* compare for newline. if newline output data */
  ld      r1, #0x0a
  sub     r1, r4
  jmpz    r12   
  st      r4, [r6]
  add     r6, #1
  jmp     r11
 
  /* wait for transmitter register empty */
check_tdre:
  ld      r2, [r8]
  ld      r3, #0x1
  and     r2, r3
  jmpz    r12

  /* transmitter register empty: send data */
  ld      r2, r10
  sub     r2, r6
  jmpz    r7  

  sub     r6, #1
  ld      r4, [r6]
  st      r4, [r9]
  jmp     r12

  .data
  .org    0x0200
buffer:
  .space  128
