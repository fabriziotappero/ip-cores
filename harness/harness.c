#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define astr(s) #s
#define str(s) astr(s)

#include "../Cpu.h"

  
unsigned char port_imem_i[4];
unsigned char port_dmem_i[4];
unsigned char port_iaddr_o[4];
unsigned char port_daddr_o[4];
unsigned char port_write_data_o[4];
unsigned char port_write_enable_o[1];
unsigned char port_read_enable_o[1];
unsigned char port_reset_i[1];
unsigned char port_buserr_i[1];
unsigned char port_reset_i[1];
unsigned char port_timer_irq_i[1];
unsigned char port_extern_irq_i[1];
unsigned char port_itlb_miss_i[1];
unsigned char port_dtlb_miss_i[1];

unsigned char ***ram = NULL;
int verbose = 0;
int number = 0;
char *srec_name = NULL;

unsigned int get_long(unsigned int addr);
void put_long(unsigned int addr, unsigned int val);
unsigned char *map(unsigned int addr);

char iram[] = {
   0x18, 0x20, 0x12, 0x34,      //    l.movhi r1,0x1234
   0x9c, 0x21, 0xd6, 0xf8,      //    l.addi r1,r1,0x5678
   0x9c, 0x40, 0x00, 0x02,      //    l.addi r2,r0,0x2
   0xe0, 0x61, 0x13, 0x06,      //    l.mul r3,r1,r2
   0xd4, 0x00, 0x08, 0x00,      //    l.sw 0(r0),r1
   0x84, 0x20, 0x00, 0x00,      //    l.lwz r1,0(r0)
   0x88, 0x20, 0x00, 0x00,      //    l.lws r1,0(r0)
   0x8c, 0x20, 0x00, 0x00,      //    l.lbz r1,0(r0)
   0x90, 0x20, 0x00, 0x00,      //    l.lbs r1,0(r0)
   0x94, 0x20, 0x00, 0x00,      //    l.lhz r1,0(r0)
   0x98, 0x20, 0x00, 0x00,      //    l.lhs r1,0(r0)
   0x18, 0x80, 0x12, 0x34,      //    l.movhi r4,0x1234
   0x20, 0,    0,    0,         //    l.system
   0xdc, 0x00, 0x08, 0x00,      //    l.sh 0(r0),r1
   0xdc, 0x00, 0x08, 0x02,      //    l.sh 2(r0),r1
   0xd8, 0x00, 0x08, 0x00,      //    l.sb 0(r0),r1
   0xd8, 0x00, 0x08, 0x01,      //    l.sb 1(r0),r1
   0xd8, 0x00, 0x08, 0x02,      //    l.sb 2(r0),r1
   0xd8, 0x00, 0x08, 0x03,      //    l.sb 3(r0),r1
   0xe4, 0x82, 0x08, 0x00,      //    l.sfltu r2,r1
   0x10, 0x00, 0x00, 0x04,      //    l.bf 1c <foo>
   0x15, 0x00, 0x00, 0x00,      //    l.nop 0x0
                                //
                                // <foo1>:
   0x04, 0x00, 0x00, 0x00,      //    l.j 14 <foo1>
   0x15, 0x00, 0x00, 0x00,      //    l.nop 0x0
                                //
                                // <foo>:
   0x00, 0x00, 0x00, 0x00,      //    l.j 1c <foo>
   0x15, 0x00, 0x00, 0x00,      //    l.nop 0x0

};

char c00[] = {
  0xd4, 0x00, 0x18, 0x80,       //    l.sw 0x80(r0),r3
  0xd4, 0x00, 0x20, 0x84,       //    l.sw 0x84(r0),r4
  0xd4, 0x00, 0x28, 0x88,       //    l.sw 0x88(r0),r5
  0xd4, 0x00, 0x30, 0x8c,       //    l.sw 0x8c(r0),r6
  0xd4, 0x00, 0x38, 0x90,       //    l.sw 0x90(r0),r7
  0xd4, 0x00, 0x58, 0x94,       //    l.sw 0x94(r0),r11
  0xb5, 0x60, 0x00, 0x20,       //    l.mfspr r11,r0,0x20 (epcr)
  0xd4, 0x00, 0x58, 0x98,       //    l.sw 0x98(r0),r11
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop        c2c
  0x85, 0x60, 0x00, 0x98,       //    l.lwz r11,0x98(r0)
  0xc0, 0x00, 0x58, 0x20,       //    l.mtspr r11,r0,0x20 (epcr)
  0x85, 0x60, 0x00, 0x7c,       //    l.lwz r11,0x7c(r0)
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x24, 0x00, 0x00, 0x00,       //    l.rfe
  0x15, 0x00, 0x00, 0x00,       //    l.nop
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
  0x00, 0x00, 0x00, 0x00,       //    l.
};

