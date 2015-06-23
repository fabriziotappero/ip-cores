`timescale 1ns / 1ps
/*
 * File         : LCD.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   16-Jun-2012  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   The top-level LCD controller. This module bridges the underlying 16x2 LCD
 *   hardware controller and the data memory bus. It caches 32 bytes of data which
 *   each correspond to a location on the LCD screen. The LCD screen is continuously
 *   updated with these 32 bytes as quickly as possible.
 */
module LCD(
    input  clock_100MHz,
    input  clock_Mem,
    input  reset,
    input  [2:0] address,
    input  [31:0] data,
    input  [3:0] writeEnable,
    output reg ack,    
    output [6:0] LCD
    );

    localparam [5:0]    INIT_1=1, INIT_2=2, INIT_3=3, INIT_4=4, LOC_0=5, LOC_1=6, LOC_2=7,
                        LOC_3=8, LOC_4=9, LOC_5=10, LOC_6=11, LOC_7=12, LOC_8=13, LOC_9=14, LOC_10=15,
                        LOC_11=16, LOC_12=17, LOC_13=18, LOC_14=19, LOC_15=20, LOC_16=21, LOC_17=22,
                        LOC_18=23, LOC_19=24, LOC_20=25, LOC_21=26, LOC_22=27, LOC_23=28, LOC_24=29,
                        LOC_25=30, LOC_26=31, LOC_27=32, LOC_28=33, LOC_29=34, LOC_30=35, LOC_31=36,
                        LINE_2=37, HOME=38;


    wire clock = clock_100MHz;
    reg [31:0] a0, a1, a2, a3, a4, a5, a6, a7;
    reg [5:0] state;
    wire bell;

    // LCD driver signals
    reg  [8:0] lcd_command;
    reg  lcd_write;
    wire lcd_ack;

    assign bell = ~(lcd_write | lcd_ack);

    always @(posedge clock_Mem) begin
        ack <= (reset) ? 0 : (writeEnable != 4'b0000);
    end

    /* 32 bytes of LCD memory held on the FPGA fabric. The following is BIG ENDIAN */
    always @(posedge clock_Mem) begin
        a0[31:24] <= (reset) ? 8'h20 : (((address == 3'd0) & writeEnable[3]) ? data[31:24] : a0[31:24]);
        a0[23:16] <= (reset) ? 8'h20 : (((address == 3'd0) & writeEnable[2]) ? data[23:16] : a0[23:16]);
        a0[15:8]  <= (reset) ? 8'h20 : (((address == 3'd0) & writeEnable[1]) ? data[15:8]  : a0[15:8]);
        a0[7:0]   <= (reset) ? 8'h20 : (((address == 3'd0) & writeEnable[0]) ? data[7:0]   : a0[7:0]);
        a1[31:24] <= (reset) ? 8'h20 : (((address == 3'd1) & writeEnable[3]) ? data[31:24] : a1[31:24]);
        a1[23:16] <= (reset) ? 8'h20 : (((address == 3'd1) & writeEnable[2]) ? data[23:16] : a1[23:16]);
        a1[15:8]  <= (reset) ? 8'h20 : (((address == 3'd1) & writeEnable[1]) ? data[15:8]  : a1[15:8]);
        a1[7:0]   <= (reset) ? 8'h20 : (((address == 3'd1) & writeEnable[0]) ? data[7:0]   : a1[7:0]);
        a2[31:24] <= (reset) ? 8'h20 : (((address == 3'd2) & writeEnable[3]) ? data[31:24] : a2[31:24]);
        a2[23:16] <= (reset) ? 8'h20 : (((address == 3'd2) & writeEnable[2]) ? data[23:16] : a2[23:16]);
        a2[15:8]  <= (reset) ? 8'h20 : (((address == 3'd2) & writeEnable[1]) ? data[15:8]  : a2[15:8]);
        a2[7:0]   <= (reset) ? 8'h20 : (((address == 3'd2) & writeEnable[0]) ? data[7:0]   : a2[7:0]);
        a3[31:24] <= (reset) ? 8'h20 : (((address == 3'd3) & writeEnable[3]) ? data[31:24] : a3[31:24]);
        a3[23:16] <= (reset) ? 8'h20 : (((address == 3'd3) & writeEnable[2]) ? data[23:16] : a3[23:16]);
        a3[15:8]  <= (reset) ? 8'h20 : (((address == 3'd3) & writeEnable[1]) ? data[15:8]  : a3[15:8]);
        a3[7:0]   <= (reset) ? 8'h21 : (((address == 3'd3) & writeEnable[0]) ? data[7:0]   : a3[7:0]);
        a4[31:24] <= (reset) ? 8'h20 : (((address == 3'd4) & writeEnable[3]) ? data[31:24] : a4[31:24]);
        a4[23:16] <= (reset) ? 8'h20 : (((address == 3'd4) & writeEnable[2]) ? data[23:16] : a4[23:16]);
        a4[15:8]  <= (reset) ? 8'h20 : (((address == 3'd4) & writeEnable[1]) ? data[15:8]  : a4[15:8]);
        a4[7:0]   <= (reset) ? 8'h20 : (((address == 3'd4) & writeEnable[0]) ? data[7:0]   : a4[7:0]);
        a5[31:24] <= (reset) ? 8'h20 : (((address == 3'd5) & writeEnable[3]) ? data[31:24] : a5[31:24]);
        a5[23:16] <= (reset) ? 8'h20 : (((address == 3'd5) & writeEnable[2]) ? data[23:16] : a5[23:16]);
        a5[15:8]  <= (reset) ? 8'h20 : (((address == 3'd5) & writeEnable[1]) ? data[15:8]  : a5[15:8]);
        a5[7:0]   <= (reset) ? 8'h20 : (((address == 3'd5) & writeEnable[0]) ? data[7:0]   : a5[7:0]);
        a6[31:24] <= (reset) ? 8'h20 : (((address == 3'd6) & writeEnable[3]) ? data[31:24] : a6[31:24]);
        a6[23:16] <= (reset) ? 8'h20 : (((address == 3'd6) & writeEnable[2]) ? data[23:16] : a6[23:16]);
        a6[15:8]  <= (reset) ? 8'h20 : (((address == 3'd6) & writeEnable[1]) ? data[15:8]  : a6[15:8]);
        a6[7:0]   <= (reset) ? 8'h20 : (((address == 3'd6) & writeEnable[0]) ? data[7:0]   : a6[7:0]);
        a7[31:24] <= (reset) ? 8'h20 : (((address == 3'd7) & writeEnable[3]) ? data[31:24] : a7[31:24]);
        a7[23:16] <= (reset) ? 8'h20 : (((address == 3'd7) & writeEnable[2]) ? data[23:16] : a7[23:16]);
        a7[15:8]  <= (reset) ? 8'h20 : (((address == 3'd7) & writeEnable[1]) ? data[15:8]  : a7[15:8]);
        a7[7:0]   <= (reset) ? 8'h20 : (((address == 3'd7) & writeEnable[0]) ? data[7:0]   : a7[7:0]);
    end

    /* The LCD continuously writes the memory locations as fast as possible */
    always @(posedge clock) begin
        lcd_write <= (reset) ? 1 : ~lcd_ack;
    end

    /* LCD commands for initialization and looping through 32 locations */
    always @(*) begin
        case (state)
            INIT_1  : lcd_command <= 9'b000101000;      // 0x28 'Function Set' Not sure what this means
            INIT_2  : lcd_command <= 9'b000000110;      // Entry mode: set auto increment and no shifting
            INIT_3  : lcd_command <= 9'b000001100;      // Turn LCD on, disable cursor/blinking
            INIT_4  : lcd_command <= 9'b000000001;      // Clear display
            LOC_0   : lcd_command <= {1'b1, a0[31:24]};
            LOC_1   : lcd_command <= {1'b1, a0[23:16]};
            LOC_2   : lcd_command <= {1'b1, a0[15:8]};
            LOC_3   : lcd_command <= {1'b1, a0[7:0]};
            LOC_4   : lcd_command <= {1'b1, a1[31:24]};
            LOC_5   : lcd_command <= {1'b1, a1[23:16]};
            LOC_6   : lcd_command <= {1'b1, a1[15:8]};
            LOC_7   : lcd_command <= {1'b1, a1[7:0]};
            LOC_8   : lcd_command <= {1'b1, a2[31:24]};
            LOC_9   : lcd_command <= {1'b1, a2[23:16]};
            LOC_10  : lcd_command <= {1'b1, a2[15:8]};
            LOC_11  : lcd_command <= {1'b1, a2[7:0]};
            LOC_12  : lcd_command <= {1'b1, a3[31:24]};
            LOC_13  : lcd_command <= {1'b1, a3[23:16]};
            LOC_14  : lcd_command <= {1'b1, a3[15:8]};
            LOC_15  : lcd_command <= {1'b1, a3[7:0]};
            LINE_2  : lcd_command <= 9'b011000000;
            LOC_16  : lcd_command <= {1'b1, a4[31:24]};
            LOC_17  : lcd_command <= {1'b1, a4[23:16]};
            LOC_18  : lcd_command <= {1'b1, a4[15:8]};
            LOC_19  : lcd_command <= {1'b1, a4[7:0]};
            LOC_20  : lcd_command <= {1'b1, a5[31:24]};
            LOC_21  : lcd_command <= {1'b1, a5[23:16]};
            LOC_22  : lcd_command <= {1'b1, a5[15:8]};
            LOC_23  : lcd_command <= {1'b1, a5[7:0]};
            LOC_24  : lcd_command <= {1'b1, a6[31:24]};
            LOC_25  : lcd_command <= {1'b1, a6[23:16]};
            LOC_26  : lcd_command <= {1'b1, a6[15:8]};
            LOC_27  : lcd_command <= {1'b1, a6[7:0]};
            LOC_28  : lcd_command <= {1'b1, a7[31:24]};
            LOC_29  : lcd_command <= {1'b1, a7[23:16]};
            LOC_30  : lcd_command <= {1'b1, a7[15:8]};
            LOC_31  : lcd_command <= {1'b1, a7[7:0]};
            HOME    : lcd_command <= 9'b010000000;
            default : lcd_command <= 9'bx_xxxx_xxxx;
        endcase
    end

    /* Main state machine */
    always @(posedge clock) begin
        if (reset) begin
            state <= INIT_1;
        end
        else begin
            case (state)
                INIT_1  : state <= (bell) ? INIT_2 : INIT_1;
                INIT_2  : state <= (bell) ? INIT_3 : INIT_2;
                INIT_3  : state <= (bell) ? INIT_4 : INIT_3;
                INIT_4  : state <= (bell) ? LOC_0  : INIT_4;
                LOC_0   : state <= (bell) ? LOC_1  : LOC_0;
                LOC_1   : state <= (bell) ? LOC_2  : LOC_1;
                LOC_2   : state <= (bell) ? LOC_3  : LOC_2;
                LOC_3   : state <= (bell) ? LOC_4  : LOC_3;
                LOC_4   : state <= (bell) ? LOC_5  : LOC_4;
                LOC_5   : state <= (bell) ? LOC_6  : LOC_5;
                LOC_6   : state <= (bell) ? LOC_7  : LOC_6;
                LOC_7   : state <= (bell) ? LOC_8  : LOC_7;
                LOC_8   : state <= (bell) ? LOC_9  : LOC_8;
                LOC_9   : state <= (bell) ? LOC_10 : LOC_9;
                LOC_10  : state <= (bell) ? LOC_11 : LOC_10;
                LOC_11  : state <= (bell) ? LOC_12 : LOC_11;
                LOC_12  : state <= (bell) ? LOC_13 : LOC_12;
                LOC_13  : state <= (bell) ? LOC_14 : LOC_13;
                LOC_14  : state <= (bell) ? LOC_15 : LOC_14;
                LOC_15  : state <= (bell) ? LINE_2 : LOC_15;
                LINE_2  : state <= (bell) ? LOC_16 : LINE_2;
                LOC_16  : state <= (bell) ? LOC_17 : LOC_16;
                LOC_17  : state <= (bell) ? LOC_18 : LOC_17;
                LOC_18  : state <= (bell) ? LOC_19 : LOC_18;
                LOC_19  : state <= (bell) ? LOC_20 : LOC_19;
                LOC_20  : state <= (bell) ? LOC_21 : LOC_20;
                LOC_21  : state <= (bell) ? LOC_22 : LOC_21;
                LOC_22  : state <= (bell) ? LOC_23 : LOC_22;
                LOC_23  : state <= (bell) ? LOC_24 : LOC_23;
                LOC_24  : state <= (bell) ? LOC_25 : LOC_24;
                LOC_25  : state <= (bell) ? LOC_26 : LOC_25;
                LOC_26  : state <= (bell) ? LOC_27 : LOC_26;
                LOC_27  : state <= (bell) ? LOC_28 : LOC_27;
                LOC_28  : state <= (bell) ? LOC_29 : LOC_28;
                LOC_29  : state <= (bell) ? LOC_30 : LOC_29;
                LOC_30  : state <= (bell) ? LOC_31 : LOC_30;
                LOC_31  : state <= (bell) ? HOME   : LOC_31;
                HOME    : state <= (bell) ? LOC_0  : HOME;
                default : state <= 6'bxxxxxx;
            endcase
        end
    end

    lcd_ctrl LCD_Driver (
        .clock    (clock), 
        .reset    (reset), 
        .command  (lcd_command), 
        .write    (lcd_write), 
        .ack      (lcd_ack), 
        .LCD_D    (LCD[6:3]), 
        .LCD_E    (LCD[2]), 
        .LCD_RS   (LCD[1]), 
        .LCD_RW   (LCD[0])
    );

endmodule

