//////////////////////////////////////////////////////////////////
//                                                              //
//  Amber Configuration and Debug for the Amber 25 Core         //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains a set of defines used to configure and debug       //
//  the Amber core                                              //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

`ifndef _A25_CONFIG_DEFINES
`define _A25_CONFIG_DEFINES

// Cache Ways
// Changing this parameter is the recommended
// way to change the Amber cache size; 2, 3, 4 and 8 ways are supported.
//
//   2 ways -> 8KB  cache
//   3 ways -> 12KB cache
//   4 ways -> 16KB cache
//   8 ways -> 32KB cache
//
//   e.g. if both caches have 8 ways, the total is 32KB icache + 32KB dcache = 64KB

`define A25_ICACHE_WAYS 4
`define A25_DCACHE_WAYS 4


// --------------------------------------------------------------------
// Debug switches 
// --------------------------------------------------------------------

// Enable the decompiler. The default output file is amber.dis
`define A25_DECOMPILE

// Co-processor 15 debug. Registers in here control the cache
//`define A25_COPRO15_DEBUG

// Cache debug
//`define A25_CACHE_DEBUG

// --------------------------------------------------------------------


// --------------------------------------------------------------------
// File Names
// --------------------------------------------------------------------
`ifndef A25_DECOMPILE_FILE
    `define A25_DECOMPILE_FILE    "amber.dis"
`endif

`endif

