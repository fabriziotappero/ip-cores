//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Clk_ctrl.v                                                  ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/projects.cgi/web/ethernet_tri_mode/////
////                                                              ////
////  Author(s):                                                  ////
////      - Jon Gao (gaojon@yahoo.com)                            ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//                                                                    
// CVS Revision History                                               
//                                                                    
// $Log: not supported by cvs2svn $
// Revision 1.2  2005/12/16 06:44:13  Administrator
// replaced tab with space.
// passed 9.6k length frame test.
//
// Revision 1.1.1.1  2005/12/13 01:51:44  Administrator
// no message
// 

module Clk_ctrl_V4port(   
Reset           ,
Clk_125M        ,
//host interface,
Speed           ,
//Phy interface ,
Gtx_clk         ,
Rx_clk          ,
Tx_clk          ,
//interface clk ,
MAC_tx_clk      ,
MAC_rx_clk      ,
MAC_tx_clk_div  ,
MAC_rx_clk_div  
);
input           Reset           ;
input           Clk_125M        ;
                //host interface
input   [2:0]   Speed           ;       
                //Phy interface         
output          Gtx_clk         ;//used only in GMII mode
input           Rx_clk          ;
input           Tx_clk          ;//used only in MII mode
                //interface clk signals
output          MAC_tx_clk      ;
output          MAC_rx_clk      ;
output          MAC_tx_clk_div  ;
output          MAC_rx_clk_div  ;


//******************************************************************************
//internal signals                                                              
//******************************************************************************
wire            Rx_clk_div2 ;
wire            Tx_clk_div2 ;

wire 	Clk125i, Clk125;
wire  Clk25i, Clk25;
//******************************************************************************
//                                                              
//******************************************************************************
assign Gtx_clk      =Clk_125M                   ;
assign MAC_rx_clk   =Rx_clk                     ;

DCM_BASE #(
      .CLKDV_DIVIDE(5.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      .CLKFX_DIVIDE(5), // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(1), // Can be any integer from 2 to 32
      .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
      .CLKIN_PERIOD(10.0), // Specify period of input clock in ns from 1.25 to 1000.00
      .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift mode of NONE or FIXED
      .CLK_FEEDBACK("1X"), // Specify clock feedback of NONE, 1X or 2X
      .DCM_PERFORMANCE_MODE("MAX_SPEED"), // Can be MAX_SPEED or MAX_RANGE
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                            //   an integer from 0 to 15
      .DFS_FREQUENCY_MODE("LOW"), // LOW or HIGH frequency mode for frequency synthesis
      .DLL_FREQUENCY_MODE("LOW"), // LOW, HIGH, or HIGH_SER frequency mode for DLL
      .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
      .FACTORY_JF(16'hf0f0), // FACTORY JF value suggested to be set to 16'hf0f0
      .PHASE_SHIFT(0), // Amount of fixed phase shift from -255 to 1023
      .STARTUP_WAIT("FALSE") // Delay configuration DONE until DCM LOCK, TRUE/FALSE
   ) DCM_BASE_TX125M (
      .CLK0(Clk125),         // 0 degree DCM CLK output
      .CLK180(),     // 180 degree DCM CLK output
      .CLK270(),     // 270 degree DCM CLK output
      .CLK2X(),       // 2X DCM CLK output
      .CLK2X180(), // 2X, 180 degree DCM CLK out
      .CLK90(),       // 90 degree DCM CLK output
      .CLKDV(Clk25),       // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKFX(),       // DCM CLK synthesis out (M/D)
      .CLKFX180(), // 180 degree CLK synthesis out
      .LOCKED(),     // DCM LOCK status output
      .CLKFB(Clk125i),       // DCM clock feedback
      .CLKIN(Clk_125M),       // Clock input (from IBUFG, BUFG or DCM)
      .RST(rst)            // DCM asynchronous reset input
   );

	BUFG 


//pragma synthesis_off
CLK_DIV2_Wrapper U_0_CLK_DIV2(
.Reset          (Reset          ),
.IN             (Rx_clk         ),
.OUT            (Rx_clk_div2    )
);

CLK_DIV2_Wrapper U_1_CLK_DIV2(
.Reset          (Reset          ),
.IN             (Tx_clk         ),
.OUT            (Tx_clk_div2    )
);

CLK_SWITCH U_0_CLK_SWITCH(
.IN_0           (Rx_clk_div2    ),
.IN_1           (Rx_clk         ),
.SW             (Speed[2]       ),
.OUT            (MAC_rx_clk_div )
);

CLK_SWITCH U_1_CLK_SWITCH(
.IN_0           (Tx_clk         ),
.IN_1           (Clk_125M       ),
.SW             (Speed[2]       ),
.OUT            (MAC_tx_clk     )
);


CLK_SWITCH U_2_CLK_SWITCH(
.IN_0           (Tx_clk_div2    ),
.IN_1           (Clk_125M       ),
.SW             (Speed[2]       ),
.OUT            (MAC_tx_clk_div )
);

//pragma synthesis_on

endmodule