//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "or32.h"

#include "periph_timer.h"

#ifdef WIN32
#include "getopt_win32.h"
#else
#include <unistd.h>
#endif

#ifdef INCLUDE_ELF_SUPPORT
#include <libelf.h>
#include <fcntl.h>
#include <gelf.h>
#endif

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
#define DEFAULT_MEM_BASE            0x10000000
#define DEFAULT_MEM_SIZE            (10 << 20)
#define DEFAULT_LOAD_ADDR           0x10000000
#define DEFAULT_FILENAME            NULL

//-----------------------------------------------------------------
// Locals
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// elf_load
//-----------------------------------------------------------------
#ifdef INCLUDE_ELF_SUPPORT
static int elf_load(OR32 *sim, const char *filename, unsigned int *startAddr)
{
    int fd;
    Elf * e;
    Elf_Kind ek;
    Elf_Scn *scn;
    Elf_Data *data;
    Elf32_Shdr *shdr;
    size_t shstrndx;

    if (elf_version ( EV_CURRENT ) == EV_NONE)
        return 0;

    if ((fd = open ( filename , O_RDONLY , 0)) < 0)
        return 0;

    if ((e = elf_begin ( fd , ELF_C_READ, NULL )) == NULL)
        return 0;
    
    ek = elf_kind ( e );
    if (ek != ELF_K_ELF)
        return 0;

    // Get section name header index
    if (elf_getshdrstrndx(e, &shstrndx)!=0)
        return 0;

    int section_idx = 0;
    while ((scn = elf_getscn(e, section_idx)) != NULL)
    {
        shdr = elf32_getshdr(scn);

        // Section which need loading (.text, .bss, .data, etc)
        if ((shdr->sh_type == SHT_PROGBITS || shdr->sh_type == SHT_NOBITS) && 
            (shdr->sh_flags & SHF_EXECINSTR || shdr->sh_flags & SHF_ALLOC)
           )
        {
            data = elf_getdata(scn, NULL);

            // .text section?
            if (elf_strptr(e, shstrndx, shdr->sh_name) && startAddr &&
                strcmp(elf_strptr(e, shstrndx, shdr->sh_name), ".text") == 0)
            {
                *startAddr = shdr->sh_addr;
            }

            // Create some memory for this section
            if (!sim->CreateMemory(shdr->sh_addr, shdr->sh_size))
                return 0;

            printf("Memory: 0x%x - 0x%x (Size=%dKB) [%s]\n", shdr->sh_addr, shdr->sh_addr + shdr->sh_size - 1, shdr->sh_size / 1024, elf_strptr(e, shstrndx, shdr->sh_name));

            if (shdr->sh_type == SHT_PROGBITS)
            {
                if (!sim->Load(shdr->sh_addr, (unsigned char*)data->d_buf, data->d_size))
                    return 0;
            }
        }

        section_idx++;
    }    

    elf_end ( e );
    close ( fd );
    
    return 1;
}
#endif
//-----------------------------------------------------------------
// main
//-----------------------------------------------------------------
int main(int argc, char *argv[])
{
    int c;
    unsigned int loadAddr = DEFAULT_LOAD_ADDR;
    unsigned int memBase = DEFAULT_MEM_BASE;
    unsigned int memSize = DEFAULT_MEM_SIZE;
    unsigned int startAddr = DEFAULT_MEM_BASE + VECTOR_RESET;
    int max_cycles = -1;
    char *filename = DEFAULT_FILENAME;
    char *elf_file = NULL;
    int help = 0;
    int trace = 0;
    unsigned int trace_mask = 1;
    int exitcode = -1;
    int mem_trace = 0;
    unsigned int trace_enable_pc = 0xFFFFFFFF;
    unsigned int stop_pc = 0xFFFFFFFF;    
    OR32 *sim = NULL;

    while ((c = getopt (argc, argv, "tv:l:b:s:f:c:x:nme:d:z:k:r:")) != -1)
    {
        switch(c)
        {
            case 't':
                 trace = 1;
                 break;
            case 'v':
                 trace_mask = strtoul(optarg, NULL, 0);
                 break;
            case 'l':
                 loadAddr = strtoul(optarg, NULL, 0);
                 break;
            case 'b':
                 memBase = strtoul(optarg, NULL, 0);
                 break;
            case 's':
                 memSize = strtoul(optarg, NULL, 0);
                 break;
            case 'x':
                 startAddr = strtoul(optarg, NULL, 0);
                 break;
            case 'k':
                 trace_enable_pc = strtoul(optarg, NULL, 0);
                 break;
            case 'r':
                 stop_pc = strtoul(optarg, NULL, 0);
                 break;
            case 'f':
                 filename = optarg;
                 break;
#ifdef INCLUDE_ELF_SUPPORT                  
            case 'e':
                 elf_file = optarg;
                 break;
#endif                 
            case 'c':
                 max_cycles = (int)strtoul(optarg, NULL, 0);
                 break;
            case 'm':
                 mem_trace = 1;
                 break;               
            case '?':
            default:
                help = 1;   
                break;
        }
    }

    if (help || (filename == NULL && elf_file == NULL))
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-f filename.bin = Executable to load (binary)\n");
#ifdef INCLUDE_ELF_SUPPORT        
        fprintf (stderr,"-e filename.elf = Executable to load (ELF)\n");
#endif
        fprintf (stderr,"-t              = Enable program trace\n");
        fprintf (stderr,"-v 0xX          = Trace Mask\n");
        fprintf (stderr,"-b 0xnnnn       = Memory base address\n");
        fprintf (stderr,"-s 0xnnnn       = Memory size\n");
        fprintf (stderr,"-l 0xnnnn       = Executable load address\n");     
        fprintf (stderr,"-x 0xnnnn       = Executable boot address\n");     
        fprintf (stderr,"-c nnnn         = Max instructions to execute\n");
        fprintf (stderr,"-k 0xnnnn       = Trace enable PC\n");
 
        exit(-1);
    }


    if (elf_file)
    {
#ifdef INCLUDE_ELF_SUPPORT                
        sim = new OR32(false);
        sim->AttachPeripheral(new TimerPeripheral());   

        if (elf_load(sim, elf_file, &memBase))
        {
            int cycles = 0;

            sim->Reset(memBase + VECTOR_RESET);

            if (trace & trace_enable_pc == 0xFFFFFFFF)
                sim->EnableTrace(trace_mask);

            if (mem_trace)
            {
                printf("Memory trace enabled\n");
                sim->EnableMemoryTrace();
            }            

            printf("Execute from 0x%x\n", memBase + VECTOR_RESET);
            while (!sim->GetBreak() && !sim->GetFault() && sim->GetPC() != stop_pc)
            {
                sim->Step();
                cycles++;

                if (max_cycles != -1 && max_cycles == cycles)
                    break;

                if (trace)
                {
                    if (sim->GetPC() == trace_enable_pc)
                        sim->EnableTrace(trace_mask);
                }
            }        

            // Show execution stats
            sim->DumpStats();

            // Fault occurred?
            if (sim->GetFault())
                exitcode = 1;
            else
                exitcode = 0;
        }
        else
            fprintf (stderr,"Error: Could not open ELF file %s\n", elf_file);

        delete sim;

        return exitcode;
#else
        fprintf (stderr,"Error: ELF files not supported\n");
        return -1;        
#endif
    }
    else
    {
        sim = new OR32(memBase, memSize, false);
        sim->AttachPeripheral(new TimerPeripheral());
                    
        sim->Reset(startAddr);

        if (trace)
            sim->EnableTrace(trace_mask);

        if (mem_trace)
        {
            printf("Memory trace enabled\n");
            sim->EnableMemoryTrace();
        }

        FILE *f = fopen(filename, "rb");
        if (f)
        {
            long size;
            char *buf;

            // Get size
            fseek(f, 0, SEEK_END);
            size = ftell(f);
            rewind(f);

            buf = (char*)malloc(size+1);
            if (buf)
            {
                int wait_for_input = 0;

                // Read file data in
                int len = fread(buf, 1, size, f);
                buf[len] = 0;

                if (sim->Load(loadAddr, (unsigned char *)buf, len))
                {
                    int cycles = 0;

                    while (!sim->GetBreak() && !sim->GetFault() && sim->GetPC() != stop_pc)
                    {
                        sim->Step();
                        cycles++;

                        if (max_cycles != -1 && max_cycles == cycles)
                            break;

                        if (trace)
                        {
                            if (sim->GetPC() == trace_enable_pc)
                                sim->EnableTrace(trace_mask);
                        }
                    }   
                }
                else
                    fprintf (stderr,"Error: Could not load image to memory\n");

                free(buf);
                fclose(f);
            }
            // Show execution stats
            sim->DumpStats();

            // Fault occurred?
            if (sim->GetFault())
                exitcode = 1;
            else
                exitcode = 0;
        }
        else
            fprintf (stderr,"Error: Could not open %s\n", filename);

        delete sim;
    }    

    return exitcode;
}

