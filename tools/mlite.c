/*-------------------------------------------------------------------
-- TITLE: Plasma CPU in software.  Executes MIPS(tm) opcodes.
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mlite.c
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--   Plasma CPU simulator in C code.  
--   This file served as the starting point for the VHDL code.
--   Assumes running on a little endian PC.
--------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

//#define ENABLE_CACHE
#define SIMPLE_CACHE

#define MEM_SIZE (1024*1024*2)
#define ntohs(A) ( ((A)>>8) | (((A)&0xff)<<8) )
#define htons(A) ntohs(A)
#define ntohl(A) ( ((A)>>24) | (((A)&0xff0000)>>8) | (((A)&0xff00)<<8) | ((A)<<24) )
#define htonl(A) ntohl(A)

#ifndef WIN32
//Support for Linux
#define putch putchar
#include <termios.h>
#include <unistd.h>

void Sleep(unsigned int value)
{ 
   usleep(value * 1000);
}

int kbhit(void)
{
   struct timeval tv;
   fd_set read_fd;

   tv.tv_sec=0;
   tv.tv_usec=0;
   FD_ZERO(&read_fd);
   FD_SET(0,&read_fd);
   if(select(1, &read_fd, NULL, NULL, &tv) == -1)
      return 0;
   if(FD_ISSET(0,&read_fd))
      return 1;
   return 0;
}

int getch(void)
{
   struct termios oldt, newt;
   int ch;

   tcgetattr(STDIN_FILENO, &oldt);
   newt = oldt;
   newt.c_lflag &= ~(ICANON | ECHO);
   tcsetattr(STDIN_FILENO, TCSANOW, &newt);
   ch = getchar();
   tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
   return ch;
}
#else
//Support for Windows
#include <conio.h>
extern void __stdcall Sleep(unsigned long value);
#endif

#define UART_WRITE        0x20000000
#define UART_READ         0x20000000
#define IRQ_MASK          0x20000010
#define IRQ_STATUS        0x20000020
#define CONFIG_REG        0x20000070
#define MMU_PROCESS_ID    0x20000080
#define MMU_FAULT_ADDR    0x20000090
#define MMU_TLB           0x200000a0

#define IRQ_UART_READ_AVAILABLE  0x001
#define IRQ_UART_WRITE_AVAILABLE 0x002
#define IRQ_COUNTER18_NOT        0x004
#define IRQ_COUNTER18            0x008
#define IRQ_MMU                  0x200

#define MMU_ENTRIES 4
#define MMU_MASK (1024*4-1)

typedef struct
{
   unsigned int virtualAddress;
   unsigned int physicalAddress;
} MmuEntry;

typedef struct {
   int r[32];
   int pc, pc_next, epc;
   unsigned int hi;
   unsigned int lo;
   int status;
   int userMode;
   int processId;
   int exceptionId;
   int faultAddr;
   int irqStatus;
   int skip;
   unsigned char *mem;
   int wakeup;
   int big_endian;
   MmuEntry mmuEntry[MMU_ENTRIES];
} State;

static char *opcode_string[]={
   "SPECIAL","REGIMM","J","JAL","BEQ","BNE","BLEZ","BGTZ",
   "ADDI","ADDIU","SLTI","SLTIU","ANDI","ORI","XORI","LUI",
   "COP0","COP1","COP2","COP3","BEQL","BNEL","BLEZL","BGTZL",
   "?","?","?","?","?","?","?","?",
   "LB","LH","LWL","LW","LBU","LHU","LWR","?",
   "SB","SH","SWL","SW","?","?","SWR","CACHE",
   "LL","LWC1","LWC2","LWC3","?","LDC1","LDC2","LDC3"
   "SC","SWC1","SWC2","SWC3","?","SDC1","SDC2","SDC3"
};

static char *special_string[]={
   "SLL","?","SRL","SRA","SLLV","?","SRLV","SRAV",
   "JR","JALR","MOVZ","MOVN","SYSCALL","BREAK","?","SYNC",
   "MFHI","MTHI","MFLO","MTLO","?","?","?","?",
   "MULT","MULTU","DIV","DIVU","?","?","?","?",
   "ADD","ADDU","SUB","SUBU","AND","OR","XOR","NOR",
   "?","?","SLT","SLTU","?","DADDU","?","?",
   "TGE","TGEU","TLT","TLTU","TEQ","?","TNE","?",
   "?","?","?","?","?","?","?","?"
};

static char *regimm_string[]={
   "BLTZ","BGEZ","BLTZL","BGEZL","?","?","?","?",
   "TGEI","TGEIU","TLTI","TLTIU","TEQI","?","TNEI","?",
   "BLTZAL","BEQZAL","BLTZALL","BGEZALL","?","?","?","?",
   "?","?","?","?","?","?","?","?"
};

static unsigned int HWMemory[8];


static int mem_read(State *s, int size, unsigned int address)
{
   unsigned int value=0;
   unsigned char *ptr;

   s->irqStatus |= IRQ_UART_WRITE_AVAILABLE;
   switch(address)
   {
      case UART_READ: 
         if(kbhit())
            HWMemory[0] = getch();
         s->irqStatus &= ~IRQ_UART_READ_AVAILABLE; //clear bit
         return HWMemory[0];
      case IRQ_MASK: 
         return HWMemory[1];
      case IRQ_MASK + 4:
         Sleep(10);
         return 0;
      case IRQ_STATUS: 
         if(kbhit())
            s->irqStatus |= IRQ_UART_READ_AVAILABLE;
         return s->irqStatus;
      case MMU_PROCESS_ID:
         return s->processId;
      case MMU_FAULT_ADDR:
         return s->faultAddr;
   }

   ptr = s->mem + (address % MEM_SIZE);

   if(0x10000000 <= address && address < 0x10000000 + 1024*1024)
      ptr += 1024*1024;

   switch(size) 
   {
      case 4: 
         if(address & 3)
            printf("Unaligned access PC=0x%x address=0x%x\n", (int)s->pc, (int)address);
         assert((address & 3) == 0);
         value = *(int*)ptr;
         if(s->big_endian) 
            value = ntohl(value);
         break;
      case 2:
         assert((address & 1) == 0);
         value = *(unsigned short*)ptr;
         if(s->big_endian) 
            value = ntohs((unsigned short)value);
         break;
      case 1:
         value = *(unsigned char*)ptr;
         break;
      default: 
         printf("ERROR");
   }
   return(value);
}

static void mem_write(State *s, int size, int unsigned address, unsigned int value)
{
   unsigned char *ptr;

   switch(address)
   {
      case UART_WRITE: 
         putch(value); 
         fflush(stdout);
         return;
      case IRQ_MASK:   
         HWMemory[1] = value; 
         return;
      case IRQ_STATUS: 
         s->irqStatus = value; 
         return;
      case CONFIG_REG:
         return;
      case MMU_PROCESS_ID:
         //printf("processId=%d\n", value);
         s->processId = value;
         return;
   }

   if(MMU_TLB <= address && address <= MMU_TLB+MMU_ENTRIES * 8)
   {
      //printf("TLB 0x%x 0x%x\n", address - MMU_TLB, value);
      ptr = (unsigned char*)s->mmuEntry + address - MMU_TLB;
      *(int*)ptr = value;
      s->irqStatus &= ~IRQ_MMU;
      return;
   }

   ptr = s->mem + (address % MEM_SIZE);

   if(0x10000000 <= address && address < 0x10000000 + 1024*1024)
      ptr += 1024*1024;

   switch(size) 
   {
      case 4: 
         assert((address & 3) == 0);
         if(s->big_endian) 
            value = htonl(value);
         *(int*)ptr = value;
         break;
      case 2:
         assert((address & 1) == 0);
         if(s->big_endian) 
            value = htons((unsigned short)value);
         *(short*)ptr = (unsigned short)value; 
         break;
      case 1:
         *(char*)ptr = (unsigned char)value; 
         break;
      default: 
         printf("ERROR");
   }
}

#ifdef ENABLE_CACHE
/************* Optional MMU and cache implementation *************/
/* TAG = VirtualAddress | ProcessId | WriteableBit */
unsigned int mmu_lookup(State *s, unsigned int processId, 
                         unsigned int address, int write)
{
   int i;
   unsigned int compare, tag;

   if(processId == 0 || s->userMode == 0)
      return address;
   //if(address < 0x30000000)
   //   return address;
   compare = (address & ~MMU_MASK) | (processId << 1);
   for(i = 0; i < MMU_ENTRIES; ++i)
   {
      tag = s->mmuEntry[i].virtualAddress;
      if((tag & ~1) == compare && (write == 0 || (tag & 1)))
         return s->mmuEntry[i].physicalAddress | (address & MMU_MASK);
   }
   //printf("\nMMUTlbMiss 0x%x PC=0x%x w=%d pid=%d user=%d\n", 
   //   address, s->pc, write, processId, s->userMode);
   //printf("m");
   s->exceptionId = 1;
   s->faultAddr = address & ~MMU_MASK;
   s->irqStatus |= IRQ_MMU;
   return address;
}


