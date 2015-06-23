/*-------------------------------------------------------------------
-- TITLE: Plasma CPU test code
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 4/21/01
-- FILENAME: test.c
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--   The executable image of this file is used as input to the VHDL.
--
--   This file must not contain any global or static data since
--   there isn't a loader to relocate the .data segment and since
--   having static data causes the opcodes to begin at a different
--   location in the resulting executable file.
--
--   Save the opcodes in "code.txt".
--
--   Testing subversion.
--------------------------------------------------------------------*/
#ifndef WIN32
#undef putchar
#define putchar(C) *(volatile unsigned char*)0x20000000=(unsigned char)(C)
#endif

void print_hex(unsigned long num);

char text[]="Testing the Plasma core.\n";
char buf[20];
int xyz=0xbadbeef;
int abc;

char *strcpy2(char *s, const char *t)
{
   char *tmp=s;
   while((int)(*s++=*t++)) ;
   return(tmp);
}

static void itoa2(long n, char *s, int base, long *digits)
{
   long i,j,sign;
   unsigned long n2;
   char number[20];
   for(i=0;i<15;++i) {
      number[i]=' ';
   }
   number[15]=0;
   if(n>=0||base!=10) {
      sign=1;
   } else {
      sign=-1;
   }
   n2=n*sign;
   for(j=14;j>=0;--j) {
      i=n2%base;
      n2/=base;
      number[j]=i<10?'0'+i:'a'+i-10;
      if(n2==0&&15-j>=*digits) break;
   } 
   if(sign==-1) {
      number[--j]='-';
   }
   if(*digits==0||*digits<15-j) {
      strcpy2(s,&number[j]);
      *digits=15-j;
   } else {
      strcpy2(s,&number[15-*digits]);
   }
}

void print(long num,long base,long digits)
{
   char *ptr,buffer[128];
   itoa2(num,buffer,base,&digits);
   ptr=buffer;
   while(*ptr) {
      putchar(*ptr++);          /* Put the character out */
      if(ptr[-1]=='\n') *--ptr='\r';
   }
}              

void print_string(char *p)
{
   int i;
   for(i=0;p[i];++i) {
      putchar(p[i]);
   }
}

int prime()
{
   int i,j;
   //show all prime numbers less than 1000
   for(i=3;i<1000;i+=2) {
      for(j=3;j<i;j+=2) {
         if(i%j==0) {
            j=0;
            break;
         }
      }
      if(j) {
         print(i,10,0);
         putchar(' ');
      }
   }
   putchar('\n');
   return 0;
}

int main(void)
{
   long i,j;
   char char_buf[16];
   short short_buf[16];
   long long_buf[16];

#if 1 
   //test shift
   j=0x12345678;
   for(i=0;i<32;++i) {
      print_hex(j>>i);
      putchar(' ');
   }
   putchar('\n');
   j=0x92345678;
   for(i=0;i<32;++i) {
      print_hex(j>>i);
      putchar(' ');
   }
   putchar('\n');
   j=0x12345678;
   for(i=0;i<32;++i) {
      print_hex(j<<i);
      putchar(' ');
   }
   putchar('\n');
   putchar('\n');
#endif
  
#if 1 
   //test multiply and divide
   j=7;
   for(i=0;i<=10;++i) {
      print(j*i,10,0);
      putchar(' ');
   }
   putchar('\n');
   j=0x321;
   for(i=0;i<=5;++i) {
      print_hex(j*(i+0x12345));
      putchar(' ');
   }
   putchar('\n');
   j=0x54321;
   for(i=0;i<=5;++i) {
      print_hex(j*(i+0x123));
      putchar(' ');
   }
   putchar('\n');
   j=0x12345;
   for(i=1;i<10;++i) {
      print_hex(j/i);
      putchar(' ');
   }
   putchar('\n');
   for(i=1;i<10;++i) {
      print_hex(j%i);
      putchar(' ');
   }
   putchar('\n');
   putchar('\n');
#endif

#if 1
   //test addition and subtraction
   j=0x1234;
   for(i=0;i<10;++i) {
      print_hex(j+i);
      putchar(' ');
   }
   putchar('\n');
   for(i=0;i<10;++i) {
      print_hex(j-i);
      putchar(' ');
   }
   putchar('\n');
   putchar('\n');
#endif
  
#if 1 
   //test bit operations
   i=0x1234;
   j=0x4321;
   print_hex(i&j);
   putchar(' ');
   print_hex(i|j);
   putchar(' ');
   print_hex(i^j);
   putchar(' ');
   print_hex(~i);
   putchar(' ');
   print_hex(i+0x12);
   putchar(' ');
   print_hex(i-0x12);
   putchar('\n');
   putchar('\n');
#endif
  
#if 1 
   //test memory access
   for(i=0;i<10;++i) {
      char_buf[i]=i;
      short_buf[i]=i;
      long_buf[i]=i;
   }
   for(i=0;i<10;++i) {
      j=char_buf[i];
      print(j,10,0);
      putchar(' ');
      j=short_buf[i];
      print(j,10,0);
      putchar(' ');
      j=long_buf[i];
      print(j,10,0);
      putchar('\n');
   }
   putchar('\n');
#endif
   
   prime();
   
   putchar('d'); putchar('o'); putchar('n'); putchar('e'); putchar('\n');

   for(;;) ;
}

