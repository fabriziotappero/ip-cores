#include <iostream.h>

class fetch {
  public:
    fetch();
    void set_pc(unsigned addr, bool addr_vld);
    unsigned get_pc();
    void next_pc();

  protected:
    unsigned pc;	// program counter
    unsigned pcj;	// program counter for jumps
    bool jmp;
};     

fetch::fetch()
{
  cout << "Begin fetch init \n";
  pc = 0;
  pcj = 0;
  jmp = false;
  cout << "End fetch init \n";
  return;
}

void fetch::set_pc (unsigned addr, bool addr_vld)
{
  if (addr_vld) {
    pcj = addr;
    jmp = true;
  }
  else {
    cout << "Invalid pc set\n";
    exit(1);
  }
}

unsigned fetch::get_pc()
{
 return (pc);
}

void fetch::next_pc()
{
  if (jmp)
    pc = pcj;
  else
    pc += 1;
  jmp = false;
}
 
/*
 *  $Id: fetch.cc,v 1.1 2001-10-27 23:56:28 samg Exp $ 
 *  Program  : fetch.cc 
 *  Author   : Sam Gladstone
 *  Function : fetch behavioral class for SXP processor 
 *  $Log: not supported by cvs2svn $
 */