#define CACHE_SET_ASSOC_LN2   0
#define CACHE_SET_ASSOC       (1 << CACHE_SET_ASSOC_LN2)
#define CACHE_SIZE_LN2        (13 - CACHE_SET_ASSOC_LN2)  //8 KB
#define CACHE_SIZE            (1 << CACHE_SIZE_LN2)
#define CACHE_LINE_SIZE_LN2   2                           //4 bytes
#define CACHE_LINE_SIZE       (1 << CACHE_LINE_SIZE_LN2)

static int cacheData[CACHE_SET_ASSOC][CACHE_SIZE/sizeof(int)];
static int cacheAddr[CACHE_SET_ASSOC][CACHE_SIZE/CACHE_LINE_SIZE];
static int cacheSetNext;
static int cacheMiss, cacheWriteBack, cacheCount;

static void cache_init(void)
{
   int set, i;
   for(set = 0; set < CACHE_SET_ASSOC; ++set)
   {
      for(i = 0; i < CACHE_SIZE/CACHE_LINE_SIZE; ++i)
         cacheAddr[set][i] = 0xffff0000;
   }
}

/* Write-back cache memory tagged by virtual address and processId */
/* TAG = virtualAddress | processId | dirtyBit */
static int cache_load(State *s, unsigned int address, int write)
{
   int set, i, pid, miss, offsetAddr, offsetData, offsetMem;
   unsigned int addrTagMatch, addrPrevMatch=0;
   unsigned int addrPrev;
   unsigned int addressPhysical, tag;

   ++cacheCount;
   addrTagMatch = address & ~(CACHE_SIZE-1);
   offsetAddr = (address & (CACHE_SIZE-1)) >> CACHE_LINE_SIZE_LN2;

   /* Find match */
   miss = 1;
   for(set = 0; set < CACHE_SET_ASSOC; ++set)
   {
      addrPrevMatch = cacheAddr[set][offsetAddr] & ~(CACHE_SIZE-1);
      if(addrPrevMatch == addrTagMatch)
      {
         miss = 0;
         break;
      }
   }

   /* Cache miss? */
   if(miss)
   {
      ++cacheMiss;
      set = cacheSetNext;
      cacheSetNext = (cacheSetNext + 1) & (CACHE_SET_ASSOC-1);
   }
   //else if(write || (address >> 28) != 0x1)
   //{
   //   tag = cacheAddr[set][offsetAddr];
   //   pid = (tag & (CACHE_SIZE-1)) >> 1; 
   //   if(pid != s->processId)
   //      miss = 1;
   //}

   if(miss)
   {
      offsetData = address & (CACHE_SIZE-1) & ~(CACHE_LINE_SIZE-1);

      /* Cache line dirty? */
      if(cacheAddr[set][offsetAddr] & 1)
      {
         /* Write back cache line */
         tag = cacheAddr[set][offsetAddr];
         addrPrev = tag & ~(CACHE_SIZE-1);
         addrPrev |= address & (CACHE_SIZE-1);
         pid = (tag & (CACHE_SIZE-1)) >> 1; 
         addressPhysical = mmu_lookup(s, pid, addrPrev, 1);   //virtual->physical
         if(s->exceptionId)
            return 0;
         offsetMem = addressPhysical & ~(CACHE_LINE_SIZE-1);
         for(i = 0; i < CACHE_LINE_SIZE; i += 4)
            mem_write(s, 4, offsetMem + i, cacheData[set][(offsetData + i) >> 2]);
         ++cacheWriteBack;
      }

      /* Read cache line */
      addressPhysical = mmu_lookup(s, s->processId, address, write); //virtual->physical
      if(s->exceptionId)
         return 0;
      offsetMem = addressPhysical & ~(CACHE_LINE_SIZE-1);
      cacheAddr[set][offsetAddr] = addrTagMatch;
      for(i = 0; i < CACHE_LINE_SIZE; i += 4)
         cacheData[set][(offsetData + i) >> 2] = mem_read(s, 4, offsetMem + i);
   }
   cacheAddr[set][offsetAddr] |= write;
   return set;
}

