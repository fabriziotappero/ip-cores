`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     17:33:56 07/27/2008
// Design Name:     BRSFmnCE
// Module Name:     C:/XProjects/ISE10.1i/BRAMFIFO/tb_BRSFmnCE.v
// Project Name:    BRAMFIFO
// Target Device:   SRAM-based FPGA: XC3S1400AN-4FGG656I, XC3S700AN-4FGG484I  
// Tool versions:   ISE 10.1i SP3  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BRSFmnCE
//
// Dependencies:    None
// 
// Revision:
//
//  1.00    08F27   MAM     File Created
//
//  1.10    13G12   MAM     Prepared for release on Opencore.com.
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_BRSFmnCE;

// Inputs
reg     Rst;
reg     Clk;

reg     Clr;

reg     WE;
reg     [7:0] DI;

reg     RE;
wire    [7:0] DO;
wire    ACK;

wire    FF;
wire    AF;
wire    HF;
wire    AE;
wire    EF;

wire    [10:0] Cnt;

integer i;

// Instantiate the Unit Under Test (UUT)

BRSFmnCE    uut (
                .Rst(Rst), 
                .Clk(Clk),
                
                .Clr(Clr),
                
                .WE(WE), 
                .DI(DI), 

                .RE(RE), 
                .DO(DO), 
                .ACK(ACK),

                .FF(FF),
                .AF(AF),
                .HF(HF),
                .AE(AE),
                .EF(EF), 

                .Cnt(Cnt)
            );

initial begin
    // Initialize Inputs
    Rst = 1;
    Clk = 1;
    Clr = 0;
    WE  = 0;
    RE  = 0;
    DI  = $random(5);
    
    i   = 0;

    // Wait 100 ns for global reset to finish
    #101 Rst = 0;
    
    // Add stimulus here
    
    while (AF != 1) begin
        @(posedge Clk) #1;
        if(AF != 1) begin
            DI = $random;
            WE = ~FF;
            i = i + 1;
        end
    end
    
    WE = 0; DI = 0;
    
    RE = ~EF;
    while (AE != 1) begin
        @(posedge Clk) #1;
        if (AE != 1) begin
            RE = ~EF;
            i = i - 1;
        end
    end
    RE = 0; i = i - 1;
    
    @(negedge ACK);
    @(posedge Clk) #1; WE = 1; DI = $random; i = i + 1;
    @(posedge Clk) #1; WE = 0;
    
    @(posedge Clk) #1; RE = 1;
    @(posedge Clk) #1; RE = 0; i = i - 1;

end

////////////////////////////////////////////////////////////////////////////////
//
//  Clock
//
    
    always #5 Clk = ~Clk;
      
////////////////////////////////////////////////////////////////////////////////

endmodule

