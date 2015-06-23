//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:51:55 $ 
// 
// Workfile     : hssdrc_timing.vh
// 
// Description  : controller sdram timing paramters
// 
// HSSDRC is licensed under MIT License
// 
// Copyright (c) 2007-2008, Denis V.Shekhalev (des00@opencores.org) 
// 
// Permission  is hereby granted, free of charge, to any person obtaining a copy of
// this  software  and  associated documentation files (the "Software"), to deal in
// the  Software  without  restriction,  including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the  Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR  A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT  HOLDERS  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


`ifndef __HSSDRC_TIMING_VH__ 

  `define __HSSDRC_TIMING_VH__ 

  //`define HSSDRC_SIMULATE_TIMING     // uncomment for easy debug arefr sequence 
  
  //-------------------------------------------------
  // sdram controller clock settings in MHz
  //-------------------------------------------------
  parameter real pClkMHz = 133.0;   
  //-------------------------------------------------
  // sdram chip timing paramters in "ns" for -6 CL3
  //-------------------------------------------------
  parameter real pTras_time =     42.0;   // act a    -> prech a                
  parameter real pTrfc_time =     60.0;   // refr     -> !nop                    
  parameter real  pTrc_time =     60.0;   // act a    -> act a  (Tras + Trcd)                 
  parameter real pTrcd_time =     18.0;   // act a    -> write/read a            
  parameter real  pTrp_time =     18.0;   // prech a  -> !nop                    
  parameter real pTrrd_time =     12.0;   // act a    -> act b                   
  parameter real  pTwr_time =     12.0;   // write a  -> prech a                

  `ifndef HSSDRC_SIMULATE_TIMING 
    parameter real pRefr_time =  15625.0;   // refr     -> refr 
    parameter real pInit_time = 100000.0;   // power up -> refr 
  `else
    parameter real pRefr_time = 500.0;   // simulate only refr     -> refr
    parameter real pInit_time = 500.0;   // simulate only power up -> refr
  `endif
  //-------------------------------------------------       
  // sdram chip normalaize to clock parameters 
  //-------------------------------------------------       
  parameter int cTras     = 0.5 + (pTras_time * pClkMHz)/1000.0;   // act a    -> prech a      
  parameter int cTrfc     = 0.5 + (pTrfc_time * pClkMHz)/1000.0;   // refr     -> !nop         
  parameter int  cTrc     = 0.5 + ( pTrc_time * pClkMHz)/1000.0;   // act a    -> act a        
  parameter int cTrcd     = 0.5 + (pTrcd_time * pClkMHz)/1000.0;   // act a    -> write/read a 
  parameter int  cTrp     = 0.5 + ( pTrp_time * pClkMHz)/1000.0;   // prech a  -> !nop         
  parameter int cTrrd     = 0.5 + (pTrrd_time * pClkMHz)/1000.0;   // act a    -> act b        
  parameter int  cTwr     = 0.5 + ( pTwr_time * pClkMHz)/1000.0;   // write a  -> prech a      
  parameter int cTmrd     = 2;                                   // lmr      -> !nop         (not used)  
  parameter int cInitTime = 0.5 + (pInit_time * pClkMHz)/1000.0; 
  //-------------------------------------------------       
  // refresh parameters 
  //-------------------------------------------------       
  parameter real  pRefrWindowLowPriority      = 0.85;   
  parameter real  pRefrWindowHighPriority     = 0.95;   
  parameter int   cRefCounterMaxTime          = 0.5 + (pRefr_time * pClkMHz)/1000.0;         
  parameter int   cRefrWindowLowPriorityTime  = 0.5 + (pRefrWindowLowPriority  * pRefr_time * pClkMHz)/1000.0; 
  parameter int   cRefrWindowHighPriorityTime = 0.5 + (pRefrWindowHighPriority * pRefr_time * pClkMHz)/1000.0; 
  //-------------------------------------------------
  // sdram controller use 0/1 cycle bus turnaround 
  //------------------------------------------------- 
  parameter int pBTA = 1;  // set 0 if not need 

  //
`endif 