static int cache_read(State *s, int size, unsigned int address)
{
   int set, offset;
   int value;

   if((address & 0xfe000000) != 0x10000000)
      return mem_read(s, size, address);

   set = cache_load(s, address, 0);
   if(s->exceptionId)
      return 0;
   offset = (address & (CACHE_SIZE-1)) >> 2;
   value = cacheData[set][offset];
   if(s->big_endian)
      address ^= 3;
   switch(size) 
   {
      case 2: 
         value = (value >> ((address & 2) << 3)) & 0xffff;
         break;
      case 1:
         value = (value >> ((address & 3) << 3)) & 0xff;
         break;
   }
   return value;
}

static void cache_write(State *s, int size, int unsigned address, unsigned int value)
{
   int set, offset;
   unsigned int mask;

   if((address >> 28) != 0x1) // && (s->processId == 0 || s->userMode == 0))
   {
      mem_write(s, size, address, value);
      return;
   }

   set = cache_load(s, address, 1);
   if(s->exceptionId)
      return;
   offset = (address & (CACHE_SIZE-1)) >> 2;
   if(s->big_endian)
      address ^= 3;
   switch(size) 
   {
      case 2:
         value &= 0xffff;
         value |= value << 16;
         mask = 0xffff << ((address & 2) << 3);
         break;
      case 1:
         value &= 0xff;
         value |= (value << 8) | (value << 16) | (value << 24);
         mask = 0xff << ((address & 3) << 3);
         break;
      case 4:
      default:
         mask = 0xffffffff;
         break;
   }
   cacheData[set][offset] = (value & mask) | (cacheData[set][offset] & ~mask);
}