void RunSyscall(void){
  printf("Running system call\n");
  switch(get_long(0x00000094)){
  case 1:
    printf("Program terminated. Return code %d\n", get_long(0x80));
    exit(0);
  case 4:
    { 
      int fd = get_long(0x80); 
      unsigned int addr = get_long(0x84); 
      int count = get_long(0x88);
      int i;

      printf("Calling write(%d, %08x, %d)\n", fd, addr, count);
      for(i = 0; i < count; i++){
//        write(fd, map(addr+i), 1);
        printf("%02x ", *map(addr+i));
        if(i%8 == 7) printf("\n");
      }
      printf("\n");
      put_long(0x7c, i);
      break;
    }
  case 0x13:
    printf("Calling lseek; ignoring\n");
    put_long(0x7c, 0);
    break;
  case 0x36:
    printf("Called IOCTL; ignoring\n");
    put_long(0x7c, 0);
    break;
  default:
    printf("Making unimplemented system call %x - panicking\n", get_long(0x94));
    exit(1);
  }
}

unsigned char *map(unsigned int addr){
  int block = (addr & 0xff000000) >> 24;
  int page =  (addr & 0x00ffe000) >> 13;
  int word =   addr & 0x00001fff;

  if(!ram){
    ram = calloc(1, 1024);
    if(!ram){
      fprintf(stderr, "Unable to allocate top memory\n");
      exit(1);
    }
  }
  if(!ram[block]){
    ram[block] = calloc(1, 8192);
    if(!ram[block]){
      fprintf(stderr, "Unable to allocate block\n");
      exit(1);
    }
  }
  if(!ram[block][page]){
    ram[block][page] = calloc(1, 8192);
    if(!ram[block][page]){
      fprintf(stderr, "Unable to allocate page\n");
      exit(1);
    }
  }
  return &ram[block][page][word];
}

unsigned int get_long(unsigned int addr){
  unsigned int val = *map(addr) << 24;
  val |= *map(addr+1) << 16;
  val |= *map(addr+2) << 8;
  val |= *map(addr+3);
  return val;
}

void put_long(unsigned int addr, unsigned int val){
  *map(addr) = (val >> 24) & 0xff;
  *map(addr+1) = (val >> 16) & 0xff;
  *map(addr+2) = (val >> 8) & 0xff;
  *map(addr+3) = val & 0xff;
}

