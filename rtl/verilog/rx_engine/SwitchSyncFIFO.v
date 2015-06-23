//
// Module SwitchSyncFIFO
//
// the differences between this FIFO and the general one are listed below
//    1. because there is no any write and read acknowledgements, the user should take advantage of the status flags to generate the write and read requests.
//    2. after the full flag has been asserted, the word can not be written into the FIFO even if the reacd request is being asserted at the same cycle.
//
// Created:
//          by - Xinchun Liu
//          at - 2006-09-25
// History: 
//			2007-1-31 9:50		change iReset to nReset  Revised  By Wang Dawei wangdawei@ncic.ac.cn
//
`resetall
`timescale 1ns/10ps

module SwitchSyncFIFO (
	nReset,
	iClk,
	iWEn,
	ivDataIn,
	iREn,
	ovDataOut,
	qEmpty,
	qFull,
	qvCount
);

// Default address and data width
parameter   pDepthWidth = 5 ;                      
parameter   pWordWidth = 16 ;                      

input	nReset ;
input	iClk ;
input iWEn ;
input [pWordWidth-1:0]	ivDataIn ;
input	iREn ;
output   [pWordWidth-1:0]	ovDataOut ;
output   qEmpty ;
output	qFull ;
output   [pDepthWidth:0]	qvCount ;

wire	nReset ;
wire	iClk ;
wire	iWEn ;
wire  [pWordWidth-1:0]	ivDataIn ;
wire	iREn ;
wire  [pWordWidth-1:0]	ovDataOut_i ;
wire	qEmpty ;
wire	qFull ;
wire  [pDepthWidth:0]	qvCount ;

wire  MemWEn;
wire  MemREn;
wire  [pDepthWidth-1:0] vWriteAddr ;
wire  [pDepthWidth-1:0] vReadAddr ;

DualPortRAM #( pDepthWidth, pWordWidth )   Fifo_Storage                 	// Generic synchronous two-port RAM interface
   (
      .clock   ( iClk ) ,
      .MemWEn   ( MemWEn ) ,
      .qvWAddr   ( vWriteAddr ) ,
      .vDataIn		( ivDataIn ) ,
      .qvRAddr		( vReadAddr ) ,
      .vDataOut		( ovDataOut_i	)
   );


reg  [pWordWidth-1:0]	ovDataOut ;

always @ ( posedge iClk )
   if ( MemREn )
       ovDataOut <= ovDataOut_i ;
   else
       ovDataOut <= 0;
       
FifoControl #( pDepthWidth ) Fifo_Ctrl
   (
      .Reset   ( nReset ) ,
      .clock   ( iClk ) ,
      .iWEn   ( iWEn ) ,
      .MemWEn   ( MemWEn ) ,
      .MemREn   (MemREn),
      .qvWAddr   ( vWriteAddr ) ,
      .iREn		( iREn ) ,
      .qvRAddr   ( vReadAddr ) ,
      .qEmpty  ( qEmpty ) , 
      .qFull   ( qFull ) , 
      .qvCount ( qvCount )
   ) ;

endmodule
 
module FifoControl(
      Reset ,
      clock ,
      iWEn ,
      MemWEn ,
      MemREn,
      qvWAddr ,
      iREn ,
      qvRAddr ,
      qEmpty , 
      qFull , 
      qvCount
   ) ;

parameter   pDepthWidth = 5;		

input  Reset ;
input  clock ;
input  iWEn ;
output  MemWEn ;
output  MemREn ;
output  [pDepthWidth-1:0] qvWAddr ;
input  iREn ;
output  [pDepthWidth-1:0] qvRAddr ;
output  qEmpty ; 
output  qFull ;
output  [pDepthWidth:0] qvCount ;

wire  Reset ;
wire  clock ;
wire  iWEn ;
wire  MemWEn ;
reg  [pDepthWidth-1:0] qvWAddr ;
wire  iREn ;
reg  [pDepthWidth-1:0] qvRAddr ;
reg  qEmpty ; 
reg  qFull ;
reg  [pDepthWidth:0] qvCount ;

wire  MemREn ;

// write allow wire - writes are allowed when fifo is not full
// read  allow wire - reads  are allowed when fifo is not empty
assign MemWEn = iWEn && ( ~qFull ) ;
assign MemREn = iREn && ( ~qEmpty ) ;

// write address module
always @ ( posedge clock or negedge Reset) begin 
   if( ~Reset ) begin
  	 	qvWAddr <= 0 ;
	end
   else  begin
		if( MemWEn )   qvWAddr <= qvWAddr + 1'b1 ;
	end
end

// read address module
always @ ( posedge clock or negedge Reset) begin 
   if( ~Reset ) begin
  	 	qvRAddr <= 0 ;
	end
   else  begin
		if( MemREn )   qvRAddr <= qvRAddr + 1'b1 ;
	end
end

// flags module
always @ ( posedge clock or negedge Reset) begin 
   if( ~Reset ) begin
		qFull  <= 0 ;
		qEmpty   <= 1 ; 
		qvCount   <= 0 ; 
	end
   else  begin
		if( MemWEn )   begin
			if( qEmpty )   qEmpty <= 0 ;
			if ( ~MemREn ) begin
			   qvCount <= qvCount + 1'b1 ;
			   if( qvCount[pDepthWidth-1:0] == { pDepthWidth{1'b1} } )
			      qFull <= 1 ;
			end
		end
		else  begin
		   if( MemREn ) begin
		      qvCount <= qvCount - 1'b1 ;
				if( qvCount == 1'b1 )  qEmpty <= 1;
				if( qFull ) qFull <= 0;
			end
		end
	end
end

endmodule

//=============================================================================================================
 
module DualPortRAM
   (
      clock ,
      MemWEn ,
      qvWAddr ,
      vDataIn ,
      qvRAddr ,
      vDataOut
	);

// Default address and data width
parameter   pDepthWidth = 5 ;                      
parameter   pWordWidth = 16 ;                      

// Generic synchronous two-port RAM interface
input clock ;		// clock
input MemWEn ;	// write enable input
input [pDepthWidth-1:0] qvWAddr ;	// write address bus
input [pWordWidth-1:0]  vDataIn ;	// input data bus
input [pDepthWidth-1:0] qvRAddr ;	// read address bus
output   [pWordWidth-1:0]  vDataOut ;	// output data bus


// Generic two-port synchronous RAM model

// Generic RAM's registers and wires
reg   [pWordWidth-1:0]  mem[(1<<pDepthWidth)-1:0] /*synthesis syn_ramstyle="no_rw_check"*/; 

always @ ( posedge clock )
   if ( MemWEn )
		mem[qvWAddr] <= vDataIn ;

assign vDataOut = mem[qvRAddr] ;

endmodule 


///**********************************************************************
//						 FIFO						
///**********************************************************************