#define mem_read cache_read
#define mem_write cache_write

#else
static void cache_init(void) {}
#endif


#ifdef SIMPLE_CACHE

//Write through direct mapped 4KB cache
#define CACHE_MISS 0x1ff
static unsigned int cacheData[1024];
static unsigned int cacheAddr[1024]; //9-bit addresses
static int cacheTry, cacheMiss, cacheInit;

static int cache_read(State *s, int size, unsigned int address)
{
   int offset;
   unsigned int value, value2, address2=address;

   if(cacheInit == 0)
   {
      cacheInit = 1;
      for(offset = 0; offset < 1024; ++offset)
         cacheAddr[offset] = CACHE_MISS;
   }

   offset = address >> 20;
   if(offset != 0x100 && offset != 0x101)
      return mem_read(s, size, address);

   ++cacheTry;
   offset = (address >> 2) & 0x3ff;
   if(cacheAddr[offset] != (address >> 12) || cacheAddr[offset] == CACHE_MISS)
   {
      ++cacheMiss;
      cacheAddr[offset] = address >> 12;
      cacheData[offset] = mem_read(s, 4, address & ~3);
   }
   value = cacheData[offset];
   if(s->big_endian)
      address ^= 3;
   switch(size) 
   {
      case 2: 
         value = (value >> ((address & 2) << 3)) & 0xffff;
         break;
      case 1:
         value = (value >> ((address & 3) << 3)) & 0xff;
         break;
   }

   //Debug testing
   value2 = mem_read(s, size, address2);
   if(value != value2)
      printf("miss match\n");
   //if((cacheTry & 0xffff) == 0) printf("\n***cache(%d,%d)\n ", cacheMiss, cacheTry);
   return value;
}

static void cache_write(State *s, int size, int unsigned address, unsigned int value)
{
   int offset;

   mem_write(s, size, address, value);

   offset = address >> 20;
   if(offset != 0x100 && offset != 0x101)
      return;

   offset = (address >> 2) & 0x3ff;
   if(size != 4)
   {
      cacheAddr[offset] = CACHE_MISS;
      return;
   }
   cacheAddr[offset] = address >> 12;
   cacheData[offset] = value;
}

#define mem_read cache_read
#define mem_write cache_write
#endif  //SIMPLE_CACHE
/************* End optional cache implementation *************/


void mult_big(unsigned int a, 
              unsigned int b,
              unsigned int *hi, 
              unsigned int *lo)
{
   unsigned int ahi, alo, bhi, blo;
   unsigned int c0, c1, c2;
   unsigned int c1_a, c1_b;

   ahi = a >> 16;
   alo = a & 0xffff;
   bhi = b >> 16;
   blo = b & 0xffff;

   c0 = alo * blo;
   c1_a = ahi * blo;
   c1_b = alo * bhi;
   c2 = ahi * bhi;

   c2 += (c1_a >> 16) + (c1_b >> 16);
   c1 = (c1_a & 0xffff) + (c1_b & 0xffff) + (c0 >> 16);
   c2 += (c1 >> 16);
   c0 = (c1 << 16) + (c0 & 0xffff);
   *hi = c2;
   *lo = c0;
}

