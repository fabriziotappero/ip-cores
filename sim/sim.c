
#include<stdio.h>
#include<stdlib.h>
#include<stdarg.h>

unsigned int R[16] = {0};
unsigned int PC = 0;
unsigned int DMEM[1024];
unsigned short PMEM[1024];

int RA=0, RB=0, RD=0, SIMM6;
unsigned int IMM8=0;

unsigned int load_io[2], load_reg[2], load_address[2], is_load[2]  = {0}; 


//#define USE_DEBUG

#define VRAM_X 128
#define VRAM_Y 64
#define VRAM_SIZE (VRAM_X * VRAM_Y)

typedef union{
  unsigned char linear[VRAM_SIZE];
  unsigned char matrix[VRAM_X][VRAM_Y];
} vram_union;

vram_union global_vram;

#define VRAM global_vram.matrix
#define VMEM global_vram.linear


void usage() 
{
  printf("USAGE:\n  sim <filename>\n\n");
  exit(1);
}


void bail_out(int err, const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt); 
  printf(fmt, ap); 
  va_end(ap); 
  exit(err);
}


int bit_is_0(int pos, int val)
{
  return !(val & (1<<pos));
}

void regdump()
{
  int i,j;
#ifdef USE_DEBUG
  
  for(i=0;i<4;i++) {
    fprintf(stderr, "                    ");
    for(j=0;j<4;j++)
      fprintf(stderr, "%08x  ", R[i*4+j]);
    fprintf(stderr, "\n");
  }
#endif
}


void mem_dump ( unsigned int addr, unsigned int size )
{
  int i, j;
  char c;
  char *mem = (char*) DMEM;
#ifdef USE_DEBUG
  for ( i=0; i<(int)( size/32 ); i++ )
  {
    fprintf(stderr,"%06x:   ", ( unsigned int ) ( addr + i*32 ) );

    for ( j=0; j<32; j+=4 ) {
      fprintf(stderr,"%08x ",  * ( ( unsigned int * ) ( mem + addr + i*32 + j ) ) );
    }

    fprintf (stderr,"   ");

    for ( j=0; j<32; j++ ) {
      c = ( * ( ( char * ) ( mem + addr + i*32 + j ) ) );
      fprintf(stderr,"%c",  c<30?'.':c );
    }

    fprintf(stderr,"\n" );
  }
#endif
}


unsigned int load (unsigned int io, unsigned int addr) {
  if(!io) 
    return DMEM[addr];
  
  int temp = -1;
  
  if(addr & 0x80) { // read from UART
    if((addr&0x0f) == 1){
      while(temp == -1) 
        temp = getchar();
        printf("read from UART %2X\n", (unsigned char) temp);
      return temp;
    }
    
    if((addr&0x0f) == 0)
      return 0x03; // send+recv is ready FIXME?
  }
  
  return 0; // default when read from unknown address
}

int loaded = 0;

void store (unsigned int io, unsigned int addr, unsigned int val) {
  unsigned int i;
  
  if(!io) {
    DMEM[addr] = val;
  } else {
    fprintf(stdout, "                      storeio: 0x%02x->[0x%02x]\n", val, addr);
    if(addr & 0x8000) { 	
      if(!(addr & 0x4000)) {// write to programm memory       
        printf("->PROGRAM-MEM address: 0x%04x (full 0x%08x) data: 0x%04x  (full: 0x%08x)\n ", addr&0x3ff, addr, val&0xffff, val);
        PMEM[addr&0x3ff] = val & 0xffff;
        loaded = loaded > (addr&0x3ff)? loaded: addr&0x3ff;
      }
      else{
        VRAM[addr & 0x7f][(addr & 0x1f80) >> 7] = val & 0xff;
        
        printf("Speicher:  %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x \n", DMEM[0], DMEM[1], DMEM[2], DMEM[3], DMEM[4], DMEM[5], DMEM[6], DMEM[7], DMEM[8], DMEM[9], DMEM[10], DMEM[11], DMEM[12], DMEM[13]);
        
      }
    }else{ 
      if((addr & 0xc0) == 0x80){      	// write to UART
        printf("                           UART ad(%x): ", addr & 0x0f);
      }else if((addr & 0xc0) == 0x00) {			// wirte to LEDs	
        for(i = 0x80; i; i>>= 1) {
          putchar(i&val?'#':'-');
        }
        printf("LED: ");
      }
      //printf("%03d  0x%02x (%c)\n",val, val,val<30?'.':val); fflush(stdout);     
    }
  }
}

void decode(unsigned int instruction)
{
  RB = instruction & 0xf;
  RA = (instruction & 0xf0) >> 4;
  RD = (instruction & 0xf00) >> 8;
  IMM8 = instruction & 0xff;
  SIMM6 = (((int)instruction & 0x3f) << (32-6)) >> (32-6);
}

