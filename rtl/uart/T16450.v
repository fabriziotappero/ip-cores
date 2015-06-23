//
// 16450 compatible UART with synchronous bus interface
// rclk/baudout is clk enable instead of actual clock
//
// Copyright (c) 2005 Guy Hutchison (ghutchis@opencores.org)
// Based on VHDL 16450 UART by Daniel Wallner
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module T16450 
  (
   input reset_n,
   input clk,
   input rclk,
   input cs_n,
   input rd_n,
   input wr_n,
   input [2:0] addr,    
   input [7:0] wr_data,
   output reg [7:0] rd_data,    
   input sin,
   input cts_n,
   input dsr_n,
   input ri_n,
   input dcd_n, 
   output reg sout,
   output reg rts_n,
   output reg dtr_n,
   output reg out1_n,
   output reg out2_n,
   output reg baudout,
   output reg intr
   );

  reg [7:0] RBR;        // Reciever Buffer Register
  reg [7:0] THR;        // Transmitter Holding Register
  reg [7:0] IER;        // Interrupt Enable Register
  reg [7:0] IIR;        // Interrupt Ident. Register
  reg [7:0] LCR;        // Line Control Register
  reg [7:0] MCR;        // MODEM Control Register
  reg [7:0] LSR;        // Line Status Register
  reg [7:0] MSR;        // MODEM Status Register
  reg [7:0] SCR;        // Scratch Register
  reg [7:0] DLL;        // Divisor Latch (LS)
  reg [7:0] DLM;        // Divisor Latch (MS)

  reg [7:0] DM0;
  reg [7:0] DM1;

  reg [3:0] MSR_In;

  reg [3:0] Bit_Phase;
  reg [3:0] Brk_Cnt;
  reg       RX_Filtered;
  reg [7:0] RX_ShiftReg;
  reg [3:0] RX_Bit_Cnt;
  reg       RX_Parity;
  reg       RXD;

  reg       TX_Tick;
  reg [7:0] TX_ShiftReg;
  reg [3:0] TX_Bit_Cnt;
  reg       TX_Parity;
  reg       TX_Next_Is_Stop;
  reg       TX_Stop_Bit;
  reg       TXD;

  always @*
    begin
      dtr_n = MCR[4] || ~ MCR[0];
      rts_n = MCR[4] || ~ MCR[1];
      out1_n = MCR[4] || ~ MCR[2];
      out2_n = MCR[4] || ~ MCR[3];
      sout = MCR[4] || (TXD && ~ LCR[6]);
      if (!MCR[4]) RXD = sin;
      else RXD = (TXD && !LCR[6]);

      intr = ~IIR[0];

      if (LCR[7])
        begin
          DM0 = DLL;
          DM1 = DLM;
        end
      else
        begin
          DM0 = RBR;
          DM1 = IER;
        end

      case (addr)
        3'h0 : rd_data = DM0;
        3'h1 : rd_data = DM1;
        3'h2 : rd_data = IIR;
        3'h3 : rd_data = LCR;
        3'h4 : rd_data = MCR;
        3'h5 : rd_data = LSR;
        3'h6 : rd_data = MSR;
        default : rd_data = SCR;
      endcase
    end

  always @ (posedge clk)
    begin
      if (!reset_n) 
        begin
          THR <= #1 8'b00000000;
          IER <= #1 8'b00000000;
          LCR <= #1 8'b00000000;
          MCR <= #1 8'b00000000;
          MSR[3:0] <= #1 4'b0000;
          SCR <= #1 8'b00000000;
          DLL <= #1 8'b00000000;
          DLM <= #1 8'b00000000;
        end 
      else 
        begin
          if (!wr_n && !cs_n ) 
            begin
              case (addr)
                3'b000  :
                  begin
                    if (LCR[7]) 
                      DLL <= #1 wr_data;
                    else 
                      THR <= #1 wr_data;
                  end 
                3'b001  :
                  begin
                    if (LCR[7]) 
                      DLM <= #1 wr_data;
                    else
                      IER[3:0] <= #1 wr_data[3:0];
                  end
                3'b011  : LCR <= #1 wr_data;
                3'b100  : MCR <= #1 wr_data;
                3'b111  : SCR <= #1 wr_data;
                default : ;
              endcase
            end
          if (!rd_n && !cs_n && (addr == 3'b110)) 
            MSR[3:0] <= #1 4'b0000;
          if (MSR[4] != MSR_In[0])
            MSR[0] <= #1 1'b1;
          if (MSR[5] != MSR_In[1])
            MSR[1] <= #1 1'b1;
          if (!MSR[6] && MSR_In[2])
            MSR[2] <= #1 1'b1;
          if (MSR[7] != MSR_In[3])
            MSR[3] <= #1 1'b1;
        end
    end 
  always @ (posedge clk)
    begin
      if (!MCR[4]) 
        begin
          MSR[4] <= #1 MSR_In[0];
          MSR[5] <= #1 MSR_In[1];
          MSR[6] <= #1 MSR_In[2];
          MSR[7] <= #1 MSR_In[3];
        end 
      else 
        begin
          MSR[4] <= #1 MCR[1];
          MSR[5] <= #1 MCR[0];
          MSR[6] <= #1 MCR[2];
          MSR[7] <= #1 MCR[3];
        end
      MSR_In[0] <= #1 cts_n;
      MSR_In[1] <= #1 dsr_n;
      MSR_In[2] <= #1 ri_n;
      MSR_In[3] <= #1 dcd_n;
    end

  always @*
    begin
      IIR[7:3] = #1 5'b00000;
      if (IER[2] && (LSR[4:1] != 4'b0000))
        IIR[2:0] = #1 3'b110;
      else if (IER[0] && LSR[0])
        IIR[2:0] = #1 3'b100;
      else if (IER[1] && LSR[5])
        IIR[2:0] = #1 3'b010;
      else if (IER[3] && ((!MCR[4] && (MSR[3:0] != 0)) || (MCR[4] && (MCR[3:0] != 0))))
        IIR[2:0] = #1 3'b000;
      else
        IIR[2:0] = #1 3'b001;
    end

  // Baud x 16 clock generator
  always @ (posedge clk)
    begin : clk_gen
      reg [15:0] Baud_Cnt;
      if (!reset_n)
        begin
          Baud_Cnt = 16'b0000000000000000;
          baudout <= #1 1'b0;
        end 
      else 
        begin
          if ((Baud_Cnt[15:1] == 15'h0) || 
              (!wr_n && !cs_n && (addr[2:1] == 2'b00) && LCR[7]) ) 
            begin
              Baud_Cnt[15:8] = DLM;
              Baud_Cnt[7:0] = DLL;
              baudout <= #1 1'b1;
            end 
          else 
            begin
              Baud_Cnt = Baud_Cnt - 1;
              baudout <= #1 1'b0;
            end
        end
    end

  // Input filter
  always @ (posedge clk)
    begin : input_filter
      reg [1:0] Samples;
      if (!reset_n)
        begin
          Samples = 2'b11;
          RX_Filtered <= #1 1'b1;
        end 
      else 
        begin
          if (rclk) 
            begin
              Samples[1] = Samples[0];
              Samples[0] = RXD;
            end
          if (Samples == 2'b00) 
            begin
              RX_Filtered <= #1 1'b0;
            end
          if (Samples == 2'b11) 
            begin
              RX_Filtered <= #1 1'b1;
            end
        end
    end

  // Receive state machine
  always @ (posedge clk)
    begin
      if (!reset_n) 
        begin
          RBR <= #1 8'b00000000;
          LSR[4:0] <= #1 5'b00000;
          Bit_Phase <= #1 4'b0000;
          Brk_Cnt <= #1 4'b0000;
          RX_ShiftReg[7:0] <= #1 8'b00000000;
          RX_Bit_Cnt <= #1 0;
          RX_Parity <= #1 1'b0;
        end 
      else 
        begin
          if (addr == 3'b000 && !LCR[7] && !rd_n && !cs_n ) 
            begin
              LSR[0] <= #1 1'b0;   // DR
            end
          if (addr == 3'b101 && !rd_n && !cs_n ) 
            begin
              LSR[4] <= #1 1'b0;   // BI
              LSR[3] <= #1 1'b0;   // FE
              LSR[2] <= #1 1'b0;   // PE
              LSR[1] <= #1 1'b0;   // OE
            end
          if (rclk) 
            begin
              if ((RX_Bit_Cnt == 0) && (RX_Filtered || (Bit_Phase == 4'b0111)))
                begin
                  Bit_Phase <= #1 4'b0000;
                end 
              else 
                begin
                  Bit_Phase <= #1 Bit_Phase + 1;
                end
              if (Bit_Phase == 4'b1111 ) 
                begin
                  if (RX_Filtered)
                    begin
                      Brk_Cnt <= #1 4'b0000;
                    end 
                  else 
                    begin
                      Brk_Cnt <= #1 Brk_Cnt + 1;
                    end
                  if (Brk_Cnt == 4'b1100) 
                    begin
                      LSR[4] <= #1 1'b1;     // BI
                    end
                end
              if (RX_Bit_Cnt == 0) 
                begin
                  if (Bit_Phase == 4'b0111) 
                    begin
                      RX_Bit_Cnt <= #1 RX_Bit_Cnt + 1;
                      RX_Parity <= #1 ! LCR[4];    // EPS
                    end
                end 
              else if (Bit_Phase == 4'b1111) 
                begin
                  RX_Bit_Cnt <= #1 RX_Bit_Cnt + 1;
                  if (RX_Bit_Cnt == 10 ) 
                    begin // Parity stop bit
                      RX_Bit_Cnt <= #1 0;
                      LSR[0] <= #1 1'b1; // UART Receive complete
                      LSR[3] <= #1 ~RX_Filtered; // Framing error
                    end 
                  else if ((RX_Bit_Cnt == 9 && LCR[1:0] == 2'b11) ||
                           (RX_Bit_Cnt == 8 && LCR[1:0] == 2'b10) ||
                           (RX_Bit_Cnt == 7 && LCR[1:0] == 2'b01) ||
                           (RX_Bit_Cnt == 6 && LCR[1:0] == 2'b00) ) 
                    begin // Stop bit/Parity
                      RX_Bit_Cnt <= #1 0;
                      if (LCR[3]) 
                        begin   // PEN
                          RX_Bit_Cnt <= #1 10;
                          if (LCR[5]) 
                            begin       // Stick parity
                              if (RX_Filtered == LCR[4]) 
                                begin
                                  LSR[2] <= #1 1'b1;
                                end
                            end 
                          else
                            begin
                              if (RX_Filtered != RX_Parity) 
                                begin
                                  LSR[2] <= #1 1'b1;
                                end
                            end
                        end 
                      else 
                        begin
                          LSR[0] <= #1 1'b1; // UART Receive complete
                          LSR[3] <= #1 ~RX_Filtered; // Framing error
                        end
                      RBR <= #1 RX_ShiftReg[7:0];
                      LSR[1] <= #1 LSR[0];
                      if (addr == 3'b101 && !rd_n && !cs_n ) 
                        begin
                          LSR[1] <= #1 1'b0;
                        end
                    end 
                  else 
                    begin
                      RX_ShiftReg[6:0] <= #1 RX_ShiftReg[7:1];
                      RX_ShiftReg[7] <= #1 RX_Filtered;
                      if (LCR[1:0] == 2'b10) 
                        begin
                          RX_ShiftReg[7] <= #1 1'b0;
                          RX_ShiftReg[6] <= #1 RX_Filtered;
                        end
                      if (LCR[1:0] == 2'b01) 
                        begin
                          RX_ShiftReg[7] <= #1 1'b0;
                          RX_ShiftReg[6] <= #1 1'b0;
                          RX_ShiftReg[5] <= #1 RX_Filtered;
                        end
                      if (LCR[1:0] == 2'b00) 
                        begin
                          RX_ShiftReg[7] <= #1 1'b0;
                          RX_ShiftReg[6] <= #1 1'b0;
                          RX_ShiftReg[5] <= #1 1'b0;
                          RX_ShiftReg[4] <= #1 RX_Filtered;
                        end
                      RX_Parity <= #1 RX_Filtered ^ RX_Parity;
                    end
                end
            end
        end
    end

  // Transmit bit tick
  always @ (posedge clk)
    begin : bit_tick
      reg [4:0] TX_Cnt;
      if (!reset_n) 
        begin
          TX_Cnt = 5'b00000;
          TX_Tick <= #1 1'b0;
        end 
      else 
        begin
          TX_Tick <= #1 1'b0;
          if (rclk) 
            begin
              TX_Cnt = TX_Cnt + 1;
              if (LCR[2] && TX_Stop_Bit) 
                begin
                  if (LCR[1:0] == 2'b00) 
                    begin
                      if (TX_Cnt == 5'b10111) 
                        begin
                          TX_Tick <= #1 1'b1;
                          TX_Cnt[3:0] = 4'b0000;
                        end
                    end 
                  else 
                    begin
                      if (TX_Cnt == 5'b11111) 
                        begin
                          TX_Tick <= #1 1'b1;
                          TX_Cnt[3:0] = 4'b0000;
                        end
                    end
                end 
              else 
                begin
                  TX_Cnt[4] = 1'b1;
                  if (TX_Cnt[3:0] == 4'b1111) 
                    begin
                      TX_Tick <= #1 1'b1;
                    end
                end
            end
        end
    end

  // Transmit state machine
  always @ (posedge clk)
    begin
      if (!reset_n) 
        begin
          LSR[7:5] <= #1 3'b011;
          TX_Bit_Cnt <= #1 0;
          TX_ShiftReg <= #1 0;
          TXD <= #1 1'b1;
          TX_Parity <= #1 1'b0;
          TX_Next_Is_Stop <= #1 1'b0;
          TX_Stop_Bit <= #1 1'b0;
        end 
      else 
        begin
          if (TX_Tick == 1'b1) 
            begin
              TX_Next_Is_Stop <= #1 1'b0;
              TX_Stop_Bit <= #1 TX_Next_Is_Stop;
              case (TX_Bit_Cnt)
                0  :
                  begin
                    if (!LSR[5]) 
                      begin     // THRE
                        TX_Bit_Cnt <= #1 1;
                      end
                    TXD <= #1 1'b1;
                  end
                1  : // Start bit
                  begin
                    TX_ShiftReg[7:0] <= #1 THR;
                    LSR[5] <= #1 1'b1;     // THRE
                    TXD <= #1 1'b0;
                    TX_Parity <= #1 ~LCR[4];       // EPS
                    TX_Bit_Cnt <= #1 TX_Bit_Cnt + 1;
                  end
                10  : // Parity bit
                  begin
                    TXD <= #1 TX_Parity;
                    if (LCR[5] == 1'b1 ) 
                      begin  // Stick parity
                        TXD <= #1 ~LCR[4];
                      end
                    TX_Bit_Cnt <= #1 0;
                    TX_Next_Is_Stop <= #1 1'b1;
                  end
                default :
                  begin
                    TX_Bit_Cnt <= #1 TX_Bit_Cnt + 1;
                    if ((TX_Bit_Cnt == 9 && LCR[1:0] == 2'b11) ||
                        (TX_Bit_Cnt == 8 && LCR[1:0] == 2'b10) ||
                        (TX_Bit_Cnt == 7 && LCR[1:0] == 2'b01) ||
                        (TX_Bit_Cnt == 6 && LCR[1:0] == 2'b00) ) 
                      begin
                        TX_Bit_Cnt <= #1 0;
                        if (LCR[3] == 1'b1 ) 
                          begin // PEN
                            TX_Bit_Cnt <= #1 10;
                          end 
                        else 
                          begin
                            TX_Next_Is_Stop <= #1 1'b1;
                          end
                        LSR[6] <= #1 1'b1; // TEMT
                      end
                    TXD <= #1 TX_ShiftReg[0];
                    TX_ShiftReg[6:0] <= #1 TX_ShiftReg[7:1];
                    TX_Parity <= #1 TX_ShiftReg[0] ^ TX_Parity;
                  end
              endcase
            end
          if (!wr_n && !cs_n && addr == 3'b000 && !LCR[7] ) 
            begin
              LSR[5] <= #1 1'b0;   // THRE
              LSR[6] <= #1 1'b0;   // TEMT
            end
        end
    end

endmodule

