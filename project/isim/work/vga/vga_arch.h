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

#ifndef H_Work_vga_vga_arch_H
#define H_Work_vga_vga_arch_H
#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


class Work_vga_vga_arch: public HSim__s6 {
public:

    HSim__s4 PE[7];
    HSim__s1 SE[11];

HSim__s4 C8;
HSim__s4 Cf;
HSim__s4 Cj;
HSim__s4 Cn;
HSim__s4 Cr;
HSim__s4 Cw;
HSim__s4 CA;
HSim__s4 CD;
HSim__s4 CG;
HSim__s4 CJ;
HSim__s4 CM;
HSim__s4 CQ;
HSim__s4 CU;
HSim__s4 CX;
HSim__s4 C10;
HSim__s4 C1C;
    HSim__s1 SA[23];
  char t75;
  char t76;
  char *t77;
  char *t78;
    Work_vga_vga_arch(const char * name);
    ~Work_vga_vga_arch();
    void constructObject();
    void constructPorts();
    void reset();
    void architectureInstantiate(HSimConfigDecl* cfg);
    virtual void vhdlArchImplement();
};



HSim__s6 *createWork_vga_vga_arch(const char *name);

#endif
