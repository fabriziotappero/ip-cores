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

// ******
//
// data.h
//
// ******

// ********************
//
// Main Characteristics
//
// ********************

`define ADDRBUS_dim 24                        // - Address Bus pin numbers
`define DATABUS_dim 16                        // - Data Bus pin numbers
`define MEMORY_dim 1 << `ADDRBUS_dim          // - Memory Dimension
`define LAST_ADDR  (`MEMORY_dim) - 1          // - Last Address

// ********************
//
// Address & Data range
//
// ********************

`define ADDRBUS_range `ADDRBUS_dim - 1 : 0
`define DATABUS_range `DATABUS_dim - 1 : 0

// *****************
//
// Init Memory Files
//
// *****************

`define CFI_dim 9'h157
`define CFI_range `CFI_dim - 1:9'h10
// *******************
//
// Protection Register 
//
// *******************


`define REG_addrStart           16'h0 
`define REG_addrEnd             16'h15 

`define REGSTART_addr           9'h80                       // Protection Register Start Address
`define REGEND_addr            9'h109                        // Protection Register End   Address
`define REG_dim                 `REGEND_addr - `REGSTART_addr + 1

`define REG_addrRange           `REG_addrEnd:`REG_addrStart

`define REG_addrbitStart        8'd0
`define REG_addrbitEnd          8'd8
`define REG_addrbitRange        `REG_addrbitEnd:`REG_addrbitStart

`define PROTECTREGLOCK_addr    9'h80                        // Protection Register Lock Address 


`define UDNREGSTART_addr        9'h81
`define UDNREGEND_addr          9'h84
`define UDNprotect_bit          8'hFE  

`define UPREGSTART_addr         9'h85
`define UPREGEND_addr           9'h88
`define UPprotect_bit           8'hFD // serve ad indentificare quale bit deve essere 0 nel lock regi
`define PRL_default             16'h0002  // Protection Register Lock default definito anche in def  

// *****************************
//
// Extended User OTP
//
// *****************************

`define ExtREG_dim                  8'h20


`define ExtREG_regiondim           8'h8 
`define ExtREGSTART_regionaddr   9'h8A      // Ext Protection Register Start Address
`define ExtREGEND_regionaddr    9'h109      // Ext Protection Register End   Address

`define ExtPROTECTREGLOCK_addr   9'h89      // Ext Protection Register Lock Address         
`define ExtPRL_default         16'hFFFF  // Protection Register Lock default   



// ***********************
//
// Voltage Characteristics
//
// ***********************
`define Voltage_range    35:0
`define VDDmin           36'd01700
`define VDDmax           36'd02000
`define VDDQmin          36'd01700
`define VDDQmax          36'd03600  
`define VPPmin           36'd00900
`define VPPmax           36'd03600
`define VPPHmin          36'd08500
`define VPPHmax          36'd09500

// **********************
//
// Configuration Register
//
// **********************

`define ConfigurationReg_dim    16
`define ConfigReg_default       16'hF94F

// ********************
//
// Electronic Signature
//
// ********************

`define ManufacturerCode      8'h89   
`define TopDeviceCode         8'h19
`define BottomDeviceCode      8'h1C
`define SignAddress_dim       9
`define SignAddress_range     `SignAddress_dim - 1 : 0



// *********************
//
// Write Buffer constant
//
// *********************


`define ProgramBuffer_addrDim           9         // Program Buffer address dimension
`define ProgramBuffer_addrRange         `ProgramBuffer_addrDim - 1:0
`define ProgramBuffer_dim              512        // Buffer Size= 2 ^ ProgramBuffer_addrDim
`define ProgramBuffer_range             `ProgramBuffer_dim - 1:0

// *********************
//
// Buffer Enhanced Program constant
//
// *********************

`define BuffEnhProgramBuffer_dim  512
`define BuffEnhProgramBuffer_range  `BuffEnhProgramBuffer_dim - 1 : 0 
`define BuffEnhProgramBuffer_addrDim  9   
`define BuffEnhProgramBuffer_addrRange  `BuffEnhProgramBuffer_addrDim - 1:0
 

// Warning and Error Messages 

`define NoError_msg             0       // No Error Found
`define CmdSeq_msg              1       // Sequence Command Unknown
`define SuspCmd_msg             2       // Cannot execute this command during suspend
`define SuspAcc_msg             3       // Cannot access this address due to suspend
`define AddrRange_msg           4       // Address out of range
`define AddrTog_msg             5       // Cannot change block address during command sequence
`define SuspAccWarn_msg         6       // It isn't possible access this address due to suspend
`define InvVDD_msg              7       // Voltage Supply must be: VDD>VDDmin or VDD<VDDmax
`define InvVPP_msg              8       // Voltage Supply must be: VDD>VDDmin or VDD<VDDmax
`define BlockLock_msg           9       // Cannot complete operation when the block is locked
`define ByteToggle_msg          10      // Cannot toggle BYTE_N while busy
`define NoUnLock_msg            11      // Invalid UnLock Block command in Locked-Down Block
`define AddrCFI_msg             12      // CFI Address out of range
`define PreProg_msg             13      // Program Failure due to cell failure
`define NoBusy_msg              14      // Device is not Busy
`define NoSusp_msg              15      // Nothing previus suspend command
`define Suspend_msg             16      // Device is Suspend mode
`define UDNlock_msg             17      // Unique Device Number Register is locked
`define UPlock_msg              18      // User Programmable Register is locked
`define ExitPHASE_BEFP_msg     19
`define WrongEraseConfirm_msg   20      // Wrong Erase Confirm code
`define SignAddrRange_msg      21       // Signature Address out of range
`define CFIAddrRange_msg       22       // CFI Address out of range
`define WrongBlankCheckConfirm_msg   23 // Wrong Blank Check Confirm code command
`define BlankCheckFailed_msg    24 //  Blank Check Failed
`define ProgramPHASE_BEFP_msg  25  // End of Program or Verify Phase on Enhanced Factory Program
`define BlkBuffer_msg          26       // Program Buffer cannot cross block boundary
`define ExtREGLock_msg         27       // Extended User Programmable Register is locked
`define LeastAddr0             28       // Significative bit [%d,0] of Start Address must be 0
`define ProtRegAddrRange_msg   29       // Protect Register Address out of range
`define BuffSize_msg           30       // Buffer size is too large
`define WrongBlankCheckBlock 31 // No main block

// ******************
//
// Valid Access Times
//
// ******************

`define tAccess_1      100
`define tAccess_2      110




