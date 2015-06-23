/* Instruction printing code for the OpenRISC 1000
   Copyright (C) 2002, 2005, 2007 Free Software Foundation, Inc.
   Contributed by Damjan Lampret <lampret@opencores.org>.
   Modified from a29k port.

   This file is part of the GNU opcodes library.

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   It is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
   License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

#define DEBUG 0

#include "dis-asm.h"
#include "or32.h"
//#include "safe-ctype.h"
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#define EXTEND28(x) ((x) & (unsigned long) 0x08000000 ? ((x) | (unsigned long) 0xf0000000) : ((x)))

/* Now find the four bytes of INSN_CH and put them in *INSN.  */

static void
find_bytes_big (unsigned char *insn_ch, unsigned long *insn)
{
  *insn =
    ((unsigned long) insn_ch[0] << 24) +
    ((unsigned long) insn_ch[1] << 16) +
    ((unsigned long) insn_ch[2] << 8) +
    ((unsigned long) insn_ch[3]);
#if DEBUG
  printf ("find_bytes_big3: %x\n", *insn);
#endif
}

static void
find_bytes_little (unsigned char *insn_ch, unsigned long *insn)
{
  *insn =
    ((unsigned long) insn_ch[3] << 24) +
    ((unsigned long) insn_ch[2] << 16) +
    ((unsigned long) insn_ch[1] << 8) +
    ((unsigned long) insn_ch[0]);
}

typedef void (*find_byte_func_type) (unsigned char *, unsigned long *);

static unsigned long
or32_extract (char param_ch, char *enc_initial, unsigned long insn)
{
  char *enc;
  unsigned long ret = 0;
  int opc_pos = 0;
  int param_pos = 0;

  for (enc = enc_initial; *enc != '\0'; enc++)
    if (*enc == param_ch)
      {
	if (enc - 2 >= enc_initial && (*(enc - 2) == '0') && (*(enc - 1) == 'x'))
	  continue;
	else
	  param_pos++;
      }

#if DEBUG
  printf ("or32_extract: %c %x ", param_ch, param_pos);
#endif
  opc_pos = 32;

  for (enc = enc_initial; *enc != '\0'; )
    if ((*enc == '0') && (*(enc + 1) == 'x'))
      {
	opc_pos -= 4;

	if ((param_ch == '0') || (param_ch == '1'))
	  {
	    unsigned long tmp = strtoul (enc, NULL, 16);
#if DEBUG
	    printf (" enc=%s, tmp=%x ", enc, tmp);
#endif
	    if (param_ch == '0')
	      tmp = 15 - tmp;
	    ret |= tmp << opc_pos;
	  }
	enc += 3;
      }
    else if ((*enc == '0') || (*enc == '1'))
      {
	opc_pos--;
	if (param_ch == *enc)
	  ret |= 1 << opc_pos;
	enc++;
      }
    else if (*enc == param_ch)
      {
	opc_pos--;
	param_pos--;
#if DEBUG
	printf ("\n  ret=%x opc_pos=%x, param_pos=%x\n", ret, opc_pos, param_pos);
#endif
	ret += ((insn >> opc_pos) & 0x1) << param_pos;

	if (!param_pos
	    && letter_signed (param_ch)
	    && ret >> (letter_range (param_ch) - 1))
	  {
#if DEBUG
	    printf ("\n  ret=%x opc_pos=%x, param_pos=%x\n",
		    ret, opc_pos, param_pos);
#endif
	    ret |= 0xffffffff << letter_range(param_ch);
#if DEBUG
	    printf ("\n  after conversion to signed: ret=%x\n", ret);
#endif
	  }
	enc++;
      }
  //else if (ISALPHA (*enc))
  else if (isalpha(*enc))
      {
	opc_pos--;
	enc++;
      }
    else if (*enc == '-')
      {
	opc_pos--;
	enc++;
      }
    else
      enc++;

#if DEBUG
  printf ("ret=%x\n", ret);
#endif
  return ret;
}

static int
or32_opcode_match (unsigned long insn, char *encoding)
{
  unsigned long ones, zeros;

#if DEBUG
  printf ("or32_opcode_match: %.8lx\n", insn);
#endif    
  ones  = or32_extract ('1', encoding, insn);
  zeros = or32_extract ('0', encoding, insn);

  // Added 090430 - jb - fixed problem where upper 4 bytes of a 64-bit long weren't getting setup properly for comparison
  // As a result, instructions weren't getting decoded properly
  insn &= 0xffffffff;
  ones &= 0xffffffff;
  zeros &= 0xffffffff;
  
#if DEBUG
  printf ("ones: %x \n", ones);
  printf ("zeros: %x \n", zeros);
#endif
  if ((insn & ones) != ones)
    {
#if DEBUG
      printf ("ret1\n");
#endif
      return 0;
    }
    
  if ((~insn & zeros) != zeros)
    {
#if DEBUG
      printf ("ret2\n");
#endif
      return 0;
    }
  
#if DEBUG
  printf ("ret3\n");
#endif
  return 1;
}

