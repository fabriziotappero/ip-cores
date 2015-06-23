/************************************************************************

        Verilog model for Atmel Devices
          AT45DBXXX  parameterizable 

            Developed for Atmel By:
                Jason G Brown
                Glenn Donovan
                 Jeff Gladu
          
              January 24, 2002

************************************************************************/

/************************************************************************
Development History:

  AT45DBXXX model : Sanjay Churiwala, May-June 1999
  Parameterized   : Niranjan Vaish, June 1999

Revision History:

1.0    : Niranjan Vaish   : Parametrized model for AT45DBXXX devices.
1.1    : Niranjan Vaish   : Updated RDY_BUSYB driving register.
2.0    : Niranjan Vaish   : 2M, 4M and 8M also offer Page Erase and Block Erase.
2.0.1  : Niranjan Vaish   : buffer1 and buffer2 were not declared correctly.
2.0.2  : Niranjan Vaish   : Additional parametrization has been done.
2.0.3  : WPI Project Team : Removed Burst Mode.

*************************************************************************/


/*************************************************************************
 Define the configuration which you want to use.
*************************************************************************/
//`define device4M 1  // This model will work like AT45DB041
`define device32M 1  // This model will work like AT45DB321


/*************************************************************************/
`timescale 1ns / 10ps

`ifdef device1M
module AT45DB011 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

`ifdef device2M
module AT45DB021 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

`ifdef device4M
module AT45DB041 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

`ifdef device8M
module AT45DB081 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

`ifdef device16M
module AT45DB161 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

`ifdef device32M
module AT45DB321 (CSB, SCK, SI, WPB, RESETB, RDY_BUSYB, SO);
`endif

input CSB, SCK, SI, WPB, RESETB;
output SO, RDY_BUSYB;

/*************************************************************************
Device configuration parameters :
*************************************************************************/

`ifdef device1M
parameter DEVICE = "AT45DB011";
parameter MEMSIZE = 135168; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 264; // no of byte_news per page
parameter PAGES = 512; // no of pages
parameter STATUS3 = 1;  // this and next two lines are for
                               //bits 3 to 5 of status register
parameter STATUS4 = 0;
parameter STATUS5 = 0;
parameter BUFFERS = 1; // no. of buffers
parameter BADDRESS = 9; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 9; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif

`ifdef device2M
parameter DEVICE = "AT45DB021";
parameter MEMSIZE = 270336; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 264; // no of byte_news per page
parameter PAGES = 1024; // no of pages
parameter STATUS3 = 0;  // this and next two lines are for
                               //bits 3 to 5 of status register
parameter STATUS4 = 1;
parameter STATUS5 = 0;
parameter BUFFERS = 2; // no. of buffers
parameter BADDRESS = 9; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 10; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif

`ifdef device4M
parameter DEVICE = "AT45DB041";
parameter MEMSIZE = 540672; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 264; // no of byte_news per page
parameter PAGES = 2048; // no of pages
parameter STATUS3 = 1;  // this and next two lines are for
                               //bits 3 to 5 of status register
parameter STATUS4 = 1;
parameter STATUS5 = 0;
parameter BUFFERS = 2; // no. of buffers
parameter BADDRESS = 9; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 11; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif

`ifdef device8M
parameter DEVICE = "AT45DB081";
parameter MEMSIZE = 1081344; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 264; // no of byte_news per page
parameter PAGES = 4096; // no of pages
parameter STATUS3 = 0;  // this and next two lines are for
                               //bits 3 to 5 of status register
parameter STATUS4 = 0;
parameter STATUS5 = 1;
parameter BUFFERS = 2; // no. of buffers
parameter BADDRESS = 9; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 12; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif

`ifdef device16M
parameter DEVICE = "AT45DB161";
parameter MEMSIZE = 2162688; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 528; // no of byte_news per page
parameter PAGES = 4096; // no of pages
parameter STATUS3 = 1;  // this and next two lines are for
                               //bits 3 to 5 of status register
parameter STATUS4 = 0;
parameter STATUS5 = 1;
parameter BUFFERS = 2; // no. of buffers
parameter BADDRESS = 10; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 12; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif



`ifdef device32M
parameter DEVICE = "AT45DB321";
//parameter MEMSIZE = 4194304; // no of byte_news = PAGESIZE * PAGES
parameter MEMSIZE = 4325376; // no of byte_news = PAGESIZE * PAGES
parameter PAGESIZE = 528; // no of byte_news per page
parameter PAGES = 8192; // no of pages
parameter STATUS3 = 0;  // this and next two lines are for 
                               //bits 3 to 5 of status register
parameter STATUS4 = 1;
parameter STATUS5 = 1;
parameter BUFFERS = 2; // no. of buffers
parameter BADDRESS = 10; // no of bits needed to access a byte_new within a page
parameter PADDRESS = 13; // no of bits needed to access a page
parameter PROTECTED = 256; // no of pages that can be Protected, using WPB
`endif

/********************************************************************
Timing Parameters :
More timing parameters given as specparam within the specify block
********************************************************************/

`ifdef device1M
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 200000;
parameter tEP = 20000000;
parameter tP = 15000000;
parameter tPE = 10000000;
parameter tBE = 15000000;
parameter tCAR = 200;
`endif

`ifdef device2M
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 250000;
parameter tEP = 20000000;
parameter tP = 14000000;
parameter tPE = 10000000; // Correct it
parameter tBE = 15000000; // Correct it
parameter tCAR = 200;
`endif

`ifdef device4M
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 250000;
parameter tEP = 20000000;
parameter tP = 14000000;
parameter tPE = 10000000;
parameter tBE = 15000000;
parameter tCAR = 200;
`endif

`ifdef device8M
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 200000;
parameter tEP = 20000000;
parameter tP = 14000000;
parameter tPE = 10000000; // Correct it
parameter tBE = 15000000; // Correct it
parameter tCAR = 200;
`endif

`ifdef device16M
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 350000;
parameter tEP = 20000000;
parameter tP = 15000000;
parameter tPE = 10000000;
parameter tBE = 15000000;
parameter tCAR = 200;
`endif

