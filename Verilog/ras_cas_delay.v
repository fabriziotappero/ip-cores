/*********************************************************
 MODULE:		Sub Level SDRAM Ras-to-Cas Delay Counter

 FILE NAME:	ras_cas_delay.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the RAS-to-CAS Delay Counter block.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module ras_cas_delay(// Input
							reset,
							clk0,
							do_reada,
							do_writea,
							ras_cas,
							// Output
							do_rw
							);

// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input do_reada;
input do_writea;
input [rc_size - 1 : 0]ras_cas;

// Output
output do_rw;

// Internal wire and reg signals
wire reset;
wire clk0;
wire do_reada;
wire do_writea;
wire [rc_size - 1 : 0]ras_cas;

reg	do_rw;
reg   [3:0]rw_shift;


// Assignment



// This always block tracks the time between the activate command and the
// subsequent writea or reada command, RC.  The shift register is set using
// the configuration register setting ras_cas. The shift register is loaded with
// a single '1' with the position within the register dependent on ras_cas.
// When the '1' is shifted out of the register it sets so_rw which triggers
// a writea or reada command
//
always @(posedge reset or posedge clk0)
begin
        if (reset == 1'b1)
        begin
                rw_shift <= 0;
                do_rw    <= 0;
        end
        
        else
        begin
                
                if ((do_reada == 1) | (do_writea == 1))
                begin
                        if (ras_cas == 1)                          // Set the shift register
                                do_rw <= 1;
                        else if (ras_cas == 2)
                                rw_shift <= 1;
                        else if (ras_cas == 3)
                                rw_shift <= 2;
                end
                else
                begin
                        rw_shift[2:0] <= rw_shift[3:1];          // perform the shift operation
                        rw_shift[3]   <= 0;
                        do_rw         <= rw_shift[0];
                end 
        end
end              


endmodule
