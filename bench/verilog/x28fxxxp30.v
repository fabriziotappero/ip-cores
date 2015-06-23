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
`include "def.h"
`include "CUIcommandData.h"
`include "data.h"
`include "UserData.h"
`include "BankLib.h"
`include "TimingData.h"

// **********************************
//
// Timing Lib Module :
// 
//      checks all timing constraints            
//
// **********************************

module TimingLibModule(A, DQ, W_N, G_N, E_N, L_N, WP_N, CK, VPP);  

   input [`ADDRBUS_dim-1:0] A;           // Address Bus 
   input [`DATABUS_dim-1:0] DQ;          // Data I/0 Bus

   input 		    W_N, G_N, E_N, L_N, WP_N, CK;
   input [`Voltage_range]   VPP;

   integer 		    AddValid_time;
   integer 		    AddNotValid_time;
   integer 		    DataValid_time;
   integer 		    DataXX_time;

   integer 		    WriteEnableLow_time;
   integer 		    WriteEnableHigh_time;
   integer 		    OutputEnableLow_time;
   integer 		    OutputEnableHigh_time;
   integer 		    LatchEnableHigh_time;
   integer 		    LatchEnableLow_time;
   integer 		    ChipEnableLow_time; 
   integer 		    ChipEnableHigh_time;
   integer 		    RisingEdge_time;
   integer 		    FallingEdge_time;

   integer 		    WaitValid_time;

   integer 		    WriteProtectHigh_time;
   integer 		    WriteProtectLow_time;
   integer 		    VPPSupplyHigh_time;
   integer 		    VPPSupplyLow_time;

   reg 			    afterReset;

   reg 			    isValid;
   reg 			    dataValid;
   reg 			    addressValid;
   reg 			    reading;
   reg 			    writing;
   reg 			    dataXX;
   time 		    temp;


initial begin

   AddValid_time         = 0;
   AddNotValid_time      = 0;
   DataValid_time        = 0;
   DataXX_time           = 0;

   WriteEnableLow_time   = 0;
   WriteEnableHigh_time  = 0;
   OutputEnableLow_time  = 0;
   OutputEnableHigh_time = 0;
   LatchEnableHigh_time  = 0;
   LatchEnableLow_time   = 0;
   ChipEnableLow_time    = 0;
   ChipEnableHigh_time   = 0;

   WaitValid_time        = 0;

   WriteProtectHigh_time = 0;
   WriteProtectLow_time  = 0;

   RisingEdge_time  = 0;
   FallingEdge_time = 0;

   dataValid = `FALSE;
   dataXX    = `FALSE;
   addressValid = `FALSE;

   reading = `FALSE;
   writing = `FALSE;

   afterReset = `FALSE;

end


// **************
//
// Change address
//
// **************

always @(A) begin : AddressCheck

   if (`TimingChecks == "off") 
      disable AddressCheck;

   if ($time > `Reset_time)
   begin
      if (isAddValid(A))               // Address Valid
      begin
         temp = $time - AddValid_time;
         checkTiming("tAVAV", TimingData_man.tAVAV, temp, "min");

         temp = $time - WriteEnableHigh_time;
         checkTiming("tWHAV", TimingData_man.tWHAV, temp, "min");

         AddValid_time = $time;        
         addressValid = `TRUE;
      end

      else
      begin
         if (isAddXX(A) || isAddZZ(A))             // Address XXXX o ZZZZ
         begin
            
            if (addressValid)
            begin
               temp = $time - LatchEnableHigh_time;
               checkTiming("tLHAX", TimingData_man.tLHAX, temp, "min");

               temp = $time - WriteEnableHigh_time;
               checkTiming("tWHAX", TimingData_man.tWHAX, temp, "min");

               
               AddNotValid_time = $time;        
            end
            addressValid = `FALSE;
         end
      end
   end           
end


// ***********
//
// Change data
//
// ***********

always @(DQ) begin : DataCheck

   if (`TimingChecks == "off") 
      disable DataCheck;

   if ($time > `Reset_time)
   begin

      if (isDataValid(DQ))               // Data Valid
      begin
         if (ConfigReg_man.isSynchronous)               // Synchronous mode 

         begin
            if (reading)
               if (ConfigReg_man.isRisingClockEdge)
               begin
                  temp = $time - RisingEdge_time;
               end
               else
               begin
                  temp = $time - FallingEdge_time;

               end
         end

         else         // Asynchronous mode
         begin        
            
            temp = $time - AddValid_time;

            temp = $time - LatchEnableLow_time;

            temp = $time - ChipEnableLow_time;

            if (reading)
            begin
               temp = $time - OutputEnableLow_time;
               
               temp = $time - WriteEnableHigh_time;
            end

            DataValid_time = $time;   
            dataValid = `TRUE;
            dataXX = `FALSE;
         end
      end         
      
      else
      begin
         if (isDataXX(DQ))                 // Data XXXX
         begin
            if (dataValid) 
            begin
               temp = $time - AddNotValid_time;

               temp = $time - ChipEnableHigh_time;
               checkTiming("tEHQX", TimingData_man.tEHQX, temp, "min");

               temp = $time - OutputEnableHigh_time;

            end

            else    
            begin
               
               temp = $time - ChipEnableLow_time;
               checkTiming("tELQX", TimingData_man.tELQX, temp, "min");

               if (reading)
               begin
                  temp = $time - OutputEnableLow_time;
                  checkTiming("tGLQX", TimingData_man.tGLQX, temp, "min");
               end        
            end


            DataXX_time = $time;
            dataValid = `FALSE;
            dataXX = `TRUE;
            
         end

         else 
            if (isDataZZ(DQ))        
            begin
               if (dataXX) 
               begin
                  temp = $time - ChipEnableHigh_time;
                  checkTiming("tEHQZ", TimingData_man.tEHQZ, temp, "max");
                  temp = $time - OutputEnableHigh_time;
                  checkTiming("tGHQZ", TimingData_man.tGHQZ, temp, "max");
               end

               if (dataValid)
               begin
                  temp = $time - WriteEnableHigh_time;
                  checkTiming("tWHDX", TimingData_man.tWHDX, temp, "min");
		  
               end
               
               dataValid = `FALSE;
               dataXX  = `FALSE;
            end
      end
   end       
end           

// ******************
//
// Change Chip Enable
//
// ******************

always @(posedge E_N) begin : ChipHighCheck    // Chip Enable High

   if (`TimingChecks == "off") 
      disable ChipHighCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - WriteEnableHigh_time;
      checkTiming("tWHEH", TimingData_man.tWHEH, temp, "min");

      ChipEnableHigh_time = $time;
   end
end

always @(negedge E_N) begin : ChipLowCheck    // Chip Enable Low

   if (`TimingChecks == "off") 
      disable ChipLowCheck;

   if ($time > `Reset_time)
   begin
      
      ChipEnableLow_time = $time;
   end    

end

always @(posedge L_N) begin : LatchLowCheck    // Latch Enable High

   if (`TimingChecks == "off") 
      disable LatchLowCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - AddValid_time;
      checkTiming("tAVLH", TimingData_man.tAVLH, temp, "min");
      
      temp = $time - LatchEnableLow_time;
      checkTiming("tLLLH", TimingData_man.tLLLH, temp, "min");
      
      temp = $time - ChipEnableLow_time;
      checkTiming("tELLH", TimingData_man.tELLH, temp, "min");
      
      LatchEnableHigh_time = $time;
   end
end

always @(negedge L_N)  begin : LatchHighCheck  // Latch Enable Low

   if (`TimingChecks == "off") 
      disable LatchHighCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - WriteEnableHigh_time;
      checkTiming("tWHLL", TimingData_man.tWHLL, temp, "min");

      temp = $time - RisingEdge_time;
      checkTiming("tKHLL", TimingData_man.tKHLL, temp, "min");

      LatchEnableLow_time = $time;
   end

end

always  @(posedge G_N) begin : OutputHighCheck    // Output Enable High

   if (`TimingChecks == "off") 
      disable OutputHighCheck;

   if ($time > `Reset_time)
   begin
      
      OutputEnableHigh_time = $time;
      reading = `FALSE;
   end

end

always @(negedge G_N) begin : OutputLowCheck    // Output Enable Low

   if (`TimingChecks == "off") 
      disable OutputLowCheck;

   if ($time > `Reset_time)
   begin

      
      temp = $time - WriteEnableHigh_time;
      checkTiming("tWHGL", TimingData_man.tWHGL, temp, "min");


      OutputEnableLow_time = $time;
      reading = `TRUE;
   end    

end

always @(posedge W_N) begin : WriteHighCheck    // Write Enable High

   if (`TimingChecks == "off") 
      disable WriteHighCheck;

   if ($time > `Reset_time)
   begin

      
      temp = $time - AddValid_time;
      checkTiming("tAVWH", TimingData_man.tAVWH, temp, "min");

      if (writing)
      begin
         temp = $time - WriteEnableLow_time;
         checkTiming("tWLWH", TimingData_man.tWLWH, temp, "min");
      end        
      
      temp = $time - DataValid_time;
      checkTiming("tDVWH", TimingData_man.tDVWH, temp, "min");

      temp = $time - WriteProtectHigh_time;
      checkTiming("tWPHWH", TimingData_man.tWPHWH, temp, "min");

      temp = $time - VPPSupplyHigh_time;
      checkTiming("tVPHWH", TimingData_man.tVPHWH, temp, "min");

      WriteEnableHigh_time = $time;
      writing = `FALSE;
   end
end

always @(negedge W_N) begin : WriteLowCheck    // Write Enable Low

   if (`TimingChecks == "off") 
      disable WriteLowCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - ChipEnableLow_time;
      checkTiming("tELWL", TimingData_man.tELWL, temp, "min");

      temp = $time - WriteEnableHigh_time;
      checkTiming("tWHWL", TimingData_man.tWHWL, temp, "min");

      WriteEnableLow_time = $time;
      writing = `TRUE; 
   end
end

always  @(posedge WP_N) begin : WPHighCheck            // Write Protect High

   if (`TimingChecks == "off") 
      disable WPHighCheck;

   if ($time > `Reset_time)
   begin
      
      WriteProtectHigh_time = $time; 
   end   
end

always  @(negedge WP_N) begin : WPLowCheck               // Write Protect Low

   if (`TimingChecks == "off") 
      disable WPLowCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - DataValid_time;
      checkTiming("tQVWPL", TimingData_man.tQVWPL, temp, "min");

      WriteProtectLow_time = $time;
   end   
end

always @(posedge VPP) begin : VPPHighCheck            // Write Protect High

   if (`TimingChecks == "off") 
      disable VPPHighCheck;

   if ($time > `Reset_time)
   begin
      
      VPPSupplyHigh_time = $time; 
   end     
end

always @(negedge VPP) begin : VPPLowCheck               // Write Protect Low

   if (`TimingChecks == "off") 
      disable VPPLowCheck;

   if ($time > `Reset_time)
   begin
      
      temp = $time - DataValid_time;
      checkTiming("tQVVPL", TimingData_man.tQVVPL, temp, "min");

      VPPSupplyLow_time = $time;

   end   
end

always @(posedge CK) begin : RisingCKCheck              

   if (`TimingChecks == "off") 
      disable RisingCKCheck;

   if ($time > `Reset_time)
   begin
      temp = $time - LatchEnableLow_time;
      checkTiming("tLLKH", TimingData_man.tLLKH, temp, "min");

      
      RisingEdge_time = $time;
   end   
end

always @(negedge CK) begin : FallingCKCheck                

   if (`TimingChecks == "off") 
      disable FallingCKCheck;

   if ($time > `Reset_time)
   begin
      temp = $time - LatchEnableLow_time;
      checkTiming("tLLKL", TimingData_man.tLLKL, temp, "min");
      
      FallingEdge_time = $time;
      
   end   
end



// **********************************************
//
// FUNCTION isAddValid :
//      return true if the input address is valid
//
// **********************************************

function isAddValid;

   input [`ADDRBUS_dim - 1 : 0] Add;

   reg [`ADDRBUS_dim - 1 : 0] 	Add;

   reg 				valid;
   integer 			count;

   begin

      valid = `TRUE;
      begin : cycle
         for (count = 0; count <= `ADDRBUS_dim - 1; count = count + 1)
         begin
            if ((Add[count] !== 1'b0) && (Add[count] !== 1'b1))
            begin
               valid = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isAddValid = valid;
   end
endfunction


// *********************************************
//
// FUNCTION isAddXX :
//      return true if the input address is XXXX
//
// *********************************************

function isAddXX;

   input [`ADDRBUS_dim - 1 : 0] Add;

   reg [`ADDRBUS_dim - 1 : 0] 	Add;

   reg 				allxx;
   integer 			count;

   begin

      allxx = `TRUE;
      begin : cycle
         for (count = 0; count <= `ADDRBUS_dim - 1; count = count + 1)
         begin
            if (Add[count] !== 1'bx)
            begin
               allxx = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isAddXX = allxx;
   end
endfunction

// *********************************************
//
// FUNCTION isAddZZ :
//      return true if the input address is ZZZZ
//
// *********************************************

function isAddZZ;

   input [`ADDRBUS_dim - 1 : 0] Add;

   reg [`ADDRBUS_dim - 1 : 0] 	Add;

   reg 				allzz;
   integer 			count;

   begin

      allzz = `TRUE;
      begin : cycle
         for (count = 0; count <= `ADDRBUS_dim - 1; count = count + 1)
         begin
            if (Add[count] !== 1'bz)
            begin
               allzz = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isAddZZ = allzz;
   end
endfunction

// **********************************************
//
// FUNCTION isDataValid :
//      return true if the data is valid
//
// **********************************************

function isDataValid;

   input [`DATABUS_dim - 1 : 0] Data;

   reg [`DATABUS_dim - 1 : 0] 	Data;

   reg 				valid;
   integer 			count;

   begin

      valid = `TRUE;
      begin : cycle
         for (count = 0; count <= `DATABUS_dim - 1; count = count + 1)
         begin
            if ((Data[count] !== 1'b0) && (Data[count] !== 1'b1))
            begin
               valid = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isDataValid = valid;
   end
endfunction

// ***************************************
//
// FUNCTION isDataXX :
//      return true if the data is unknown
//
// ***************************************

