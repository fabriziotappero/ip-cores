/*----------------------------------------------------------------
//                                                              //
//  amber-elfsplitter                                           //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Read in a binary elf file and write it out in               //
//  in Verilog readmem format.                                  //
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


/*
ELF File Structure
A single segment usually consist of several sections. E.g., a loadable 
read-only segment could contain sections for executable code, read-only 
data, and symbols for the dynamic linker. Relocatable files have section 
header tables. Executable files have program header tables. Shared object 
files have both. Sections are intended for further processing by a linker, 
while the segments are intended to be mapped into memory.
*/


/* #define DEBUG */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_SIZE (1024*1024*8)
#define EI_NIDENT 16

#define	SHT_NULL		0		/* sh_type */
#define	SHT_PROGBITS		1
#define	SHT_SYMTAB		2
#define	SHT_STRTAB		3
#define	SHT_RELA		4
#define	SHT_HASH		5
#define	SHT_DYNAMIC		6
#define	SHT_NOTE		7
#define	SHT_NOBITS		8
#define	SHT_REL			9
#define	SHT_SHLIB		10
#define	SHT_DYNSYM		11
#define	SHT_UNKNOWN12		12
#define	SHT_UNKNOWN13		13
#define	SHT_INIT_ARRAY		14
#define	SHT_FINI_ARRAY		15
#define	SHT_PREINIT_ARRAY	16
#define	SHT_GROUP		17
#define	SHT_SYMTAB_SHNDX	18
#define	SHT_NUM			19


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


/* Program Headers */
typedef struct {
   unsigned int p_type;     /* entry type */
   unsigned int p_offset;   /* file offset */
   unsigned int p_vaddr;    /* virtual address */
   unsigned int p_paddr;    /* physical address */
   unsigned int p_filesz;   /* file size */
   unsigned int p_memsz;    /* memory size */
   unsigned int p_flags;    /* entry flags */
   unsigned int p_align;    /* memory/file alignment */
} Elf32_Phdr;


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

int fsize(FILE *f);

void set_low(unsigned char *ptr,unsigned int address,unsigned int value)
{
   unsigned int opcode;
   opcode=*(unsigned int*)(ptr+address);
//    opcode=switch_endian_long(opcode);
   opcode=(opcode&0xffff0000)|(value&0xffff);
//    opcode=switch_endian_long(opcode);
   *(unsigned int*)(ptr+address)=opcode;
}

/*
PROGBITS: This holds program contents including code, data, and debugger information.
NOBITS: Like PROGBITS. However, it occupies no space.
SYMTAB and DYNSYM: These hold symbol table. 
STRTAB: This is a string table, like the one used in a.out.
REL and RELA:  These hold relocation information.
DYNAMIC and HASH: This holds information related to dynamic linking.
*/

#define	SHT_NULL		0		/* sh_type */
#define	SHT_PROGBITS		1
#define	SHT_SYMTAB		2
#define	SHT_STRTAB		3
#define	SHT_RELA		4
#define	SHT_HASH		5
#define	SHT_DYNAMIC		6
#define	SHT_NOTE		7
#define	SHT_NOBITS		8
#define	SHT_REL			9
#define	SHT_SHLIB		10
#define	SHT_DYNSYM		11
#define	SHT_UNKNOWN12		12
#define	SHT_UNKNOWN13		13
#define	SHT_INIT_ARRAY		14
#define	SHT_FINI_ARRAY		15
#define	SHT_PREINIT_ARRAY	16
#define	SHT_GROUP		17
#define	SHT_SYMTAB_SHNDX	18
#define	SHT_NUM			19



char SHT_NAME[80];

char* pSHT ( int sh_type )
{
   switch (sh_type) {
      case SHT_NULL         : strcpy(SHT_NAME, "SHT_NULL"); break;
      case SHT_PROGBITS     : strcpy(SHT_NAME, "SHT_PROGBITS"); break;
      case SHT_SYMTAB       : strcpy(SHT_NAME, "SHT_SYMTAB"); break;
      case SHT_STRTAB       : strcpy(SHT_NAME, "SHT_STRTAB"); break;
      case SHT_RELA         : strcpy(SHT_NAME, "SHT_RELA"); break;
      case SHT_HASH         : strcpy(SHT_NAME, "SHT_HASH"); break;
      case SHT_DYNAMIC      : strcpy(SHT_NAME, "SHT_DYNAMIC"); break;
      case SHT_NOTE         : strcpy(SHT_NAME, "SHT_NOTE"); break;
      case SHT_NOBITS       : strcpy(SHT_NAME, "SHT_NOBITS"); break;
      case SHT_REL          : strcpy(SHT_NAME, "SHT_REL"); break;
      case SHT_SHLIB        : strcpy(SHT_NAME, "SHT_SHLIB"); break;
      case SHT_DYNSYM       : strcpy(SHT_NAME, "SHT_DYNSYM"); break;
      case SHT_UNKNOWN12    : strcpy(SHT_NAME, "SHT_UNKNOWN12"); break;
      case SHT_UNKNOWN13    : strcpy(SHT_NAME, "SHT_UNKNOWN13"); break;
      case SHT_INIT_ARRAY   : strcpy(SHT_NAME, "SHT_INIT_ARRAY"); break;
      case SHT_FINI_ARRAY   : strcpy(SHT_NAME, "SHT_FINI_ARRAY"); break;
      case SHT_PREINIT_ARRAY: strcpy(SHT_NAME, "SHT_PREINIT_ARRAY"); break;
      case SHT_GROUP        : strcpy(SHT_NAME, "SHT_GROUP"); break;
      case SHT_SYMTAB_SHNDX : strcpy(SHT_NAME, "SHT_SYMTAB_SHNDX"); break;
      case SHT_NUM          : strcpy(SHT_NAME, "SHT_NUM"); break;
      default: strcpy(SHT_NAME, "???"); break;
   }
   return &SHT_NAME[0];
}