void arith(unsigned int instruction)
{
  int subc = (instruction & 0x7000) >> 12;
#ifdef USE_DEBUG
  fprintf(stderr, "arith: ");
#endif
  switch (subc) 
  {
    case 0: R[RD] = R[RA] + R[RB]; 
#ifdef USE_DEBUG 
    fprintf(stderr, "add ");
#endif
    break;
    case 1: R[RD] = R[RA] - R[RB]; 
#ifdef USE_DEBUG 
    fprintf(stderr, "sub ");
#endif
    break;

    case 2: R[RD] = R[RA] & R[RB]; 
#ifdef USE_DEBUG 
    fprintf(stderr, "and ");
#endif
    break;

    case 3: R[RD] = R[RA] | R[RB]; 
#ifdef USE_DEBUG 
    fprintf(stderr, "or  "); 
#endif
    break;

    case 4: R[RD] = R[RA] ^ R[RB];
#ifdef USE_DEBUG 
    fprintf(stderr, "xor ");
#endif
    break;

    case 5: R[RD] = R[RA] << ((int) R[RB]); 
#ifdef USE_DEBUG 
    fprintf(stderr, "sh  ");
#endif
    break;

    case 6: R[RD] = IMM8; 
#ifdef USE_DEBUG
    fprintf(stderr, "ldi ");
#endif
    break;

    case 7: R[RD] = (R[RD] << 8) | IMM8;
#ifdef USE_DEBUG  
    fprintf(stderr, "lsi ");
#endif
    break;
  }
#ifdef USE_DEBUG
  fprintf(stderr, "%d = %d . %d\n", RD, RA, RB);
#endif
}


void compare(unsigned int instruction)
{
  int gt = instruction & 0x2000;
  int sign = instruction & 0x1000;

  if(gt) {
    //if(sign) R[RD] = ((int)R[RA])>((int)R[RB]);
    //else R[RD] = R[RA]>R[RB];
    printf("UNKNOWN INSTRUCTIION (former compare greater)\n");
  } else {
    if(sign) R[RD] = ((int)R[RA])<((int)R[RB]);
    else R[RD] = R[RA]<R[RB];
  }
}



void execute();


void branch(unsigned int instruction)
{
  int offset = (((int) instruction & 0x0ff0) << (32-12)) >> (32-8);
  if(!!R[RB] == !!(instruction&0x1000)) {
#ifdef USE_DEBUG
    fprintf(stderr, "branch taken: %d == %d\n", R[RB], !!(instruction&0x1000));
#endif
    PC++;
    execute();
    PC += offset - 3;
  } else {
#ifdef USE_DEBUG
    fprintf(stderr, "branch NOT taken: %d == %d\n", R[RB], !!(instruction&0x1000));
#endif
  }
}

void addshift(unsigned int instruction)
{
  int ra = RD ^ ((instruction&0x80)>>4);
  if(!(instruction&0x40)) {   // add
    R[RD] = R[ra] + SIMM6;
  } else {
#ifdef USE_DEBUG
    fprintf(stderr, "shift imm %d\n", SIMM6);
#endif
    if(SIMM6<0) R[RD] = R[ra] >> (-SIMM6);
    else R[RD] = R[ra] << SIMM6;
  }
}

void special(unsigned int instruction)
{
  unsigned int rra = R[RA];
  int io_t = !!(instruction & 0x8);
  int rb = RA^(io_t<<3);  
  int sh_off = ((instruction & 0xc0) >> 6) * 8;
  int imm_mask = (instruction & 0x20)?0xffff:0xff;

  switch (instruction & 0x7) 
  {
    case 0:  // calll
#ifdef USE_DEBUG
      fprintf(stderr, "call/jump delay slot\n");
#endif
      if(io_t) R[RD] = PC+2;
      PC++;
      execute();
      PC = rra-1;
      break;
    case 1: 
      R[RD] = R[RA];
      break;
    case 2:
      is_load[0] = 1;
      load_io[0] = io_t;
      load_reg[0] = RD;      
      load_address[0] = R[RA];
      //if(io_t) R[RD] = getchar();
      //else R[RD] = DMEM[R[RA]];
      break;
    case 3:
      //fprintf(stderr, "store io:%d %d->[%d]\n", !!io_t, R[RD], R[RA]);
      //if(io_t) { printf(" %02x",R[RD],R[RD]); fflush(stdout); }
      //else DMEM[R[RA]] = R[RD];
      
      store(io_t, R[RA], R[RD]);
      
      
      break;
    case 4:
      R[RD] = (R[RB] >> (8*(R[RA]&0x3))) & 0xffff;
      break;
    case 5:
      R[RD] = (R[RB] >> (8*(R[RA]&0x3))) & 0xff;
      break;
    case 6: 
      R[RD] = (R[RD^((instruction&0x8)?8:0)] >> sh_off) & imm_mask;
      if(instruction&0x40) {
        if(imm_mask == 0xffff) R[RD] = (R[RD] << 16) >> 16;
        else R[RD] = (R[RD] << 24) >> 24;
      }
      break;
    default: 
      bail_out(1, "Unknown Operation");
      break;
  }
}

