//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     ctrl_fifo512x64st_v0 BB 
// Project Name:    
// Target Devices:  XC6SLX45T-3FGG484
// Tool versions:   ISE v13.2
// Description:     
//                  
//                  
//                  
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ctrl_fifo512x64st_v0
(
    input           clk,
    input           rst,
    input           wr_en,
    input   [63:0]  din,
    input           rd_en,
    output  [63:0]  dout,
    output          full,
    output          empty,
    output  [ 8:0]  data_count
    
)/* synthesis syn_black_box */;

// synthesis translate_off

// synthesis translate_on

endmodule