int main(int argc,char *argv[])
{
   FILE *infile,*outfile;
   unsigned char *inbuf;
   unsigned char *outbuf;
   int buf_size;
   unsigned int length,i;
   unsigned int StringSectionOffset;
   unsigned int StringSectionOffsetFound = 0;
   unsigned int outP;
   
   char filename_mem[80], filename_nopath[80];
   char tmp[6] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
   FILE *file_mem;
   unsigned int j, k, last_k;
   int m;
   ElfHeader *elfHeader;
   Elf32_Phdr *elfProgram;
   Elf32_Shdr *elfSection;
   int stack_ptr16KB_flag=1;  /*  permanently switch on the -sp16k option */
   char* ptr=argv[1];

   int infile_size;
   int boffset;
   int max_out = 0;
   
   if (argc<2){
      printf("%s ERROR: no input file specified. Quitting\n", argv[0]);
      exit(1);
      }


   infile=fopen(argv[1],"rb");
   if(infile==NULL) {
      printf("%s ERROR: Can't open %s. Quitting\n", argv[0], argv[1]);
      exit(1);
   }
   infile_size = fsize(infile);
   
   inbuf =(unsigned char*)malloc(infile_size);
   outbuf=(unsigned char*)malloc(infile_size*2);
   buf_size=fread(inbuf,1,infile_size,infile);
   fclose(infile);

   if ( buf_size != infile_size ) {
      fprintf(stderr, "%s ERROR: Input %s file length is %d bytes long, buffer read buf_size %d\n", 
      argv[0], argv[1], infile_size, buf_size);
      exit(1);
      }
      
      
   if ( infile_size > 0x1000000 ) {
      fprintf(stderr, "%s WARNING: Input %s file length is %d bytes long, greater than boot-loader can handle \n", 
      argv[0], argv[1], infile_size);
      }
      
   elfHeader=(ElfHeader*)inbuf;

#ifdef DEBUG   
   strncpy(tmp, (char*)elfHeader->e_ident+1, 3);
   printf("Debug: elfHeader->e_ident= %s\n",tmp);
   printf("Debug: elfHeader->e_machine= 0x%x\n",elfHeader->e_machine);
#endif


   if(strncmp((char*)elfHeader->e_ident+1,"ELF",3)) {

      printf("%s ERROR: Not an ELF file.\n", argv[0]);
      printf("Use the correct cross compiler for mips. Quitting\n");
      exit(1);
   }
   
   if(elfHeader->e_machine != 40) {
      printf("%s ERROR: Invalid ELF file.\n", argv[0]);
      exit(1);
   }

#ifdef DEBUG   
   printf("Debug: elfHeader->e_phnum=0x%x\n",elfHeader->e_phnum);
#endif

   for(i=0;i<elfHeader->e_phnum;++i) {
      elfProgram           = (Elf32_Phdr*)(inbuf+elfHeader->e_phoff+elfHeader->e_phentsize*i);      

      length=elfProgram->p_vaddr+elfProgram->p_memsz;
#ifdef DEBUG   
      printf("Debug: Program Length=0x%x\n",length);
#endif
   }


   /* Find the location in the file of the string section
      containing the section names
   */   
   for(i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(inbuf+elfHeader->e_shoff+elfHeader->e_shentsize*i);
      if (elfSection->sh_type == SHT_STRTAB && !StringSectionOffsetFound) { 
         StringSectionOffset      = elfSection->sh_offset; 
         StringSectionOffsetFound = 1;
         }
      }

   for(i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(inbuf+elfHeader->e_shoff+elfHeader->e_shentsize*i);

        /* Get the byte offset and use it to word-align the data */
        boffset = elfSection->sh_offset & 3;

        if (elfSection->sh_type != SHT_NULL) {
          printf("// Section name %s\n", (char*)(inbuf+StringSectionOffset+elfSection->sh_name));
          printf("//  Type %s, Size 0x%x, Start address 0x%08x, File offset 0x%x, boffset %d\n",
              pSHT(elfSection->sh_type), 
              elfSection->sh_size, 
              elfSection->sh_addr, 
              elfSection->sh_offset,
              boffset);
           }     
        

        /* section with non-zero bits, can be either text or data */
        if (elfSection->sh_type == SHT_PROGBITS && elfSection->sh_size != 0) {
            for (j=0; j<elfSection->sh_size; j++) {
               k = j + elfSection->sh_offset;
               outP = elfSection->sh_addr + j;
               outbuf[outP] = inbuf[k];
               if (outP > max_out) max_out = outP;
               }
           }
           
           
        if (elfSection->sh_type == SHT_NOBITS && elfSection->sh_size != 0) {
            printf("// .bss Dump Zeros\n");
            for (j=0; j<elfSection->sh_size; j++) {
               outP = j + elfSection->sh_addr;
               outbuf[outP] = 0;
               if (outP > max_out) max_out = outP;
               }
           }
   }

   
   for(j=0;j<max_out+3;j=j+4) {
        printf("@%08x %02x%02x%02x%02x\n", j, outbuf[j+3], outbuf[j+2], outbuf[j+1], outbuf[j+0]);
        }
        
   free(inbuf);
   free(outbuf);

   return 0;
}



/* Return the buf_size of a file in bytes */
int fsize( FILE *f )
{
    int end;

    /* Set current position at end of file */
    fseek( f, 0, SEEK_END );

    /* File size in bytes */
    end = ftell( f );

    /* Set current position at start of file */
    fseek( f, 0, SEEK_SET );

    return end;
}



