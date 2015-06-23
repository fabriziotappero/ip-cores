//
// Module SwitchAsyncFIFO
//
// the differences between this FIFO and the general one are listed below
//    1. because there is no any write and read acknowledgements, the user should take advantage of the status flags to generate the write and read requests.
//    2. after the qWFull flag has been asserted, the word can not be written into the FIFO.
//    3. after the qREmpty flag has been asserted, the data can not be read out from the FIFO.
//    4. 2 flip-flops are used to re-synchronize the addresses of the different clock domains.
//    5. to decrease 1 clock, the negedge of the clock is utilized by the 1st flip-flop.
//    6. to provide guaranteed free space information, the qRNumberLeft has been subtracted 4.
//
// Created:
//          by - Xinchun Liu
//          at - 2006-09-27
//
// revised:
//          by - Xinchun Liu
//          at - 2007-05-15
//    1. to decrease the clock to output time, a output register has been added.
//    2. 1 cycle latency has been added to the output data and empty flag.
//
`resetall
`timescale 1ns/10ps

module SwitchAsyncFIFO
(
   inReset,
   iWClk,
   iWEn,
   ivDataIn,
   qWFull,
   qvWCount,
   iRClk,
   iREn,
   ovDataOut,
   qREmpty,
   qvRNumberLeft
);

// Default address and data width
parameter   pDepthWidth = 5 ;
parameter   pWordWidth = 16 ;

input   inReset ;
input   iWClk ;
input iWEn ;
input [pWordWidth-1:0]   ivDataIn ;
output   qWFull ;
output   [pDepthWidth:0]   qvWCount ;
input   iRClk ;
input   iREn ;
output   [pWordWidth-1:0]   ovDataOut ;
output   qREmpty ;
output   [pDepthWidth:0]   qvRNumberLeft ;

wire   inReset ;
wire   iWClk ;
wire   iWEn ;
wire  [pWordWidth-1:0]   ivDataIn ;
wire   qWFull ;
wire  [pDepthWidth:0]   qvWCount ;
wire   iRClk ;
wire   iREn ;
wire  [pWordWidth-1:0]   ovDataOut ;
wire   qREmpty ;
wire  [pDepthWidth:0]   qvRNumberLeft ;

wire  MemWEn;
wire  [pDepthWidth-1:0] vWriteAddr ;
wire  [pDepthWidth-1:0] vReadAddr ;
wire   [pWordWidth-1:0] MemDataOut ;

DualPortRAM_ASYN #( pDepthWidth, pWordWidth ) Fifo_Storage
   (
      // Generic synchronous two-port RAM interface
      .WriteClock    ( iWClk ),
      .MemWEn        ( MemWEn ),
      .MemWAddr      ( vWriteAddr ),
      .MemDataIn     ( ivDataIn ),
      .ReadClock     ( iRClk ),
      .MemRAddr      ( vReadAddr ),
      .MemDataOut    ( MemDataOut )
    );

FifoControl_ASYN #( pDepthWidth, pWordWidth ) Fifo_Controller
   (
      .inReset       ( inReset ) ,
      .WriteClock    ( iWClk ) ,
      .iWEn          ( iWEn ) ,
      .MemWEn        ( MemWEn ) ,
      .vWAddr        ( vWriteAddr ) ,
      .qWFull        ( qWFull ) , 
      .qvWCount      ( qvWCount ) ,
      .ReadClock     ( iRClk ) ,
      .iREn          ( iREn ) ,
      .vRAddr        ( vReadAddr ) ,
      .qREmpty       ( qREmpty ) , 
      .MemDataOut    ( MemDataOut ),
      .qvDataOut     ( ovDataOut ),
      .qvRNumberLeft ( qvRNumberLeft )
   ) ;

endmodule

module FifoControl_ASYN
(
   inReset ,
   WriteClock ,
   iWEn ,
   MemWEn ,
   vWAddr ,
   qWFull , 
   qvWCount ,
   ReadClock ,
   iREn ,
   vRAddr ,
   qREmpty , 
   MemDataOut , 
   qvDataOut , 
   qvRNumberLeft
);

