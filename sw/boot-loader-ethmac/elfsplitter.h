/*----------------------------------------------------------------
//                                                              //
//  elfsplitter.c                                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Used by the boot loader to split an elf file and copy it    //
//  to the correct memory locations ready for execution.        //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

#define MEM_BUF_ENTRIES 32

/*
ELF File Structure
A single segment usually consist of several sections. E.g., a loadable
read-only segment could contain sections for executable code, read-only
data, and symbols for the dynamic linker. Relocatable files have section
header tables. Executable files have program header tables. Shared object
files have both. Sections are intended for further processing by a linker,
while the segments are intended to be mapped into memory.
*/

#define EI_NIDENT               16
#define	SHT_PROGBITS		1
#define	SHT_NOBITS		8


/* Main ELF Header Table */
typedef struct {
   unsigned char  e_ident[EI_NIDENT]; /* bytes 0 to 15  */
   unsigned short e_e_type;           /* bytes 15 to 16 */
   unsigned short e_machine;          /* bytes 17 to 18 */
   unsigned int   e_version;          /* bytes 19 to 22 */
   unsigned int   e_entry;            /* bytes 23 to 26 */
   unsigned int   e_phoff;            /* bytes 27 to 30 */
   unsigned int   e_shoff;            /* bytes 31 to 34 */
   unsigned int   e_flags;            /* bytes 35 to 38 */
   unsigned short e_ehsize;           /* bytes 39 to 40 */
   unsigned short e_phentsize;        /* bytes 41 to 42 */
   unsigned short e_phnum;            /* bytes 43 to 44 (2B to 2C) */
   unsigned short e_shentsize;        /* bytes 45 to 46 */
   unsigned short e_shnum;            /* bytes 47 to 48 */
   unsigned short e_shstrndx;         /* bytes 49 to 50 */
} ElfHeader;


/* Section Headers */
typedef struct {
   unsigned int sh_name;        /* section name - index into string table */
   unsigned int sh_type;        /* SHT_... */
   unsigned int sh_flags;       /* SHF_... */
   unsigned int sh_addr;        /* virtual address */
   unsigned int sh_offset;      /* file offset */
   unsigned int sh_size;        /* section size */
   unsigned int sh_link;        /* misc info */
   unsigned int sh_info;        /* misc info */
   unsigned int sh_addralign;   /* memory alignment */
   unsigned int sh_entsize;     /* entry size if table */
} Elf32_Shdr;


/* Buffer to hold interrupt vector memory values
   Can't copy these into mem0 locations until ready to pass control
   t new program
*/
typedef struct {
    char  data;
    int   valid;
} mem_entry_t;


typedef struct {
    mem_entry_t entry [MEM_BUF_ENTRIES];
} mem_buf_t;


/* global vectors */
mem_buf_t*      elf_mem0_g;

/* function prototypes */
int elfsplitter (char*);
