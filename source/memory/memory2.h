#ifndef _MEMORY2_H
#define _MEMORY2_H

#include <systemc.h>
#include <iomanip.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "../constants/elf.h"
#include "../constants/constants.h"
#include "../constants/config.h"

SC_MODULE(memory2)
{
  sc_in<bool> in_clk;
  sc_in<bool> reset;

  sc_in<sc_logic> 	memreq;
  sc_in<sc_logic> 	memrw;
  sc_in<sc_lv<2> > 	membs;
  sc_in<sc_uint<32> > 	memaddr;
  // sc_inout_rv<32> 	memdata;
  sc_in<sc_lv<32> > 	memdatawrite;
  sc_out<sc_lv<32> > 	memdataread;
  // sc_out<sc_logic> 	memhold;
  
  // Segnali per la gestioe delle eccezioni 
  sc_out<sc_logic>	addrl;		//indirizzo disallineato in lettura
  sc_out<sc_logic>	addrs;  	//indirizzo disallineato in scrittura
  sc_out<sc_logic>	page_fault;	//indirizzo mancante
  
  
  unsigned int x[MEMSIZE]; // Lower part of kuseg (starting at 0x0000_0000)
  char *memoryname;
  unsigned int pc;

  void mread();
  void mwrite();
  
  void page_fault_analyzer();
  void check_load_aligned();
  void check_store_aligned();
  

#ifdef _CC_MEMDUMP_
  int memcontents;
#endif

  typedef memory2 SC_CURRENT_USER_MODULE;
  memory2(sc_module_name name, char *contents_file)
    {
      unsigned int i = 0;
      unsigned int line;
      unsigned int codepos = 0;
      //unsigned int datasegstart = 0;
      unsigned char *buf;
      unsigned char *code;
      //char main[4];
#ifdef _CC_MEMDUMP_
      unsigned int ci = 0x00000000;

      // Create blank memory file filled with 0's
      memcontents = open("mem.bin", O_CREAT | O_RDWR, 0666);
      for (i = 0; i < (MEMSIZE/4); i++)
	write(memcontents, &ci, 4);
      close(memcontents);
#endif



      FILE *fid = fopen(contents_file, "r");
      buf = (unsigned char*)malloc(32768);
      int size = fread(buf, 1, 32768, fid);
      code = (unsigned char*)malloc(MEMSIZE);
      
      
	  memcpy(code,buf,size);
	  codepos = size;
	 
      i = 0;
      while (i < codepos)
	{
	  line  = code[i];
	  line += (code[i+1]<<8);
	  line += (code[i+2]<<16);
	  line += (code[i+3]<<24);

	  x[i>>2] = line;
	  i += 4;
	}

        SC_METHOD(mread);
        sensitive << reset;
       sensitive_neg << in_clk;
      

        SC_METHOD(mwrite);
        sensitive << reset;
        sensitive_neg << in_clk;
	
	SC_METHOD(page_fault_analyzer);
	sensitive << memaddr << memreq << memrw << membs;
	
	SC_METHOD(check_load_aligned);
	sensitive << memaddr << memreq << memrw << membs;
	
	SC_METHOD(check_store_aligned);
	sensitive << memaddr << memreq << memrw << membs;
     }
};

#endif