// Default address and data width
parameter   pDepthWidth = 5 ;
parameter   pWordWidth = 16 ;

input  inReset ;
input  WriteClock ;
input  iWEn ;
output  MemWEn ;
output  [pDepthWidth-1:0] vWAddr ;
output  qWFull ;
output  [pDepthWidth:0] qvWCount ;
input   ReadClock ;
input   iREn ;
output  [pDepthWidth-1:0] vRAddr ;
output  qREmpty ; 
input   [pWordWidth-1:0]  MemDataOut ;
output  [pWordWidth-1:0]  qvDataOut ;
output  [pDepthWidth:0]   qvRNumberLeft ;

wire  inReset ;
wire  WriteClock ;
wire  iWEn ;
wire  MemWEn ;
wire  [pDepthWidth-1:0] vWAddr ;
reg   qWFull ;
reg   [pDepthWidth:0]   qvWCount ;
wire  ReadClock ;
wire  iREn ;
wire  [pDepthWidth-1:0] vRAddr ;
reg   qREmpty ; 
wire  [pWordWidth-1:0]  MemDataOut ;
reg   [pWordWidth-1:0]  qvDataOut ;
reg   [pDepthWidth:0]   qvRNumberLeft ;

// internal variables
   // write clock domain
reg  [pDepthWidth:0] qvWAddr ;
reg  [pDepthWidth:0] qvNextWAddr ;
reg  [pDepthWidth:0] qvPreWGrayAddr ;
reg  [pDepthWidth:0] qvWGrayAddr ;
reg  [pDepthWidth:0] qvRGrayAddr_WSync1 ;
reg  [pDepthWidth:0] qvRGrayAddr_WSync2 ;
reg  [pDepthWidth:0] qvRAddr_WSync2 ;
   // read clock domain
reg  [pDepthWidth:0] qvRAddr ;
reg  [pDepthWidth:0] qvNextRAddr ;
reg  [pDepthWidth:0] qvRGrayAddr ;
reg  [pDepthWidth:0] qvPreWGrayAddr_RSync1 ;
reg  [pDepthWidth:0] qvPreWGrayAddr_RSync2 ;
reg  [pDepthWidth:0] qvPreWAddr_RSync2 ;
reg  [pDepthWidth:0] qvWGrayAddr_RSync1 ;
reg  [pDepthWidth:0] qvWGrayAddr_RSync2 ;
reg  [pDepthWidth:0] qvPointerForNumLeft ;
reg  [pDepthWidth:0] qvNextPointerForNumLeft ;

reg   qREmpty_int ;
wire  MemREn ;

assign MemREn = !qREmpty_int && ( qREmpty || iREn ) ;
assign MemWEn = iWEn && ( !qWFull ) ;
assign vWAddr = qvWAddr[pDepthWidth-1:0] ;
assign vRAddr = MemREn ? qvNextRAddr[pDepthWidth-1:0] : qvRAddr[pDepthWidth-1:0] ;

// logic
integer i;

// write clock domain
   // write address
always @ ( negedge inReset or posedge WriteClock )
begin
   if( !inReset ) begin
      qvWAddr <= 1 ;
      qvNextWAddr <= 2 ;
      qvPreWGrayAddr <= 0 ;
      qvWGrayAddr <= 1 ;
   end
   else  if( MemWEn )   begin
      qvWAddr <= qvNextWAddr ;
      qvNextWAddr <= qvNextWAddr + 1'b1 ;
      qvPreWGrayAddr <= qvWGrayAddr ;
      qvWGrayAddr <= ( qvNextWAddr >> 1 ) ^ qvNextWAddr ;
//      qvPreWGrayAddr <= ( qvWAddr >> 1 ) ^ qvWAddr ;
   end
end
   // re-synchronize the read addresses within write clock domain
      // the 1st synchronizing cycle
