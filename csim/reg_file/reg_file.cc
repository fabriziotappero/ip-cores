#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>

class reg_file
{
  public:
    reg_file(unsigned number);
    void write_reg (unsigned addr, unsigned data, bool data_vld);
    unsigned read_reg (unsigned addr);
    bool valid_reg (unsigned addr);
    void print_regs();
    ~reg_file();
  protected:
    bool *valid;
    unsigned *reg; 
    unsigned num_regs;
};

reg_file::reg_file(unsigned number)
{ 
  cout << "Begin regfile init, size = " << number << "\n";
  num_regs = number;
  valid = new bool[number];   
  reg = new unsigned[number];
  
  for (unsigned i=0;i<number;i += 1) 
    valid[i] = false;
  cout << "End regfile init\n";
  return;
}

void reg_file::write_reg (unsigned addr, unsigned data, bool data_vld)
{
  if(addr >= num_regs) {
    cout << "Invalid write address, addr = " << addr << ", max = " << num_regs-1 << ".\n";
    // throw an exception
    return;
  }
  else {
    valid[addr] = data_vld;
    reg[addr] = data;
    return;
  }
}

unsigned reg_file::read_reg (unsigned addr)
{
  if(addr >= num_regs) {
    cout << "Invalid read address, addr = " << addr << ", max = " << num_regs-1 << ".\n";
    // throw an exception
    return (0);
  }
  else 
    if (valid[addr] == false) {
      return (0);
    }
    else
      return (reg[addr]);
}  

bool reg_file::valid_reg (unsigned addr)
{
  if (addr >= num_regs) 
    return (false);
  else
    return (valid[addr]);
}


void reg_file::print_regs()
{
  for (unsigned i=0;i<num_regs;i += 1) {
    printf ("Register %d  = ",i);
    if (valid_reg(i))
      printf ("%.8x\n",reg[i]);
    else
      printf ("xxxxxxxx\n");
  }
  return;
}

reg_file::~reg_file()
{
  delete [] reg;
  delete [] valid;
}
    
/*
 *  $Id: reg_file.cc,v 1.1 2001-10-29 00:43:05 samg Exp $ 
 *  Program  : reg_file.cc 
 *  Author   : Sam Gladstone
 *  Function : reg file behavioral class for SXP processor 
 *  $Log: not supported by cvs2svn $
 */

