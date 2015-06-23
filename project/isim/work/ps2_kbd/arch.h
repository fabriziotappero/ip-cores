////////////////////////////////////////////////////////////////////////////////
//   ____  ____   
//  /   /\/   /  
// /___/  \  /   
// \   \   \/  
//  \   \        Copyright (c) 2003-2004 Xilinx, Inc.
//  /   /        All Right Reserved. 
// /---/   /\     
// \   \  /  \  
//  \___\/\___\
////////////////////////////////////////////////////////////////////////////////

#ifndef H_Work_ps2_kbd_arch_H
#define H_Work_ps2_kbd_arch_H
#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


class Work_ps2_kbd_arch: public HSim__s6 {
public:

    HSim__s4 PE[1];
    HSim__s1 SE[9];

HSim__s4 C7;
HSim__s4 C9;
HSim__s4 Cd;
HSim__s4 Cg;
HSim__s4 Cp;
    HSim__s1 SA[19];
HSimConstraints *c0;
HSimConstraints *c1;
  char *t2;
  char *t3;
  char t4;
  char t5;
  char t6;
  char t7;
    Work_ps2_kbd_arch(const char * name);
    ~Work_ps2_kbd_arch();
    void constructObject();
    void constructPorts();
    void reset();
    void architectureInstantiate(HSimConfigDecl* cfg);
    virtual void vhdlArchImplement();
};



HSim__s6 *createWork_ps2_kbd_arch(const char *name);

#endif
