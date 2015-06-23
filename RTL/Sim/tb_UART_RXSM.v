`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates
// Engineer:        Michael A. Morris
//
// Create Date:     18:00:24 06/07/2008
// Design Name:     LTAS 
// Module Name:     C:/XProjects/ISE10.1i/LTAS/tb_UART_RxSM.v
// Project Name:    LTAS 
// Target Devices:  XC3S700AN-5FFG484I 
// Tool versions:   ISE 10.1i SP3 
//
// Description: This test bench is intended to test the RxSM module for the SSP 
//              UART.
//
// Verilog Test Fixture created by ISE for module: UART_RXSM
//
// Dependencies:    UART_TxSM, UART_RxSM
// 
// Revision History:
//
//  0.01    08F07   MAM     File Created
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module tb_UART_RXSM_v;

// Inputs
reg  Rst;
reg  Clk;
reg  CE_16x;
reg  XLen, XNumStop, XParEn;
reg  RLen, RNumStop, RParEn;
reg  [1:0] XPar, RPar;
reg  [3:0] RFMT, XFMT;
wire RxD;

// Outputs
wire [8:0] RD;
wire WE_RHR;
wire RxWait;
wire RxIdle;
wire RxStart;
wire RxShift;
wire RxParity;
wire RxStop;
wire RxError;

reg  TF_EF;
reg  [7:0] THR;
wire TF_RE;
wire TxIdle, TxStart, TxShift, TxStop;

// Instantiate the UART TxSM Module (U1) to drive the RxD Input

UART_TXSM   U1 (
                .Rst(Rst), 
                .Clk(Clk), 
                .CE_16x(CE_16x), 
                .Len(XLen),
                .NumStop(XNumStop),
                .ParEn(XParEn),
                .Par(XPar), 
                .TF_EF(TF_EF), 
                .THR(THR), 
                .TF_RE(TF_RE), 
                .CTSi(1'b1),
                .TxD(RxD), 
                .TxIdle(TxIdle), 
                .TxStart(TxStart),
                .TxShift(TxShift),
                .TxStop(TxStop)
            );

// Instantiate the Unit Under Test (UUT)

UART_RXSM   uut (
                .Rst(Rst), 
                .Clk(Clk), 
                .CE_16x(CE_16x), 
                .Len(RLen),
                .NumStop(RNumStop),
                .ParEn(RParEn),
                .Par(RPar), 
                .RxD(RxD), 
                .RD(RD), 
                .WE_RHR(WE_RHR), 
                .RxWait(RxWait), 
                .RxIdle(RxIdle), 
                .RxStart(RxStart), 
                .RxShift(RxShift), 
                .RxParity(RxParity), 
                .RxStop(RxStop), 
                .RxError(RxError)
            );

initial begin
    Rst     = 1;
    Clk     = 0;
    CE_16x  = 1;
    RFMT    = 0;        //  8N1 - default
    XFMT    = 0;
    THR     = 8'h77;
    TF_EF   = 1;

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here

    @(posedge Clk) #1 TF_EF = 0;
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    @(posedge TxIdle);
    THR   = 8'h55;
    TF_EF = 0;

    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk);

    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    @(negedge TxStop);
    
    TF_EF = 0;
    THR   = 8'h5A;
    RFMT  = 4'b1100;    // 7O1
    XFMT  = RFMT;
    @(posedge TxStart);
    
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

    @(negedge TxStop);
    
    TF_EF = 0;
    THR   = 8'h5A;
    RFMT  = 4'b1100;    // 7O1
    XFMT  = 4'b1101;    // 7E1
    @(posedge TxStart);
    
    @(posedge TF_RE);   // Emulate read of External Tx FIFO
    @(posedge Clk) #1 TF_EF = 1;

end

///////////////////////////////////////////////////////////////////////////////
//
//  Clocks
//

always #5 Clk = ~Clk;
    
///////////////////////////////////////////////////////////////////////////////
//
//  Simulation Drivers/Models
//

//  Transmit Format Decode

always @(XFMT)
    case(XFMT)
        4'b0000 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0001 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0010 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b1, 2'b00};   // 8O1
        4'b0011 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b1, 2'b01};   // 8E1
        4'b0100 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b1, 2'b10};   // 8S1
        4'b0101 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b1, 2'b11};   // 8M1
        4'b0110 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0111 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b1, 1'b0, 2'b00};   // 8N2
        4'b1000 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b1, 1'b1, 2'b00};   // 8O2
        4'b1001 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b1, 1'b1, 2'b01};   // 8E2
        4'b1010 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b1, 1'b1, 2'b10};   // 8S2
        4'b1011 : {XLen, XNumStop, XParEn, XPar} <= {1'b0, 1'b1, 1'b1, 2'b11};   // 8M2
        4'b1100 : {XLen, XNumStop, XParEn, XPar} <= {1'b1, 1'b0, 1'b1, 2'b00};   // 7O1
        4'b1101 : {XLen, XNumStop, XParEn, XPar} <= {1'b1, 1'b0, 1'b1, 2'b01};   // 7E1
        4'b1110 : {XLen, XNumStop, XParEn, XPar} <= {1'b1, 1'b1, 1'b1, 2'b00};   // 7O2
        4'b1111 : {XLen, XNumStop, XParEn, XPar} <= {1'b1, 1'b1, 1'b1, 2'b01};   // 7E2
    endcase

//  Format Decode

always @(RFMT)
    case(RFMT)
        4'b0000 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0001 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0010 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b1, 2'b00};   // 8O1
        4'b0011 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b1, 2'b01};   // 8E1
        4'b0100 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b1, 2'b10};   // 8S1
        4'b0101 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b1, 2'b11};   // 8M1
        4'b0110 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b0, 1'b0, 2'b00};   // 8N1
        4'b0111 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b1, 1'b0, 2'b00};   // 8N2
        4'b1000 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b1, 1'b1, 2'b00};   // 8O2
        4'b1001 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b1, 1'b1, 2'b01};   // 8E2
        4'b1010 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b1, 1'b1, 2'b10};   // 8S2
        4'b1011 : {RLen, RNumStop, RParEn, RPar} <= {1'b0, 1'b1, 1'b1, 2'b11};   // 8M2
        4'b1100 : {RLen, RNumStop, RParEn, RPar} <= {1'b1, 1'b0, 1'b1, 2'b00};   // 7O1
        4'b1101 : {RLen, RNumStop, RParEn, RPar} <= {1'b1, 1'b0, 1'b1, 2'b01};   // 7E1
        4'b1110 : {RLen, RNumStop, RParEn, RPar} <= {1'b1, 1'b1, 1'b1, 2'b00};   // 7O2
        4'b1111 : {RLen, RNumStop, RParEn, RPar} <= {1'b1, 1'b1, 1'b1, 2'b01};   // 7E2
    endcase

endmodule

