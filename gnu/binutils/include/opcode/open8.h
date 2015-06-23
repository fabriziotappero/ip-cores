/* Opcode table for the Open8/V8/ARClite MCUs

   Copyright 2000, 2001, 2004, 2006, 2008, 2010, 2011
   Free Software Foundation, Inc.

   Contributed by Kirk Hays <khays@hayshaus.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

#define OPEN8_ISA_OPEN8   0x0001 /* Opcode set as published for the Open8.  */
#define OPEN8_ISA_V8      0x0002 /* Opcode set for original VAutomation V8.  */
#define OPEN8_ISA_ALL (OPEN8_ISA_V8 | OPEN8_ISA_OPEN8)

/* constraint letters
   r - any general purpose register index (R0..R7)
   e - any even numbered general purpose register, the upper two
   bits thereof

   u - unsigned offset expression, 8 bits, from 0 to 255,
   always 2nd byte of insn
   s - signed pc-relative offset expression, 8 bits, from -128 to 127,
   always 2nd byte of insn
   i - immediate value expression, eight bits, signed or unsigned,
   always 2nd byte of insn

   n - immediate value expression from 0 to 7, 3 bits
   b - immediate value expression from 0 to 7, 3 bits, indexing PSR

   h - 16 bit address expression for JMP variant,
   located at bytes 2 and 3 of the instruction

   H - 16 bit address expression for composed JMP variants,
   located at bytes 4 and 5 of the composed instruction

   M - 16 bit memory address for load and store,
   located at bytes 2 and 3 of the instruction

   a - autoincrement operator - syntactically "++", bitvalue = 1, 0 if not
   present

   Order is important - some binary opcodes have more than one name,
   the disassembler will only see the first match.

*/

#define R "rrr"
#define E "ee"
#define U "uuuuuuuu"
#define S "ssssssss"
#define I "iiiiiiii"
#define N "nnn"
#define B "bbb"
#define H "hhhhhhhhhhhhhhhh"
#define BIG_H "HHHHHHHHHHHHHHHH"
#define M "MMMMMMMMMMMMMMMM"
#define A "a"

#define REGISTER_P(x) ((x) == 'r' || (x) == 'e')
#define MAX_INSN_SIZE (5)

#define SUBOP_MASK  (0x07U)
#define SUBOP_SHIFT (0U)

#define REG_MASK  (SUBOP_MASK)
#define REG_SHIFT (SUBOP_SHIFT)

#define EREG_MASK  (SUBOP_MASK & 0x06U)
#define EREG_SHIFT (SUBOP_SHIFT)

#define U_MASK  (0x0FF00U)
#define U_SHIFT (8U)

#define S_MASK  (U_MASK)
#define S_SHIFT (U_SHIFT)

#define I_MASK  (U_MASK)
#define I_SHIFT (U_SHIFT)

#define N_MASK  (SUBOP_MASK)
#define N_SHIFT (SUBOP_SHIFT)

#define B_MASK  (SUBOP_MASK)
#define B_SHIFT (SUBOP_SHIFT)

#define H_MASK  (0xFFFF00ULL)
#define H_SHIFT (8U)

#define BIG_H_MASK  (0xFFFF000000ULL)
#define BIG_H_SHIFT (24U)

#define M_MASK  (0xFFFF00ULL)
#define M_SHIFT (8U)

#define A_MASK (0x01U)

#define MAKE_OPCODE(a, b, c)			\
  (((unsigned long long) (a))			\
   | ((unsigned long long) (b) << 8)		\
   | ((unsigned long long) (c) << 16))

/* Composite-mnemonics - generate two or more machine instructions,
 * introduced to simplify compiler logic for branching,
 * oftimes relaxed by peephole or linker into simple branches
 */
/* NB: these must come first, so that the composites are recognized first when
 * disassembling.
 */
