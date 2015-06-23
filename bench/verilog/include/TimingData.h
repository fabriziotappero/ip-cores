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
`include "data.h"
`include "UserData.h"

`define Reset_time  300000

// *********************************************
//
// Table 29 
//      Program/Erase Characteristics
// 
// *********************************************

// Vpp = VppL

/*
// Too long!
`define ParameterBlockErase_time         800000000//  0.8 sec
`define MainBlockErase_time        800000000
*/

/* erase times much reduced for simulation - Julius */
`define ParameterBlockErase_time         8000//  800ns sec
`define MainBlockErase_time        8000

/*
`define WordProgram_time                  150000   //      150 us
`define ParameterBlockProgram_time       272000   //   32000 us =  32 ms???????verificare
`define MainBlockProgram_time            700000   //  256000 us = 256 ms???????verificare
*/ 

`define WordProgram_time                  1500   //      150 us
`define ParameterBlockProgram_time       2720   //   32000 us =  32 ms???????verificare
`define MainBlockProgram_time            7000   //  256000 us = 256 ms???????verificare

`define ProgramSuspendLatency_time         20000   //      20 us
`define EraseSuspendLatency_time           20000   //      20 us
`define MainBlankCheck_time                     3200000
// Vpp = VppH

`define FastParameterBlockErase_time        800000000    //  0.8 sec
`define FastMainBlockErase_time             800000000    //  0.8 sec
`define FastWordProgram_time                 150000    //  8   us
`define FastParameterBlockProgram_time     272000   //  32 ms
`define FastMainBlockProgram_time      700000  //  256000 us = 256 ms 

`define BlockProtect_time                     1800
`define BlockUnProtect_time                   5000000 

`define ProgramBuffer_time                     700000


`define EnhBuffProgram_time                     512000 //
`define EnhBuffProgramSetupPhase_time             5000



// **********************
//
// Timing Data Module :
//      set timing values
//
// **********************

module TimingDataModule;

// ************************************
//
//  AC Read Specifications
//
//      Table 27
//
// ************************************

integer tAVAV;                   // Address Valid to Next Address Valid
integer tAVQV;                   // Address Valid to Output Valid (Random)
integer tAVQV1;                  // Address Valid to Output Valid (Page)
integer tELTV;                   // Chip Enable Low to Wait Valid
integer tELQV;                   // Chip Enable Low to Output Valid
integer tELQX;                   // Chip Enable Low to Output Transition
integer tEHTZ;                 // Chip Enable High to Wait Hi-Z
integer tEHQX;//tOH                   // Chip Enable High to Output Transition
integer tEHQZ;                   // Chip Enable High to Output Hi-Z
integer tGLQV;                   // Output Enable Low to Output Valid 
integer tGLQX;                   // Output Enable Low to Output Transition
integer tGHQZ;                   // Output Enable High to Output Hi-Z
integer tAVLH;//tAVVH                   // Address Valid to (ADV#) Latch Enable High
integer tELLH;  //tELVH                 // Chip Enable Low to Latch Enable High
integer tLHAX;  //tVHAX                 // Latch Enable High to Address Transition
integer tLLLH;  //tVLVH                 // Latch Enable Low to Latch Enable High
integer tLLQV; //tVLQV                  // Latch Enable Low to Output Valid

integer tGLTV; //// Output Enable Low to Wait Valid
integer tGLTX; //// Output Enable Low to Wait Transition
integer tGHTZ; //// Output Enable high to Wait Hi-Z





integer tAVKH;  //tAVCH/L      // Address Valid to Clock High
integer tELKH;    //tELCH            // Chip Enable Low to Clock High
integer tEHEL;// tEHEL              // Chip Enable High to Chip Enable Low (reading)
integer tKHAX;//tCHAX                // Clock High to Address Transition
integer tKHQV; //tCHQV               // Clock High to Output Enable Valid
integer tKHTV;   //tCHTV             // Clock High to Wait Valid
integer tKHQX;   //tCHQX             // Clock High to Output Enable Transition
integer tKHTX; //tCHTX                // Clock High to Wait Transition
integer tLLKH;  //tVLCH/L              // Latch Enable Low to Clock High
integer tLLKL;  //tVLCH/L              // Latch Enable Low to Clock High
integer tKHLL;  //tCHVL               //Clock valid to ADV# setup  
integer tKHKH;  //tCLK               // Clock Period
integer tKHKL; //tCH/CL               // Clock High to Clock Low
integer tKLKH;                      // Clock Low to Clock High
integer tCK_fall; //R203            // Clock Fall Time
integer tCK_rise;             // Clock Rise Time


