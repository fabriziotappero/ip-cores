/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Router configuration header file for SDM routers.
 
 Possible configuration combinations:
 * Wormhole (set VCN to 1)
   ENABLE_EOF [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD]
 * SDM (set VCN > 1 without define ENABLE_CLOS)
   ENABLE_EOF [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD] [ENABLE_MRMA]
 * SDM-Clos (set VCN > 1 and define ENABLE_CLOS)
   ENABLE_EOF ENABLE_CLOS [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD] [ENABLE_CRRD [ENABLE_MRMA]]
 
 The combinations not presented above are illegal, which may produce unexpected failures.
  
 History:
 20/09/2009  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 26/05/2011  Add ENABLE_MRMA and configuration explanations. <wsong83@gmail.com>
 
*/

// if VCN > 1, set ENABLE_CLOS to use the 2-stage Clos switch for less switching area
// `define ENABLE_CLOS

// Using the asynchronous version of the Concurrent round-robin dispatching
// algorithm for the 2-stage Clos can save some area but introduce a 5%
// throughput loss
// `define ENABLE_CRRD

// for the SDM router using crossbars and the Clos router using CRRD
// algorithm, using the multi-resource match arbiter may save the area in
// switch allocators
// `define ENABLE_MRMA

// set to enable channel slicing for fast data paths
// `define ENABLE_CHANNEL_SLICING

// set to use the early acknowledge of lookahead pipelines in the critical cycle
// `define ENABLE_LOOKAHEAD

// always set in wormhole and SDM routers to enable the eof bit in data pipeline stages
`define ENABLE_EOF
