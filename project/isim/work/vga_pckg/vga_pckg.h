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

#ifndef H_Work_vga_pckg_H
#define H_Work_vga_pckg_H

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


#include "work/common/common.h"
#include "unisim.auxlib/vcomponents/vcomponents.h"
#include "ieee/numeric_std/numeric_std.h"
#include "ieee/std_logic_1164/std_logic_1164.h"

class Work_vga_pckg: public HSim__s6 {
public:
  Work_vga_pckg(const HSimString &name);
  ~Work_vga_pckg();
};

extern Work_vga_pckg *WorkVga_pckg;

#endif