/* Print register to INFO->STREAM. Used only by print_insn.  */

static void
or32_print_register (char param_ch,
		     char *encoding,
		     unsigned long insn)
		     //		     struct disassemble_info *info)
{
  int regnum = or32_extract (param_ch, encoding, insn);
  
#if DEBUG
  printf ("or32_print_register: %c, %s, %x\n", param_ch, encoding, insn);
#endif  
  if (param_ch == 'A')
    //(*info->fprintf_func) (info->stream, "r%d", regnum);
    printf("r%d", regnum);
  else if (param_ch == 'B')
    //(*info->fprintf_func) (info->stream, "r%d", regnum);
    printf("r%d", regnum);
  else if (param_ch == 'D')
    //(*info->fprintf_func) (info->stream, "r%d", regnum);
    printf("r%d", regnum);
  else if (regnum < 16)
    //(*info->fprintf_func) (info->stream, "r%d", regnum);
    printf("r%d", regnum);
  else if (regnum < 32)
    //(*info->fprintf_func) (info->stream, "r%d", regnum-16);
    printf("r%d", regnum-16);
  else
    //(*info->fprintf_func) (info->stream, "X%d", regnum);
    printf("X%d", regnum);
}

/* Print immediate to INFO->STREAM. Used only by print_insn.  */

static void
or32_print_immediate (char param_ch,
		      char *encoding,
		      unsigned long insn)
		      //struct disassemble_info *info)
{
  int imm = or32_extract(param_ch, encoding, insn);
  
  if (letter_signed(param_ch))
    //(*info->fprintf_func) (info->stream, "0x%x", imm);
    printf("0x%x", imm);
/*    (*info->fprintf_func) (info->stream, "%d", imm); */
  else
    //(*info->fprintf_func) (info->stream, "0x%x", imm);
    printf("0x%x", imm);
}

/* Print one instruction from MEMADDR on INFO->STREAM.
   Return the size of the instruction (always 4 on or32).  */

static int
//print_insn (bfd_vma memaddr, struct disassemble_info *info)
print_insn(unsigned long insn)
{
  /* The raw instruction.  */
  unsigned char insn_ch[4];
  /* Address. Will be sign extened 27-bit.  */
  unsigned long addr;
  /* The four bytes of the instruction.  */
  //unsigned long insn;
  //find_byte_func_type find_byte_func = (find_byte_func_type) info->private_data;
  struct or32_opcode const * opcode;
  /*
  {
    int status =
      (*info->read_memory_func) (memaddr, (bfd_byte *) &insn_ch[0], 4, info);

    if (status != 0)
      {
        (*info->memory_error_func) (status, memaddr, info);
        return -1;
      }
  }
  */

  //(*find_byte_func) (&insn_ch[0], &insn);

  for (opcode = &or32_opcodes[0];
       opcode < &or32_opcodes[or32_num_opcodes];
       ++opcode)
    {
      if (or32_opcode_match (insn, opcode->encoding))
        {
          char *s;

          //(*info->fprintf_func) (info->stream, "%s ", opcode->name);
	  printf("%s ", opcode->name);

          for (s = opcode->args; *s != '\0'; ++s)
            {
              switch (*s)
                {
                case '\0':
                  return 4;
      
                case 'r':
                  //or32_print_register (*++s, opcode->encoding, insn, info);
		  or32_print_register (*++s, opcode->encoding, insn);
                  break;

                case 'N':
                  addr = or32_extract ('N', opcode->encoding, insn) << 2;
		  int32_t int32_addr = (int32_t) addr; // Must use explicitly sized bariable here
		  //printf("int32_addr: %d ", int32_addr);
		  if (int32_addr >= 0)
		    printf("(+0x%x)", int32_addr);
		  else
		    {
		      int32_addr = (~int32_addr) + 1;
		      printf("(-0x%x)", int32_addr);
		    }
                  /* Calulate the correct address.  */
                  //addr = memaddr + EXTEND28 (addr);

                  //(*info->print_address_func)
                  //  (addr, info);
                  break;

                default:
                  if (strchr (opcode->encoding, *s))
                    //or32_print_immediate (*s, opcode->encoding, insn, info);
		    or32_print_immediate (*s, opcode->encoding, insn);
                  else
                    //(*info->fprintf_func) (info->stream, "%c", *s);
		    printf("%c", *s);
                }
            }

          return 4;
        }
    }

  /* This used to be %8x for binutils.  */
  //  (*info->fprintf_func)
  //  (info->stream, ".word 0x%08lx", insn);
  printf(".word 0x%08lx", insn);
  return 4;
}

