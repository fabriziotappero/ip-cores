`timescale 1ns / 1ps
/*
 * File         : I2C_Phy.v
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
 *   I2C Master controller made for a single-master I2C bus.
 *   Uses a FIFO to store transmit and receive data, and is made
 *   to be generic enough to use with a wide variety of I2C slave devices.
 *   A Read command sends a bus address byte then receives a requested number
 *   of bytes, while a Write command writes all bytes that are presently in
 *   the FIFO.
 */

module I2C_Phy(
    input  clock,
    input  reset,
    input  Read,
    input  Write,
    input  ReadCountSet,
    input  EnQ,
    input  DeQ,
    input  Clear,
    input  [7:0] DataIn,
    output reg [7:0] DataOut,
    output Ack,
    output reg Nack,
    output Fifo_Empty,
    output Fifo_Full,
    inout  i2c_scl,
    inout  i2c_sda
    );

    localparam [5:0]    IDLE=0, ENQ=1, DEQ=2, START=3, ADDR6=4, ADDR5=5, ADDR4=6, ADDR3=7, ADDR2=8,
                        ADDR1=9, ADDR0=10, RWBIT=11, A_DEQ=12, A_ACK=13, WDWAIT=14, WDATA7=15,
                        WDATA6=16, WDATA5=17, WDATA4=18, WDATA3=19, WDATA2=20, WDATA1=21, WDATA0=22,
                        W_DEQ=23, W_ACK=24, RDATA7=25, RDATA6=26, RDATA5=27, RDATA4=28, RDATA3=29,
                        RDATA2=30, RDATA1=31, RDATA0=32, R_ENQ=33, R_ACKW=34, R_ACK=35, NACK=36,
                        STOPW=37, STOP=38, BUSW=39, CLEAR=40, RNSET=41;

    // FIFO signals
    wire Fifo_Clear, Fifo_EnQ, Fifo_DeQ;
    wire [7:0] Fifo_In, Fifo_Out;
    
    wire scl, scl_tick_90;
    reg [5:0] state;
    reg [7:0] Rx_Data;
    reg sda;
    reg [7:0] Rx_Todo, Rx_Remain;
    
    // The I2C bus is high-impedance instead of a driven 1.
    assign i2c_sda = (sda) ? 1'bz : 1'b0;
    assign i2c_scl = (scl | (state == IDLE)) ? 1'bz : 1'b0;
    
    // Control logic : 4-way handshaking
    assign Ack = (state == BUSW);

    always @(posedge clock) begin
        Rx_Todo   <= (reset) ? 8'h00 : ((state == RNSET) ? DataIn : Rx_Todo);
        Rx_Remain <= (reset) ? 8'h00 : ((state == IDLE) ? Rx_Todo : ((state == R_ENQ) ? Rx_Remain - 1 : Rx_Remain));
    end
    
    always @(posedge clock) begin
        DataOut <= (reset) ? 8'h00 : ((state == DEQ) ? Fifo_Out : DataOut);
    end
    
    always @(posedge clock) begin
        Nack <= (reset | (state == START)) ? 0 : ((state == NACK) ? 1 : Nack);
    end

    assign Fifo_EnQ   = (state == ENQ) || (state == R_ENQ);
    assign Fifo_DeQ   = (state == DEQ) || (state == A_DEQ) || (state == W_DEQ);
    assign Fifo_In    = (state == R_ENQ) ? Rx_Data : DataIn;
    assign Fifo_Clear = (state == CLEAR);
    
    // Main state machine
    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE:   begin
                            if      (EnQ)           state <= ENQ;
                            else if (DeQ)           state <= DEQ;
                            else if (Clear)         state <= CLEAR;
                            else if (ReadCountSet)  state <= RNSET;
                            else if ((Read | Write) & scl & scl_tick_90) state <= START;
                            else    state <= IDLE;
                        end
                ENQ:    state <= BUSW;
                DEQ:    state <= BUSW;
                CLEAR:  state <= BUSW;
                RNSET:  state <= BUSW;
                START:  state <= (~scl & scl_tick_90) ? ADDR6 : START;
                ADDR6:  state <= (~scl & scl_tick_90) ? ADDR5 : ADDR6;
                ADDR5:  state <= (~scl & scl_tick_90) ? ADDR4 : ADDR5;
                ADDR4:  state <= (~scl & scl_tick_90) ? ADDR3 : ADDR4;
                ADDR3:  state <= (~scl & scl_tick_90) ? ADDR2 : ADDR3;
                ADDR2:  state <= (~scl & scl_tick_90) ? ADDR1 : ADDR2;
                ADDR1:  state <= (~scl & scl_tick_90) ? ADDR0 : ADDR1;
                ADDR0:  state <= (~scl & scl_tick_90) ? RWBIT : ADDR0;
                RWBIT:  state <= (~scl & scl_tick_90) ? A_DEQ : RWBIT;
                A_DEQ:  state <= A_ACK;
                A_ACK:  state <= ( scl & scl_tick_90) ? ((i2c_sda) ? NACK : ((Read) ? RDATA7 : WDWAIT)) : A_ACK;
                
                // Writes
                WDWAIT: state <= (~scl & scl_tick_90) ? WDATA7 : WDWAIT;
                WDATA7: state <= (~scl & scl_tick_90) ? WDATA6 : WDATA7;
                WDATA6: state <= (~scl & scl_tick_90) ? WDATA5 : WDATA6;
                WDATA5: state <= (~scl & scl_tick_90) ? WDATA4 : WDATA5;
                WDATA4: state <= (~scl & scl_tick_90) ? WDATA3 : WDATA4;
                WDATA3: state <= (~scl & scl_tick_90) ? WDATA2 : WDATA3;
                WDATA2: state <= (~scl & scl_tick_90) ? WDATA1 : WDATA2;
                WDATA1: state <= (~scl & scl_tick_90) ? WDATA0 : WDATA1;
                WDATA0: state <= (~scl & scl_tick_90) ? W_DEQ  : WDATA0;
                W_DEQ:  state <= W_ACK;
                W_ACK:  state <= ( scl & scl_tick_90) ? ((i2c_sda) ? NACK : ((Fifo_Empty) ? STOPW : WDWAIT)) : W_ACK;
                
                // Reads
                RDATA7: state <= ( scl & scl_tick_90) ? RDATA6 : RDATA7;
                RDATA6: state <= ( scl & scl_tick_90) ? RDATA5 : RDATA6;
                RDATA5: state <= ( scl & scl_tick_90) ? RDATA4 : RDATA5;
                RDATA4: state <= ( scl & scl_tick_90) ? RDATA3 : RDATA4;
                RDATA3: state <= ( scl & scl_tick_90) ? RDATA2 : RDATA3;
                RDATA2: state <= ( scl & scl_tick_90) ? RDATA1 : RDATA2;
                RDATA1: state <= ( scl & scl_tick_90) ? RDATA0 : RDATA1;
                RDATA0: state <= ( scl & scl_tick_90) ? R_ENQ  : RDATA0;
                R_ENQ:  state <= R_ACKW;
                R_ACKW: state <= (~scl & scl_tick_90) ? R_ACK : R_ACKW;
                R_ACK:  state <= (~scl & scl_tick_90) ? ((Rx_Remain != 8'h00) ? RDATA7 : STOP) : R_ACK;
                
                // Termination
                NACK:   state <= STOPW;
                STOPW:  state <= (~scl & scl_tick_90) ? STOP : STOPW;
                STOP:   state <= ( scl & scl_tick_90) ? BUSW : STOP;
                BUSW:   state <= (Read | Write | EnQ | DeQ) ? BUSW : IDLE;
                default: state <= 6'bxxxxxx; 
            endcase
        end
    end    

    // Incoming data capture
    always @(posedge clock) begin
        if (reset) begin
            Rx_Data <= 8'h00;
        end
        else begin
            Rx_Data[7] <= ((state == RDATA7) & scl & scl_tick_90) ? i2c_sda : Rx_Data[7];
            Rx_Data[6] <= ((state == RDATA6) & scl & scl_tick_90) ? i2c_sda : Rx_Data[6];
            Rx_Data[5] <= ((state == RDATA5) & scl & scl_tick_90) ? i2c_sda : Rx_Data[5];
            Rx_Data[4] <= ((state == RDATA4) & scl & scl_tick_90) ? i2c_sda : Rx_Data[4];
            Rx_Data[3] <= ((state == RDATA3) & scl & scl_tick_90) ? i2c_sda : Rx_Data[3];
            Rx_Data[2] <= ((state == RDATA2) & scl & scl_tick_90) ? i2c_sda : Rx_Data[2];
            Rx_Data[1] <= ((state == RDATA1) & scl & scl_tick_90) ? i2c_sda : Rx_Data[1];
            Rx_Data[0] <= ((state == RDATA0) & scl & scl_tick_90) ? i2c_sda : Rx_Data[0];
        end
    end

    // I2C data line assignment
    always @(*) begin
        case (state)
            IDLE:   sda <= 1;
            ENQ:    sda <= 1;
            DEQ:    sda <= 1;
            CLEAR:  sda <= 1;
            START:  sda <= 0;
            ADDR6:  sda <= Fifo_Out[6];
            ADDR5:  sda <= Fifo_Out[5];
            ADDR4:  sda <= Fifo_Out[4];
            ADDR3:  sda <= Fifo_Out[3];
            ADDR2:  sda <= Fifo_Out[2];
            ADDR1:  sda <= Fifo_Out[1];
            ADDR0:  sda <= Fifo_Out[0];
            RWBIT:  sda <= Read;   // 0 is write, 1 is read
            A_DEQ:  sda <= 1;
            A_ACK:  sda <= 1;
            WDWAIT: sda <= 1;
            WDATA7: sda <= Fifo_Out[7];
            WDATA6: sda <= Fifo_Out[6];
            WDATA5: sda <= Fifo_Out[5];
            WDATA4: sda <= Fifo_Out[4];
            WDATA3: sda <= Fifo_Out[3];
            WDATA2: sda <= Fifo_Out[2];
            WDATA1: sda <= Fifo_Out[1];
            WDATA0: sda <= Fifo_Out[0];
            W_DEQ:  sda <= 1;
            W_ACK:  sda <= 1;
            RDATA7: sda <= 1;
            RDATA6: sda <= 1;
            RDATA5: sda <= 1;
            RDATA4: sda <= 1;
            RDATA3: sda <= 1;
            RDATA2: sda <= 1;
            RDATA1: sda <= 1;
            RDATA0: sda <= 1;
            R_ENQ:  sda <= 1;
            R_ACKW: sda <= 1;
            R_ACK:  sda <= (Rx_Remain == 8'h00); // Low for more data, high for done
            NACK:   sda <= 1;
            STOPW:  sda <= 1;
            STOP:   sda <= 0;
            BUSW:   sda <= 1;
            default: sda <= 1;
        endcase
    end

    // I2C Clock Generation
    I2C_Clock I2C_Clock (
        .clock        (clock), 
        .reset        (reset), 
        .scl          (scl), 
        .scl_tick_90  (scl_tick_90)
    );

    FIFO_Clear FIFO (
        .clock     (clock),
        .reset     (reset),
        .clear     (Fifo_Clear),
        .enQ       (Fifo_EnQ),
        .deQ       (Fifo_DeQ),
        .data_in   (Fifo_In),
        .data_out  (Fifo_Out),
        .empty     (Fifo_Empty),
        .full      (Fifo_Full)
    );

endmodule

