//**********************************************************************************************
// SPI Peripheral for the AVR Core
// Version 1.2
// Modified 10.01.2007
// Designed by Ruslan Lepetenok
// Internal resynchronizers for scki and ss_b inputs were added	
//**********************************************************************************************

`timescale 1 ns / 1 ns

module spi_mod(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en,
   misoi,
   mosii,
   scki,
   ss_b,
   misoo,
   mosio,
   scko,
   spe,
   spimaster,
   spiirq,
   spiack,
   por,
   spiextload,
   spidwrite,
   spiload
);



parameter SPCR_Address   = 6'h0D; // SPI Control Register
parameter SPSR_Address   = 6'h0E; // SPI Status Register
parameter SPDR_Address   = 6'h0F; // SPI I/O Data Register


   // AVR Control
   input               ireset;
   input               cp2;
   input [5:0]         adr;
   input [7:0]         dbus_in;
   output reg [7:0]    dbus_out;
   input               iore;
   input               iowe;
   output reg          out_en;
   // SPI i/f
   input               misoi;
   input               mosii;
   input               scki;		// Resynch
   input               ss_b;		// Resynch
   output reg          misoo;
   output reg          mosio;
   output reg          scko;
   output              spe;
   output              spimaster;
   // IRQ
   output              spiirq;
   input               spiack;
   // Slave Programming Mode
   input               por;
   input               spiextload;
   output              spidwrite;
   output              spiload;
   
   // Resynch
   wire                scki_resync;
   wire                ss_b_resync;
   
   // Registers
   reg [7:0]           SPCR;
   `define SPIE SPCR[7]
   `define SPEB SPCR[6]		// SPE in Atmel's doc
   `define DORD SPCR[5]
   `define MSTR SPCR[4]
   `define CPOL SPCR[3]
   `define CPHA SPCR[2]
   `define SPR SPCR[1:0]
   
//   wire [7:0]          SPSR;

//reg [7:0]          SPSR;
//   `define SPIF SPSR[7]
//   `define WCOL SPSR[6]
//   `define SPI2X SPSR[0]

