/*********************************************************
 MODULE:		Sub Level SDRAM Output Enable Generator

 FILE NAME:	oe_generator.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will generate the Output Enable signal.

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module oe_generator(// Input
							reset,
							clk0,
							page_mod,
							do_writea1,
							bur_len,
							cas_lat,
							do_preacharge,
							do_reada,
							do_refresh,
							// Output
							oe,
							oe4
							);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input page_mod;
input do_writea1;
input [burst_size - 1 : 0]bur_len;
input [cas_size - 1 : 0]cas_lat;
input do_preacharge;
input do_reada;
input do_refresh;

// Output
output oe;
output oe4;

// Internal wire and reg signals
wire reset;
wire clk0;
wire page_mod;
wire do_writea1;
wire [burst_size - 1 : 0]bur_len;
wire [cas_size - 1 : 0]cas_lat;
wire do_preacharge;
wire do_reada;
wire do_refresh;

reg oe;
reg oe4;

reg oe1;
reg oe2;
reg oe3;
reg [7:0]oe_shift;

// Assignment


// logic that generates the oe signal for the data path module
// For normal burst write he duration of oe is dependent on the configured burst length.
// For page mode accesses(page_mod=1) the oe signal is turned on at the start of the write command
// and is left on until a preacharge(page burst terminate) is detected.
//
always @(posedge reset or posedge clk0)
begin
        if (reset == 1'b1)
        begin
                oe_shift <= 0;
                oe1      <= 0;
                oe2      <= 0;
                oe       <= 0;
        end
        else
        begin
                if (page_mod == 0)
                begin
                        if (do_writea1 == 1)
                        begin
                                if (bur_len == 1)                     //  Set the shift register to the appropriate
                                        oe_shift <= 0;                // value based on burst length.
                                else if (bur_len == 2)
                                        oe_shift <= 1;
                                else if (bur_len == 4)
                                        oe_shift <= 7;
                                else if (bur_len == 8)
                                        oe_shift <= 127;
                                oe1 <= 1;
                        end
                        else 
                        begin
                                oe_shift[6:0] <= oe_shift[7:1];       // Do the shift operation
                                oe_shift[7]   <= 0;
                                oe1  <= oe_shift[0];
                                oe2  <= oe1;
                                oe3  <= oe2;
                                oe4   <= oe3;
                                if (cas_lat == 2)
                                        oe <= oe3;
                                else
                                        oe <= oe4;
                        end
                end
                else
                begin
                        if (do_writea1 == 1)                                    // oe generation for page mode accesses
                                oe4   <= 1;
                        else if (do_preacharge == 1 | do_reada == 1 | do_refresh)
                                oe4   <= 0;
                        oe <= oe4;
                end
                               
        end
end

endmodule
