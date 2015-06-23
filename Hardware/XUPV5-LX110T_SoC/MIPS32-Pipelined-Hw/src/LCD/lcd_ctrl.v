`timescale 1ns / 1ps
/*
 * File         : lcd_ctrl.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   16-Jun-2011  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A controller for the common 16x2-character LCD screen based on the
 *   Sitronix ST7066U, Samsung S6A0069X / KS0066U, Hitachi HD44780, SMOS SED1278,
 *   or other compatible device. This controller uses a 4-bit data bus, is write-only,
 *   and requires a total of 7 output pins to the LCD. The timing must be adjusted for
 *   different input clock frequencies where noted. The primary version is based on a
 *   100 MHz clock.
 */
module lcd_ctrl(
    input  clock,
    input  reset,
    input  [8:0] command,
    input  write,
    output reg ack,
    //---------------------------------
    output reg [3:0] LCD_D, // 4-bit LCD data bus
    output reg LCD_E,       // Enable
    output LCD_RS,          // Register Select (0->Register; 1->Data)
    output LCD_RW           // Read/Write (0->Write; 1->Read)
    );

    localparam [4:0]    INIT_1=1, INIT_2=2, INIT_3=3, INIT_4=4, INIT_5=5, INIT_6=6, INIT_7=7, INIT_8=8,
                        CMD_WAIT=9, NOP=10, U_SETUP=11, U_ENAB=12, U_HOLD=13, UL_WAIT=14, L_SETUP=15,
                        L_ENAB=16, L_HOLD=17;
    
    reg  [18:0] count;
    reg  [18:0] compare;
    reg  [4:0] state;
    wire bell;
    wire long_instr;
    
    assign LCD_RW = 0;                  // There is no reason to read from the LCD screen.
    assign LCD_RS = command[8];
    assign bell = (count == compare);
    assign long_instr = ((command == 9'b0_0000_0001) || (command[8:1] == 8'b0_0000_001));


    /* The count register increments until it equals 'compare' */
    always @(posedge clock) begin
        count <= (reset | bell) ? 19'b0 : count + 1;
    end
    
    /* Time delays for various states */
    always @(*) begin
        case (state)
            INIT_1   : compare <= 19'd410000;  // 15ms (4.1ms OK due to power-up delay)
            INIT_2   : compare <= 19'd24;      // 240 ns
            INIT_3   : compare <= 19'd410000;  // 4.1 ms
            INIT_4   : compare <= 19'd24;      // 240 ns
            INIT_5   : compare <= 19'd10000;   // 100 us or longer
            INIT_6   : compare <= 19'd24;      // 240 ns
            INIT_7   : compare <= 19'd4000;    // 40  us or longer
            INIT_8   : compare <= 19'd24;      // 240 ns
            CMD_WAIT : compare <= (long_instr) ? 19'd164000 : 19'd4000;   // 40 us or 1.64 ms
            NOP      : compare <= 19'hxxxxx;
            U_SETUP  : compare <= 19'd4;       // 40  ns
            U_ENAB   : compare <= 19'd23;      // 230 ns
            U_HOLD   : compare <= 19'd1;       // 10  ns
            UL_WAIT  : compare <= 19'd100;     // 1   us
            L_SETUP  : compare <= 19'd4;       // 40  ns
            L_ENAB   : compare <= 19'd23;      // 230 ns
            L_HOLD   : compare <= 19'd1;       // 10  ns
            default  : compare <= 19'hxxxxx;
        endcase
    end

    /* The main state machine */
    always @(posedge clock) begin
        if (reset) begin
            state <= INIT_1;
        end
        else begin
            case (state)
                INIT_1   : state <= (bell)  ? INIT_2   : INIT_1;
                INIT_2   : state <= (bell)  ? INIT_3   : INIT_2;
                INIT_3   : state <= (bell)  ? INIT_4   : INIT_3;
                INIT_4   : state <= (bell)  ? INIT_5   : INIT_4;
                INIT_5   : state <= (bell)  ? INIT_6   : INIT_5;
                INIT_6   : state <= (bell)  ? INIT_7   : INIT_6;
                INIT_7   : state <= (bell)  ? INIT_8   : INIT_7;
                INIT_8   : state <= (bell)  ? CMD_WAIT : INIT_8;
                CMD_WAIT : state <= (bell)  ? NOP      : CMD_WAIT;
                NOP      : state <= (write & ~ack) ? U_SETUP  : NOP;
                U_SETUP  : state <= (bell)  ? U_ENAB   : U_SETUP;
                U_ENAB   : state <= (bell)  ? U_HOLD   : U_ENAB;
                U_HOLD   : state <= (bell)  ? UL_WAIT  : U_HOLD;
                UL_WAIT  : state <= (bell)  ? L_SETUP  : UL_WAIT;
                L_SETUP  : state <= (bell)  ? L_ENAB   : L_SETUP;
                L_ENAB   : state <= (bell)  ? L_HOLD   : L_ENAB;
                L_HOLD   : state <= (bell)  ? CMD_WAIT : L_HOLD;
                default  : state <= 5'bxxxxx;
            endcase
        end
    end
    
    /* Combinatorial enable and data assignments */
    always @(*) begin
        case (state)
            INIT_1   : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            INIT_2   : begin LCD_E <= 0; LCD_D <= 4'b0011; end
            INIT_3   : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            INIT_4   : begin LCD_E <= 1; LCD_D <= 4'b0011; end
            INIT_5   : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            INIT_6   : begin LCD_E <= 1; LCD_D <= 4'b0011; end
            INIT_7   : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            INIT_8   : begin LCD_E <= 1; LCD_D <= 4'b0010; end
            CMD_WAIT : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            NOP      : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            U_SETUP  : begin LCD_E <= 0; LCD_D <= command[7:4]; end
            U_ENAB   : begin LCD_E <= 1; LCD_D <= command[7:4]; end
            U_HOLD   : begin LCD_E <= 0; LCD_D <= command[7:4]; end
            UL_WAIT  : begin LCD_E <= 0; LCD_D <= 4'b0000; end
            L_SETUP  : begin LCD_E <= 0; LCD_D <= command[3:0]; end
            L_ENAB   : begin LCD_E <= 1; LCD_D <= command[3:0]; end
            L_HOLD   : begin LCD_E <= 0; LCD_D <= command[3:0]; end
            default  : begin LCD_E <= 0; LCD_D <= 4'b0000; end
        endcase
    end
    
    /* Full 4-way Handshake */
    always @(posedge clock) begin       
        ack <= (reset | ~write) ? 0 : (((state == L_HOLD) && (bell == 1'b1)) ? 1 : ack);
    end

endmodule

