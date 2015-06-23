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
#include <unistd.h>

#include "top_if.h"
#include "verilated.h"

#ifdef INCLUDE_ELF_SUPPORT
#include <libelf.h>
#include <fcntl.h>
#include <gelf.h>
#endif

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
#define MEM_BASE             0x10000000
#define MEM_EXEC_OFFSET      0x100

//-----------------------------------------------------------------
// Locals
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// elf_load
//-----------------------------------------------------------------
#ifdef INCLUDE_ELF_SUPPORT
static int elf_load(const char *filename, unsigned int *startAddr)
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
                *startAddr = shdr->sh_addr + MEM_EXEC_OFFSET;
            }

            printf("Memory: 0x%x - 0x%x (Size=%dKB) [%s]\n", shdr->sh_addr, shdr->sh_addr + shdr->sh_size - 1, shdr->sh_size / 1024, elf_strptr(e, shstrndx, shdr->sh_name));

            if (shdr->sh_type == SHT_PROGBITS)
            {
                int i;
                for (i=0;i<shdr->sh_size;i++)
                    top_load(shdr->sh_addr + i, ((unsigned char*)data->d_buf)[i]);                
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
int main(int argc, char **argv, char **env) 
{
    int c;
    int err;
    unsigned int loadAddr = MEM_BASE;
    unsigned int execAddr = MEM_BASE + MEM_EXEC_OFFSET;
    unsigned int breakAddr = 0xFFFFFFFF;
    char *filename = NULL;
    int help = 0;
    int exitcode = 0;
    int cycles = -1;
    int intr_after = -1;

    Verilated::commandArgs(argc, argv);

    while ((c = getopt (argc, argv, "f:l:c:i:b:e:")) != -1)
    {
        switch(c)
        {
            case 'l':
                 loadAddr = strtoul(optarg, NULL, 0);
                 break;
            case 'f':
                 filename = optarg;
                 break;
            case 'c':
                 cycles = strtoul(optarg, NULL, 0);
                 break;
            case 'i':
                 intr_after = strtoul(optarg, NULL, 0);
                 break;
            case 'b':
                 breakAddr = strtoul(optarg, NULL, 0);
                 break;
            case '?':
            default:
                help = 1;    
                break;
        }
    }

    if (loadAddr < MEM_BASE)
    {
        fprintf (stderr,"Load address incorrect (0x%x)\n", loadAddr); 
        exit(-1);
    }

    if (help || filename == NULL)
    {
        fprintf (stderr,"Usage:\n");
        fprintf (stderr,"-t          = Enable program trace\n");
        fprintf (stderr,"-l 0xnnnn   = Executable load address\n");
        fprintf (stderr,"-f filename = Executable to load\n");
        fprintf (stderr,"-c num      = Max number of cycles\n");
        fprintf (stderr,"-i num      = Generate interrupt after num cycles\n");
        fprintf (stderr,"-b addr     = Break at address\n");
 
        exit(0);
    }

    top_init();

    if (strstr(filename, ".elf"))
    {
#ifdef INCLUDE_ELF_SUPPORT        
        if (!elf_load(filename, &execAddr))
        {
            fprintf (stderr,"Error: Could not open ELF file %s\n", filename);
            exit(-1);
        }
#else
        fprintf (stderr,"Error: ELF files not supported\n");
        exit(-1);
#endif
    }
    else
    {
        FILE *f;

        printf("Opening %s\n", filename);
        f = fopen(filename, "rb");
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
                unsigned int addr;

                // Read file data in
                int len = fread(buf, 1, size, f);
                buf[len] = 0;

                printf("Loading to 0x%x\n", loadAddr);
                for (addr=0;addr<len;addr++)
                    top_load(loadAddr + addr, buf[addr]);

                free(buf);
                fclose(f);
            }
        }
        else
        {
            printf("Could not read file!\n");
            exit(-1);
        }
    }

    // Setup breakpoint to stop at (or 0xFFFFFFFF if none)
    top_setbreakpoint(0, breakAddr);

    // Run
    err = top_run(execAddr, cycles, intr_after);

    // Cleanup
    top_done();

    printf("Exit\n");
    exit((err == TOP_RES_FAULT) ? 1 : 0);
}
