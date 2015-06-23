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

// **********************
//
// COMMAND USER INTERFACE 
//
// **********************

// Read Commands     

`define RD_cmd                  8'hFF   // Read Memory Array 
`define RSR_cmd                 8'h70   // Read Status Register 
`define RSIG_cmd                8'h90   // Read Electronic Signature 
`define RCFI_cmd                8'h98   // Read CFI


// Program/Erase Commands 

`define PG_cmd                  8'h40   // Program  
`define PES_cmd                 8'hB0   // Program/Erase Suspend 
`define PER_cmd                 8'hD0   // Program/Erase Resume 
`define BLKEE_cmd               8'h20   // Block Erase
`define BLKEEconfirm_cmd        8'hD0   // Block Erase Confirm      
`define CLRSR_cmd               8'h50   // Clear Status Register 
`define PRREG_cmd               8'hC0   // Protection Register Program //verificare se va bene x OTP register program setup


// Protect Commands 

`define BL_cmd                  8'h60   // Block Lock //setup??
`define BUL_cmd                 8'h60   // Block UnLock 
`define BLD_cmd                 8'h60   // Block lock-down
`define BLDconfirm_cmd          8'h2F   // Block Lock-down confirm
`define BLconfirm_cmd           8'h01   // Block Lock Confirm
`define BULconfirm_cmd          8'hD0   // Block unLock Confirm


// Additional Features Commands 

`define PB_cmd                  8'hE8   // Program Buffer
`define PBcfm_cmd               8'hD0   // Close Sequence of Program Buffer Command


// Configuration Register   

`define SCR_cmd                 8'h60   // Set Configuration Register
`define SCRconfirm_cmd          8'h03   // Set Configuration Register confirm

// Additional Features Commands //aggiunto
`define BLNKCHK_cmd             8'hBC // Blank Check Command
`define BLNKCHKconfirm_cmd      8'hD0 // Blank Check Confirm


// Factory Program Commands  
`define BuffEnhProgram_cmd      8'h80   // Enhanced Setup Command
`define BuffEnhProgramCfrm_cmd  8'hD0   // Enhanced Setup confirm

`define EnhSetup_cmd            8'h80   // Enhanced Setup Command
`define EnhSetup_cfrm           8'hD0   // Enhanced Setup confirm


// CUI Status 

// Read Bus Status Operation 

`define ReadArray_bus           2'b00       // Read Memory Array 
`define ReadSignature_bus       2'b01       // Read Electronic Signature
`define ReadStatusReg_bus       2'b10       // Read Status Register
`define ReadCFI_bus             2'b11       // Read CFI


// Program/Erase Controller Status 

`define Free_pes                0       // No Operation
`define Program_pes             1       // Programming
`define ProgramBuff_pes         7       // Programming


`define BlockErase_pes          2       // Erasing Block
`define ChipErase_pes           3       // Chip Erasing
`define BlockEraseSuspend_pes   4       // Block Erase Suspend
`define ProgramEraseSuspend_pes 5       // Program/Erase Resume
`define ProgramEraseWait_pes    6       // Program/Erase Wait
`define Reset_pes               10      // Reset status



