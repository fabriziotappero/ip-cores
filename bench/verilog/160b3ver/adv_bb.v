



//`timescale      1ns/1ns


//****************************************************************************
// This file contains the paramenters which define the part for the
// Smart 3 Advanced Boot Block memory model (adv_bb.v).  The '2.7V Vcc Timing'
// parameters are representative of the 28F160B3-120 operating at 2.7-3.6V Vcc.
// These parameters need to be changed if the 28F160B3-150 operating at
// 2.7-3.6V Vcc is to be modeled.  The parameters were taken from the Smart 3 
// Advanced Boot Block Flash Memory Family datasheet (Order Number 290580).

// This file must be loaded before the main model, as it contains
// definitions required by the model.

//28F160B3-B

`define BlockFileBegin  "f160b3b.bkb"   //starting addresses of each block
`define BlockFileEnd    "f160b3b.bke"   //ending addresses of each block
`define BlockFileType   "f160b3b.bkt"   //block types

//Available Vcc supported by the device.
`define VccLevels       4       //Bit 0 - 5V, Bit 1 = 3.3V, Bit 2 = 2.7V

`define AddrSize        20          //number of address pins
`define MaxAddr         `AddrSize'hFFFFF    // device ending address
`define MainArraySize   0:`MaxAddr  //array definition in bytes
                                    //include A-1 for 8 bit mode
`define MaxOutputs      16          //number of output pins
`define NumberOfBlocks  39          //number of blocks in the array

`define ID_DeviceCodeB      'h8891  //160B3 Bottom
`define ID_ManufacturerB    'h0089

// Timing parameters.  See the data sheet for definition of the parameter.
// Only the WE# controlled write timing parameters are used since their
// respective CE# controlled write timing parameters have the same value.
// The model does not differentiate between the two types of writes.

//2.7V Vcc Timing

// Changed the timings below to represent a "c3" device. --- RU 9/9/99

`define TAVAV_27            110
`define TAVQV_27            110
`define TELQV_27            110
`define TPHQV_27            150
`define TGLQV_27              0.1
`define TELQX_27              0
`define TEHQZ_27             20
`define TGLQX_27              0
`define TGHQZ_27             20
`define TOH_27                0
`define TPHWL_27            150
`define TWLWH_27             70 
`define TDVWH_27             60
`define TAVWH_27             70
`define TWHDX_27              0
`define TWHAX_27              0
`define TWHWL_27             30
`define TVPWH_27            200


// The following constants control how long it take an algorithm to run
// to scale all times together (for making simulation run faster
// change the constant later listed as TimerPeriod.  The actual delays
// are TimerPeriod*xxx_Time, except for the suspend latency times.

`define TimerPeriod_        1000    //1 usec = 1000ns  requires for
                                    //following times to be accurate

// The typical values given in the datasheet are used.

// reducing the following will reduce simulation time

//2.7V Vcc, 12V Vpp
`define AC_ProgramTime_Word_27_12      8       //usecs
`define AC_EraseTime_Param_27_12       800000  //0.8secs
`define AC_EraseTime_Main_27_12        1100000 //1.1secs
 //Latency times are NOT multiplied by TimerPeriod_
`define AC_Program_Suspend_27_12       5000    //5 usecs
`define AC_Erase_Suspend_27_12         10000   //10 usecs

//2.7V Vcc 2.7V Vpp
`define AC_ProgramTime_Word_27_27      22       //usecs
`define AC_EraseTime_Param_27_27       1000000  //1sec
`define AC_EraseTime_Main_27_27        1800000  //1.8secs
 //Latency times are NOT multiplied by TimerPeriod_
`define AC_Program_Suspend_27_27       6000     //6 usecs
`define AC_Erase_Suspend_27_27         13000    //13 usecs



//generic defines for readability
`define FALSE           1'b0
`define TRUE            1'b1

`define Word            15:0
`define Byte            7:0

`define VIL             1'b0
`define VIH             1'b1

`define Ready           1'b1
`define Busy            1'b0

// These constants are the actual command codes
`define ClearCSRCmd     8'h50
`define ProgramCmd      8'h10
`define Program2Cmd     8'h40
`define EraseBlockCmd   8'h20
`define ReadArrayCmd    8'hFF
`define ReadCSRCmd      8'h70
`define ReadIDCmd       8'h90
`define SuspendCmd      8'hB0  //Valid for both erase
`define ResumeCmd       8'hD0  //and program suspend
`define ConfirmCmd      8'hD0

`define ReadMode_T      2:0
`define rdARRAY         3'b000
`define rdCSR           3'b011
`define rdID            3'b100

`define   Program           2'b00
`define   Erase             2'b01

// Cmd_T record
`define   Cmd_T             172:0
`define   CmdAdd_1          172:153
`define   CmdAdd_2          152:133
`define   Add               132:113
`define   CmdData_1         112:97
`define   CmdData_2         96:81
`define   Cmd               80:73
`define   Count             72:41
`define   Time              40:9
`define   Confirm           8
`define   OpBlock           7:2
`define   OpType            1:0
`define   CmdData1Fx8       104:97

`define WritePtr_T          1:0
`define NewCmd              2'b01
`define CmdField            2'b10

`define BlockType_T         1:0
`define MainBlock           2'b00
`define LockBlock           2'b01
`define ParamBlock          2'b10