function isDataXX;

   input [`DATABUS_dim - 1 : 0] Data;

   reg [`DATABUS_dim - 1 : 0] 	Data;

   reg 				allxx;
   integer 			count;

   begin

      allxx = `TRUE;
      begin : cycle
         for (count = 0; count <= `DATABUS_dim - 1; count = count + 1)
         begin
            if (Data[count] !== 1'bx) 
            begin
               allxx = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isDataXX = allxx;
   end
endfunction

// ************************************
//
// FUNCTION isDataZZ :
//      return true if the data is Hi-Z
//
// ************************************

function isDataZZ;

   input [`DATABUS_dim - 1 : 0] Data;

   reg [`DATABUS_dim - 1 : 0] 	Data;

   reg 				allzz;
   integer 			count;

   begin

      allzz = `TRUE;
      begin : cycle
         for (count = 0; count <= `DATABUS_dim - 1; count = count + 1)
         begin
            if (Data[count] !== 1'bz) 
            begin
               allzz = `FALSE;
               disable cycle;
            end
         end
      end                
      
      isDataZZ = allzz;
   end
endfunction

// *****************************
//
// Task Check Timing
//      check timing constraints
//
// *****************************

task checkTiming;
   input [8*6:1] tstr;
   input [31:0]  tOK, tcheck;
   input [8*3:1] check_str;
   
   begin
      if ((check_str == "min") && (tcheck < tOK)) begin
         $display ("[%t]  !ERROR: %0s timing constraint violation!! ", $time, tstr);
      end         

      else 
         if ((check_str == "max") && (tcheck > tOK))
            $display ("[%t]  !ERROR: %0s timing constraint violation!! ", $time, tstr);
   end
endtask


endmodule


// Protect Manager
// implements the architecture of the memory blocks

module BlockLockModule(address, WP_N, RP_N, Info);
   input [`ADDRBUS_range] address;
   input 		  WP_N, RP_N;
   input 		  Info;

   reg 			  LockArray [`BLOCK_dim - 1 : 0]; 
   reg 			  LockDownArray [`BLOCK_dim - 1 : 0];  

   reg [`BYTE_range] 	  Status;
   integer 		  count;
initial begin              // constructor sequence         
   
   for (count = 0; count <= `BLOCK_dim - 1; count = count + 1)             // all blocks are locked at power-up
   begin 
      LockDownArray[count] = `UNLOCKDOWN;
      if (`BLOCKPROTECT == "on") LockArray[count] = `LOCK;
      else LockArray[count] = `UNLOCK;
   end
end

always @(negedge RP_N) begin
   initLockArray;
end

task initLockArray;
   begin 
      
      for (count = 0; count <= `BLOCK_dim - 1; count = count + 1)             // all blocks are locked at power-up
      begin 
         LockDownArray[count] = `UNLOCKDOWN;
         LockArray[count] = `LOCK;
      end
   end
endtask



// ********************************************
//
// FUNCTION isLocked : return the status of the 
//                     specified block 
//
// ********************************************

function IsLocked;                     // boolean function primitive   
   
   input [`ADDRBUS_range] address;
   
   integer 		  n_block;

   begin
      
      n_block  = BankLib_man.getBlock(address); 
      IsLocked = (LockArray[n_block] == `LOCK) ? `TRUE : `FALSE;
      
   end
endfunction  

// ********************************************
//
// FUNCTION isLocked : return the status of the 
//                     specified block 
//
// ********************************************

function IsUnLocked;                     // boolean function primitive   
   
   input [`ADDRBUS_range] address;
   integer 		  n_block;

   begin
      
      n_block  = BankLib_man.getBlock(address); 
      IsUnLocked = (LockArray[n_block] == `UNLOCK) ? `TRUE : `FALSE;
      
   end
endfunction  


function getLockBit;                     // boolean function primitive   
   
   input [`ADDRBUS_range] address;
   integer 		  n_block;

   begin
      
      n_block  = BankLib_man.getBlock(address); 
      getLockBit = LockArray[n_block];
      
   end
endfunction  

