//convert.c by Steve Rhoads 4/26/01
//Now uses the ELF format (get gccmips_elf.zip) 
//set $gp and zero .sbss and .bss
//May.15.2004 add code0.hex code1.hex code2.hex code3.hex 8bitIntelHex File Generation by Tak.Sugawara
//Jan.6.2005 add Xilinx *.coe file code0.coe, code1.coe,code2.coe,code3.coe
//Apr.3.2005 -sp16k flag addition
//Apr.5.2005 -mif file addition
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_SIZE (1024*1024)
/*Assumes running on PC little endian*/
#define ntohl(A) (((A)>>24)|(((A)&0x00ff0000)>>8)|(((A)&0xff00)<<8)|((A)<<24))
#define ntohs(A) ((((A)&0xff00)>>8)|((A)<<8))

#define EI_NIDENT 16
#define SHT_PROGBITS 1
#define SHT_STRTAB 3
#define SHT_NOBITS 8

typedef struct {
   unsigned char  e_ident[EI_NIDENT];
   unsigned short e_e_type;
   unsigned short e_machine;
   unsigned long  e_version;
   unsigned long  e_entry;
   unsigned long  e_phoff;
   unsigned long  e_shoff;
   unsigned long  e_flags;
   unsigned short e_ehsize;
   unsigned short e_phentsize;
   unsigned short e_phnum;
   unsigned short e_shentsize;
   unsigned short e_shnum;
   unsigned short e_shstrndx;
} ElfHeader;

typedef struct {
   unsigned long p_type;
   unsigned long p_offset;
   unsigned long p_vaddr;
   unsigned long p_paddr;
   unsigned long p_filesz;
   unsigned long p_memsz;
   unsigned long p_flags;
   unsigned long p_align;
} Elf32_Phdr;

typedef struct {
   unsigned long sh_name;
   unsigned long sh_type;
   unsigned long sh_flags;
   unsigned long sh_addr;
   unsigned long sh_offset;
   unsigned long sh_size;
   unsigned long sh_link;
   unsigned long sh_info;
   unsigned long sh_addralign;
   unsigned long sh_entsize;
} Elf32_Shdr;

#if 0
unsigned long load(unsigned char *ptr,unsigned long address)
{
   unsigned long value;
   value=*(unsigned long*)(ptr+address);
   value=ntohl(value);
   return value;
}

unsigned short load_short(unsigned char *ptr,unsigned long address)
{
   return (ptr[address]<<8)+ptr[address+1];
}
#endif

void set_low(char *ptr,unsigned long address,unsigned long value)
{
   unsigned long opcode;
   opcode=*(unsigned long*)(ptr+address);
   opcode=ntohl(opcode);
   opcode=(opcode&0xffff0000)|(value&0xffff);
   opcode=ntohl(opcode);
   *(unsigned long*)(ptr+address)=opcode;
}

