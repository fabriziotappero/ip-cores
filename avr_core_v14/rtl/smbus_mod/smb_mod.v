//**********************************************************************************************
// SMBus(Revision 1.1) Peripheral for the AVR Core
// Version 2.2
// Modified 12.01.2007
// Designed by Ruslan Lepetenok
// CONSTANT(Cimpl_pec) was replaces by GENERIC(impl_pec)
//**********************************************************************************************

`timescale 1 ns / 1 ns

module smb_mod(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en,
   twiirq,
   msmbirq,
   offstirq,
   offstirq_ack,
   sdain,
   sdaout,
   sdaen,
   sclin,
   sclout,
   sclen,
   msdain,
   msdaout,
   msdaen,
   msclin,
   msclout,
   msclen
);
   parameter                      impl_pec = 1;
   // AVR Control
   input                          ireset;
   input                          cp2;
   input [5:0]                    adr;
   input [7:0]                    dbus_in;
   output reg [7:0]               dbus_out;
   input                          iore;
   input                          iowe;
   output reg                     out_en;
   // Slave IRQ
   output                         twiirq;
   // Master IRQ
   output                         msmbirq;
   // "Off state" timer IRQ
   output                         offstirq;
   input                          offstirq_ack;
   // TRI control and data for the slave channel
   input                          sdain;
   output                         sdaout;
   output                         sdaen;
   input                          sclin;
   output                         sclout;
   output                         sclen;
   // TRI control and data for the master channel
   input                          msdain;
   output                         msdaout;
   output                         msdaen;
   input                          msclin;
   output                         msclout;
   output                         msclen;
   
   // Slave synchronizer
   reg                            SDASyncA;
   reg                            SDASyncB;
   reg                            SCLSyncA;
   reg                            SCLSyncB;
   
   // Master synchronizer
   reg                            MSDASyncA;
   reg                            MSDASyncB;
   reg                            MSCLSyncA;
   reg                            MSCLSyncB;
   
   // Internal copies of output signals(for slave)
   reg                            sdaen_int;
   reg                            sclen_int;
   
   // Internal copies of output signals(for master)
   reg                            msdaen_int;
   reg                            msclen_int;
   
   // TWI Registers
   reg [7:0]                      TWBR;
   wire [7:0]                     TWCR; // Fixed
//   wire [7:0]                     TWSR; // !!!
   reg [7:0]                      TWDR;
   reg [7:0]                      TWAR;
   
   // Bit names
   // TWCR
   reg TWINT_Current; // TWCR[7]
   reg TWEA_Current;  // TWCR[6]
   reg TWIE_Current;  // TWCR[0]
   
   // TWSR
   reg[1:0] TWPS_Current; // TWSR[1:0] -> !!! Note : Implemented only in ATmega128
   
   //TWAR
//   `define TWA   TWAR[7:1]
   wire TWGCE = TWAR[0]; 
   
   //Detectors
   wire                           DetStart;
   wire                           DetStop;
   wire                           DetSCLRE;
   wire                           DetSCLFE;
   reg                            SDADelDFF;
   reg                            SCLDelDFF;
   
   // Address/Data Shift In register
   reg [7:0]                      ADInReg;
   wire                           ADInRegEn;
   
   // Address comparator
   wire                           AdrCmpMatch;		// Output of the comporator
   
   // Receiver state machine
   reg                            nRcSM_St0;
   reg                            RcSM_St1;
   reg                            RcSM_St2;
   reg                            RcSM_St3;
   
   // SCL counter
   reg [3:0]                      SCLCnt;		// 0 to 8
   
   // Stages for slave (Address and Data) TBD
   reg                            AdrStage_St;
   reg                            DataStage_St;
   
   reg                            SlvSel_St;		// Slave is selected
   //signal SlvADAck_St  : std_logic;
   reg                            SRNW;		// '1'->Read, '0'->Write
   
   reg                            SARF;		// Indicates receiving of SLA+R/SLA+W
   
   reg                            sdaen_In;		// Input of sdaen_int DFF
   
   // Control registers for SMBus Slave and Master
   reg [7:0]                      SMBTOR;		// !!! TBD !!!
   
   // SMBus 50 uS timeout counter
   parameter [8+1:12]             C50uSCntWidth = 9;
   reg [C50uSCntWidth-1:0]        TO50uSCnt;
   wire                           TO50uS;		// Timeout for SCL (SCL is high for longer than 50 uS)
   
   // SMBus master signals
   wire [7:0]                     SMBMSR;		// Fixed
   reg [6:0]                      SMBMCR_Current;		// !!! Under construction
   
   // SMBus master status register bits
   reg MSTA_Current; // SMBMSR[0]		 // Start condition has been detected
   reg MSTO_Current; // SMBMSR[1]		 // Stop condition has been detected
   reg MRE_Current; //  SMBMSR[2]		 // SCL rising edge has been detected
   reg MFE_Current; //  SMBMSR[3]		 // SCL falling edge has been detected
   reg MCO_Current; //  SMBMSR[4]
   reg TOF_Current; //  SMBMSR[5]
   reg SDAS_Current; // SMBMSR[6]		 // SDA sampled on the "rising edge" of SCL
   
   // SMBus master control register bits
   wire MSTAIE; // SMBMCR[0]
   wire MSTOIE; // SMBMCR[1]
   wire MREIE;  // SMBMCR[2]
   wire MFEIE;  // SMBMCR[3]
   wire MCOIE;  // SMBMCR[4]
   wire TOE;    // SMBMCR[5] 	     // !!! TBD !!!
   wire TOFIE;  // SMBMCR[6]
   
   // Counter for SMBus Off State detection
   parameter [10:16]              CSMBOSCntWidth = 10;
   reg [CSMBOSCntWidth-1:0]       SMBOSCnt;
   parameter [CSMBOSCntWidth-1:0] CSMBOSCntOne = {CSMBOSCntWidth{1'b1}};
   
   // Combined control/status rgister
   wire [7:0]                     SMBOSR;
   // Control and status bits
   reg SMBOS_Current;  // SMBOSR[0]
   reg SMBOSC_Current; // SMBOSR[1]
   reg SMBOIE_Current; // SMBOSR[2]		 // Interrupt enable
   
   // Master bit rate counter (for SCL)
   reg [9:0]                      MBitRateCnt;
   
   // 
   wire                           LastRdDataPhase;
   
   // PEC 
   reg /*wire*/ [7:0]             SMBPEC_LFSR;
   
   // New
   reg                            Ack_Reg;
   reg                            EWS_Current; // TWCR[1] -> Enables wait state(SCL='0') before Data ACK(Slave receiver mode)
   wire                           WSP;		// 0 - after ACK / 1 - before ACK

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

//function fn_smb_pec(vect : std_logic_vector(7 downto 0); b : std_logic) return std_logic_vector is
//variable result : std_logic_vector(vect'range);
//begin
//
//result(0) := vect(7) xor b; 
//result(1) := vect(0) xor vect(7) xor b; 
//result(2) := vect(1) xor vect(0) xor vect(7) xor b; 
//
//for i in 3 to vect'high loop
// result(i) := vect(i-1);
//end loop;		
//	
// return (result);
//end fn_smb_pec;

function[7:0] fn_smb_pec;
input [7:0] vect;
input       b; 
reg[7:0]    result;
begin
 result[0] = vect[7] ^ b; 
 result[1] = vect[0] ^ vect[7] ^ b; 
 result[2] = vect[1] ^ vect[0] ^ vect[7] ^ b; 
 result[7:3] = vect[6:2];
 fn_smb_pec = result;
end
endfunction // fn_smb_pec


`include "avr_adr_pack.vh"

// SMBus "remapping"
localparam TWBR_Address    = PINF_Address;
localparam TWCR_Address    = SFIOR_Address;
localparam TWSR_Address    = PINE_Address;
localparam TWDR_Address    = PORTE_Address;
localparam TWAR_Address    = DDRE_Address;	

localparam SMBTOR_Address  = ADCSRA_Address;
localparam SMBMSR_Address  = ADCH_Address;
localparam SMBMCR_Address  = ADCL_Address;

localparam SMBOSR_Address  = ACSR_Address;
localparam SMBPEC_Address  = ADMUX_Address;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
   
   always @(negedge ireset or posedge cp2)
   begin: SynchronizersAndDetDFF
      if (!ireset)		// Reset
      begin
         // Slave
         SDASyncA <= 1'b1;
         SDASyncB <= 1'b1;
         SCLSyncA <= 1'b1;
         SCLSyncB <= 1'b1;
         SDADelDFF <= 1'b1;
         SCLDelDFF <= 1'b1;
         // Master
         MSDASyncA <= 1'b1;
         MSDASyncB <= 1'b1;
         MSCLSyncA <= 1'b1;
         MSCLSyncB <= 1'b1;
      end
      else 		// Clock
      begin
         // Slave
         SDASyncA <= sdain;
         SDASyncB <= SDASyncA;
         SCLSyncA <= sclin;
         SCLSyncB <= SCLSyncA;
         SDADelDFF <= SDASyncB;
         SCLDelDFF <= SCLSyncB;
         // Master
         MSDASyncA <= msdain;
         MSDASyncB <= MSDASyncA;
         MSCLSyncA <= msclin;
         MSCLSyncB <= MSCLSyncA;
      end
   end
   
   // Detecters(Combinatorial part)
   assign DetStart = SCLSyncB & SCLDelDFF & (~SDASyncB) & SDADelDFF;
   
   assign DetStop = SCLSyncB & SCLDelDFF & SDASyncB & (~SDADelDFF);
   
   assign DetSCLRE = SCLSyncB & (~SCLDelDFF);
   
   assign DetSCLFE = (~SCLSyncB) & SCLDelDFF;
   
   
   always @(negedge ireset or posedge cp2)
   begin: SCL_SDA_SM
      if (!ireset)		// Reset
      begin
         sclen_int <= 1'b0;
         sdaen_int <= 1'b0;
      end
      else 		// Clock
      begin
         
         // SCL
         case (sclen_int)
            1'b0 :
               if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SlvSel_St == 1'b1 & ((SCLCnt == 4'b1000 & LastRdDataPhase == 1'b0) | (SCLCnt == 4'b0111 & EWS_Current == 1'b1 & DataStage_St == 1'b1 & SRNW == 1'b0)))		// SCL='0' after Address/Data ACK
                  // SCL='0' after Data LSB(Slave reciever)
                  sclen_int <= 1'b1;
            1'b1 :
               if (adr == TWCR_Address & iowe == 1'b1 & dbus_in[7] == 1'b1)
                  sclen_int <= 1'b0;
            default :
               ;
         endcase
         
         // SDA  
         if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1)
            sdaen_int <= sdaen_In;
         else if (TWINT_Current == 1'b1)
         begin
            if (SCLCnt == 4'b0000 & adr == TWDR_Address & iowe == 1'b1)		// Data MSB transmit
               sdaen_int <= (~dbus_in[7]);		// Write to TWDR(7)  
            else if (SCLCnt[3] == 1'b1 & EWS_Current == 1'b1 & DataStage_St == 1'b1 & SlvSel_St == 1'b1 & SRNW == 1'b0 & adr == TWCR_Address & iowe == 1'b1)		// Data ACK transmit(Slave receiver)
               sdaen_int <= dbus_in[6];		// Write to TWEA bit
         end
      end
      
   end
   
   // Combinatorial process
   always @(*)
   begin: SDARegInMux
      
      sdaen_In = 1'b0;
      
      case (SCLCnt)
         
         4'b0111 :		// 7 -> Set Address/Data Acknowlege
            // Data Ack(for Write)
            if (((AdrStage_St == 1'b1 & AdrCmpMatch == 1'b1) | (DataStage_St == 1'b1 & SlvSel_St == 1'b1 & SRNW == 1'b0)) & TWEA_Current == 1'b1)		// Address Ack
               sdaen_In = 1'b1;
         
         default :		// 0 .. 6
            if (DataStage_St == 1'b1 & SlvSel_St == 1'b1 & SRNW == 1'b1)
               case (SCLCnt)
                  4'b0000 :		// 0
                     sdaen_In = (~TWDR[6]);
                  4'b0001 :		// 1
                     sdaen_In = (~TWDR[5]);
                  4'b0010 :		// 2
                     sdaen_In = (~TWDR[4]);
                  4'b0011 :		// 3
                     sdaen_In = (~TWDR[3]);
                  4'b0100 :		// 4
                     sdaen_In = (~TWDR[2]);
                  4'b0101 :		// 5
                     sdaen_In = (~TWDR[1]);
                  4'b0110 :		// 6
                     sdaen_In = (~TWDR[0]);
                  default :
                     sdaen_In = 1'b0;
               endcase
      endcase
      
   end
   
   // !!!TBD!!!
   assign LastRdDataPhase = DataStage_St & SRNW & Ack_Reg;		// ??
   
   // Bus snooping state machine TBD: add timeout ?
   
   always @(negedge ireset or posedge cp2)
   begin: RecieverStateMachine
      if (!ireset)		// Reset
      begin
         nRcSM_St0 <= 1'b0;
         RcSM_St1 <= 1'b0;
         RcSM_St2 <= 1'b0;
         RcSM_St3 <= 1'b0;
         
         AdrStage_St <= 1'b0;
         DataStage_St <= 1'b0;
         SlvSel_St <= 1'b0;
         
         //  SlvADAck_St <= '0';
         TWINT_Current <= 1'b0;
         SRNW <= 1'b0;
         
         SARF <= 1'b0;
      end
      
      else 		// Clock
      begin
         
         case (nRcSM_St0)
            1'b0 :
               if (DetStart == 1'b1)		// Start has been detected
                  nRcSM_St0 <= 1'b1;
            1'b1 :
               if (DetStop == 1'b1 | (RcSM_St2 == 1'b1 & TO50uS == 1'b1 & DetStart == 1'b0))		// Stop has been detected
                  nRcSM_St0 <= 1'b0;
            default :
               ;
         endcase
         
         case (RcSM_St1)		// SCL =0 (after Start or Repeated Start)
            1'b0 :
               if (DetStart == 1'b1)		// ??? Start has been detected
                  RcSM_St1 <= 1'b1;
            1'b1 :
               if (DetStop == 1'b1 | DetSCLRE == 1'b1)
                  RcSM_St1 <= 1'b0;
            default :
               ;
         endcase
         
         case (RcSM_St2)		// SCL = 1
            1'b0 :
               if ((RcSM_St1 == 1'b1 | RcSM_St3 == 1'b1) & DetSCLRE == 1'b1)
                  RcSM_St2 <= 1'b1;
            1'b1 :
               if (DetSCLFE == 1'b1 | DetStart == 1'b1 | DetStop == 1'b1 | TO50uS == 1'b1)
                  RcSM_St2 <= 1'b0;
            default :
               ;
         endcase
         
         case (RcSM_St3)		// SCL = 0 
            1'b0 :
               if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & DetStart == 1'b0 & DetStop == 1'b0 & TO50uS == 1'b0)		// TO50uS !!!
                  RcSM_St3 <= 1'b1;
            1'b1 :
               if (DetSCLRE == 1'b1 | DetStart == 1'b1 | DetStop == 1'b1)		// ??
                  RcSM_St3 <= 1'b0;
            default :
               ;
         endcase
         
         case (AdrStage_St)
            1'b0 :
               if (DetStart == 1'b1)
                  AdrStage_St <= 1'b1;
            1'b1 :
               if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SCLCnt == 4'b1000)		// End of address stage
                  AdrStage_St <= 1'b0;
            default :
               ;
         endcase
         
         case (DataStage_St)
            1'b0 :
               if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SCLCnt == 4'b1000)		// End of address stage
                  DataStage_St <= 1'b1;
            1'b1 :
               if (DetStart == 1'b1 | DetStop == 1'b1)
                  DataStage_St <= 1'b0;
            default :
               ;
         endcase
         
         // !!! TBD !!!  
         case (SlvSel_St)
            1'b0 :
               if (AdrStage_St == 1'b1 & RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SCLCnt == 4'b0111 & AdrCmpMatch == 1'b1)
                  SlvSel_St <= 1'b1;
            1'b1 :
               if (DetStart == 1'b1 | DetStop == 1'b1 | (RcSM_St2 == 1'b1 & TO50uS == 1'b1))
                  SlvSel_St <= 1'b0;
            default :
               ;
         endcase
         
         // TWCR.TWINT  TBD
         case (TWINT_Current)
            1'b0 :
               if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SlvSel_St == 1'b1 & ((SCLCnt == 4'b1000 & LastRdDataPhase == 1'b0) | (SCLCnt == 4'b0111 & EWS_Current == 1'b1 & DataStage_St == 1'b1 & SRNW == 1'b0)))		// SCL='0' after Address/Data ACK
                  // SCL='0' after Data LSB(Slave reciever)
                  TWINT_Current <= 1'b1;
            1'b1 :
               if (adr == TWCR_Address & iowe == 1'b1 & dbus_in[7] == 1'b1)
                  TWINT_Current <= 1'b0;
            default :
               ;
         endcase
         
         case (SARF)
            1'b0 :
               if (AdrStage_St == 1'b1 & RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SCLCnt == 4'b1000 & SlvSel_St == 1'b1)
                  SARF <= 1'b1;
            1'b1 :
               if (adr == TWCR_Address & iowe == 1'b1 & dbus_in[7] == 1'b1)
                  SARF <= 1'b0;
            default :
               ;
         endcase
         
         // Read/nWrite Flag   
         if (AdrStage_St == 1'b1 & RcSM_St2 == 1'b1 & DetSCLFE == 1'b1 & SCLCnt == 4'b0111 & AdrCmpMatch == 1'b1)
            SRNW <= ADInReg[0];
      end
      
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: SCLFECounter
      if (!ireset)		// Reset
         SCLCnt <= {4{1'b0}};
      else 		// Clock
      begin
         if (DetStart == 1'b1)
            SCLCnt <= {4{1'b0}};
         else if (RcSM_St2 == 1'b1 & DetSCLFE == 1'b1)
         begin
            if (SCLCnt == 4'b1000)
               SCLCnt <= {4{1'b0}};
            else
               SCLCnt <= SCLCnt + 1;
         end
      end
   end
   
   // Address/Data Input Shift Register
   
   always @(negedge ireset or posedge cp2)
   begin: AdrDataInShReg
      integer                        i;
      if (!ireset)		// Reset
      begin
         ADInReg <= {8{1'b0}};
         Ack_Reg <= 1'b0;
      end
      else 		// Clock
      begin
         if (ADInRegEn == 1'b1)		// Clock enable
         begin
            // Shift 
            ADInReg[0] <= SDASyncB;		// SDA after resynchronization 
            for (i = 1; i <= 7; i = i + 1)
               ADInReg[i] <= ADInReg[i - 1];
         end
         
         if ((RcSM_St1 == 1'b1 | RcSM_St3 == 1'b1) & DetSCLRE == 1'b1 & SCLCnt[3] == 1'b1)
            Ack_Reg <= SDASyncB;
      end
   end
   
   // !!!TBD!!!
   assign ADInRegEn = ((RcSM_St1 == 1'b1 | RcSM_St3 == 1'b1) & DetSCLRE == 1'b1 & SCLCnt[3] == 1'b0) ? 1'b1 : 
                      1'b0;
   
   // Address comparator
   // Compare match
   assign AdrCmpMatch = (ADInReg[7:1] == TWAR[7:1] | (ADInReg[7:0] == 8'b00000000 & TWGCE == 1'b1)) ? 1'b1 : 1'b0; // General Call
                        
   
   // SCLCnt indicator flag
   assign WSP = SCLCnt[3];		// WSP = '1' when SCLCnt=8
   
   // Address(Slave) Register
   
   always @(negedge ireset or posedge cp2)
   begin: SlvAdrReg
      if (!ireset)		// Reset
         TWAR <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == TWAR_Address & iowe == 1'b1)		// Clock enable
            TWAR <= dbus_in;		// Write from the CPU
      end
   end
   
   // TWCR bits
   
   always @(negedge ireset or posedge cp2)
   begin: TWCRBits
      if (!ireset)		// Reset
      begin
         TWEA_Current <= 1'b0;
         EWS_Current <= 1'b0;
         TWIE_Current <= 1'b0;
      end
      else 		// Clock
      begin
         if (adr == TWCR_Address & iowe == 1'b1)		// Clock enable
         begin
            TWEA_Current <= dbus_in[6];		// Write from the CPU
            EWS_Current <= dbus_in[1];
            TWIE_Current <= dbus_in[0];
         end
      end
   end
   
   // Slave output data register
   
   always @(negedge ireset or posedge cp2)
   begin: SlvOutDataReg
      if (!ireset)		// Reset
         TWDR <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == TWDR_Address & iowe == 1'b1)		// Clock enable
            TWDR <= dbus_in;		// Write data from the CPU
      end
   end
   
   // SMBus 50uS timeout register
   
   always @(negedge ireset or posedge cp2)
   begin: SMB50uSTOReg
      if (!ireset)		// Reset
         SMBTOR <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == SMBTOR_Address & iowe == 1'b1)		// Clock enable
            SMBTOR <= dbus_in;		// Write data from the CPU
      end
   end
   
   // Counter for the 50uS SMBus timeout
   
   always @(negedge ireset or posedge cp2)
   begin: SMB50uSTOCnt
      if (!ireset)		// Reset
         TO50uSCnt <= {C50uSCntWidth{1'b0}};
      else 		// Clock
      begin
         if (SDASyncB == 1'b0 | SCLSyncB == 1'b0)		// Clear counter -- !!!TBD!!! SCL only or SCL/SDA
            TO50uSCnt <= {C50uSCntWidth{1'b0}};
         else
            TO50uSCnt <= TO50uSCnt + 1;		// Increment timeout counter
      end
   end
   
   // !!!TBD!!! compare LSB bits of the TO50uSCnt with "00..0" or not
   assign TO50uS = (TO50uSCnt[C50uSCntWidth-1:C50uSCntWidth - 8] == SMBTOR & TOE == 1'b1) ? 1'b1 : 1'b0;
   
   // SMBus control register for Master/Slave !!!TBD!!!
   
   always @(negedge ireset or posedge cp2)
   begin: SMBCtrlReg
      if (!ireset)		// Reset
         SMBMCR_Current[6:0] <= {7{1'b0}};
      else 		// Clock
      begin
         if (adr == SMBMCR_Address & iowe == 1'b1)		// Clock enable
            SMBMCR_Current[6:0] <= dbus_in[6:0];		// Write data from the CPU
      end
   end
   
      
   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SMBus master %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   always @(negedge ireset or posedge cp2)
   begin: MasterBitRateHighReg
      if (!ireset)		// Reset
         TWPS_Current <= {2{1'b0}};
      else 		// Clock
      begin
         if (adr == TWSR_Address & iowe == 1'b1)		// Clock enable
            TWPS_Current <= dbus_in[1:0];		// Write data from the CPU
      end
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: MasterPinControlReg
      if (!ireset)		// Reset
      begin
         msdaen_int <= 1'b1;
         msclen_int <= 1'b1;
      end
      else 		// Clock
      begin
         if (adr == TWSR_Address & iowe == 1'b1)		// Clock enable
         begin
            msdaen_int <= dbus_in[5];
            msclen_int <= dbus_in[4];
         end
      end
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: MasterBitRateReg
      if (!ireset)		// Reset
         TWBR <= {8{1'b0}};
      else 		// Clock
      begin
         if (adr == TWBR_Address & iowe == 1'b1)		// Clock enable
            TWBR <= dbus_in;		// Write data from the CPU
      end
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: MasterBitRateCnt
      if (!ireset)		// Reset
         MBitRateCnt <= {10{1'b0}};
      else 		// Clock
      begin
         if (DetSCLRE == 1'b1 | DetSCLFE == 1'b1)		// Clock enable
            MBitRateCnt <= {10{1'b0}};		// Clear counter
         else if (MBitRateCnt != {TWPS_Current, TWBR})
            MBitRateCnt <= MBitRateCnt + 1;
      end
   end
   
   
   always @(negedge ireset or posedge cp2)
   begin: SMBusMasterStatusReg
      if (!ireset)		// Reset
      begin
         
         MSTA_Current <= 1'b0;
         MSTO_Current <= 1'b0;
         MRE_Current <= 1'b0;
         MFE_Current <= 1'b0;
         MCO_Current <= 1'b0;
         TOF_Current <= 1'b0;
         SDAS_Current <= 1'b0;
      end
      
      else 		// Clock
      begin
         
         // Start flag	 
         case (MSTA_Current)
            1'b0 :
               if (DetStart == 1'b1)		// Set
                  MSTA_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[0] == 1'b1 & iowe == 1'b1 & DetStart == 1'b0)		// Reset
                  MSTA_Current <= 1'b0;
            default :
               ;
         endcase
         
         // Stop flag	 
         case (MSTO_Current)
            1'b0 :
               if (DetStop == 1'b1)		// Set
                  MSTO_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[1] == 1'b1 & iowe == 1'b1 & DetStop == 1'b0)		// Reset
                  MSTO_Current <= 1'b0;
            default :
               ;
         endcase
         
         // SCL rising edge flag	 
         case (MRE_Current)
            1'b0 :
               if (DetSCLRE == 1'b1)		// Set
                  MRE_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[2] == 1'b1 & iowe == 1'b1 & DetSCLRE == 1'b0)		// Reset
                  MRE_Current <= 1'b0;
            default :
               ;
         endcase
         
         // SCL falling edge flag	 
         case (MFE_Current)
            1'b0 :
               if (DetSCLFE == 1'b1)		// Set
                  MFE_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[3] == 1'b1 & iowe == 1'b1 & DetSCLFE == 1'b0)		// Reset
                  MFE_Current <= 1'b0;
            default :
               ;
         endcase
         
         // SCL length timer overflow flag
         case (MCO_Current)
            1'b0 :
               if (MBitRateCnt + 10'h1 == {TWPS_Current, TWBR})		// Set
                  MCO_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[4] == 1'b1 & iowe == 1'b1)		// Reset
                  MCO_Current <= 1'b0;
            default :
               ;
         endcase
         
         // Timeout 50 uS
         case (TOF_Current)
            1'b0 :
               if (RcSM_St2 == 1'b1 & TO50uS == 1'b1 & DetStart == 1'b0 & DetStop == 1'b0)		// Set
                  TOF_Current <= 1'b1;
            1'b1 :
               if (adr == SMBMSR_Address & dbus_in[5] == 1'b1 & iowe == 1'b1)		// Reset
                  TOF_Current <= 1'b0;
            default :
               ;
         endcase
         
         // SDA "sampler"
         if (DetSCLRE == 1'b1)		// Clock enable
            SDAS_Current <= SDASyncB;
      end
      
   end
   
   // SMBus master interrupt logic
   assign msmbirq = (MSTA_Current & MSTAIE) | 
                    (MSTO_Current & MSTOIE) | 
		    (MRE_Current &  MREIE) | 
		    (MFE_Current &  MFEIE) | 
		    (MCO_Current &  MCOIE) | 
		    (TOF_Current &  TOFIE);
   
   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Off State detector %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
   
   
   always @(negedge ireset or posedge cp2)
   begin: OffStDetCnt
      if (!ireset)		// Reset
      begin
         SMBOSCnt <= {CSMBOSCntWidth{1'b0}};
         
         // SMBOSR bits
         SMBOS_Current <= 1'b0;
         SMBOSC_Current <= 1'b0;
         SMBOIE_Current <= 1'b0;
      end
      
      else 		// Clock
      begin
         // Counter
         if (SDASyncB == 1'b1 | SCLSyncB == 1'b1)		// Clear counter
            SMBOSCnt <= {CSMBOSCntWidth{1'b0}};
         else
            SMBOSCnt <= SMBOSCnt + 1;		// Increment counter
         
         // SMBus Off State counter overflow flag
         case (SMBOS_Current)
            1'b0 :
               if (SMBOSCnt == CSMBOSCntOne)		// Set
                  SMBOS_Current <= 1'b1;
            1'b1 :
               if ((adr == SMBOSR_Address & dbus_in[0] == 1'b1 & iowe == 1'b1) | offstirq_ack == 1'b1)		// Reset  !!!TBD!!!
                  SMBOS_Current <= 1'b0;
            default :
               ;
         endcase
         
         // This flag indicates that SMBOSCnt was cleared 
         case (SMBOSC_Current)
            1'b0 :
               if (SDASyncB == 1'b1 | SCLSyncB == 1'b1)		// Set
                  SMBOSC_Current <= 1'b1;
            1'b1 :
               if (SDASyncB == 1'b0 & SCLSyncB == 1'b0 & adr == SMBOSR_Address & dbus_in[1] == 1'b1 & iowe == 1'b1)		// Reset
                  SMBOSC_Current <= 1'b0;
            default :
               ;
         endcase
         
         // Interrupt enable bit
         if (adr == SMBOSR_Address & iowe == 1'b1)
            SMBOIE_Current <= dbus_in[2];
      end
      
   end
   
   // Off State interrupt request
   assign offstirq = SMBOS_Current & SMBOIE_Current;
   
   // *************************************************************************************** 
   
   generate
      if (impl_pec)
      begin : SMBPECImplemented
         
         always @(negedge ireset or posedge cp2)
         begin: SMBPEC_Calculation
            if (!ireset)		// Reset
               SMBPEC_LFSR <= {8{1'b0}};
            else 		// Clock
            begin
               if (DetStart == 1'b1 | DetStop == 1'b1)
                  SMBPEC_LFSR <= {8{1'b0}};		// Clear
               else if ((RcSM_St1 == 1'b1 | RcSM_St3 == 1'b1) & DetSCLRE == 1'b1 & SCLCnt != 4'b1000)		// !!!TBD!!!
                  SMBPEC_LFSR <= fn_smb_pec(SMBPEC_LFSR, SDASyncB);
            end
         end
      end

      else // (impl_pec == 0)
      begin : SMBPECNotlemented
        // !!!TBD!!! 
	 always@(*) 
	  SMBPEC_LFSR = {8{1'b0}};
	  
      end
   endgenerate
   
   // *************************************************************************************** 
   
  // assign TWCR[5:2] = {4{1'b0}};
   assign TWCR[7:0] = {TWINT_Current,TWEA_Current,{4{1'b0}},EWS_Current,TWIE_Current};
   
  // assign TWSR[7:2] = {6{1'b0}};
   //assign SMBMSR[7] = 1'b0;
   assign SMBMSR = {1'b0,SDAS_Current,TOF_Current,MCO_Current,MFE_Current,MRE_Current,MSTO_Current,MSTA_Current};
   
   assign {TOFIE,TOE,MCOIE,MFEIE,MREIE,MSTOIE,MSTAIE} = SMBMCR_Current[6:0];
   
   assign SMBOSR[7:0] = {{5{1'b0}},SMBOIE_Current,SMBOSC_Current,SMBOS_Current}; // ??? Strange : WRITE ONLY REGISTER
   
   // Output multiplexer
   
   always @(*)
   begin: OutMuxComb
      case (adr)
         TWBR_Address :
            begin
               dbus_out = TWBR;
               out_en = iore;
            end
         TWDR_Address :		// Received data 
            begin
               dbus_out = ADInReg;
               out_en = iore;
            end
         TWAR_Address :		// Address
            begin
               dbus_out = TWAR;
               out_en = iore;
            end
         SMBMCR_Address :		// Extended Control	   
            begin
               dbus_out = {1'b0,SMBMCR_Current};
               out_en = iore;
            end
         SMBTOR_Address :		// !!!TBD!!! Timeout register    
            begin
               dbus_out = SMBTOR;
               out_en = iore;
            end
         SMBPEC_Address :
            begin
               dbus_out = SMBPEC_LFSR;
               out_en = iore;
            end
         TWCR_Address :		// Control    
            begin
               dbus_out = {TWCR[7:6], MSDASyncB, MSCLSyncB, TWCR[3:0]};
               out_en = iore;
            end
         TWSR_Address :		// Status  
            begin
               dbus_out = {SARF, SRNW, msdaen_int, msclen_int, WSP, Ack_Reg, TWPS_Current};
               out_en = iore;
            end
         SMBMSR_Address :		// Extended Status
            begin
               dbus_out = {nRcSM_St0, SMBMSR[6:0]};
               out_en = iore;
            end
         default :
            begin
               dbus_out = {8{1'b0}};
               out_en = 1'b0;
            end
      endcase
      end // OutMuxComb
      
      // Slave IRQ
      assign twiirq = TWINT_Current & TWIE_Current;
      
      // Outputs(slave)
      assign sdaen = sdaen_int;
      assign sclen = sclen_int;
      
      // Outputs(master)
      assign msdaen = (~msdaen_int);
      assign msclen = (~msclen_int);
      
      // Clock and Data lines may be '0' or 'Z' only 
      assign sdaout = 1'b0;
      assign sclout = 1'b0;
      
      assign msdaout = 1'b0;
      assign msclout = 1'b0;
      
endmodule
