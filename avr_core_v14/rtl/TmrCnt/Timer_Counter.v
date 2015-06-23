//**********************************************************************************************
// Timers/Counters Block Peripheral for the AVR Core
// Version 1.40?? (Special version for the JTAG OCD)
// Modified 08.01.2007
// Synchronizer for EXT1/EXT2 inputs was added
// Designed by Ruslan Lepetenok
// Note : Only T/C0 and T/C2 are implemented
// OCF0/OCF2 bug found and fixed 
//**********************************************************************************************

`timescale 1 ns / 1 ns

module Timer_Counter(ireset, cp2, cp2en, tmr_cp2en, stopped_mode, tmr_running, adr, dbus_in, dbus_out, iore, iowe, out_en, EXT1, EXT2, OC0_PWM0, OC1A_PWM1A, OC1B_PWM1B, OC2_PWM2, TC0OvfIRQ, TC0OvfIRQ_Ack, TC0CmpIRQ, TC0CmpIRQ_Ack, TC2OvfIRQ, TC2OvfIRQ_Ack, TC2CmpIRQ, TC2CmpIRQ_Ack, TC1OvfIRQ, TC1OvfIRQ_Ack, TC1CmpAIRQ, TC1CmpAIRQ_Ack, TC1CmpBIRQ, TC1CmpBIRQ_Ack, TC1ICIRQ, TC1ICIRQ_Ack);
   // AVR Control
   input            ireset;
   input            cp2;
   input            cp2en;
   input            tmr_cp2en;
   input            stopped_mode;		// ??
   input            tmr_running;		// ??
   input [5:0]      adr;
   input [7:0]      dbus_in;
   output reg [7:0] dbus_out;
   input            iore;
   input            iowe;
   output reg       out_en;
   // External inputs/outputs
   input            EXT1;
   input            EXT2;
   output           OC0_PWM0;
   output           OC1A_PWM1A;
   output           OC1B_PWM1B;
   output           OC2_PWM2;
   // Interrupt related signals
   output           TC0OvfIRQ;
   input            TC0OvfIRQ_Ack;
   output           TC0CmpIRQ;
   input            TC0CmpIRQ_Ack;
   output           TC2OvfIRQ;
   input            TC2OvfIRQ_Ack;
   output           TC2CmpIRQ;
   input            TC2CmpIRQ_Ack;
   output           TC1OvfIRQ;
   input            TC1OvfIRQ_Ack;
   output           TC1CmpAIRQ;
   input            TC1CmpAIRQ_Ack;
   output           TC1CmpBIRQ;
   input            TC1CmpBIRQ_Ack;
   output           TC1ICIRQ;
   input            TC1ICIRQ_Ack;
    
  `include "avr_adr_pack.vh"
     
   // Copies of the external signals
   reg              OC0_PWM0_Int;
   reg              OC2_PWM2_Int;
   
   // Registers
   reg /*wire*/ [7:0]       TCCR0;
   wire [7:0]       TCCR1A;
   wire [7:0]       TCCR1B;
   reg /*wire*/ [7:0]       TCCR2;
   wire [7:0]       ASSR;		// Asynchronous status register (for TCNT0)
   reg [7:0]        TIMSK;
   reg /*wire*/ [7:0]       TIFR;
   reg /*wire*/ [7:0]        TCNT0;
   reg /*wire*/ [7:0]        TCNT2;
   reg /*wire*/ [7:0]        OCR0;
   reg /*wire*/ [7:0]        OCR2;
   wire [7:0]       TCNT1H;
   wire [7:0]       TCNT1L;
   wire [7:0]       OCR1AH;
   wire [7:0]       OCR1AL;
   wire [7:0]       OCR1BH;
   wire [7:0]       OCR1BL;
   wire [7:0]       ICR1H;
   wire [7:0]       ICR1L;
   
   // TCCR0 Bits
   `define CS00 TCCR0[0]
   `define CS01 TCCR0[1]
   `define CS02 TCCR0[2]
   `define CTC0 TCCR0[3]
   `define COM00 TCCR0[4]
   `define COM01 TCCR0[5]
   `define PWM0 TCCR0[6]
   
   // TCCR1A Bits
   `define PWM10 TCCR1A[0]
   `define PWM11 TCCR1A[1]
   `define COM1B0 TCCR1A[4]
   `define COM1B1 TCCR1A[5]
   `define COM1A0 TCCR1A[4]
   `define COM1A1 TCCR1A[5]
   
   // TCCR1B Bits
   `define CS10 TCCR1A[0]
   `define CS11 TCCR1A[1]
   `define CS12 TCCR1A[2]
   `define CTC1 TCCR1A[3]
   `define ICES1 TCCR1A[6]
   `define ICNC1 TCCR1A[7]
   
   // TCCR2 Bits
   `define CS20 TCCR2[0]
   `define CS21 TCCR2[1]
   `define CS22 TCCR2[2]
   `define CTC2 TCCR2[3]
   `define COM20 TCCR2[4]
   `define COM21 TCCR2[5]
   `define PWM2 TCCR2[6]
   
   // ASSR bits
   `define TCR0UB ASSR[0]
   `define OCR0UB ASSR[1]
   `define TCN0UB ASSR[2]
   `define AS0 ASSR[3]
   
   // TIMSK bits
   `define TOIE0 TIMSK[0]
   `define OCIE0 TIMSK[1]
   `define TOIE1 TIMSK[2]
   `define OCIE1B TIMSK[3]
   `define OCIE1A TIMSK[4]
   `define TICIE1 TIMSK[5]
   `define TOIE2 TIMSK[6]
   `define OCIE2 TIMSK[7]
   
   // TIFR bits
   `define TOV0 TIFR[0]
   `define OCF0 TIFR[1]
   `define TOV1 TIFR[2]
   `define OCF1B TIFR[3]
   `define OCF1A TIFR[4]
   `define ICF1 TIFR[5]
   `define TOV2 TIFR[6]
   `define OCF2 TIFR[7]
   
   // Prescaler1 signals
   reg              CK8;
   reg              CK64;
   reg              CK256;
   reg              CK1024;
   
   reg [9:0]        Pre1Cnt;		// Prescaler 1 counter (10-bit)
   
   reg              EXT1RE;		// Rising edge of external input EXT1 (for TCNT1 only)
   reg              EXT1FE;		// Falling edge of external input EXT1 (for TCNT1 only)
   
   reg              EXT2RE;		// Rising edge of external input EXT2	(for TCNT2 only)
   reg              EXT2FE;		// Falling edge of external input EXT2 (for TCNT2 only)
   
   // Risign/falling edge detectors	
   reg              EXT1Latched;
   reg              EXT2Latched;
   
   // Prescalers outputs 
   wire             TCNT0_En;		// Output of the prescaler 0
   wire             TCNT1_En;		// Output of the prescaler 1
   wire             TCNT2_En;		// Output of the prescaler 1
   
   // Prescaler0 signals	
   reg              PCK08;
   reg              PCK032;
   reg              PCK064;
   reg              PCK0128;
   reg              PCK0256;
   reg              PCK01024;
   
   reg [9:0]        Pre0Cnt;		// Prescaler 0 counter (10-bit)
   
   // Synchronizer signals
   reg              EXT1SA;
   reg              EXT1SB;		// Output of the synchronizer for EXT1
   reg              EXT2SA;
   reg              EXT2SB;		// Output of the synchronizer for EXT1
   
   // Temporary registers
   reg [7:0]        OCR0_Tmp;
   reg [7:0]        OCR2_Tmp;
   
   // Counters control(Inc/Dec)
   reg              Cnt0Dir;
   reg              Cnt2Dir;
   
   // 
   reg              TCNT0WrFl;
   wire             TCNT0CmpBl;
   
   reg              TCNT2WrFl;
   wire             TCNT2CmpBl;
   
   // Synchronizers
   
   always @(posedge cp2 or negedge ireset)
   begin: SyncDFFs
      if (!ireset)		// Reset
      begin
         EXT1SA <= 1'b0;
         EXT1SB <= 1'b0;
         EXT2SA <= 1'b0;
         EXT2SB <= 1'b0;
      end
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock Enable(Note 2)	 
         begin
            EXT1SA <= EXT1;
            EXT1SB <= EXT1SA;
            EXT2SA <= EXT2;
            EXT2SB <= EXT2SA;
         end
      end
   end
   
   // -------------------------------------------------------------------------------------------
   // Prescalers
   // -------------------------------------------------------------------------------------------	
   
   // Prescaler 1 for TCNT1 and TCNT2
   
   always @(posedge cp2 or negedge ireset)
   begin: Prescaler_1
      if (!ireset)		// Reset
      begin
         Pre1Cnt <= {10{1'b0}};
         CK8 <= 1'b0;
         CK64 <= 1'b0;
         CK256 <= 1'b0;
         CK1024 <= 1'b0;
         EXT1RE <= 1'b0;
         EXT1FE <= 1'b0;
         EXT2RE <= 1'b0;
         EXT2FE <= 1'b0;
         EXT1Latched <= 1'b0;
         EXT2Latched <= 1'b0;
      end
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock Enable
         begin
            Pre1Cnt <= Pre1Cnt + 1;
            CK8 <= (~CK8) & (Pre1Cnt[0] & Pre1Cnt[1] & Pre1Cnt[2]);
            CK64 <= (~CK64) & (Pre1Cnt[0] & Pre1Cnt[1] & Pre1Cnt[2] & Pre1Cnt[3] & Pre1Cnt[4] & Pre1Cnt[5]);
            CK256 <= (~CK256) & (Pre1Cnt[0] & Pre1Cnt[1] & Pre1Cnt[2] & Pre1Cnt[3] & Pre1Cnt[4] & Pre1Cnt[5] & Pre1Cnt[6] & Pre1Cnt[7]);
            CK1024 <= (~CK1024) & (Pre1Cnt[0] & Pre1Cnt[1] & Pre1Cnt[2] & Pre1Cnt[3] & Pre1Cnt[4] & Pre1Cnt[5] & Pre1Cnt[6] & Pre1Cnt[7] & Pre1Cnt[8] & Pre1Cnt[9]);
            EXT1RE <= (~EXT1RE) & (EXT1SB & (~EXT1Latched));
            EXT1FE <= (~EXT1FE) & ((~EXT1SB) & EXT1Latched);
            EXT2RE <= (~EXT2RE) & (EXT2SB & (~EXT2Latched));
            EXT2FE <= (~EXT2FE) & ((~EXT2SB) & EXT2Latched);
            EXT1Latched <= EXT1SB;
            EXT2Latched <= EXT2SB;
         end
      end
   end
   
   // CK             "001"
   // CK/64			 "011"
   // CK/256		 "100"
   // CK/1024		 "101"
   // Falling edge	 "110"
   assign TCNT1_En = ((~`CS12) & (~`CS11) & `CS10) | (CK8 & (~`CS12) & `CS11 & (~`CS10)) | (CK64 & (~`CS12) & `CS11 & `CS10) | (CK256 & `CS12 & (~`CS11) & (~`CS10)) | (CK1024 & `CS12 & (~`CS11) & `CS10) | (EXT1FE & `CS12 & `CS11 & (~`CS10)) | (EXT1RE & `CS12 & `CS11 & `CS10);		// CK/8			 "010"
   // Rising edge	 "111"
   
   // CK             "001"
   // CK/64			 "011"
   // CK/256		 "100"
   // CK/1024		 "101"
   // Falling edge	 "110"
   assign TCNT2_En = ((~`CS22) & (~`CS21) & `CS20) | (CK8 & (~`CS22) & `CS21 & (~`CS20)) | (CK64 & (~`CS22) & `CS21 & `CS20) | (CK256 & `CS22 & (~`CS21) & (~`CS20)) | (CK1024 & `CS22 & (~`CS21) & `CS20) | (EXT2FE & `CS22 & `CS21 & (~`CS20)) | (EXT2RE & `CS22 & `CS21 & `CS20);		// CK/8			 "010"
   // Rising edge	 "111"
   
   
   always @(posedge cp2 or negedge ireset)
   begin: Prescaler_0_Cnt
      if (!ireset)		// Reset
         Pre0Cnt <= {10{1'b0}};
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock Enable(Note 2)	
            Pre0Cnt <= Pre0Cnt + 1;
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: Prescaler_0
      if (!ireset)		// Reset
      begin
         PCK08 <= 1'b0;
         PCK032 <= 1'b0;
         PCK064 <= 1'b0;
         PCK0128 <= 1'b0;
         PCK0256 <= 1'b0;
         PCK01024 <= 1'b0;
      end
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock Enable
         begin
            PCK08 <= ((~PCK08) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2]));
            PCK032 <= ((~PCK032) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2] & Pre0Cnt[3] & Pre0Cnt[4]));
            PCK064 <= ((~PCK064) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2] & Pre0Cnt[3] & Pre0Cnt[4] & Pre0Cnt[5]));
            PCK0128 <= ((~PCK0128) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2] & Pre0Cnt[3] & Pre0Cnt[4] & Pre0Cnt[5] & Pre0Cnt[6]));
            PCK0256 <= ((~PCK0256) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2] & Pre0Cnt[3] & Pre0Cnt[4] & Pre0Cnt[5] & Pre0Cnt[6] & Pre0Cnt[7]));
            PCK01024 <= ((~PCK01024) & (Pre0Cnt[0] & Pre0Cnt[1] & Pre0Cnt[2] & Pre0Cnt[3] & Pre0Cnt[4] & Pre0Cnt[5] & Pre0Cnt[6] & Pre0Cnt[7] & Pre0Cnt[8] & Pre0Cnt[9]));
         end
      end
   end
   
   // PCK            "001" 
   // PCK/32		   "011"
   // PCK/64		   "100"
   // PCK/64		   "101"
   // PCK/256		   "110"
   assign TCNT0_En = ((~`CS02) & (~`CS01) & `CS00) | (PCK08 & (~`CS02) & `CS01 & (~`CS00)) | (PCK032 & (~`CS02) & `CS01 & `CS00) | (PCK064 & `CS02 & (~`CS01) & (~`CS00)) | (PCK0128 & `CS02 & (~`CS01) & `CS00) | (PCK0256 & `CS02 & `CS01 & (~`CS00)) | (PCK01024 & `CS02 & `CS01 & `CS00);		// PCK/8		   "010"
   // PCK/1024	   "111"
   
   // -------------------------------------------------------------------------------------------
   // End of prescalers
   // -------------------------------------------------------------------------------------------
   
   // -------------------------------------------------------------------------------------------
   // Timer/Counter 0 
   // -------------------------------------------------------------------------------------------
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TimerCounter0Cnt
      if (!ireset)		// Reset
         TCNT0 <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == TCNT0_Address && iowe & cp2en)		// Write to TCNT0
            TCNT0 <= dbus_in;
         else if (tmr_cp2en)
            case (`PWM0)
               1'b0 :		// Non-PWM mode  
                  if (`CTC0 == 1'b1 & TCNT0 == OCR0)		// Clear T/C on compare match
                     TCNT0 <= {8{1'b0}};
                  else if (TCNT0_En == 1'b1)
                     TCNT0 <= TCNT0 + 1;		// Increment TCNT0	  
               1'b1 :		// PWM mode  
                  if (TCNT0_En == 1'b1)
                     case (Cnt0Dir)
                        1'b0 :		// Counts up
                           if (TCNT0 == 8'hFF)
                              TCNT0 <= 8'hFE;
                           else
                              TCNT0 <= TCNT0 + 1;		// Increment TCNT0 (0 to FF)
                        1'b1 :		// Counts down
                           if (TCNT0 == 8'h00)
                              TCNT0 <= 8'h01;
                           else
                              TCNT0 <= TCNT0 - 1;		// Decrement TCNT0 (FF to 0)	  
                        default :
                           ;
                     endcase
               default :
                  ;
            endcase
         
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: Cnt0DirectionControl
      if (!ireset)		// Reset
         Cnt0Dir <= 1'b0;
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock enable
         begin
            if (TCNT0_En == 1'b1)
            begin
               if (`PWM0 == 1'b1)
                  case (Cnt0Dir)
                     1'b0 :
                        if (TCNT0 == 8'hFF)
                           Cnt0Dir <= 1'b1;
                     1'b1 :
                        if (TCNT0 == 8'h00)
                           Cnt0Dir <= 1'b0;
                     default :
                        ;
                  endcase
            end
         end
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCnt0OutputControl
      if (!ireset)		// Reset
         OC0_PWM0_Int <= 1'b0;
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock enable
         begin
            if (TCNT0_En == 1'b1)
               
               case (`PWM0)
                  1'b0 :		//  Non PWM Mode
                     if (TCNT0 == OCR0 & TCNT0CmpBl == 1'b0)
                     begin
                        if (`COM01 == 1'b0 & `COM00 == 1'b1)		// Toggle	 
                           OC0_PWM0_Int <= (~OC0_PWM0_Int);
                     end
                  1'b1 :		//  PWM Mode	   
                     case (TCCR0[5:4])		// -> COM01&COM00
                        2'b10 :		// Non-inverted PWM  
                           if (TCNT0 == 8'hFF)		// Update OCR0
                           begin
                              if (OCR0_Tmp == 8'h00)
                                 OC0_PWM0_Int <= 1'b0;		// Clear
                              else if (OCR0_Tmp == 8'hFF)
                                 OC0_PWM0_Int <= 1'b1;		// Set
                           end
                           else if (TCNT0 == OCR0 & OCR0 != 8'h00)
                           begin
                              if (Cnt0Dir == 1'b0)		// Up-counting 
                                 OC0_PWM0_Int <= 1'b0;		// Clear			 
                              else
                                 // Down-counting
                                 OC0_PWM0_Int <= 1'b1;		// Set		 			
                           end
                        2'b11 :		// Inverted PWM  
                           if (TCNT0 == 8'hFF)		// Update OCR0
                           begin
                              if (OCR0_Tmp == 8'h00)
                                 OC0_PWM0_Int <= 1'b1;		// Set
                              else if (OCR0_Tmp == 8'hFF)
                                 OC0_PWM0_Int <= 1'b0;		// Clear
                           end
                           else if (TCNT0 == OCR0 & OCR0 != 8'h00)
                           begin
                              if (Cnt0Dir == 1'b0)		// Up-counting 
                                 OC0_PWM0_Int <= 1'b1;		// Set 			 
                              else
                                 // Down-counting
                                 OC0_PWM0_Int <= 1'b0;		// Clear 		 			
                           end
                        default :
                           ;
                     endcase
                  
                  default :
                     ;
               endcase
            
         end
      end
   end
   
   assign OC0_PWM0 = OC0_PWM0_Int;
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCnt0_TIFR_Bits
      if (!ireset)		// Reset
      begin
         `TOV0 <= 1'b0;
         `OCF0 <= 1'b0;
      end
      else 		// Clock	
      begin
         
         // TOV0
         if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
         begin
            if (adr == TIFR_Address && iowe)
               `TOV0 <= dbus_in[0];		// !!!
         end
         else
            case (`TOV0)
               1'b0 :
                  if (tmr_cp2en & TCNT0_En == 1'b1)
                  begin
                     if (`PWM0 == 1'b0)		// Non PWM Mode
                     begin
                        if (TCNT0 == 8'hFF)
                           `TOV0 <= 1'b1;
                     end
                     else
                        // PWM Mode 
                        if (TCNT0 == 8'h00)
                           `TOV0 <= 1'b1;
                  end
               1'b1 :
                  if ((TC0OvfIRQ_Ack == 1'b1 | (adr == TIFR_Address && iowe & dbus_in[0] == 1'b1)) & cp2en)		// Clear TOV0 flag
                     `TOV0 <= 1'b0;
               default :
                  ;
            endcase
         
         // OCF0
         if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
         begin
            if (adr == TIFR_Address && iowe)
               `OCF0 <= dbus_in[1];		// !!!
         end
         else
            case (`OCF0)
               1'b0 :
                  if (tmr_cp2en)		// Was  "and TCNT0_En='1'"
                  begin
                     if (TCNT0 == OCR0 & TCNT0CmpBl == 1'b0)
                        `OCF0 <= 1'b1;
                  end
               1'b1 :
                  if ((TC0CmpIRQ_Ack == 1'b1 | (adr == TIFR_Address && iowe & dbus_in[1] == 1'b1)) & cp2en)		// Clear OCF2 flag
                     `OCF0 <= 1'b0;
               default :
                  ;
            endcase
      end
      
   end
   
//   assign TCCR0[7] = 1'b0;
     always@(*) 
      TCCR0[7] = 1'b0; 
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCCR0_Reg
      if (!ireset)		// Reset
         TCCR0[6:0] <= {7{1'b0}};
      else 		// Clock
      begin
         if (cp2en)		// Clock Enable	
         begin
            if (adr == TCCR0_Address && iowe)
               TCCR0[6:0] <= dbus_in[6:0];
         end
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: OCR0_Write
      if (!ireset)		// Reset
         OCR0 <= {8{1'b0}};
      else 		// Clock
         case (`PWM0)
            1'b0 :		// Non-PWM mode
               if (adr == OCR0_Address && iowe & cp2en)		// Load data from the data bus
                  OCR0 <= dbus_in;
            1'b1 :		// PWM mode
               if (TCNT0 == 8'hFF & tmr_cp2en & TCNT0_En == 1'b1)		// Load data from the temporary register
                  OCR0 <= OCR0_Tmp;
            default :
               ;
         endcase
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: OCR0_Tmp_Write
      if (!ireset)		// Reset
         OCR0_Tmp <= {8{1'b0}};
      else 		// Clock
      begin
         if (cp2en)
         begin
            if (adr == OCR0_Address && iowe)		// Load data from the data bus
               OCR0_Tmp <= dbus_in;
         end
      end
   end
   
   // 
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCNT0WriteControl
      if (!ireset)		// Reset
         TCNT0WrFl <= 1'b0;
      else 		// Clock
      begin
         if (cp2en)
            case (TCNT0WrFl)
               1'b0 :
                  if (adr == TCNT0_Address && iowe & TCNT0_En == 1'b0)		// Load data from the data bus 
                     TCNT0WrFl <= 1'b1;
               1'b1 :
                  if (TCNT0_En == 1'b0)
                     TCNT0WrFl <= 1'b0;
               default :
                  ;
            endcase
      end
   end
   
   // Operations on compare match(OCF0 and Toggling) disabled for TCNT0
   assign TCNT0CmpBl = ((TCNT0WrFl == 1'b1 | (adr == TCNT0_Address && iowe))) ? 1'b1 : 
                       1'b0;
   
   // -------------------------------------------------------------------------------------------
   // Timer/Counter 2
   // -------------------------------------------------------------------------------------------
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TimerCounter2Cnt
      if (!ireset)		// Reset
         TCNT2 <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == TCNT2_Address && iowe & cp2en)		// Write to TCNT2
            TCNT2 <= dbus_in;
         else if (tmr_cp2en)
            case (`PWM2)
               1'b0 :		// Non-PWM mode  
                  if (`CTC2 == 1'b1 & TCNT2 == OCR2)		// Clear T/C on compare match
                     TCNT2 <= {8{1'b0}};
                  else if (TCNT2_En == 1'b1)
                     TCNT2 <= TCNT2 + 1;		// Increment TCNT2
               1'b1 :		// PWM mode  
                  if (TCNT2_En == 1'b1)
                     case (Cnt2Dir)
                        1'b0 :		// Counts up
                           if (TCNT2 == 8'hFF)
                              TCNT2 <= 8'hFE;
                           else
                              TCNT2 <= TCNT2 + 1;		// Increment TCNT2 (0 to FF)
                        1'b1 :		// Counts down
                           if (TCNT2 == 8'h00)
                              TCNT2 <= 8'h01;
                           else
                              TCNT2 <= TCNT2 - 1;		// Decrement TCNT0 (FF to 0)	  
                        default :
                           ;
                     endcase
               default :
                  ;
            endcase
         
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: Cnt2DirectionControl
      if (!ireset)		// Reset
         Cnt2Dir <= 1'b0;
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock enable
         begin
            if (TCNT2_En == 1'b1)
            begin
               if (`PWM2 == 1'b1)
                  case (Cnt2Dir)
                     1'b0 :
                        if (TCNT2 == 8'hFF)
                           Cnt2Dir <= 1'b1;
                     1'b1 :
                        if (TCNT2 == 8'h00)
                           Cnt2Dir <= 1'b0;
                     default :
                        ;
                  endcase
            end
         end
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCnt2OutputControl
      if (!ireset)		// Reset
         OC2_PWM2_Int <= 1'b0;
      else 		// Clock
      begin
         if (tmr_cp2en)		// Clock enable
         begin
            if (TCNT2_En == 1'b1)
               
               case (`PWM2)
                  1'b0 :		//  Non PWM Mode
                     if (TCNT2 == OCR2 & TCNT2CmpBl == 1'b0)
                     begin
                        if (`COM21 == 1'b0 & `COM20 == 1'b1)		// Toggle	 
                           OC2_PWM2_Int <= (~OC2_PWM2_Int);
                     end
                  1'b1 :		//  PWM Mode	   
                     case (TCCR2[5:4])		// -> COM21&COM20
                        2'b10 :		// Non-inverted PWM  
                           if (TCNT2 == 8'hFF)		// Update OCR2
                           begin
                              if (OCR2_Tmp == 8'h00)
                                 OC2_PWM2_Int <= 1'b0;		// Clear
                              else if (OCR2_Tmp == 8'hFF)
                                 OC2_PWM2_Int <= 1'b1;		// Set
                           end
                           else if (TCNT2 == OCR2 & OCR2 != 8'h00)
                           begin
                              if (Cnt2Dir == 1'b0)		// Up-counting 
                                 OC2_PWM2_Int <= 1'b0;		// Clear			 
                              else
                                 // Down-counting
                                 OC2_PWM2_Int <= 1'b1;		// Set		 			
                           end
                        2'b11 :		// Inverted PWM  
                           if (TCNT2 == 8'hFF)		// Update OCR2
                           begin
                              if (OCR2_Tmp == 8'h00)
                                 OC2_PWM2_Int <= 1'b1;		// Set
                              else if (OCR2_Tmp == 8'hFF)
                                 OC2_PWM2_Int <= 1'b0;		// Clear
                           end
                           else if (TCNT2 == OCR2 & OCR2 != 8'h00)
                           begin
                              if (Cnt2Dir == 1'b0)		// Up-counting 
                                 OC2_PWM2_Int <= 1'b1;		// Set 			 
                              else
                                 // Down-counting
                                 OC2_PWM2_Int <= 1'b0;		// Clear 		 			
                           end
                        default :
                           ;
                     endcase
                  
                  default :
                     ;
               endcase
            
         end
      end
   end
   
   assign OC2_PWM2 = OC2_PWM2_Int;
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCnt2_TIFR_Bits
      if (!ireset)		// Reset
      begin
         `TOV2 <= 1'b0;
         `OCF2 <= 1'b0;
      end
      else 		// Clock	
      begin
         
         // TOV2
         if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
         begin
            if (adr == TIFR_Address && iowe)
               `TOV2 <= dbus_in[6];		// !!!
         end
         else
            case (`TOV2)
               1'b0 :
                  if (tmr_cp2en & TCNT2_En == 1'b1)
                  begin
                     if (`PWM2 == 1'b0)		// Non PWM Mode
                     begin
                        if (TCNT2 == 8'hFF)
                           `TOV2 <= 1'b1;
                     end
                     else
                        // PWM Mode 
                        if (TCNT2 == 8'h00)
                           `TOV2 <= 1'b1;
                  end
               1'b1 :
                  if ((TC2OvfIRQ_Ack == 1'b1 | (adr == TIFR_Address && iowe & dbus_in[6] == 1'b1)) & cp2en)		// Clear TOV2 flag
                     `TOV2 <= 1'b0;
               default :
                  ;
            endcase
         
         // OCF2
         if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
         begin
            if (adr == TIFR_Address && iowe)
               `OCF2 <= dbus_in[7];		// !!!
         end
         else
            case (`OCF2)
               1'b0 :
                  if (tmr_cp2en)		// Was  "and TCNT2_En='1'"
                  begin
                     if (TCNT2 == OCR2 & TCNT2CmpBl == 1'b0)
                        `OCF2 <= 1'b1;
                  end
               1'b1 :
                  if ((TC2CmpIRQ_Ack == 1'b1 | (adr == TIFR_Address && iowe & dbus_in[7] == 1'b1)) & cp2en)		// Clear OCF2 flag
                     `OCF2 <= 1'b0;
               default :
                  ;
            endcase
      end
      
   end
   
   // assign TCCR2[7] = 1'b0;
   
   always @(*)
    TCCR2[7] = 1'b0;
   
   always @(posedge cp2 or negedge ireset)
   begin: TCCR2_Reg
      if (!ireset)		// Reset
         TCCR2[6:0] <= {7{1'b0}};
      else 		// Clock
      begin
         if (cp2en)		// Clock Enable	
         begin
            if (adr == TCCR2_Address && iowe)
               TCCR2[6:0] <= dbus_in[6:0];
         end
      end
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: OCR2_Write
      if (!ireset)		// Reset
         OCR2 <= {8{1'b0}};
      else 		// Clock
         case (`PWM2)
            1'b0 :		// Non-PWM mode
               if (adr == OCR2_Address && iowe & cp2en)		// Load data from the data bus
                  OCR2 <= dbus_in;
            1'b1 :		// PWM mode
               if (TCNT2 == 8'hFF & tmr_cp2en & TCNT2_En == 1'b1)		// Load data from the temporary register
                  OCR2 <= OCR2_Tmp;
            default :
               ;
         endcase
   end
   
   
   always @(posedge cp2 or negedge ireset)
   begin: OCR2_Tmp_Write
      if (!ireset)		// Reset
         OCR2_Tmp <= {8{1'b0}};
      else 		// Clock
      begin
         if (cp2en)
         begin
            if (adr == OCR2_Address && iowe)		// Load data from the data bus
               OCR2_Tmp <= dbus_in;
         end
      end
   end
   
   // 
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TCNT2WriteControl
      if (!ireset)		// Reset
         TCNT2WrFl <= 1'b0;
      else 		// Clock
      begin
         if (cp2en)
            case (TCNT2WrFl)
               1'b0 :
                  if (adr == TCNT2_Address && iowe & TCNT2_En == 1'b0)		// Load data from the data bus 
                     TCNT2WrFl <= 1'b1;
               1'b1 :
                  if (TCNT2_En == 1'b0)
                     TCNT2WrFl <= 1'b0;
               default :
                  ;
            endcase
      end
   end
   
   // Operations on compare match(OCF2 and Toggling) disabled for TCNT2
   assign TCNT2CmpBl = ((TCNT2WrFl == 1'b1 | (adr == TCNT2_Address && iowe))) ? 1'b1 : 
                       1'b0;
   
   // -------------------------------------------------------------------------------------------
   // Common (Control/Interrupt) bits
   // ------------------------------------------------------------------------------------------- 
   
   
   always @(posedge cp2 or negedge ireset)
   begin: TIMSK_Bits
      if (!ireset)
         TIMSK <= {8{1'b0}};
      else 
      begin
         if (cp2en)		// Clock Enable	
         begin
            if (adr == TIMSK_Address && iowe)
               TIMSK <= dbus_in;
         end
      end
   end
   
   // Interrupt flags of Timer/Counter0
   assign TC0OvfIRQ = `TOV0 & `TOIE0;		// Interrupt on overflow of TCNT0
   assign TC0CmpIRQ = `OCF0 & `OCIE0;		// Interrupt on compare match	of TCNT0
   
   // Interrupt flags of Timer/Counter0
   assign TC2OvfIRQ = `TOV2 & `TOIE2;		// Interrupt on overflow of TCNT2
   assign TC2CmpIRQ = `OCF2 & `OCIE2;		// Interrupt on compare match	of TCNT2
   
   // Unused interrupt requests(for T/C1)
   assign TC1OvfIRQ = `TOV1 & `TOIE1;
   assign TC1CmpAIRQ = `OCF1A & `OCIE1A;
   assign TC1CmpBIRQ = `OCF1B & `OCIE1B;
   assign TC1ICIRQ = `ICF1 & `TICIE1;
   
   // Unused TIFR flags(for T/C1)
   /*
   assign `TOV1 = 1'b0;
   assign `OCF1A = 1'b0;
   assign `OCF1B = 1'b0;
   assign `ICF1 = 1'b0;
   */
   always@(*) begin
    `TOV1 = 1'b0;
    `OCF1A = 1'b0;
    `OCF1B = 1'b0;
    `ICF1 = 1'b0;
   end
   
   
   
   // -------------------------------------------------------------------------------------------
   // End of common (Control/Interrupt) bits
   // -------------------------------------------------------------------------------------------
   
   // -------------------------------------------------------------------------------------------
   // Bus interface
   // -------------------------------------------------------------------------------------------
   
   
   always @(adr or iore or TIMSK or TIFR or TCCR0 or TCNT0 or OCR0 or OCR0_Tmp or TCCR2 or TCNT2 or OCR2 or OCR2_Tmp)
   begin: OutMuxComb
      case (adr)
         TCCR0_Address :
            begin
               dbus_out = TCCR0;
               out_en = iore;
            end
         TCCR1A_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         TCCR1B_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         TCCR2_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         ASSR_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         TIMSK_Address :
            begin
               dbus_out = TIMSK;
               out_en = iore;
            end
         TIFR_Address :
            begin
               dbus_out = TIFR;
               out_en = iore;
            end
         TCNT0_Address :
            begin
               dbus_out = TCNT0;
               out_en = iore;
            end
         TCNT2_Address :
            begin
               dbus_out = TCNT2;
               out_en = iore;
            end
         OCR0_Address :
            begin
               out_en = iore;
               if (`PWM0 == 1'b0)		// Non PWM mode of T/C0
                  dbus_out = OCR0;
               else
                  dbus_out = OCR0_Tmp;
            end
         OCR2_Address :
            begin
               out_en = iore;
               if (`PWM2 == 1'b0)		// Non PWM mode of T/C2
                  dbus_out = OCR2;
               else
                  dbus_out = OCR2_Tmp;
            end
         TCNT1H_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         TCNT1L_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         OCR1AH_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         OCR1AL_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         OCR1BH_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         OCR1BL_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         ICR1H_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         ICR1L_Address :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
         default :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
      endcase
      end  // OutMuxComb
      
endmodule

// -------------------------------------------------------------------------------------------
// End of bus interface
// -------------------------------------------------------------------------------------------
