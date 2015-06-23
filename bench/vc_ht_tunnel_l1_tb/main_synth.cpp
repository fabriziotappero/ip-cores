//main.cpp for vc_ht_tunnel_l1 testbench

/*==========================================================================
  HyperTransport Tunnel IP Core Source Code

  Copyright (C) 2005 by École Polytechnique de Montréal, All rights 
  reserved.
 
  No part of this file may be duplicated, revised, translated, localized or
  modified in any manner or compiled, synthetized, linked or uploaded or
  downloaded to or from any computer system without the prior written 
  consent of École Polytechnique de Montréal.

==========================================================================*/


#ifdef MTI_SYSTEMC
//For ModelSim simulation, top simulation must be contained within
//a module instanciated in a .h
#include "main_synth.h"
//Directive to mark the top level of the simulated design
SC_MODULE_EXPORT(top);

//MTI_SYSTEMC does not work on all version of ModelSim, this is a fallback
#elif MTI2_SYSTEMC

//For ModelSim simulation, top simulation must be contained within
//a module instanciated in a .h
#include "main_synth.h"
//Directive to mark the top level of the simulated design
SC_MODULE_EXPORT(top);

#endif

