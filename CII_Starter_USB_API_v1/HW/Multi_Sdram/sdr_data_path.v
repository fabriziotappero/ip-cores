//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

module sdr_data_path(
        CLK,
        RESET_N,
        DATAIN,
        DM,
        DQOUT,
        DQM
        );

`include        "Sdram_Params.h"

input                           CLK;                    // System Clock
input                           RESET_N;                // System Reset
input   [`DSIZE-1:0]            DATAIN;                 // Data input from the host
input   [`DSIZE/8-1:0]          DM;                     // byte data masks
output  [`DSIZE-1:0]            DQOUT;
output  [`DSIZE/8-1:0]          DQM;                    // SDRAM data mask ouputs
reg     [`DSIZE/8-1:0]          DQM;
            
// internal 
reg     [`DSIZE-1:0]            DIN1;
reg     [`DSIZE-1:0]            DIN2;

reg     [`DSIZE/8-1:0]          DM1;



// Allign the input and output data to the SDRAM control path
always @(posedge CLK or negedge RESET_N)
begin
        if (RESET_N == 0) 
        begin
                DIN1    <= 0;
                DIN2    <= 0;
                DM1     <= 0;
        end        
        else
        begin
                DIN1	<=	DATAIN;
                DIN2	<=	DIN1;
 				DQM		<=	DM;                 
        end
end

assign DQOUT = DIN2;

endmodule

