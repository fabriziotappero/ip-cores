/* simple boot monitor in c 
   for the openfire soc
   a.anton 27/02/2007 */
   
/* ----------------------------------------
   S{1,2,3}xxxxx --> Motorola S-record
   l		 --> load from PROM at SRAM start
   x <hex32>	 --> execute code at @
   d <hex32> <hex32> {1,2,4} --> dump starting at <hex32>, len=<hex32>, 1(bytes),2(halfw),4(words)
   w <hex32> <hex32> {1,2,4} --> write at <hex32> value=<hex32>  1(byte), 2(halfw), 4(word)
   f <hex32> <hex32> <hex32> --> fill starting at <hex32>, len=<hex32>, value=<hex32> (word)
   ---------------------------------------- */
   
#include "openfire.h"
#define SRAM_START		0x04000000

#define MAX_LINE		128
#define BYTES_PER_LINE		16

// -------------------------------------

void process_Sline(void);
void dump(unsigned, int, unsigned);
void write(unsigned, unsigned, unsigned);
void fill(unsigned, int, unsigned);
void load_promfile(unsigned);
unsigned char prom_readbyte(void);

// -------------------------------------

char banner[]   = "MONC1\r\n";
char prompt[]   = "$ ";
char linefeed[] = "\r\n";
char error[]    = "ERROR\r\n";
char nofile[]   = "No file\r\n";
char loading[]  = "Loading...\r\n";

char input_buffer[MAX_LINE]; // = "d 0000 0010 1";	// input buffer (temporal)

// -------------------------------------

void main(void)
{
  unsigned p1, p2, p3;
  char *ptr;
	
  uart1_printline(banner);
  
main_loop:
  uart1_printline(prompt);
  uart1_readline(input_buffer);
  uart1_printline(linefeed);

  switch(input_buffer[0])
  {
    case 'd' :
    case 'w' : 
    case 'f' :    
    	       ptr = gethexstring(input_buffer + 2, &p1, 8);	// start address
    	       ptr = gethexstring(ptr + 1, &p2, 8);		// lenght or value
    	       ptr = gethexstring(ptr + 1, &p3, 8);		// width=1,2,4 or value
    	       if(input_buffer[0] == 'd') 	dump(p1, p2, p3);
    	       else if(input_buffer[0] == 'w') 	write(p1, p2, p3);
    	       else 				fill(p1, p2, p3);
    	       break;
    	       
    case 'S' : process_Sline();
    	       break;
    
    case 'l' : gethexstring(input_buffer + 2, &p1, 2);	// file-id
    	       load_promfile(p1);
    	       break;
    	       
    case 'x' : gethexstring(input_buffer + 2, &p1, 8);
      	       ((void (*)(void))p1)();
    	       break;
  }   	       
  goto main_loop;
}

// --------------------------------------------------------------
// process S1, S2 and S3 records
// http://www.amelek.gda.pl/avr/uisp/srecord.htm

void process_Sline(void)
{
  int tipo = input_buffer[1] - '0';	
  unsigned rec_len, address, checksum = 0, pos, byte, tmp;

  if(tipo < 1 || tipo > 3) return;		// process 1, 2 or 3 records only

  gethexstring(input_buffer + 2, &rec_len, 2);	// number of bytes in the record (address+data+checksum)  
  checksum += rec_len;
  gethexstring(input_buffer + 4, &address, tipo == 1 ? 4 : (tipo == 2 ? 6 : 8) );	// read start address
  pos = 4 + 2 + (tipo << 1);			// 1st byte of data is at...
  rec_len -= tipo == 1 ? 2 : (tipo == 2 ? 3 : 4);
  
  tmp = address;
  while(tipo >= 0)				// compute address checksum
  {
    checksum += tmp & 0xff;
    tmp >>= 8;
    tipo--;
  }

  while(rec_len-- > 1)				// read all data bytes and store in memory
  {
    gethexstring(input_buffer + pos, &byte, 2);	// read byte
    *(unsigned char *)address++ = (unsigned char) byte;
    checksum += byte;
    pos += 2;
  }

  gethexstring(input_buffer + pos, &byte, 2);		// read checksum
  checksum += byte;
  if( (checksum & 0xff) != 0xff) uart1_printline(error);	// verify checksum  
}

// ---------- dump memory region --------------------------------
void dump(unsigned start, int len, unsigned width)
{
  unsigned n = 0, pos, v;
  while(len > 0)
  {
    if(n == 0)					// init line: current address
    {
      puthexstring(input_buffer, start, 8);
      input_buffer[8] = ' ';
      pos = 9;
    }

    if(width == 1) v = *(unsigned char *)start;		// fetch data
    else if(width == 2) v = *(unsigned short *)start;
    else v = *(unsigned *)start;
    start += width;					// next address
    
    puthexstring(input_buffer + pos,  v, width << 1);  	// data 2 ascii
    pos += (width << 1);
    input_buffer[pos++] = ' ';
    n += width;
    len -= width;
    
    if(n >= BYTES_PER_LINE) 				// end of line
    {
showline:
      input_buffer[pos++] = '\r';
      input_buffer[pos++] = '\n';
      input_buffer[pos] = 0x0;
      uart1_printline(input_buffer);
      n = 0;
    }
  }
  if(n != 0) goto showline;		// hack to print incomplete lines
}

// ---------- write data to memory -------------
void write(unsigned address, unsigned value, unsigned width)
{
  if(width == 1)  *(unsigned char *)address = (unsigned char) value;
  else if(width == 2) *(unsigned short *)address = (unsigned short) value;
  else *(unsigned *)address = value;
}

// ----------- fill memory with dword ----------
void fill(unsigned start, int len, unsigned value)
{
  while(len-- > 0) *(unsigned *)(start++) = value;
}

// ----------- load file from prom ----------
void load_promfile(unsigned file_id)
{
  unsigned char *ptr = (unsigned char *)SRAM_START;	// start of SRAM
  unsigned long status, data;
  unsigned fileno, size;

  status = *(volatile unsigned long *) PROM_READER;
  if( !(status & PROM_SYNCED) )			// not in sync .. exit
  {
    uart1_printline(nofile);
    return;
  }  
  uart1_printline(loading);
  
  fileno = prom_readbyte();			// ignore at the moment...
  size   = prom_readbyte();			// MSByte
  size <<= 8;
  size  |= prom_readbyte();
  size <<= 8;
  size  |= prom_readbyte();			// LSBbyte
  
  while(size-- > 0)				// read file
    *(unsigned char *) ptr++ = prom_readbyte();
}
 
unsigned char prom_readbyte(void)
{
  *(unsigned long *) PROM_READER = PROM_REQUEST_DATA;				// request byte
  while( !(*(volatile unsigned long *) PROM_READER & PROM_DATA_READY) );	// wait for data
  *(unsigned char *) PROM_READER = 0;
  return (unsigned char) ((*(volatile unsigned long *) PROM_READER) & PROM_DATA);// return byte 
}