`ifdef device32M
`ifdef ATFLASH_SPDUP
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 35000;
parameter tEP = 20000;
parameter tP = 15000;
parameter tPE = 10000;
parameter tBE = 15000;
parameter tCAR = 200;
`else
parameter tDIS = 25;
parameter tV = 30;
parameter tXFR = 350000;
parameter tEP = 20000000;
parameter tP = 15000000;
parameter tPE = 10000000;
parameter tBE = 15000000;
parameter tCAR = 200;
`endif
`endif


/**********************************************************************
Memory PreLoading Parameters:
============================= 
These parameters are related to Memory-Preloading. Since, we had to declare
multiple memories, due to Verilog limitation; for PreLoading also, one may
have to preload multiple memories.
Any of the memories can be preloaded, in either Hex format, or, in Binary 
To load a memory (say memory0) in Hex format, define parameter: mem0_h
To load a memory (say memory0) in Binary format, define parameter: mem0_b
If none of the parameters are specified, the memory will be initialized to
    Erase state.
If both of the parameters are specified, the hex file will be used.
If any of the memory locations are initialized, the status of all the page
   will be Not-Erased.
**********************************************************************/
`ifdef SPI_PRELOAD_FNAME
parameter mem0_h = `SPI_PRELOAD_FNAME;
`else
parameter mem0_h = "";
`endif
parameter mem1_h = "";
parameter mem2_h = "";
parameter mem3_h = "";
parameter mem4_h = "";
parameter mem5_h = "";
parameter mem6_h = "";
parameter mem7_h = "";

parameter mem0_b = "";
parameter mem1_b = "";
parameter mem2_b = "";
parameter mem3_b = "";
parameter mem4_b = "";
parameter mem5_b = "";
parameter mem6_b = "";
parameter mem7_b = "";

/********* Memory And Access Related Declarations *****************/
// Verilog seems to be having a restriction due to which, large
// memory-registers can not be used. Hence, declaring 8 smaller,
// equal size memories.

reg [7:0] memory0 [540671:0] ;
reg [7:0] memory1 [1081343:540672] ;
reg [7:0] memory2 [1622015:1081344] ;
reg [7:0] memory3 [2162687:1622016] ;
reg [7:0] memory4 [2703359:2162688] ;
reg [7:0] memory5 [3244031:2703360] ;
reg [7:0] memory6 [3784703:3244032] ;
reg [7:0] memory7 [4325375:3784704] ;

reg [7:0] buffer1 [PAGESIZE-1:0] ; //Buffer 1
reg [7:0] buffer2 [PAGESIZE-1:0] ; //Buffer 2

reg [PADDRESS-1:0] page ; // page address
reg [BADDRESS-1:0] byte_new ; // byte_new address
reg [7:0] status ; // status reg
reg [PAGES-1:0] page_status;  // 0 means page-erased, otherwise not erased


/********* Events to trigger some task based on opcode ***********/
     event  MMPR ;  // Main Memory Page Read
     event  B1R ;   // Buffer 1 Read
     event  B2R ;   // Buffer 2 Read
     event  MMPTB1T ;   // Main Memory Page To Buffer 1 Transfer
     event  MMPTB2T ;   // Main Memory Page To Buffer 2 Transfer
     event  MMPTB1C ;   // Main Memory Page To Buffer 1 Compare
     event  MMPTB2C ;   // Main Memory Page To Buffer 2 Compare
     event  B1W ;   // Buffer 1 Write
     event  B2W ;   // Buffer 2 Write
     event  B1TMMPPWBIE ;   // Buffer 1 To Main Memory Page Prog 
                                     //With Built-In Erase 
     event  B2TMMPPWBIE ;   // Buffer 2 To Main Memory Page Prog 
                                     //With Built-In Erase 
     event  B1TMMPPWOBIE ;   // Buffer 1 To Main Memory Page Prog 
                                     //WithoOut Built-In Erase 
     event  B2TMMPPWOBIE ;   // Buffer 2 To Main Memory Page Prog 
                                     //WithoOut Built-In Erase 
     event  PE ;   // Page Erase
     event  BE ;   // Block Erase
     event  MMPPB1 ;   // Main Memory Page Prog. Through Buffer 1
     event  MMPPB2 ;   // Main Memory Page Prog. Through Buffer 2
     event  APRB1 ;   // Auto Page Rewrite Through Buffer 1
     event  APRB2 ;   // Auto Page Rewrite Through Buffer 2
     event  SR ;   // Status Register Read
     event  RWOPR ; // This is basically same as MMPR, except that rollover
                    // at the end of a page does not occur;

/********* Registers to track the current operation of the device ********/
reg status_read;
reg updating_buffer1;
reg updating_buffer2;
reg updating_memory;
reg comparing;
reg erasing_page;
reg erasing_block;
reg skip; // reg to denote whether or no an extra clock needs to be skipped.
          // This skipping is needed only for Inactive Clock Low. 


/******** Other variables/registers/events ******************/
reg [7:0] read_data; // temp. register in which data is read-in
reg [7:0] temp_reg1; // temp. register to store temporary data
reg [7:0] temp_reg2; // temp. register to store temporary data
reg [PADDRESS-1:0] temp_page; // temp register to store page-address
reg SO_reg , SO_on ; 
reg RDYBSY_reg;
integer j;
integer page_boundary_low, page_boundary_high, current_address;
integer mem_no; // this will keep track of the actual memory to be used.
reg mem_initialized;


/********* Drive SO ***********************/
bufif1 (SO, SO_reg, SO_on); //SO will be driven only if SO_on is High
bufif1 (RDY_BUSYB, 1'b0, RDYBSY_reg); //RDYBUSYB will be driven only if RDYBSY_reg is High


/********* Initialize **********************/
initial
begin  
    // start with erased state
    // Memory Initialization
  mem_initialized = 1'b0;

  for (j=0; j<540672; j=j+1)   // Pre-initiazliation to Erased
  begin                        // state is useful if a user wants to
    memory0[j] = 8'hff;        // initialize just a few locations.
    memory1[j+540672] = 8'hff; 
    memory2[j+1081344] = 8'hff; 
    memory3[j+1622016] = 8'hff;
    memory4[j+2162688] = 8'hff;
    memory5[j+2703360] = 8'hff;
    memory6[j+3244032] = 8'hff;
    memory7[j+3784704] = 8'hff;
  end

   // Now preload, if needed
  if (mem0_h != "")
  begin  
     $readmemh (mem0_h, memory0);
     mem_initialized = 1'b1;
  end
  else if (mem0_b != "")
  begin  
     $readmemb (mem0_b, memory0);
     mem_initialized = 1'b1;
  end

  if (mem1_h != "")
  begin  
     $readmemh (mem1_h, memory1);
     mem_initialized = 1'b1;
  end
  else if (mem1_b != "")
  begin  
     $readmemb (mem1_b, memory1);
     mem_initialized = 1'b1;
  end

  if (mem2_h != "")
  begin  
     $readmemh (mem2_h, memory2);
     mem_initialized = 1'b1;
  end
  else if (mem2_b != "")
  begin  
     $readmemb (mem2_b, memory2);
     mem_initialized = 1'b1;
  end

  if (mem3_h != "")
  begin  
     $readmemh (mem3_h, memory3);
     mem_initialized = 1'b1;
  end
  else if (mem3_b != "")
  begin  
     $readmemb (mem3_b, memory3);
     mem_initialized = 1'b1;
  end

  if (mem4_h != "")
  begin  
     $readmemh (mem4_h, memory4);
     mem_initialized = 1'b1;
  end
  else if (mem4_b != "")
  begin  
     $readmemb (mem4_b, memory4);
     mem_initialized = 1'b1;
  end

  if (mem5_h != "")
  begin  
     $readmemh (mem5_h, memory5);
     mem_initialized = 1'b1;
  end
  else if (mem5_b != "")
  begin  
     $readmemb (mem5_b, memory5);
     mem_initialized = 1'b1;
  end

  if (mem6_h != "")
  begin  
     $readmemh (mem6_h, memory6);
     mem_initialized = 1'b1;
  end
  else if (mem6_b != "")
  begin  
     $readmemb (mem6_b, memory6);
     mem_initialized = 1'b1;
  end

  if (mem7_h != "")
  begin  
     $readmemh (mem7_h, memory7);
     mem_initialized = 1'b1;
  end
  else if (mem7_b != "")
  begin  
     $readmemb (mem7_b, memory7);
     mem_initialized = 1'b1;
  end

  if (mem_initialized == 1'b1)
  for (j=0; j<PAGES; j=j+1)
    page_status[j] = 1'b1; // memory was initialized, so, Pages are Not Erased.
  else
  for (j=0; j<PAGES; j=j+1)
    page_status[j] = 1'b0;

  // Now initialize all registers
  status[7] = 1'b1; // device is ready to start with
  status[6] = 1'bx; // compare bit is unknown
  status[5] = STATUS5;
  status[4] = STATUS4;
  status[3] = STATUS3;
  status[2:0] = 3'bx; // these reserved bits are also unknown

  // There is no activity at this time
  status_read = 1'b0;
  updating_buffer1 = 1'b0;
  updating_buffer2 = 1'b0;
  updating_memory = 1'b0;
  comparing = 1'b0;
  erasing_page = 1'b0;
  erasing_block = 1'b0;

  // All o/ps are High-impedance
  SO_on = 1'b0;
  RDYBSY_reg = 1'b0;

end


always @(negedge CSB)  // the device will now become active
begin : get_opcode
   if (SCK == 1'b0)
   begin
      skip = 1'b1;
    
   end
   else 
   begin
      skip = 1'b0;
      // If the opcode is related to SPI Mode 0/3, no skipping is needed. So, skip
      // will be reset to "0".
      // If opcode is related to Inactive Clock Low/high, skipping might or might
      // not be needed, depending on the value of SCK at negedge of CSB. So, in
      // such situations, skip will retain its value.
    end

   get_data;  // get opcode here

   case (status[5:3]) 
     3'b001:  // 1M Memory
         case (read_data)
           // Illegal Opcode for 1M memory. It has only one buffer.
           8'h56, 8'hd6, 8'h55, 8'h61, 8'h87, 8'h86, 8'h89, 8'h85, 8'h59: 
              begin
                $display("Unrecognized opcode %h", read_data);
                disable get_opcode;
              end
         endcase
   endcase

   case (read_data)   // based on opcode, trigger an action
     8'h52 : -> MMPR ;  // Main Memory Page Read
     8'hd2 : begin
               skip = 1'b0;
               -> MMPR ;  // Main Memory Page Read
             end
     8'h54 : -> B1R ;   // Buffer 1 Read
     8'hd4 : begin
               skip = 1'b0;
               -> B1R ;   // Buffer 1 Read
             end
     8'h56 : -> B2R ;   // Buffer 2 Read
     8'hd6 : begin
               skip = 1'b0;
               -> B2R ;   // Buffer 2 Read
             end
     8'h53 : -> MMPTB1T ;   // Main Memory Page To Buffer 1 Transfer
     8'h55 : -> MMPTB2T ;   // Main Memory Page To Buffer 2 Transfer
     8'h60 : -> MMPTB1C ;   // Main Memory Page To Buffer 1 Compare
     8'h61 : -> MMPTB2C ;   // Main Memory Page To Buffer 2 Compare
     8'h84 : -> B1W ;   // Buffer 1 Write
     8'h87 : -> B2W ;   // Buffer 2 Write
     8'h83 : -> B1TMMPPWBIE ;   // Buffer 1 To Main Memory Page Prog 
                                               //With Built-In Erase 
     8'h86 : -> B2TMMPPWBIE ;   // Buffer 2 To Main Memory Page Prog 
                                               //With Built-In Erase 
     8'h88 : -> B1TMMPPWOBIE ;   // Buffer 1 To Main Memory Page Prog 
                                               //WithoOut Built-In Erase 
     8'h89 : -> B2TMMPPWOBIE ;   // Buffer 2 To Main Memory Page Prog 
                                               //WithoOut Built-In Erase 
     8'h81 : -> PE ;   // Page Erase
     8'h50 : -> BE ;   // Block Erase
     8'h82 : -> MMPPB1 ;   // Main Memory Page Prog. Through Buffer 1
     8'h85 : -> MMPPB2 ;   // Main Memory Page Prog. Through Buffer 2
     8'h58 : -> APRB1 ;   // Auto Page Rewrite Through Buffer 1
     8'h59 : -> APRB2 ;   // Auto Page Rewrite Through Buffer 2
     8'h57 : -> SR ;   // Status Register Read
     8'hd7 : begin
               skip = 1'b0;
               -> SR ;   // Status Register Read
             end
     8'h68 : -> RWOPR ;
     8'hE8 : begin
               skip = 1'b0;
               -> RWOPR ;
             end
     default : $display ("Unrecognized opcode %h", read_data);
   endcase
end


/******* Main Memory Page Read ********************/

always @(MMPR)
begin : MMPR_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory Page Read is not allowed");
     disable MMPR_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress and byte_new-address, according to 
        // the parameters.
   compute_page_address;
   compute_byte_new_address;
      // next 8 bits always contain byte_new-address[7:0], and, so is
      // not dependent on parameters
   get_data;
   byte_new[7:0] = read_data[7:0];

   for (j=0; j<4; j=j+1)
      get_data ;  // these 32 bits are dont-care, and so have been discarded.

   compute_address;
   if (skip == 1'b1)
     @(posedge SCK); // skip one SCK
   read_out (mem_no, current_address, page_boundary_low, page_boundary_high);
end


/******* Buffer 1 Read ********************/

always @(B1R)
begin : B1R_
   get_data; // first 8 bits are dont care
   get_data;
        // For buffers, PageAddress can be assumed as "0".
        // This will allow us to share code with MMPR;
   page [PADDRESS-1:0] = 'h0;

   compute_byte_new_address;
      // next 8 bits always contain byte_new-address[7:0], and, so is
      // not dependent on parameters
   get_data;
   byte_new[7:0] = read_data[7:0];

   compute_address;
   get_data; // next 8 bits are dont care
   if (skip == 1'b1)
     @(posedge SCK); // skip one SCK
   read_out (1, current_address, page_boundary_low, page_boundary_high);
end



/******* Buffer 2 Read ********************/

always @(B2R)
begin : B2R_
   get_data; // first 8 bits are dont care
   get_data;
        // For buffers, PageAddress can be assumed as "0".
        // This will allow us to share code with MMPR;
   page [PADDRESS-1:0] = 'h0;

   compute_byte_new_address;

      // next 8 bits always contain byte_new-address[7:0], and, so is
      // not dependent on parameters
   get_data;
   byte_new[7:0] = read_data[7:0];

   compute_address;
   get_data; // next 8 bits are don't care
   if (skip == 1'b1)
     @(posedge SCK); // skip one SCK
   read_out (2, current_address, page_boundary_low, page_boundary_high);
end


/******* Main Memory Page To Buffer 1 Transfer *****************/

always @(MMPTB1T)
begin : MMPTB1T_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory To Buffer Transfer is not allowed");
     disable MMPTB1T_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   transfer_to_buffer (1, page_boundary_low);
   updating_buffer1 = 1'b1;
   #tXFR RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_buffer1 = 1'b0;
end


/******* Main Memory Page To Buffer 2 Transfer *****************/

always @(MMPTB2T)
begin : MMPTB2T_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory To Buffer Transfer is not allowed");
     disable MMPTB2T_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   transfer_to_buffer (2, page_boundary_low);
   updating_buffer2 = 1'b1;
   #tXFR RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_buffer2 = 1'b0;
end


/******* Main Memory Page To Buffer 1 Compare *****************/

always @(MMPTB1C)
begin : MMPTB1C_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory To Buffer Compare is not allowed");
     disable MMPTB1C_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   compare_with_buffer (1, page_boundary_low);
   comparing = 1'b1;
   #tXFR RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   comparing = 1'b0;
end



/******* Main Memory Page To Buffer 2 Compare *****************/

always @(MMPTB2C)
begin : MMPTB2C_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory To Buffer Compare is not allowed");
     disable MMPTB2C_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   compare_with_buffer (2, page_boundary_low);
   comparing = 1'b1;
   #tXFR RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   comparing = 1'b0;
end


/*******    Buffer 1 Write *****************/

always @(B1W)
begin : B1W_
   get_data; // dont care bits
   get_data;
            // got some address bits, depending on device parameters
   compute_byte_new_address;
   get_data;
   byte_new[7:0] = read_data [7:0];

   page[PADDRESS-1:0] = 'h0; // buffer is equivalent to just one page

   compute_address; 

   write_data (1);

end


/*******    Buffer 2 Write *****************/

always @(B2W)
begin : B2W_
   get_data; // dont care bits
   get_data;
            // got some address bits, depending on device parameters
   compute_byte_new_address;
   get_data;
   byte_new[7:0] = read_data [7:0];

   page[PADDRESS-1:0] = 'h0; // buffer is equivalent to just one page

   compute_address; 

   write_data (2);

end


/******* Buffer 1 To Main Memory Page Prog With Built In Erase *******/

always @(B1TMMPPWBIE)
begin : B1TMMPPWBIE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Buffer To Main Memory Page Prog. is not allowed");
     disable B1TMMPPWBIE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't write: Page No. %d is Protected, becase WPB is Low", page);        
     disable B1TMMPPWBIE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   write_to_memory (1, page_boundary_low);
   updating_memory = 1'b1;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_memory = 1'b0;
end


/******* Buffer 2 To Main Memory Page Prog With Built In Erase *******/

always @(B2TMMPPWBIE)
begin : B2TMMPPWBIE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Buffer To Main Memory Page Prog. is not allowed");
     disable B2TMMPPWBIE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't write: Page No. %d is Protected, becase WPB is Low", page);        
     disable B2TMMPPWBIE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   write_to_memory (2, page_boundary_low);
   updating_memory = 1'b1;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_memory = 1'b0;
end


/******* Buffer 1 To Main Memory Page Prog WithOut Built In Erase *******/

always @(B1TMMPPWOBIE)
begin : B1TMMPPWOBIE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Buffer To Main Memory Page Prog. is not allowed");
     disable B1TMMPPWOBIE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't write: Page No. %d is Protected, becase WPB is Low", page);        
     disable B1TMMPPWOBIE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   if (page_status[page] == 1'b0) // page is already erased
   begin
      RDYBSY_reg = 1'b1; // device is busy
      status[7] = 1'b0;
      write_to_memory (1, page_boundary_low);
      updating_memory = 1'b1;
      #tP RDYBSY_reg = 1'b0; // device is now ready
      status[7] = 1'b1;
      updating_memory = 1'b0;
   end
   else
      $display ("Trying to write into Page %d which is not erased", page);
end


/******* Buffer 2 To Main Memory Page Prog WithOut Built In Erase *******/

always @(B2TMMPPWOBIE)
begin : B2TMMPPWOBIE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Buffer To Main Memory Page Prog. is not allowed");
     disable B2TMMPPWOBIE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't write: Page No. %d is Protected, becase WPB is Low", page);        
     disable B2TMMPPWOBIE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   if (page_status[page] == 1'b0) // page is already erased
   begin
      RDYBSY_reg = 1'b1; // device is busy
      status[7] = 1'b0;
      updating_memory = 1'b1;
      write_to_memory (2, page_boundary_low);
      #tP RDYBSY_reg = 1'b0; // device is now ready
      status[7] = 1'b1;
      updating_memory = 1'b0;
   end
   else
      $display ("Trying to write into Page %d which is not erased", page);
end


/******* Page Erase *******/

always @(PE)
begin : PE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Page Erase is not allowed");
     disable PE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't Erase: Page No. %d is Protected, becase WPB is Low", page);        
     disable PE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   erase_page ( page_boundary_low);
   erasing_page = 1'b1;
   #tPE RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   erasing_page = 1'b0;
end


/******* Block Erase *******/

always @(BE)
begin : BE_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Block Erase is not allowed");
     disable BE_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;
   page [2:0] = 3'h0; // lowest page of the block

   get_data; // This is dont_care

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't Erase: Block starting at Page No. %d is Protected, becase WPB is Low", page);        
     disable BE_ ;
   end

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;

   for (j=page_boundary_low; j<(page_boundary_low+8*PAGESIZE); j=j+PAGESIZE)
      erase_page ( j ); // erase 8 pages, i.e. a block

   for (j=0; j<8; j=j+1) // erase_page will only change the status of one-page 
     page_status[page+j] = 1'b0; // hence, changing the remaining ones explicitly

   erasing_block = 1'b1;
   #tBE RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   erasing_block = 1'b0;
end

/******* Main Memory Page Prog Through Buffer 1 *******/

always @(MMPPB1)
begin : MMPPB1_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory Page Prog. is not allowed");
     disable MMPPB1_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;
        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress/ByteAddress according to the parameters
   compute_page_address;
   compute_byte_new_address;
   temp_reg2[7:0] = read_data [7:0];
   get_data; 
   byte_new[7:0] = read_data[7:0];
   temp_page = page; // page value has been stored for main memory page program


   page[PADDRESS-1:0] = 'h0; // Buffer is 0 pages

   compute_address; // this computes where to write in buffer

   write_data (1); // this will write to buffer
                   // it will proceed to next step, when, posedge of CSB.
                   // This is complicated, and, hence, explained here:
                   // At posedge of CSB, the write_data will get disabled.
                   // At this time, writing to buffer needs to stop, and,
                   // writing into memory should start.
                 
   page[PADDRESS-1:0] = temp_page[PADDRESS-1:0]; // page address in Main Memory to which
                                                 // data needs to be written
   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't Write: Page No. %d is Protected, becase WPB is Low", page);        
     disable MMPPB1_ ;
   end

   compute_address; // even if byte_new-address is junk, we only need Page_Low_Boundary

   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   write_to_memory (1, page_boundary_low);
   updating_memory = 1'b1;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_memory = 1'b0;
end


/******* Main Memory Page Prog Through Buffer 2 *******/

always @(MMPPB2)
begin : MMPPB2_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory Page Prog. is not allowed");
     disable MMPPB2_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;
        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress/ByteAddress according to the parameters
   compute_page_address;
   compute_byte_new_address;
   temp_reg2[7:0] = read_data [7:0];
   get_data; 
   // Third byte_new is always for byte_new address[7:0]
   byte_new[7:0] = read_data[7:0];

   temp_page = page; // page value has been stored for main memory page program

   page[PADDRESS-1:0] = 'h0; // Buffer is 0 pages

   compute_address; // this computes where to write in buffer

   write_data (2); // this will write to buffer
                   // it will proceed to next step, when, posedge of CSB.
                   // This is complicated, and, hence, explained here:
                   // At posedge of CSB, the write_data will get disabled.
                   // At this time, writing to buffer needs to stop, and,
                   // writing into memory should start.
                 
   page[PADDRESS-1:0] = temp_page[PADDRESS-1:0]; // page address in Main Memory to which
                                                 // data needs to be written
   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't Write: Page No. %d is Protected, becase WPB is Low", page);        
     disable MMPPB2_ ;
   end

   compute_address; // even if byte_new-address is junk, we only need Page_Low_Boundary

   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   write_to_memory (2, page_boundary_low);
   updating_memory = 1'b1;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_memory = 1'b0;
end


/******* Auto Page Rewrite Through Buffer 1 *****************/

always @(APRB1)
begin : APRB1_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Auto Page Rewrite is not allowed");
     disable APRB1_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   transfer_to_buffer (1, page_boundary_low);
   updating_buffer1 = 1'b1;

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't ReWrite: Page No. %d is Protected, becase WPB is Low", page);        
     #tEP updating_buffer1 = 1'b0;
     disable APRB1_ ;
   end

   updating_memory = 1'b1;
   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_buffer1 = 1'b0;
   updating_memory = 1'b0;
   // NOTE:
   // We dont need to rewrite the data back into main-memory, as the 
   //        data is already available in the main-memory
   // This task was exactly same as MMPTB1T, except the delay-value
   //      We could have easily used the same code as MMPTB1T, using 
   //      an if condition for delay-selection. However, still doing
   //      this way, so that the code for each opcode is independent
   //      of anything else.
end


/******* Auto Page Rewrite Through Buffer 2 *****************/

always @(APRB2)
begin : APRB2_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Auto Page Rewrite is not allowed");
     disable APRB2_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress according to the parameters
   compute_page_address;

   get_data; // This is dont_care

   compute_address; // even though, byte_new-address could be junk,
                    // we are only interested in Low page-boundaries,
                    // which can be obtained correctly
   @ (posedge CSB);
   transfer_to_buffer (2, page_boundary_low);
   updating_buffer2 = 1'b1;

   if ((WPB == 1'b0) && (page < PROTECTED))
   begin
     $display ("Cann't ReWrite: Page No. %d is Protected, becase WPB is Low", page);        
     #tEP updating_buffer2 = 1'b0;
     disable APRB2_ ;
   end

   RDYBSY_reg = 1'b1; // device is busy
   status[7] = 1'b0;
   updating_memory = 1'b1;
   #tEP RDYBSY_reg = 1'b0; // device is now ready
   status[7] = 1'b1;
   updating_buffer2 = 1'b0;
   updating_memory = 1'b0;
   // NOTE:
   // We dont need to rewrite the data back into main-memory, as the 
   //        data is already available in the main-memory
   // This task was exactly same as MMPTB2T, except the delay-value
   //      We could have easily used the same code as MMPTB2T, using 
   //      an if condition for delay-selection. However, still doing
   //      this way, so that the code for each opcode is independent
   //      of anything else.
end


/********* Status Register Read ********************/

always @(SR)
begin: SR_
  status_read = 1'b1; // reading status_reg
  j = 8;
   if (skip == 1'b1)
     @(posedge SCK); // skip one SCK
  while (CSB == 1'b0)
  begin
    @(negedge SCK);
    #tV ;
    if (j > 0) 
       j = j-1;
    else
       j = 7;
    SO_reg=status[j];
    SO_on = 1'b1;
    SO_reg = status[j];
  end // output next bit on next falling edge of SCK
  status_read = 1'b0; // status_reg read is over

end

always @(negedge RDYBSY_reg) // this block to take care of situations,
                             // where status gets changed, while, it
                             // is being read.
                             // Applicable only in cases, where, device gets
                             // ready, from busy.
   if (status_read == 1'b1)  
      SO_reg = status[j];    // No harm, even if we have done this for other bits
                             // of status_reg


/******* Main Memory Continuous Read ********************/

always @(RWOPR)
begin : RWOPR_
   if (RDYBSY_reg == 1'b1) // device is already busy
   begin
     $display ("Device is busy. Main Memory Page Read is not allowed");
     disable RWOPR_ ;     
   end
         // if it comes here, means, the above if was false.
   get_data;
   temp_reg1[7:0] = read_data [7:0];
   get_data;

        // Now that the two byte_news have been obtained, distribute it 
        // within PageAddress and byte_new-address, according to 
        // the parameters.
   compute_page_address;
   compute_byte_new_address;

      // next 8 bits always contain byte_new-address[7:0], and, so is
      // not dependent on parameters
   get_data;
   byte_new[7:0] = read_data[7:0];

   for (j=0; j<4; j=j+1)
      get_data ;  // these 32 bits are dont-care, and so have been discarded.

   compute_address;
   if (skip == 1'b1)
     @(posedge SCK); // skip one SCK
   read_out_array ;
end


/******** Posedge CSB. Stop all reading, recvng. commands/addresses etc. *********/

always @(posedge CSB)
begin
  disable MMPR_; // MMPR will stop, if CSB goes high
  disable RWOPR_; // RWOPR will stop, if CSB goes high

  disable B1R_; // B1R will stop, if CSB goes high

  disable B2R_; // B2R will stop, if CSB goes high

  disable B1W_; // B1W will stop, if CSB goes high

  disable B2W_; // B2W will stop, if CSB goes high

  disable SR_; // Status reading should stop.
  status_read = 1'b0; 

  disable read_out; // Stop reading, NOW
  disable read_out_array; 
  disable get_data; // Stop data retrieval
  disable write_data; // Stop writing to buffers, NOW
  
  #tDIS SO_on = 1'b0;  // SO is now in high-impedance
end


/******** RESETB asserted. ******************/

always @(negedge RESETB)
begin 
                               // stop doing whatever you were doing
  disable get_opcode;
  disable MMPR_;
  disable B1R_;
  disable B2R_;
  disable MMPTB1T_;
  disable MMPTB2T_;
  disable MMPTB1C_;
  disable MMPTB2C_;
  disable B1W_;
  disable B2W_;
  disable B1TMMPPWBIE_;
  disable B2TMMPPWBIE_;
  disable B1TMMPPWOBIE_;
  disable B2TMMPPWOBIE_;
  disable PE_;
  disable BE_;
  disable MMPPB1_;
  disable MMPPB2_;
  disable APRB1_;
  disable APRB2_;
                            // if you were in the middle of some prog. that part
                            //                  is now unknown.
  if (updating_buffer1 == 1'b1)
  begin
    $display("RESETB asserted, when, updating Buffer1. Corrupting Buffer1");
    corrupt_buffer (1);
    updating_buffer1 = 1'b0;
  end
 
  if (updating_buffer2 == 1'b1)
  begin
    $display("RESETB asserted, when, updating Buffer2. Corrupting Buffer1");
    corrupt_buffer (2);
    updating_buffer2 = 1'b0;
  end
 
  if (comparing == 1'b1)
  begin
    $display("RESETB asserted, when, comparing. Corrupting Status Bit 6");
    status[6] = 1'bx; // unknown
    comparing = 1'b0;
  end
 
  if (updating_memory == 1'b1)
  begin
    $display("RESETB asserted, when, updating memory. Corrupting Memory Page");
    corrupt_memory ;
    updating_memory = 1'b0;
  end
 
  if (erasing_page == 1'b1)
  begin
    $display("RESETB asserted, when, erasing page. Corrupting Memory Page");
    corrupt_memory ;
    erasing_page = 1'b0;
  end
 
  if (erasing_block == 1'b1)
  begin
    $display("RESETB asserted, when, erasing block. Corrupting Memory Block");
    corrupt_block ;
    erasing_block = 1'b0;
  end

 // SO also, needs to go to high-state, as well as the device needs to be Ready.
 SO_on = 1'b0; 
 RDYBSY_reg = 1'b0;
 
end


/************************ TASKS / FUNCTIONS **************************/

/* get_data is a task to get 8 bits of data. This data could be an opcode,
address, data or anything. It just obtains 8 bits of data obtained on SI*/

task get_data;

integer i;

begin
   for (i=7; i>=0; i = i-1)
   begin
      @(posedge SCK);  
      read_data[i] = SI;
   end
end

endtask


/* compute_address is a task which to compute the current address, 
as well as obtain the page boundaries */

task compute_address;

begin
  page_boundary_low = page * PAGESIZE; 
  page_boundary_high = page_boundary_low + (PAGESIZE - 1);
  current_address = page_boundary_low + byte_new;
  if (current_address < 540672)
      mem_no = 10;
  else if (current_address < 1081344)
      mem_no = 11;
  else if (current_address < 1622016)
      mem_no = 12;
  else if (current_address < 2162688)
      mem_no = 13;
  else if (current_address < 2703360)
      mem_no = 14;
  else if (current_address < 3244032)
      mem_no = 15;
  else if (current_address < 3784704)
      mem_no = 16;
  else mem_no = 17;
end

endtask

/* read_out will read the output on SO pin. It can read contents of mainmemory, or,
either of the two buffers */

task read_out ;
input mem_type;
input add;
input low;
input high;

integer mem_type;
integer add;
integer low;
integer high;

integer i;

begin
  if (mem_type == 1)
     temp_reg1 = buffer1 [add];
  else if (mem_type == 2)
     temp_reg1 = buffer2 [add];

  else if (mem_type == 10)
     temp_reg1 = memory0 [add];
  else if (mem_type == 11)
     temp_reg1 = memory1 [add];
  else if (mem_type == 12)
     temp_reg1 = memory2 [add];
  else if (mem_type == 13)
     temp_reg1 = memory3 [add];
  else if (mem_type == 14)
     temp_reg1 = memory4 [add];
  else if (mem_type == 15)
     temp_reg1 = memory5 [add];
  else if (mem_type == 16)
     temp_reg1 = memory6 [add];
  else if (mem_type == 17)
     temp_reg1 = memory7 [add];
  else
     $display ("Int Error 1. This message should never appear. Something is wrong");

   i = 7;
   while (CSB == 1'b0) // continue transmitting, while, CSB is Low
   begin : CONTINUE_READING
      @(negedge SCK) ;
      #tV SO_reg = temp_reg1[i];
          SO_on = 1'b1; 
      if (i == 0) 
        begin
          add = add + 1; // next byte_new
          i = 7;
          if (add > high)
              add = low; // Page rollover

          if (mem_type == 1)
             temp_reg1 = buffer1 [add];
          else if (mem_type == 2)
             temp_reg1 = buffer2 [add];

          else if (mem_type == 10)
             temp_reg1 = memory0 [add];
          else if (mem_type == 11)
             temp_reg1 = memory1 [add];
          else if (mem_type == 12)
             temp_reg1 = memory2 [add];
          else if (mem_type == 13)
             temp_reg1 = memory3 [add];
          else if (mem_type == 14)
             temp_reg1 = memory4 [add];
          else if (mem_type == 15)
             temp_reg1 = memory5 [add];
          else if (mem_type == 16)
             temp_reg1 = memory6 [add];
          else if (mem_type == 17)
             temp_reg1 = memory7 [add];

        end
      else
        i = i - 1; // next bit

   end // reading over, because CSB has gone high
end

endtask

/* task read_out_array is to read from main Memory, either in 
          Continuous Mode, or, in Burst Mode */

task read_out_array ;

integer i;
integer temp_mem;
integer temp_current;
integer temp_high;
integer temp_low;
integer temp_add;

begin
  temp_mem = mem_no;
  temp_high = page_boundary_high;
  temp_low = page_boundary_low;
  temp_add = current_address;

  if (temp_mem == 10)
     temp_reg1 = memory0 [temp_add];
  else if (temp_mem == 11)
     temp_reg1 = memory1 [temp_add];
  else if (temp_mem == 12)
     temp_reg1 = memory2 [temp_add];
  else if (temp_mem == 13)
     temp_reg1 = memory3 [temp_add];
  else if (temp_mem == 14)
     temp_reg1 = memory4 [temp_add];
  else if (temp_mem == 15)
     temp_reg1 = memory5 [temp_add];
  else if (temp_mem == 16)
     temp_reg1 = memory6 [temp_add];
  else if (temp_mem == 17)
     temp_reg1 = memory7 [temp_add];
  else
     $display ("Int Error 1. This message should never appear. Something is wrong");

   i = 7;
   while (CSB == 1'b0) // continue transmitting, while, CSB is Low
   begin : CONTINUE_READING
      @(negedge SCK) ;
      #tV SO_reg = temp_reg1[i];
          SO_on = 1'b1; 
      if (i == 0) 
        begin
          temp_add = temp_add + 1; // next byte_new
          i = 7;
          if (temp_add >= MEMSIZE)
          begin
              temp_add = 0; // Note that rollover occurs at end of memory,
              temp_high = PAGESIZE - 1; // and not at the end of the page
              temp_low = 0;
          end
          if (temp_add > temp_high) // going to next page
          begin
             temp_high = temp_high + PAGESIZE;
             temp_low = temp_low + PAGESIZE;
          end

          if (temp_add > 3784703)  // this block is a kludge to take
             temp_mem = 17;        // care of multiple memory declarations
          else if (temp_add > 3244031) // in the model, due to limitation
             temp_mem = 16;            // of Verilog
          else if (temp_add > 2703359)
             temp_mem = 15;
          else if (temp_add > 2162687)
             temp_mem = 14;
          else if (temp_add > 1622015)
             temp_mem = 13;
          else if (temp_add > 1081343)
             temp_mem = 12;
          else if (temp_add > 540671)
             temp_mem = 11;
          else temp_mem = 10;

          if (temp_mem == 10)
             temp_reg1 = memory0 [temp_add];
          else if (temp_mem == 11)
             temp_reg1 = memory1 [temp_add];
          else if (temp_mem == 12)
             temp_reg1 = memory2 [temp_add];
          else if (temp_mem == 13)
             temp_reg1 = memory3 [temp_add];
          else if (temp_mem == 14)
             temp_reg1 = memory4 [temp_add];
          else if (temp_mem == 15)
             temp_reg1 = memory5 [temp_add];
          else if (temp_mem == 16)
             temp_reg1 = memory6 [temp_add];
          else if (temp_mem == 17)
             temp_reg1 = memory7 [temp_add];

        end
      else
        i = i - 1; // next bit
   end // reading over, because CSB has gone high
end

endtask


/* transfer_to_buffer will transfer data into a buffer from a page of
main memory */

/* transfer_to_buffer will transfer data into a buffer from a page of
main memory */

task transfer_to_buffer ;
input buf_type;
input low;

integer buf_type;
integer low;

integer i;

begin
       // Intentionally written this way: i.e. the for loop is within all if.
       // Writing in alternative way would cause shorter code, but, significant
       // increase in simulation time.
  if (buf_type == 1)
  begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory0[low+i];
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory1[low+i];
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory2[low+i];
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory3[low+i];
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory4[low+i];
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory5[low+i];
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory6[low+i];
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer1[i] = memory7[low+i];
    else $display ("Should Never reach here. Something is wrong");
  end

  else if (buf_type == 2)
  begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory0[low+i];
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory1[low+i];
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory2[low+i];
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory3[low+i];
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory4[low+i];
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory5[low+i];
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory6[low+i];
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          buffer2[i] = memory7[low+i];
    else $display ("Should Never reach here. Something is wrong");
  end

  else
     $display ("Int Error 2. This message should never appear. Something is wrong");

end

endtask


/* compare_with_buffer will compare data into a buffer against a page of
main memory */

task compare_with_buffer ;
input buf_type;
input low;

integer buf_type;
integer low;

integer i, k;
reg [7:0] tmp1, tmp2;

begin

  status[6] = 1'b0;
  if (buf_type == 1)
    for (i=0 ; i < PAGESIZE; i = i+1)
    begin : LOOP1
       if (mem_no == 10)
          tmp1 = memory0[low+i];
       else if (mem_no == 11)
          tmp1 = memory1[low+i];
       else if (mem_no == 12)
          tmp1 = memory2[low+i];
       else if (mem_no == 13)
          tmp1 = memory3[low+i];
       else if (mem_no == 14)
          tmp1 = memory4[low+i];
       else if (mem_no == 15)
          tmp1 = memory5[low+i];
       else if (mem_no == 16)
          tmp1 = memory6[low+i];
       else if (mem_no == 17)
          tmp1 = memory7[low+i];
       else $display ("should never reach here. Something went wrong");
       tmp2 = buffer1[i];
       for (k=0; k < 8; k = k+1)
           if (tmp1[k] !== tmp2[k])
           begin  // detected miscompare. No need for further comparison
             status[6] = 1'b1;
             disable LOOP1;
           end
    end
  else if (buf_type == 2)
    for (i=0 ; i < PAGESIZE; i = i+1)
    begin : LOOP2
       if (mem_no == 10)
          tmp1 = memory0[low+i];
       else if (mem_no == 11)
          tmp1 = memory1[low+i];
       else if (mem_no == 12)
          tmp1 = memory2[low+i];
       else if (mem_no == 13)
          tmp1 = memory3[low+i];
       else if (mem_no == 14)
          tmp1 = memory4[low+i];
       else if (mem_no == 15)
          tmp1 = memory5[low+i];
       else if (mem_no == 16)
          tmp1 = memory6[low+i];
       else if (mem_no == 17)
          tmp1 = memory7[low+i];
       else $display ("should never reach here. Something went wrong");
       tmp2 = buffer2[i];
       for (k=0; k < 8; k = k+1)
           if (tmp1[k] !== tmp2[k])
           begin  // detected miscompare. No need for further comparison
             status[6] = 1'b1;
             disable LOOP2;
           end
    end
  else
     $display ("Int error 3. This message should never appear. Something is wrong");

end

endtask


/* write_data will gat data from SI, and, write into device */

task write_data ;
input buf_type;

integer buf_type;

integer i;

begin

   while (CSB == 1'b0)
   begin
     for (i=7; i>=0; i=i-1)
     begin
       @(posedge SCK);
       temp_reg1[i] = SI;
     end // Complete byte_new recvd. Now transfer the byte_new to memory/buffer

   if (buf_type == 1)  // Buffer 1
      buffer1[current_address] = temp_reg1;
   else if (buf_type == 2) // Buffer 2
      buffer2[current_address] = temp_reg1;
   else
     $display ("Int error 4. This message should never appear. Something is wrong");

   current_address = current_address + 1;
   if (current_address > page_boundary_high)
       current_address = page_boundary_low;

   end // continue writing. Note that parts of a byte_new will not be written.

end

endtask


/* write_to_memory will transfer data from a buffer into a page of
main memory */

task write_to_memory ;
input buf_type;
input low;

integer buf_type;
integer low;

integer i;

begin

  if (buf_type == 1)
  begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory0[low+i] = buffer1[i];
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory1[low+i] = buffer1[i];
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory2[low+i] = buffer1[i];
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory3[low+i] = buffer1[i];
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory4[low+i] = buffer1[i];
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory5[low+i] = buffer1[i];
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory6[low+i] = buffer1[i];
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory7[low+i] = buffer1[i];
    else $display ("should never reach here. Something is wrong");
  end
  else if (buf_type == 2)
  begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory0[low+i] = buffer2[i];
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory1[low+i] = buffer2[i];
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory2[low+i] = buffer2[i];
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory3[low+i] = buffer2[i];
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory4[low+i] = buffer2[i];
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory5[low+i] = buffer2[i];
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory6[low+i] = buffer2[i];
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory7[low+i] = buffer2[i];
    else $display ("should never reach here. Something is wrong");
  end
  else 
    $display ("Int error 4. This message should never appear. Something is wrong");

   page_status[page] = 1'b1; // this page is now not erased
end

endtask


/* erase_page will erase a page of main memory */

task erase_page ;
input low;

integer low;

integer i;

begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory0[low+i] = 8'hff;
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory1[low+i] = 8'hff;
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory2[low+i] = 8'hff;
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory3[low+i] = 8'hff;
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory4[low+i] = 8'hff;
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory5[low+i] = 8'hff;
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory6[low+i] = 8'hff;
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory7[low+i] = 8'hff;
    else $display ("should never reach here. Something is wrong");

   page_status[page] = 1'b0; // this page is now erased
end

endtask


/* corrupt_buffer will corrupt the entire buffer */

task corrupt_buffer ;
input buf_type;

integer buf_type;

integer i;

begin

  if (buf_type == 1)
    for (i=0 ; i < PAGESIZE; i = i+1)
       buffer1[i] = 8'hx;
  else if (buf_type == 2)
    for (i=0 ; i < PAGESIZE; i = i+1)
       buffer2[i] = 8'hx;
  else
     $display ("Int Error 2. This message should never appear. Something is wrong");

end

endtask


/* corrupt_memory will corrupt a page of memory */

task corrupt_memory ;

integer i;

begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory0[page_boundary_low+i] = 8'hx;
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory1[page_boundary_low+i] = 8'hx;
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory2[page_boundary_low+i] = 8'hx;
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory3[page_boundary_low+i] = 8'hx;
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory4[page_boundary_low+i] = 8'hx;
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory5[page_boundary_low+i] = 8'hx;
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory6[page_boundary_low+i] = 8'hx;
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE; i = i+1)
          memory7[page_boundary_low+i] = 8'hx;
    else $display ("should never reach here. something is wrong");

   page_status[page] = 1'b1; // Actually, sometimes, the status of this page is
                             // unknown. But, using UnErased, is also OK here.
                             // Because, either way, user has to erase, in order
                             // to Program the page
end

endtask


/* corrupt_block will corrupt a block (i.e. 8 pages) of memory */

task corrupt_block ;

integer i;

begin
    if (mem_no == 10)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory0[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 11)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory1[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 12)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory2[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 13)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory3[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 14)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory4[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 15)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory5[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 16)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory6[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else if (mem_no == 17)
       for (i=0 ; i < PAGESIZE*8; i = i+1)
          memory7[page_boundary_low+i] = 8'hx; // corrupted 8 pages
    else $display ("should never reach here. Something is wrong");

    for (i=0 ; i < 8; i = i+1)
       page_status[page+i] = 1'b1; // Actually, sometimes, the status of this page is
                                   //   unknown. But, using UnErased, is also OK here.
                                   //   Because, either way, user has to erase, in order
                                   //   to Program the page
end

endtask


/* Task to compute page address */

task compute_page_address;
begin
   page = 0; // zero out the redundant bits of 'page'
   case (PADDRESS) 
      13 : begin
             page [12:6] = temp_reg1[6:0] ;
             page [5:0] = read_data[7:2] ;
           end
      12 : begin
             if (status[5:3] == 3'b100)
             begin
               page [11:7] = temp_reg1[4:0] ;
               page [6:0] = read_data[7:1] ;
             end
             if (status[5:3] == 3'b101)
             begin
               page [11:6] = temp_reg1[5:0] ;
               page [5:0] = read_data[7:2] ;
             end
           end
      11 : begin
             page [10:7] = temp_reg1[3:0] ;
             page [6:0] = read_data[7:1] ;
           end
      10 : begin
             page [9:7] = temp_reg1[2:0] ;
             page [6:0] = read_data[7:1] ;
           end
       9 : begin
             page [8:7] = temp_reg1[1:0] ;
             page [6:0] = read_data[7:1] ;
           end
   endcase
end
endtask

/* Task to compute starting byte_new address */

task compute_byte_new_address;
begin
   case (BADDRESS)
      10 : byte_new[9:8] = read_data[1:0] ;
       9 : byte_new[8]   = read_data[0] ;
   endcase
end
endtask

/* SPECIFY BLOCK */

specify  /* all timing checks */

`ifdef device1M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

