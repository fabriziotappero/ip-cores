/* Vins Tisc CPU Core, 7th Nov 2001 */

/* implemented in C for starters, transferred to VHDL later... */
/* My first attempt at processor design, thanks to :- */
/* Tim Boscke - CPU8BIT2, Rokwell - 6502, Microchip - Pic */
/* Jien Chung Lo - EL405 , Steve Scott - Tisc, */
/* Giovanni Moretti - Intro to Asm */
/* Uses 12 bit program word, and 8 bit data memory */
/* but its not a pic (honest guv) */

/* 2 reg machine,accumulator based, with akku and index regs */
/* Harvard architecture, uses return x so as to eliminate need of pmem */
/* indirect instructions like 8051. */
/* pc is 10 bits, akku and idx are 8 bit. */
/* Zero flag checked and pc always incremented */
/* at end of each instruction. */

/* Has carry and zero flags, */
/* three addressing modes:- immediate, indirect and reg. */
/* seperate program and data memory for pipelining later... */

/* Instructions coded as thus:- */

/*
   ; Long instructions first - program jump.
   ; Both store return address for subroutine calls, 1 deep stack.
   00 xxxxxxxxxx jc pmem10 ; if c==1, stack = pc, pc <- pmem10, fi
   01 xxxxxxxxxx jz pmem10 ; if z==1, stack = pc, pc <- pmem10, fi

   ; Immediate ops
   ; bits 9 and 8 select what to do
   10 00 xxxxxxxx ld a,#imm8 ; a= imm8, c=0,
   10 01 xxxxxxxx adc a,#imm8 ; add with carry imm8, cy and z set
   10 10 xxxxxxxx adx ix,#imm8 ; add imm8 to idx reg, z=(a==0)

   ; Special op is method of reading pmem space/lookup table and sub return
   ; kind of load immediate - not sure how many states this will need
   10 11 xxxxxxxx ret a,#imm8 ; a= imm8, pc = stack

   ; Indirect and alu ops
   ; bit 9 selects indirect or alu ops

   ; Indirect - bits 7 and 8 select what to do
   11 0 0 0 xxxxxxx ld a,[ix] ; load a indirect data mem
   11 0 0 1 xxxxxxx st [ix],a ; store a indirect data mem

   ; register register
   11 0 1 0 xxxxxxx tax ; x = a,
   11 0 1 1 xxxxxxx txa ; a = x

   ; Arithmetic ops use indirect addressing
   ; all alu ops indirect, bits 7 and 8 select alu op.
   11 1 00 xxxxxxx add a,[ix] ; add with carry
   11 1 01 xxxxxxx sub a,[ix] ; sub with carry as borrow
   11 1 10 xxxxxxx and a,[ix] ; and mem contents into a
   11 1 11 xxxxxxx nor a,[ix] ; nor

 */

/* Further work:- since some indirect, register and alu ops */
/* dont use all of the word, we could do the following:-

   1) Implement dual instructions in a single 12 bit instruction word.
   2) Extend indirect addressing to use offset.
   3) Increase oip code functionality.

   Do this later - get it working first using small nostates.
 */
#include <stdlib.h>
#include <stdio.h>
/* Non Ansi - used for keypress */
#include <conio.h>

/* Vins handy defines */

#define bit(x) (1 << (x))
#define getbit(x, y) ((x & bit(y)) >> y)
#define setbit(x, y) ((x) & bit(y))
#define clrbit(x, y) ((x) & ~bit(y))

/* Mem bit widths */
#define DMEMWIDTH (8)
#define PMEMWIDTH (10)

/* Make a few macros for carry access */
/* not needed in hdl */
#define CY getbit(akku, 8)

/* VHDL take offs */
#define NINETO0 (0x3FF)
#define SEVENTO0 (0xFF)

/* Define instructions */
/* jcc is b00 xx xxxx xxxx */
#define JC (0x000)
/* ldx is b01 xx xxxx xxxx */
#define JZ (0x400)
/* Immediate instructions - b10 xx xxxx xxxx */
#define IMM (0x800)
/* indirect and alu ops - b11 xx xxxx xxxx */
#define IND (0xC00)
/* Reg - Reg */
#define REG IND

/* Subset instructions */
/* Immediate subtypes */
#define LDA (0x000)
#define ADC (0x100)
#define ADX (0x200)
#define RET (0x300)

/* ALU indirect ops */
/* add - b 00 xxxxxxx */
#define ADD (0x000)
/* sub - b 01 xxxxxxx */
#define SUB (0x080)
/* and - b 10 xxxxxxx */
#define AND (0x100)
/* nor - b 11 xxxxxxx */
#define NOR (0x180)

/* Reg to Reg */
/* transfer a to x - b1101 0000 0000*/
#define TAX (0xD00)
/* transfer x to a - b1101 1000 0000*/
#define TXA (0xD80)

/* Indirect Ops ld/st */
/* ld a,[ix] - b1100 0xxx xxxx ld */
#define LDAX (0xC00)
/* st [ix],a - b1100 1xxx xxxx st */
#define STAX (0xC80)

/* create special data type */
typedef unsigned short UNSIGNED10;
typedef unsigned short AKKU9;
typedef unsigned char BYTE;
typedef unsigned char BIT;

/* data memory */
BYTE dmem[2 ^ DMEMWIDTH]; /* program memory */
UNSIGNED10 pmem[2 ^ PMEMWIDTH];