void mult_big_signed(int a, 
                     int b,
                     unsigned int *hi, 
                     unsigned int *lo)
{
   unsigned int ahi, alo, bhi, blo;
   unsigned int c0, c1, c2;
   int c1_a, c1_b;

   ahi = a >> 16;
   alo = a & 0xffff;
   bhi = b >> 16;
   blo = b & 0xffff;

   c0 = alo * blo;
   c1_a = ahi * blo;
   c1_b = alo * bhi;
   c2 = ahi * bhi;

   c2 += (c1_a >> 16) + (c1_b >> 16);
   c1 = (c1_a & 0xffff) + (c1_b & 0xffff) + (c0 >> 16);
   c2 += (c1 >> 16);
   c0 = (c1 << 16) + (c0 & 0xffff);
   *hi = c2;
   *lo = c0;
}

//execute one cycle of a Plasma CPU
void cycle(State *s, int show_mode)
{
   unsigned int opcode;
   unsigned int op, rs, rt, rd, re, func, imm, target;
   int imm_shift, branch=0, lbranch=2, skip2=0;
   int *r=s->r;
   unsigned int *u=(unsigned int*)s->r;
   unsigned int ptr, epc, rSave;

   opcode = mem_read(s, 4, s->pc);
   op = (opcode >> 26) & 0x3f;
   rs = (opcode >> 21) & 0x1f;
   rt = (opcode >> 16) & 0x1f;
   rd = (opcode >> 11) & 0x1f;
   re = (opcode >> 6) & 0x1f;
   func = opcode & 0x3f;
   imm = opcode & 0xffff;
   imm_shift = (((int)(short)imm) << 2) - 4;
   target = (opcode << 6) >> 4;
   ptr = (short)imm + r[rs];
   r[0] = 0;
   if(show_mode) 
   {
      printf("%8.8x %8.8x ", s->pc, opcode);
      if(op == 0) 
         printf("%8s ", special_string[func]);
      else if(op == 1) 
         printf("%8s ", regimm_string[rt]);
      else 
         printf("%8s ", opcode_string[op]);
      printf("$%2.2d $%2.2d $%2.2d $%2.2d ", rs, rt, rd, re);
      printf("%4.4x", imm);
      if(show_mode == 1)
         printf(" r[%2.2d]=%8.8x r[%2.2d]=%8.8x", rs, r[rs], rt, r[rt]);
      printf("\n");
   }
   if(show_mode > 5) 
      return;
   epc = s->pc + 4;
   if(s->pc_next != s->pc + 4)
      epc |= 2;  //branch delay slot
   s->pc = s->pc_next;
   s->pc_next = s->pc_next + 4;
   if(s->skip) 
   {
      s->skip = 0;
      return;
   }
   rSave = r[rt];
   switch(op) 
   {
      case 0x00:/*SPECIAL*/
         switch(func) 
         {
            case 0x00:/*SLL*/  r[rd]=r[rt]<<re;          break;
            case 0x02:/*SRL*/  r[rd]=u[rt]>>re;          break;
            case 0x03:/*SRA*/  r[rd]=r[rt]>>re;          break;
            case 0x04:/*SLLV*/ r[rd]=r[rt]<<r[rs];       break;
            case 0x06:/*SRLV*/ r[rd]=u[rt]>>r[rs];       break;
            case 0x07:/*SRAV*/ r[rd]=r[rt]>>r[rs];       break;
            case 0x08:/*JR*/   s->pc_next=r[rs];         break;
            case 0x09:/*JALR*/ r[rd]=s->pc_next; s->pc_next=r[rs]; break;
            case 0x0a:/*MOVZ*/ if(!r[rt]) r[rd]=r[rs];   break;  /*IV*/
            case 0x0b:/*MOVN*/ if(r[rt]) r[rd]=r[rs];    break;  /*IV*/
            case 0x0c:/*SYSCALL*/ epc|=1; s->exceptionId=1; break;
            case 0x0d:/*BREAK*/   epc|=1; s->exceptionId=1; break;
            case 0x0f:/*SYNC*/ s->wakeup=1;              break;
            case 0x10:/*MFHI*/ r[rd]=s->hi;              break;
            case 0x11:/*FTHI*/ s->hi=r[rs];              break;
            case 0x12:/*MFLO*/ r[rd]=s->lo;              break;
            case 0x13:/*MTLO*/ s->lo=r[rs];              break;
            case 0x18:/*MULT*/ mult_big_signed(r[rs],r[rt],&s->hi,&s->lo); break;
            case 0x19:/*MULTU*/ mult_big(r[rs],r[rt],&s->hi,&s->lo); break;
            case 0x1a:/*DIV*/  s->lo=r[rs]/r[rt]; s->hi=r[rs]%r[rt]; break;
            case 0x1b:/*DIVU*/ s->lo=u[rs]/u[rt]; s->hi=u[rs]%u[rt]; break;
            case 0x20:/*ADD*/  r[rd]=r[rs]+r[rt];        break;
            case 0x21:/*ADDU*/ r[rd]=r[rs]+r[rt];        break;
            case 0x22:/*SUB*/  r[rd]=r[rs]-r[rt];        break;
            case 0x23:/*SUBU*/ r[rd]=r[rs]-r[rt];        break;
            case 0x24:/*AND*/  r[rd]=r[rs]&r[rt];        break;
            case 0x25:/*OR*/   r[rd]=r[rs]|r[rt];        break;
            case 0x26:/*XOR*/  r[rd]=r[rs]^r[rt];        break;
            case 0x27:/*NOR*/  r[rd]=~(r[rs]|r[rt]);     break;
            case 0x2a:/*SLT*/  r[rd]=r[rs]<r[rt];        break;
            case 0x2b:/*SLTU*/ r[rd]=u[rs]<u[rt];        break;
            case 0x2d:/*DADDU*/r[rd]=r[rs]+u[rt];        break;
            case 0x31:/*TGEU*/ break;
            case 0x32:/*TLT*/  break;
            case 0x33:/*TLTU*/ break;
            case 0x34:/*TEQ*/  break;
            case 0x36:/*TNE*/  break;
            default: printf("ERROR0(*0x%x~0x%x)\n", s->pc, opcode);
               s->wakeup=1;
         }
         break;
      case 0x01:/*REGIMM*/
         switch(rt) {
            case 0x10:/*BLTZAL*/ r[31]=s->pc_next;
            case 0x00:/*BLTZ*/   branch=r[rs]<0;    break;
            case 0x11:/*BGEZAL*/ r[31]=s->pc_next;
            case 0x01:/*BGEZ*/   branch=r[rs]>=0;   break;
            case 0x12:/*BLTZALL*/r[31]=s->pc_next;
            case 0x02:/*BLTZL*/  lbranch=r[rs]<0;   break;
            case 0x13:/*BGEZALL*/r[31]=s->pc_next;
            case 0x03:/*BGEZL*/  lbranch=r[rs]>=0;  break;
            default: printf("ERROR1\n"); s->wakeup=1;
          }
         break;
      case 0x03:/*JAL*/    r[31]=s->pc_next;
      case 0x02:/*J*/      s->pc_next=(s->pc&0xf0000000)|target; break;
      case 0x04:/*BEQ*/    branch=r[rs]==r[rt];     break;
      case 0x05:/*BNE*/    branch=r[rs]!=r[rt];     break;
      case 0x06:/*BLEZ*/   branch=r[rs]<=0;         break;
      case 0x07:/*BGTZ*/   branch=r[rs]>0;          break;
      case 0x08:/*ADDI*/   r[rt]=r[rs]+(short)imm;  break;
      case 0x09:/*ADDIU*/  u[rt]=u[rs]+(short)imm;  break;
      case 0x0a:/*SLTI*/   r[rt]=r[rs]<(short)imm;  break;
      case 0x0b:/*SLTIU*/  u[rt]=u[rs]<(unsigned int)(short)imm; break;
      case 0x0c:/*ANDI*/   r[rt]=r[rs]&imm;         break;
      case 0x0d:/*ORI*/    r[rt]=r[rs]|imm;         break;
      case 0x0e:/*XORI*/   r[rt]=r[rs]^imm;         break;
      case 0x0f:/*LUI*/    r[rt]=(imm<<16);         break;
      case 0x10:/*COP0*/
         if((opcode & (1<<23)) == 0)  //move from CP0
         {
            if(rd == 12)
               r[rt]=s->status;
            else
               r[rt]=s->epc;
         }
         else                         //move to CP0
         {
            s->status=r[rt]&1;
            if(s->processId && (r[rt]&2))
            {
               s->userMode|=r[rt]&2;
               //printf("CpuStatus=%d %d %d\n", r[rt], s->status, s->userMode);
               //s->wakeup = 1;
               //printf("pc=0x%x\n", epc);
            }
         }
         break;
//      case 0x11:/*COP1*/ break;
//      case 0x12:/*COP2*/ break;
//      case 0x13:/*COP3*/ break;
      case 0x14:/*BEQL*/   lbranch=r[rs]==r[rt];    break;
      case 0x15:/*BNEL*/   lbranch=r[rs]!=r[rt];    break;
      case 0x16:/*BLEZL*/  lbranch=r[rs]<=0;        break;
      case 0x17:/*BGTZL*/  lbranch=r[rs]>0;         break;
//      case 0x1c:/*MAD*/  break;   /*IV*/
      case 0x20:/*LB*/   r[rt]=(signed char)mem_read(s,1,ptr);  break;
      case 0x21:/*LH*/   r[rt]=(signed short)mem_read(s,2,ptr); break;
      case 0x22:/*LWL*/  
                         //target=8*(ptr&3);
                         //r[rt]=(r[rt]&~(0xffffffff<<target))|
                         //      (mem_read(s,4,ptr&~3)<<target); break;
      case 0x23:/*LW*/   r[rt]=mem_read(s,4,ptr);   break;
      case 0x24:/*LBU*/  r[rt]=(unsigned char)mem_read(s,1,ptr); break;
      case 0x25:/*LHU*/  r[rt]=(unsigned short)mem_read(s,2,ptr); break;
      case 0x26:/*LWR*/  
                         //target=32-8*(ptr&3);
                         //r[rt]=(r[rt]&~((unsigned int)0xffffffff>>target))|
                         //((unsigned int)mem_read(s,4,ptr&~3)>>target); 
                         break;
      case 0x28:/*SB*/   mem_write(s,1,ptr,r[rt]);  break;
      case 0x29:/*SH*/   mem_write(s,2,ptr,r[rt]);  break;
      case 0x2a:/*SWL*/  
                         //mem_write(s,1,ptr,r[rt]>>24);  
                         //mem_write(s,1,ptr+1,r[rt]>>16);
                         //mem_write(s,1,ptr+2,r[rt]>>8);
                         //mem_write(s,1,ptr+3,r[rt]); break;
      case 0x2b:/*SW*/   mem_write(s,4,ptr,r[rt]);  break;
      case 0x2e:/*SWR*/  break; //fixme
      case 0x2f:/*CACHE*/break;
      case 0x30:/*LL*/   r[rt]=mem_read(s,4,ptr);   break;
//      case 0x31:/*LWC1*/ break;
//      case 0x32:/*LWC2*/ break;
//      case 0x33:/*LWC3*/ break;
//      case 0x35:/*LDC1*/ break;
//      case 0x36:/*LDC2*/ break;
//      case 0x37:/*LDC3*/ break;
//      case 0x38:/*SC*/     *(int*)ptr=r[rt]; r[rt]=1; break;
      case 0x38:/*SC*/     mem_write(s,4,ptr,r[rt]); r[rt]=1; break;
//      case 0x39:/*SWC1*/ break;
//      case 0x3a:/*SWC2*/ break;
//      case 0x3b:/*SWC3*/ break;
//      case 0x3d:/*SDC1*/ break;
//      case 0x3e:/*SDC2*/ break;
//      case 0x3f:/*SDC3*/ break;
      default: printf("ERROR2 address=0x%x opcode=0x%x\n", s->pc, opcode); 
         s->wakeup=1;
   }
   s->pc_next += (branch || lbranch == 1) ? imm_shift : 0;
   s->pc_next &= ~3;
   s->skip = (lbranch == 0) | skip2;

   if(s->exceptionId)
   {
      r[rt] = rSave;
      s->epc = epc; 
      s->pc_next = 0x3c;
      s->skip = 1; 
      s->exceptionId = 0;
      s->userMode = 0;
      //s->wakeup = 1;
      return;
   }
}