always @ ( negedge inReset or posedge WriteClock )  begin
   if( !inReset ) begin
      qvRGrayAddr_WSync1 <= 1 ;
   end
   else  begin
      qvRGrayAddr_WSync1 <= qvRGrayAddr ;
   end
end
      // the 2nd synchronizing cycle
always @ ( negedge inReset or posedge WriteClock )  begin
   if( !inReset ) begin   
      qvRGrayAddr_WSync2 <= 1 ;
   end
   else  begin
      qvRGrayAddr_WSync2 <= qvRGrayAddr_WSync1 ;
   end
end

   //   to calculate the read address in write clock domain
always @ ( negedge inReset or posedge WriteClock )  begin   // 1 cycle delay will be added
   if( !inReset ) begin   
      qvRAddr_WSync2 <= 1 ;
   end
   else  begin
      for( i=0; i<=pDepthWidth; i=i+1 )
         qvRAddr_WSync2[i] <= ^( qvRGrayAddr_WSync2 >>i ) ;   // Gray To Binary Conversion
   end
end

//always @ ( qvRGrayAddr_WSync2 )   // Gray To Binary Conversion
//   for( i=0; i<=pDepthWidth; i=i+1 )
//      qvRAddr_WSync2[i] = ^( qvRGrayAddr_WSync2 >>i ) ;

   // calculates qvWCount 
always @ ( negedge inReset or posedge WriteClock )  begin
   if( !inReset ) begin   
      qvWCount <= 0 ;
   end
   else  begin
      if( MemWEn )
         qvWCount <= qvNextWAddr - qvRAddr_WSync2 ;
      else
         qvWCount <= qvWAddr - qvRAddr_WSync2 ; 
   end            
end

   // generates qWFull
always @ ( qvWCount[pDepthWidth] )
   qWFull <= qvWCount[pDepthWidth] ;

// read clock domain
   // read address
always @ ( negedge inReset or posedge ReadClock )
begin
   if( !inReset ) begin
      qvRAddr <= 1 ;
      qvNextRAddr <= 2 ;
      qvRGrayAddr <= 1 ;
      qvPointerForNumLeft <= { 1'b1, {pDepthWidth{1'b0}} } ;
      qvNextPointerForNumLeft <= { 1'b1, {(pDepthWidth-1){1'b0}}, 1'b1 } ;
   end
   else  if( MemREn )   begin
      qvRAddr <= qvNextRAddr ;
      qvNextRAddr <= qvNextRAddr + 1'b1 ;
      qvRGrayAddr <= ( qvNextRAddr >> 1 ) ^ qvNextRAddr ;
      qvNextPointerForNumLeft <= qvNextPointerForNumLeft + 1'b1 ;
      qvPointerForNumLeft <= qvNextPointerForNumLeft ;
//      qvPointerForNumLeft <= qvPointerForNumLeft + 1'b1 ;
    end
end
   // re-synchronize the write addresses within read clock domain
      // the 1st synchronizing cycle
always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qvPreWGrayAddr_RSync1 <= 0 ;
      qvWGrayAddr_RSync1 <= 1 ;
   end
   else  begin
      qvPreWGrayAddr_RSync1 <= qvPreWGrayAddr ;
      qvWGrayAddr_RSync1 <= qvWGrayAddr ;
   end
end
      // the 2nd synchronizing cycle
always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qvPreWGrayAddr_RSync2 <= 0 ;
      qvWGrayAddr_RSync2 <= 1 ;
   end
   else  begin
      qvPreWGrayAddr_RSync2 <= qvPreWGrayAddr_RSync1 ;
      qvWGrayAddr_RSync2 <= qvWGrayAddr_RSync1 ;
   end
end

   //   to calculate the write address in read clock domain
always @ ( negedge inReset or posedge ReadClock )  begin   // 1 cycle delay will be added
   if( !inReset ) begin   
      qvPreWAddr_RSync2 <= 0 ;
   end
   else  begin
      for( i=0; i<=pDepthWidth; i=i+1 )
         qvPreWAddr_RSync2[i] <= ^( qvPreWGrayAddr_RSync2 >>i ) ;   // Gray To Binary Conversion
   end
