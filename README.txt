//////////////////////////////////////////////////////////////////
//                                                              //
//  The simu_mem project provides functional simulation models  //
//  of commercially available RAMs. The following types are     //
//  presently supported:                                        //
//                                                              //
//  - asynchronous static SRAMs                                 //
//  - synchronous static RAMs ("Zero Bus Turnaround" RAM, ZBT   //
//    RAM)                                                      //
//                                                              //
//  Author(s):                                                  //
//      - Michael Geng (vhdl@MichaelGeng.de)                    //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2008 Authors                                   //
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $

Advantages of the simu_mem models
=================================

1. Consumes few simulator memory if only few memory
   locations are accessed because it internally uses a
   linked list.
2. Simulates quickly because it does not contain timing
   information. Fast simulator startup time because of the
   linked list.
3. Usable for any data and address bus width.
4. Works at any clock frequency.
5. Programmed in VHDL.

When the simu_mem models will not be useful
===========================================
1. When it has to be synthesized.
2. When a timing model is required. Ask your RAM vendor for
   a timing model.
3. When your design is in Verilog.

Where are the simulation models?
================================

The RAM simulation models are located in rtl/vhdl/. They were
tested only with the Modelsim simulator.

How were the models tested?
===========================

A testbench exists for ZBT RAMs. sim/rtl_sim/bin/sim.sh will execute 
the simulation. In order to run this test you must replace
bench/verilog/samsung/k7n643645m_R03.v with the original simulation
file from Samsung. You can find it on the Samsung semiconductor home
page under High Speed SRAM / NtRAM / K7N643645M.