int main(int argc,char *argv[])
{
   FILE *infile,*outfile,*txtfile;
   unsigned char *buf,*code;
   long size,stack_pointer;
   unsigned long length,d,i,gp_ptr=0;
   unsigned long bss_start=0,bss_end=0;
 char filename[80];//TAK May.10.2004
 char filename_coe[80];//TAK Jan.6.2005
 char filename_mif[80];//TAK Apr.5.2005
   FILE *file;//TAK May.10.2004
   FILE *file_coe;//TAK Jan.6.2005
   FILE *file_mif;
   unsigned long j,k,sum;
   int m;
   ElfHeader *elfHeader;
   Elf32_Phdr *elfProgram;
   Elf32_Shdr *elfSection;
   int stack_ptr16KB_flag=0;
   char* ptr=argv[1];
   if (argc==2){
		if(!strcmp( argv[1],"-sp16k")){
				stack_ptr16KB_flag=1;
		}
   }	
   printf("test.exe -> code.txt & test2.exe\n");
   infile=fopen("test.exe","rb");
   if(infile==NULL) {
      printf("Can't open test.exe");
      return 0;
   }
   buf=(unsigned char*)malloc(BUF_SIZE);
   size=fread(buf,1,BUF_SIZE,infile);
   fclose(infile);
   code=(unsigned char*)malloc(BUF_SIZE);
   memset(code,0,BUF_SIZE);

   elfHeader=(ElfHeader*)buf;
   if(strncmp(elfHeader->e_ident+1,"ELF",3)) {
      printf("Error:  Not an ELF file!\n");
      printf("Use the gccmips_elf.zip from opencores/projects/plasma!\n");
      return -1;
   }

   elfHeader->e_entry=ntohl(elfHeader->e_entry);
   elfHeader->e_phoff=ntohl(elfHeader->e_phoff);
   elfHeader->e_shoff=ntohl(elfHeader->e_shoff);
   elfHeader->e_phentsize=ntohs(elfHeader->e_phentsize);
   elfHeader->e_phnum=ntohs(elfHeader->e_phnum);
   elfHeader->e_shentsize=ntohs(elfHeader->e_shentsize);
   elfHeader->e_shnum=ntohs(elfHeader->e_shnum);
   length=0;

   for(i=0;i<elfHeader->e_phnum;++i) {
      elfProgram=(Elf32_Phdr*)(buf+elfHeader->e_phoff+elfHeader->e_phentsize*i);
      elfProgram->p_offset=ntohl(elfProgram->p_offset);
      elfProgram->p_vaddr=ntohl(elfProgram->p_vaddr);
      elfProgram->p_filesz=ntohl(elfProgram->p_filesz);
      elfProgram->p_memsz=ntohl(elfProgram->p_memsz);
//      printf("[0x%x,0x%x,0x%x]\n",elfProgram->p_vaddr,elfProgram->p_offset,elfProgram->p_filesz);
      memcpy(code+elfProgram->p_vaddr,buf+elfProgram->p_offset,elfProgram->p_filesz);
      length=elfProgram->p_vaddr+elfProgram->p_memsz;
   }

   for(i=0;i<elfHeader->e_shnum;++i) {
      elfSection=(Elf32_Shdr*)(buf+elfHeader->e_shoff+elfHeader->e_shentsize*i);
      elfSection->sh_name=ntohl(elfSection->sh_name);
      elfSection->sh_type=ntohl(elfSection->sh_type);
      elfSection->sh_addr=ntohl(elfSection->sh_addr);
      elfSection->sh_offset=ntohl(elfSection->sh_offset);
      elfSection->sh_size=ntohl(elfSection->sh_size);
#if 0
      printf("{0x%x,0x%x:0x%x,0x%x,0x%x}\n",
         elfSection->sh_name,elfSection->sh_type,elfSection->sh_addr,
         elfSection->sh_offset,elfSection->sh_size);
#endif
#if 0
      if(elfSection->sh_type==SHT_PROGBITS||elfSection->sh_type==SHT_STRTAB) {
//         memcpy(code+elfSection->sh_addr,buf+elfSection->sh_offset,elfSection->sh_size);
         length=elfSection->sh_addr+elfSection->sh_size;
         bss_start=length;
      }
#endif
      if(elfSection->sh_type==SHT_PROGBITS) {
         gp_ptr=elfSection->sh_addr;
      }
      if(elfSection->sh_type==SHT_NOBITS) {
         if(bss_start==0) {
            bss_start=elfSection->sh_addr;
         }
         bss_end=elfSection->sh_addr+elfSection->sh_size;
      }
   }

   if(bss_start==length) {
      bss_start=length;
      bss_end=length+4;
   }

   /*Initialize the $gp register for sdata and sbss*/   
   gp_ptr+=0x7ff0;
   printf("gp_ptr=0x%x ",gp_ptr);
   /*modify the first opcodes in boot.asm*/
   /*modify the lui opcode*/
   set_low(code,0,gp_ptr>>16);
   /*modify the ori opcode*/
   set_low(code,4,gp_ptr&0xffff);

   /*Clear .sbss and .bss*/
   printf(".sbss=0x%x .bss_end=0x%x\n",bss_start,bss_end);
   set_low(code,8,bss_start>>16);
   set_low(code,12,bss_start&0xffff);
   set_low(code,16,bss_end>>16);
   set_low(code,20,bss_end&0xffff);
   /*Set stack pointer*/
   stack_pointer=bss_end+512;
   if(stack_ptr16KB_flag) stack_pointer=0x3f80;//Apr.4.2005
   printf("Stack pointer=0x%x\n",stack_pointer);
   
   set_low(code,24,stack_pointer>>16);//TAK
   set_low(code,28,stack_pointer&0xffff);//TAK
   /*write out code.txt*/
   outfile=fopen("test2.exe","wb");
   fwrite(code,length,1,outfile);
   fclose(outfile);

   txtfile=fopen("code.txt","w");
   for(i=0;i<=length;i+=4) {
      d=ntohl(*(unsigned long*)(code+i));
      fprintf(txtfile,"%8.8x\n",d);
   }
   fclose(txtfile);
   //TAK May.10.2004 
    strcpy(filename,"codeX.hex");
    strcpy(filename_coe,"codeX.coe");
	strcpy(filename_mif,"ram1kX.mif");
   for(i=0;i<4;++i) {
      filename[4]='0'+i;
      filename_coe[4]='0'+i;//Jan.6.2005
	  filename_mif[5]='0'+i;
      file=fopen(filename,"wb");
      file_coe=fopen(filename_coe,"wb");//Jan.6.2005
	  file_mif=fopen(filename_mif,"wb");
	  fprintf(file_coe,"memory_initialization_radix=16;\n");//Jan.6.2005
	  fprintf(file_coe,"memory_initialization_vector=\n");//Jan.6.2005
	  
      for(j=0;i+j*4*16<length;++j) {
         k=j*16;
         fprintf(file,":10%4.4x00",k);
         sum=0x10+(k>>8)+(k&0xff);
         for(k=0;k<16;++k) {
            fprintf(file,"%2.2x",code[i+j*4*16+k*4]);
            fprintf(file_coe,"%2.2x",code[i+j*4*16+k*4]);//Jan.6.2005
			for (m=7;m>=0;m--){
				fprintf(file_mif,"%1x",(code[i+j*4*16+k*4] >> m) & 1);
			}
			fprintf(file_mif,"\n");
			if (k==15 && (j+1)*4*16>=length) fprintf(file_coe,";\n");//Jan.6.2005
   			else fprintf(file_coe,",\n");//Jan.6.2005
            sum+=code[i+j*4*16+k*4];
           
         }
         sum&=0xff;
         sum=0x100-sum;
         sum&=0xff;
         fprintf(file,"%2.2x\n",sum);
      }
      fprintf(file,":00000001ff\n");
      fclose(file);
      fclose(file_coe);//Jan.6.2005
	  fclose(file_mif);
   }
   
  
   
   
   
   
   
   
   
   
   free(buf);

   return 0;
}