/* Disassemble a big-endian or32 instruction.  */
/*
int
print_insn_big_or32 (bfd_vma memaddr, struct disassemble_info *info)
{
  info->private_data = find_bytes_big;

  return print_insn (memaddr, info);
}
*/
/* Disassemble a little-endian or32 instruction.  */
 /*
int
print_insn_little_or32 (bfd_vma memaddr, struct disassemble_info *info)
{
  info->private_data = find_bytes_little;
  return print_insn (memaddr, info);
}
 */
#define PRINT_ORIG_INSN_OPTION "-print-orig-insn"

static void print_or32_dis_usage(char *argv[])
{
  printf(" OpenRISC instruction decoder\n");
  printf("\n");
  printf(" Decodes an instruction passed on the command line, otherwise reads from stdin.\n");
  printf(" The option %s prints out the original instruction along with the decoded version\n similar to the objdump disassembler output, except without address information\n", PRINT_ORIG_INSN_OPTION);
  printf("\n");
  printf(" Usage:\n");
  printf("\n");
  printf(" Decode a single instruction from the command line:\n");
  printf(" \t%s 0x1500000\n", argv[0]);
  printf("\n");
  printf(" Decode a list of instructions from stdin:\n");
  printf(" \t%s < list_of_insns\n", argv[0]);
  printf("\n");
  printf(" Decode a list of instructions from stdin, and print out the original instruction as well:\n");
  printf(" \t%s -print-orig-insn < list_of_insns\n", argv[0]);
  printf("\n");
  printf(" Note: The values don't require the leading \"0x\"\n"); 
  printf("\n");
  return;
}

// Simple program to do disassembly like or32-objdump but on individual instructions passed to it
  // Pass the instruction in hex
int main (int argc, char *argv[])
{
  unsigned long insn;
  
  
  int print_orig_inst_option = 0; // Don't print the instruction we're passed, by default, just the decoded version
  // extract possible options we were passed
  int i;
  for(i=1;i<argc;i++)
    {
      // First check if it's an option we've been passed
      if (strncmp(argv[i],"-", 1) == 0 )
	{
	  //printf("option detected at argv[%d]\n", i);
	  if (strcmp(argv[i],PRINT_ORIG_INSN_OPTION) == 0 )
	    {
	      print_orig_inst_option = 1;
	      break;
	    }
	  if (strncmp(argv[i],"-h",2) == 0 )
	    {
	      print_or32_dis_usage(argv);
	      return 0;
	    }

	}
    }
  
  int use_stdin = 0;
  
  if ((argc == 3 && print_orig_inst_option) || (argc == 2 && !print_orig_inst_option))
    use_stdin = 0;
  else
    use_stdin = 1;

  if (!use_stdin) // Just read the instruction passed to us on the command line and exit
    {
      int index = 1;
      if (argc > 2 ) 
	{
	  if (i == 1) index++; // If the option was the first thing passed, the instruction is in argv[2]
	}

      insn = strtoul(argv[index], NULL, 16);
      if (print_orig_inst_option)
	printf(" %.8lx\t", insn);
      print_insn (insn);
      printf("\n");

    }
  else
    {
      char inp[10]; // Buffer is long enough to have an 8 char hex value plus its leading "0x", but that is not essential
      while(1) // Loop, reading from stdin
	{
	  char c;
	  c = getchar();
	  //printf("%c",c);
	  if (c == '\n') // End of a line - now determine the instruction we've been given
	    {
	      insn = strtoul(inp, NULL, 16);

	      if (print_orig_inst_option)
		printf(" %.8lx\t", insn);

	      print_insn (insn);
	      printf("\n");
	      	      
	      // clear our little buffer
	      for(i=0;i<10;i++)inp[i]=0;
	    }
	  else if (c == EOF)
	    {
	      break;
	    }
	  else
	    {
	      for(i=0;i<9-1;i++)inp[i]=inp[i+1];
	      inp[7]=c;
	    }
	  
	}
    }
  return 0;
}
