`timescale 1ns / 1ps
/*
 * File         : LED.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   13-Jul-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A read/write interface between a 4-way handshaking data bus and
 *   8 LEDs.
 *
 *   An optional mode allows the LEDs to show current interrupts
 *   instead of bus data.
 */
module LED(
    input  clock,
    input  reset,
    input  [14:0] dataIn,
    input  [7:0] IP,
    input  Write,
    input  Read,
    output [13:0] dataOut,
    output reg Ack,
    output [13:0] LED
    );

    reg  [13:0] data;
    reg  useInterrupts;
    
    always @(posedge clock) begin
        data <= (reset) ? 14'b0 : ((Write) ? dataIn[13:0] : data);
        useInterrupts <= (reset) ? 0 : ((Write) ? dataIn[14] : useInterrupts);
    end
    
    always @(posedge clock) begin
        Ack <= (reset) ? 0 : (Write | Read);
    end
    
    assign LED = (useInterrupts) ? {6'b0, IP[7:0]} : data;
    assign dataOut = data;

endmodule

