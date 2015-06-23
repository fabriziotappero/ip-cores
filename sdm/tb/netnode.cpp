/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC module of network node including the processing element and the network interface.
 Currently the transmission FIFO is 500 frame deep.
   
 History:
 26/02/2011  Initial version. <wsong83@gmail.com>
 
*/

#include "netnode.h"

NCSC_MODULE_EXPORT(NetNode)