void run_sim_cycles(int count){
  unsigned long ip;
  unsigned long dp;
  unsigned char *m;
  int i;

  for(i = 0; i < count; i++){
    ip = port_iaddr_o[3] << 24;
    ip += port_iaddr_o[2] << 16;
    ip += port_iaddr_o[1] << 8;
    ip += port_iaddr_o[0] << 0;
    m = map(ip);
    if(ip == 0xc2c) RunSyscall();
    if(verbose) printf("\n");
    if(number) printf("Cycle %d ", i);
    if(verbose) printf("Fetching instruction from %08x", ip);
    port_imem_i[3] = *m++;
    port_imem_i[2] = *m++;
    port_imem_i[1] = *m++;
    port_imem_i[0] = *m++;
    if(verbose) printf(" insn is %02x%02x%02x%02x\n",port_imem_i[3],
                                         port_imem_i[2],
                                         port_imem_i[1],
                                         port_imem_i[0]);
    dp = (port_daddr_o[3] << 24)+
         (port_daddr_o[2]<<16)+
         (port_daddr_o[1]<<8)+
          port_daddr_o[0];
    m  = map(dp);
    if(port_write_enable_o[0]){
      if(verbose) printf("   Write addr is %08x ",dp);
      if(verbose) printf("   Write data is %02x%02x%02x%02x\n",
               port_write_data_o[3],
               port_write_data_o[2],
               port_write_data_o[1],
               port_write_data_o[0]);
      if(verbose) printf("   Write enable is %02x\n",port_write_enable_o[0]);
      if(port_write_enable_o[0] & 8)
        *m = port_write_data_o[3];
      m++;
      if(port_write_enable_o[0] & 4)
        *m = port_write_data_o[2];
      m++;
      if(port_write_enable_o[0] & 2)
        *m = port_write_data_o[1];
      m++;
      if(port_write_enable_o[0] & 1)
        *m = port_write_data_o[0];
      m++;
    }
    if(port_read_enable_o[0]){
      if(verbose) printf("   Read addr is %08x ",dp);
      port_dmem_i[3] = *m++;
      port_dmem_i[2] = *m++;
      port_dmem_i[1] = *m++;
      port_dmem_i[0] = *m++;
      if(verbose) printf("   Read data is %02x%02x%02x%02x\n",
               port_dmem_i[3],
               port_dmem_i[2],
               port_dmem_i[1],
               port_dmem_i[0]);
    }

    Cpu_calc();
    Cpu_sim_sample();
    Cpu_cycle_clock();
  }
}

void LoadSrec(void){
  FILE *infile = NULL;
  int addr;
  int data;
  int len;
  int ch;
  char buf[256];
  char *p;
  int i;
  char tmp;

  infile = fopen(srec_name, "rt");
  if(!infile){
    fprintf(stderr, "Unable to open S-record file %s\n",srec_name);
    exit(1);
  }
  while(!feof(infile)){
    if(!fgets(buf, 256, infile)) break;
    if(buf[0] == 'S'){
      switch(buf[1]){
        case '0':
          break;
        case '1':
          /* Get the length of the record */
          tmp = buf[4];
          buf[4] = 0;
          len = strtol(&buf[2], NULL, 16);
          buf[4] = tmp;
          /* Get the address */
          tmp = buf[8];
          buf[8] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[8] = tmp;
          /* Get the data */
          for(i = 0; i < len-1; i++){
            tmp = buf[8+2*i+2];
            buf[8+2*i+2] = 0;
            data = strtol(&buf[8+2*i], NULL, 16);
            buf[8+2*i+2] = tmp;
            *map(addr++) = data;
          }
          break;
        case '2':
          /* Get the length of the record */
          tmp = buf[4];
          buf[4] = 0;
          len = strtol(&buf[2], NULL, 16);
          buf[4] = tmp;
          /* Get the address */
          tmp = buf[10];
          buf[10] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[10] = tmp;
          /* Get the data */
          for(i = 0; i < len-1; i++){
            tmp = buf[10+2*i+2];
            buf[10+2*i+2] = 0;
            data = strtol(&buf[10+2*i], NULL, 16);
            buf[10+2*i+2] = tmp;
            *map(addr++) = data;
          }
          break;
        case '3':
          /* Get the length of the record */
          tmp = buf[4];
          buf[4] = 0;
          len = strtol(&buf[2], NULL, 16);
          buf[4] = tmp;
          /* Get the address */
          tmp = buf[12];
          buf[12] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[12] = tmp;
          /* Get the data */
          for(i = 0; i < len-1; i++){
            tmp = buf[12+2*i+2];
            buf[12+2*i+2] = 0;
            data = strtol(&buf[12+2*i], NULL, 16);
            buf[12+2*i+2] = tmp;
            *map(addr++) = data;
          }
          break;
        case '4':
          break;
        case '5':
          break;
        case '6':
          break;
        case '7':
          /* Get the address */
          tmp = buf[12];
          buf[12] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[12] = tmp;
          if(addr){
            *map(0)  = 0x18;   // l.movhi r1,hi(start addr)
            *map(1)  = 0x20;
            *map(2)  = (addr >> 24) & 0xff;
            *map(3)  = (addr >> 16) & 0xff;
            *map(4)  = 0xa8;  // l.ori r1,r1,lo(start addr)
            *map(5)  = 0x21;
            *map(6)  = (addr >> 8) & 0xff;
            *map(7)  = addr & 0xff;
            *map(8)  = 0x44;  // l.jr r1
            *map(9)  = 0x00;
            *map(10) = 0x08;
            *map(11) = 0x00;
            *map(12) = 0x18;  // l.movhi r1,0xffff
            *map(13) = 0x20;
            *map(14) = 0xff;
            *map(15) = 0xff;
          }
          break;
        case '8':
          /* Get the address */
          tmp = buf[10];
          buf[10] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[10] = tmp;
          if(addr){
            if(addr & 0x00008000) addr += 0x00010000;
            *map(0)  = 0x18;
            *map(1)  = 0x20;
            *map(2)  = (addr >> 24) & 0xff;
            *map(3)  = (addr >> 16) & 0xff;
            *map(4)  = 0xa8;
            *map(5)  = 0x21;
            *map(6)  = (addr >> 8) & 0xff;
            *map(7)  = addr & 0xff;
            *map(8)  = 0x44;
            *map(9)  = 0x00;
            *map(10) = 0x08;
            *map(11) = 0x00;
            *map(12) = 0x15;
            *map(13) = 0x00;
            *map(14) = 0x00;
            *map(15) = 0x00;
          }
          break;
        case '9':
          /* Get the address */
          tmp = buf[8];
          buf[8] = 0;
          addr = strtol(&buf[4], NULL, 16);
          buf[8] = tmp;
          if(addr){
            if(addr & 0x00008000) addr += 0x00010000;
            *map(0)  = 0x18;
            *map(1)  = 0x20;
            *map(2)  = (addr >> 24) & 0xff;
            *map(3)  = (addr >> 16) & 0xff;
            *map(4)  = 0xa8;
            *map(5)  = 0x21;
            *map(6)  = (addr >> 8) & 0xff;
            *map(7)  = addr & 0xff;
            *map(8)  = 0x44;
            *map(9)  = 0x00;
            *map(10) = 0x08;
            *map(11) = 0x00;
            *map(12) = 0x15;
            *map(13) = 0x00;
            *map(14) = 0x00;
            *map(15) = 0x00;
          }
          break;
        default:
          fprintf(stderr, "Malformed S-record file %s\n",srec_name);
          exit(1);
      }
    }
  }
}

