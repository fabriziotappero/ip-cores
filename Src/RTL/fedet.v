`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Alpha Beta Technologies, Inc.
// Engineer:        Michael A. Morris 
// 
// Create Date:     03/01/2008
// Design Name:     USB MBP HDL 
// Module Name:     fedet.v
// Project Name:    4020 HAWK ZAOM Upgrade
// Target Devices:  XC2S150-5PQ208I 
// Tool versions:   ISE 8.2i
//
// Description:     Multi-stage synchronizer with falling edge detection
//
// Dependencies:    None
//
// Revision History:
//
//  0.01    08C01   MAM     File Created
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module fedet(rst, clk, din, pls);

///////////////////////////////////////////////////////////////////////////////
//
//  Module Port Declarations
//
    
    input   rst;
    input   clk;
    input   din;
    output  pls;

///////////////////////////////////////////////////////////////////////////////
//
//  Module Level Declarations
//

    reg [2:0] QSync;
    
///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge clk or posedge rst) begin
    if(rst)
        #1 QSync <= 3'b011;
    else 
        #1 QSync <= {~QSync[0] & QSync[1], QSync[0], din};
end

assign pls = QSync[2];

endmodule
