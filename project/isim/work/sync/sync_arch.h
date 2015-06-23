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

#ifndef H_Work_sync_sync_arch_H
#define H_Work_sync_sync_arch_H
#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


class Work_sync_sync_arch: public HSim__s6 {
public:

    HSim__s4 PE[5];
    HSim__s1 SE[7];

HSim__s4 C8;
HSim__s4 Cc;
HSim__s4 Cg;
HSim__s4 Ck;
HSim__s4 Cp;
    HSim__s1 SA[8];
  char t54;
  char *t55;
HSimConstraints *c56;
  char t57;
    Work_sync_sync_arch(const char * name);
    ~Work_sync_sync_arch();
    void constructObject();
    void constructPorts();
    void reset();
    void architectureInstantiate(HSimConfigDecl* cfg);
    virtual void vhdlArchImplement();
};



HSim__s6 *createWork_sync_sync_arch(const char *name);

#endif