`ifdef device2M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

`ifdef device4M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

`ifdef device8M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

`ifdef device16M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

`ifdef device32M
specparam tSCK = 77  ; // SCK time-period. 10e9/fSCK
specparam tWH = 35;
specparam tWL = 35;
specparam tCS = 250;
specparam tCSS = 250;
specparam tCSH = 250;
specparam tCSB = 200;
specparam tSU = 10;
specparam tH = 20;
specparam tHO = 0;
specparam tRST = 10000;
specparam tREC = 1000;
specparam tBAR = 200;
specparam tCAR1 = 200; // this is same as tCAR, but, is needed twice
specparam tBRBD = 1000;
`endif

  // SCK related
  $period(posedge SCK, tSCK); // SCK period is checked between
  $period(negedge SCK, tSCK); // rise-to-rise, as well as fall-to-fall
  $width(posedge SCK, tWH); // High PulseWidth
  $width(negedge SCK, tWL); // Low PulseWidth

  // CSB related
  $width(posedge CSB, tCS); // CSB Min. High
  $setup(CSB,posedge SCK, tCSS); // CSB setup time
  $hold(posedge SCK, CSB, tCSH); // CSB hold time

  // SI related. Being checked, only when CSB is Low
   $setup(SI, posedge SCK &&& ~CSB, tSU); // SI setup time
   $hold(posedge SCK &&& ~CSB, SI, tH); // SI hold time

  // RESETB related
  $width(negedge RESETB, tRST); // RESETB Low Width
  $recovery(posedge SCK, RESETB, tREC); // RESETB Recovery 

endspecify

endmodule

//`include "test_sequence2.v"
