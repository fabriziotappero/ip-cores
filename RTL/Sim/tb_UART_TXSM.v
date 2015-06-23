`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     09:26:15 05/11/2008
// Design Name:     LTAS 
// Module Name:     C:/XProjects/ISE10.1i/LTAS/tb_UART_TxSM.v
// Project Name:    LTAS 
// Target Devices:  XC3S700AN-5FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This test bench is intended to test the TxSM module for the SSP 
//              UART.
//
// Verilog Test Fixture created by ISE for module: UART_TXSM
//
// Dependencies:    UART_TxSM
// 
// Revision History:
//
//  0.01    08E10   MAM     File Created
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module tb_UART_TXSM_v;

// Inputs
reg     Rst;
reg     Clk;
reg     CE_16x;
reg     [1:0] MD;

reg     [3:0] FMT;
reg     Len, NumStop, ParEn;
reg     [1:0] Par;

reg     [7:0] THR;
reg     TF_EF;
reg     RTSo;
reg     CTSi;

// Outputs
wire    TF_RE;
wire    TxIdle;
wire    TxStart;
wire    TxShift;
wire    TxStop;
wire    TxD;
wire    DE;
wire    RTSi;

// Instantiate the Unit Under Test (UUT)

UART_TXSM   uut (
                .Rst(Rst), 
                .Clk(Clk), 
                .CE_16x(CE_16x), 

                .Len(Len),
                .NumStop(NumStop),
                .ParEn(ParEn),
                .Par(Par),

                .TF_EF(TF_EF), 
                .THR(THR), 
                .TF_RE(TF_RE), 
                .CTSi(CTSi),
                .TxD(TxD), 

                .TxIdle(TxIdle), 
                .TxStart(TxStart),
                .TxShift(TxShift),
                .TxStop(TxStop)
            );

initial begin
    // Initialize Inputs
    Rst     = 1;
    Clk     = 0;
    CE_16x  = 1;
    FMT     = 0;
    THR     = 8'h77;
    TF_EF   = 1;
    RTSo    = 1;
    CTSi    = 0;

    // Wait 100 ns for global reset to finish
    #100;
    
    Rst = 0;
    
    // Add stimulus here

    //  RS-232 w/ Handshaking
    
    @(posedge Clk) #1 TF_EF = 0;
    #100 CTSi = 1;      // Wait before asserting input handshake signal
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;
    #400 CTSi = 0;      // Deassert input handshake signal
    
    @(negedge TxStop);
    THR   = 8'h55;
    #400 CTSi = 1;
    TF_EF = 0;

    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk);

    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    #200  CTSi = 0;
    
    @(negedge TxStop);
    
    THR   = 8'h5A;
    TF_EF = 0;

    @(posedge TxStart) CTSi = 1;
    
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    @(negedge TxStop);

    THR   = 8'hA5;
    TF_EF = 0;

    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    #100 CTSi = 0;
    
    @(posedge TxStop);
    
    THR   = 8'h99;
    TF_EF = 0;

    @(posedge TxStart)
        #100 CTSi = 1;
    
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;
    
    @(posedge TxStop)
        CTSi = 0;

end

///////////////////////////////////////////////////////////////////////////////

//  Clocks

always #5 Clk = ~Clk;
    
//  Format Decode

always @(FMT)
    case(FMT)
        4'b0000 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0001 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0010 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b00};   // 8O1
        4'b0011 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b01};   // 8E1
        4'b0100 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b10};   // 8S1
        4'b0101 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b1, 2'b11};   // 8M1
        4'b0110 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0111 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b0, 2'b00};   // 8N2
        4'b1000 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b00};   // 8O2
        4'b1001 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b01};   // 8E2
        4'b1010 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b10};   // 8S2
        4'b1011 : {Len, NumStop, ParEn, Par} <= {1'b0, 1'b1, 1'b1, 2'b11};   // 8M2
        4'b1100 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b0, 1'b1, 2'b00};   // 7O1
        4'b1101 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b0, 1'b1, 2'b01};   // 7E1
        4'b1110 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b1, 1'b1, 2'b00};   // 7O2
        4'b1111 : {Len, NumStop, ParEn, Par} <= {1'b1, 1'b1, 1'b1, 2'b01};   // 7E2
    endcase

endmodule

