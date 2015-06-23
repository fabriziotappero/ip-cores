// ===========================================================================
// File    : ti_phy_top.v
// Author  : cmagleby
// Date    : Mon Dec 3 11:03:46 MST 2007
// Project : TI PHY design
//
// Copyright (c) notice
// This code adheres to the GNU public license
// Please contact www.gutzlogic.com for details.
// cmagleby@gutzlogic.com; cwinward@gutzlogic.com
//
// ===========================================================================
//
// $Id: ti_phy_top.v,v 1.2 2008-01-15 03:25:07 cmagleby Exp $
//
// ===========================================================================
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2007/12/05 18:37:06  cmagleby
// importing tb files
//
//
// ===========================================================================
// Function : This file is non-synthesizable rtl file to demonstrate TS1's.
// Insert your own RTL design here.  It has dummy signals for a sram if that
// can be ignored.
// ===========================================================================
// ===========================================================================

module ti_phy_top (/*AUTOARG*/
   // Outputs
   LED, txclk, txdata16, txdatak16, txidle16, rxdet_loopb, txcomp, 
   rxpol, phy_reset_n, pwrdwn, sram_addr, sram_adscn, sram_adspn, 
   sram_advn, sram_ben, sram_ce, sram_clk, sram_gwn, sram_mode, 
   sram_oen, sram_wen, sram_zz, 
   // Inouts
   sram_data, 
   // Inputs
   clk_50mhz, PUSH_BUTTON, FPGA_RESET_n, PERST_n, rxclk, rxdata16, 
   rxdatak16, rxvalid16, rxidle16, rxidle, rxstatus, phystatus
   );
   //****************************************************************************************
   //TI PHY interface
   //****************************************************************************************
   //debug ports
   input          clk_50mhz;
   input [1:0] 	  PUSH_BUTTON;
   output [7:0]   LED;
   reg [7:0] 	  LED;
   input 	  FPGA_RESET_n;
   input 	  PERST_n;
   //****************************************************************************************
   //Phillips PHY interface
   output 	  txclk;		//source synch 250 Mhz transmit clock from MAC.
   wire 	  txclk;
   
   output [15:0]  txdata16;
   reg [15:0] 	  txdata16;
   output [1:0]   txdatak16;
   reg [1:0] 	  txdatak16;
   output 	  txidle16; 	//forces tx output to electrical idle.  txidle should be asserted while in power states p0 and p1.
   reg 		  txidle16;
   input 	  rxclk; 		//source synch 250 clk for received data.
   input [15:0]   rxdata16;
   input [1:0] 	  rxdatak16;
   input          rxvalid16;
   output 	  rxdet_loopb; 	//used to tell the phy to begin
   reg 		  rxdet_loopb;
   input          rxidle16;
   input 	  rxidle; 	//indicates receiver detection of an electrical idle;  This is a synchronous signal.
   input [2:0] 	  rxstatus; 	//encodes receiver status and error codes.
   
   input 	  phystatus; 	//used to communicate completion of several phy functions.
   output 	  txcomp; 	//used when transmitting the compliance pattern; high-level sets the running disparity to negative.
   reg 		  txcomp;
   output 	  rxpol; 		//signals the phy to perform a polarity inversion on the receive data; low = no polarity inversion; high = polarity inversion.
   reg 		  rxpol;
   output 	  phy_reset_n; 	//phy reset active low
   reg 		  phy_reset_n;
   output [1:0]   pwrdwn;
   reg [1:0] 	  pwrdwn;
   
   //****************************************************************************************
   //SRAM Interface
   output [16:0]  sram_addr;		
   reg [16:0] 	  sram_addr;		
   output 	  sram_adscn;		
   reg 		  sram_adscn;		
   output 	  sram_adspn;		
   reg 		  sram_adspn;		
   output 	  sram_advn;		
   reg 		  sram_advn;		
   output [3:0]   sram_ben;		
   reg [3:0] 	  sram_ben;		
   output [2:0]   sram_ce;		
   reg [2:0] 	  sram_ce;		
   output 	  sram_clk;		
   reg 		  sram_clk;	
   output 	  sram_gwn;		
   reg 		  sram_gwn;		
   output 	  sram_mode;		
   reg 		  sram_mode;		
   output 	  sram_oen;		
   reg 		  sram_oen;		
   output 	  sram_wen;		
   reg 		  sram_wen;		
   output 	  sram_zz;		
   reg 		  sram_zz;
   inout [35:0]   sram_data;
   
   
   assign 	  txclk = rxclk;
   reg 		  continue;
   
   initial begin
      LED            <= 'b0; 
      txdata16 	     <= 15'b0;
      txdatak16      <= 2'b0;
      txidle16 	     <= 1'b0;
      pwrdwn 	     <= 2'b0;
      phy_reset_n    <= 1'b0;
      rxpol 	     <= 1'b0;
      txcomp 	     <= 1'b0;
      rxdet_loopb    <= 1'b0;
      phy_reset_n    <= 1'b0;
      //ignore these signals
      sram_addr      <= 'b0;
      sram_adscn     <= 'b0;
      sram_adspn     <= 'b0;
      sram_advn      <= 'b0;
      sram_ben 	     <= 'b0; 
      sram_ce 	     <= 'b0;  
      sram_clk 	     <= 'b0; 
      sram_gwn 	     <= 'b0; 
      sram_mode      <= 'b0;
      sram_oen 	     <= 'b0; 
      sram_wen 	     <= 'b0; 
      sram_zz 	     <= 'b0;  
      //sram_data      <= 'b0;
      continue 	     <= 1'b1;
      #100;
      phy_reset_n             <= 1'b1;
      sample_ts1();
   end
   
   task sample_ts1;
      begin
	 pwrdwn <=  2'b10;
	 @ (negedge rxclk);
	 wait (phystatus == 0); //indicate that the pll is locked.
	 repeat (20) @ (negedge rxclk);
	 rxdet_loopb <=  1'b1;
	 wait (phystatus == 1'b1 && rxstatus == 3'b11); //receiver detect
	 repeat (5) @ (negedge rxclk);
	 rxdet_loopb <=  1'b0;
	 repeat (2) @ (negedge rxclk);
	 pwrdwn <= 2'b0;
	 wait (phystatus == 1'b0);
	 wait (phystatus == 1'b1 && rxstatus == 4'b100); //power change accept
	 repeat (100) @ (negedge rxclk);
      
	 while (continue == 1) begin
	    //start sending ts1;	 
	    @ (negedge rxclk);
	    txdatak16 <= 2'b11;
	    txdata16  <= 16'hf7bc; //PAD LINK,COM
	    @ (negedge rxclk);
	    txdatak16 <= 2'b01;
	    txdata16  <= 16'hf0f7; //NFST,PAD LANE	 
	    @ (negedge rxclk); 
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h02;  //training control Rate ID
	    @ (negedge rxclk);
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h4a4a; //ts id
	    @ (negedge rxclk);
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h4a4a; //ts id
	    @ (negedge rxclk);
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h4a4a; //ts id
	    @ (negedge rxclk);
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h4a4a; //ts id
	    @ (negedge rxclk);
	    txdatak16 <= 2'b0;
	    txdata16  <= 16'h4a4a; //ts id
	    //add sending ts2;
	    //add link and lane
	 end // while (continue == 1)
      end
   endtask // sample_ts1
   
   

	 
	 
	 
endmodule


// Local Variables:
// verilog-library-directories:("." "./dcm" "./ddr_div2" "./single_dcm" "./dll" "./tl")
// End: