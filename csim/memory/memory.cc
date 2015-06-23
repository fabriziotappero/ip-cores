#include <iostream.h>
#include <fstream.h>
#include <stdio.h>
#include <stdlib.h>

class memory 
{
  public:
    memory(unsigned number);
    void write_mem (unsigned addr, unsigned data, bool data_vld);
    unsigned read_mem (unsigned addr);
    bool valid_mem (unsigned addr);
    bool load_data (char file_name[256]);
    void print_mem ();
    ~memory();
  protected:
    bool *valid;
    unsigned *mem; 
    unsigned size;
};

memory::memory(unsigned number)
{ 
  cout << "Begin Memory Init, size = " << number << "\n";
  size = number;
  valid = new bool[number];   
  mem = new unsigned[number];
  
  for (unsigned i=0;i<number;i += 1) 
    valid[i] = false;
  cout << "End Memory Init\n";
  return;
}

void memory::write_mem (unsigned addr, unsigned data, bool data_vld)
{
  if(addr >= size) {
    cout << "Invalid write address, addr = " << addr << ", max = " << size-1 << ".\n";
    // throw an exception
    return;
  }
  else {
    valid[addr] = data_vld;
    mem[addr] = data;
  }
  return;
}

unsigned memory::read_mem (unsigned addr)
{
  if(addr >= size) {
    cout << "Invalid read address, addr = " << addr << ", max = " << size-1 << ".\n";
    // throw an exception
    return (0);
  }
  else 
    if (valid[addr] == false) {
      return (0);
      // generate exception
    }
    else
      return (mem[addr]);
}  

bool memory::valid_mem (unsigned addr)
{
  if(addr >= size) 
    return (false);
  else { 
    return (valid[addr]);
  }
}  

bool memory::load_data (char file_name[256])
{
  FILE *f;
  unsigned faddr;
  unsigned data;
  char rline[81];
  char xline[81];
  faddr = 0;
  f = fopen(file_name,"r");
  while (!feof(f)){
    fgets (rline,20,f);
    sprintf (xline,"0x%s",rline); 
    sscanf(xline,"%x",&data);
    write_mem(faddr,data,true);
    faddr += 1;
  }
  fclose(f);
  return (true);
}

void memory::print_mem()
{
  for (unsigned i=0;i<size;i+=1) 
    if (valid_mem(i)) 
      printf("memory location %.8x = %.8x\n",i,read_mem(i));
}

memory::~memory()
{
  delete [] mem;
  delete [] valid;
}
    
/*
 *  $Id: memory.cc,v 1.1 2001-10-27 23:58:29 samg Exp $ 
 *  Program  : memory.cc 
 *  Author   : Sam Gladstone
 *  Function : memory behavioral class for SXP processor 
 *  $Log: not supported by cvs2svn $
 */

