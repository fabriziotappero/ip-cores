#include <iostream.h>
#include "./reg_file/reg_file.cc"
#include "./memory/memory.cc"
#include "./fetch/fetch.cc"
#include "./ext/ext.cc"
#include "./alu/alu.cc"
#include "./sxp/sxp.cc"

int main ()
{
  unsigned cycle = 0;
  sxp sxp_proc;
  cout << "Starting SXP Simulation\n";
  while (sxp_proc.end_sim == false) {
  cycle += 1;
  sxp_proc.run_cycle();
  sxp_proc.print_regs();
  cout << "---------------------------\n";
  if (cycle == 20)
    sxp_proc.interupt(1);
  } 
  cout << "Ending SXP Simulation\n";
  return(0);
}

/*
 *  $Id: sxp_sim.cc,v 1.1 2001-10-29 00:53:17 samg Exp $ 
 *  Program  : sxp_sim.cc 
 *  Author   : Sam Gladstone
 *  Function : Simulate a c++ version of the SXP
 *  $Log: not supported by cvs2svn $
 */

