/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The define file for the SystemC test modules
 
 History:
 28/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef NOC_DEF_H_
#define NOC_DEF_H_

#define SC_INCLUDE_DYNAMIC_PROCESSES
#include "sim_ana.h"
#include "pdu_def.h"

// channel bandwidth
const unsigned int ChBW = 1;	    // the data width of a single virtual circuit in unit of byte, must equal DW/8
const unsigned int SubChN = 1;	    // the number of virtual circuits or VCs per direction, must equal VCN
const unsigned int FSIZE_MAX = 512; // the longest frame has 512 bytes of  data

const unsigned int DIMX = 4;	// the X size of the mesh network
const unsigned int DIMY = 4;	// the Y size of the mesh network
const unsigned int FLEN = 64;	// the payload size of a frame in unit of bytes

const unsigned int BufDepth = 1; // the depth of the input buffer (only useful in VC routers to determine the inital tokens in output ports)

const double FFreq = 0.1;	// Node injection rate, in unit of MFlit/second, 0 means the maximal inject rate

const double Record_Period = 1e3 * 1e3;	// the interval of recording the average performance to log files, in unit of ps
const double Warm_UP = 0e4 * 1e3;	// the warm up time of performance analysis, in unit of ps
const double SIM_TIME = 1e3 * 1e3;	// the overall simulation time of the netowrk, in unit of ns

extern sim_ana * ANA;		// declaration of the global simulation analysis module

typedef pdu_flit<ChBW> FLIT;	// define the template of flit
typedef pdu_frame<ChBW> FRAME;	// define the template of frame

// Channel Slicing will alter the port format
// #define ENABLE_CHANNEL_CLISING

#endif