OPEN8_INSN (jmpz,  "H", "10010000000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x090U,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brnz <label>
* jmp h
* <label>:
*/

OPEN8_INSN (jmpnz, "H", "10011000000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x098U,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brz <label>
* jmp h,
* <label>:
*/

OPEN8_INSN (jmplz, "H", "10010010000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x092U,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brgez <label>
* jmp h
* <label>:
*/

OPEN8_INSN (jmpgez,"H", "10011010000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x09AU,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brlz <label>
* jmp h
*<label>:
*/

OPEN8_INSN (jmpc,  "H", "10010001000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x091U,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brnc <label>
* jmp h
* <label>:
*/

OPEN8_INSN (jmpnc, "H", "10011001000010010111100" BIG_H, 5, OPEN8_ISA_ALL, \
	    MAKE_OPCODE (0x099U,0x05U,0x0BCU), 0x0FFFFFFU)
/*
* brc <label>
* jmp h
* <label>:
*/

/* Pseudo-mnemonics - map 1:1 to actual machine instructions,
 * introduced for programmer/compiler ease.
 */
/* NB: these must come before the actual machine instructions,
 * so that the pseudo-mnemonics are recognized first when disassembling.
 */
OPEN8_INSN (stz,  "",   "01011000",         1, OPEN8_ISA_ALL, 0x058U, 0x0FFU)
/* stp 0 */

OPEN8_INSN (stc,  "",   "01011001",         1, OPEN8_ISA_ALL, 0x059U, 0x0FFU)
/* stp 1 */

OPEN8_INSN (stn,  "",   "01011010",         1, OPEN8_ISA_ALL, 0x05AU, 0x0FFU)
/* stp 2 */

OPEN8_INSN (sti,  "",   "01011011",         1, OPEN8_ISA_ALL, 0x05BU, 0x0FFU)
/* stp 3 */

OPEN8_INSN (clz,  "",   "01101000",         1, OPEN8_ISA_ALL, 0x068U, 0x0FFU)
/* clp 0 */

OPEN8_INSN (clc,  "",   "01101001",         1, OPEN8_ISA_ALL, 0x069U, 0x0FFU)
/* clp 1 */

OPEN8_INSN (cln,  "",   "01101010",         1, OPEN8_ISA_ALL, 0x06AU, 0x0FFU)
/* clp 2 */

OPEN8_INSN (cli,  "",   "01101011",         1, OPEN8_ISA_ALL, 0x06BU, 0x0FFU)
/* clp 3 */

OPEN8_INSN (brnz, "s",  "10010000" S,       2, OPEN8_ISA_ALL, 0x090U, 0x0FFU)
/* br0 0, s */

OPEN8_INSN (brnc, "s",  "10010001" S,       2, OPEN8_ISA_ALL, 0x091U, 0x0FFU)
/* br0 1, s */

OPEN8_INSN (brgez,"s",  "10010010" S,       2, OPEN8_ISA_ALL, 0x092U, 0x0FFU)
/* br0 2, s */

OPEN8_INSN (brz,  "s",  "10011000" S,       2, OPEN8_ISA_ALL, 0x098U, 0x0FFU)
/* br1 0, s */

OPEN8_INSN (brc,  "s",  "10011001" S,       2, OPEN8_ISA_ALL, 0x099U, 0x0FFU)
/* br1 1, s */

OPEN8_INSN (brlz, "s",  "10011010" S,       2, OPEN8_ISA_ALL, 0x09AU, 0x0FFU)
/* br1 2, s */

OPEN8_INSN (nop,  "",   "10111011",         1, OPEN8_ISA_ALL, 0x0BBU, 0x0FFU)
/* brk */
OPEN8_INSN (clr,  "",   "00101000",         1, OPEN8_ISA_ALL, 0x028U, 0x0FFU)
/* clr */

/* Native instructions */
OPEN8_INSN (inc,  "r",    "00000" R,     1, OPEN8_ISA_ALL,    0x000U, 0x0F8U)
OPEN8_INSN (adc,  "r",    "00001" R,     1, OPEN8_ISA_ALL,    0x008U, 0x0F8U)
OPEN8_INSN (tx0,  "r",    "00010" R,     1, OPEN8_ISA_ALL,    0x010U, 0x0F8U)
OPEN8_INSN (or,   "r",    "00011" R,     1, OPEN8_ISA_ALL,    0x018U, 0x0F8U)
OPEN8_INSN (and,  "r",    "00100" R,     1, OPEN8_ISA_ALL,    0x020U, 0x0F8U)
OPEN8_INSN (xor,  "r",    "00101" R,     1, OPEN8_ISA_ALL,    0x028U, 0x0F8U)
OPEN8_INSN (rol,  "r",    "00110" R,     1, OPEN8_ISA_ALL,    0x030U, 0x0F8U)
OPEN8_INSN (ror,  "r",    "00111" R,     1, OPEN8_ISA_ALL,    0x038U, 0x0F8U)
OPEN8_INSN (dec,  "r",    "01000" R,     1, OPEN8_ISA_ALL,    0x040U, 0x0F8U)
OPEN8_INSN (sbc,  "r",    "01001" R,     1, OPEN8_ISA_ALL,    0x048U, 0x0F8U)
OPEN8_INSN (add,  "r",    "01010" R,     1, OPEN8_ISA_ALL,    0x050U, 0x0F8U)
OPEN8_INSN (stp,  "b",    "01011" B,     1, OPEN8_ISA_ALL,    0x058U, 0x0F8U)
OPEN8_INSN (btt,  "b",    "01100" B,     1, OPEN8_ISA_ALL,    0x060U, 0x0F8U)
OPEN8_INSN (clp,  "b",    "01101" B,     1, OPEN8_ISA_ALL,    0x068U, 0x0F8U)
OPEN8_INSN (t0x,  "r",    "01110" R,     1, OPEN8_ISA_ALL,    0x070U, 0x0F8U)
OPEN8_INSN (cmp,  "r",    "01111" R,     1, OPEN8_ISA_ALL,    0x078U, 0x0F8U)
OPEN8_INSN (psh,  "r",    "10000" R,     1, OPEN8_ISA_ALL,    0x080U, 0x0F8U)
OPEN8_INSN (pop,  "r",    "10001" R,     1, OPEN8_ISA_ALL,    0x088U, 0x0F8U)
OPEN8_INSN (br0,  "b,s",  "10010" B S,   2, OPEN8_ISA_ALL,    0x090U, 0x0F8U)
OPEN8_INSN (br1,  "b,s",  "10011" B S,   2, OPEN8_ISA_ALL,    0x098U, 0x0F8U)
/* `usr' is defined below */
OPEN8_INSN (int,  "n",    "10101" N,     1, OPEN8_ISA_ALL,    0x0A8U, 0x0F8U)
/* `usr2' is defined below */
OPEN8_INSN (rsp,  "",     "10111000",    1, OPEN8_ISA_ALL,    0x0B8U, 0x0FFU)
OPEN8_INSN (rts,  "",     "10111001",    1, OPEN8_ISA_ALL,    0x0B9U, 0x0FFU)
OPEN8_INSN (rti,  "",     "10111010",    1, OPEN8_ISA_ALL,    0x0BAU, 0x0FFU)
OPEN8_INSN (brk,  "",     "10111011",    1, OPEN8_ISA_ALL,    0x0BBU, 0x0FFU)
OPEN8_INSN (jmp,  "h",    "10111100" H,  3, OPEN8_ISA_ALL,    0x0BCU, 0x0FFU)
OPEN8_INSN (jsr,  "h",    "10111111" H,  3, OPEN8_ISA_ALL,    0x0BFU, 0x0FFU)
OPEN8_INSN (upp,  "e",    "11000" E "0", 1, OPEN8_ISA_ALL,    0x0C0U, 0x0F9U)
OPEN8_INSN (sta,  "r,M",  "11001" R M,   3, OPEN8_ISA_ALL,    0x0C8U, 0x0F8U)
OPEN8_INSN (ldi,  "r,i",  "11100" R I,   2, OPEN8_ISA_ALL,    0x0E0U, 0x0F8U)
OPEN8_INSN (lda,  "r,M",  "11101" R M,   3, OPEN8_ISA_ALL,    0x0E8U, 0x0F8U)

/* Open8 specific mnemonics.  */

/* Open8 instructions that add auto-increment to existing V8 instructions.  */
OPEN8_INSN (stx,  "ea",   "11010" E A,   1, OPEN8_ISA_OPEN8,  0x0D0U, 0x0F8U)
OPEN8_INSN (ldx,  "ea",   "11110" E A,   1, OPEN8_ISA_OPEN8,  0x0F0U, 0x0F8U)
OPEN8_INSN (ldo,  "ea,u", "11111" E A U, 2, OPEN8_ISA_OPEN8,  0x0F8U, 0x0F8U)
OPEN8_INSN (sto,  "ea,u", "11011" E A U, 2, OPEN8_ISA_OPEN8,  0x0D8U, 0x0F8U)

/* Instructions that substitute for the V8 `usr' and `usr2' instructions.  */
OPEN8_INSN (dbnz, "r,s",  "10100" R S,   2, OPEN8_ISA_OPEN8,  0x0A0U, 0x0F8U)
OPEN8_INSN (mul,  "r",    "10110" R,     1, OPEN8_ISA_OPEN8,  0x0B0U, 0x0F8U)

/* Interrupt mask instructions that are unique to the Open8.  */
OPEN8_INSN (smsk, "",     "10111101",    1, OPEN8_ISA_OPEN8,  0x0BDU, 0x0FFU)
OPEN8_INSN (gmsk, "",     "10111110",    1, OPEN8_ISA_OPEN8,  0x0BEU, 0x0FFU)