end
//always @ ( qvPreWGrayAddr_RSync2 )   // Gray To Binary Conversion
//   for( i=0; i<=pDepthWidth; i=i+1 )
//      qvWAddr_RSync2[i] <= ^( qvPreWGrayAddr_RSync2 >>i ) ;   // Gray To Binary Conversion

   // calculates qvRNumberLeft
reg  [pDepthWidth:0] qvRNumberLeft_int ;
always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qvRNumberLeft_int <= { 1'b1, {pDepthWidth{1'b0}} } ;
   end
   else  begin
      if( MemREn )
         qvRNumberLeft_int <= qvNextPointerForNumLeft - qvPreWAddr_RSync2 ;
      else
         qvRNumberLeft_int <= qvPointerForNumLeft - qvPreWAddr_RSync2 ; 
   end            
end

always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qvRNumberLeft <= { 1'b1, {pDepthWidth{1'b0}} } ;
   end
   else  begin
      if( qvRNumberLeft_int >= 4 )  qvRNumberLeft <= qvRNumberLeft_int - 4 ; 
      else  qvRNumberLeft <= 0 ; 
   end            
end

   // generates qREmpty_int
always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qREmpty_int <= 1 ;
   end
   else  begin
      if( ~qREmpty_int ) begin
         if( MemREn && ( qvRGrayAddr == qvPreWGrayAddr_RSync2 ) )
            qREmpty_int <= 1 ;
      end
       else  begin
          if( qvRGrayAddr != qvWGrayAddr_RSync2 )
             qREmpty_int <= 0 ; 
      end
   end            
end

//always @ ( qvRNumberLeft_int[pDepthWidth] )
//   qREmpty_int <= qvRNumberLeft_int[pDepthWidth] ;

always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qREmpty <= 1'b1 ;
   end
   else  begin
      if( qREmpty )  begin
         if( !qREmpty_int )   qREmpty <= 1'b0 ; 
      end 
      else
         if( qREmpty_int && iREn )   qREmpty <= 1'b1 ; 
   end            
end

always @ ( negedge inReset or posedge ReadClock )  begin
   if( !inReset ) begin   
      qvDataOut <= {pWordWidth{1'b0}} ;
   end
   else  begin
      if( MemREn )  begin
         qvDataOut <= MemDataOut ;
      end 
   end            
end

endmodule
 

module DualPortRAM_ASYN
   (
      // Generic synchronous two-port RAM interface
   WriteClock ,
   MemWEn ,
   MemWAddr ,
   MemDataIn ,
   ReadClock ,
   MemRAddr ,
   MemDataOut 
    );

// Default address and data width
parameter   pDepthWidth = 5 ;                      
parameter   pWordWidth = 16 ;                      

// Generic synchronous two-port RAM interface
input WriteClock ;
input MemWEn ;
input MemWAddr ;
input MemDataIn ;
input ReadClock ;
input  [pDepthWidth-1:0] MemRAddr ;
output  [pWordWidth-1:0] MemDataOut ;

wire  WriteClock ;
wire  MemWEn ;
wire  [pDepthWidth-1:0] MemWAddr ;
wire  [pWordWidth-1:0] MemDataIn ;
wire  ReadClock ;
wire  [pDepthWidth-1:0] MemRAddr ;
wire  [pWordWidth-1:0] MemDataOut ;

reg   [pWordWidth-1:0]  mem [(1<<pDepthWidth)-1:0] /*synthesis syn_ramstyle="no_rw_check"*/; 

// RAM read and write
// a port for write
always @ ( posedge WriteClock )
   if( MemWEn )
      mem[MemWAddr] <= MemDataIn ;

// RAM read and write
//b for read

/* registered address */
reg   [pDepthWidth-1:0] qvRAddr ;
always @ ( posedge ReadClock )
   qvRAddr <= MemRAddr ;   

assign MemDataOut = mem[qvRAddr] ;

endmodule 