`define Vcc2700             3'b100
`define Vcc3300             3'b010
`define Vcc5000             3'b001


// device specific

//module definition for Intel Advanced Boot Block Flash Memory Family
//
//vpp and vcc are are 32 bit vectors which are treated as unsigned int
//scale for vpp and vcc is millivolts.  ie. 0 = 0V, 5000 = 5V
//

module IntelAdvBoot(dq, addr, ceb, oeb, web, rpb, wpb, vpp, vcc);

inout [`MaxOutputs-1:0] dq;     //16 outputs

input [`AddrSize-1:0]   addr;   //address pins.

input                   ceb,    //CE# - chip enable bar
                        oeb,    //OE# - output enable bar
                        web,    //WE# - write enable bar
                        rpb,    //RP# - reset bar, powerdown
                        wpb;    //WP# = write protect bar
                        
input [31:0]            vpp,    //vpp in millivolts
                        vcc;    //vcc in millivolts

reg [`Word]             MainArray[`MainArraySize];  //flash array

//  Flag to show that a Cmd has been written
//  and needs predecoding
reg       CmdValid ;

// This points to where data written to the part will
// go. By default it is to NewCmd. CmdField means the 
// chip is waiting on more data for the cmd (ie confirm)

reg [`WritePtr_T]   WriteToPtr ;

// Contains the current executing command and all its 
// support information.
reg  [`Cmd_T] Cmd;
reg  [`Cmd_T] Algorithm;
reg  [`Cmd_T] SuspendedAlg;

// Output of Data
reg [`Word]  ArrayOut ;

// Current output of the Compatible status register
reg [`Word]  CSROut ;

// Current output of the ID register
reg [`Word]  IDOut ;

//  Startup Flag phase
reg        StartUpFlag ;

//  Global Reset Flag
reg         Reset ;

//Vpp Monitoring
reg         VppFlag ;
reg         VppError ;
reg         VppErrFlag ;
reg         ClearVppFlag ;

// Internal representation of the CSR SR.1 bit
reg         BlockLockStatus;
// Internal representation of the CSR SR.4 bit
reg         ProgramError;
// Internal representation of the CSR SR.5 bit
reg         EraseError;

//  Internal representation of CUI modes
reg [`ReadMode_T] ReadMode ;

//  Current value of the CSR
wire [`Byte] CSR ;

//  Flag that determines if the chip is driving
//  the outputs
reg        DriveOutputs ;

//  Internal value of the out data.  If DriveOutputs
//  is active this value will be placed on the
//  outputs.  -1 == Unknown or XXXX
reg [`MaxOutputs-1:0]    InternalOutput ;

//  Number of addition writes necessary to 
//  supply the current command information.
//  When it hits zero it goes to Decode
integer       DataPtr ;

//  Master internal write enable
wire       Internal_WE ;
   
//  Master internal output enable
wire       Internal_OE ;
wire       Internal_OE2 ;
wire       Internal_OE3 ;

//  Master internal read enable
wire       Internal_RE ;

//  Master internal boot block write enable
reg         InternalBoot_WE ;
wire        InternalBoot;

//  Internal flag to tell if an algorithm is running
reg         ReadyBusy ;
//reg        RunningAlgorithm ;  *******************************

//  Flag to represent if the chip is write suspended
reg        WriteSuspended ;
//  Flag to represent if the chip is erase suspended
reg        EraseSuspended ;
// Flag for if the chip should be suspended
reg        Suspend ;
//  Variable to hold which algorithm (program or erase)
//  is to be suspended
reg [1:0]  ToBeSuspended;

//  Algorithm Timer
reg        TimerClk ;

//  Flag to show the running algorithm is done.
reg        AlgDone ;

// Number of timer cycles remaining for the 
// current algorithm
integer    AlgTime;

// Number of timer cycles remaining for erase operation
// when erase suspended and program operation in progress
integer    TimeLeft;

// Generic temporary varible
integer    LoopCntr ;
reg        Other ;

//Block begin and end address
reg [`AddrSize-1:0] BlocksBegin[0:`NumberOfBlocks-1];
reg [`AddrSize-1:0] BlocksEnd[0:`NumberOfBlocks-1];
reg [`BlockType_T] BlocksType[0:`NumberOfBlocks-1];
reg [31:0]  BlocksEraseCount[0:`NumberOfBlocks-1];

//************************************************************************
//TIMING VALUES

//************************************************************************
time    ToOut ;
time    last_addr_time ,curr_addr_time;
time    last_oe_time, curr_oe_time;
time    last_ce_time, curr_ce_time;
time    last_rp_time, curr_rp_time;
time    last_ReadMode_time, curr_ReadMode_time ;
time    last_Internal_RE_time, curr_Internal_RE_time ;
time    last_Internal_WE_time, curr_Internal_WE_time ;
time    last_dq_time ,curr_dq_time;
time    last_rpb_time, curr_rpb_time ;
time    WriteRecovery ;
time    TempTime;

time    Program_Time_Word;
time    Param_Erase_Time;
time    Main_Erase_Time;
time    Program_Suspend_Time;  // latency time
time    Erase_Suspend_Time;    // latency time

//************************************************************************
//input configuration

                        
parameter
    LoadOnPowerup = `FALSE,        //load array from file
    LoadFileName = "f160b3.dat",   //File to load array with
    SaveOnPowerdown = `FALSE,      //save array to file
    SaveFileName = "f160b3.dat";   //save file name

