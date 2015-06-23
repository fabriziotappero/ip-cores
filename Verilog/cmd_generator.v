/*********************************************************
 MODULE:		Sub Level SDRAM Command Genrator

 FILE NAME:	cmd_generator.v
 VERSION:	1.0
 DATE:		April 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will generate the SDRAM control signals.


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module cmd_generator(// Input
							reset,
							clk0,
							do_reada,
							do_writea,
							do_preacharge,
							do_rw,
							rowaddr,
							coladdr,
							bankaddr,
							page_mod,
							do_load_mod,
							do_refresh,
							caddr,
							do_nop,
							rw_flag,
							oe4,
							// Output
							sadd,
							ba,
							cs,
							ras,
							cas,
							we,
							cke
							);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input do_reada;
input do_writea;
input do_preacharge;
input do_rw;
input [row_size - 1:0]        rowaddr;
input [col_size - 1:0]        coladdr;
input [bank_size - 1:0]       bankaddr;
input page_mod;
input do_load_mod;
input do_refresh;
input [padd_size - 1 : 0]caddr;
input do_nop;
input rw_flag;
input oe4;

// Output
output [add_size - 1 : 0]sadd;
output [ba_size - 1 : 0]ba;
output [cs_size - 1 : 0]cs;
output ras;
output cas;
output we;
output cke;


// Internal wire and reg signals
wire reset;
wire clk0;
wire do_reada;
wire do_writea;
wire do_preacharge;
wire do_rw;
wire [row_size - 1:0]        rowaddr;
wire [col_size - 1:0]        coladdr;
wire [bank_size - 1:0]       bankaddr;
wire page_mod;
wire do_load_mod;
wire do_refresh;
wire [padd_size - 1 : 0]caddr;
wire do_nop;
wire rw_flag;
wire oe4;

reg [add_size - 1 : 0]sadd;
reg [ba_size - 1 : 0]ba;
reg [cs_size - 1 : 0]cs;
reg ras;
reg cas;
reg we;
reg cke;


// Assignment



// This always block generates the address, cs, cke, and command signals(ras,cas,wen)
// 
always @(posedge reset or posedge clk0)
begin
        if (reset == 1'b1) begin
                sadd <= 0;
                ba   <= 0;
                cs   <= 1;
                ras  <= 1;
                cas  <= 1;
                we   <= 1;
                cke  <= 0;
        end
        else begin
                cke  <= 1;

// Generate sadd 	

                if (do_writea == 1 | do_reada == 1)    // ACTIVATE command is being issued, so present the row address
                        sadd <= rowaddr;
                else if ((do_rw == 1) | (do_preacharge == 1))
                        sadd[10] <= !page_mod;              // set sadd[10] for autopreacharge read/write or for a preacharge all command
                else                                        // don't set it if the controller is in page mode.           
                        sadd <= coladdr;                 // else alway present column address
                if (do_preacharge == 1 | do_load_mod == 1)
                        ba <= 0;                       // Set ba=0 if performing a preacharge or load_mod command
                else
                        ba <= bankaddr[1:0];           // else set it with the appropriate address bits
		
                if (do_refresh == 1 | do_preacharge == 1 | do_load_mod == 1)
                        cs <= 0;                                    // Select both chip selects if performing
                else                                                  // refresh, preacharge(all) or load_mod
                begin
                        cs[0] <= caddr[padd_size - 1];                   // else set the chip selects based off of the
                        cs[1] <= ~caddr[padd_size - 1];                  // msb address bit
                end


//Generate the appropriate logic levels on ras, cas, and we
//depending on the issued command.
//		
                if (do_nop == 1) begin			                      	// No Operation: RAS=1, CAS=1, WE=1
                        ras <= 1;
                        cas <= 1;
                        we  <= 1;
                end
	             else if (do_refresh == 1) begin                        // refresh: S=00, RAS=0, CAS=0, WE=1
                        ras <= 0;
                        cas <= 0;
                        we  <= 1;
                end
                else if ((do_preacharge == 1) & ((oe4 == 1) | (rw_flag == 1))) begin      // burst terminate if write is active
                        ras <= 1;
                        cas <= 1;
                        we  <= 0;
                end
                else if (do_preacharge == 1) begin                 // preacharge All: S=00, RAS=0, CAS=1, WE=0
                        ras <= 0;
                        cas <= 1;
                        we  <= 0;
                end
                else if (do_load_mod == 1) begin                 // Mode Write: S=00, RAS=0, CAS=0, WE=0
                        ras <= 0;
                        cas <= 0;
                        we  <= 0;
                end
                else if (do_reada == 1 | do_writea == 1) begin  // Activate: S=01 or 10, RAS=0, CAS=1, WE=1
                        ras <= 0;
                        cas <= 1;
                        we  <= 1;
                end
                else if (do_rw == 1) begin                      // Read/Write: S=01 or 10, RAS=1, CAS=0, WE=0 or 1
                        ras <= 1;
                        cas <= 0;
                        we  <= rw_flag;
                end
                else begin                                      // No Operation: RAS=1, CAS=1, WE=1
                        ras <= 1;
                        cas <= 1;
                        we  <= 1;
                end
        end 
end



endmodule
