/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC class to keep a module of the simulation analysis object. 
 
 History:
 27/02/2011  Initial version. <wsong83@gmail.com>
 28/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#include "anaproc.h"

NCSC_MODULE_EXPORT(AnaProc)

// the simulation analysis object, global object
sim_ana * ANA = new sim_ana(Warm_UP, Record_Period);

