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

#ifdef _PRINT_IT
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
#endif



int elfsplitter (unsigned int base, unsigned int size)
{
   unsigned char *buf;
   unsigned int length,d,i,gp_ptr=0;
   unsigned int bss_start=0,bss_end=0;
   unsigned int StringSectionOffset;
   unsigned int StringSectionOffsetFound = 0;

   char tmp[6] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
   unsigned int j, k;
   int m;
   ElfHeader *elfHeader;
   Elf32_Phdr *elfProgram;
   Elf32_Shdr *elfSection;

   buf=(unsigned char*)base;

#ifdef DEBUG   
   printf("Debug: size = %d\n",size);
#endif
   
   elfHeader=(ElfHeader*)buf;

#ifdef DEBUG   
//    printf("Call strncpy\n");
//    strncpy(tmp, (char*)elfHeader->e_ident+1, 3);
//    printf("Debug: elfHeader->e_ident= %s\n",tmp);
   printf("Debug: elfHeader->e_machine= 0x%x\n",elfHeader->e_machine);
#endif


   if(strncmp((char*)elfHeader->e_ident+1,"ELF",3)) {

      printf("ERROR: Not an ELF file.\n");
      return(1);
   }
   
   if(elfHeader->e_machine != 40) {
      printf("ERROR: ELF file not targetting correct processor type\n");
      return(1);
   }

#ifdef DEBUG   
   printf("Debug: elfHeader->e_phnum=0x%x\n",elfHeader->e_phnum);
#endif

   for(i=0;i<elfHeader->e_phnum;++i) {
      elfProgram           = (Elf32_Phdr*)(buf+elfHeader->e_phoff+elfHeader->e_phentsize*i);      
      length=elfProgram->p_vaddr+elfProgram->p_memsz;
#ifdef DEBUG   
      printf("Debug: Program Length=0x%x\n",length);
#endif
   }


   /* Find the location in the file of the string section
      containing the section names
   */   
   for(i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(buf+elfHeader->e_shoff+elfHeader->e_shentsize*i);
      if (elfSection->sh_type == SHT_STRTAB && !StringSectionOffsetFound) { 
         StringSectionOffset      = elfSection->sh_offset; 
         StringSectionOffsetFound = 1;
         }
      }

   for(i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(buf+elfHeader->e_shoff+elfHeader->e_shentsize*i);

#ifdef _PRINT_IT
        if (elfSection->sh_type != SHT_NULL) {
          printf("Section name %s\n", (char*)(buf+StringSectionOffset+elfSection->sh_name));
          printf("Type %s, Size 0x%x, Start address 0x%08x, File offset 0x%x\n",
              pSHT(elfSection->sh_type), 
              elfSection->sh_size, 
              elfSection->sh_addr, 
              elfSection->sh_offset);
           }     
#endif

        /* section with non-zero bits, can be either text or data */
        if (elfSection->sh_type == SHT_PROGBITS && elfSection->sh_size != 0) {
            for (j=0; j<elfSection->sh_size; j=j+4) {
               k = j + elfSection->sh_offset;
               *(unsigned int*)(elfSection->sh_addr + j)  = 
                    (buf[k+3] << 24) | (buf[k+2] << 16) | (buf[k+1] << 8) | (buf[k+0]);
#ifdef _PRINT_IT
               if (j%0x1000 == 0) {     
                     printf("@%08x %02x%02x%02x%02x\n", 
                      (elfSection->sh_addr + j),        /* use word addresses */
                      buf[k+3], buf[k+2], buf[k+1], buf[k+0]);
                    }
#endif
               }
           }
           
        if (elfSection->sh_type == SHT_NOBITS && elfSection->sh_size != 0) {
#ifdef _PRINT_IT
            printf("// .bss Dump Zeros\n");
#endif
            for (j=elfSection->sh_offset; j<elfSection->sh_offset+elfSection->sh_size; j=j+4) {
               *(unsigned int*) (j + elfSection->sh_addr - elfSection->sh_offset) = 0;
#ifdef _PRINT_IT
               printf("@%08x 00000000\n", 
               (j + elfSection->sh_addr - elfSection->sh_offset)); /* use word addresses */
#endif
               }
           }


   }
   
   return 0;
}
