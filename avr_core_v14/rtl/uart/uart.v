//**********************************************************************************************
// UART Peripheral for the AVR Core
// Version 2.1 "Original" (Mega103) version
// Modified 08.01.2007
// Designed by Ruslan Lepetenok
// UDRE bug found
// Transmitter bug (for 9 bit transmission) was found 
// Bug in UART_RcDel_St state machine was fixed
// Bug in UART_RcDel_St state machine was fixed(2) (!!!simulation only!!!) 
// Receiver start detector now searches for the falling edge of RXD (like in the original UART)
// Modified 27.05.12(Verilog version)
// `include" was replaced by `include " to avoid error in VCS
// localparam replaced by parameter (for UBRR0L_Address, UCSR0B_Address, UCSR0A_Address, 
// UDR0_Address) 10.06.12
//**********************************************************************************************

`timescale 1 ns / 1 ns
// TBD
//pragma translate_off
// `include "timescale.vh"
//pragma translate_on

// Alias replacement
`define RXC  USR[7] 
`define TXC  USR[6] 
`define UDRE USR[5] 
`define FE   USR[4] 
`define DOR  USR[3] // OR in Atmel documents

`define RXCIE UCR[7] 
`define TXCIE UCR[6] 
`define UDRIE UCR[5] 
`define RXEN  UCR[4] 
`define TXEN  UCR[3] 
`define CHR9  UCR[2] 
`define RXB8  UCR[1] 
`define TXB8  UCR[0] 


module uart (
             ireset, 
             cp2, 
	     adr, 
	     dbus_in, 
	     dbus_out, 
	     iore, 
	     iowe, 
	     out_en, 
	     rxd, 
	     rx_en, 
	     txd, 
	     tx_en, 
	     txcirq, 
	     txc_irqack, 
	     udreirq, 
	     rxcirq
	     );

   // included from package avr_adr_pack

parameter UBRR0L_Address =  6'h09; // USART0 Baud Rate Register Low
parameter UCSR0B_Address =  6'h0A; // USART0 Control and Status Register B
parameter UCSR0A_Address =  6'h0B; // USART0 Control and Status Register A
parameter UDR0_Address   =  6'h0C; // USART0 I/O Data Register  
   
   input       ireset; 
   input       cp2; 
   input[5:0]  adr; 
   input[7:0]  dbus_in; 
   output[7:0] dbus_out; 
   wire[7:0]   dbus_out;
   input       iore; 
   input       iowe; 
   output      out_en; 
   wire        out_en;
   input       rxd; 
   output      rx_en; 
   wire        rx_en;
   output      txd; 
   reg         txd;
   output      tx_en; 
   wire        tx_en;
   output      txcirq; 
   wire        txcirq;
   input       txc_irqack; 
   output      udreirq; 
   wire        udreirq;
   output      rxcirq; 
   wire        rxcirq;

   reg[7:0] UDR_Tx; 
   reg[7:0] UDR_Rx; 
   reg[7:0] UBRR; 
   // USR Bits
   reg[7:0] USR; 
   wire USR_Wr_En; 
   // UCR Bits
   reg[7:0] UCR; 
   wire UCR_Wr_En; 
   reg CHR9_Latched; 
   reg TXB8_Latched; 
   // Common internal signals
   reg UART_Clk_En; 
   // Internal signals for transmitter
   reg[7:0] SR_Tx; // UART transmit shift register
   wire[7:0] SR_Tx_In; 
   wire Tx_In; 
   // Transmitter state machine
   reg nUART_Tr_St0; 
   reg UART_Tr_St1; 
   reg UART_Tr_St2; 
   reg UART_Tr_St3; 
   reg UART_Tr_St4; 
   reg UART_Tr_St5; 
   reg UART_Tr_St6; 
   reg UART_Tr_St7; 
   reg UART_Tr_St8; 
   reg UART_Tr_St9; 
   reg UART_Tr_St10; 
   reg UART_Tr_St11; 
   reg Flag_A; 
   reg Flag_B; 
   wire UDR_Wr_En; 
   wire UDR_Rd; 
   wire USR_Rd; 
   wire UCR_Rd; 
   wire UBRR_Rd; 
   // Frequence divider signals
   reg[3:0] Div16_Cnt; 
   wire[3:0] Div16_In; // Counter Input
   wire Div16_Eq; // Combinatorial output of the comparator
   // Baud generator signals
   wire UBRR_Wr_En; 
   reg[7:0] Baud_Gen_Cnt; // Counter
   wire[7:0] Baud_Gen_In; // Counter Input
   wire Baud_Gen_Eq; // Combinatorial output of the comparator
   reg Baud_Gen_Out; 
   // Receiver signals
   reg nUART_RcDel_St0; 
   reg UART_RcDel_St1; 
   reg UART_RcDel_St2; 
   reg UART_RcDel_St3; 
   reg UART_RcDel_St4; 
   reg UART_RcDel_St5; 
   reg UART_RcDel_St6; 
   reg UART_RcDel_St7; 
   reg UART_RcDel_St8; 
   reg UART_RcDel_St9; 
   reg UART_RcDel_St10; 
   reg UART_RcDel_St11; 
   reg UART_RcDel_St12; 
   reg UART_RcDel_St13; 
   reg UART_RcDel_St14; 
   reg UART_RcDel_St15; 
   reg UART_RcDel_St16; 
   reg nUART_Rc_St0; 
   reg UART_Rc_St1; 
   reg UART_Rc_St2; 
   reg UART_Rc_St3; 
   reg UART_Rc_St4; 
   reg UART_Rc_St5; 
   reg UART_Rc_St6; 
   reg UART_Rc_St7; 
   reg UART_Rc_St8; 
   reg UART_Rc_St9; 
   reg UART_Rc_St10; 
   reg RXD_ResyncA; 
   reg RXD_ResyncB; 
   wire Detector_Out; 
   reg Detector_A; 
   reg Detector_B; 
   reg[9:0] UART_Rc_SR; 
   wire UART_Rc_SR7_In; 
   reg UART_Rc_Delay; 
   wire RcStartDet; 

   // Baud generator (First divider)
   always @(posedge cp2 or negedge ireset)
   begin : Baud_Generator
      if (!ireset)
      begin
         // Reset
         Baud_Gen_Cnt <= {8{1'b0}} ; 
         Baud_Gen_Out <= 1'b0 ; 
      end
      else
      begin
         // Clock
         Baud_Gen_Cnt <= Baud_Gen_In ; 
         Baud_Gen_Out <= Baud_Gen_Eq ; 
      end 
   end 
   assign Baud_Gen_Eq = (UBRR == Baud_Gen_Cnt) ? 1'b1 : 1'b0 ;
   assign Baud_Gen_In = (Baud_Gen_Eq == 1'b0) ? Baud_Gen_Cnt + 1 : {8{1'b0}} ;

   //Divide by 16 (Second divider)
   always @(posedge cp2 or negedge ireset)
   begin : Divide_By_16
      if (!ireset)
      begin
         // Reset
         Div16_Cnt <= {4{1'b0}} ; 
      end
      //  UART_Clk_En <= '0'; 
      else
      begin
         // Clock
         if (Baud_Gen_Out == 1'b1)
         begin
            // Clock enable   
            Div16_Cnt <= Div16_In ; 
         end
         //     UART_Clk_En <= Div16_Eq; 
      end 
   end 
   assign Div16_Eq = (Div16_Cnt == 4'b1111) ? 1'b1 : 1'b0 ;
   assign Div16_In = (Div16_Eq == 1'b0) ? Div16_Cnt + 1 : {4{1'b0}} ;

   always @(posedge cp2 or negedge ireset)
   begin : Global_Clock_Enable
      if (!ireset)
      begin
         // Reset
         UART_Clk_En <= 1'b0 ; 
      end
      else
      begin
         // Clock
         UART_Clk_En <= Div16_Eq & Baud_Gen_Out ; 
      end 
   end 
   // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   // UBRR 
   assign UBRR_Wr_En = (/*fn_to_integer(*/adr/*)*/ == UBRR0L_Address & iowe == 1'b1) ? 1'b1 : 1'b0 ;

   always @(posedge cp2 or negedge ireset)
   begin : UBRR_Load
      if (!ireset)
      begin
         // Reset
         UBRR <= {8{1'b0}} ; 
      end
      else
      begin
         // Clock
         if (UBRR_Wr_En == 1'b1)
         begin
            // Clock enable
            UBRR <= dbus_in ; 
         end 
      end 
   end 
   assign UDR_Rd = (/*fn_to_integer(*/adr/*)*/ == UDR0_Address & iore == 1'b1) ? 1'b1 : 1'b0 ;
   // UDR	for transmitter
   assign UDR_Wr_En = (/*fn_to_integer(*/adr/*)*/ == UDR0_Address & iowe == 1'b1 & `TXEN == 1'b1) ? 1'b1 : 1'b0 ;

   always @(posedge cp2 or negedge ireset)
   begin : UDR_Tx_Load
      if (!ireset)
      begin
         // Reset
         UDR_Tx <= {8{1'b0}} ; 
         CHR9_Latched <= 1'b0 ; 
         TXB8_Latched <= 1'b0 ; 
      end
      else
      begin
         // Clock
         if (UDR_Wr_En & (Flag_A | nUART_Tr_St0) == 1'b1)
         begin
            // Clock enable
            UDR_Tx <= dbus_in ; 
            CHR9_Latched <= `CHR9 ; 
            TXB8_Latched <= `TXB8 ; 
         end 
      end 
   end 

   // Load flags
   always @(posedge cp2 or negedge ireset)
   begin : Load_Flags
      if (!ireset)
      begin
         // Reset
         Flag_A <= 1'b0 ; 
         Flag_B <= 1'b0 ; 
      end
      else
      begin
         // Clock
         Flag_A <= (~Flag_A & UDR_Wr_En & ~nUART_Tr_St0) | (Flag_A & ~(UART_Tr_St1 & UART_Clk_En)) ; 
         Flag_B <= (~Flag_B & (UDR_Wr_En & (Flag_A | (nUART_Tr_St0 & ~(UART_Tr_St11 & UART_Clk_En))))) | (Flag_B & ~(UART_Clk_En & UART_Tr_St11)) ; 
      end 
   end 

   assign SR_Tx_In[6:0] = (dbus_in[6:0] & {7{(UDR_Wr_En & ((~Flag_A & ~nUART_Tr_St0) | (~Flag_B & UART_Tr_St11 & UART_Clk_En)))}}) | 
                          (UDR_Tx[6:0]  & {7{(UART_Tr_St11 & Flag_B)}}) | 
			  (SR_Tx[7:1]   & {7{(nUART_Tr_St0 & ~UART_Tr_St11)}}) ;
   
   
   // Direct load from data bus	
   // Load from UDR(TX)
   // Shift first
   assign SR_Tx_In[7] = (dbus_in[7] & UDR_Wr_En & ((~Flag_A & ~nUART_Tr_St0) | (~Flag_B & UART_Tr_St11 & UART_Clk_En))) | (UDR_Tx[7] & UART_Tr_St11 & Flag_B) | (TXB8_Latched & (UART_Tr_St2 & CHR9_Latched)) | (1'b1 & ~((~Flag_A & ~nUART_Tr_St0 & UDR_Wr_En) | UART_Tr_St11 | (UART_Tr_St2 & CHR9_Latched))) ;
   // Start bit
   // Shift
   
   // assign Tx_In = (1'b0 & UART_Tr_St1) | (SR_Tx[0] & (nUART_Tr_St0 & ~UART_Tr_St1)) | (1'b1 & ~nUART_Tr_St0) ;

   assign Tx_In = (SR_Tx[0] & (nUART_Tr_St0 & ~UART_Tr_St1)) | ~nUART_Tr_St0 ;

   // Transmitter shift register
   always @(posedge cp2 or negedge ireset)
   begin : SR_Tx_Load_Sift
      if (!ireset)
      begin
         // Reset
         SR_Tx <= {8{1'b0}} ; 
      end
      else
      begin
         // Clock
         if (((~Flag_A & ~nUART_Tr_St0 & UDR_Wr_En) | (UART_Tr_St11 & UART_Clk_En) | (nUART_Tr_St0 & UART_Clk_En & ~UART_Tr_St1)) == 1'b1)
         begin
            // Clock enable
            SR_Tx <= SR_Tx_In ; 
         end 
      end 
   end 

   // Transmitter output register
   always @(posedge cp2 or negedge ireset)
   begin : Tx_Out
      if (!ireset)
      begin
         // Reset
         txd <= 1'b1 ; 
      end
      else
      begin
         // Clock
         if (UART_Clk_En & (nUART_Tr_St0 | Flag_A) == 1'b1)
         begin
            // Clock enable
            txd <= Tx_In ; 
         end 
      end 
   end 

   always @(posedge cp2 or negedge ireset)
   begin : Transmit_State_Machine
      if (!ireset)
      begin
         // Reset
         nUART_Tr_St0 <= 1'b0 ; 
         UART_Tr_St1 <= 1'b0 ; 
         UART_Tr_St2 <= 1'b0 ; 
         UART_Tr_St3 <= 1'b0 ; 
         UART_Tr_St4 <= 1'b0 ; 
         UART_Tr_St5 <= 1'b0 ; 
         UART_Tr_St6 <= 1'b0 ; 
         UART_Tr_St7 <= 1'b0 ; 
         UART_Tr_St8 <= 1'b0 ; 
         UART_Tr_St9 <= 1'b0 ; 
         UART_Tr_St10 <= 1'b0 ; 
         UART_Tr_St11 <= 1'b0 ; 
      end
      else
      begin
         // Clock
         if (UART_Clk_En == 1'b1)
         begin
            // Clock enable
            nUART_Tr_St0 <= (~nUART_Tr_St0 & Flag_A) | (nUART_Tr_St0 & ~(UART_Tr_St11 & ~Flag_B & ~UDR_Wr_En)) ; 
            UART_Tr_St1 <= ~UART_Tr_St1 & ((~nUART_Tr_St0 & Flag_A) | (UART_Tr_St11 & (Flag_B | UDR_Wr_En))) ; // Start bit
            UART_Tr_St2 <= UART_Tr_St1 ; // Bit 0
            UART_Tr_St3 <= UART_Tr_St2 ; // Bit 1
            UART_Tr_St4 <= UART_Tr_St3 ; // Bit 2
            UART_Tr_St5 <= UART_Tr_St4 ; // Bit 3
            UART_Tr_St6 <= UART_Tr_St5 ; // Bit 4
            UART_Tr_St7 <= UART_Tr_St6 ; // Bit 5
            UART_Tr_St8 <= UART_Tr_St7 ; // Bit 6
            UART_Tr_St9 <= UART_Tr_St8 ; // Bit 7
            UART_Tr_St10 <= UART_Tr_St9 & CHR9_Latched ; // Bit 8 (if enabled)
            UART_Tr_St11 <= (UART_Tr_St9 & ~CHR9_Latched) | UART_Tr_St10 ; // Stop bit
         end 
      end 
   end 

   // USR bits
   always @(posedge cp2 or negedge ireset)
   begin : USR_UDRE
      if (!ireset)
      begin
         // Reset
         `UDRE <= 1'b1 ; // !!
      end
      else
      begin
         // Clock
         `UDRE <= (`UDRE & ~(UDR_Wr_En & (Flag_A | (nUART_Tr_St0 & ~(UART_Tr_St11 & UART_Clk_En))))) | (~`UDRE & (UART_Tr_St11 & Flag_B & UART_Clk_En)) ; 
      end 
   end 
   assign USR_Wr_En = (/*fn_to_integer(*/adr/*)*/ == UCSR0A_Address & iowe == 1'b1) ? 1'b1 : 1'b0 ;

   always @(posedge cp2 or negedge ireset)
   begin : USR_TXC
      if (!ireset)
      begin
         // Reset
         `TXC <= 1'b0 ; 
      end
      else
      begin
         // Clock
         // TXC set	??? 
         `TXC <= (~`TXC & (UART_Tr_St11 & ~Flag_B & UART_Clk_En & ~UDR_Wr_En)) | (`TXC & ~(UDR_Wr_En | txc_irqack | (USR_Wr_En & dbus_in[6]))) ; // TXC reset  
      end 
   end 
   // Transmitter IRQ
   assign txcirq = `TXC & `TXCIE ;
   assign udreirq = `UDRE & `UDRIE ;
   // Output enable signal(for external multiplexer control)
   assign out_en = ((/*fn_to_integer(*/adr/*)*/ == UDR0_Address | /*fn_to_integer(*/adr/*)*/ == UBRR0L_Address | /*fn_to_integer(*/adr/*)*/ == UCSR0A_Address | /*fn_to_integer(*/adr/*)*/ == UCSR0B_Address) & iore == 1'b1) ? 1'b1 : 1'b0 ;
   assign UCR_Wr_En = (/*fn_to_integer(*/adr/*)*/ == UCSR0B_Address & iowe == 1'b1) ? 1'b1 : 1'b0 ;

   always @(posedge cp2 or negedge ireset)
   begin : UCR_Bits
      if (!ireset)
      begin
         // Reset
         UCR[7:2] <= {6{1'b0}} ; 
         UCR[0] <= 1'b0 ; 
      end
      else
      begin
         // Clock
         if (UCR_Wr_En == 1'b1)
         begin
            // Clock enable
            UCR[7:2] <= dbus_in[7:2] ; 
            UCR[0] <= dbus_in[0] ; 
         end 
      end 
   end 

   //*********************************** Receiver **************************************
   always @(posedge cp2 or negedge ireset)
   begin : Receiver
      if (!ireset)
      begin
         // Reset
         nUART_RcDel_St0 <= 1'b0 ; 
         UART_RcDel_St1 <= 1'b0 ; 
         UART_RcDel_St2 <= 1'b0 ; 
         UART_RcDel_St3 <= 1'b0 ; 
         UART_RcDel_St4 <= 1'b0 ; 
         UART_RcDel_St5 <= 1'b0 ; 
         UART_RcDel_St6 <= 1'b0 ; 
         UART_RcDel_St7 <= 1'b0 ; 
         UART_RcDel_St8 <= 1'b0 ; 
         UART_RcDel_St9 <= 1'b0 ; 
         UART_RcDel_St10 <= 1'b0 ; 
         UART_RcDel_St11 <= 1'b0 ; 
         UART_RcDel_St12 <= 1'b0 ; 
         UART_RcDel_St13 <= 1'b0 ; 
         UART_RcDel_St14 <= 1'b0 ; 
         UART_RcDel_St15 <= 1'b0 ; 
         UART_RcDel_St16 <= 1'b0 ; 
      end
      else
      begin
         // Clock
         if (Baud_Gen_Out == 1'b1)
         begin
            // Clock enable
            // Was :(nUART_RcDel_St0 and not((UART_RcDel_St10 and(Detector_Out and not nUART_Rc_St0))or -- Noise instead of start bit
            // Noise instead of start bit
            // Stop bit was detected
            nUART_RcDel_St0 <= (~nUART_RcDel_St0 & RcStartDet) | (nUART_RcDel_St0 & ~((UART_RcDel_St9 & (Detector_Out & ~nUART_Rc_St0)) | (UART_RcDel_St9 & UART_Rc_St10) | (UART_RcDel_St16 & ~nUART_Rc_St0))) ; // ?bug? 
            UART_RcDel_St1 <= ~UART_RcDel_St1 & ((~nUART_RcDel_St0 & RcStartDet) | (UART_RcDel_St16 & nUART_Rc_St0)) ; 
            UART_RcDel_St2 <= UART_RcDel_St1 ; 
            UART_RcDel_St3 <= UART_RcDel_St2 ; 
            UART_RcDel_St4 <= UART_RcDel_St3 ; 
            UART_RcDel_St5 <= UART_RcDel_St4 ; 
            UART_RcDel_St6 <= UART_RcDel_St5 ; 
            UART_RcDel_St7 <= UART_RcDel_St6 ; 
            UART_RcDel_St8 <= UART_RcDel_St7 ; 
            UART_RcDel_St9 <= UART_RcDel_St8 ; 
            UART_RcDel_St10 <= ~UART_RcDel_St10 & UART_RcDel_St9 & ((~Detector_Out & ~nUART_Rc_St0) | (nUART_Rc_St0 & ~UART_Rc_St10)) ; 
            UART_RcDel_St11 <= UART_RcDel_St10 ; 
            UART_RcDel_St12 <= UART_RcDel_St11 ; 
            UART_RcDel_St13 <= UART_RcDel_St12 ; 
            UART_RcDel_St14 <= UART_RcDel_St13 ; 
            UART_RcDel_St15 <= UART_RcDel_St14 ; 
            UART_RcDel_St16 <= UART_RcDel_St15 ; 
         end 
      end 
   end 
   assign UART_Rc_SR7_In = (`CHR9 == 1'b1) ? UART_Rc_SR[8] : UART_Rc_SR[9] ;

   always @(posedge cp2 or negedge ireset)
   begin : Receiver_Shift
      if (!ireset)
      begin
         // Reset
         nUART_Rc_St0 <= 1'b0 ; 
         UART_Rc_St1 <= 1'b0 ; 
         UART_Rc_St2 <= 1'b0 ; 
         UART_Rc_St3 <= 1'b0 ; 
         UART_Rc_St4 <= 1'b0 ; 
         UART_Rc_St5 <= 1'b0 ; 
         UART_Rc_St6 <= 1'b0 ; 
         UART_Rc_St7 <= 1'b0 ; 
         UART_Rc_St8 <= 1'b0 ; 
         UART_Rc_St9 <= 1'b0 ; 
         UART_Rc_St10 <= 1'b0 ; 
         UART_Rc_SR <= {10{1'b0}} ; 
      end
      else
      begin
         // Clock
         if ((Baud_Gen_Out & UART_RcDel_St9) == 1'b1)
         begin
            // Clock enable
            nUART_Rc_St0 <= (~nUART_Rc_St0 & ~RXD_ResyncB) | (nUART_Rc_St0 & ~UART_Rc_St10) ; 
            UART_Rc_St1 <= ~UART_Rc_St1 & (~nUART_Rc_St0 & ~RXD_ResyncB) ; // D0
            UART_Rc_St2 <= UART_Rc_St1 ; // D1
            UART_Rc_St3 <= UART_Rc_St2 ; // D2
            UART_Rc_St4 <= UART_Rc_St3 ; // D3
            UART_Rc_St5 <= UART_Rc_St4 ; // D4
            UART_Rc_St6 <= UART_Rc_St5 ; // D5
            UART_Rc_St7 <= UART_Rc_St6 ; // D6
            UART_Rc_St8 <= UART_Rc_St7 ; // D7
            UART_Rc_St9 <= UART_Rc_St8 & `CHR9 ; // D8
            UART_Rc_St10 <= (UART_Rc_St8 & ~`CHR9) | UART_Rc_St9 ; // Stop bit
            UART_Rc_SR[6:0] <= UART_Rc_SR[7:1] ; 
            UART_Rc_SR[7] <= UART_Rc_SR7_In ; 
            UART_Rc_SR[8] <= UART_Rc_SR[9] ; 
            UART_Rc_SR[9] <= Detector_Out ; 
         end 
      end 
   end 

   always @(posedge cp2 or negedge ireset)
   begin : RXD_Resynch
      if (!ireset)
      begin
         // Reset
         RXD_ResyncA <= 1'b1 ; 
         RXD_ResyncB <= 1'b1 ; 
      end
      else
      begin
         // Clock
         RXD_ResyncA <= rxd ; 
         RXD_ResyncB <= RXD_ResyncA ; 
      end 
   end 

   always @(posedge cp2 or negedge ireset)
   begin : Receiver_Detect
      if (!ireset)
      begin
         // Reset
         Detector_A <= 1'b0 ; 
         Detector_B <= 1'b0 ; 
      end
      else
      begin
         // Clock
         //if (Baud_Gen_Out and UART_RcDel_St7)='1' then -- Clock enable
         if (Baud_Gen_Out == 1'b1)
         begin
            // Clock enable	 
            Detector_A <= RXD_ResyncB ; 
            Detector_B <= Detector_A ; 
         end 
      end 
   end 
   assign RcStartDet = (RXD_ResyncB == 1'b0 & Detector_A == 1'b1) ? 1'b1 : 1'b0 ;
   assign Detector_Out = (Detector_A & Detector_B) | (Detector_B & RXD_ResyncB) | (Detector_A & RXD_ResyncB) ;

   always @(posedge cp2 or negedge ireset)
   begin : UDR_Rx_Reg
      if (!ireset)
      begin
         // Reset
         UDR_Rx <= {8{1'b0}} ; 
         `FE <= 1'b0 ; // Framing error
      end
      else
      begin
         // Clock
         if ((UART_Rc_Delay & `RXEN & ~`RXC) == 1'b1)
         begin
            // Clock enable ??? TBD
            UDR_Rx <= UART_Rc_SR[7:0] ; 
            `FE <= ~UART_Rc_SR[9] ; // Framing error
         end 
      end 
   end 

   always @(posedge cp2 or negedge ireset)
   begin : UCR_RXB8
      if (!ireset)
      begin
         // Reset
         `RXB8 <= 1'b1 ; // ??? Check the papers again
      end
      else
      begin
         // Clock
         if ((UART_Rc_Delay & `RXEN & ~`RXC & `CHR9) == 1'b1)
         begin
            // Clock enable ??? TBD
            `RXB8 <= UART_Rc_SR[8] ; // RXB8
         end 
      end 
   end 

   always @(posedge cp2 or negedge ireset)
   begin : USR_Bits
      if (!ireset)
      begin
         // Reset
         `RXC <= 1'b0 ; 
         `DOR <= 1'b0 ; 
         UART_Rc_Delay <= 1'b0 ; 
      end
      else
      begin
         // Clock
         `RXC <= (~`RXC & (UART_Rc_Delay & `RXEN)) | (`RXC & ~UDR_Rd) ; 
         `DOR <= (~`DOR & (UART_Rc_Delay & `RXEN & `RXC)) | (`DOR & ~(UART_Rc_Delay & `RXEN & ~`RXC)) ; 
         UART_Rc_Delay <= ~UART_Rc_Delay & (Baud_Gen_Out & UART_Rc_St10 & UART_RcDel_St9) ; 
      end 
   end 
   
   // Reserved USR bits
   //assign USR[2:0] = {3{1'b0}};
   always@(USR)
   	USR[2:0] = {3{1'b0}};
   
   assign USR_Rd = (/*fn_to_integer(*/adr/*)*/ == UCSR0A_Address & iore == 1'b1) ? 1'b1 : 1'b0 ;
   assign UCR_Rd = (/*fn_to_integer(*/adr/*)*/ == UCSR0B_Address & iore == 1'b1) ? 1'b1 : 1'b0 ;
   assign UBRR_Rd = (/*fn_to_integer(*/adr/*)*/ == UBRR0L_Address & iore == 1'b1) ? 1'b1 : 1'b0 ;

   assign dbus_out[7:0] = (UDR_Rx[7:0] & {8{UDR_Rd}}) | 
                          (USR[7:0] & {8{USR_Rd}}) | 
			  (UCR[7:0] & {8{UCR_Rd}}) | 
			  (UBRR[7:0] & {8{UBRR_Rd}}) ; 
   
   // Reciever IRQ
   assign rxcirq = `RXC & `RXCIE ;
   // External lines
   assign rx_en = `RXEN ;
   assign tx_en = `TXEN ;
   
endmodule // uart