int main(int argc, char *argv[]){
  int cycles = 20;
  int i;
  char *addr;

  for(i = 0; i < sizeof(iram); i++){
    addr = map(i);
    *addr = iram[i];
  }
  for(i = 0; i < sizeof(c00); i++){
    addr = map(i+0xc00);
    *addr = c00[i];
  }

  while(*++argv){
    if(!strncmp(*argv, "-c", 2)){
      if(argv[0][2])
        cycles = strtol(&argv[0][2], NULL, 10);
      else
        cycles = strtol((++argv)[0], NULL, 10);
      continue;
    }
    if(!strncmp(*argv, "-v", 2)){
      verbose++;
      continue;
    }
    if(!strncmp(*argv, "-n", 2)){
      number++;
      continue;
    }
    if(argv[0][0] == '-'){
      fprintf(stderr, "Unknown argument %s\n",*argv);
      exit(1);
    }
    srec_name = *argv;
    LoadSrec();
  }
  Cpu_ports(port_imem_i,
            port_dmem_i,
            port_iaddr_o,
            port_daddr_o,
            port_write_data_o,
            port_write_enable_o,
            port_read_enable_o,
            port_reset_i,
            port_buserr_i,
            port_timer_irq_i,
            port_extern_irq_i,
            port_itlb_miss_i,
            port_dtlb_miss_i);
  Cpu_init();
  Cpu_sim_init("Cpu.vcd");
  port_reset_i[0] = 1;
    Cpu_calc();
    Cpu_sim_sample();
    Cpu_cycle_clock();
  port_reset_i[0] = 0;
  run_sim_cycles(cycles);
  Cpu_sim_end();
  return 0;
}

