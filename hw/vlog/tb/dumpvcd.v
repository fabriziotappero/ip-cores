//////////////////////////////////////////////////////////////////
//                                                              //
//  Waveform Dumping Control                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Its useful in very long simulations to be able to record    //
//  a set of signals for a limited window of time, so           //
//  that the dump file does not get too large.                  //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
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

`include "global_defines.vh"

module dumpvcd();

    
// ======================================
// Dump Waves to VCD File
// ======================================
`ifdef AMBER_DUMP_VCD
initial
    begin
    $display ("VCD Dump enabled from %d to %d", 
    ( `AMBER_DUMP_START                ),
    ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH ) );
    
    $dumpfile(`AMBER_VCD_FILE);
    $dumpvars(1, `U_TB.clk_count);
    
    $dumpvars(1, `U_DECOMPILE.xINSTRUCTION_EXECUTE);
    $dumpvars(1, `U_EXECUTE.o_write_enable);
    $dumpvars(1, `U_EXECUTE.o_exclusive);
    $dumpvars(1, `U_EXECUTE.o_write_data);
    $dumpvars(1, `U_EXECUTE.base_address);
    $dumpvars(1, `U_EXECUTE.pc);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r0);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r1);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r2);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r3);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r4);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r5);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r6);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r7);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r8);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r9);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r10);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r11);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r12);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r13_out);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r14_out);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r14_irq);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r15);


    $dumpvars(1, `U_FETCH);
    $dumpvars(1, `U_CACHE);
    $dumpvars(1, `U_DECODE);
    $dumpvars(1, `U_WISHBONE);
    $dumpvars(1, `U_AMBER);    
     
    `ifdef AMBER_A25_CORE
    $dumpvars(1, `U_MEM);
    $dumpvars(1, `U_DCACHE);
    `endif
    
    $dumpoff;    
    end
    
always @(posedge `U_DECOMPILE.i_clk)
    begin
    if ( `U_DECOMPILE.clk_count == 10 )
        begin
        $dumpon;
        $display("\nDump on at  %d ticks", `U_DECOMPILE.clk_count);
        end
            
    if ( `U_DECOMPILE.clk_count == 20 )
        begin
        $dumpoff;
        $display("\nDump off at %d ticks", `U_DECOMPILE.clk_count);
        end


    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + 0 ) )
        begin
        $dumpon;
        $display("\nDump on at  %d ticks", `U_DECOMPILE.clk_count);
        end
                                   
    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH ) )
        begin
        $dumpoff;
        $display("\nDump off at %d ticks", `U_DECOMPILE.clk_count);
        end
        
    `ifdef AMBER_TERMINATE
    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH + 100) )
        begin
        $display("\nAutomatic test termination after dump has completed");
        `TB_ERROR_MESSAGE
        end
    `endif
    end
    
    
    
`endif


    
endmodule