function getLockDownBit;                     // boolean function primitive   
   
   input [`ADDRBUS_range] address;
   integer 		  n_block;

   begin
      
      n_block  = BankLib_man.getBlock(address); 
      getLockDownBit = LockDownArray[n_block];
      
   end
endfunction  


// ********************************
//
// Task UnLock :
//    implements Block UnLock Command
//
// ********************************

task UnLock;
   
   output [`BYTE_range] Status;
   reg [`BYTE_range] 	Status;

   integer 		n_block;
   
   begin
      
      n_block = BankLib_man.getBlock(address);
      Status = `NoError_msg;
      if (LockDownArray[n_block]==`LOCKDOWN && WP_N==`LOW) Status = `NoUnLock_msg;
      else  LockArray[n_block] = `UNLOCK;
   end
endtask

// ********************************
//
// Task Lock :
//    implements Block Lock Command
//
// ********************************

task Lock;
   
   output [`BYTE_range] Status;
   reg [`BYTE_range] 	Status;

   integer 		n_block;
   
   begin
      
      n_block = BankLib_man.getBlock(address);
      Status = `NoError_msg;
      LockArray[n_block] = `LOCK;
   end
endtask

// *****************************************
//
// Task LockDown :
//    implements the Block Lock-Down Command
//
// *****************************************

task LockDown;
   
   output [`BYTE_range] Status;
   reg [`BYTE_range] 	Status;

   integer 		n_block;
   
   begin
      
      n_block = BankLib_man.getBlock(address);
      Status = `NoError_msg;
      LockDownArray[n_block] = `LOCKDOWN;
      
   end 
endtask


endmodule 


// *************************
//
// CFI Query Module
// Implements the CFI memory
//
// *************************

module CFIqueryModule();   //, isCFI);

//input isCFI;

   reg [`BYTE_range] CFIarray [0:`CFI_dim];
   reg 		     error;
   reg [8*20:1]      CFI_file;
   integer 	     i;

initial begin
   if (`organization == "top") CFI_file = "CFImemory_top.vmf";
   else CFI_file= "CFImemory_bottom.vmf";

   for (i=0; i <= `CFI_dim; i = i + 1) CFIarray[i] = {8{`HIGH}};   // CFI Memory Init
   $readmemb(CFI_file,CFIarray);
end 

always @(posedge error)  begin
   Kernel.SetWarning(`RCFI_cmd,16'h00,`CFIAddrRange_msg);
   error = `FALSE;
end

function [`WORD_range] Get;

   input [`ADDRBUS_range] address;
   
   begin
      if (address[`BYTE_range] >= 9'h10 && address[`BYTE_range] <= `CFI_dim )  //verificare se tener conto che il primo indirizzo accessibile e' 10h
      begin 
         if (address[`BYTE_range] >= 9'h39 && address[`BYTE_range] <= 9'h109) begin
            Get = 8'hXX;
            error = `TRUE;
         end else begin

            Get[`LOW_range] = CFIarray[address[`BYTE_range]];
            Get[`HIGH_range] = 8'h00;
         end
         
      end else 
      begin
         Get = 8'hXX;
         error = `TRUE;
      end
   end
endfunction

endmodule

// ********************************
//
// Data Error Module
// 
//      search for errors in data.h
//
// ********************************

module DataErrorModule;  

   reg SevError;

initial begin

   SevError = `FALSE;

   if ((`organization != "top") && (`organization != "bottom")) 
   begin
      SevError = `TRUE;
      $display("!Error: BLOCK ORGANIZATION INVALID: it must be top or bottom!!!"); 
   end        

   if ((`BLOCKPROTECT != "on") && (`BLOCKPROTECT != "off")) 
   begin
      SevError = `TRUE;
      $display("!Error: BLOCK PROTECT INVALID: it must be on or off!!!");
   end

   if ((`TimingChecks != "on") && (`TimingChecks != "off")) 
   begin
      SevError = `TRUE;
      $display("!Error: TIMING CHECKS INVALID: it must be on or off!!!");
   end


   if ((`t_access != 100) && (`t_access != 110))
   begin
      SevError = `TRUE;
      $display("!Error: Access time INVALID: it must be 100 ns or 110 ns!!!");
   end


   if (SevError) $finish;
end

endmodule

// ******************************************
//
// Configuration Register module :
//
//      implements the configuration register
//
// ******************************************

module ConfigRegModule(address,Info);  
   input [`ADDRBUS_range] address;
   input 		  Info;

   reg [`ConfigurationReg_dim - 1 : 0] CR_reg;
   reg [`BYTE_range] 		       Status;

// **********************
//
// Setting default values
//
// **********************

`define ReadMode_bit         15
`define ClockLatency_MSBbit  14
`define ClockLatency_LSBbit  11
`define WaitPolarity_bit     10
`define WaitConfig_bit       8
`define BurstType_bit        7
`define ValidClockEdge_bit   6
`define WrapBurst_bit        3
`define BurstLength_MSBbit   2
`define BurstLength_LSBbit   0

// Interpreter  Config Reg\\

   wire 			       isASynchronous      = CR_reg[`ReadMode_bit] ? `TRUE : `FALSE;
   wire 			       isSynchronous       = CR_reg[`ReadMode_bit] ? `FALSE : `TRUE;
   wire [3:0] 			       Xlatency      = (CR_reg[`ClockLatency_MSBbit : `ClockLatency_LSBbit]<2 &&
							CR_reg[`ClockLatency_MSBbit : `ClockLatency_LSBbit]>15) ? 0 : 
				       CR_reg[`ClockLatency_MSBbit : `ClockLatency_LSBbit];
   wire 			       isWaitPolActiveHigh = CR_reg[`WaitPolarity_bit] ? `TRUE : `FALSE;
   wire 			       isWaitBeforeActive    = CR_reg[`WaitConfig_bit] ? `TRUE : `FALSE;
   wire 			       isRisingClockEdge   = CR_reg[`ValidClockEdge_bit] ? `TRUE : `FALSE;
   wire 			       isWrapBurst         = CR_reg[`WrapBurst_bit] ? `FALSE : `TRUE;
   wire 			       isNoWrapBurst       = CR_reg[`WrapBurst_bit] ? `TRUE : `FALSE;

   wire [4:0] 			       BurstLength   = CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 1 ? 4 : 
				       CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 2 ? 8 : 
				       CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 3 ? 16:
				       0; // continous Burst


   wire [2:0] 			       BurstLength_bit = CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 1 ? 2 : 
				       CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 2 ? 3 : 
				       CR_reg[`BurstLength_MSBbit : `BurstLength_LSBbit] == 3 ? 4:
				       0; // continous Burst

initial begin    
   Status = `NoError_msg;
   CR_reg = `ConfigReg_default; 
end 

always @(isSynchronous) begin
   if (Info)
      if (isSynchronous) 
         $write("[%t]  Synchronous Read Mode\n",$time);
      else 
         $write("[%t]  ASynchronous Read Mode\n",$time);
end 
// **********************
//
// ReSet to default value
//
// **********************
always @(Kernel.ResetEvent) begin 
   Status = `NoError_msg;
   CR_reg = `ConfigReg_default;
end

// **************************************
//
// FUNCTION getConfigReg :
//
//      return the Configuration Register
//
// **************************************

function [`ConfigurationReg_dim - 1 : 0] getConfigReg;
   input required;
   begin
      getConfigReg = CR_reg;
   end
endfunction

// *************************************
//
// FUNCTION putConfigReg :
//
//      write the Configuration Register
//
// *************************************

task putConfigReg;
   output [`BYTE_range] outStatus;
   
   reg [`BYTE_range] 	outStatus;

   integer 		count;

   begin
      
      CR_reg = address[`ConfigurationReg_dim - 1 : 0];

      outStatus = Status;        

   end
endtask


endmodule

// ***************************
//
// Electronic Signature Module
//
// ***************************

module SignatureModule;  

   reg error;
   integer i;
   integer n_block;

initial begin
end 

always @(posedge error)  begin
   Kernel.SetWarning(`RSIG_cmd,16'h00,`SignAddrRange_msg);
   error = `FALSE;
end

function [`WORD_range] Get;

   input [`ADDRBUS_range] address;
   
   begin
      if (address[`SignAddress_range] == 9'h00) 
      begin
         Get[`LOW_range] = `ManufacturerCode; 
         Get[`HIGH_range] = 8'h00;
      end
      else if (address[`SignAddress_range] == 9'h01)
      begin 
         if (`organization == "top") Get[`LOW_range] = `TopDeviceCode;  
         else  Get[`LOW_range] = `BottomDeviceCode;  

         Get[`HIGH_range] = 8'h89;
      end
      else if (address[`SignAddress_range] == 9'h02)
      begin 
         Get[`LOW_range] = { 6'b0, BlockLock_man.getLockDownBit(address), BlockLock_man.getLockBit(address) };
         Get[`HIGH_range] =  8'h00; 
      end
      else if (address[`SignAddress_range] == 9'h05)                       // Configuration Register
         Get = ConfigReg_man.getConfigReg(0);       
      else if ((address[`SignAddress_range] >= `REGSTART_addr) && (address[`SignAddress_range] <= `REGEND_addr)) 
      begin 
         Get = ProtectReg_man.RegisterMemory[address[`SignAddress_range] - `REGSTART_addr ];

      end
      else begin
         Get = 8'hXX;
         error = `TRUE;
      end
   end
endfunction

endmodule

// ********************
//
// CUI decoder module :
//      decode commands
//
// ********************

module CUIdecoder1(DataBus,Name,Cmd,CmdAllowed,Info);
   input [`BYTE_range] DataBus, Cmd;
   input [8*35:1]      Name;
   input 	       Info;
   input 	       CmdAllowed;         
always @Kernel.CUIcommandEvent begin
   #1;
   if (DataBus == Cmd  && CmdAllowed) begin  // is a First Command ?
      #1 -> Kernel.VerifyEvent;
      Kernel.CommandDecode1[Cmd] = !Kernel.CommandDecode1[Cmd];
      if (Info) $display("[%t]  Command Issued: %0s",$time,Name);
   end
   else begin
      if (`FALSE) $display("[%t]  The %0s instruction decode unit is waiting for operation to complete.",$time,Name);
      @(Kernel.CompleteEvent or Kernel.ErrorEvent)
	 if (`FALSE) $display("[%t]  The %0s instruction decode unit is listening for next command.",$time,Name);
   end
end
endmodule


// ********************
//
// CUIdecoder manager :
//      decode commands
//
// ********************

module CUIdecoder2(DataBus,Name,Cmd1,Cmd2,CmdAllowed,Info);
   input [`BYTE_range] DataBus, Cmd1, Cmd2;
   input [8*27:1]      Name;
   input 	       Info;
   input 	       CmdAllowed; 

always @Kernel.CUIcommandEvent begin
   if (DataBus == Cmd1 && CmdAllowed) begin
      #1 -> Kernel.VerifyEvent;

      @Kernel.CUIcommandEvent

	 if (DataBus == Cmd2 && CmdAllowed)  begin
	    #1  -> Kernel.VerifyEvent;

            Kernel.CommandDecode2[{Cmd1,Cmd2}] = !Kernel.CommandDecode2[{Cmd1,Cmd2}];
            if (Info) $display("[%t]  Command Issued: %0s",$time,Name);
	 end
   end
   else begin
      if (`FALSE) $display("%t  The %0s instruction decode unit is waiting for operation to complete.",$time,Name);
      @(Kernel.CompleteEvent or Kernel.ErrorEvent)
	 if (`FALSE) $display("%t  The %0s instruction decode unit is listening for next command",$time,Name);
   end
end

endmodule


// ****************************
//
// CUI Decoder Manager :
//      decode the cUI commands
//
// ****************************

module CUIdecoder_Busy1(DataBus,Name,Cmd,CmdAllowed,Info);
   input [`BYTE_range] DataBus, Cmd;
   input [8*8:1]       Name;
   input 	       Info;
   input 	       CmdAllowed; 

always @Kernel.CUIcommandEvent begin
   if ((DataBus == Cmd) && CmdAllowed) begin
      -> Kernel.VerifyEvent;
      Kernel.CommandDecode1[Cmd] = !Kernel.CommandDecode1[Cmd];
      if (Info) $display("[%t]  Command Issued: %0s",$time,Name);
   end



end

endmodule


// Erase Manager
// manage the erase functionality

module EraseModule(address, data, progVoltOK, progHighVoltOK,Info);
   input [`ADDRBUS_range] address;
   input [`WORD_range] 	  data;

   input 		  progVoltOK, progHighVoltOK;

   input 		  Info;
   event 		  ErrorCheckEvent, CompleteEvent;

   reg [`BYTE_range] 	  Status;
   reg [`ADDRBUS_range]   hold_address;
   reg [`BLOCKADDR_range] hold_block;

   reg 			  Busy, Suspended, first_time;
   integer 		  i;
   time 		  startTime, delayTime,Erase_time;

initial begin                   // constructor sequence             
   Busy       = `FALSE;                                                    
   Suspended  = `FALSE;                                               
   Erase_time = `MainBlockErase_time;
   delayTime  =  Erase_time;                                      

end         


function IsBusy;                // boolean function primitive       
   input obbl;                     // all functions require a parameter
   IsBusy = Busy;                // return Boolean value             
endfunction                                                         

function IsSuspended;           // boolean function primitive       
   input obbl;                     // all functions require a parameter
   IsSuspended = Suspended;      // return Boolean value             
endfunction                                                         

function IsAddrSuspended;       // boolean function primitive       
   input [`ADDRBUS_range] addr;
   IsAddrSuspended = (Suspended && (addr == hold_address));
endfunction

function IsBlockSuspended;       // boolean function primitive       
   input [`ADDRBUS_range] addr;
   IsBlockSuspended = (Suspended && ((BankLib_man.getBlock(addr) == BankLib_man.getBlock(/*hold_*/addr/*ess*/))));
endfunction

// *********************
//
// Task checkConfirm :
//    check confirm code
//
// *********************

task checkConfirm;
   
   output  [`BYTE_range] outStatus;
   
   reg [`BYTE_range] 	 outStatus;

   begin

      if (data == `BLKEEconfirm_cmd) outStatus = `NoError_msg;
      else outStatus = `WrongEraseConfirm_msg;

   end
endtask


task Suspend;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
   begin
      delayTime = delayTime - ($time - startTime);
      #`EraseSuspendLatency_time
	 outStatus = `NoError_msg;
      Status = `Suspend_msg;
      Suspended = `TRUE;
      -> CompleteEvent;
   end
endtask

task Resume;
   output [`BYTE_range] Status;
   begin
      Suspended = `FALSE;
      BlockErase(Status);
   end
endtask

task BlockErase;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
   begin


      if (progHighVoltOK) 
         if (BankLib_man.isMainBlock(address)) Erase_time = `FastMainBlockErase_time;
         else  Erase_time = `FastParameterBlockErase_time;
      else 
         if (BankLib_man.isMainBlock(address)) Erase_time   = `MainBlockErase_time;
         else  Erase_time  = `ParameterBlockErase_time;

      delayTime 					      = Erase_time;
      hold_address 					      = address;
      hold_block 					      = BankLib_man.getBlock(address);



      fork
         begin : Operation
            Busy = `TRUE;
            startTime = $time;
            -> ErrorCheckEvent;
            #delayTime Memory_man.EraseBlock(hold_block,Status);
            delayTime = Erase_time;
            -> CompleteEvent;
         end
         @CompleteEvent
            disable Operation;
      join
      outStatus = Status;
      Busy = `FALSE;
   end
endtask

always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (BlockLock_man.IsLocked(hold_address))
      Status = `BlockLock_msg;
   else if (Memory_man.IsBlockSuspended(hold_address))      
      Status = `SuspCmd_msg;
   else if (!progVoltOK)
      Status = `InvVDD_msg;

   if (Status != `NoError_msg)
      ->CompleteEvent;
   else
      fork : ErrorCheck
         @(negedge progVoltOK) Status = `InvVDD_msg;
         @(Status) -> CompleteEvent;
         @(CompleteEvent) disable ErrorCheck;
      join
end

endmodule  //end module Erase


// *********************
//
// Memory Manager :
//      the memory array
// 
// *********************

module MemoryModule(Info);
   input Info;
   reg [`WORD_range] memory [0:(`MEMORY_dim) - 1];     // the Memory: word organization

initial begin 
   LoadMemory;
end 

task LoadMemory;                                // Initialize and load the memory from a file
   integer i;     
   begin
      #0 if (Info) $display("[%t] Inizialize the Memory to default value",$time);
/*      
 Don't need to preload this memory for these testbenches now -- Julius
 
      for (i = 0; i < `MEMORY_dim; i = i + 1)  memory[i] = {16{`HIGH}};    // Memory Init
      
      if (`FILENAME_mem !== "") begin 
         $readmemb(`FILENAME_mem, memory);

         if (Info) $display("[%t] Load Memory from file: %s",$time, `FILENAME_mem);
         else if (Info) $display("[%t] Warning: File: %s not found",$time, `FILENAME_mem);
      end
 */
   end
endtask


function [`WORD_range] Get;
   input [`ADDRBUS_range] address;
   Get = memory[address];
endfunction


function IsSuspended;
   input [`ADDRBUS_range] address;
   IsSuspended = Program_man.IsAddrSuspended(address) || Erase_man.IsAddrSuspended(address) || ProgramBuffer_man.IsAddrSuspended(address);
endfunction

function IsBlockSuspended;
   input [`ADDRBUS_range] address;
   IsBlockSuspended = Program_man.IsBlockSuspended(address) || Erase_man.IsBlockSuspended(address);
endfunction


task Program;
   input [`WORD_range] data;
   input [`ADDRBUS_range] address;
   output [`BYTE_range]   Status;
begin
   Status = `NoError_msg;
   memory[address] = memory[address] & data;
   if (memory[address] != data) Status = `PreProg_msg;
end
endtask

task EraseBlock;
   
   input [`INTEGER] block;
   
   output [`BYTE_range] ErrFlag;

   reg [`ADDRBUS_range] start_address;
   reg [`ADDRBUS_range] end_address;
   reg [`ADDRBUS_range] address;

   
   begin
      ErrFlag 	     = `NoError_msg;
      start_address  = BankLib_man.getBlockAddress(block);
      end_address    = BankLib_man.BlockBoundaryEndAddr[block];

      if (start_address > end_address)
      begin
         address = start_address;
         start_address = end_address;
         end_address = address;
      end
      
      
      for (address = start_address; address <= end_address; address = address + 1)
         memory[address] = `WORDNP;

   end
endtask

task BlockBlankCheck;
   
   input [`INTEGER] block;
   
   output [`BYTE_range] ErrFlag;

   reg [`ADDRBUS_range] start_address;
   reg [`ADDRBUS_range] end_address;
   reg [`ADDRBUS_range] address;

   
   begin
      ErrFlag = `NoError_msg;
      start_address = BankLib_man.BlockBoundaryStartAddr[block];
      end_address   = BankLib_man.BlockBoundaryEndAddr[block];

      if (start_address > end_address)
      begin
         address = start_address;
         start_address = end_address;
         end_address = address;
      end
      
      ErrFlag = `NoError_msg;
      address = start_address;
      while (memory[address] == `WORDNP && address <= end_address ) 
         address = address + 1;
      if (memory[address] != `WORDNP)  
         ErrFlag = `BlankCheckFailed_msg;

   end
endtask 



endmodule //end MemoryModule 


// ***************************************
//
// Output Buffer :
//
//      manage the communication between 
//      the memory and the output data bus
//
// ***************************************

module OutputBufferModule(DataInput, DataInputBurst, DataOutput, OutputEnable);
   input [`WORD_range] DataInput;
   input [`WORD_range] DataInputBurst;
   output [`WORD_range] DataOutput;
   input 		OutputEnable;
   reg [`WORD_range] 	DataOutput;
   time 		timeDataV, timeDataX, timeDataZ;

initial begin
   timeDataV=0;
   timeDataX=0;
   timeDataZ=0;
   SetZ(0);
end

task SetValid;
   input [63:0] delayTime;
   begin

      if ((delayTime+$time > timeDataV) || (timeDataV < $time)) begin
         timeDataV = delayTime + $time;


         disable waitValid;


         disable goValid;

      end
   end
endtask

always   
   fork 
      begin:  goValid

	 #(timeDataV - $time) 
         if (OutputEnable == 1'b0) begin 
            
            if (ConfigReg_man.isASynchronous) DataOutput = DataInput;
            else DataOutput = DataInputBurst;
         end                                  
         
      end // goValid
      begin: waitValid
	 wait (`FALSE);
      end
   join

task SetX;
   input [63:0] delayTime;
   begin
      if ((delayTime+$time < timeDataX) || (timeDataX < $time)) begin
         timeDataX = delayTime + $time;
         disable waitX;


      end
   end
endtask

always fork
   begin : goX
      #(timeDataX - $time) if ((OutputEnable == `LOW) || (timeDataZ > timeDataX))
         DataOutput = 16'hX;
   end // goX
   begin: waitX
      wait (`FALSE);
   end
join

task SetZ;
   input [63:0] delayTime;
   begin
      if ((delayTime+$time < timeDataZ) || (timeDataZ < $time)) begin
         timeDataZ = delayTime + $time;
         disable waitZ;
         if (timeDataZ < timeDataV)
            disable goValid;
         if (timeDataZ < timeDataX)
            disable goX;
      end
   end
endtask

always begin: waitZ
   #(timeDataZ - $time) DataOutput = 16'hZ;
   wait (`FALSE);
end

endmodule


// *********************************
//
// Program module :
//
//      manage the program operation
//
// *********************************

module ProgramModule(address,data, progVoltOK, progHighVoltOK, Info);
   input [`WORD_range] data;
   input [`ADDRBUS_range] address;
   input 		  progVoltOK,progHighVoltOK;
   input 		  Info;
   event 		  ErrorCheckEvent, CompleteEvent;
   reg [`BYTE_range] 	  Status;
   reg [`WORD_range] 	  hold_data;
   reg [`ADDRBUS_range]   hold_address;
   reg 			  Busy, Suspended;

   integer 		  i;
   time 		  startTime, delayTime, WordProgram_time;

initial begin                 // constructor sequence
   Busy = `FALSE;
   Suspended = `FALSE;
   WordProgram_time = `WordProgram_time;
   delayTime = WordProgram_time;
end

always @(progHighVoltOK) begin
   if (progHighVoltOK) WordProgram_time=`FastWordProgram_time;
   else WordProgram_time=`WordProgram_time;
end 

function IsBusy;              // boolean function primitive
   input obbl;                   // all functions require a parameter
   IsBusy = Busy;              // return Boolean value
endfunction

function IsSuspended;         // boolean function primitive
   input obbl;                   // all functions require a parameter
   IsSuspended = Suspended;    // return Boolean value 
endfunction                                                       

function IsAddrSuspended;     // boolean function primitive       
   input [`ADDRBUS_range] addr;
   IsAddrSuspended = (Suspended && (addr == hold_address));
endfunction

function IsBlockSuspended;    // return true if block is suspended
   input [`ADDRBUS_range] addr; begin
      IsBlockSuspended  = (Suspended && (BankLib_man.getBlock(addr) == BankLib_man.getBlock(/*hold_*/addr/*ess*/)));
   end
endfunction


task Suspend;
   output [`BYTE_range] suspErrFlag;
   reg [`BYTE_range] 	suspErrFlag;
   begin
      delayTime = delayTime - ($time - startTime);
      #`ProgramSuspendLatency_time suspErrFlag = `NoError_msg;
      Status = `Suspend_msg;
      Suspended = `TRUE;
      -> CompleteEvent;
   end
endtask

task Resume;
   output [`BYTE_range] ErrFlag;
   begin
      Suspended = `FALSE;
      Program(ErrFlag);
end
endtask

task Program;
   output [`BYTE_range] outErrFlag;
   reg [`BYTE_range] 	outErrFlag;
begin
   if (delayTime == WordProgram_time) begin
      hold_data = data;
      hold_address = address;
   end
   fork
      begin : Operation
         Busy = `TRUE;
         startTime = $time;
         -> ErrorCheckEvent;
         #delayTime Memory_man.Program(hold_data,hold_address,Status);
delayTime = `WordProgram_time;
-> CompleteEvent;
end
      @CompleteEvent disable Operation;
   join
   outErrFlag = Status;
   Busy = `FALSE;
end
endtask

always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (BlockLock_man.IsLocked(hold_address))
      Status = `BlockLock_msg;
   else
      if (Memory_man.IsSuspended(hold_address))
	 Status = `SuspAcc_msg;
      else if (!progVoltOK)
	 Status = `InvVDD_msg;

   if (Status != `NoError_msg) ->CompleteEvent;
   else
      fork : ErrorCheck
         @(negedge progVoltOK) Status = `InvVDD_msg;
         @(Status) -> CompleteEvent;
         @(CompleteEvent) disable ErrorCheck;
      join
end

endmodule // end PrograModule 


// *********************************
//
// Buffer Ehnanced Program module :
//
//      program buffer functionality
//
// *********************************

module BuffEnhancedFactProgramModule(address, data, progVoltOK, progHighVoltOK, Info);
   input [`ADDRBUS_range] address;
   input [`WORD_range] 	  data;
   input 		  progVoltOK, progHighVoltOK, Info;

   event 		  ErrorCheckEvent,ErrorCheckEvent_inVerify, CompleteEvent, WatchAddressEvent;
   reg [`BYTE_range] 	  Status;
   reg [`WORD_range] 	  hold_data, hold_StartBlock;
   reg [`ADDRBUS_range]   hold_address, startAddress;
   reg [`WORD_range] 	  bufferData [`BuffEnhProgramBuffer_range];

   reg 			  Busy;
   time 		  Program_time;
   integer 		  i,Len;

initial begin                 // constructor sequence             
   Busy = `FALSE;
   Status = `NoError_msg;
   Program_time = `WordProgram_time;
   EmptyBuffer;
end                                                               

task EmptyBuffer;
   begin 
      for (i = 0; i < `BuffEnhProgramBuffer_dim; i = i + 1) 
         bufferData[i] = 16'hFFFF;
      Len=0;
   end 
endtask

function IsBusy;              // boolean function primitive       
   input obbl;               // all functions require a parameter
   IsBusy = Busy;              // return Boolean value             
endfunction                                                       

task Setup;
   output [`BYTE_range] outStatus;
   begin
      Status 	       = `NoError_msg;
      Len	       =0;
      startAddress     = address;
      hold_address     = address;

      hold_StartBlock  = BankLib_man.getBlock(address);
      -> ErrorCheckEvent; 
      #0 outStatus=Status;
      if (Status == `NoError_msg) begin 
         if (Info) $display("[%t]  Enhanced Factory Program -> Setup Phase",$time);
         if (Info) $display("[%t]  Enhanced Factory Program: Start address: %h",$time,startAddress);
         #`EnhBuffProgramSetupPhase_time;
         Busy = `TRUE;
      end
   end 
endtask

task Exit;
   output [`BYTE_range] outStatus;
   begin
      Busy = `FALSE;
      outStatus = Status;
      if (Info) $display("[%t]  Enhanced Factory Program -> Exit Phase",$time);
      if (Len != `BuffEnhProgramBuffer_dim)  
         $display("[%t] Warning --- The buffer must be completely filled for programming to occur",$time);
   end
endtask

task Load;
   output [`BYTE_range] outStatus;
   begin
      if (BankLib_man.getBlock(address) != hold_StartBlock) Status = `ExitPHASE_BEFP_msg;
      else begin
         bufferData[Len] = data;
         if (Info) $display("[%t]  Enhanced Factory Program -> Load: data[%d]=%h ",$time,Len,bufferData[Len]);
         Len = Len + 1;
         if (Len == `BuffEnhProgramBuffer_dim) Status = `ProgramPHASE_BEFP_msg;
         
      end 
      outStatus = Status;
   end
endtask

task Program;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
begin
   fork
      begin : Operation
         if (Info) $display("[%t]  Enhanced Factory Program {Program Phase}",$time); 
         #`EnhBuffProgram_time

            if (Info) $display("[%t]  Enhanced Factory Program {End of Program Phase}",$time); 
         for (i = startAddress;i < (`BuffEnhProgramBuffer_dim + startAddress); i = i + 1) begin
            Memory_man.Program(bufferData[i - startAddress],i,Status);
end
         -> CompleteEvent;      //end of program
      end
      @CompleteEvent begin 
         disable Operation;
      end 
   join
   if (Status == `ProgramPHASE_BEFP_msg) begin //prova
      Status = `NoError_msg;
   end
   outStatus = Status;
end
endtask

always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (BlockLock_man.IsLocked(hold_address))
      Status = `BlockLock_msg;
   else if (!progVoltOK)
      Status = `InvVDD_msg;
   else if (!progHighVoltOK)
      Status =  `InvVPP_msg;
   if (Status != `NoError_msg)
      ->CompleteEvent;
   else
      fork : ErrorCheck
         @(negedge progVoltOK) Status = `InvVDD_msg;
         @(negedge progHighVoltOK) Status = `InvVPP_msg;
         @(CompleteEvent) disable ErrorCheck;
      join
end



endmodule

// ******************************************
//
// Protect Register module :
//
//      operations on the protection register
//
// ******************************************

module ProtectRegModule(address, data, voltOK, Info);
   input [`ADDRBUS_range] address;
   input [`DATABUS_range] data;
   input 		  voltOK, Info;
   reg [`WORD_range] 	  RegisterMemory[`REG_dim - 1 :0];
   reg [`BYTE_range] 	  Status;
   reg 			  Busy;
   reg [`ADDRBUS_range]   AddressLatched;
   event 		  ErrorCheckEvent, CompleteEvent;
   integer 		  i;
   reg [`ADDRBUS_range]   hold_addr;
   reg [`DATABUS_range]   hold_data;


initial begin                         // constructor sequence             
   Busy = `FALSE;
   RegisterMemory[0] = `PRL_default;
   for (i = 1; i < `REG_dim; i = i + 1) begin
      RegisterMemory[i] = `WORDNP;
   end  
end


function IsBusy;              // boolean function primitive       
   input required;               // all functions require a parameter
   IsBusy = Busy;              // return Boolean value             
endfunction                                                       

function UDNisLocked;            // boolean function primitive
   input obbl;                           // input is required
   if ((RegisterMemory[`PROTECTREGLOCK_addr - `REGSTART_addr] | `UDNprotect_bit) == `UDNprotect_bit) 
      UDNisLocked = `TRUE;
   else 
      UDNisLocked = `FALSE;
endfunction

function UPisLocked;            // boolean function primitive
   input obbl;                   // input is required
   UPisLocked = ((RegisterMemory[`PROTECTREGLOCK_addr - `REGSTART_addr] | `UPprotect_bit) == `UPprotect_bit) ? `TRUE : `FALSE;
endfunction

function isUDNaddress;
   input [`ADDRBUS_range] address;
   if ((address >= `UDNREGSTART_addr) && ( address <= `UDNREGEND_addr)) // Check UDN register Address Bound 
      isUDNaddress = `TRUE;
   else isUDNaddress = `FALSE;
endfunction

function isUPaddress;
   input [`ADDRBUS_range] address;
   if ((address >= `UPREGSTART_addr) && (address <= `UPREGEND_addr)) // Check UP register Address Bound 
      isUPaddress = `TRUE;
   else isUPaddress = `FALSE;
endfunction

function [`BYTE_range] ExtIndexPRL;            // bit index of PRL register 
   input [`ADDRBUS_range] addr;
   ExtIndexPRL=(addr - `ExtREGSTART_regionaddr) / `ExtREG_regiondim;
endfunction

function isExtLocked;            // boolean function primitive
   input [`ADDRBUS_range] addr;                   // input is required
   reg [`BYTE_range] 	  bitIndex;
   begin 
      bitIndex = ExtIndexPRL(addr);  // protect bit index of Extended Protection Register Memory
      isExtLocked = !(RegisterMemory[(`ExtPROTECTREGLOCK_addr - `REGSTART_addr)][bitIndex]);
   end
endfunction

function isExtValidAddress;
   input [`ADDRBUS_range] address;
   if ((address >= `ExtREGSTART_regionaddr) && (address <= `ExtREGEND_regionaddr) ) // Check ExtRegister Address Bound 
      isExtValidAddress = `TRUE;
   else isExtValidAddress = `FALSE;
endfunction

task Program;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
begin
   Busy = `TRUE;
   hold_addr = address[`REG_addrbitRange];
   hold_data = data;
   if (Info) $write("[%t]  OTP Program Memory[%h]=%h\n",$time,hold_addr,data);
   fork
      begin : Operation
         -> ErrorCheckEvent;
         #`WordProgram_time RegisterMemory[hold_addr - `REGSTART_addr] = RegisterMemory[hold_addr - `REGSTART_addr] & hold_data;   
         -> CompleteEvent;
      end
      @CompleteEvent disable Operation;
   join
   outStatus = Status;
   Busy = `FALSE;
end
endtask

always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (( address < `REGSTART_addr) || ( address > `REGEND_addr)) // Check Address Bound 
      Status = `AddrRange_msg;
   else if ( isUDNaddress(address) && UDNisLocked(1'bX) ) 
      Status = `UDNlock_msg;
   else if ((isUPaddress(address) && UPisLocked(1'bX)))
      Status = `UPlock_msg;
   else if ( isExtValidAddress(hold_addr) & isExtLocked(hold_addr) )
      Status = `ExtREGLock_msg;
   
   else if (Kernel.Suspended)
      Status = `SuspCmd_msg;
   else if (!voltOK)
      Status = `InvVDD_msg;

   if (Status != `NoError_msg)
      ->CompleteEvent;
   else
      fork : ErrorCheck
         @(negedge voltOK) Status = `InvVDD_msg;
         @(Status) -> CompleteEvent;
         @(CompleteEvent) disable ErrorCheck;
      join
end
endmodule //end ProtectRegModule


// Read Manager
// Manage the read operation

module ReadModule(dataOutput,address,voltOK,Info);
   output [`WORD_range] dataOutput;
   input [`ADDRBUS_range] address;
   input 		  voltOK;
   input 		  Info;
   reg [`WORD_range] 	  dataOutput, regRead;
   reg [1:0] 		  Mode, oldMode;
   reg [`BYTE_range] 	  Status;

   integer 		  i;

initial begin
   regRead = 0; 
   Mode = `ReadArray_bus;
   oldMode = `ReadArray_bus;
   dataOutput = `DATABUS_dim'hzzzz;
end

task SetMode;
   input [1:0] newMode;
   output [`BYTE_range] Status;
   begin
      Status = `NoError_msg;
      if (Info && (newMode!=Mode)) begin
         case (newMode)
            `ReadArray_bus        : $display ("[%t]  Device now in Read Array mode ", $time);
            `ReadCFI_bus          : $display ("[%t]  Device now in Read CFI mode ", $time);
            `ReadSignature_bus    : $display ("[%t]  Device now in Read Electronic Signature Mode ", $time);
            `ReadStatusReg_bus    : $display ("[%t]  Device now in Read Status Register Mode ", $time); 
            default               : $display ("[%t]  !!!Model Error: Read mode not recognized!!!", $time);
         endcase

         oldMode=Mode;
         Mode = newMode;
      end
   end
endtask


always @Kernel.ResetEvent begin
   Mode = `ReadArray_bus;
end

always @(negedge Kernel.Ready) begin   // Configure according to status register
   Mode = `ReadStatusReg_bus;
end

always @Kernel.ReadEvent begin          // Main execution of a read is based on an event


   case (Mode)
      `ReadArray_bus       : begin 
         dataOutput = Memory_man.Get(address);
         if (Info) $display("[%t]  Data Read result: memory[%h]=%h", $time,address,dataOutput);
      end 
      `ReadCFI_bus         : begin
         dataOutput = CFIquery_man.Get(address);
         if (Info) $display("[%t]  Data Read result: CFI_memory[%h]=%h", $time,address,dataOutput);
      end  
      `ReadSignature_bus   :  begin
         dataOutput = Signature_man.Get(address);
         if (Info) $display("[%t]  Read Device Identifier(addr=%h) :%h", $time,address,dataOutput);
      end

      `ReadStatusReg_bus   : begin
         dataOutput = SR_man.SR;
         if (Info) $display("[%t]  Read Status Register: %b", $time,dataOutput[`BYTE_range]);
      end 

      default              : $display("[%t]  !!!Model Error: Read mode not recognized!!!", $time);
   endcase
   if ((Mode == `ReadArray_bus) && (Memory_man.IsSuspended(address) == `TRUE)) begin
      dataOutput = 16'hXX;
      Kernel.SetWarning(`RD_cmd,8'hXX,`SuspAcc_msg);
   end
end

endmodule
// end Module Read


// *************************************************
//
// Status Register module :
//
//      implements the Status Register of the device
//
// *************************************************

module StatusRegModule(Info);
   input Info;


   reg 	 EraseStatus, ProgramStatus, 
	 VpenStatus, BlockProtectionStatus, BW_status;

   reg [`BYTE_range] Status;

   wire [7:0] 	     SR = {Kernel.Ready,                        // bit 7 
			   Erase_man.IsSuspended(1'bX),         // bit 6
			   EraseStatus,                         // bit 5
			   ProgramStatus,                       // bit 4
			   VpenStatus,                          // bit 3
			   Program_man.IsSuspended(1'bX) ||  ProgramBuffer_man.IsSuspended(1'bX),       // bit 2
			   BlockProtectionStatus,               // bit 1
			   BW_status};                          // bit 0
   wire [7:0] 	     SR_Info =  SR;



//-----------------
// Init
//-----------------

initial begin
   EraseStatus=1'b0;
   ProgramStatus=1'b0;
   VpenStatus=1'b0;
   BlockProtectionStatus=1'b0;
   BW_status=1'b0;
end


always @(SR_Info) if (Kernel.Ready!=1'bZ)
   if (Info) $display("[%t]  Status Register Update: %b",$time, SR_Info);

always @(Kernel.ResetEvent) begin
   Clear(Status);
end


always @(Kernel.Ready,ProtectReg_man.Busy, BuffEnhancedFactProgram_man.Busy) 
begin
   if (Kernel.Ready) 
      BW_status = `FALSE;
   else 
      if (BuffEnhancedFactProgram_man.Busy == `TRUE) 
         BW_status=`TRUE;

end

always @(Kernel.ErrorEvent) begin //Update status register bits upon specific errors
   #0;
   case(Kernel.GetError(1'bX))
      `InvVDD_msg       : begin VpenStatus = `TRUE; end
      `InvVPP_msg       : begin VpenStatus = `TRUE; end
      `BlockLock_msg    : begin BlockProtectionStatus = `TRUE;  end
      `UDNlock_msg      : begin ProgramStatus = `TRUE; end
      `UPlock_msg       : begin ProgramStatus = `TRUE; end

      `ProtRegAddrRange_msg : begin 
         BlockProtectionStatus = `TRUE;  
      end
      `ExtREGLock_msg   : begin 
         BlockProtectionStatus = `TRUE;  
      end

      `CmdSeq_msg       : begin ProgramStatus = `TRUE; EraseStatus = `TRUE; end
      `AddrRange_msg    : begin ProgramStatus = `TRUE; EraseStatus = `TRUE; end
      `AddrTog_msg      : begin ProgramStatus = `TRUE; EraseStatus = `TRUE; end
      `PreProg_msg      : begin ProgramStatus = `TRUE; end 
      `WrongEraseConfirm_msg : begin ProgramStatus = `TRUE; EraseStatus   = `TRUE; end
      `WrongBlankCheckConfirm_msg : begin 
         ProgramStatus = `TRUE; EraseStatus   = `TRUE; 
      end
      `BlankCheckFailed_msg : begin 
         EraseStatus   = `TRUE; 
      end
      `LeastAddr0:        begin 
         ProgramStatus = `TRUE; 
      end
      

   endcase
   case(Kernel.GetCmd(4'h1))
      `PG_cmd           : begin ProgramStatus = `TRUE; end
      `PRREG_cmd        : begin ProgramStatus = `TRUE; end
      `PB_cmd           : begin ProgramStatus = `TRUE; end
      `BLKEE_cmd        : begin EraseStatus = `TRUE; end
      `BL_cmd           : if (Kernel.GetCmd(4'h2) == `BLconfirm_cmd) ProgramStatus = `TRUE;
      `BUL_cmd          : if (Kernel.GetCmd(4'h2) ==`BULconfirm_cmd) EraseStatus   = `TRUE;
      `BLD_cmd          : if (Kernel.GetCmd(4'h2) ==`BLDconfirm_cmd) ProgramStatus = `TRUE;
      `BuffEnhProgram_cmd :
         if (Kernel.GetCmd(4'h2) == `BuffEnhProgramCfrm_cmd) 
            ProgramStatus = `TRUE;

   endcase 
end  

task Clear;
   output [`BYTE_range] Status;
   begin
      Status = `NoError_msg;
      EraseStatus = `FALSE;
      ProgramStatus = `FALSE;
      VpenStatus  = `FALSE;
      BlockProtectionStatus   = `FALSE;
      BW_status = `FALSE;
   end
endtask

endmodule  // end module status register


// *************
//
// Kernel Module 
//
// *************

module KernelModule(VDD, VDDQ, VPP, Info);
   input [`Voltage_range] VDD, VDDQ, VPP;
   input 		  Info;
   event 		  CUIcommandEvent, VerifyEvent, ErrorEvent, CompleteEvent, ResetEvent, ReadEvent, ProgramCompleteEvent, EraseCompleteEvent;

   reg 			  voltOK, progVoltOK, eraseVoltOK, lockVoltOK, ioVoltOK, lockOverrideOK;
   reg 			  progHighVoltOK, eraseHighVoltOK;
   reg [8'hFF:0] 	  CommandDecode1;
   reg [16'hFFFF:0] 	  CommandDecode2;
   reg [7:0] 		  lastStatus, lastCmd1, lastCmd2;

// Device Status

   wire 		  Ready = (!Program_man.Busy && !ProgramBuffer_man.Busy  && !BuffEnhancedFactProgram_man.Busy
				   && !Erase_man.Busy && !ProtectReg_man.Busy && !BlankCheck_man.Busy);


   wire 		  Suspended = Program_man.Suspended || Erase_man.Suspended || ProgramBuffer_man.Suspended;

initial begin                 // constructor sequence
   CommandDecode1 = 8'h00;         // initialize decode success status variables
   CommandDecode2 = 16'h0000;
end


always @(voltOK) begin
   if (!voltOK) begin 
      $display("[%t]  !ERROR: Invalid VDD Voltage.",$time);
      -> ErrorEvent;
   end
   else     
      $display("[%t]  VDD Voltage is OK",$time);
end

always @(ioVoltOK) begin
   if (!ioVoltOK) begin 
      $display("[%t]  !ERROR: Invalid VDDQ I/O voltage.", $time);
      -> ErrorEvent;
   end 
   else 
      $display("[%t]  VDDQ Voltage is OK",$time);
   
end

always @(VDD) begin        
   if ((VDD < `VDDmin) | (VDD > `VDDmax))
      voltOK = `FALSE;
   else
      voltOK = `TRUE;
end


always @(VDDQ) begin  // check i/o voltage constraints
   if ((VDDQ >= `VDDQmin) && (VDDQ <= `VDDQmax))
      ioVoltOK = `TRUE;
   else 
      ioVoltOK = `FALSE;
end

always @(VPP) begin // program/erase/lock
   if ((VPP>=`VPPmin && VPP<=`VPPmax))  begin
      progVoltOK  = `TRUE;
      eraseVoltOK = `TRUE;
      lockVoltOK  = `TRUE;
      progHighVoltOK  = `FALSE;
      eraseHighVoltOK = `FALSE;
   end
   else if ((VPP>=`VPPHmin) && (VPP<=`VPPHmax)) begin 
      progVoltOK  = `TRUE;
      eraseVoltOK = `TRUE;
      lockVoltOK  = `TRUE;
      progHighVoltOK  = `TRUE;
      eraseHighVoltOK = `TRUE;
   end
   else begin 
      progVoltOK  = `FALSE;
      eraseVoltOK = `FALSE;
      lockVoltOK  = `FALSE;
      progHighVoltOK  = `FALSE;
      eraseHighVoltOK = `FALSE;
   end 
end


function [7:0] GetError;
   input required;
   GetError = lastStatus;
endfunction

function [7:0] GetCmd;
   input commandNum;
   GetCmd = (commandNum == 1) ? lastCmd1 : lastCmd2;
endfunction

task SetWarning;
   input [7:0] Cmd1, Cmd2;
   input [7:0] Status;
   begin
      Report(Cmd1,Cmd2,Status);
      lastStatus = Status;
   end
endtask

task SetError;
   input [7:0] Cmd1, Cmd2;
   input [7:0] ErrFlag;
   begin
      SetWarning(Cmd1,Cmd2,ErrFlag);
      -> ErrorEvent; // Only errors set error event
   end
endtask


task Report;
   input [7:0] Cmd1, Cmd2;
   input [7:0] Status;
   begin
      lastStatus = Status;
      lastCmd1 = Cmd1;
      lastCmd2 = Cmd2;
      if ((lastStatus != `NoError_msg) || Info) begin //Display error .
         $write("[%t] ",$time);
         case(Status)
            `NoError_msg         : begin $write(" Command Completion Successful "); end
            `CmdSeq_msg         : begin $write(" !Error:   [Invalid Command]\n Sequence Command Unknown"); -> ErrorEvent; end
            `SuspCmd_msg        : begin $write(" !Error:   [Invalid Command]\n Cannot execute this command during suspend"); -> ErrorEvent; end
            `SuspAcc_msg        : begin $write(" !Error:   [Invalid Command]\n Cannot access this address due to suspend"); -> ErrorEvent; end
            `SignAddrRange_msg  : begin $write(" !Error:   [Invalid Address]\n Signature Address out of range"); end
            `CFIAddrRange_msg   : begin $write(" !Error:   [Invalid Address]\n CFI Address out of range"); end
            `AddrRange_msg      : begin $write(" !Error:   [Invalid Address]\n Address out of range"); -> ErrorEvent; end
            `AddrTog_msg        : begin $write(" !Error:   [Program Buffer]\n Cannot change block address during command sequence"); -> ErrorEvent; end
            `BuffSize_msg       : begin $write(" !Error:   [Program Buffer]\n Buffer size is too large (Max Size is %d) ",`ProgramBuffer_dim); -> ErrorEvent; end
            `InvVDD_msg         : begin $write(" !Error:   [Invalid Supply]\n Voltage Supply must be: VDD>VDDmin and VDD<VDDmax "); -> ErrorEvent; end
            `InvVPP_msg         : begin $write(" !Error:   [Invalid Program Supply]\n Program Supply Voltage must be: VPP>VPPHmin and VPP<VPPHmax for this Operation"); -> ErrorEvent; end
            `ByteToggle_msg     : begin $write(" !Error:   [BYTE_N Toggled]\n Cannot toggle BYTE_N while busy"); -> ErrorEvent; end
            `PreProg_msg        : begin $write(" !Error:   [Program Failure]\n Program Failure due to cell failure"); -> ErrorEvent; end 
            `UDNlock_msg        : begin $write(" !Error:   [Program Failure]\n Unique Device Number Register is locked"); -> ErrorEvent; end
            `UPlock_msg         : begin $write(" !Error:   [Program Failure]\n User Programmable Register is locked"); -> ErrorEvent; end
            `ExtREGLock_msg     : begin $write(" !Error:   [Program Failure]\n Extended User Programmable OTP is locked"); -> ErrorEvent; end
            `NoUnLock_msg       : begin $write(" #Warning: [Locked Down Warning]\n  Invalid UnLock Block command in Locked-Down Block"); end
            `SuspAccWarn_msg    : begin $write(" #Warning: [Invalid Access]\n  It isn't possible access this address due to suspend"); end
            `BlockLock_msg      : begin $write(" !Error:   [Locked Error]\n Cannot complete operation when the block is locked "); -> ErrorEvent; end
            `BlkBuffer_msg      : begin $write(" !Error: [Program Buffer]  Program Buffer cannot cross block boundary"); end
            `AddrCFI_msg        : begin $write(" #Warning: [Invalid CFI Address]\n CFI Address out of range"); end
            `NoBusy_msg         : begin $write(" #Warning: [NO Busy]\n Device is not Busy"); end
            `NoSusp_msg         : begin $write(" #Warning: [NO Suspend]\n Nothing previus suspend command"); end
            `Suspend_msg        : begin $write("  Suspend of "); end
            `WrongEraseConfirm_msg : begin
               $write(" !Error: [Wrong Erase Confirm Code "); 
               -> ErrorEvent;
            end   
            `LeastAddr0         : begin 
               $write(" !Error:   [Program Failure]\n Least Significative bit [%2d downto 0] of Start Address must be 0",`ProgramBuffer_addrDim-1); 
               -> ErrorEvent;
            end
            
            `WrongBlankCheckConfirm_msg : begin
               $write(" !Error: [Confirm Code] Wrong Blank Check Confirm Code "); 
               -> ErrorEvent;
            end   

            `WrongBlankCheckBlock:  begin 
               $write(" !Error:   [Blank Check Failure]\n The block must be a main block"); 
               -> ErrorEvent;
            end

            `BlankCheckFailed_msg : begin $write(" !Error:   [Blank Check]\n Blank Check Failed "); 
               -> ErrorEvent; 
            end

            default             : begin $write(" !ERROR: [Unknown error]\n Flag=%h, cmd1=%hh, cmd2=%hh",Status,Cmd1,Cmd2); -> ErrorEvent; end
         endcase 
         case (Cmd1)
            16'hXX              : $display(" !Error: [General Error}\n Error not defined");
            `RD_cmd             : $display(" { Read Array }");
            `RSR_cmd            : $display(" { Read Status Register }");
            `RSIG_cmd           : $display(" { Read Electronic Signature }");
            `RCFI_cmd           : $display(" { Read CFI }");
            `PG_cmd             : $display(" { Program }");
            `BuffEnhProgram_cmd : $display(" { Buffer Enhanced Factory Program }");

            `SCR_cmd | `BL_cmd | `BUL_cmd |  `BLD_cmd 
               : begin 
                  if (Cmd2 == `SCRconfirm_cmd) $display(" { Set Configuration Register }");
                  if (Cmd2 == `BLconfirm_cmd)  $display(" { Block Lock }");
                  if (Cmd2 == `BULconfirm_cmd) $display(" { Block UnLock }");
                  if (Cmd2 == `BLDconfirm_cmd) $display(" { Block Lock-Down }");
               end
            `PER_cmd          : $display(" { Program/Erase Resume }");                    
            `PRREG_cmd        : $display(" { Protection Register Command }");
            `BLKEE_cmd        : $display(" { Block Erase }");
            `BLNKCHK_cmd      : $display(" { Blank Check }");
            `CLRSR_cmd        : $display(" { Clear Status Register }");
            `PES_cmd          : $display(" { Program/Erase Suspend }");
            `PB_cmd           : $display(" { Write to Buffer and Program }");
            default           : $display(" {unknown command:  %hh}", Cmd1);
         endcase
      end
   end
endtask

task CheckTime;
   input [8*6:1] tstr;
   input [31:0]  tdiff, tprev;
   
   begin
      if ($time - tprev < tdiff) begin
	 $display ("[%t]  !ERROR: %0s timing constraint violation:  %0d-%0d < %0dns ", $time, tstr, $time, tprev, tdiff);
	 -> ErrorEvent;
      end
   end
endtask

endmodule // end module Kernel 





module x28fxxxp30(A, DQ, W_N, G_N, E_N, L_N, K, WAIT, WP_N, RP_N, VDD, VDDQ, VPP, Info);

// Signal Bus
   input [`ADDRBUS_dim-1:0] A;           // Address Bus 
   inout [`DATABUS_dim-1:0] DQ;          // Data I/0 Bus
// Control Signal
   input 		    W_N;                           // Write Enable 
   input 		    G_N;                           // Output Enable
   input 		    E_N;                           // Chip Enable
   input 		    L_N;                           // Latch Enable
   input 		    K;                             // Clock
   input 		    WP_N;                          // Write Protect
   input 		    RP_N;                          // Reset/Power-Down

// Voltage signal rappresentad by integer Vector which correspond to millivolts
   input [`Voltage_range]   VDD;           // Supply Voltage
   input [`Voltage_range]   VDDQ;          // Input/Output Supply Voltage
   input [`Voltage_range]   VPP;           // Optional Supply Voltage for fast Program & Erase

// Others Signal       
   output 		    WAIT;                          // Wait
   reg 			    wait_;
assign WAIT = wait_;
   input 		    Info;                           // Enable/Disable Information of the operation in the memory 
   wire 		    CLK;
assign CLK = (K ~^ ConfigReg_man.isRisingClockEdge);
   reg 			    CLOCK;
// === Internal Signal ===
// Chip Enable 
   wire 		    CE_N = E_N & Kernel.voltOK & RP_N;

// Output Enable 
   wire 		    OE_N = G_N | CE_N | !Kernel.ioVoltOK | !RP_N;
// Write Enable 
   wire 		    WE_N = W_N | CE_N;

// Latch Enable

   wire 		    LE_N = L_N | CE_N;
// === Bus Latch ===
// Data Bus
   wire [`DATABUS_dim-1:0]  DataBusIn;
   wire [`DATABUS_dim-1:0]  DataBurst;

// read burst is in wait state
   wire 		    isWait; 

// Address Bus
   reg [`ADDRBUS_dim - 1:0] AddrBusIn;

// Status
//aggiunti stati buffenha...e blank....
   reg [`BYTE_range] 	    KernelStatus, ReadStatus, EraseStatus, ProgramStatus, BuffEnhancedProgramStatus,
			    LockStatus, ConfigStatus, BufferStatus,BlankCheckStatus,ProgramBufferStatus,
			    SuspendStatus, ResumeStatus, ClearSRStatus, ProtectRegStatus;


   reg [`BYTE_range] 	    status=`Free_pes;

//address latching in read operation
always @(negedge LE_N) if (W_N==`HIGH)  begin
   if (KernelStatus == `READY && ConfigReg_man.isASynchronous) 
      @(posedge LE_N) begin
         if (L_N)

            AddrBusIn = A;                // AddressBus has been Latched

      end
end

always @(negedge LE_N) if (W_N==`HIGH) begin :latching_a
   if (KernelStatus == `READY) begin
      if(ConfigReg_man.isSynchronous)
         fork
            
            begin : L_Address

               @(posedge LE_N) if (L_N) begin
                  
                  AddrBusIn = A;                // AddressBus has been Latched
                  disable K_Address;

               end
            end    
            
            begin : K_Address

               @(posedge CLK) begin

                  AddrBusIn = A;                // AddressBus has been Latched
                  disable L_Address;
               end
            end 
         join

   end
end


always @(negedge WE_N) begin
   if (KernelStatus==`READY) 
      @(posedge WE_N) begin
         if(OE_N==`HIGH)
            AddrBusIn = A;                // AddressBus has been Latched

      end                
end

   integer i;
   integer n_block;

// Wait Driver 
   time    timeWaitDriver,timeWaitDriverZ;

   reg 	   PB_init=0;
   reg 	   P_init=0;
   reg 	   BP_init=0;
   reg 	   Prog_init=0;

always @(PB_init,P_init,BP_init) begin
   Prog_init=(PB_init ||P_init || BP_init);
end

   wire [`BYTE_range] AccessTime;

// ****************
// 
// Modules Istances
//
// ****************

DataErrorModule   DataError_man();              // Check for errors on UserData.h

CUIdecoder1       ReadArray_Command  (DQ[`LOW_range], "Read Array                         ", `RD_cmd, (Kernel.Ready && !Prog_init),        Info),
   ReadSR_Command     (DQ[`LOW_range], "Read Status Register               ", `RSR_cmd, !Prog_init,        Info),
   ReadSign_Command   (DQ[`LOW_range], "Read Electronic Signature          ", `RSIG_cmd, (Kernel.Ready && !Prog_init),       Info),
   ReadCFI_Command    (DQ[`LOW_range], "Read CFI                           ", `RCFI_cmd, (Kernel.Ready && !Prog_init),      Info),
   Program_Command    (DQ[`LOW_range], "Program                            ", `PG_cmd,   (Kernel.Ready && !Prog_init),      Info),

   ProgramBuffer_Command    (DQ[`LOW_range], "Program Buffer                     ", `PB_cmd, (Kernel.Ready && !Prog_init),        Info),
   ProgramReg_Command (DQ[`LOW_range], "Protection Register Program        ", `PRREG_cmd,  (Kernel.Ready && !Prog_init),    Info),
   Resume_Command     (DQ[`LOW_range], "Resume                             ", `PER_cmd,  (Kernel.Ready && Kernel.Suspended),      Info),
   BlockErase_Command  (DQ[`LOW_range], "Block Erase                        ", `BLKEE_cmd,(Kernel.Ready && !Prog_init),      Info),
   ClearSR_Command    (DQ[`LOW_range], "Clear Status Register              ", `CLRSR_cmd, (Kernel.Ready && !Prog_init),     Info),

   BlankCheck_Command  (DQ[`LOW_range], "Blank Check                        ", `BLNKCHK_cmd, (Kernel.Ready && !Prog_init),   Info),
   BuffEnhactoryProgram_Command (DQ[`LOW_range], "Buffer Enh.Factory Program  [Setup]", `BuffEnhProgram_cmd,(Kernel.Ready && !Prog_init), Info);


CUIdecoder_Busy1  Suspend_Command    (DQ[`LOW_range], "Suspend ",   `PES_cmd, !Kernel.Ready, Info);

CUIdecoder2        BlockLock_Command (DQ[`LOW_range], "Block Lock                 ", `BL_cmd,       `BLconfirm_cmd, (Kernel.Ready && !Prog_init),    Info),
   BlockUnlock_Command (DQ[`LOW_range], "Block UnLock               ", `BUL_cmd,      `BULconfirm_cmd, (Kernel.Ready && !Prog_init),   Info),
   BlockLockDown_Command (DQ[`LOW_range], "Block Lock-Down            ", `BLD_cmd,      `BLDconfirm_cmd, (Kernel.Ready && !Prog_init),   Info),
   SetConfigReg_Command (DQ[`LOW_range], "Set Configuration Register ", `SCR_cmd,      `SCRconfirm_cmd, (Kernel.Ready && !Prog_init),   Info);

KernelModule            Kernel            (VDD, VDDQ, VPP, Info);
ReadModule              Read_man          (DataBusIn, AddrBusIn, Kernel.ioVoltOK, Info);
OutputBufferModule      OutputBuffer_man  (DataBusIn, DataBurst, DQ, OE_N);
StatusRegModule         SR_man            (Info);
MemoryModule            Memory_man        (Info);
ProgramModule           Program_man       (AddrBusIn, DQ, Kernel.progVoltOK, Kernel.progHighVoltOK, Info);

BuffEnhancedFactProgramModule BuffEnhancedFactProgram_man(AddrBusIn, DQ, Kernel.progVoltOK, Kernel.progHighVoltOK, Info);
ProtectRegModule        ProtectReg_man    (AddrBusIn, DQ, Kernel.progVoltOK, Info);
EraseModule             Erase_man         (AddrBusIn, DQ, Kernel.eraseVoltOK, Kernel.progHighVoltOK, Info);


BlankCheckModule        BlankCheck_man    (AddrBusIn, DQ, Kernel.eraseVoltOK, Kernel.progHighVoltOK, Info);

BlockLockModule         BlockLock_man     (AddrBusIn, WP_N, RP_N, Info);
ProgramBufferModule   ProgramBuffer_man (AddrBusIn, DQ, Kernel.progVoltOK, Info);
SignatureModule         Signature_man     ();        // , `FALSE);
CFIqueryModule          CFIquery_man      ();        // , `TRUE);
ConfigRegModule         ConfigReg_man     (AddrBusIn,Info);                              // implements the Configuration Register
BurstModule             Burst_man         (AddrBusIn, DataBurst, isWait, CLK, CLOCK, L_N, G_N,W_N, Info);

BankLib                 BankLib_man       ();
TimingDataModule        TimingData_man    ();
TimingLibModule         TimingLib_man     (A,DQ,W_N,G_N,E_N,L_N,WP_N,K,VPP);

initial begin

   $timeformat(-9, 0, " ns", 12);               // Format time displays to screen
   -> Kernel.ResetEvent;                        // Reset Device 
   KernelStatus = `BUSY;                        // Device is Busy
   $display ("[%t]  --- Device is Busy  (start up time) --- ", $time);
   #(TimingData_man.tVDHPH) KernelStatus = `READY;              // End of Start-Up Time
   $display ("[%t]  --- Device is Ready (end of start-up time) --- ", $time);

   AddrBusIn = `ADDRBUS_dim'hZ;

   wait_ = 1'hZ;
   CLOCK = 1'b0;
end

// Recognize command input
always @(negedge WE_N) begin
   if (KernelStatus==`READY) 
      @(posedge WE_N) begin

         -> Kernel.CUIcommandEvent;               // new command has been written into Kernel.

      end
end

// Check error
always @(Kernel.CUIcommandEvent) begin : Timeout  
   #3
      -> Kernel.ErrorEvent;                      
   disable Verify;                                 
end

// Verify command issued 
always @(Kernel.CUIcommandEvent) begin : Verify   
   @(Kernel.VerifyEvent)  

      disable Timeout;          
end

// Default to Read Array command
always @(negedge OE_N) begin
   if (OE_N == `LOW && (ConfigReg_man.isASynchronous)) begin
      if (L_N==0) AddrBusIn=A;
      #1 
         -> Kernel.ReadEvent;
   end      
end

// Page Read
always @(A) begin
   
   if ((OE_N == `LOW) &&  (A !== `ADDRBUS_dim'hZ) && (A !== `ADDRBUS_dim'hx) && (ConfigReg_man.isASynchronous))  begin
      AddrBusIn = A;
      #0 -> Kernel.ReadEvent;
      
   end 
end 


// Reset the Kernel
always @(negedge RP_N) begin 
   -> Kernel.ResetEvent;
   if (Info) $display ("[%t]  Device has been reset ", $time);
   KernelStatus = `BUSY;
   @(posedge RP_N) KernelStatus = `READY;
end

// ----- Recognize Command Input -----
always @(Kernel.CommandDecode1[`RD_cmd]) if (KernelStatus==`READY)  begin                        // Read Array
   Read_man.SetMode(`ReadArray_bus, ReadStatus);
   Kernel.Report(`RD_cmd, 8'hXX, ReadStatus);
   #1 -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode1[`RSR_cmd]) if (KernelStatus==`READY) begin                       // Read Status Register
   Read_man.SetMode(`ReadStatusReg_bus, ReadStatus);
   Kernel.Report(`RSR_cmd, 8'hXX, ReadStatus); 
   #1 -> Kernel.CompleteEvent;
end


always @(Kernel.CommandDecode1[`RSIG_cmd]) if (KernelStatus==`READY )  begin                      // Read Electronic Signature
   Read_man.SetMode(`ReadSignature_bus, ReadStatus);
   Kernel.Report(`RSIG_cmd, 8'hXX, ReadStatus);
   #1 -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode1[`RCFI_cmd]) if (KernelStatus==`READY)  begin                      // Read CFI 
   Read_man.SetMode(`ReadCFI_bus, ReadStatus);
   Kernel.Report(`RCFI_cmd, 8'hXX, ReadStatus); 
   #1 -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode1[`PG_cmd]) if (KernelStatus==`READY) begin                     // Program
   P_init=1;
   @Kernel.CUIcommandEvent
	  #1 -> Kernel.VerifyEvent;
   Program_man.Program(ProgramStatus);
Kernel.Report(`PG_cmd, 8'hXX, ProgramStatus);
-> Kernel.CompleteEvent;
P_init=0;
end


always @(Kernel.CommandDecode1[`PRREG_cmd]) if (KernelStatus==`READY)  begin                      // Protection Register Program
   @Kernel.CUIcommandEvent 
      #1 -> Kernel.VerifyEvent;
   ProtectReg_man.Program(ProtectRegStatus);
Kernel.Report(`PRREG_cmd, 8'hXX, ProtectRegStatus);
-> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode1[`PES_cmd]) if (KernelStatus==`READY) begin                       // Suspend
   if (Program_man.IsBusy(1'bX))
      Program_man.Suspend(SuspendStatus);
   else if (ProgramBuffer_man.IsBusy(1'bX))
      ProgramBuffer_man.Suspend(SuspendStatus); 
   else if (Erase_man.IsBusy(1'bX))
      Erase_man.Suspend(SuspendStatus);
   -> Kernel.CompleteEvent;
end


always @(Kernel.CommandDecode1[`PER_cmd]) if (KernelStatus==`READY) begin                       // Program/Erase Resume
   ResumeStatus = `NoError_msg;
   if (Program_man.IsSuspended(1'bX)) begin
      Program_man.Resume(ProgramStatus);
      Kernel.Report(`PG_cmd, 8'hXX, ProgramStatus);
   end
   else if (ProgramBuffer_man.IsSuspended(1'bX)) begin 
      ProgramBuffer_man.Resume(BufferStatus);
      Kernel.Report(`PB_cmd, 8'hXX, BufferStatus);
   end
   else if (Erase_man.IsSuspended(1'bX)) begin
      Erase_man.Resume(EraseStatus);
      Kernel.Report(`BLKEE_cmd, 8'hXX, EraseStatus);
   end
   else
      ResumeStatus = `NoSusp_msg;
   Kernel.Report(`PER_cmd, 8'hXX, ResumeStatus);
   -> Kernel.CompleteEvent;

end

always @(Kernel.CommandDecode1[`BLKEE_cmd]) if (KernelStatus==`READY) begin                    // Block Erase
   Read_man.SetMode(`ReadStatusReg_bus,ReadStatus);
   EraseStatus=`NoError_msg;
   @Kernel.CUIcommandEvent
               Erase_man.checkConfirm(EraseStatus);
   #1 -> Kernel.VerifyEvent;
   if (EraseStatus != `NoError_msg)
      Kernel.Report(`BLKEE_cmd, `BLKEEconfirm_cmd, EraseStatus);
   else
   begin
      Erase_man.BlockErase(EraseStatus);
      Kernel.Report(`BLKEE_cmd, `BLKEEconfirm_cmd , EraseStatus);
      -> Kernel.CompleteEvent;
   end        
end

always @(Kernel.CommandDecode1[`CLRSR_cmd]) if (KernelStatus==`READY)  begin                    // Clear Status Register
   SR_man.Clear(ClearSRStatus);
   Kernel.Report(`CLRSR_cmd, 8'hXX, ClearSRStatus); 
   #1 -> Kernel.CompleteEvent;
end


//aggiunta ************************************************
// PB Fast Program Commands
always @(Kernel.CommandDecode1[`PB_cmd]) if (KernelStatus==`READY)  begin                       // Write to Program and Buffer 
   ProgramBufferStatus = `NoError_msg;
   PB_init=1;
   Read_man.SetMode(`ReadStatusReg_bus, ReadStatus);
   @Kernel.CUIcommandEvent 
      ProgramBuffer_man.SetCount(ProgramBufferStatus);
   #1 -> Kernel.VerifyEvent;
   
   if (ProgramBufferStatus == `NoError_msg) begin
      for (i=1; i <= ProgramBuffer_man.GetCount(1'bX); i=i+1) begin : GetData
         @Kernel.CUIcommandEvent
             #1;

         ProgramBuffer_man.Load(ProgramBufferStatus);
         #1 -> Kernel.VerifyEvent;
         if (ProgramBufferStatus != `NoError_msg)
            disable GetData;
      end
      @Kernel.CUIcommandEvent
         if (DQ[`BYTE_range] != `PBcfm_cmd)
            ProgramBufferStatus = `CmdSeq_msg;
         else begin
            #1 -> Kernel.VerifyEvent;
            ProgramBuffer_man.Program(ProgramBufferStatus);
end
   end
   Kernel.Report(`PB_cmd, 8'hXX, ProgramBufferStatus);
   ->Kernel.CompleteEvent;
   PB_init=0;
end
//*************************************************************************

always @(Kernel.CommandDecode2[{`BL_cmd,`BLconfirm_cmd}]) if (KernelStatus==`READY)  begin      // Block Lock
   BlockLock_man.Lock(LockStatus);
   Kernel.Report(`BL_cmd, `BLconfirm_cmd, LockStatus);
   -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode2[{`BUL_cmd,`BULconfirm_cmd}]) if (KernelStatus==`READY) begin    // Block UnLock
   BlockLock_man.UnLock(LockStatus);
   Kernel.Report(`BUL_cmd,`BULconfirm_cmd, LockStatus);
   -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode2[{`BLD_cmd,`BLDconfirm_cmd}]) if (KernelStatus==`READY)  begin    // Block Lock-Down
   BlockLock_man.LockDown(LockStatus);
   Kernel.Report(`BLD_cmd,`BLDconfirm_cmd, LockStatus);
   -> Kernel.CompleteEvent;
end

always @(Kernel.CommandDecode2[{`SCR_cmd,`SCRconfirm_cmd}]) if (KernelStatus==`READY) begin    // Set Configuration Register
   ConfigReg_man.putConfigReg(ConfigStatus);
   Kernel.Report(`SCR_cmd,`SCRconfirm_cmd, ConfigStatus);
   -> Kernel.CompleteEvent;
end


// BC
always @(Kernel.CommandDecode1[`BLNKCHK_cmd]) if (KernelStatus==`READY)  begin                    // Blank Check
   BlankCheckStatus=`NoError_msg;
   Read_man.SetMode(`ReadStatusReg_bus, ReadStatus);
   @Kernel.CUIcommandEvent
      BlankCheck_man.checkConfirm(BlankCheckStatus);
   #1 -> Kernel.VerifyEvent;
   
   if (BlankCheckStatus != `NoError_msg) begin
      
      Kernel.Report(`BLNKCHK_cmd, `BLNKCHKconfirm_cmd, BlankCheckStatus);
   end else
   begin
      BlankCheck_man.BlankCheck(BlankCheckStatus);
      Kernel.Report(`BLNKCHK_cmd, `BLNKCHKconfirm_cmd, BlankCheckStatus);
   end        
   -> Kernel.CompleteEvent;

end
// BEFP 
always @(Kernel.CommandDecode1[`BuffEnhProgram_cmd]) if (KernelStatus==`READY)  begin    // Buffer Enhanced Factory Program: Setup Phase
   Read_man.SetMode(`ReadStatusReg_bus, ReadStatus);
   BP_init=1;
   @Kernel.CUIcommandEvent
           #1 -> Kernel.VerifyEvent;
   if (Kernel.Suspended | !Kernel.Ready)
      BuffEnhancedProgramStatus = `SuspCmd_msg;
   else begin 
      if (DQ[`LOW_range]!=`BuffEnhProgramCfrm_cmd)  
         BuffEnhancedProgramStatus=`CmdSeq_msg;     
      else begin 
         if (Info) $display("[%t]  Command Issued: Buffer Enh.Factory Program  [Confirm]",$time);
         
         BuffEnhancedFactProgram_man.Setup(BuffEnhancedProgramStatus);
         if (BuffEnhancedProgramStatus == `NoError_msg) begin 
            while (BuffEnhancedProgramStatus == `NoError_msg)  begin               // Loop Program - Enhanced Factory Program: Program Phase
               if (Info) $display("[%t]  Enhanced Factory Program -> Load Phase",$time);
               
               while (BuffEnhancedProgramStatus == `NoError_msg ) begin               // Loop Load - Enhanced Factory Program: Load Phase
                  @Kernel.CUIcommandEvent
						 #1 -> Kernel.VerifyEvent;
                  BuffEnhancedFactProgram_man.Load(BuffEnhancedProgramStatus);
               end 
               if (BuffEnhancedProgramStatus==`ProgramPHASE_BEFP_msg) begin
                  BuffEnhancedFactProgram_man.Program(BuffEnhancedProgramStatus);
end        
            end 
            BuffEnhancedFactProgram_man.Exit(BuffEnhancedProgramStatus);
         end
      end 
      if (BuffEnhancedProgramStatus == `ExitPHASE_BEFP_msg) 
         BuffEnhancedProgramStatus = `NoError_msg;
   end 
   Kernel.Report(`BuffEnhProgram_cmd,`BuffEnhProgramCfrm_cmd, BuffEnhancedProgramStatus);
   -> Kernel.CompleteEvent;
   BP_init=0;
end



//***********************************************************

// Decode Delays for Page Mode Reads

//******************************************************

// Page mode
always 
begin :nopage
   @(A[`ADDRBUS_dim - 1:4])
      disable page;          

   OutputBuffer_man.SetValid(TimingData_man.tAVQV);
end 

// Page mode
always
begin :page
   @(A[3:0]) //pagina di 16 words
      OutputBuffer_man.SetValid(TimingData_man.tAVQV1);
end 


// Output Buffer delays 

always @(negedge E_N) begin
   OutputBuffer_man.SetX(TimingData_man.tELQX);
   OutputBuffer_man.SetValid(TimingData_man.tELQV);

end

always @(negedge G_N) begin
   #0;
   OutputBuffer_man.SetX(TimingData_man.tGLQX);
   OutputBuffer_man.SetValid(TimingData_man.tGLQV);

end

always @(posedge CLK) begin
   CLOCK = !CLOCK;
end

always @(negedge CLK) begin
   CLOCK = !CLOCK;
end



   reg waiting=1;

always @(posedge G_N) begin

   waiting=1;

end



always @(CLK) begin

   if ((!G_N) && (CE_N == `LOW) && (ConfigReg_man.isSynchronous) && (CLK)) begin

      if (ConfigReg_man.isWaitBeforeActive && Burst_man.firstEOWL && waiting) begin
         OutputBuffer_man.SetX(TimingData_man.tKHQX);
         @(posedge (CLK))
            OutputBuffer_man.SetX(TimingData_man.tKHQX);
         OutputBuffer_man.SetValid(TimingData_man.tKHQV);
         waiting=0;

      end else begin
         
         OutputBuffer_man.SetX(TimingData_man.tKHQX);
         OutputBuffer_man.SetValid(TimingData_man.tKHQV);
         
      end
      
   end 
end 

always @(negedge L_N) if(W_N==`HIGH)begin
   if (ConfigReg_man.isSynchronous && CE_N==`LOW) begin
      OutputBuffer_man.SetValid(TimingData_man.tLLQV);
      

   end
end


always @(RP_N) begin
   if (RP_N == `HIGH)
      OutputBuffer_man.SetValid(TimingData_man.tPHWL);
end

always @(posedge CE_N) begin
   OutputBuffer_man.SetZ(TimingData_man.tEHQZ);
end

always @(posedge G_N) begin
   OutputBuffer_man.SetZ(TimingData_man.tGHQZ);
   OutputBuffer_man.SetZ(TimingData_man.tGHTZ);

end



////////////////////////////////
always @(CE_N) begin 
   if (CE_N == `LOW && W_N==`HIGH && G_N == `LOW) begin 
      if (ConfigReg_man.isSynchronous)  
         wait_ = #(TimingData_man.tELTV) ConfigReg_man.isWaitPolActiveHigh;
      else wait_ = #(TimingData_man.tELTV) !ConfigReg_man.isWaitPolActiveHigh;
   end
   else
      wait_ = #(TimingData_man.tEHTZ) 1'hZ;
end 

always @(G_N) begin 
   if (G_N == `LOW && CE_N == `LOW && W_N==`HIGH) begin
      if (ConfigReg_man.isSynchronous) begin
         wait_ = #(TimingData_man.tGLTV) ConfigReg_man.isWaitPolActiveHigh;
      end else begin
         wait_ = #(TimingData_man.tGLTV) !ConfigReg_man.isWaitPolActiveHigh;
      end
   end
   else begin if (G_N == `HIGH )  
      wait_ = #(TimingData_man.tGHTZ) 1'hZ;
      
      disable Burst_man.pollingBurst;
   end
end 




always @(isWait) begin

   if ((CE_N == `LOW) && (G_N == `LOW) && ConfigReg_man.isSynchronous ) begin
      
      if (CLK) begin
         if (isWait == `LOW ) begin
            if(!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) ConfigReg_man.isWaitPolActiveHigh;
            else wait_ = #(TimingData_man.tKHTX) ConfigReg_man.isWaitPolActiveHigh;
         end else begin
            if (!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) !ConfigReg_man.isWaitPolActiveHigh;
            else wait_ = #(TimingData_man.tKHTX) !ConfigReg_man.isWaitPolActiveHigh;
         end        

      end else 
	 
         fork 
            
            begin
               @(posedge(CLK)) 
		  
		  if (isWait == `LOW) begin
                     if(!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) ConfigReg_man.isWaitPolActiveHigh;
                     else wait_ = #(TimingData_man.tKHTX) ConfigReg_man.isWaitPolActiveHigh;
		  end else begin
                     if (!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) !ConfigReg_man.isWaitPolActiveHigh;
                     else wait_ = #(TimingData_man.tKHTX) !ConfigReg_man.isWaitPolActiveHigh;
		  end 
            end
	    

            begin
               
               @(isWait)
		  
		  if (CLK) begin
		     if (isWait == `LOW) begin
			if(!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) ConfigReg_man.isWaitPolActiveHigh;
			else wait_ = #(TimingData_man.tKHTX) ConfigReg_man.isWaitPolActiveHigh;
		     end else begin
			if (!Burst_man.nWait) wait_ = #(TimingData_man.tKHTV) !ConfigReg_man.isWaitPolActiveHigh;
                        else wait_ = #(TimingData_man.tKHTX) !ConfigReg_man.isWaitPolActiveHigh;
		     end

		  end
            end   

	 join
      
      
   end else if  (G_N == `HIGH && isWait == `HIGH && W_N==`HIGH)
      $display("%t --- WARNING --- WAIT should be deasserted but OE# is not yet LOW. Please check the timings!",$time);
end 


endmodule



// *********************************
//
// Burst module :
//
//      manage the Read Burst operation
//
// *********************************

module BurstModule(address, data, ISWAIT, CLK, CLOCK, L_N, G_N, W_N, Info);
   input [`ADDRBUS_range] address;
   output [`WORD_range]   data;
   reg [`WORD_range] 	  data;

   input 		  CLK;
   input 		  CLOCK;
   input 		  L_N;
   input 		  G_N;
   input 		  W_N;
   output 		  ISWAIT;
   input 		  Info;

   reg [`ADDRBUS_range]   Start_address, Sync_address,new_address;
   reg 			  EnableBurst, isValidData, IsNowWait, endSingleSynchronous;
   reg [2:0] 		  incLSBaddress, incMSBaddress, temp_address;

   wire 		  isSingleSynchronous = (Read_man.Mode != `ReadArray_bus) ? `TRUE : `FALSE;

   integer 		  WaitState,nWait,nRead,xLatency;
//aggiunta per il calcolo degli nwait
   integer 		  boundary,offset;
   reg 			  firstEOWL;

initial begin                 // constructor sequence
   Start_address = `ADDRBUS_dim'h000000;
   EnableBurst = `FALSE;
   endSingleSynchronous = `FALSE;
   data = 16'hZZ;
   nWait = 0;
   IsNowWait = `FALSE;
   isValidData = `FALSE;
   xLatency=0;
   nRead=0;
   WaitState=0;
   firstEOWL=0;
end

always @(G_N) if (G_N==`TRUE) begin
   IsNowWait = `FALSE;
   isValidData = `FALSE;
   EnableBurst = `FALSE;
   endSingleSynchronous = `FALSE;
   data = 16'hZZ;
   nWait = 0;
   xLatency=0;
   nRead=0;
   WaitState=0;
   firstEOWL=0;
end


always @(isValidData) begin
   case (isValidData)

      1: if (!ConfigReg_man.isWaitBeforeActive) begin
         
         IsNowWait = `TRUE;
      end 

      0: begin if (!ConfigReg_man.isWaitBeforeActive) 
         IsNowWait = `FALSE;

         
      end
      
   endcase
end 


assign ISWAIT = (IsNowWait) ? `TRUE : `FALSE;


always @(negedge L_N) if(W_N==`HIGH) begin  : pollingBurst
   fork  : pollingBurst

      begin: L_lacthing
	 @(posedge L_N) if (ConfigReg_man.isSynchronous) begin 
            #1;
            Start_address = address;
            Sync_address =  address;
            firstEOWL=0;
            disable K_lacthing;
            
            @(posedge CLK) begin

               case(ConfigReg_man.BurstLength)

                  0: begin
                     boundary =16;
                     offset = address[3:0];
                  end
                  
                  16:begin
                     boundary =16;
                     offset = address[3:0];
                  end

                  8: begin
                     boundary =8;
                     offset = address[2:0];
                  end


                  4:begin
                     boundary =4;
                     offset = address[1:0];
                  end
               endcase
               
               xLatency = ConfigReg_man.Xlatency;
               WaitState = xLatency - (boundary - offset);
               
               if (WaitState < 0) WaitState =0; 
               nWait = 0;
               EnableBurst = `TRUE;
               data = 16'hXX;
               nRead = 0;
               isValidData = `FALSE;
               endSingleSynchronous=`FALSE;
               disable pollingBurst;
            end
         end
         else EnableBurst = `FALSE;
      end

      begin: K_lacthing
	 @(posedge CLK) if (ConfigReg_man.isSynchronous && L_N==`LOW) begin 
            #1;
            Start_address = address;
            Sync_address =  address;
            firstEOWL=0;
            disable L_lacthing;

            @(posedge CLK) begin

               case(ConfigReg_man.BurstLength)

                  0: begin
                     boundary =16;
                     offset = address[3:0];
                  end
                  
                  16:begin
                     boundary =16;
                     offset = address[3:0];
                  end

                  8: begin
                     boundary =8;
                     offset = address[2:0];
                  end


                  4:begin
                     boundary =4;
                     offset = address[1:0];
                  end
               endcase
               
               xLatency = ConfigReg_man.Xlatency;
               WaitState = xLatency - (boundary - offset); //
               if (WaitState < 0) WaitState =0; 
               nWait = 0;
               EnableBurst = `TRUE;
               data = 16'hXX;
               nRead = 0;
               isValidData = `FALSE;
               endSingleSynchronous=`FALSE;
               disable pollingBurst;
            end
         end
         else EnableBurst = `FALSE;
      end
   join
   $display("  %t address=%h",$time,Start_address);
end


always @(posedge (CLK)) if(G_N==`LOW) begin 
   if (EnableBurst) begin
      if (xLatency == 2 && ConfigReg_man.isWaitBeforeActive)
	 IsNowWait = `TRUE;

      if (xLatency == 1) begin
         isValidData = `TRUE;
         if (offset == 4'd15 && ConfigReg_man.isWaitBeforeActive && WaitState!=0 && (ConfigReg_man.isNoWrapBurst || ConfigReg_man.BurstLength == 5'd00)) begin
            IsNowWait = `FALSE;

	 end

	 
      end
      if (xLatency) xLatency = xLatency - 1; //vuol dire se xLatency e' >1 o diverso da zero????
   end     
end

always @(nRead) begin 
   if (isSingleSynchronous && nRead>=1) begin //End of SingleBurstRead???
      endSingleSynchronous=`TRUE;
      isValidData = `FALSE;
   end
   if((offset + nRead) == 4'd15 && ConfigReg_man.isWaitBeforeActive && WaitState!=0 && (ConfigReg_man.isNoWrapBurst || ConfigReg_man.BurstLength == 5'd00)) begin
      IsNowWait = `FALSE;

   end
   
end


always @(CLK) begin 
   
   if (EnableBurst) begin
      
      if (!xLatency) begin // burst is ongoing(after xLatency)
         
         if (!G_N) begin 
            
            if (nWait || endSingleSynchronous) data = `DATABUS_dim'hXXXX; //Wait State;
            
            else begin  // Read is Possible!
               // -- \\ 
               case (Read_man.Mode)
                  `ReadArray_bus       : begin  
                     data = Memory_man.Get(Sync_address);
                     @(posedge (CLK)) if (Info && !G_N) $write("[%t]  Burst Read: Memory[%h]=%h\n",$time,Sync_address,data);
                  end
                  `ReadCFI_bus         : begin 
                     data = CFIquery_man.Get(Sync_address);
                     @(posedge (CLK)) if (Info && !G_N) $write("[%t]  Burst Read: CFIMemory[%h]=%h\n",$time,Sync_address,data);
                  end
                  `ReadSignature_bus   : begin 
                     data = Signature_man.Get(Sync_address);
                     @(posedge (CLK)) if (Info && !G_N) $write("[%t]  Burst Read: Electronic Signature[%h]=%h\n",$time,Sync_address,data);
                  end
                  `ReadStatusReg_bus   : begin 
                     data = SR_man.SR;
                     @(posedge (CLK)) if (Info && !G_N) $write("[%t]  Burst Read: StatusRegister: %b\n",$time,data[`BYTE_range]);
                  end
                  default             : $display("[%t]  !!!Model Error: Read mode not recognized!!!", $time);
               endcase
               // -- \\     
            end 
            if((CLK)) begin
               
               if (!nWait) // Wait State??? if no calculate next address
               begin
                  
                  new_address = Sync_address + 1;
                  nRead = nRead + 1;
                  
               end
               if (!isSingleSynchronous) begin

                  // Calcultate Address for Sequential and Wrap Burst 
                  if ((ConfigReg_man.BurstLength != 5'd00) && ConfigReg_man.isWrapBurst)  begin      
                     case (ConfigReg_man.BurstLength_bit) 
                        3'd2: new_address = {Sync_address[`ADDRBUS_dim - 1 : 2], new_address[1:0] };
                        3'd3: new_address = {Sync_address[`ADDRBUS_dim - 1 : 3], new_address[2:0] };
                        3'd4: new_address = {Sync_address[`ADDRBUS_dim - 1 : 4], new_address[3:0] };
                     endcase
                  end 
		  
                  // Calculate Next Wait State
                  if (ConfigReg_man.isNoWrapBurst || (ConfigReg_man.BurstLength == 5'd00) )  //Calculate WAIT STATE
                     if ((new_address[3:0]==4'd0) && (Sync_address[3:0] == 4'd15)) begin
			
			if(!ConfigReg_man.isWaitBeforeActive)  begin

                           if (nWait<WaitState && !firstEOWL) begin
                              nWait = nWait+1; // Another Wait State???
                              isValidData = `FALSE;
                           end else begin 
                              nWait = 0;       // end of wait state
                              Sync_address = new_address;
                              isValidData = `TRUE;
                              firstEOWL =1;

                           end

			end else begin
                           if (nWait<WaitState-1 && !firstEOWL ) begin
                              nWait = nWait+1; // Another Wait State???
                              IsNowWait = `FALSE;
                           end else begin
                              nWait = 0;       // end of wait state
                              Sync_address = new_address;
                              IsNowWait = `TRUE;
                              firstEOWL =1;

                           end
			end 

		     end  
		  if (!nWait) 
                     if ((nRead<ConfigReg_man.BurstLength) || (ConfigReg_man.BurstLength==5'd00) // Read Data is Over Burst Lenght???
                         && !endSingleSynchronous) // end of SingleSinchronous Burst Read ???
                        Sync_address = new_address;
               end  // !isSyn
               
            end //aggiunta
            
         end //G_N
      end // XLatency
   end //Enable Burst
end


endmodule // end Burst Module 


// Erase Manager
// manage the erase functionality

module BlankCheckModule(address, data, progVoltOK, progHighVoltOK,Info);

   input [`WORD_range] data;
   input [`ADDRBUS_range] address;
   input 		  progVoltOK, progHighVoltOK;
   input 		  Info;

   event 		  ErrorCheckEvent, CompleteEvent;

   reg [`BYTE_range] 	  Status;
   reg [`ADDRBUS_range]   hold_address;
   reg [`BLOCKADDR_range] hold_block;


   reg 			  Busy;
   integer 		  i;
   time 		  startTime, delayTime, Erase_time;

initial begin                   // constructor sequence             
   Busy       = `FALSE;                                                    
   Erase_time = `MainBlockErase_time; //modificato
   delayTime  =  Erase_time;                                      
end         

always @(progVoltOK,progHighVoltOK,address) begin
   if (progHighVoltOK) 
      if (BankLib_man.isMainBlock(address)) Erase_time=`FastMainBlockErase_time;
      else  Erase_time=`FastParameterBlockErase_time;
   else 
      if (BankLib_man.isMainBlock(address)) Erase_time=`MainBlockErase_time;
      else  Erase_time=`ParameterBlockErase_time;
end 


function IsBusy;                // boolean function primitive       
   input obbl;                     // all functions require a parameter
   IsBusy = Busy;                // return Boolean value             
endfunction                                                         



// *********************
//
// Task checkConfirm :
//    check confirm code
//
// *********************

task checkConfirm;
   
   output  [`BYTE_range] outStatus;
   
   reg [`BYTE_range] 	 outStatus;

   begin

      if (data == `BLNKCHKconfirm_cmd) outStatus = `NoError_msg;
      
      else outStatus = `WrongBlankCheckConfirm_msg;
   end
endtask





// ****************
//
// Task Blank Check
// 
// ****************

task BlankCheck;
   
   output  [`BYTE_range] outStatus;
   
   reg [`BYTE_range] 	 outStatus;

   integer 		 hold_block;
   reg [`ADDRBUS_range]  hold_address;

   begin
      hold_address = address;
      hold_block = BankLib_man.getBlock(hold_address);
      
      if (BankLib_man.isMainBlock(address)) begin
         // Main Block
         delayTime = `MainBlankCheck_time;
      end else  // Parameter Block
         -> ErrorCheckEvent;
      disable Operation;

      fork
         begin: Operation
            Busy = `TRUE;
            startTime = $time;
            -> ErrorCheckEvent; 
            #delayTime         
               Memory_man.BlockBlankCheck(hold_block, Status);
            -> CompleteEvent;
         end
         @CompleteEvent
            disable Operation; 
      join
      outStatus = Status;
      Busy = `FALSE;
   end
endtask



always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (!progVoltOK)
      Status = `InvVDD_msg;
   if (BankLib_man.isParameterBlock(address)) begin
      
      Status = `WrongBlankCheckBlock;
      $display("parameter block");
   end    
   if (Status != `NoError_msg) begin
      ->CompleteEvent;
      disable ErrorCheck;
   end
   else
      fork : ErrorCheck
         @(negedge progVoltOK) Status = `InvVDD_msg;
         @(Status) -> CompleteEvent;
         @(CompleteEvent) disable ErrorCheck;
      join
end

endmodule  //end module Erase


// *********************************
//
// Program Buffer module :
//
//      program buffer functionality
//
// *********************************

module ProgramBufferModule(address,data,voltOK,Info);
   input [`ADDRBUS_range] address;
   input [`WORD_range] 	  data;
   input 		  voltOK, Info;
   event 		  ErrorCheckEvent, CompleteEvent, WatchAddressEvent;
   reg [`BYTE_range] 	  Status;
   reg [`DATABUS_dim-1:0] Count;

   reg [`WORD_range] 	  bufferData [`ProgramBuffer_range];

   reg [`ADDRBUS_range]   AddressLatched, startAddress,newAddress;
   reg 			  Busy, Suspended, Empty;
   time 		  startTime, delayTime;
   integer 		  i;

initial begin                 // constructor sequence             
   Busy = `FALSE;                                                  
   Suspended = `FALSE;
   Empty = `TRUE;
   delayTime = `ProgramBuffer_time;                                        
end                                                               

function IsBusy;              // boolean function primitive       
   input obbl;               // all functions require a parameter
   IsBusy = Busy;              // return Boolean value             
endfunction                                                       

function IsSuspended;         // boolean function primitive       
   input obbl;               // all functions require a parameter
   IsSuspended = Suspended;    // return Boolean value             
endfunction                                                       

function IsAddrSuspended;     // boolean function primitive       
   input [`ADDRBUS_range] addr;
   IsAddrSuspended = (Suspended && ((addr >= startAddress) && (addr < (startAddress + Count))));
endfunction


function [`DATABUS_dim-1:0] GetCount;
   input 		  required;
   GetCount = Count;
endfunction

task SetCount;                // sets the number of writes
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
   begin
      outStatus = `NoError_msg;
      AddressLatched = address;
      Count = data + 1;
      

      if (Count > `ProgramBuffer_dim)
         outStatus = `BuffSize_msg;
      else if (BankLib_man.getBlock(AddressLatched) != BankLib_man.getBlock(AddressLatched + Count - 1))
	 
	 outStatus = `BlkBuffer_msg;
      else
         -> WatchAddressEvent;
   end
endtask

task Suspend;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
   begin
      delayTime = delayTime - ($time - startTime);
      #`ProgramSuspendLatency_time;
      outStatus = `NoError_msg;
      Status = `Suspend_msg;
      Suspended = `TRUE;
      -> CompleteEvent;
   end
endtask

task Resume;
   output [`BYTE_range] Status;
   begin
      Suspended = `FALSE;
      Program(Status);
end
endtask

task Load;
   output [`BYTE_range] Status;
   begin
      if (Empty) begin
         startAddress = address;
         if (Info) $display("[%t]  Buffer start address: %h",$time,startAddress);
         Empty = `FALSE;
         
      end
      bufferData[address[`ProgramBuffer_addrRange]] = data;

   end
endtask

task Program;
   output [`BYTE_range] outStatus;
   reg [`BYTE_range] 	outStatus;
begin

   fork
      begin : Operation
         Busy = `TRUE;
	 
         startTime = $time;
         -> ErrorCheckEvent;
         -> WatchAddressEvent; // disable address watch
         #delayTime
            for (i = startAddress;i < ( Count + startAddress); i = i + 1) begin
               Memory_man.Program(bufferData[i[`ProgramBuffer_addrRange]],i,Status);

end
         delayTime = `ProgramBuffer_time;
         -> CompleteEvent;
      end
      @CompleteEvent
         disable Operation;

   join
   if(!Suspended)
      for (i = 0; i < `ProgramBuffer_dim; i = i + 1) begin
	 bufferData[i] =16'hFFFF;
      end 
   Empty = `TRUE;
   outStatus = Status;
   Busy = `FALSE;
end
endtask

always @(ErrorCheckEvent) begin
   Status = `NoError_msg;
   if (BlockLock_man.IsLocked(AddressLatched))
      Status = `BlockLock_msg;
   else if (Suspended)
      Status = `SuspAcc_msg;
   else if (!voltOK)
      Status = `InvVDD_msg;

   if (Status != `NoError_msg)
      ->CompleteEvent;
   else
      fork : ErrorCheck
         @(negedge voltOK) Status = `InvVDD_msg;
         @(Status) -> CompleteEvent;
         @(CompleteEvent) disable ErrorCheck;
      join
end

always @(WatchAddressEvent) fork : AddressWatch
   while (`TRUE)
      @address
         if (BankLib_man.getBlock(address) != BankLib_man.getBlock(AddressLatched)) begin
            Status = `AddrTog_msg;
            -> CompleteEvent;
         end
   @WatchAddressEvent
      disable AddressWatch;
join

endmodule
