`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:38:44 09/10/2012
// Design Name:   Top
// Module Name:   C:/root/Work/Gauss/Final/Hardware/XUM_Singlecore/MIPS32-Pipelined-Hw/src/Simulation/Top_Tester.v
// Project Name:  MIPS32-Pipelined-Hw
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_Tester;

    // Inputs
    reg clock_100MHz;
    reg reset_n;
    reg [7:0] Switch;
    reg UART_Rx;

    // Outputs
    wire [14:0] LED;
    wire [6:0] LCD;
    wire UART_Tx;
    wire Piezo;

    // Bidirs
    wire i2c_scl;
    wire i2c_sda;

    // Instantiate the Unit Under Test (UUT)
    Top uut (
        .clock_100MHz(clock_100MHz), 
        .reset_n(reset_n), 
        .Switch(Switch), 
        .LED(LED), 
        .LCD(LCD), 
        .UART_Rx(UART_Rx), 
        .UART_Tx(UART_Tx), 
        .i2c_scl(i2c_scl), 
        .i2c_sda(i2c_sda), 
        .Piezo(Piezo)
    );
    integer i;

    initial begin
        // Initialize Inputs
        clock_100MHz = 0;
        reset_n = 0;
        Switch = 0;
        UART_Rx = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        for (i=0; i<900000; i=i+1) begin
            reset_n = (i < 28) ? 0 : 1;
            clock_100MHz = ~clock_100MHz;
            if (i > 4000) Switch <= 8'h00;
            if (i > 100000) i = i - 1;
            #5;
        end
    end
      
endmodule

