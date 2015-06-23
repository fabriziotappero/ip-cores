/*--------------------------------------------------------------------
 * TITLE: Plasma DDR Initialization
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: ddr_init.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma DDR Initialization
 *    Supports 64MB (512Mb) MT46V32M16 by default.
 *    For 32 MB and 128 MB DDR parts change AddressLines and Bank shift:
 *    For 32 MB change 13->12 and 11->10.  MT46V16M16
 *    For 128 MB change 13->14 and 11->12. MT46V64M16
 *--------------------------------------------------------------------*/
#define DDR_BASE 0x10000000
#define MemoryRead(A) (*(volatile int*)(A))
#define MemoryWrite(A,V) *(volatile int*)(A)=(V)

extern int putchar(int value);
extern int puts(const char *string);
extern void print_hex(unsigned long num);

//SD_A  <= address_reg(25 downto 13);  --address row
//SD_BA <= address_reg(12 downto 11);  --bank_address
//cmd   := address_reg(6 downto 4);    --bits RAS & CAS & WE
int DdrInitData[] = {
// AddressLines    Bank        Command
   (0x000 << 13) | (0 << 11) | (7 << 4),  //CKE=1; NOP="111"
   (0x400 << 13) | (0 << 11) | (2 << 4),  //A10=1; PRECHARGE ALL="010"
#ifndef DLL_DISABLE
   (0x000 << 13) | (1 << 11) | (0 << 4),  //enable DLL; BA="01"; LMR="000"
#else
   (0x001 << 13) | (1 << 11) | (0 << 4),  //disable DLL; BA="01"; LMR="000"
#endif
   (0x121 << 13) | (0 << 11) | (0 << 4),  //reset DLL, CL=2, BL=2; LMR="000"
   (0x400 << 13) | (0 << 11) | (2 << 4),  //A10=1; PRECHARGE ALL="010" 
   (0x000 << 13) | (0 << 11) | (1 << 4),  //AUTO REFRESH="001"
   (0x000 << 13) | (0 << 11) | (1 << 4),  //AUTO REFRESH="001
   (0x021 << 13) | (0 << 11) | (0 << 4)   //clear DLL, CL=2, BL=2; LMR="000"
};

int DdrInit(void)
{
   int i, j, k=0;
   for(i = 0; i < sizeof(DdrInitData)/sizeof(int); ++i)
   {
      MemoryWrite(DDR_BASE + DdrInitData[i], 0);
      for(j = 0; j < 4; ++j)
         ++k;
   }
   for(j = 0; j < 100; ++j)
      ++k;
   k += MemoryRead(DDR_BASE);  //Enable DDR
   return k;
}

#ifdef DDR_TEST_MAIN
int main()
{
   volatile int *ptr = (int*)DDR_BASE;
   int i;

   DdrInit();

   ptr[0] = 0x12345678;
   if(ptr[0] != 0x12345678)
      putchar('X');
   for(i = 0; i < 10; ++i)
   {
      ptr[i] = i;
   }

   for(i = 0; i < 10; ++i)
   {
      if(ptr[i] != i)
         putchar('A' + i);
   }
   *(unsigned char*)DDR_BASE = 0x23;
   *(unsigned char*)(DDR_BASE+1) = 0x45;
   *(unsigned char*)(DDR_BASE+2) = 0x67;
   *(unsigned char*)(DDR_BASE+3) = 0x89;
   if(ptr[0] != 0x23456789)
      putchar('Y');
   puts("\r\ndone\r\n");
   return 0;
}
#endif
