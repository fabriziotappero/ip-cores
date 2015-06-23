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

#include "amber_registers.h"
#include "address_map.h"
#include "utilities.h"
#include "line-buffer.h"
#include "timer.h"
#include "packet.h"
#include "tcp.h"
#include "telnet.h"
#include "elfsplitter.h"



int elfsplitter (char* inbuf)
{
   unsigned int i, j, k;
   ElfHeader*  elfHeader;
   Elf32_Shdr* elfSection;
   char *outbuf;
   unsigned int outP;
   int interrupt_table_written = 0;
   int interrupt_table_zero_written = 0;

   /* Create buffer to hold interrupt vector memory values
      Can't copy these into mem0 locations until ready to pass control
      t new program
   */
   elf_mem0_g = malloc(sizeof(mem_buf_t));
   for(i=0;i<MEM_BUF_ENTRIES;i++)
      elf_mem0_g->entry[i].valid = 0;


   elfHeader=(ElfHeader*)inbuf;


   if (strncmp((char*)elfHeader->e_ident+1,"ELF",3)) {
      return(1);
   }

   if (elfHeader->e_machine != 40) {
      print_serial ("%s:L%d ERROR: ELF file not targetting correct processor type.\r\n",
            __FILE__, __LINE__);
      return(1);
   }


   for (i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(inbuf+elfHeader->e_shoff+elfHeader->e_shentsize*i);

      /* section with non-zero bits, can be either text or data */
      if (elfSection->sh_type == SHT_PROGBITS && elfSection->sh_size != 0) {
         for (j=0; j<elfSection->sh_size; j++) {
            k = j + elfSection->sh_offset;
            outP         = elfSection->sh_addr + j;

            /* debug */
            if (outP >= ADR_EXEC_BASE)
               print_serial("%s:L%d ERROR: 1 outP value 0x%08x\r\n",__FILE__, __LINE__, outP);
            else if (outP > MEM_BUF_ENTRIES)
               outbuf[outP] = inbuf[k];
            else {
               elf_mem0_g->entry[outP].valid = 1;
               elf_mem0_g->entry[outP].data  = inbuf[k];
               interrupt_table_written = 1;
               }
         }
      }

      if (elfSection->sh_type == SHT_NOBITS && elfSection->sh_size != 0) {
         for (j=0; j<elfSection->sh_size; j++) {
            outP         = j + elfSection->sh_addr;

            /* debug */
            if (outP >= ADR_EXEC_BASE)
               print_serial("%s:L%d ERROR: 2 outP value 0x%08x\r\n",__FILE__, __LINE__, outP);
            else if (outP > MEM_BUF_ENTRIES)
               outbuf[outP] = 0;
            else {
               elf_mem0_g->entry[outP].valid = 1;
               elf_mem0_g->entry[outP].data  = 0;
               interrupt_table_zero_written = 1;
               }
         }
      }
   }

   return 0;
}