/* main program start */
void main(int argc, char **argv)
{
  UNSIGNED10 PC; /* Program counter is 10 bit */
  UNSIGNED10 stack; /* stack is also 10 bit */
  UNSIGNED10 instr; /* working data bus */

  BIT Z; /* Flags */

/* 9 bit accumulator */
/* bit 9 is cy */
  AKKU9 akku;

/* State, temp and index registers */
  BYTE state, temp, ix;

/* reset - only reset PC & States in real CPU?*/
  PC = 0; akku = 0;
  state = 0; ix = 0; Z = 0;

  printf("\nPress 'q' to quit.\n");

/* Load a simple program - just an opcode test*/
  pmem[0] = IMM | LDA | 0x55;
  pmem[1] = REG | TAX;
  pmem[2] = IMM | LDA | 0xAA;
  pmem[3] = IND | STAX; /* Store A (0xaa) at 0x55 */
  pmem[4] = IND | NOR; /* Zero A */
  pmem[5] = IMM | LDA | 0xff;
  pmem[6] = IMM | ADC | 0x01; /* Set carry */
  pmem[7] = JC | 0x10 - 1; /* start again of overflow - remember 1 less*/
  pmem[0x10] = IMM | LDA | 0x00; /* clear A and zero flag */
  pmem[0x11] = JZ | 0x20 - 1; /* jump to 0x21 - remember 1 less */
/* should now return here with val in A */
  pmem[0x12] = IND | STAX; /* Store A (0xaa) at 0x55 */
  pmem[0x13] = IMM | LDA | 0x00; /* clear A and zero flag */
  pmem[0x14] = JZ | 0x21 - 1; /* jump to 0x21 - remember 1 less */
/* should now return here with val in A */
  pmem[0x15] = IND | STAX; /* Store A at 0x55 */
  pmem[0x16] = IMM | LDA | 0x00; /* clear A and zero flag */
  pmem[0x17] = JZ | 0x00; /* Start again, 1 less remember */

/* Lookup table */
  pmem[0x20] = IMM | RET | 0x99;
  pmem[0x21] = IMM | RET | 0x81;

/* Main fetch-decode-execute-store cycle */
  while (1) /* main state machine loop */

    { /* fetch */
      instr = pmem[PC];

/* now single step through program */
      printf("mem\top\takku\tix\tStack\ttemp\tState\tC Z\n");

      printf("%03X\t%03X\t%02X\t%02X\t%03X\t%02X\t%02X\t%c %c\n",
             PC, instr, akku & 0xff, ix, stack, temp, state, CY ? '1' : '0', Z ? '1' : '0');

/* Non Ansi but you know what I mean... */
      while (!_kbhit()) ;
      if (tolower(_getch()) == 'q') return; /* Quit if 'q' pressed */

/* Initial decode */
      switch (instr & (bit(11) | bit(10)))
        {
        case JC: /* jump if cary set */
          if (CY)
            {
/* save return address */
              stack = PC;

/* Set PC to new value */
/* remember it also increments */
              PC = instr & NINETO0;
            }

          break;

        case JZ:
          if (Z)
            {
/* Save return address */
              stack = PC;

/* Set PC to new value */
/* remember it also increments */

              PC = instr & NINETO0;
            }

          break;

        case IMM:
/* decode immediate instruction */
          switch (instr & (bit(8) | bit(9)))
            {
            case LDA:
              akku = (instr & SEVENTO0);
              break;

            case ADC:
              akku += (instr & SEVENTO0);
/* CY set on overflow */
              break;

            case ADX:
              ix += (instr & SEVENTO0);
              break;

            case RET:
              akku = (instr & SEVENTO0);
/* return stack */
              PC = stack;
              break;

            default: /* shoudl never get here */
              ;
            } /* end of imm subtype decode */

          break;

        case IND: /* All these are indirect */
/* Decode either alu or load/store instr */
          if (instr & bit(9)) /* ALU add, sub, and, or*/

            { /* get temp value of mem location */
/* might include disp7 here, ignore for min */
              temp = dmem[ix];

/* decode indirect alu instruction */
              switch (instr & (bit(8) | bit(7)))
                {
                case ADD:
                  akku += temp;
                  break;

                case SUB:
/* CY acts as borrow if underflow */
                  akku -= temp;
                  break;

                case AND:
                  akku &= temp;
                  break;

                case NOR:
                  akku = ~(akku | temp) & SEVENTO0;
                  break;

                default: /* shoudl never get here */
                  ;
                } /* end of imm subtye decode */
            }
          else                            /* ld/store indirect & reg - reg*/
            {
              if (instr & bit(8)) /* reg - reg */
                {
                  if (bit(7)) /* tax */
                    {
                      ix = akku & SEVENTO0;
                    }
                  else /* txa */
                    {
                      akku = ix;
                    }
                }
              else /* ld/store */
                {
                  if (bit(7)) /* store */
                    { /* not sure how to do this */
                      dmem[ix] = akku & SEVENTO0;
                    }
                  else /* load */
                    {
                      akku = dmem[ix];
                    }
                } /* reg - reg if */
            } /* alu or indirect if */

          break; /* alu/ind load/store switch */

        default:
          ; /* shouldnt get here */
        }

/* PC always incremented */
      PC += 1;
/* set zero flag */
      Z = (akku == 0);
    } /* main while loop */
} /* end of prog */