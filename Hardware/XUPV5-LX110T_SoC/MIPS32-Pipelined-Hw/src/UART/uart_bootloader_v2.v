`timescale 1ns / 1ps
/*
 * File         : uart_bootloader_v2.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   24-May-2010  GEA       Initial design of standalone bootloader
 *   2.0    7-Jul-2012  GEA       Added data memory bus to allow for general-purpose use.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   An RS-232 compatible UART coupled with the XUM bootloader.
 *
 *   The UART is general-purpose and capable of sending and receiving at a
 *   pre-determined BAUD rate (determined by the clocking module) 
 *   with 8 data bits, 1 stop bit, and no parity. In other words it 
 *   is 8N1 with only RxD and TxD signals. It uses two 256-byte FIFO 
 *   buffers, one for receiving and the other for transmitting.
 *
 *   The XUM bootloader protocol is as follows:
 *
 *      1. Programmer sends 'XUM' ASCII bytes.
 *      2. Programmer sends a number indicating how many 32-bit data words
 *         it has to send, minus 1. (For example, if it has one 32-bit data word,
 *         this number would be 0.) The size of this number is 18 bits.
 *         This means the minimum transmission size is 1 word (32 bits), and
 *         the maximum transmission size is 262144 words, or exactly 1 MB.
 *         This 18-bit number is sent MSB first, in three bytes, with the six
 *         most-significant bits set to 0.
 *      3. The FPGA sends back the third size byte from the programmer, allowing
 *         the programmer to determine if the FPGA is listening and conforming
 *         to the XUM boot protocol.
 *      4. The programmer sends another 18-bit number indicating the starting
 *         offset in memory where the data should be placed. Normally this will
 *         be 0. This number is also sent in three bytes, and the six most-significant
 *         bits of the first byte are ignored.
 *      5. The programmer sends the data. A copy of each byte that it sends will be
 *         sent back to the programmer from the FPGA, allowing the programmer
 *         to determine if all of the data was transmitted successfully.
 *
 *   On reset, the bootloader is enabled by default. When the bootloader is enabled,
 *   the data memory bus will not see any incoming data. To configure the UART for
 *   general-purpose use, software must issue a write command to the UART
 *   over the data memory bus with bit 8 set. This disables the boot protocol until
 *   the UART is reset again and allows normal use. Note however that there is 
 *   a 5-second guard time after reset during which the boot loader is
 *   enabled regardless of any software commands to disable it. After the 5 second
 *   time has lapsed after reset, the software state determines the operating mode
 *   of the UART.
 */
module uart_bootloader(
    input  clock,
    input  reset,
    input  Read,                // MMIO
    input  Write,               // MMIO
    input  [8:0] DataIn,        // MMIO
    output reg [16:0] DataOut,  // MMIO
    output Ack,                 // MMIO
    output DataReady,           // Can be used as an interrupt
    output BootResetCPU,        // XUM Boot Protocol: Reset CPU
    output BootWriteMem,        // XUM Boot Protocol: Write to CPU memory
    output reg [17:0] BootAddr, // XUM Boot Protocol
    output reg [31:0] BootData, // XUM Boot Protocol
    input RxD,                  // UART Rx Signal
    output TxD                  // UART Tx Signal
    );

    localparam [4:0]    IDLE=0, WRITE=1, READ=2, BUSW=3, XHEAD1=4, XHEAD2=5, XHEAD3=6, XSIZE1=7, XSIZE2=8, XSIZE3=9, 
                        XOFST1=10, XOFST2=11, XOFST3=12, XDATA1=13, XDATA2=14, XDATA3=15, XDATA4=16, XADDRI=17;

    // UART module signals
    wire uart_write; 
    reg  uart_read;
    wire uart_data_ready;
    wire [7:0] uart_data_in;
    wire [7:0] uart_data_out;
    wire [8:0] uart_rx_count;
    
    reg [8:0] DataIn_r;             // Latch for incoming data to improve timing
    wire DisableBoot = DataIn_r[8]; // Software boot disable command is bit 8
    reg [28:0] BootTimedEnable;     // Hardware override enabler for boot loader after reset
    reg  BootSwEnabled;             // Software enabled/disabled state of bootloader
    wire BootProtoEnabled;          // Master bootloader enabled signal
    reg [17:0] rx_count;            // Number of 32-bit words received (boot loader)
    reg [17:0] rx_size;             // Number of 32-bit words to expect (boot loader)
    reg  [4:0] state;

    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE:    begin
                            if      (Write)                              state <= WRITE;
                            else if (Read)                               state <= READ;
                            else if (BootProtoEnabled & uart_data_ready) state <= XHEAD1;
                            else                                         state <= IDLE;
                         end
                WRITE:   state <= BUSW;
                READ:    state <= BUSW;
                BUSW:    state <= ~(Read | Write) ? IDLE : BUSW;
                XHEAD1:  state <= (uart_data_out == 8'h58) ? XHEAD2 : IDLE;                                 // 'X'
                XHEAD2:  state <= (uart_data_ready) ? ((uart_data_out == 8'h55) ? XHEAD3 : IDLE) : XHEAD2;  // 'U'
                XHEAD3:  state <= (uart_data_ready) ? ((uart_data_out == 8'h4D) ? XSIZE1 : IDLE) : XHEAD3;  // 'M'
                XSIZE1:  state <= (uart_data_ready) ? ((uart_data_out[7:2] == 6'b000000) ? XSIZE2 : IDLE) : XSIZE1;
                XSIZE2:  state <= (uart_data_ready) ? XSIZE3 : XSIZE2;
                XSIZE3:  state <= (uart_data_ready) ? XOFST1 : XSIZE3;
                XOFST1:  state <= (uart_data_ready) ? XOFST2 : XOFST1;
                XOFST2:  state <= (uart_data_ready) ? XOFST3 : XOFST2;
                XOFST3:  state <= (uart_data_ready) ? XDATA1 : XOFST3;
                XDATA1:  state <= (uart_data_ready) ? XDATA2 : XDATA1;
                XDATA2:  state <= (uart_data_ready) ? XDATA3 : XDATA2;
                XDATA3:  state <= (uart_data_ready) ? XDATA4 : XDATA3;
                XDATA4:  state <= (uart_data_ready) ? XADDRI : XDATA4;
                XADDRI:  state <= (rx_count == rx_size) ? IDLE : XDATA1;
                default: state <= IDLE;
            endcase
        end
    end
    
    always @(*) begin
        case (state)
            IDLE:    uart_read <= 0;
            WRITE:   uart_read <= 0;
            READ:    uart_read <= 1;
            BUSW:    uart_read <= 0;
            XHEAD1:  uart_read <= uart_data_ready;
            XHEAD2:  uart_read <= uart_data_ready;
            XHEAD3:  uart_read <= uart_data_ready;
            XSIZE1:  uart_read <= uart_data_ready;
            XSIZE2:  uart_read <= uart_data_ready;
            XSIZE3:  uart_read <= uart_data_ready;
            XOFST1:  uart_read <= uart_data_ready;
            XOFST2:  uart_read <= uart_data_ready;
            XOFST3:  uart_read <= uart_data_ready;
            XDATA1:  uart_read <= uart_data_ready;
            XDATA2:  uart_read <= uart_data_ready;
            XDATA3:  uart_read <= uart_data_ready;
            XDATA4:  uart_read <= uart_data_ready;
            XADDRI:  uart_read <= 0;
            default: uart_read <= 0;
        endcase
    end
    
    always @(posedge clock) begin
        DataIn_r <= ((state == IDLE) & Write) ? DataIn : DataIn_r;
    end
    
    always @(posedge clock) begin
        DataOut <= (reset) ? 17'h00000 : ((state == READ) ? {uart_rx_count[8:0], uart_data_out[7:0]} : DataOut);
    end
    
    always @(posedge clock) begin
        BootTimedEnable <= (reset) ? 29'h00000000 : (BootTimedEnable != 29'h1dcd6500) ? BootTimedEnable + 1 : BootTimedEnable; // 5 sec @ 100 MHz
        BootSwEnabled <= (reset) ? 1 : ((state == WRITE) ? ~DisableBoot : BootSwEnabled);
    end
    
    assign BootResetCPU = (state != IDLE) && (state != WRITE) && (state != READ) && (state != BUSW) &&
                          (state != XHEAD1) && (state != XHEAD2) && (state != XHEAD3) && (state != XSIZE1);
    assign BootWriteMem = (state == XADDRI);
    assign uart_write   = ((state == WRITE) & ~DisableBoot) | 
                          (uart_data_ready & ((state == XSIZE3) | (state == XDATA1) | (state == XDATA2) | (state == XDATA3) | (state == XDATA4)));
    assign uart_data_in = (state == WRITE) ? DataIn_r[7:0] : uart_data_out;
    assign Ack          = (state == BUSW);
    assign DataReady    = uart_data_ready;
    assign BootProtoEnabled = BootSwEnabled | (BootTimedEnable != 29'h1dcd6500);
    
    
    // XUM Boot Protocol Logic
    always @(posedge clock) begin
        BootData[31:24] <= (reset) ? 8'h00 : (((state == XDATA1) & uart_data_ready) ? uart_data_out : BootData[31:24]);
        BootData[23:16] <= (reset) ? 8'h00 : (((state == XDATA2) & uart_data_ready) ? uart_data_out : BootData[23:16]);
        BootData[15:8]  <= (reset) ? 8'h00 : (((state == XDATA3) & uart_data_ready) ? uart_data_out : BootData[15:8]);
        BootData[7:0]   <= (reset) ? 8'h00 : (((state == XDATA4) & uart_data_ready) ? uart_data_out : BootData[7:0]);
    end
    
    always @(posedge clock) begin
        if (reset) begin
            BootAddr <= 18'h00000;
        end
        else if (state == XADDRI) begin
            BootAddr <= BootAddr + 1;
        end
        else begin
            BootAddr[17:16] <= ((state == XOFST1) & uart_data_ready) ? uart_data_out[1:0] : BootAddr[17:16];
            BootAddr[15:8]  <= ((state == XOFST2) & uart_data_ready) ? uart_data_out[7:0] : BootAddr[15:8];
            BootAddr[7:0]   <= ((state == XOFST3) & uart_data_ready) ? uart_data_out[7:0] : BootAddr[7:0];
        end
    end
    
    always @(posedge clock) begin
        rx_count <= (state == IDLE) ? 18'h00000 : ((state == XADDRI) ? rx_count + 1 : rx_count);
    end
    
    always @(posedge clock) begin
        rx_size[17:16] <= (reset) ? 2'b00 : (((state == XSIZE1) & uart_data_ready) ? uart_data_out[1:0] : rx_size[17:16]);
        rx_size[15:8]  <= (reset) ? 8'h00 : (((state == XSIZE2) & uart_data_ready) ? uart_data_out[7:0] : rx_size[15:8]);
        rx_size[7:0]   <= (reset) ? 8'h00 : (((state == XSIZE3) & uart_data_ready) ? uart_data_out[7:0] : rx_size[7:0]);
    end
    
    // UART Driver
    uart_min UART (
        .clock       (clock),
        .reset       (reset),
        .write       (uart_write),
        .data_in     (uart_data_in),
        .read        (uart_read),
        .data_out    (uart_data_out),
        .data_ready  (uart_data_ready),
        .rx_count    (uart_rx_count),
        .RxD         (RxD),
        .TxD         (TxD)
    );

endmodule

