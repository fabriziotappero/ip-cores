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

#ifndef H_Unisim_vcomponents_H
#define H_Unisim_vcomponents_H

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


#include "ieee/std_logic_1164/std_logic_1164.h"

class Unisim_vcomponents: public HSim__s6 {
public:
    HSim__s1 Sc;
    HSim__s1 Se;
    HSim__s1 Sg;
    HSim__s1 Si;
    HSim__s1 Sk;
    HSim__s1 Sn;
    HSim__s1 Sq;
    HSim__s1 Ss;
    HSim__s1 Su;
    HSim__s1 Sw;
    HSim__s1 Sy;
    HSim__s1 SA;
    HSim__s1 SC;
    HSim__s1 SE;
    HSim__s1 SG;
    HSim__s1 SI;
    HSim__s1 SK;
    HSim__s1 SM;
    HSim__s1 SP;
    HSim__s1 SR;
  Unisim_vcomponents(const HSimString &name);
  ~Unisim_vcomponents();
};

extern Unisim_vcomponents *UnisimVcomponents;

#endif