//TIMING PARAMETERS
parameter
    TAVAV       =   `TAVAV_27,
    TAVQV       =   `TAVQV_27,
    TELQV       =   `TELQV_27,
    TPHQV       =   `TPHQV_27,
    TGLQV       =   `TGLQV_27,
    TELQX       =   `TELQX_27,
    TEHQZ       =   `TEHQZ_27,
    TGLQX       =   `TGLQX_27,
    TGHQZ       =   `TGHQZ_27,
    TOH         =   `TOH_27  ,
    TPHWL       =   `TPHWL_27,
    TWLWH       =   `TWLWH_27,
    TDVWH       =   `TDVWH_27,
    TAVWH       =   `TAVWH_27,
    TWHDX       =   `TWHDX_27,
    TWHAX       =   `TWHAX_27,
    TWHWL       =   `TWHWL_27,
    TVPWH       =   `TVPWH_27,
    TimerPeriod =   `TimerPeriod_;
    

//************************************************************************


initial begin
    Other               =       `FALSE  ;
    AlgDone             =       `FALSE  ;
    Reset               =       1'hx    ;
    Reset               <=      `TRUE   ;
    StartUpFlag         =       `TRUE   ;
    StartUpFlag         <=  #2  `FALSE  ;
    DriveOutputs        =       `FALSE  ;
    ToOut               =       0       ;       
    VppError            =       `FALSE  ;
    VppErrFlag          =       `FALSE  ;
    ClearVppFlag        =       `FALSE  ;
    VppFlag             =       `FALSE  ;
    WriteSuspended      =       `FALSE  ;
    EraseSuspended      =       `FALSE  ;
    Suspend             =       `FALSE  ;
    ToBeSuspended       =       `Program;
    EraseError          =       `FALSE  ;
    TimerClk            =       1'b0    ;
    ArrayOut            =       `MaxOutputs'hxxxx ;
    CSROut              =       0       ;
    IDOut               =       0       ;
    CmdValid            =       `FALSE  ;
    WriteToPtr          =       `NewCmd ;
    last_addr_time      =       0       ;
    curr_addr_time      =       0       ;
    last_ce_time      =         0       ;
    curr_ce_time      =         0       ;
    last_oe_time      =         0       ;
    curr_oe_time      =         0       ;
    last_rp_time      =         0       ;
    curr_rp_time      =         0       ;
    last_ReadMode_time  =       0       ;
    curr_ReadMode_time  =       0       ;
    last_dq_time        =       0       ;
    curr_dq_time        =       0       ;
    last_rpb_time       =       0       ;
    curr_rpb_time       =       0       ;
    WriteRecovery       =       0       ;
    last_Internal_RE_time =     0       ;
    curr_Internal_RE_time =     0       ;
    InternalOutput        =     `MaxOutputs'hx     ;
    last_Internal_WE_time = 0           ;
    curr_Internal_WE_time = 0           ;
    Program_Time_Word    = `AC_ProgramTime_Word_27_12;
    Param_Erase_Time     = `AC_EraseTime_Param_27_12;
    Main_Erase_Time      = `AC_EraseTime_Main_27_12;
    Program_Suspend_Time = `AC_Program_Suspend_27_12;
    Erase_Suspend_Time   = `AC_Erase_Suspend_27_12;

    $readmemh(`BlockFileBegin,BlocksBegin);
    $readmemh(`BlockFileEnd,BlocksEnd);
    $readmemh(`BlockFileType,BlocksType,0,`NumberOfBlocks-1);
    for (LoopCntr = 0; LoopCntr <= `NumberOfBlocks; LoopCntr = LoopCntr + 1) begin
        BlocksEraseCount [LoopCntr] = 0 ;
    end

//------------------------------------------------------------------------
// Array Init
//------------------------------------------------------------------------

//Constant condition expression: LoadOnPowerup == 1'b1
    if (LoadOnPowerup) 
        LoadFromFile;
    else begin
      //$display("Initializing Memory to 'hFFFF");
      //for (LoopCntr = 0; LoopCntr <= `MaxAddr; LoopCntr = LoopCntr + 1) begin
      //  MainArray [LoopCntr] = 16'hFFFF ;
      $display("FLASH: Initializing Memory data to address value (0, 1, 2 ...)");
      for (LoopCntr = 0; LoopCntr <= 1024; LoopCntr = LoopCntr + 1) begin
        MainArray [LoopCntr] = LoopCntr ;

      end
    end
end


//------------------------------------------------------------------------
// LoadFromFile
//  This is used when the LoadOnPowerup parameter is set so that the Main 
//  array contains code at startup.  Basically it loads the array from 
//  data in a file (LoadFileName).
//------------------------------------------------------------------------

task LoadFromFile ;
begin
    $display("FLASH: Loading from file %s",LoadFileName);
    $readmemh(LoadFileName,MainArray);
end
endtask 

//------------------------------------------------------------------------
// StoreToFile
//  This is used when the SaveOnPowerDown flag is set so that the Main 
//  Array stores code at powerdown.  Basically it stores the array into
//  a file (SaveFileName).
//-----------------------------------------------------------------

task  StoreToFile;
    reg [31:0]  ArrayAddr ;
    reg [31:0]  outfile ;
begin
    outfile = $fopen(SaveFileName) ;
    if (outfile == 0) 
        $display("FLASH: Error, cannot open output file %s",SaveFileName) ;
    else
        $display("FLASH: Saving data to file %s",SaveFileName);
    for (ArrayAddr = 0 ; ArrayAddr <= `MaxAddr; ArrayAddr = ArrayAddr + 1) begin
        $fdisplay(outfile,"%h",MainArray[ArrayAddr]);
    end
end 
endtask

//------------------------------------------------------------------------
// Program  
// -- Description: Programs new values in to the array --
//------------------------------------------------------------------------

task  Program ;
  inout  [`Word] TheArrayValue ;
  input  [`Word] DataIn;

  reg    [`Word] OldData;
  begin
    OldData = TheArrayValue;
    TheArrayValue = DataIn & OldData;
  end 