void show_state(State *s)
{
   int i,j;
   printf("pid=%d userMode=%d, epc=0x%x\n", s->processId, s->userMode, s->epc);
   for(i = 0; i < 4; ++i) 
   {
      printf("%2.2d ", i * 8);
      for(j = 0; j < 8; ++j) 
      {
         printf("%8.8x ", s->r[i*8+j]);
      }
      printf("\n");
   }
   //printf("%8.8lx %8.8lx %8.8lx %8.8lx\n", s->pc, s->pc_next, s->hi, s->lo);
   j = s->pc;
   for(i = -4; i <= 8; ++i) 
   {
      printf("%c", i==0 ? '*' : ' ');
      s->pc = j + i * 4;
      cycle(s, 10);
   }
   s->pc = j;
}

void do_debug(State *s)
{
   int ch;
   int i, j=0, watch=0, addr;
   s->pc_next = s->pc + 4;
   s->skip = 0;
   s->wakeup = 0;
   show_state(s);
   ch = ' ';
   for(;;) 
   {
      if(ch != 'n')
      {
         if(watch) 
            printf("0x%8.8x=0x%8.8x\n", watch, mem_read(s, 4, watch));
         printf("1=Debug 2=Trace 3=Step 4=BreakPt 5=Go 6=Memory ");
         printf("7=Watch 8=Jump 9=Quit> ");
      }
      ch = getch();
      if(ch != 'n')
         printf("\n");
      switch(ch) 
      {
      case '1': case 'd': case ' ': 
         cycle(s, 0); show_state(s); break;
      case 'n': 
         cycle(s, 1); break;
      case '2': case 't': 
         cycle(s, 0); printf("*"); cycle(s, 10); break;
      case '3': case 's':
         printf("Count> ");
         scanf("%d", &j);
         for(i = 0; i < j; ++i) 
            cycle(s, 1);
         show_state(s);
         break;
      case '4': case 'b':
         printf("Line> ");
         scanf("%x", &j);
         printf("break point=0x%x\n", j);
         break;
      case '5': case 'g':
         s->wakeup = 0;
         cycle(s, 0);
         while(s->wakeup == 0) 
         {
            if(s->pc == j) 
               break;
            cycle(s, 0);
         }
         show_state(s);
         break;
      case 'G':
         s->wakeup = 0;
         cycle(s, 1);
         while(s->wakeup == 0) 
         {
            if(s->pc == j) 
               break;
            cycle(s, 1);
         }
         show_state(s);
         break;
      case '6': case 'm':
         printf("Memory> ");
         scanf("%x", &j);
         for(i = 0; i < 8; ++i) 
         {
            printf("%8.8x ", mem_read(s, 4, j+i*4));
         }
         printf("\n");
         break;
      case '7': case 'w':
         printf("Watch> ");
         scanf("%x", &watch);
         break;
      case '8': case 'j':
         printf("Jump> ");
         scanf("%x", &addr);
         s->pc = addr;
         s->pc_next = addr + 4;
         show_state(s);
         break;
      case '9': case 'q': 
         return;
      }
   }
}
/************************************************************/

