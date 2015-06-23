`timescale 1ns / 1ps
/*
 * File         : Top.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   8-Jul-2011   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   The top-level file for the FPGA. Also known as the 'motherboard,' this
 *   file connects all processor, memory, clocks, and I/O devices together.
 *   All inputs and outputs correspond to actual FPGA pins.
 */
module Top(
    input  clock_100MHz,
    input  reset_n,
    // I/O
    input  [7:0] Switch,
    output [14:0] LED,
    output [6:0] LCD,
    input  UART_Rx,
    output UART_Tx,
    inout  i2c_scl,
    inout  i2c_sda,
    output Piezo
    );
    
    
    // Clock signals
    wire clock, clock2x;
    wire PLL_Locked;
    
    reg reset;
    always @(posedge clock) begin
        reset <= ~reset_n | ~PLL_Locked;
    end
    
    // MIPS Processor Signals
    reg  [31:0] MIPS32_DataMem_In;
    wire [31:0] MIPS32_DataMem_Out, MIPS32_InstMem_In;
    wire [29:0] MIPS32_DataMem_Address, MIPS32_InstMem_Address;
    wire [3:0]  MIPS32_DataMem_WE;
    wire        MIPS32_DataMem_Read, MIPS32_InstMem_Read;
    reg         MIPS32_DataMem_Ready;
    wire [4:0]  MIPS32_Interrupts;
    wire        MIPS32_NMI;
    wire [7:0]  MIPS32_IP;
    wire        MIPS32_IO_WE;
    
    // BRAM Memory Signals
    reg  [3:0] BRAM_WEA;
    reg  BRAM_REA;
    reg  [17:0] BRAM_AddrA;
    reg  [31:0] BRAM_DINA;
    wire BRAM_ReadyA;
    wire BRAM_REB;
    wire [3:0] BRAM_WEB;
    wire [31:0] BRAM_DOUTB;
    wire BRAM_ReadyB;
    
    // LCD Signals
    wire [3:0] LCD_WE;
    wire LCD_Ready;

    // UART Bootloader Signals
    wire UART_RE;
    wire UART_WE;
    wire [16:0] UART_DOUT;
    wire UART_Ack;
    wire UART_Interrupt;
    wire UART_BootResetCPU;
    wire [17:0] UART_BootAddress;
    wire [31:0] UART_BootData;
    wire UART_BootWriteMem_pre;
    wire [3:0] UART_BootWriteMem = (UART_BootWriteMem_pre) ? 4'hF : 4'h0;
    
    // I2C Signals
    wire I2C_Ready;
    wire [10:0] I2C_DOUT;
    wire I2C_RE, I2C_WE;

    // Piezo Transducer Signals
    wire Piezo_WE;
    wire Piezo_Ready;
    
    // LED Signals
    wire LED_WE;
    wire LED_RE;
    wire [13:0] LED_DOUT;
    wire LED_Ready;
    wire [13:0] LED_Sw_LEDs;

    // Filtered Switch Input Signals
    wire Switches_RE;
    wire Switches_WE;
    wire Switches_Ready;
    wire [7:0] Switches_DOUT;

    // Clock Generation
    PLL_100MHz_to_33MHz_66MHz Clock_Generator (
        .CLKIN1_IN    (clock_100MHz),
        .RST_IN       (1'b0),
        .CLKOUT0_OUT  (clock), 
        .CLKOUT1_OUT  (clock2x),
        .LOCKED_OUT   (PLL_Locked)
    );

    // MIPS-32 Core
    Processor MIPS32 (
        .clock            (clock),
        .reset            ((reset | UART_BootResetCPU)),
        .Interrupts       (MIPS32_Interrupts),
        .NMI              (MIPS32_NMI),
        .DataMem_In       (MIPS32_DataMem_In),
        .DataMem_Ready    (MIPS32_DataMem_Ready),
        .DataMem_Read     (MIPS32_DataMem_Read),
        .DataMem_Write    (MIPS32_DataMem_WE),
        .DataMem_Address  (MIPS32_DataMem_Address),
        .DataMem_Out      (MIPS32_DataMem_Out),
        .InstMem_In       (MIPS32_InstMem_In),
        .InstMem_Address  (MIPS32_InstMem_Address),
        .InstMem_Ready    (BRAM_ReadyA),
        .InstMem_Read     (MIPS32_InstMem_Read),
        .IP               (MIPS32_IP)
    );

    // On-Chip Block RAM
    BRAM_592KB_Wrapper Memory (
        .clock    (clock2x),
        .reset    (reset),
        .rea      (BRAM_REA),
        .wea      (BRAM_WEA),
        .addra    (BRAM_AddrA),
        .dina     (BRAM_DINA),
        .douta    (MIPS32_InstMem_In),
        .dreadya  (BRAM_ReadyA),
        .reb      (BRAM_REB),
        .web      (BRAM_WEB),
        .addrb    (MIPS32_DataMem_Address[17:0]),
        .dinb     (MIPS32_DataMem_Out),
        .doutb    (BRAM_DOUTB),
        .dreadyb  (BRAM_ReadyB)
    );

    // 16x2 LCD Display Screen
    LCD LCD_Screen (
        .clock_100MHz  (clock2x),
        .clock_Mem     (clock2x),
        .reset         (reset),
        .address       (MIPS32_DataMem_Address[2:0]),
        .data          (MIPS32_DataMem_Out),
        .writeEnable   (LCD_WE),
        .ack           (LCD_Ready),
        .LCD           (LCD)
    );

    // UART + Boot Loader (v2)
    uart_bootloader UART (
        .clock         (clock2x),
        .reset         (reset),
        .Read          (UART_RE),
        .Write         (UART_WE),
        .DataIn        (MIPS32_DataMem_Out[8:0]),
        .DataOut       (UART_DOUT),
        .Ack           (UART_Ack),
        .DataReady     (UART_Interrupt),
        .BootResetCPU  (UART_BootResetCPU),
        .BootWriteMem  (UART_BootWriteMem_pre),
        .BootAddr      (UART_BootAddress),
        .BootData      (UART_BootData),
        .RxD           (UART_Rx),
        .TxD           (UART_Tx)
    );

    // I2C Module
    I2C_Controller I2C (
        .clock    (clock2x),
        .reset    (reset),
        .Read     (I2C_RE),
        .Write    (I2C_WE),
        .DataIn   (MIPS32_DataMem_Out[12:0]),
        .DataOut  (I2C_DOUT),
        .Ack      (I2C_Ready),
        .i2c_scl  (i2c_scl),
        .i2c_sda  (i2c_sda)
    );
    
    // Piezo-electric Transducer
    Piezo_Driver Piezo_Driver (
        .clock  (clock2x), 
        .reset  (reset), 
        .data   (MIPS32_DataMem_Out[24:0]), 
        .Write  (Piezo_WE), 
        .Ack    (Piezo_Ready), 
        .Piezo  (Piezo)
    );
    
    // LEDs
    LED LEDs (
        .clock    (clock2x),
        .reset    (reset),
        .dataIn   (MIPS32_DataMem_Out[14:0]),
        .IP       (MIPS32_IP),
        .Write    (LED_WE),
        .Read     (LED_RE),
        .dataOut  (LED_DOUT),
        .Ack      (LED_Ready),
        .LED      (LED_Sw_LEDs)
    );

    // Filtered Input Switches
    Switches Switches (
        .clock       (clock2x),
        .reset       (reset),
        .Read        (Switches_RE),
        .Write       (Switches_WE),
        .Switch_in   (Switch),
        .Ack         (Switches_Ready),
        .Switch_out  (Switches_DOUT)
    );
    
    
    assign MIPS32_IO_WE = (MIPS32_DataMem_WE == 4'hF) ? 1 : 0;
    assign MIPS32_Interrupts[4:1] = Switches_DOUT[7:4];
    assign MIPS32_Interrupts[0]   = UART_Interrupt;
    assign MIPS32_NMI             = Switches_DOUT[3];
    assign LED = {UART_BootResetCPU, LED_Sw_LEDs[13:0]};

    // Allow writes to Instruction Memory Port when bootloading
    always @(*) begin
        BRAM_REA   <= (UART_BootResetCPU) ? 0 : MIPS32_InstMem_Read;
        BRAM_WEA   <= (UART_BootResetCPU) ? UART_BootWriteMem : 4'h0;
        BRAM_AddrA <= (UART_BootResetCPU) ? UART_BootAddress : MIPS32_InstMem_Address;
        BRAM_DINA  <= (UART_BootResetCPU) ? UART_BootData : 32'h0000_0000;
    end


    always @(*) begin
        case (MIPS32_DataMem_Address[29])
            0 : begin
                    MIPS32_DataMem_In    <= BRAM_DOUTB;
                    MIPS32_DataMem_Ready <= BRAM_ReadyB;
                end
            1 : begin
                    // Memory-mapped I/O
                    case (MIPS32_DataMem_Address[28:26])
                        // LCD
                        3'b000 :    begin
                                        MIPS32_DataMem_In    <= 32'h0000_0000;
                                        MIPS32_DataMem_Ready <= LCD_Ready;
                                    end
                        // I2C
                        3'b001 :    begin
                                        MIPS32_DataMem_In    <= {21'h000000, I2C_DOUT[10:0]};
                                        MIPS32_DataMem_Ready <= I2C_Ready;
                                    end
                        // Piezo
                        3'b010 :    begin
                                        MIPS32_DataMem_In    <= 32'h0000_0000;
                                        MIPS32_DataMem_Ready <= Piezo_Ready;
                                    end
                        // UART
                        3'b011 :    begin
                                        MIPS32_DataMem_In    <= {15'h0000, UART_DOUT[16:0]};
                                        MIPS32_DataMem_Ready <= UART_Ack;
                                    end
                        // LED
                        3'b100 :    begin
                                        MIPS32_DataMem_In    <= {18'h00000, LED_DOUT[13:0]};
                                        MIPS32_DataMem_Ready <= LED_Ready;
                                    end
                        // Switches
                        3'b101 :    begin
                                        MIPS32_DataMem_In    <= {24'h000000, Switches_DOUT[7:0]};
                                        MIPS32_DataMem_Ready <= Switches_Ready;
                                    end
                        default:    begin
                                        MIPS32_DataMem_In    <= 32'h0000_0000;
                                        MIPS32_DataMem_Ready <= 0;
                                    end
                    endcase
                end
        endcase
    end
    
    // Memory
    assign BRAM_REB    = (MIPS32_DataMem_Address[29]) ? 0    : MIPS32_DataMem_Read;
    assign BRAM_WEB    = (MIPS32_DataMem_Address[29]) ? 4'h0 : MIPS32_DataMem_WE;
    // I/O
    assign LCD_WE      = (MIPS32_DataMem_Address[29:26] == 4'b1000) ? MIPS32_DataMem_WE : 4'h0;
    assign Piezo_WE    = (MIPS32_DataMem_Address[29:26] == 4'b1010) ? MIPS32_IO_WE : 0;
    assign I2C_WE      = (MIPS32_DataMem_Address[29:26] == 4'b1001) ? MIPS32_IO_WE : 0;
    assign I2C_RE      = (MIPS32_DataMem_Address[29:26] == 4'b1001) ? MIPS32_DataMem_Read : 0;
    assign UART_WE     = (MIPS32_DataMem_Address[29:26] == 4'b1011) ? MIPS32_IO_WE : 0;
    assign UART_RE     = (MIPS32_DataMem_Address[29:26] == 4'b1011) ? MIPS32_DataMem_Read : 0;
    assign LED_WE      = (MIPS32_DataMem_Address[29:26] == 4'b1100) ? MIPS32_IO_WE : 0;
    assign LED_RE      = (MIPS32_DataMem_Address[29:26] == 4'b1100) ? MIPS32_DataMem_Read : 0;
    assign Switches_WE = (MIPS32_DataMem_Address[29:26] == 4'b1101) ? MIPS32_IO_WE : 0;
    assign Switches_RE = (MIPS32_DataMem_Address[29:26] == 4'b1101) ? MIPS32_DataMem_Read : 0;
    
endmodule