void execute()
{
  unsigned int temp;
  unsigned int instruction = PMEM[PC];
#ifdef USE_DEBUG
  fprintf(stderr, "PC: 0x%04x = 0x%04x\n", PC, PMEM[PC]);
#endif
  
  
  is_load[1] = is_load[0];
  load_reg[1] = load_reg[0];
  load_address[1] = load_address[0];
  load_io[1] = load_io[0];
  
  
  // wenn im "delayslot" von einer Load Instruktion
  // das Register, in das geladen wird, geschrieben wird (zB auch nop: l0 = l0 | l0)
  // ist der Wert zwar kurz ins registerfile geschrieben, ist aber nie sichtbar
  
  is_load[0] = 0;
  decode(instruction);
  if (bit_is_0(15, instruction)) arith(instruction);
  else if (bit_is_0(14, instruction)) compare(instruction);
  else if (bit_is_0(13, instruction)) branch(instruction);
  else if (bit_is_0(12, instruction)) addshift(instruction);
  else special(instruction);
  PC++;
  
  if(is_load[1]) 
  {     
    temp = load(load_io[1], load_address[1]);
    
    if( RD != load_reg[1]) // simuliert das problem (aber nicht haargenau, weil branch etc. nicht wirklich auf RD schreiben) 
      R[load_reg[1]] = temp;
  }
}
/**********************
 * graphic simulation *
 **********************/

unsigned char header[0x2A] = {
           0x00,0x01,0x01,0x00,0x00,0x08,0x00,0x18,
           0x00,0x00,0x00,0x00,0x80,0x02,0xE0,0x01,
           0x08,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,
           0x00,0xFF,0x00,0x00,0xFF,0xFF,0xC2,0x79,
           0x02,0xC2,0x5D,0xFC,0xFF,0xE8,0xA3,0xFF,
           0xFF,0xFF};

unsigned char pcolor(int x, int y) {
  unsigned char addr;

  addr = VRAM[x>>3][y>>3];  

  addr = VRAM[(1<<6) + ((addr & 0x0F) << 2) + ((x&0x6) >> 1)][((addr & 0x70) >> 1) + ((y & 0x07))];


  if(x & 0x01)
    return (addr & 0x07);     
  else 
    return (addr & 0x70) >> 4;
}



void sim_graphic(int num) {
  int i; int x; int y;
  char str[256];

  FILE *tgaout = 0;

  sprintf(str, "pic%04d.tga", num);
  tgaout = fopen(str, "w+");

  if(!tgaout){
    printf("picture output file");
  }
  else {
    for(i = 0; i < 0x2A; i++) {
      fputc(header[i],tgaout);
    }

    for(y = 479; y >= 0; y --)
      for(x = 0; x < 640; x++)
        fputc(pcolor(x,y), tgaout);
    
    /*
    for(y = 0; y < VRAM_Y; y++)
      for(x = 0; x < VRAM_X; x++)
        fputc(VRAM[x][y], tgaout); 
    */

    fclose(tgaout);
  }
  
}





int main(int argc, char **argv)
{
  FILE *bin;
  int running = 1;
  int x,y;
  long cycle = 0;

  if(argc<2) usage();

  bin = fopen(argv[1], "r");
  if(!bin) bail_out(1, "Binary File '%s' not found\n");

  // load programm memory
  loaded = fread(PMEM+0x40, sizeof(short), sizeof(PMEM)/sizeof(short), bin) + 0x40;
  PC = 0x40;
  
  // load video memory
  FILE *vram_dump = fopen("video.ram", "r");

  if(!vram_dump) {
    printf("cannot open video ram file video.ram (VIDEO RAM unititialized!)\n");
  } else {
    for(y = 0; y < VRAM_Y; y++)
      for(x = 0; x < VRAM_X; x++)
        VRAM[x][y] = fgetc(vram_dump);
    fclose(vram_dump);
  }

  while(running) {
    execute(); 
    regdump();
    if(PC>=loaded) running = 0;



    if((cycle % 400000) == 0)
      sim_graphic(cycle/400000);
    cycle++;

  }
  mem_dump ( 0, 2058);

  return 0;
}
