//          _/             _/_/
//        _/_/           _/_/_/
//      _/_/_/_/         _/_/_/
//      _/_/_/_/_/       _/_/_/              ____________________________________________ 
//      _/_/_/_/_/       _/_/_/             /                                           / 
//      _/_/_/_/_/       _/_/_/            /                                 28F256P30 / 
//      _/_/_/_/_/       _/_/_/           /                                           /  
//      _/_/_/_/_/_/     _/_/_/          /                                   256Mbit / 
//      _/_/_/_/_/_/     _/_/_/         /                                single die / 
//      _/_/_/ _/_/_/    _/_/_/        /                                           / 
//      _/_/_/  _/_/_/   _/_/_/       /                  Verilog Behavioral Model / 
//      _/_/_/   _/_/_/  _/_/_/      /                               Version 1.3 / 
//      _/_/_/    _/_/_/ _/_/_/     /                                           /
//      _/_/_/     _/_/_/_/_/_/    /           Copyright (c) 2010 Numonyx B.V. / 
//      _/_/_/      _/_/_/_/_/    /___________________________________________/ 
//      _/_/_/       _/_/_/_/      
//      _/_/          _/_/_/  
// 
//     
//             NUMONYX              
                
// *****************************************
// Glogal Definition for Device :  M58WR128F
// *****************************************

// TimeScale Directive
`timescale 1 ns / 1 ns

`define HIGH                 1'b1
`define LOW                  1'b0
`define Z                    1'bZ
`define X                    1'bX
`define FALSE                1'b0
`define TRUE                 1'b1
`define UNLOCK               1'b0      // Unlocked Block Lock Status
`define LOCK                 1'b1      // Locked Block Lock Status
`define UNLOCKDOWN           1'b0      // UnLocked-down Status 
`define LOCKDOWN             1'b1      // Locked-down Status
`define BUSY                 1'b0
`define READY                1'b1
`define BYTE_range           7:0
`define WORD_range          15:0
`define LOW_range            7:0
`define HIGH_range          15:8
`define WORDNP               16'hFFFF  // Memory not programmed 
`define Kbyte                1024
`define Kword                1024
`define INTEGER              15:0

