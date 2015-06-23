`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     08:46:12 07/04/2013
// Design Name:     M16C5x
// Module Name:     C:/XProjects/ISE10.1i/M16C5x/tb_M16C5x.v
// Project Name:    M16C5x
// Target Device:   SRAM FPGAs: XC3S50A-4VQG100I, XC3S200A-4VQG100I
// Tool versions:   Xilinx ISE 10.1i SP3
  
// Description: 
//
// Verilog Test Fixture created by ISE for module: M16C5x
//
// Dependencies:
// 
// Revision:
//
//  0.01    13G07   MAM     File Created
//
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_M16C5x;

reg     ClkIn;
reg     Clk_UART;
//
reg     nMCLR;
//
reg     nT0CKI;
reg     nWDTE;
reg     PROM_WE;
//
wire    TD;
wire    RD;
wire    nRTS;
reg     nCTS;
//
wire    [2:0] nCS;
wire    SCK;
wire    MOSI;
reg     MISO;
//
wire    [2:0] nCSO;
wire    nWait;

//  Simulation Structures

reg     [3:0] Clk_Div;
reg     Clk_16x;

reg     TF_EF;
reg     [7:0] THR;
wire    TF_RE;
wire    Idle;

// Instantiate the Unit Under Test (UUT)

M16C5x  #(
            .pUserProg("Src/M16C5x_Tst4.coe")
        ) uut (
            .ClkIn(ClkIn),
            
            .nMCLR(nMCLR), 

            .nT0CKI(nT0CKI), 
            .nWDTE(nWDTE), 
            .PROM_WE(PROM_WE), 

            .TD(TD), 
            .RD(RD), 
            .nRTS(nRTS), 
            .nCTS(nCTS),
            .DE(DE),

            .nCS(nCS), 
            .SCK(SCK), 
            .MOSI(MOSI), 
            .MISO(MISO),
            
            .nCSO(nCSO), 
            .nWait(nWait)
        );
        
//  Instantiate a UART Transmitter for testing UART Receiver in M16C5x

UART_TXSM   RxD (
                .Rst(~nMCLR),   // Reset
                .Clk(Clk_UART), // UART Clock - 29.4912 MHz

                .CE_16x(Clk_16x),   // 16x Clock Enable - Baud Rate x16
                
                .Len(1'b0),     // Word length: 0 - 8-bits; 1 - 7 bits
                .NumStop(1'b0), // Number Stop Bits: 0 - 1 Stop; 1 - 2 Stop
                .ParEn(1'b0),   // Parity Enable
                .Par(2'b00),    // 0 - Odd;       1 - Even;
                                // 2 - Space (0); 3 - Mark (1)

                .TF_EF(TF_EF),  // Transmit THR Empty Flag

                .THR(THR),      // Transmit Holding Register
                .TF_RE(TF_RE),  // Transmit THR Read Enable Strobe

                .CTSi(1'b1),    // RS232 Mode CTS input

                .TxD(RD),       // Serial Data Out, LSB First, Start bit = 0

                .TxIdle(Idle),  // Transmit SM - Idle State
                .TxStart(),     // Transmit SM - Start State - CTS wait
                .TxShift(),     // Transmit SM - Shift State
                .TxStop()       // Transmit SM - Stop State - RTS clear
            );


initial begin
    // Initialize Inputs
    ClkIn    = 1;
    Clk_UART = 1;
    nMCLR    = 0;
    nT0CKI   = 0;
    nWDTE    = 1;
    PROM_WE  = 0;
    
    nCTS     = 0;
    MISO     = 1;
    
    Clk_Div = ~0;
    Clk_16x =  0;
    TF_EF   =  1;
    THR     =  8'h00;

    // Wait 100 ns for global reset to finish
    
    #201 nMCLR = 1;
    
    // Add stimulus here
    
    @(negedge nRTS);

    #20000 PutCh(8'hFF);
    #20000 PutCh(8'h80);
    #20000 PutCh(8'h7B);
    #20000 PutCh(8'h7A);
    #20000 PutCh(8'h61);
    #20000 PutCh(8'h60);
    #20000 PutCh(8'h5B);
    #20000 PutCh(8'h5A);
    #20000 PutCh(8'h41);
    #20000 PutCh(8'h40);
    #20000 PutCh(8'h39);
    #20000 PutCh(8'h31);
    #20000 PutCh(8'h00);

end

////////////////////////////////////////////////////////////////////////////////

always #33.908 ClkIn = ~ClkIn;          // Reference Clock - 14.7456 MHz

////////////////////////////////////////////////////////////////////////////////

always #16.954 Clk_UART = ~Clk_UART;    // UART Clock      - 29.4912 MHz

////////////////////////////////////////////////////////////////////////////////

always @(posedge Clk_UART or negedge nMCLR)
begin
    if(~nMCLR) begin
        Clk_Div <= #1 ~0;
        Clk_16x <= #1  0;
    end else begin
        Clk_Div <= #1 (Clk_Div - 1);
        Clk_16x <= #1 ~|Clk_Div;
    end
end

////////////////////////////////////////////////////////////////////////////////

task PutCh;
    input   [7:0] ch;

    begin
        @(posedge Clk_UART) #1;
        TF_EF = 0; THR = ch;
        @(posedge TF_RE);
        @(posedge Clk_UART) #1;
        TF_EF = 1;
    end

endtask

endmodule