endtask


assign  Internal_OE = !(ceb | oeb | !rpb) ;
assign  Internal_OE2 = Internal_OE ;
assign  Internal_OE3 = Internal_OE2 ;
assign  Internal_RE = (((ReadyBusy == `Ready) || (ReadMode != `rdARRAY)) && !ceb && !Reset) ;
assign  Internal_WE = !(ceb | web | !rpb) ;
assign  InternalBoot = wpb ;

//******************************************************************
// Determine if the algorithm engine is operating
//assign  ReadyBusy = (RunningAlgorithm & !Suspended) ? `Busy : `Ready;
//******************************************************************

// register definitions //

// Compatible Status Register
assign  CSR [7] = ReadyBusy;
assign  CSR [6] = EraseSuspended ;
assign  CSR [5] = EraseError ;
assign  CSR [4] = ProgramError ;
assign  CSR [3] = VppError ;
assign  CSR [2] = WriteSuspended;
assign  CSR [1] = BlockLockStatus;
assign  CSR [0] = 1'b0;


// Output Drivers //
assign dq = (DriveOutputs == `TRUE) ? InternalOutput : 16'hz;

always @(Reset) begin : Reset_process
    if (Reset) begin   
        ClearVppFlag    <=  #1  `TRUE   ;
        ClearVppFlag    <=  #9  `FALSE  ;
        AlgDone         =       `FALSE  ;
        VppError        =       `FALSE  ;
        ReadMode        =       `rdARRAY;
        ReadyBusy       =       `Ready  ;
        WriteSuspended  =       `FALSE  ;
        EraseSuspended  =       `FALSE  ;
        Suspend         =       `FALSE  ;
        EraseError      =       `FALSE  ;
        ProgramError    =       `FALSE  ;
        BlockLockStatus =       `FALSE  ;
        AlgTime         =       0       ;
        CmdValid        =       `FALSE  ;
        WriteToPtr      =       `NewCmd ;
        CSROut          =       0       ;
        IDOut           =       0       ;
    end
end


always @(Internal_RE or ReadMode or addr) begin : array_read
  if (Internal_RE && ReadMode == `rdARRAY) begin
    ArrayOut = MainArray[addr] ;      // x16 outputs
  end
end


always @(Internal_RE or ReadMode or addr or Internal_OE2 or ArrayOut) begin
    // output mux
    // Determine and generate the access time .
    ToOut = 0;

    if ($time > TAVQV) begin
        last_addr_time = $time - curr_addr_time;

        if ((last_addr_time < TAVQV) && ((TAVQV - last_addr_time) > ToOut))
            ToOut = TAVQV - last_addr_time ;
        last_oe_time = $time - curr_oe_time;
        if ((last_oe_time < TGLQV) && ((TGLQV - last_oe_time) > ToOut))
            ToOut = TGLQV - last_oe_time ;
        last_ce_time = $time - curr_ce_time;

        if ((last_ce_time < TELQV) && ((TELQV - last_ce_time) > ToOut))
            ToOut = TELQV - last_ce_time ;
        last_rp_time = $time - curr_rp_time;
        if ((last_rp_time < TPHQV) && ((TPHQV - last_rp_time) > ToOut))
            ToOut = TPHQV - last_rp_time ;
        last_ReadMode_time = $time - curr_ReadMode_time;
        if ((last_ReadMode_time < TAVQV) && ((TAVQV - last_ReadMode_time) > ToOut))
            ToOut = TAVQV - last_ReadMode_time ;
        last_Internal_RE_time = $time - curr_Internal_RE_time ;
        if ((last_Internal_RE_time < TAVQV) && ((TAVQV - last_Internal_RE_time) > ToOut)) begin
           ToOut = TAVQV - last_Internal_RE_time ;
            end

        end

//  Output Mux with timing
    if (!StartUpFlag) begin
         case (ReadMode) 
            `rdARRAY : begin
              if ( (EraseSuspended == `TRUE) && (WriteSuspended == `FALSE)
                   && (addr >= BlocksBegin[Algorithm[`OpBlock]])
                   && (addr <= BlocksEnd[Algorithm[`OpBlock]]) && (oeb == `VIL) ) begin
                $display("FLASH: Error:  Attempting to read from erase suspended block");
                InternalOutput <= `MaxOutputs'hxxxx;
              end
              else if ( (WriteSuspended == `TRUE) && (EraseSuspended == `TRUE)
                       && (addr >= BlocksBegin[SuspendedAlg[`OpBlock]])
                       && (addr <= BlocksEnd[SuspendedAlg[`OpBlock]]) && (oeb == `VIL)) begin
                $display("FLASH: Error:  Attempting to read from erase suspended block");
                InternalOutput <= `MaxOutputs'hxxxx;
              end
              else if ( (WriteSuspended == `TRUE) && (addr == Algorithm[`CmdAdd_1])
                       && (oeb == `VIL) ) begin
                $display("FLASH: Error:  Attempting to read from write suspended address");
                InternalOutput = `MaxOutputs'hxxxx;
              end
              else
                InternalOutput <= #ToOut ArrayOut ;
            end
            `rdCSR   : begin
                InternalOutput <= #ToOut CSROut ;
            end
            `rdID    :  begin
                InternalOutput <= #ToOut IDOut ;
            end
            default  :  begin
                $display("FLASH: Error: illegal readmode");
            end
        endcase
    end
end



//
// other reads 
//
always @(Internal_OE or addr) begin : other_read
    if (!Reset) begin
        if (ReadMode != `rdARRAY) begin
            CSROut = {8'h00,CSR} ;
            if (addr[0] == 1'b0) 
                IDOut = `ID_ManufacturerB ;
            else
                IDOut = `ID_DeviceCodeB ;
        end
    end
end

// Handle Write to Part

always @(negedge Internal_WE) begin : handle_write
  reg [`Word]   temp ;       // temporary variable needed for double
                             // indexing CmdData.
  if (!Reset) begin
    case (WriteToPtr)                        // Where are we writting to ?
      `NewCmd : begin                       // This is a new command.
         Cmd[`Cmd] = dq[7:0];
         Cmd[`Add] = addr[`AddrSize-1:0];   //by 16 word index
         CmdValid <= `TRUE ;                // CmdValid sends it to the Predecode section
         DataPtr <= -1;
       end
      `CmdField : begin   // This is data used by another command
         if (DataPtr == 1) begin
           Cmd[`CmdData_1] = dq[`Word];
           Cmd[`CmdAdd_1] = addr[`AddrSize-1:0];
         end
         else if (DataPtr == 2) begin
           Cmd[`CmdData_2] = dq[`Word];
           Cmd[`CmdAdd_2] = addr[`AddrSize-1:0];
         end
         else
           $display("FLASH: DataPtr out of range");
         DataPtr <= #1 DataPtr - 1 ; // When DataPtr = 0 the command goes to Decode section
       end
       default : begin
         $display("FLASH: Error: Write To ? Cmd");
       end
    endcase
  end
end

//
// Predecode Command
//
always @(posedge CmdValid) begin : predecode
  reg [`Byte] temp;       // temporary variable needed for double 
                          // indexing BSR.
  if (!Reset) begin
    // Set Defaults
    Cmd [`OpType] = `Program ;
    WriteToPtr = `NewCmd ;
    DataPtr <= 0 ;
    case (Cmd [`Cmd])            // Handle the basic read mode commands
    // READ ARRAY COMMAND --
      `ReadArrayCmd  : begin     // Read Flash Array
         CmdValid <= `FALSE ;
         if (ReadyBusy == `Busy) // Can not read array when running an algorithm
           ReadMode <= `rdCSR ;
         else
           ReadMode <= `rdARRAY ;
       end
    // READ INTELLIGENT IDENTIFIER COMMAND --
      `ReadIDCmd     :  begin    // Read Intelligent ID
         if ((WriteSuspended == `TRUE) || (EraseSuspended == `TRUE))
           $display("FLASH: Invalid read ID command during suspend");
         else
           ReadMode <= `rdID ;
         CmdValid <= `FALSE ;
       end
    // READ COMPATIBLE STATUS REGISTER COMMAND --
      `ReadCSRCmd  : begin       // Read CSR 
         ReadMode <= `rdCSR ;
         CmdValid <= `FALSE ;
       end 
       default  : begin 
         Other = `TRUE ;            // Other flag marks commands that are algorithms
         Cmd [`Confirm] = `FALSE  ; // Defaults
         case (Cmd [`Cmd])
    // PROGRAM WORD COMMAND --
           `ProgramCmd : begin                              // Program Word
              if (WriteSuspended == `TRUE) begin
                $display("FLASH: Error:  Program Command during Write Suspend");
                CmdValid <= `FALSE;
              end
              else begin
                WriteToPtr = `CmdField;
                DataPtr <= 1;
                if (EraseSuspended == `TRUE) begin
                  TimeLeft = AlgTime;
                  SuspendedAlg = Algorithm;
                end
                ToBeSuspended = `Program;
                Cmd [`Time] = Program_Time_Word;
              end
            end
    // PROGRAM WORD COMMAND --
           `Program2Cmd  : begin       // Program Word
              if (WriteSuspended == `TRUE) begin
                $display("FLASH: Error:  Program Command during Write Suspend");
                CmdValid <= `FALSE;
              end
              else begin
                Cmd [`Cmd] = `ProgramCmd;
                WriteToPtr = `CmdField;
                DataPtr <= 1;
                if (EraseSuspended == `TRUE) begin
                  TimeLeft = AlgTime;
                  SuspendedAlg = Algorithm;
                end
                ToBeSuspended = `Program;
                Cmd [`Time] = Program_Time_Word ;
              end
            end
    // ERASE BLOCK COMMAND --
           `EraseBlockCmd : begin    // Single Block Erase
              if ((WriteSuspended == `TRUE) || (EraseSuspended == `TRUE)) begin
                $display("FLASH: Attempted to erase block while suspended");
                CmdValid <= `FALSE;
              end
              else begin
                WriteToPtr = `CmdField;
                DataPtr <= 1;
//              Cmd [`Time] = `AC_EraseTime ;
                Cmd [`OpType] = `Erase;
                Cmd [`Confirm] = `TRUE;
                ToBeSuspended = `Erase;
              end
            end
            default : begin // The remaining commands are complex non-algorithm commands
              Other = `FALSE ;
              CmdValid = `FALSE ;
    // CLEAR STATUS REGISTER COMMAND
              if (Cmd [`Cmd] == `ClearCSRCmd) begin
                if (WriteSuspended | EraseSuspended)
                  ReadMode <= `rdARRAY;
                else if (ReadyBusy == `Busy)
                  ReadMode <= `rdCSR;
                else begin
                  EraseError <= `FALSE;
                  ProgramError <= `FALSE;
                  VppError <= `FALSE;
                  BlockLockStatus <= `FALSE;
                  ReadMode <= `rdCSR;
                end
              end
    // RESUME COMMAND --
              else if (Cmd [`Cmd] == `ResumeCmd) begin
                if (WriteSuspended | EraseSuspended)
                  ReadMode <= `rdCSR;
                Suspend = `FALSE;
                if (ToBeSuspended == `Program)
                  WriteSuspended <= `FALSE;
                else
                  EraseSuspended <= `FALSE;
                ReadyBusy = `Busy;
              end
    // SUSPEND COMMAND --
              else if (Cmd [`Cmd] == `SuspendCmd) begin
                if (ReadyBusy == `Ready) begin
                  ReadMode <= `rdARRAY;
                  $display("FLASH: Algorithm finished; nothing to suspend");
                end
                else begin
                  ReadMode <= `rdCSR;
                  Suspend = `TRUE;
                end
                CmdValid <= `FALSE;
              end
              else begin
                CmdValid <= `FALSE;
                $display("FLASH: Warning:Illegal Command (%h)", Cmd [`Cmd]);	// Added displaying command code,--- RU 9/10/99
              end
            end  //default
         endcase 
       end  //default
    endcase
  end  //if
end  //always (predecode)


//
// Command Decode
//
always @(DataPtr) begin : command
  integer BlockUsed;
  // When DataPtr hits zero it means that all the
  // additional data has been given to the current command
  if (!Reset && (DataPtr == 0) && (WriteToPtr != `NewCmd)) begin
    if (CmdValid && (WriteToPtr == `CmdField)) begin
      WriteToPtr = `NewCmd;
      // Just finish a multi-cycle command.  Determine which block the command uses
      BlockUsed = -1;
      for (LoopCntr = `NumberOfBlocks-1; LoopCntr >= 0; LoopCntr = LoopCntr - 1) begin
        if (Cmd[`CmdAdd_1] <= BlocksEnd[LoopCntr])
          BlockUsed = LoopCntr;
      end
      if (BlockUsed == -1)
        $display("FLASH: Error:  Invalid Command Address");
      else
        Cmd [`OpBlock] = BlockUsed;
      if (Cmd [`OpType] ==  `Erase ) begin
        if (BlocksType[BlockUsed] == `MainBlock)
          Cmd[`Time] = Main_Erase_Time;
        else
          Cmd[`Time] = Param_Erase_Time;
      end
      else if (Cmd [`OpType] == `Program)
        Cmd[`Time] = Program_Time_Word;
      else
        Cmd[`Time] = 0;
      // If this command needs a confirm 
      // (flaged at predecode) then check if confirm was received
      if (Cmd [`Confirm]) begin
        if (Cmd[`CmdData1Fx8] == `ConfirmCmd) begin
       // If the command is still valid put it in the queue and deactivate the array
          Algorithm = Cmd;
          AlgTime = Cmd [`Time] ;
          CmdValid <= `FALSE;
          if (!VppError)
            ReadyBusy <= #1 `Busy;
          ReadMode <= `rdCSR;
        end
        else begin
          ReadMode <= `rdCSR ;
          ProgramError <= `TRUE;
          EraseError <= `TRUE;
          CmdValid <= `FALSE;
        end
      end   
      else begin
        Algorithm = Cmd;
        AlgTime = Cmd [`Time] ;
        CmdValid <= `FALSE;
        if (!VppError)
          ReadyBusy <= #1 `Busy ;
        ReadMode <= `rdCSR;
      end
    end 
  end
end  //always (command)

//////////////
// Execution //
//////////////
always @(posedge AlgDone)  begin  : execution
  if (!Reset) begin
    if (AlgDone) begin   // When the algorithm finishes
                         // if chips is executing during an erase interrupt
                         // then execute out of queue slot 2
      if (Algorithm [`OpType] == `Erase) begin
    // ERASE COMMAND //
        if (VppFlag) begin
          VppError <= `TRUE ;
          EraseError <= `TRUE;
        end
        else begin
    // Do ERASE to OpBlock
          if ((BlocksType[Algorithm[`OpBlock]] == `LockBlock) && !InternalBoot_WE) begin
            $display("FLASH: Error: Attempted to erase locked block.");
            EraseError <= `TRUE;
            BlockLockStatus <= `TRUE;
          end
          else begin
            for (LoopCntr = BlocksBegin[Algorithm[`OpBlock]];
                 LoopCntr <= BlocksEnd[Algorithm[`OpBlock]]; LoopCntr = LoopCntr + 1)
              MainArray [LoopCntr] = 'hFFFF;
            BlocksEraseCount[Algorithm[`OpBlock]] = BlocksEraseCount[Algorithm[`OpBlock]] + 1;
            $display("FLASH: Block %d Erase Count: %d",Algorithm[`OpBlock],BlocksEraseCount[Algorithm[`OpBlock]]);
          end
        end
      end
      else begin
    // PROGRAM COMMAND //
        if (VppFlag) begin
          ProgramError <= `TRUE;
          VppError <= `TRUE ;
        end
        else begin
          if ((BlocksType[Algorithm[`OpBlock]] == `LockBlock) && !InternalBoot_WE) begin
            $display("FLASH: Error: Attempted to program locked boot block.");
            ProgramError <= `TRUE;
            BlockLockStatus <= `TRUE;
          end
          else begin
            Program (MainArray[Algorithm [`CmdAdd_1]], Algorithm [`CmdData_1]);
            if (EraseSuspended == `TRUE) begin
              AlgTime = TimeLeft;
              ToBeSuspended = `Erase;
              Algorithm = SuspendedAlg;
            end
          end
        end
      end
    end  //if (AlgDone)
    ReadyBusy <= `Ready;
  end  //if (!Reset)