reg SPIF_Current;
reg WCOL_Current;
reg SPI2X_Current;

   
   reg                 SPIE_Next;
   reg                 SPEB_Next;
   reg                 DORD_Next;
   reg                 CPOL_Next;
   reg                 CPHA_Next;
   reg [1:0]           SPR_Next;
   reg                 SPI2X_Next;
   
   reg [7:0]           SPDR_Rc;
   reg [7:0]           SPDR_Rc_Next;
   reg [7:0]           SPDR_Sh_Current;
   reg [7:0]           SPDR_Sh_Next;
   
   reg [5:0]           Div_Next;
   reg [5:0]           Div_Current;
   reg                 Div_Toggle;
   
   reg                 DivCntMsb_Current;
   reg                 DivCntMsb_Next;
   
   parameter [3:0]     MstSMSt_Type_MstSt_Idle = 0,
                       MstSMSt_Type_MstSt_B0 = 1,
                       MstSMSt_Type_MstSt_B1 = 2,
                       MstSMSt_Type_MstSt_B2 = 3,
                       MstSMSt_Type_MstSt_B3 = 4,
                       MstSMSt_Type_MstSt_B4 = 5,
                       MstSMSt_Type_MstSt_B5 = 6,
                       MstSMSt_Type_MstSt_B6 = 7,
                       MstSMSt_Type_MstSt_B7 = 8;
   reg [3:0]           MstSMSt_Current;
   reg [3:0]           MstSMSt_Next;
   
   wire                TrStart;
   
   reg                 scko_Next;
   reg                 scko_Current;		//!!!
   
   reg                 UpdRcDataRg_Current;
   reg                 UpdRcDataRg_Next;
   
   reg                 TmpIn_Current;
   reg                 TmpIn_Next;
   
   // Slave
   reg                 sck_EdgeDetDFF;
   wire                SlvSampleSt;
   
   wire                SlvSMChangeSt;
   
   parameter [3:0]     SlvSMSt_Type_SlvSt_Idle = 0,
                       SlvSMSt_Type_SlvSt_B0I = 1,
                       SlvSMSt_Type_SlvSt_B0 = 2,
                       SlvSMSt_Type_SlvSt_B1 = 3,
                       SlvSMSt_Type_SlvSt_B2 = 4,
                       SlvSMSt_Type_SlvSt_B3 = 5,
                       SlvSMSt_Type_SlvSt_B4 = 6,
                       SlvSMSt_Type_SlvSt_B5 = 7,
                       SlvSMSt_Type_SlvSt_B6 = 8,
                       SlvSMSt_Type_SlvSt_B6W = 9;
   reg [3:0]           SlvSMSt_Current;
   reg [3:0]           SlvSMSt_Next;
   
   // SIF clear SM
   reg                 SPIFClrSt_Current;
   reg                 SPIFClrSt_Next;
   
   // WCOL clear SM
   reg                 WCOLClrSt_Current;
   reg                 WCOLClrSt_Next;
   
   reg                 MSTR_Next;
   reg                 SPIF_Next;
   reg                 WCOL_Next;
   
   reg                 MstDSamp_Next;
   reg                 MstDSamp_Current;


   function[7:0] Fn_RevBitVector;
      input [7:0]        InVector;
      input  integer    Dummy_Agr;
   begin
      Fn_RevBitVector = {InVector[0],InVector[1],InVector[2],InVector[3],InVector[4],InVector[5],InVector[6],InVector[7]};
   end
   endfunction


   
   // ******************** Resynchronizers ************************************
   
   rsnc_bit #(.add_stgs_num(0), .inv_f_stgs(0)) scki_resync_inst(
      .clk(cp2),
      .di(scki),
      .do(scki_resync)
   );
   
   
   rsnc_bit #(.add_stgs_num(0), .inv_f_stgs(0)) ss_b_resync_inst(
      .clk(cp2),
      .di(ss_b),
      .do(ss_b_resync)
   );
   // ******************** Resynchronizers ************************************
   
  always @(negedge ireset or posedge cp2)
   begin: SeqPrc
      if (!ireset)		// Reset
      begin
         
         SPCR <= {8{1'b0}};
         
         SPIF_Current <= 1'b0;
         WCOL_Current <= 1'b0;
         SPI2X_Current <= 1'b0;
         
         Div_Current <= {6{1'b0}};
         DivCntMsb_Current <= 1'b0;
         
         MstSMSt_Current <= MstSMSt_Type_MstSt_Idle;
         SlvSMSt_Current <= SlvSMSt_Type_SlvSt_Idle;
         
         SPDR_Sh_Current <= {8{1'b1}};
         SPDR_Rc <= {8{1'b0}};
         
         sck_EdgeDetDFF <= 1'b0;
         SPIFClrSt_Current <= 1'b0;
         WCOLClrSt_Current <= 1'b0;
         
         scko <= 1'b0;
         scko_Current <= 1'b0;
         misoo <= 1'b0;
         mosio <= 1'b0;
         
         TmpIn_Current <= 1'b0;
         UpdRcDataRg_Current <= 1'b0;
         MstDSamp_Current <= 1'b0;
      end
      
      else 		// Clock
      begin
         
         `SPIE <= SPIE_Next;
         `SPEB <= SPEB_Next;
         `DORD <= DORD_Next;
         `CPOL <= CPOL_Next;
         `CPHA <= CPHA_Next;
         `SPR <= SPR_Next;
         
         `MSTR <= MSTR_Next;
         SPIF_Current <= SPIF_Next;
         SPI2X_Current <= SPI2X_Next;
         WCOL_Current <= WCOL_Next;
         
         Div_Current <= Div_Next;
         DivCntMsb_Current <= DivCntMsb_Next;
         MstSMSt_Current <= MstSMSt_Next;
         SlvSMSt_Current <= SlvSMSt_Next;
         SPDR_Sh_Current <= SPDR_Sh_Next;
         SPDR_Rc <= SPDR_Rc_Next;
         sck_EdgeDetDFF <= scki_resync;
         SPIFClrSt_Current <= SPIFClrSt_Next;
         WCOLClrSt_Current <= WCOLClrSt_Next;
         
         scko_Current <= scko_Next;
         scko <= scko_Next;
         misoo <= SPDR_Sh_Next[7];
         mosio <= SPDR_Sh_Next[7];
         
         TmpIn_Current <= TmpIn_Next;
         UpdRcDataRg_Current <= UpdRcDataRg_Next;
         MstDSamp_Current <= MstDSamp_Next;
      end
      
   end // SeqPrc 

   
   
   always @(adr or iowe or SPCR or SPIF_Current or WCOL_Current or SPI2X_Current or dbus_in)
   begin: IORegWriteComb
      
      SPIE_Next = `SPIE;
      SPEB_Next = `SPEB;
      DORD_Next = `DORD;
      CPOL_Next = `CPOL;
      CPHA_Next = `CPHA;
      SPR_Next = `SPR;
      SPI2X_Next = SPI2X_Current;
      
      if (adr == SPCR_Address && iowe)
      begin
         SPIE_Next = dbus_in[7];
         SPEB_Next = dbus_in[6];
         DORD_Next = dbus_in[5];
         CPOL_Next = dbus_in[3];
         CPHA_Next = dbus_in[2];
         SPR_Next = dbus_in[1:0];
      end
      
      if (adr == SPSR_Address && iowe)
         SPI2X_Next = dbus_in[0];
      
   end
   
 //  rle  
 //  assign SPSR[5:1] = {5{1'b0}};
   
   // Divider
   // SPI2X | SPR1 | SPR0 | SCK Frequency
   //   0   |  0   |   0  | fosc /4       (2)
   //   0   |  0   |   1  | fosc /16	   (8)
   //   0   |  1   |   0  | fosc /64	   (32)
   //   0   |  1   |   1  | fosc /128	   (64)
   // ------+------+------+-------------
   //   1   |  0   |   0  | fosc /2	   (1)
   //   1   |  0   |   1  | fosc /8	   (4)
   //   1   |  1   |   0  | fosc /32	   (16)
   //   1   |  1   |   1  | fosc /64	   (32)
   
   
   always @(MstSMSt_Current or Div_Current or SPCR or SPIF_Current or WCOL_Current or SPI2X_Current)
   begin: DividerToggleComb
      Div_Toggle = 1'b0;
      if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle)
      begin
         if (SPI2X_Current == 1'b1)		// Extended mode
            case (`SPR)
               2'b00 :		// fosc /2
                  if (Div_Current == 6'b000001)
                     Div_Toggle = 1'b1;
               2'b01 :		// fosc /8
                  if (Div_Current == 6'b000011)
                     Div_Toggle = 1'b1;
               2'b10 :		// fosc /32
                  if (Div_Current == 6'b001111)
                     Div_Toggle = 1'b1;
               2'b11 :		// fosc /64
                  if (Div_Current == 6'b011111)
                     Div_Toggle = 1'b1;
               default :
                  Div_Toggle = 1'b0;
            endcase
         else
            // Normal mode
            case (`SPR)
               2'b00 :		// fosc /4	  
                  if (Div_Current == 6'b000001)
                     Div_Toggle = 1'b1;
               2'b01 :		// fosc /16
                  if (Div_Current == 6'b000111)
                     Div_Toggle = 1'b1;
               2'b10 :		// fosc /64
                  if (Div_Current == 6'b011111)
                     Div_Toggle = 1'b1;
               2'b11 :		// fosc /128
                  if (Div_Current == 6'b111111)
                     Div_Toggle = 1'b1;
               default :
                  Div_Toggle = 1'b0;
            endcase
      end
   end
   
   
   always @(MstSMSt_Current or Div_Current or DivCntMsb_Current or Div_Toggle)
   begin: DividerNextComb
      Div_Next = Div_Current;
      DivCntMsb_Next = DivCntMsb_Current;
      if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle)
      begin
         if (Div_Toggle == 1'b1)
         begin
            Div_Next = {6{1'b0}};
            DivCntMsb_Next = (~DivCntMsb_Current);
         end
         else
            Div_Next = Div_Current + 1;
      end
      
   end
   
   assign TrStart = ((adr == SPDR_Address & iowe == 1'b1 & `SPEB == 1'b1)) ? 1'b1 : 1'b0;
   
   // Transmitter Master Mode Shift Control SM
   
   always @(MstSMSt_Current or DivCntMsb_Current or Div_Toggle or TrStart or SPCR)
   begin: MstSmNextComb
      MstSMSt_Next = MstSMSt_Current;
      case (MstSMSt_Current)
         MstSMSt_Type_MstSt_Idle :
            if (TrStart == 1'b1 & `MSTR == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B0;
         MstSMSt_Type_MstSt_B0 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B1;
         MstSMSt_Type_MstSt_B1 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B2;
         MstSMSt_Type_MstSt_B2 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B3;
         MstSMSt_Type_MstSt_B3 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B4;
         MstSMSt_Type_MstSt_B4 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B5;
         MstSMSt_Type_MstSt_B5 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B6;
         MstSMSt_Type_MstSt_B6 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_B7;
         MstSMSt_Type_MstSt_B7 :
            if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1)
               MstSMSt_Next = MstSMSt_Type_MstSt_Idle;
         default :
            MstSMSt_Next = MstSMSt_Type_MstSt_Idle;
      endcase
   end
   
   
   always @(SPIFClrSt_Current or SPCR or SPIF_Current or WCOL_Current or SPI2X_Current or adr or iore or iowe)
   begin: SPIFClrCombProc
      SPIFClrSt_Next = SPIFClrSt_Current;
      case (SPIFClrSt_Current)
         1'b0 :
            if (adr == SPSR_Address & iore == 1'b1 & SPIF_Current == 1'b1 & `SPEB == 1'b1)
               SPIFClrSt_Next = 1'b1;
         1'b1 :
            if (adr == SPDR_Address & (iore == 1'b1 | iowe == 1'b1))
               SPIFClrSt_Next = 1'b0;
         default :
            SPIFClrSt_Next = SPIFClrSt_Current;
      endcase
      end  //SPIFClrCombProc
      
      
      always @(WCOLClrSt_Current or SPIF_Current or WCOL_Current or SPI2X_Current or adr or iore or iowe)
      begin: WCOLClrCombProc
         WCOLClrSt_Next = WCOLClrSt_Current;
         case (WCOLClrSt_Current)
            1'b0 :
               if (adr == SPSR_Address & iore == 1'b1 & WCOL_Current == 1'b1)
                  WCOLClrSt_Next = 1'b1;
            1'b1 :
               if (adr == SPDR_Address & (iore == 1'b1 | iowe == 1'b1))
                  WCOLClrSt_Next = 1'b0;
            default :
               WCOLClrSt_Next = WCOLClrSt_Current;
         endcase
         end //WCOLClrCombProc
         
         
         always @(SPCR or scko_Current or scko_Next or MstDSamp_Current or MstSMSt_Current)
         begin: MstDataSamplingComb
            MstDSamp_Next = 1'b0;
            case (MstDSamp_Current)
               1'b0 :
                  if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle)
                  begin
                     if (`CPHA == `CPOL)
                     begin
                        if (scko_Next == 1'b1 & scko_Current == 1'b0)		// Rising edge 	  
                           MstDSamp_Next = 1'b1;
                     end
                     else
                        // CPHA/=CPOL
                        if (scko_Next == 1'b0 & scko_Current == 1'b1)		// Falling edge 	  
                           MstDSamp_Next = 1'b1;
                  end
               1'b1 :
                  MstDSamp_Next = 1'b0;
               default :
                  MstDSamp_Next = 1'b0;
            endcase
            end // MstDataSamplingComb
            
            //
            
            always @(UpdRcDataRg_Current or MstSMSt_Current or MstSMSt_Next or SlvSMSt_Current or SlvSMSt_Next or SPCR)
            begin: DRLatchComb
               UpdRcDataRg_Next = 1'b0;
               case (UpdRcDataRg_Current)
                  1'b0 :
                     if ((`MSTR == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle) | (`MSTR == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMSt_Next == SlvSMSt_Type_SlvSt_Idle))
                        UpdRcDataRg_Next = 1'b1;
                  1'b1 :
                     UpdRcDataRg_Next = 1'b0;
                  default :
                     UpdRcDataRg_Next = 1'b0;
               endcase
            end
            
            
            always @(TmpIn_Current or mosii or misoi or MstDSamp_Current or SlvSampleSt or SPCR or ss_b_resync)
            begin: TmpInComb
               TmpIn_Next = TmpIn_Current;
               if (`MSTR == 1'b1 & MstDSamp_Current == 1'b1)		// Master mode
                  TmpIn_Next = misoi;
               else if (`MSTR == 1'b0 & SlvSampleSt == 1'b1 & ss_b_resync == 1'b0)		// Slave mode ???
                  TmpIn_Next = mosii;
            end
            
            
            always @(MstSMSt_Current or SlvSMSt_Current or SPDR_Sh_Current or SPCR or DivCntMsb_Current or Div_Toggle or TrStart or dbus_in or ss_b_resync or TmpIn_Current or SlvSMChangeSt or SlvSampleSt or UpdRcDataRg_Current)
            begin: ShiftRgComb
               SPDR_Sh_Next = SPDR_Sh_Current;
               if (TrStart == 1'b1 & (MstSMSt_Current == MstSMSt_Type_MstSt_Idle & SlvSMSt_Current == SlvSMSt_Type_SlvSt_Idle & (~(`MSTR == 1'b0 & SlvSampleSt == 1'b1 & ss_b_resync == 1'b0))))		// Load
               begin
                  if (`DORD == 1'b1)		// the LSB of the data word is transmitted first
                     SPDR_Sh_Next = Fn_RevBitVector(dbus_in, 8);
                  else
                     // the MSB of the data word is transmitted first
                     SPDR_Sh_Next = dbus_in;
               end
               else if (`MSTR == 1'b1 & UpdRcDataRg_Current == 1'b1)		// ???
                  SPDR_Sh_Next[7] = 1'b1;
               else if ((`MSTR == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) | (`MSTR == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMChangeSt == 1'b1 & ss_b_resync == 1'b0))
                  // Shift
                  SPDR_Sh_Next = {SPDR_Sh_Current[7 - 1:0], TmpIn_Current};
               end //ShiftRgComb
               
               
               always @(scko_Current or SPCR or adr or iowe or dbus_in or DivCntMsb_Next or DivCntMsb_Current or TrStart or MstSMSt_Current or MstSMSt_Next)
               begin: sckoGenComb
                  scko_Next = scko_Current;
                  if (adr == SPCR_Address & iowe == 1'b1)		// Write to SPCR
                     scko_Next = dbus_in[3];		// CPOL
                  else if (TrStart == 1'b1 & `CPHA == 1'b1 & MstSMSt_Current == MstSMSt_Type_MstSt_Idle)
                     scko_Next = (~`CPOL);
                  else if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle)		// "Parking"
                     scko_Next = `CPOL;
                  else if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle & DivCntMsb_Current != DivCntMsb_Next)
                     scko_Next = (~scko_Current);
               end
               
               // Receiver data register
               
               always @(SPDR_Rc or SPCR or SPDR_Sh_Current or UpdRcDataRg_Current or TmpIn_Current)
               begin: SPDRRcComb
                  SPDR_Rc_Next = SPDR_Rc;
                  if (UpdRcDataRg_Current == 1'b1)
                  begin
                     if (`MSTR == 1'b0 & `CPHA == 1'b1)
                     begin
                        if (`DORD == 1'b1)		// the LSB of the data word is transmitted first
                           SPDR_Rc_Next = Fn_RevBitVector({SPDR_Sh_Current[7 - 1:0], TmpIn_Current}, 2);
                        else
                           // the MSB of the data word is transmitted first
                           SPDR_Rc_Next = {SPDR_Sh_Current[7 - 1:0], TmpIn_Current};
                     end
                     else
                        if (`DORD == 1'b1)		// the LSB of the data word is transmitted first
                           SPDR_Rc_Next = Fn_RevBitVector(SPDR_Sh_Current, 8);
                        else
                           // the MSB of the data word is transmitted first
                           SPDR_Rc_Next = SPDR_Sh_Current;
                  end
               end
               
               //****************************************************************************************			
               // Slave
               //****************************************************************************************
               
               // Rising edge 
               assign SlvSampleSt = (((sck_EdgeDetDFF == 1'b0 & scki_resync == 1'b1 & `CPOL == `CPHA) | (sck_EdgeDetDFF == 1'b1 & scki_resync == 1'b0 & `CPOL != `CPHA))) ? 1'b1 : 		// Falling edge
                                    1'b0;
               
               // Falling edge 
               assign SlvSMChangeSt = (((sck_EdgeDetDFF == 1'b1 & scki_resync == 1'b0 & `CPOL == `CPHA) | (sck_EdgeDetDFF == 1'b0 & scki_resync == 1'b1 & `CPOL != `CPHA))) ? 1'b1 : 		// Rising edge
                                      1'b0;
               
               // Slave Master Mode Shift Control SM
               
               always @(SlvSMSt_Current or SPCR or SlvSampleSt or SlvSMChangeSt or ss_b_resync)
               begin: SlvSMNextComb
                  SlvSMSt_Next = SlvSMSt_Current;
                  if (ss_b_resync == 1'b0)
                     case (SlvSMSt_Current)
                        SlvSMSt_Type_SlvSt_Idle :
                           
                           if (`MSTR == 1'b0)
                           begin
                              if (`CPHA == 1'b1)
                              begin
                                 if (SlvSMChangeSt == 1'b1)
                                    SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0;
                              end
                              else
                                 //	CPHA='0'
                                 if (SlvSampleSt == 1'b1)
                                    SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0I;
                           end
                        
                        SlvSMSt_Type_SlvSt_B0I :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0;
                        
                        SlvSMSt_Type_SlvSt_B0 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B1;
                        SlvSMSt_Type_SlvSt_B1 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B2;
                        SlvSMSt_Type_SlvSt_B2 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B3;
                        SlvSMSt_Type_SlvSt_B3 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B4;
                        SlvSMSt_Type_SlvSt_B4 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B5;
                        SlvSMSt_Type_SlvSt_B5 :
                           if (SlvSMChangeSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_B6;
                        
                        SlvSMSt_Type_SlvSt_B6 :
                           if (SlvSMChangeSt == 1'b1)
                           begin
                              if (`CPHA == 1'b0)
                                 SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
                              else
                                 // CPHA='1'
                                 SlvSMSt_Next = SlvSMSt_Type_SlvSt_B6W;
                           end
                        
                        SlvSMSt_Type_SlvSt_B6W :
                           if (SlvSampleSt == 1'b1)
                              SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
                        default :
                           SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
                     endcase
               end
               
               
               always @(adr or iowe or dbus_in or ss_b_resync or SPCR)
               begin: MSTRGenComb
                  MSTR_Next = `MSTR;
                  case (`MSTR)
                     1'b0 :
                        if (adr == SPCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b1)		// TBD (ss_b_resync='0')
                           MSTR_Next = 1'b1;
                     1'b1 :
                        if ((adr == SPCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b0) | (ss_b_resync == 1'b0))
                           MSTR_Next = 1'b0;
                     default :
                        MSTR_Next = `MSTR;
                  endcase
               end
               
               
               always @(WCOLClrSt_Current or SlvSMSt_Current or MstSMSt_Current or adr or iowe or iore or SPCR or SPIF_Current or WCOL_Current or SPI2X_Current or SlvSampleSt or ss_b_resync)
               begin: WCOLGenComb
                  WCOL_Next = WCOL_Current;
                  case (WCOL_Current)
                     1'b0 :
                        if (adr == SPDR_Address & iowe == 1'b1 & ((`MSTR == 1'b0 & (SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle | (SlvSampleSt == 1'b1 & ss_b_resync == 1'b0))) | (`MSTR == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle)))
                           WCOL_Next = 1'b1;
                     1'b1 :
                        if (((adr == SPDR_Address & (iowe == 1'b1 | iore == 1'b1)) & WCOLClrSt_Current == 1'b1) & (~(adr == SPDR_Address & iowe == 1'b1 & ((`MSTR == 1'b0 & (SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle | (SlvSampleSt == 1'b1 & ss_b_resync == 1'b0))) | (`MSTR == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle)))))
                           WCOL_Next = 1'b0;
                     default :
                        WCOL_Next = WCOL_Current;
                  endcase
               end
               
               
               always @(SPIFClrSt_Current or adr or iowe or iore or SPCR or SPIF_Current or WCOL_Current or SPI2X_Current or SlvSMSt_Current or SlvSMSt_Next or MstSMSt_Current or MstSMSt_Next or spiack)
               begin: SPIFGenComb
                  SPIF_Next = SPIF_Current;
                  case (SPIF_Current)
                     1'b0 :
                        if ((`MSTR == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMSt_Next == SlvSMSt_Type_SlvSt_Idle) | (`MSTR == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle))
                           SPIF_Next = 1'b1;
                     1'b1 :
                        if ((adr == SPDR_Address & (iowe == 1'b1 | iore == 1'b1) & SPIFClrSt_Current == 1'b1) | spiack == 1'b1)
                           SPIF_Next = 1'b0;
                     default :
                        SPIF_Next = SPIF_Current;
                  endcase
               end
               
               //*************************************************************************************
               
               assign spimaster = `MSTR;
               assign spe = `SPEB;
               
               // IRQ
               assign spiirq = `SPIE & SPIF_Current;
               
               
               always @(adr or iore or SPDR_Rc or SPIF_Current or WCOL_Current or SPI2X_Current or SPCR)
               begin: OutMuxComb
                  case (adr)
                     SPDR_Address :
                        begin
                           dbus_out = SPDR_Rc;
                           out_en = iore;
                        end
                     SPSR_Address :
                        begin
                           dbus_out = {SPIF_Current, WCOL_Current, {5{1'b0}},SPI2X_Current}; // SPSR -> !!!!!!!!
                           out_en = iore;
                        end
                     SPCR_Address :
                        begin
                           dbus_out = SPCR;
                           out_en = iore;
                        end
                     default :
                        begin
                           dbus_out = {8{1'b0}};
                           out_en = 1'b0;
                        end
                  endcase
                  end // OutMuxComb
                  
                  //			
                  assign spidwrite = 1'b0;
                  assign spiload = 1'b0;
	          
endmodule // spi_mod
