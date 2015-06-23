`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Grant Ayers (ayers@cs.utah.edu)
// 
// Create Date:    09:59:05 05/24/2010 
// Design Name: 
// Module Name:    uart_bootloader 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:
//       Implements the XUM bootloader protocol over a serial port (115200 8N1).
//       The protocol is as follows:
//
//       1. Programmer sends 'XUM' ascii bytes
//       2. Programmer sends a number indicating how many 32-bit data words it
//          has to send, minus 1. (For example, if it has one 32-bit data word,
//          this number will be 0.) The size of this number is 18 bits.
//          This means the minimum transmission size is 1 word (32 bits), and
//          the maximum transmission size is 262144 words (exactly 1MB).
//          This 18-bit number is sent in three bytes, and the six most
//          significant bits of the first byte must be 0.
//       3. The FPGA sends back the third size byte from the programmer, allowing
//          the programmer to determine if the FPGA is listening and conforming
//          to the XUM boot protocol.
//       4. The programmer sends another 18-bit number indicating the starting
//          offset in memory where the data should be placed. Normally this will
//          be 0. This number is also sent in three bytes, and the six most
//          significant bits of the first byte are ignored.
//       5. The programmer sends the data. A copy of each byte that it sends will
//          be sent back to the programmer from the FPGA, allowing the programmer
//          to determine if all of the data was transmitted successfully.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_bootloader(
   input clock,                  // 100Mhz
   input reset,                  // System-wide global reset
   input RxD,                    // UART data from computer
   output TxD,                   // UART data to computer
   output resetCPU,              // Reset CPUs' PCs to start execution at 0x0
   output reg writeMem = 0,      // Write command to instruction memory
   output reg [17:0] addrMem = 0, // address to instruction memory
   output reg [31:0] dataMem = 0 // 32-bit data words of instruction memory
   );
   
   localparam [3:0]  HEAD_1=0, HEAD_2=1, HEAD_3=2, SIZE_1=3, SIZE_2=4, SIZE_3=5, OFST_1=6, OFST_2=7,
                     OFST_3=8, ADDRSET=9, DATA_1=10, DATA_2=11, DATA_3=12, DATA_4=13, ADDRINC=14;
   
   /* UART Signals */
   reg uart_write = 0;
   reg uart_read = 0;
      
   wire [7:0] uart_rx_data;
   wire [7:0] uart_tx_data = uart_rx_data;
   wire uart_rx_data_ready;
   
   reg [17:0] size = 0;       // Number of 32-bit words to expect
   reg [17:0] offset = 0;     // Starting address to store words
   reg [17:0] rx_count = 0;   // Number of 32-bit words received so far
   
   reg [3:0] state = HEAD_1;
   
   // The CPU(s) is continuously reset while memory is being replaced.
   assign resetCPU = ((state!=HEAD_1) && (state!=HEAD_2) && (state!=HEAD_3) && (state!=SIZE_1));
   
   always @(posedge clock) begin
      if (reset) begin
         state <= HEAD_1;
         uart_read <= 0;
         uart_write <= 0;
         writeMem <= 0;
         rx_count <= 0;
      end
      else begin
         uart_read <= uart_rx_data_ready & ((state!=ADDRSET) && (state!=ADDRINC));
         uart_write <= uart_rx_data_ready & ((state==SIZE_3) || (state==DATA_1) || (state==DATA_2) || (state==DATA_3) || (state==DATA_4));
         writeMem <= uart_rx_data_ready & (state == DATA_4);
         rx_count <= (state == HEAD_1) ? 0 : ((state == ADDRINC) ? rx_count + 1 : rx_count);
         case (state)
            HEAD_1:  begin
                        if (uart_rx_data_ready) begin
                           state <= (uart_rx_data == 8'h58) ? HEAD_2 : HEAD_1;   // 'X'
                        end
                        else begin
                           state <= HEAD_1;
                        end
                     end
            HEAD_2:  begin
                        if (uart_rx_data_ready) begin
                           state <= (uart_rx_data == 8'h55) ? HEAD_3 : HEAD_1;   // 'U'
                        end
                        else begin
                           state <= HEAD_2;
                        end
                     end
            HEAD_3:  begin
                        if (uart_rx_data_ready) begin
                           state <= (uart_rx_data == 8'h4D) ? SIZE_1 : HEAD_1;   // 'M'
                        end
                        else begin
                           state <= HEAD_3;
                        end
                     end
            SIZE_1:  begin
                        if (uart_rx_data_ready) begin
                           state <= (uart_rx_data[7:2] == 6'b000000) ? SIZE_2 : HEAD_1;   // 6 leading 0s
                           size[17:16] <= uart_rx_data[1:0];
                        end
                        else begin
                           state <= SIZE_1;
                        end
                     end
            SIZE_2:  begin
                        state <= (uart_rx_data_ready) ? SIZE_3 : SIZE_2;
                        size[15:8] <= (uart_rx_data_ready) ? uart_rx_data : size[15:8];
                     end
            SIZE_3:  begin
                        state <= (uart_rx_data_ready) ? OFST_1 : SIZE_3;
                        size[7:0] <= (uart_rx_data_ready) ? uart_rx_data : size[7:0];
                     end
            OFST_1:  begin
                        state <= (uart_rx_data_ready) ? OFST_2 : OFST_1;
                        offset[17:16] <= (uart_rx_data_ready) ? uart_rx_data[1:0] : offset[17:16];
                     end
            OFST_2:  begin
                        state <= (uart_rx_data_ready) ? OFST_3 : OFST_2;
                        offset[15:8] <= (uart_rx_data_ready) ? uart_rx_data : offset[15:8];
                     end
            OFST_3:  begin
                        state <= (uart_rx_data_ready) ? ADDRSET : OFST_3;
                        offset[7:0] <= (uart_rx_data_ready) ? uart_rx_data : offset[7:0];
                     end
            ADDRSET: begin
                        state <= DATA_1;
                        addrMem <= offset;
                     end
            DATA_1:  begin
                        state <= (uart_rx_data_ready) ? DATA_2 : DATA_1;
                        dataMem[31:24] <= (uart_rx_data_ready) ? uart_rx_data : dataMem[31:24];
                     end
            DATA_2:  begin
                        state <= (uart_rx_data_ready) ? DATA_3 : DATA_2;
                        dataMem[23:16] <= (uart_rx_data_ready) ? uart_rx_data : dataMem[23:16];
                     end
            DATA_3:  begin
                        state <= (uart_rx_data_ready) ? DATA_4 : DATA_3;
                        dataMem[15:8] <= (uart_rx_data_ready) ? uart_rx_data : dataMem[15:8];
                     end
            DATA_4:  begin
                        state <= (uart_rx_data_ready) ? ADDRINC : DATA_4;
                        dataMem[7:0] <= (uart_rx_data_ready) ? uart_rx_data : dataMem[7:0];
                     end
            ADDRINC:   begin
                        addrMem <= addrMem + 1;
                        state <= (rx_count == size) ? HEAD_1 : DATA_1;
                     end
            default: state <= HEAD_1;
         endcase
      end
   end


   uart_min uart (
      .clock      (clock), 
      .reset      (reset), 
      .write      (uart_write), 
      .data_in    (uart_tx_data), 
      .read       (uart_read), 
      .data_out   (uart_rx_data), 
      .data_ready (uart_rx_data_ready), 
      .RxD        (RxD), 
      .TxD        (TxD)
   );
   
endmodule