end  //always (execution)

always @(ReadyBusy) begin
  if ((!Reset) && (ReadyBusy  == `Busy)) begin  // If the algorithm engine
                                                // just started, start the clock
    ClearVppFlag <= #1 `TRUE ;
    ClearVppFlag <= #3 `FALSE ;
    TimerClk <= #1 1'b1 ;
    TimerClk <= #TimerPeriod 1'b0 ;
  end 
end

// record the time for addr changes .
always @(addr) begin
  if ($time != 0 & !ceb) begin
    if (((curr_addr_time + TAVAV) > $time) & !ceb)    //Read/Write Cycle Time		--- Added "& !ceb" RU 9/9/99 9pm
      $display("FLASH: [",$time,"] Timing Violation: Read/Write Cycle Time (TAVAV), Last addr change: %d",curr_addr_time) ;
    curr_addr_time = $time ;
  end
end

// record the time for oe changes .
always @(oeb) begin
  if ($time != 0) begin
    curr_oe_time = $time ;
  end
end

// record the time for ce changes .
always @(ceb) begin
  if ($time != 0) begin
    curr_ce_time = $time ;
  end
end

reg rpb_r;
initial rpb_r = rpb;

// record the time for rp changes .
always @(rpb) begin
  if ((rpb_r != rpb) & ($time != 0) ) begin
    curr_rp_time = $time ;
    rpb_r = rpb;
  end
end

// record the time for ReadMode changes .
always @(ReadMode) begin
  if ($time != 0) begin
    curr_ReadMode_time = $time ;
  end
end

// record the time for Internal_RE changes .
always @(Internal_RE) begin
  if ($time != 0) begin
    curr_Internal_RE_time = $time ;
  end
end

always @(InternalBoot) begin
  InternalBoot_WE <= #TVPWH InternalBoot;
end

always @(TimerClk) begin
  if ((!Reset) && (ReadyBusy == `Busy) && (TimerClk == 1'b0)) begin  // Reschedule clock and
                                                                     // decrement algorithm count
    TimerClk <= #1 1'b1 ;
    TimerClk <= #TimerPeriod 1'b0 ; 
    if (Suspend) begin   // Is the chip pending suspend? If so do it
      Suspend = `FALSE;
      if (ToBeSuspended == `Program) begin
        WriteSuspended <= #Program_Suspend_Time `TRUE;
        ReadyBusy <= #Program_Suspend_Time `Ready;
      end
      else begin
        EraseSuspended <= #Erase_Suspend_Time `TRUE;
        ReadyBusy <= #Erase_Suspend_Time `Ready;
      end
    end
    if (ReadyBusy == `Busy) begin
      AlgTime = AlgTime - 1;
      if (AlgTime <= 0) begin // Check if the algorithm is done
        AlgDone <= #1 `TRUE ;
        AlgDone <= #10 `FALSE ;
      end 
    end
  end 
end 

//------------------------------------------------------------------------
//  Reset Controller
//------------------------------------------------------------------------

always @(rpb or vcc) begin : ResetPowerdownMonitor 
    // Go into reset if reset powerdown pin is active or
    // the vcc is too low
    if ((rpb != `VIH) || (vcc < 2500)) begin // Low Vcc protection
        Reset <= `TRUE ;
    if (!((vcc >= 2500) || StartUpFlag))
        $display ("FLASH: Low Vcc: Chip Resetting") ;
    end
    else
    // Coming out of reset takes time
        Reset <= #TPHWL  `FALSE ;
end


//------------------------------------------------------------------------
// VccMonitor
//------------------------------------------------------------------------

always @(Reset or vcc) begin : VccMonitor
// Save the array when chip is powered off
  if ($time > 0) begin
    if (vcc == 0 && SaveOnPowerdown)
      StoreToFile;
    if (vcc < 2700)
      $display("FLASH: Vcc is below minimum operating specs");
    else if ((vcc >= 2700) && (vcc <= 3600) && (`VccLevels & `Vcc2700)) begin
      //$display ("Vcc is in operating range for 2.7 volt mode") ;			// Commented out RU 9/11/99
/*
      TAVAV       =   `TAVAV_27;
      TAVQV       =   `TAVQV_27;
      TELQV       =   `TELQV_27;
      TPHQV       =   `TPHQV_27;
      TGLQV       =   `TGLQV_27;
      TELQX       =   `TELQX_27;
      TEHQZ       =   `TEHQZ_27;
      TGLQX       =   `TGLQX_27;
      TGHQZ       =   `TGHQZ_27;
      TOH         =   `TOH_27  ;
      TPHWL       =   `TPHWL_27;
      TWLWH       =   `TWLWH_27;
      TDVWH       =   `TDVWH_27;
      TAVWH       =   `TAVWH_27;
      TWHDX       =   `TWHDX_27;
      TWHAX       =   `TWHAX_27;
      TWHWL       =   `TWHWL_27;
      TVPWH       =   `TVPWH_27;
*/
      if ((vpp <= 3600) && (vpp >= 2700)) begin
        Param_Erase_Time  = `AC_EraseTime_Param_27_27;
        Main_Erase_Time   = `AC_EraseTime_Main_27_27;
        Program_Time_Word = `AC_ProgramTime_Word_27_27;
      end
      else begin
        Param_Erase_Time  = `AC_EraseTime_Param_27_12;
        Main_Erase_Time   = `AC_EraseTime_Main_27_12;
        Program_Time_Word = `AC_ProgramTime_Word_27_12;
      end
    end
    else
      $display ("FLASH: Vcc is out of operating range") ;
  end //$time
end

//------------------------------------------------------------------------
// VppMonitor
//------------------------------------------------------------------------
always @(VppFlag or ClearVppFlag or vpp) begin : VppMonitor
  if (ClearVppFlag) begin
    VppErrFlag = `FALSE ;
  end
  else
    if (!(((vpp <= 12600) && (vpp >= 11400)) || ((vpp <= 3600) && (vpp >= 2700)))) begin
      VppErrFlag = `TRUE ;
    end
  if ((vpp <= 3600) && (vpp >= 2700)) begin
    if ((vcc >= 2700) && (vcc <= 3600)) begin
      Param_Erase_Time  = `AC_EraseTime_Param_27_27;
      Main_Erase_Time   = `AC_EraseTime_Main_27_27;
      Program_Time_Word = `AC_ProgramTime_Word_27_27;
    end
    else begin
      $display("FLASH: Invalid Vcc level at Vpp change");
      VppErrFlag = `TRUE;
    end
  end
  else begin
    if ((vcc >= 2700) && (vcc <= 3600)) begin
      Param_Erase_Time  = `AC_EraseTime_Param_27_12;
      Main_Erase_Time   = `AC_EraseTime_Main_27_12;
      Program_Time_Word = `AC_ProgramTime_Word_27_12;
    end
    else begin
      $display("FLASH: Invalid Vcc level at Vpp change");
      VppErrFlag = `TRUE;
    end
  end
  VppFlag <= VppErrFlag;
end


always @(StartUpFlag or Internal_OE3) begin : OEMonitor
   // This section generated DriveOutputs which is the main signal that
   // controls the state of the output drivers

   if (!StartUpFlag)  begin
      WriteRecovery = 0 ;
      last_Internal_WE_time = $time - curr_Internal_WE_time;
      if (Internal_OE) begin
         TempTime = WriteRecovery + TGLQX ;
         DriveOutputs = `FALSE ;
         WriteRecovery = WriteRecovery + TGLQV - TempTime;
         DriveOutputs <= #WriteRecovery `TRUE ;
      end
      else begin
         InternalOutput <= #TOH `MaxOutputs'hx;
         if (oeb == `VIH)
           WriteRecovery = WriteRecovery + TGHQZ;
         else
           WriteRecovery = WriteRecovery + TEHQZ;
         DriveOutputs <= #WriteRecovery `FALSE ;
      end
   end 
   else
      DriveOutputs <= `FALSE ;
end

/////// Timing Checks /////////////

always @(Internal_WE) begin : Timing_chk
  if ($time > 0) begin
  // pulse chk
    if (Internal_WE) begin
      if ((($time - curr_Internal_WE_time) < TWHWL) && (TWHWL > 0 )) begin
        $display("FLASH: [",$time,"] Timing Violation: Internal Write Enable Insufficient High Time") ;
      end
    end
    else if ((($time - curr_Internal_WE_time) < TWLWH) && (TWLWH > 0 ))
      $display("FLASH: [",$time,"] Timing Violation: Internal Write Enable Insufficient Low Time") ;
    curr_Internal_WE_time = $time ;
    // timing_chk - addr
    last_dq_time = $time - curr_dq_time;
    last_rpb_time = $time - curr_rpb_time;
    last_addr_time = $time - curr_addr_time;
    if (Internal_WE == 0)  begin
      if ((last_addr_time < TAVWH) && (last_addr_time > 0))
        $display("FLASH: [",$time,"] Timing Violation: Address setup time during write, Last Event %d",last_addr_time) ;
      if ((last_rpb_time < TPHWL) && (last_rpb_time > 0))
        $display("FLASH: [",$time,"] Timing Violation: Writing while coming out of powerdown,  Last Event %d",last_rpb_time) ;
      if ((last_dq_time < TDVWH) && (last_dq_time > 0))
        $display("FLASH: [",$time,"] Timing Violation: Data setup time during write, Last Event %d",last_dq_time) ;
    end 
  end
end  

always @(addr) begin
  last_Internal_WE_time = $time - curr_Internal_WE_time;
  if (($time > 0) && !Internal_WE) begin   //timing chk
    if ((last_Internal_WE_time < TWHAX) && (last_Internal_WE_time > 0))
      $display("FLASH: [",$time,"] Timing Violation:Address hold time after write, Last Event %d",last_Internal_WE_time) ;
  end
end

always @(rpb) begin
  if ((rpb_r != rpb) & ($time > 0)) begin
    curr_rpb_time = $time ;
  end
end

always @(dq) begin
  curr_dq_time = $time ;
  last_Internal_WE_time = $time - curr_Internal_WE_time;
  if (($time > 0) && !Internal_WE) begin
    if ((last_Internal_WE_time < TWHDX) && (last_Internal_WE_time > 0))
      $display("FLASH: [",$time,"] Timing Violation:Data hold time after write, Last Event %d",last_Internal_WE_time) ;
  end
end

endmodule


