`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:38:25 07/06/2013
// Design Name:   M16C5x_SPI
// Module Name:   C:/XProjects/ISE10.1i/M16C5x/Src/tb_M16C5x_SPI.v
// Project Name:  M16C5x
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: M16C5x_SPI
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_M16C5x_SPI;

reg     Rst;
reg     SysClk;
reg     ClkEn;
//
reg     Clk_UART;
//
reg     WE_CR;
reg     WE_TF;
reg     RE_RF;
reg     [7:0] DI;
wire    [7:0] DO;
//
wire    [1:0] CS;
wire    SCK;
wire    MOSI;
wire    MISO;
//
wire    SS;
//
wire    TF_FF;
wire    TF_EF;
wire    RF_FF;
wire    RF_EF;

reg     [7:0] Val;

// Instantiate the Unit Under Test (UUT)

M16C5x_SPI  uut (
                .Rst(Rst), 
                .Clk(SysClk), 
                .ClkEn(ClkEn),
                
                .WE_CR(WE_CR), 
                .WE_TF(WE_TF), 
                .RE_RF(RE_RF), 
                .DI(DI), 
                .DO(DO),
                
                .CS(CS), 
                .SCK(SCK), 
                .MOSI(MOSI), 
                .MISO(MISO), 

                .SS(SS), 

                .TF_FF(TF_FF), 
                .TF_EF(TF_EF), 
                .RF_FF(RF_FF), 
                .RF_EF(RF_EF)
            );
            
wire    [2:0] SSP_RA;
wire    SSP_WnR;
wire    SSP_En;
wire    SSP_EOC;
wire    [11:0] SSP_DI;
wire    [11:0] SSP_DO;
wire    [ 3:0] BC;

SSPx_Slv    SSP_Slv (
                .Rst(Rst),
                
                .SSEL(CS[1]), 
                .SCK(SCK), 
                .MOSI(MOSI), 
                .MISO(MISO),
                
                .RA(SSP_RA),
                .WnR(SSP_WnR),
                .En(SSP_En), 
                .EOC(SSP_EOC),
                .DI(SSP_DI), 
                .DO(SSP_DO),
                
                .BC(BC) 
            );
            
wire    TxD_232;
wire    xRTS;
reg     xCTS;

wire    TxD_485;
wire    xDE;

wire    TxIdle;
wire    RxIdle;

SSP_UART    UART (
                .Rst(Rst), 
                .Clk(Clk_UART),
                
                .SSP_SSEL(CS[1]),
                .SSP_SCK(SCK), 
                .SSP_RA(SSP_RA),
                .SSP_WnR(SSP_WnR),
                .SSP_EOC(SSP_EOC), 
                .SSP_DI(SSP_DI), 
                .SSP_DO(SSP_DO),
                
                .TxD_232(TxD_232), 
                .RxD_232(TxD_232), 
                .xRTS(xRTS), 
                .xCTS(xCTS),
                
                .TxD_485(TxD_485), 
                .RxD_485(TxD_485), 
                .xDE(xDE),
                
                .IRQ(IRQ),
                
                .TxIdle(TxIdle),
                .RxIdle(RxIdle)
            );

initial begin
    // Initialize Inputs
    Rst      = 1;
    SysClk   = 1;
    Clk_UART = 1;
    
    WE_CR    = 0;
    WE_TF    = 0;
    RE_RF    = 0;
    DI       = 0;
    
    xCTS     = 1;

    // Wait 100 ns for global reset to finish
    #101 Rst = 0;
    
    // Add stimulus here
    
    WR_CR(8'h0F);   // Enable Reads, Select SSP_UART, Mode 3, Divide by 2, MSB
    
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    @(posedge SysClk);
    
    WR_TF(8'h02);   // Write UART CR, Md = 0, RTSo = 1, Fmt = 8n1, Baud = 1.5M
    WR_TF(8'h00);   
    
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (high byte)
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (low byte)

    WR_TF(8'h00);   // Read UART CR
    WR_TF(8'h00);   
    
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (high byte)
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (low byte)

    WR_TF(8'h20);   // Read UART SR
    WR_TF(8'h00);   
    
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (high byte)
    @(negedge RF_EF) RD_RF(Val);     // Read out return data (low byte)

    WR_CR(8'h0E);   // Select UART but disable capturing input data

    WR_TF(8'h50);   // Write TDR
    WR_TF(8'h0F);   
    
end

////////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #8 SysClk = ~SysClk;

always @(posedge SysClk)
begin
    if(Rst)
        ClkEn = #1 0;
    else
        ClkEn = #1 ~ClkEn;
end

always #10.416 Clk_UART = ~Clk_UART;

////////////////////////////////////////////////////////////////////////////////
//
//  Tasks and Functions
//

task WR_CR;
    input [7:0] Val;
        
    begin
        @(posedge ClkEn);
        WE_CR = 1; DI = Val;
        @(posedge SysClk) #1;
        WE_CR = 0; DI = 0;
    end
endtask

task WR_TF;
    input [7:0] Val;
    
    begin
        @(posedge ClkEn);
        WE_TF = 1; DI = Val;
        @(posedge SysClk) #1;
        WE_TF = 0; DI = 0;
    end
endtask

task RD_RF;
    output [7:0] Val;
    
    begin
        @(posedge ClkEn);
        RE_RF = 1;
        @(posedge SysClk) Val = #1 DO;
        RE_RF = 0;
    end
endtask
      
endmodule