int main(int argc,char *argv[])
{
   State state, *s=&state;
   FILE *in;
   int bytes, index;
   printf("Plasma emulator\n");
   memset(s, 0, sizeof(State));
   s->big_endian = 1;
   s->mem = (unsigned char*)malloc(MEM_SIZE);
   memset(s->mem, 0, MEM_SIZE);
   if(argc <= 1) 
   {
      printf("   Usage:  mlite file.exe\n");
      printf("           mlite file.exe B   {for big_endian}\n");
      printf("           mlite file.exe L   {for little_endian}\n");
      printf("           mlite file.exe BD  {disassemble big_endian}\n");
      printf("           mlite file.exe LD  {disassemble little_endian}\n");

      return 0;
   }
   in = fopen(argv[1], "rb");
   if(in == NULL) 
   { 
      printf("Can't open file %s!\n",argv[1]); 
      getch(); 
      return(0); 
   }
   bytes = fread(s->mem, 1, MEM_SIZE, in);
   fclose(in);
   memcpy(s->mem + 1024*1024, s->mem, 1024*1024);  //internal 8KB SRAM
   printf("Read %d bytes.\n", bytes);
   cache_init();
   if(argc == 3 && argv[2][0] == 'B') 
   {
      printf("Big Endian\n");
      s->big_endian = 1;
   }
   if(argc == 3 && argv[2][0] == 'L') 
   {
      printf("Big Endian\n");
      s->big_endian = 0;
   }
   s->processId = 0;
   if(argc == 3 && argv[2][0] == 'S') 
   {  /*make big endian*/
      printf("Big Endian\n");
      for(index = 0; index < bytes+3; index += 4) 
      {
         *(unsigned int*)&s->mem[index] = htonl(*(unsigned int*)&s->mem[index]);
      }
      in = fopen("big.exe", "wb");
      fwrite(s->mem, bytes, 1, in);
      fclose(in);
      return(0);
   }
   if(argc == 3 && argv[2][1] == 'D') 
   {  /*dump image*/
      for(index = 0; index < bytes; index += 4) {
         s->pc = index;
         cycle(s, 10);
      }
      free(s->mem);
      return(0);
   }
   s->pc = 0x0;
   index = mem_read(s, 4, 0);
   if((index & 0xffffff00) == 0x3c1c1000)
      s->pc = 0x10000000;
   do_debug(s);
   free(s->mem);
   return(0);
}

