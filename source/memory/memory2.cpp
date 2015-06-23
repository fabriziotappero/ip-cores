//! Memory model for 5-stage version of MIPS
//
// $Id: memory2.cpp,v 1.1 2006-01-25 17:00:11 igorloi Exp $
//

#include "memory2.h"
#include <iomanip.h>
#include <iostream.h>

//! Bla bla..
//
// Get the memory module @ memaddr
// Output to memdata...
//
void memory2::mread()
{
  sc_lv<32> fd3_map = FD3_MAP;
  sc_uint<32> uifd3_map = fd3_map;
  sc_lv<32> stop_cpu_map = STOP_CPU_MAP;
  sc_uint<32> uistop_cpu_map = stop_cpu_map;
  
  if(memaddr == uistop_cpu_map)
     sc_stop();
  else ;
       
  sc_lv<32> lmemaddr;
  sc_uint<32> imemaddr;
  sc_lv<2> byteselect;
  sc_uint<32> lmemdataread;

  if (memreq.read() == SC_LOGIC_1)
    {}

  if ((memreq.read() == 1) && (memrw.read() == 0) && (reset.read() == false))
    {
      imemaddr = memaddr.read();
      lmemaddr = memaddr.read();
      if (lmemaddr(1,0) != "00")
	{
	  // cout << "UNALIGNED ADDRESS" << endl;
	}

      byteselect = membs.read();
      if (lmemaddr(1,0) == "01") // Unaligned...
	{
	  lmemdataread = x[imemaddr >> 2];
	  if (byteselect == "01") // Select byte, zero rest
	    lmemdataread = ("000000000000000000000000", lmemdataread.range(15,8));
	  else if (byteselect == "10") // Select halfword, zero rest
	    lmemdataread = ("0000000000000000", lmemdataread.range(23,8));
	  else // Select word, this line doesn't work properly because of unalignment!
	    lmemdataread = lmemdataread;
	}
      else if (lmemaddr(1,0) == "10") // Unaligned...
	{
	  lmemdataread = x[imemaddr >> 2];
	  // cout << "test  " << lmemdataread << endl;
	  if (byteselect == "01")
	    lmemdataread = ("000000000000000000000000", lmemdataread.range(23,16));
	  else
	    lmemdataread = ("0000000000000000", lmemdataread.range(31,16));
	  // cout << "test2 " << lmemdataread << endl;
	}
      else if (lmemaddr(1,0) == "11") // Unaligned...
	{
	  lmemdataread = x[imemaddr >> 2];
	  lmemdataread = ("000000000000000000000000", lmemdataread.range(31,24));
	}
      else // Aligned!
	{
	  // cout << "go! " << byteselect << endl;
	  lmemdataread = x[imemaddr >> 2];
	  // cout << "lmemdataread = " << lmemdataread << endl;
	  if (byteselect == "01")
	    lmemdataread = ("000000000000000000000000", lmemdataread.range(7,0));
	  else if (byteselect == "10")
	    lmemdataread = ("0000000000000000", lmemdataread.range(15,0));
	  else
	    lmemdataread = lmemdataread;
	}
    }
  else
    {
      lmemdataread = WORD_ZERO;
    }
    
  memdataread = lmemdataread;
}

