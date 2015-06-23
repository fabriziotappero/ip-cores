`timescale 1ns / 1ps
/*
 * File         : I2C_Controller.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   25-Jun-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A top-level I2C controller which bridges the I2C physical layer with
 *   the data memory bus. This controller accepts the following commands:
 *
 *      Clear   : [Bit 8]  Empties the I2C FIFO of all data.
 *      EnQ     : [Bit 9]  Enqueues a byte of data to the FIFO for transmission.
 *      Tx      : [Bit 10] Transmits all bytes within the FIFO.
 *      Rx      : [Bit 11] Transmits the first byte in the FIFO (bus address),
 *                         then receives a requested number of bytes into the FIFO.
 *      RxN     : [Bit 12] Sets the number of bytes to receive on an 'Rx' command.
 *
 *   To read data from the FIFO, the data memory bus issues a Read command. The received
 *   data is arranged as follows:
 *
 *      Bit 10  : 'Nack' which indicates if the last Tx/Rx command did not receive
 *                an acknowledgment from the slave device.
 *      Bit  9  : Indicates if the FIFO is currently full.
 *      Bit  8  : Indicates if the FIFO is currently empty.
 *      Bit 7-0 : The first byte in the FIFO.
 */
module I2C_Controller(
    input  clock,
    input  reset,
    input  Read,
    input  Write,
    input  [12:0] DataIn,
    output [10:0] DataOut,
    output Ack,
    
    inout  i2c_scl,
    inout  i2c_sda
    );

    // I2C Physical layer signals
    wire I2C_Read, I2C_Write;
    wire I2C_ReadCountSet;
    wire I2C_EnQ, I2C_DeQ, I2C_Clear;
    wire [7:0] I2C_DataIn, I2C_DataOut;
    wire I2C_Ack, I2C_Nack;
    wire I2C_FifoEmpty, I2C_FifoFull;


    wire Cmd_Clear = DataIn[8];
    wire Cmd_EnQ   = DataIn[9];
    wire Cmd_Tx    = DataIn[10];
    wire Cmd_Rx    = DataIn[11];
    wire Cmd_RxN   = DataIn[12];
    

    assign I2C_Read         = Write & Cmd_Rx;
    assign I2C_Write        = Write & Cmd_Tx;
    assign I2C_ReadCountSet = Write & Cmd_RxN;
    assign I2C_EnQ          = Write & Cmd_EnQ;
    assign I2C_DeQ          = Read;
    assign I2C_Clear        = Write & Cmd_Clear;
    assign I2C_DataIn       = DataIn[7:0];
    assign DataOut[7:0]     = I2C_DataOut;
    assign DataOut[8]       = I2C_FifoEmpty;
    assign DataOut[9]       = I2C_FifoFull;
    assign DataOut[10]      = I2C_Nack;
    assign Ack              = I2C_Ack;
    
    
    // I2C Physical layer
    I2C_Phy PHY (
        .clock         (clock),
        .reset         (reset),
        .Read          (I2C_Read),
        .Write         (I2C_Write),
        .ReadCountSet  (I2C_ReadCountSet),
        .EnQ           (I2C_EnQ),
        .DeQ           (I2C_DeQ),
        .Clear         (I2C_Clear),
        .DataIn        (I2C_DataIn),
        .DataOut       (I2C_DataOut),
        .Ack           (I2C_Ack),
        .Nack          (I2C_Nack),
        .Fifo_Empty    (I2C_FifoEmpty),
        .Fifo_Full     (I2C_FifoFull),
        .i2c_scl       (i2c_scl),
        .i2c_sda       (i2c_sda)
    );

endmodule

