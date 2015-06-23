//************************************************************************************************
// I/O Arbiter
// Version 0.9 
// Designed by Ruslan Lepetenok 
// Modified 09.01.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module io_arb_mux(
   c_adr,
   c_iore,
   c_iowe,
   c_ramre,
   c_ramwe,
   c_dbusout,
   d_adr,
   d_iore,
   d_iowe,
   d_dbusout,
   d_wait,
   adr,
   iore,
   iowe,
   dbusout
);
   // AVR Core
   input [5:0]  c_adr;
   input        c_iore;
   input        c_iowe;
   input        c_ramre;
   input        c_ramwe;
   input [7:0]  c_dbusout;
   // Debugger
   input [5:0]  d_adr;
   input        d_iore;
   input        d_iowe;
   input [7:0]  d_dbusout;
   output       d_wait;
   // I/O i/f
   output [5:0] adr;
   output       iore;
   output       iowe;
   output [7:0] dbusout;

//**********************************************************************************************
   
   assign adr = (c_iowe || c_iore) ? c_adr : d_adr;
   assign dbusout = (c_iowe) ? c_dbusout : d_dbusout;
   assign iowe = (c_iowe || c_iore || c_ramwe || c_ramre) ? c_iowe : d_iowe;
   assign iore = (c_iowe || c_iore || c_ramwe || c_ramre) ? c_iore : d_iore;
   assign d_wait = (c_iowe || c_iore || c_ramwe || c_ramre) ? 1'b1 : 1'b0;
   
endmodule // io_arb_mux