//! Bla bla
//
// For writing - read input from data and write to memaddr...
//
void memory2::mwrite()
{
  sc_lv<32> lmemdata;
  sc_lv<32> lmemdatawrite;
  sc_lv<32> lmemaddr;
  sc_uint<32> imemaddr;
  sc_lv<2> byteselect = membs;

#ifdef _CC_MEMDUMP_
  // For writing
  unsigned int i;
  int j;
#endif
  sc_uint<32> imemdata;

  if (memrw.read() == SC_LOGIC_1)
    {}
    
  if ((memreq.read() == 1) && (memrw.read() == 1) && (reset.read() == false))
    {
      lmemdatawrite = memdatawrite.read();

      imemaddr = memaddr.read();
      lmemaddr = memaddr.read();
      if (lmemaddr.range(1,0) != "00")
	{
	  // imemaddr = imemaddr + 4;
	}

      if (lmemaddr.range(1,0) == "00")
	{
	  lmemdata = x[imemaddr >> 2];
	  if (byteselect == "01")
	    lmemdata = (lmemdata.range(31,8), lmemdatawrite.range(7,0));
	  else if (byteselect == "10")
	    lmemdata = (lmemdata.range(31,16), lmemdatawrite.range(15,0));
	  else
	    lmemdata = lmemdatawrite;
	}
      else if (lmemaddr.range(1,0) == "01")
	{
	  lmemdata = x[imemaddr >> 2];
	  if (byteselect == "01") // Write one byte
	    lmemdata = (lmemdata.range(31,16), lmemdatawrite.range(7,0), lmemdata.range(7,0));
	  else if (byteselect == "10")
	    lmemdata = (lmemdata.range(31,24), lmemdatawrite.range(15,0), lmemdata.range(7,0));
	  else // NB! Doesn't work to write entire words unaligned!
	    lmemdata = (lmemdatawrite.range(23,0), lmemdata.range(7,0));
	}
      else if (lmemaddr.range(1,0) == "10")
	{
	  lmemdata = x[imemaddr >> 2];
	  if (byteselect == "01")
	    lmemdata = (lmemdata.range(31,24), lmemdatawrite.range(7,0), lmemdata.range(15,0));
	  else
	    lmemdata = (lmemdatawrite.range(15,0), lmemdata.range(15,0));
	}
      else // if (lmemaddr.range(1,0) == "11")
	{
	  lmemdata = x[imemaddr >> 2];
	  lmemdata = (lmemdatawrite.range(7,0), lmemdata.range(23,0));
	}

#ifdef _DEBUG_MEMORY_
      cout << memoryname << ": lmemdata = " << lmemdata << endl;
#endif
      imemdata = lmemdata;
      x[imemaddr >> 2] = imemdata;

#ifdef _CC_MEMDUMP_
      i = imemdata;
      memcontents = open("mem.bin", O_CREAT | O_RDWR, 0666);
      for (j = 0; j < 10000; j++)
	{
	  i = x[j];
	  write(memcontents, &i, 4);
	}
      close(memcontents);
#endif
    }
}

void memory2::page_fault_analyzer()
{
	if(memreq == SC_LOGIC_1)
	{
	   if(( (unsigned int) memaddr.read() )  < MEMSIZE)
	      page_fault.write(SC_LOGIC_0);
	   else 
	      page_fault.write(SC_LOGIC_1); 
	}
	else page_fault.write(SC_LOGIC_0);
}


void memory2::check_load_aligned()
{
	sc_uint<2> 	twobit;
	sc_uint<1>      onebit;
	
	twobit = (memaddr.read()).range(1,0);
	onebit = (memaddr.read()).range(0,0);
	
	if(memreq == SC_LOGIC_1 )
	{
		if(membs.read() == "00")  //accesso ad una word
		{
		   if(twobit == 0)
			addrl.write(SC_LOGIC_0);  //dato allineato
		   else
			addrl.write(SC_LOGIC_1); // dato disallineato
		}
		else  
		   if(membs.read() == "10")  // accesso ad una half word
		   {
		      if(memreq == SC_LOGIC_1)
			 if(onebit == 0 )
			    addrl.write(SC_LOGIC_0);  //dato allineato
			 else
			    addrl.write(SC_LOGIC_1); // dato disallineato
		   }
		// L'accesso a singolo byte non genera mai errori
	}
	else 
	   addrl.write(SC_LOGIC_0);
}

void memory2::check_store_aligned()
{
	sc_uint<2> 	twobit;
	sc_uint<1> 	onebit;
	
	twobit = (memaddr.read()).range(1,0);
	onebit = (memaddr.read()).range(0,0);
	
	if((memreq.read() == SC_LOGIC_1 ) && (memrw.read() == SC_LOGIC_1 ) )
	{
		if(membs.read() == "00")  //aligned data accesso a word
		{
		   if(twobit == 0)
			addrs.write(SC_LOGIC_0);  //dato allineato
		   else
			addrs.write(SC_LOGIC_1); // dato disallineato
		}
		else  
		   if(membs.read() == "10")  // accesso ad una half word
		   {
		      if(onebit == 0)
			addrs.write(SC_LOGIC_0);  //dato allineato
		      else
			addrs.write(SC_LOGIC_1); // dato disallineato
		}
		// L'accesso a singolo byte non genera mai errori
	}
	else 
	   addrs.write(SC_LOGIC_0);
}