// *************************************************
//
//  AC Write Specifications
//
//      Table 28
//
// *************************************************

integer tAVWH;                  // Address Valid to Write Enable High
integer tDVWH;                  // Data Valid to Write Enable High
integer tELWL;                  // Chip Enable Low to Write Enable Low
integer tWHAV;  //W18           // Write Enable High to Address Valid
integer tWHAX;                  // Write Enable High to Address Transition
integer tWHDX;                  // Write Enable High to Data Transition
integer tWHEH;                  // Write Enable High to Chip Enable High
integer tWHGL;                  // Write Enable High to Output Enable High
integer tWHLL; //W28 tWHVL      // Write Enable High to Latch Enable Low
integer tWHWL;                  // Write Enable High to Latch Enable Low
integer tWHQV;                  // Write Enable High to Output Enable Valid
integer tWLWH;                  // Write Enable Low to Write Enable High
integer tQVVPL; //tQVVL         // Output (Status Register) Valid to Vpp Low
integer tQVWPL;   //tQVBL       // Output (Status Register) Valid to Write Protect Low
integer tVPHWH;                  // Vpp High to Write Enable High
integer tWPHWH;   //tBHWH               // Write Protect High to Write Enable High


integer tELEH;                // Chip Enable Low to Chip Enable High


//!// *************************************
//!//
//!// Power and Reset
//!//
//!//      Table 20
//!//
//!// **************************************

integer tPHWL; //W1                 // Reset High to Write Enable Low
integer tPLPH;//P1                  // Reset High to Reset Low

integer tVDHPH;  //tVCCPH               // Supply voltages High to Reset High



initial begin

       setTiming(`t_access); 
       
end

// **********************
//
// FUNCTION getTime :
//      return time value
//
// **********************

function getTime;

input [8*31 : 0] time_str;

begin

        

end
endfunction

// **********************
//
// Task setTiming :
//      set timing values
//
// **********************

task setTiming;

input time_access;

integer time_access;

begin

        // ***********************************************
        //
        // AC Read Specifications
        //
        //      Table 27
        //
        // ***********************************************

        tELQX    =  0;
        tEHQX    =  0;
        tGLQX    =  0;
        tGHQZ    = 15;
        tELLH    = 10;

        tAVAV  =  time_access;
        tAVQV  =  time_access;
        tELQV  =  time_access;
        tLLQV  =  time_access;
        
        tEHTZ    =  20;
        tAVQV1   =  25;
        tELTV    =  17;
        
        tEHEL  = 17;
        tCK_fall =  3;
        tCK_rise =  3;
         tEHQZ    =  20;
                                tGLQV    =  25;
                                tAVLH    =  10;
                                tLHAX    =   9;
                                tLLLH    =  10;

                                tAVKH    =   9;
                                tELKH    =   9;
                                tKHAX    =   10;
                                tKHQV    =  17;
                                tKHTV    =  17;
                                tKHQX    =   3;
                                tKHTX    =   3;
                                tLLKH    =   9;
                                tLLKL    =   9;
                                tKHLL    =   3;
                                tKHKH    =  19.2;
                                tKHKL    =   5;
                                tKLKH    =   5; 
                                tGLTV    =   17;
                                tGLTX    =   0;
                                tGHTZ    =   20;

// *************************************************
//
//  AC Write Specifications
//
//      Table 28
//
// *************************************************

        tELWL    =    0;
        tWHAV    =    0;
        tWHAX    =    0;
        tWHDX    =    0;
        tWHEH    =    0;
        tWHGL    =    0;
        tWHLL    =    7;
        tQVVPL   =    0;
        tQVWPL   =    0;
        tVPHWH   =  200;
        tWPHWH   =  200;
        tAVWH    =  50; 
                                                    
                                tDVWH    =  50;  
                                tWHWL    =  20;
                                tWHQV    =  tAVQV + 35;  //tAVQV+35 
                                tWLWH    =  50;  
                                tELEH    =  50;  
 
// *************************************
//
// Power and Reset
//
//      Table 20
//
// **************************************

        tPHWL           = 150;               
        tPLPH           =  100;       
        tVDHPH          =  300;     


end
endtask

endmodule

