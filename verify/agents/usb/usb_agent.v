
`timescale 1 ns/ 1 ns
module usb_agent (
        dpls,
        dmns
       );

inout         dpls, dmns;
wire  [24:0] ControlPkt;



    assign dpls = 1'bz;
    assign dmns = 1'bz;

    pullup(dpls);
    pulldown(dmns);


    // ------------------------------
    // Module Instantiations.---------------
    // ------------------------------


    // a. Host Bus Model Instantiation.

    host_usb_bfm bfm_inst( .DPLS( dpls ),
                      .DMNS( dmns ),
                      .ControlPkt( ControlPkt)
                    );





endmodule

module host_usb_bfm( 
                DPLS, 
                DMNS,
                ControlPkt
              );

inout       DPLS;
inout       DMNS;
output [24:0] ControlPkt;
    
wire        DPLS;
wire        DMNS;

reg         zDPLS;              // this register is driven in host_usb_drvr.v
reg         zDMNS;              // this register is driven in host_usb_drvr.v
 
wire        clk;                // clock

// encoder signals
reg         enc_enbl;           // signal to enable encoder block
reg         enc_reset_n;        // signal to reset encoder block
reg [7:0]   enc_data_in;        // byte wide data being pumped into the encoder
wire        enc_count_out;      // wire for encoder count_out signal
wire        enc_data_out_valid; // wire for encoder data_out_valid signal
reg         enc_last_byte;
wire [3:0]  enc_bit_count_out;

// decoder signals
reg         dec_enbl;           // signal to enable decoder block
reg         dec_reset_n;        // signal to reset decoder block
wire        dec_ser_data_rdy;   // signal to indicate serial data is ready
wire        dec_par_data_rdy;   // signal to indicate parallel data is ready
wire [7:0]  dec_par_data_out;   // parallel data out from decoder
wire [31:0] dec_recv_bit_count; // gives the number of bits received so far
wire        dec_bit_stuff_err;  // goes high if there is a bit stuff error in
                                // the present data stream
// dpll signals
reg         clk48;
reg         clk6;
reg         dpll_reset_n;
wire        dpll_clk;
reg         rec_clk;
wire        clk4x;

// Jitter control registers

integer     tmpJitterPeriod;
integer     tmpJitterCount;

// clock related registers
reg         HSClkComp;  // compensation when generating the 4x clock
reg         HSClkCompToggle;

////////////////////////////////////////////////
//                                            //
//  Added to accomodate 1 ms slots and files  //
//                                            //
////////////////////////////////////////////////

// reg [24:0]  ControlPkt;

// Control Packet format;

//   [0]    :  1 - Assert BufOk/0 - Donot assert BufOk.
//   [1]    :  1 - Create BufOk Error/0 - Donot Create BufOk Error.
//   [9:2]  :  Start Byte for In Transfers.
//   [10]   :  1 - Create a 4 Clock Protocol violation/0 - donot create vio.
//   [20:11]:  Errors after num transfers.
//   [21]   :  Stalled or Not.
//   [22]   :  Check for data on Application Bus during Writes.
//   [23]   :  Check for the Hshk on the Application Bus.
//   [24]   :  If check for hshkis true, 1'b1 = XfrAck, 1'b0 = XfrNack.

// integer   ByteCount;
// integer   Status ;

reg [6:0] dutAddr;
reg       sofOnFlag ;
integer   sofPeriod ;
reg       interruptOnFlag ;
reg       interruptRequest ;
integer   interruptTimer ;
integer   interruptPeriod ;
reg       controlRequest ;
reg       controlGrant ;
reg       bulkInOnFlag ;
reg       bulkOutOnFlag ;

parameter DumpToFile = 1;

parameter IN_OUT_BUF_SIZE     = 2048,    // outgoing buffer data size
          IN_OUT_BUF_PTR_SIZE = 12,      // number of bits in out buff pointer

          XMIT_BUF_SIZE       = 1028,    // Xmitbuffer size
          RECV_BUF_SIZE       = 1028;    // Recvbuffer size
 
parameter OUT_TOKEN           = 4'b0001,
          IN_TOKEN            = 4'b1001,
          SOF_TOKEN           = 4'b0101,
          SETUP_TOKEN         = 4'b1101,
          DATA0               = 4'b0011,
          DATA1               = 4'b1011,
          ACK                 = 4'b0010,
          NAK                 = 4'b1010,
          STALL               = 4'b1110,
          PREAMBLE            = 4'b1100;

parameter GET_CONFIGURATION   = 01,  // Standard Request Codes for end points
          GET_DESCRIPTOR      = 02,
          GET_INTERFACE       = 03,
          GET_MAX_PACKET      = 04,
          GET_STATUS          = 05,
          SET_ADDRESS         = 06,
          SET_CONFIGURATION   = 07,
          SET_DESCRIPTOR      = 08,
          SET_IDLE            = 09,
          SET_INTERFACE       = 10,
          SET_MAX_PACKET      = 11,
          SET_REMOTE_WAKEUP   = 12,
          SET_STATUS          = 13;

parameter DEVICE              = 1, // Descriptor Types
          CONFIGURATION       = 2,
          STRING              = 3,
          INTERFACE           = 4,
          ENDPOINT            = 5;

parameter GET_HUB_STATUS      = 0, // Hub class request codes
          GET_PORT_STATUS     = 0,
          CLEAR_FEATURE       = 1,
          GET_STATE           = 2,
          SET_FEATURE         = 3,
          // reserved for future use 4-5
          GET_HUB_DESCRIPTOR  = 6,
          SET_HUB_DESCRIPTOR  = 7;

parameter C_HUB_LOCAL_POWER   = 00, // Hub class feature selectors
          C_HUB_OVER_CURRENT  = 01,
          PORT_CONNECTION     = 00,
          PORT_ENABLE         = 01,
          PORT_SUSPEND        = 02,
          PORT_OVER_CURRENT   = 03,
          PORT_RESET          = 04,
          PORT_POWER          = 08,
          PORT_LOW_SPEED      = 09,
          C_PORT_CONNECTION   = 16,
          C_PORT_ENABLE       = 17,
          C_PORT_SUSPEND      = 18,
          C_PORT_OVER_CURRENT = 19,
          C_PORT_RESET        = 20;

parameter true                = 1'b1,
          True                = 1'b1,
          TRUE                = 1'b1,
          false               = 1'b0,
          False               = 1'b0,
          FALSE               = 1'b0;

parameter HIGH_SPEED          = 1'b1,
          LOW_SPEED           = 1'b0;

parameter J                   = 2'b10, // high speed idle state {DPLS, DMNS}
          K                   = 2'b01, // low speed idle state  {DPLS, DMNS}
          SE0                 = 2'b00, // single ended zero     {DPLS, DMNS}
          SE1                 = 2'b11; // single ended 1        {DPLS, DMNS}

parameter MAX_CNTRL_INTERLEAVE= 6;  // number of control transactions that can
                                    // interleaved

parameter NUM_ENDPT_FILES     = 12; // number of transmit files associtated
                                    // with endpoints

parameter READ                = 2'b10;
parameter WRITE               = 2'b11;

parameter BINARY              = 1'b0;
parameter HEX                 = 1'b1;

parameter XMIT_BUF            = 4'b0000;
parameter OUT_BUFF            = 4'b0001;

parameter NumCharsInFileName  = 20; // number of characters in a file name
parameter CharByte            = 8;  // number of bits for a character
parameter MaxFileSize         = 9 * 1024; // 9k file size

reg [7:0]   in_out_buf            [0 : IN_OUT_BUF_SIZE - 1];
reg [11:0]  in_out_buf_ptr;

reg [7:0]   XmitBuffer        [0 : XMIT_BUF_SIZE]; // Xmit buffer
reg [7:0]   RecvBuffer        [0 : RECV_BUF_SIZE]; // Recv buffer

reg [10:0]  FrameNumber;   // frame number

reg [15:0]  InDataToggle       [127:0]; // set\unset Data0/Data1 for data Xfers
reg [15:0]  OutDataToggle      [127:0]; // set\unset Data0/Data1 for data Xfers

reg         TimeOut;        // register to specify timeout
integer     TimeOutVal;     // value to specify for how many bit times
                            // to wait for before time out

reg [31:0]  ResponseLatency; // turnaround time for the host before
                             // responding
reg         IsoHeadGen;     // specifies if a header is generated for an 
                            // isochronous transfer or not

reg         GenCrc16Err;   // specifies if a crc error is to be generated or not
reg [15:0]  Crc16ErrMask;  // a particular crc bit is inverted according to the
                           // bit in the Mask is high

reg         GenCrc5Err;    // specifies if a crc error is to be generated or not
reg [4:0]   Crc5ErrMask;   // a particular crc bit is inverted according to the
                           // bit in the Mask is high

reg         ReportResults;  // reports results to a file
reg [NumCharsInFileName * CharByte : 1] ResultsFile;    // reports file name 
integer     ResultsFp;      // filepointer for reults file

reg         ReportErrors;

integer     PulseWidth;     // PulseWidth of USB clock

reg         SyncField;      // specifies if a correct/incorrect sync field is to
                            // be sent
reg [31:0]  SyncLevel;      // at which point in a task to corrupt the SyncField
reg [31:0]  SetSyncLevel;   // set this value before calling SendData
reg [7:0]   SyncFieldMask;  // specifies how the sync field is to be corrupted

reg         GenSE0Error;    // generate a SE0 error
reg [31:0]  SE0BitTimes;    // generate SE0 for this many bit times
reg [31:0]  SE0ErrorLevel;  // = 0 : generates a SE0 error after a sync field
                            // = 1 : generates a SE0 error after data
                            // = 2 : generates a SE0 error after a handshake


reg         HshkPidIntegrity; // specifies if correct ACKs should be sent
reg [7:0]   HshkPidIntegrityMask; // Mask according to which ACK's are corrupted

reg         BitStuffErr;

integer     RespTimeOutVal; // bit times to wait for when no response is to be
                            // sent

integer     tmpCounter;   // a scratch variable to be used any where

event       DoesNotOccur; // an event which will not be triggered to
                          // used to suspend threads

reg  [31:0]  StartTime;    // start time of a transaction
reg  [31:0]  StopTime;     // stop time of a transaction
reg  [31:0]  SE0StartTime; // start time of a single ended 0
reg  [31:0]  SE0StopTime;  // stop of a single ended 0

reg  [31:0]  SelfName;     // 4 byte wide register to differentiate between
                           // instantiations


// info about a current control transaction

reg  [1:0]   CntrlTransType  [1 : MAX_CNTRL_INTERLEAVE];
                               // type of control transaction
                               // 00 no control transaction in progress
                               // 01 control_rd transaction in progress
                               // 11 control_wr transaction in progress
reg  [6:0]   CntrlTransAddr  [1 : MAX_CNTRL_INTERLEAVE];
                               // address to which a cntrl trans is in progress
reg  [3:0]   CntrlTransEndP  [1 : MAX_CNTRL_INTERLEAVE];
                               // End Pnt to which a cntrl trans is in progress
reg  [15:0]  CntrlTransDlen  [1 : MAX_CNTRL_INTERLEAVE];
                               // data length for this control transaction


reg  [NumCharsInFileName * CharByte : 1] SendDataFileName;
     // File from which data to be sent is taken from, format is 1 byte per line
     // in hex format

reg  [NumCharsInFileName * CharByte : 1] RecvDataFileName;
     // File to which received data is logged to, format is 1 byte per line in
     // hex format

reg  [NumCharsInFileName * CharByte : 1] ErrorFileName;
     // file name to report errors

reg  [31:0]  RecvDataFp;   // file pointer to RecvDataFileName

reg  [31:0]  SendDataOfst; // offset into SendDataFileName

reg  [31:0]  ErrorFileFp;    // file pointer of the error file


reg  [NumCharsInFileName * CharByte : 1]  EndPtFileName [1 : NUM_ENDPT_FILES];
     // array to store file names associated with end points
reg  [1:0]                                EndPtFileMode [1 : NUM_ENDPT_FILES];
     // array to store read/write mode info for each file
reg  [31:0]                               EndPtFp [1 : NUM_ENDPT_FILES];
reg  [10:0]                               EndPtFileInfo [1 : NUM_ENDPT_FILES];
reg  [31:0]                               EndPtFileOfst [1 : NUM_ENDPT_FILES];
     // offset into the file if it is in write mode


reg          Debug;   // debugging messages are turned on if set to true


reg          GenDataPidErr;  // generates a data pid integrity error
reg  [7:0]   DataPidErrMask; // error mask for generating
reg          GenTokenErr;    // generates a token pid integrity error
reg  [7:0]   TokenErrMask;   // token error mask

reg          DeviceSpeed;    // low speed or high speed

reg          GenByteBoundary; // generate a byte boundary error

reg          SendPreamble;

// registers to log simulation results

reg  [31:0]  NumBulkInTrans;      // number of bulk in transactions
reg  [31:0]  NumSucBulkInTrans;   // number of successful bulk in transctions
reg  [31:0]  NumBulkOutTrans;     // number of bulk out transactions
reg  [31:0]  NumSucBulkOutTrans;  // number of successful bulk out transactions
reg  [31:0]  NumIsoInTrans;       // number of iso in transactions
reg  [31:0]  NumSucIsoInTrans;    // number of successful iso in transactions
reg  [31:0]  NumIsoOutTrans;      // number of iso out transactions
reg  [31:0]  NumSOF;              // number of SOF's sent
reg  [31:0]  NumCntrlRdTrans;     // number of control reads
reg  [31:0]  NumSucCntrlRdTrans;  // number of successful control reads
reg  [31:0]  NumCntrlWrTrans;     // number of control writes
reg  [31:0]  NumSucCntrlWrTrans;  // number of successful control writes
reg  [31:0]  NumIntrptTrans;      // number of interrupt transactions
reg  [31:0]  NumSucIntrptTrans;   // number of successful interrupt transactions
reg  [31:0]  NumIntrOutTrans;     // number of interrupt out transactions
reg  [31:0]  NumSucIntrOutTrans;  // number of successful interrupt out transactions
reg  [31:0]  NumResets;           // number of resets


// registers to store jitter information

integer HighJitterTime;     // time by which high time pulse width is modified
integer LowJitterTime;      // time by which low time pulse width is modified
integer JitterPeriod;       // specifies in pulse numbers when the Jitter is
                            // to be repeated
integer JitterCount;        // number of pulses for which jitter is induced
reg     JitterOnOff;        // specifies if jitter is being induced or not

reg     task_in_progress;

                            // SOF's
reg     hs_clk;             // high speed clock
reg     ls_clk;             // low-speed clock
reg     clk_swtch;          // clock switch


reg [31:0]  SetupDataLen;

reg     GenByteBoundaryPos;
reg     BoundaryBitVal;

integer     ModifyGran;



task DispErrMsg;

input [6:0] address;
input [3:0] EndPt;
input [31:0] ErrMsgNo;

begin
    if (ReportErrors == FALSE) disable DispErrMsg;
    if ((ErrorFileFp == 0) & (ErrorFileName == "")) begin
        $display("No file name specified to log errors.");
        disable DispErrMsg;
    end
    if (ErrorFileFp == 0) ErrorFileFp = $fopen(ErrorFileName);
    if ((ErrMsgNo >= 0) & (ErrMsgNo <= 32)) $fwrite(ErrorFileFp, "Error %0d :", (500 + ErrMsgNo));
    case (ErrMsgNo)
    0: $fdisplay(ErrorFileFp, "Time out for bulk in transfer at address %h for End Point %h at time %0t", address, EndPt, $time);
    1: $fdisplay(ErrorFileFp, "Time out for iso in transfer at address %h for End Point %h at time %0t", address, EndPt, $time);
    2: $fdisplay(ErrorFileFp, "Time out for interrupt transfer at address %h for End Point %h at time %0t", address, EndPt, $time);
    3: $fdisplay(ErrorFileFp, "Time out for control transfer at address %h for End Point %h at time %0t", address, EndPt, $time); //this EndPt value should be zero
    4: $fdisplay(ErrorFileFp, "Time out for bulk out transfer at address %h for End Point %h at time %0t", address, EndPt, $time);
    5: $fdisplay(ErrorFileFp, "Pid error at address %h for End Point %h at time %0t", address, EndPt, $time);
    6: $fdisplay(ErrorFileFp, "Short packet at address %h for End Point %h at time %0t", address, EndPt, $time);
    7: $fdisplay(ErrorFileFp, "CRC error for token packet at address %h for End Point %h at time %0t", address, EndPt, $time);
    8: $fdisplay(ErrorFileFp, "CRC error for data at address %h for End Point %h at time %0t", address, EndPt, $time);
    9: $fdisplay(ErrorFileFp, "Incorrect token received at address %h for End Point %h at time %0t", address, EndPt, $time);
    10: $fdisplay(ErrorFileFp, "Incorrect Data0/Data1 toggle received at address %h for End Point %h at time %0t", address, EndPt, $time);
    11: $fdisplay(ErrorFileFp, "NAK recevied at address %h for End Point %h at time %0t", address, EndPt, $time);
    12: $fdisplay(ErrorFileFp, "STALL received at address %h for End Point %h at time %0t", address, EndPt, $time);
    13: $fdisplay(ErrorFileFp, "Incorrect handshake received at address %h for End Point %h at time %0t", address, EndPt, $time);
    14: $fdisplay(ErrorFileFp, "Long packet at address %h for End Point %h at time %0t", address, EndPt, $time);
    15: $fdisplay(ErrorFileFp, "Corrupted handshake received at address %h for End Point %h at time %0t", address, EndPt, $time);
    16: $fdisplay(ErrorFileFp, "Device error at address %h for End Point %h at time %0t", address, EndPt, $time);
    17: $fdisplay(ErrorFileFp, "Invalid wIndex value for control transfer to address %h at time %0t", address, $time);
    18: $fdisplay(ErrorFileFp, "Invalid RequestType for control transfer to address %h at time %0t", address, $time);
    19: $fdisplay(ErrorFileFp, "Invalid wValue value for control transfer to address %h at time %0t", address, $time);
    20: $fdisplay(ErrorFileFp, "Invalid data length during data phase for control transfer to address %0h and End Point %0h at time %0t", address, EndPt, $time);
    21: $fdisplay(ErrorFileFp, "No setup transaction in progress to do a control_in or a control_out or a status transaction at time %0t", $time);
    22: $fdisplay(ErrorFileFp, "Doing a control_in when a control_out is expected and vice-versa at time %0t", $time);
    23: $fdisplay(ErrorFileFp, "Doing a control_in or control_out when the number of bytes specified by wLength have been received or sent at time %0t", $time);
    24: $fdisplay(ErrorFileFp, "Doing a status_in when a status_out is expected and vice-versa at time %0t", $time);
    25: $fdisplay(ErrorFileFp, "Received a DATA0 token during the status phase of a control transaction at address %0h, EndPt %0h, at time %0t", address, EndPt, $time);
    26: $fdisplay(ErrorFileFp, "Incorrect sync field at time %0t", $time);
    27: $fdisplay(ErrorFileFp, "Bit Stuffing error at time %0t", $time);
    28: $fdisplay(ErrorFileFp, "Eop incorrect at time %0t", $time);
    29: $fdisplay(ErrorFileFp, "Null File Name passed to command at time %0t", $time);
    30: $fdisplay(ErrorFileFp, "Offset into file greater than size of file at time %0t", $time);
    31: $fdisplay(ErrorFileFp, "Command not supported by a low speed device issued at time %0t.", $time);
    32: $fdisplay(ErrorFileFp, "Command not supported by command line interface issued at time %0t.", $time);
endcase
end
endtask

//bit 0 has the IN DataToggle and bit 1 has the OUT DataToggle
function [1:0] CheckDataToggle;
input [6:0]  address;
input [3:0]  EndPt;

reg   [15:0] tmpReg1;
reg   [15:0] tmpReg2;

begin
    tmpReg1 = InDataToggle[address];
    tmpReg2 = OutDataToggle[address];
    if ((EndPt < 16) & (EndPt >= 0)) begin
        CheckDataToggle[0] = tmpReg1[EndPt];
        CheckDataToggle[1] = tmpReg2[EndPt];
    end
    else CheckDataToggle = 0;  // default
end
endfunction

function CheckDataToggleIN;
input [6:0]  address;
input [3:0]  EndPt;

reg   [15:0] tmpReg;

begin
    tmpReg = InDataToggle[address];
    if ((EndPt < 16) & (EndPt >= 0)) CheckDataToggleIN = tmpReg[EndPt];
    else CheckDataToggleIN = 0;  // default
end
endfunction

function CheckDataToggleOUT;
input [6:0]  address;
input [3:0]  EndPt;

reg   [15:0] tmpReg;

begin
    tmpReg = OutDataToggle[address];
    if ((EndPt < 16) & (EndPt >= 0)) CheckDataToggleOUT = tmpReg[EndPt];
    else CheckDataToggleOUT = 0;  // default
end
endfunction

task SetDataToggle;
input [6:0]  address;
input [3:0]  EndPt;
input [1:0]  SetVal; //value to which the toggle value should be changed to
                     // index 0 has the IN value and index 1 has the OUT value
reg   [15:0] tmpReg;
begin
    tmpReg = InDataToggle[address];
    if ((SetVal[0] == 0) | (SetVal[0] == 1)) tmpReg[EndPt] = SetVal;
    else tmpReg[EndPt] = 0; // default
    InDataToggle[address] = tmpReg;
    tmpReg = OutDataToggle[address];
    if ((SetVal[1] == 0) | (SetVal[1] == 1)) tmpReg[EndPt] = SetVal;
    else tmpReg[EndPt] = 0; // default
    OutDataToggle[address] = tmpReg;
end
endtask

task SetDataToggleIN;
input [6:0]  address;
input [3:0]  EndPt;
input SetVal; //value to which the toggle value should be changed to
reg   [15:0] tmpReg;
begin
    tmpReg = InDataToggle[address];
    if ((SetVal == 0) | (SetVal == 1)) tmpReg[EndPt] = SetVal;
    else tmpReg[EndPt] = 0; // default
    InDataToggle[address] = tmpReg;
end
endtask

task SetDataToggleOUT;
input [6:0]  address;
input [3:0]  EndPt;
input SetVal; //value to which the toggle value should be changed to
reg   [15:0] tmpReg;
begin
    tmpReg = OutDataToggle[address];
    if ((SetVal == 0) | (SetVal == 1)) tmpReg[EndPt] = SetVal;
    else tmpReg[EndPt] = 0; // default
    OutDataToggle[address] = tmpReg;
end
endtask

function [7:0] CorruptHshk;
input  [7:0] funHshk;
reg    [7:0] tmpReg;
reg    [4:0] i;
begin
tmpReg = funHshk;
if (HshkPidIntegrity == TRUE) begin
    for (i = 0; i < 8; i = i + 1) begin
        if (HshkPidIntegrityMask[i] == 1'b1) tmpReg[i] = ~tmpReg[i];
    end
end
CorruptHshk = tmpReg;
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
//  swap2 : swaps around the bits in half a nibble
//
////////////////////////////////////////////////////////////////////////////////
function [1:0] swap2;
input    [1:0] SwapBits;
begin
swap2 = {SwapBits[0], SwapBits[1]};
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
//  swap8 : swaps around the bits in a byte and returns the swapped byte
//
////////////////////////////////////////////////////////////////////////////////
function [7:0] swap8;
input    [7:0] SwapByte;
begin
swap8 = {SwapByte[0], SwapByte[1], SwapByte[2], SwapByte[3], SwapByte[4], SwapByte[5], SwapByte[6], SwapByte[7]};
end
endfunction

////////////////////////////////////////////////////////////////////////////////
//
//  DumpData : dumps the data received into in_out_buf to a file
//  Inputs   : address   : device address to which data is dumped to the 
//                         associated file, 7 bits
//             EndPt     : End Point number, 4 bits
//             ByteCount : number of bytes to dump from in_out_buf to the file
//
////////////////////////////////////////////////////////////////////////////////
task DumpData;

input   [6:0]  address;
input   [3:0]  EndPt;
input   [3:0]  DataToggle;
input   [31:0] ByteCount;

integer        i;
integer        j;

reg     [39:0] DataToggleString;
reg            Match;

begin
DataToggleString = (DataToggle == DATA0) ? "DATA0" : "DATA1" ;
Match = FALSE;
for (i = 1; i <= NUM_ENDPT_FILES; i = i + 1) begin
   if (EndPtFileInfo[i] == {EndPt, address}) begin
       if ((EndPtFp[i] > 0) & (EndPtFileMode[i] == WRITE)) begin
           $fdisplay (EndPtFp[i], "//address = %b, EndPt = %b, Data Toggle = %0s at time = %0t", address, EndPt, DataToggleString, $time);
           //for (j = 1; j <= ByteCount; j = j + 1) $fwrite (EndPtFp[i], "%h, ", in_out_buf [j]);
           for (j = 1; j <= ByteCount; j = j + 1) $fdisplay (EndPtFp[i], "%h", in_out_buf[j]);
           $fdisplay(EndPtFp[i], "\n");
           Match = TRUE;
       end
       i = NUM_ENDPT_FILES + 1;
   end
end

if (Match == FALSE) begin // no file name associated with this address
                          // dump data into the common bucket(file)
    if (RecvDataFp == 0) RecvDataFp = $fopen(RecvDataFileName);
    $fdisplay (RecvDataFp, "//address = %b, EndPt = %b, Data Toggle = %0s at time = %0t", address, EndPt, DataToggleString, $time);
    //for (j = 1; j <= ByteCount; j = j + 1) $fwrite (RecvDataFp, "%h, ", in_out_buf[j]);
    for (j = 1; j <= ByteCount; j = j + 1) $fdisplay (RecvDataFp, "%h", in_out_buf[j]);
    $fdisplay(RecvDataFp, "\n");
end

end
endtask



function [7:0] CorruptDataPid;
input [7:0]    funDataPid;
integer        i;
reg   [7:0]    tmpReg;
begin
tmpReg = funDataPid;
if (GenDataPidErr == TRUE) begin
    for ( i = 0; i < 8; i = i + 1) begin
        if (DataPidErrMask[i] == 1'b1) tmpReg[i] = ~tmpReg[i];
    end
end
CorruptDataPid = tmpReg;
end
endfunction


function [7:0] CorruptToken;
input [7:0]    funToken;
integer        i;
reg   [7:0]    tmpReg;
begin
tmpReg = funToken;
if (GenTokenErr == TRUE) begin
    for ( i = 0; i < 8; i = i + 1) begin
        if (TokenErrMask[i] == 1'b1) tmpReg[i] = ~tmpReg[i];
    end
end
CorruptToken = tmpReg;
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
//   WriteResults : writes out the results to the file pointed to by ResultsFp
//
////////////////////////////////////////////////////////////////////////////////
task WriteResults;

begin

if (ResultsFile == "") disable WriteResults;

if (ResultsFp != 0) $fclose(ResultsFp);

ResultsFp = $fopen(ResultsFile);

$fdisplay(ResultsFp, "\n");
$fdisplay(ResultsFp, "--------------------------------------------------------------------------------");
$fdisplay(ResultsFp, "-------------------- Transfer Statistics for the HOST model --------------------");
$fdisplay(ResultsFp, "--------------------------------------------------------------------------------");
$fdisplay(ResultsFp, "\n");


$fdisplay(ResultsFp,
                 "     Simulation Start Time ------------------------------ : 0",);
$fdisplay(ResultsFp,
                 "     Number of Bulk In transactions --------------------- : %0d",
                 NumBulkInTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Bulk In transactions ---------- : %0d",
                 NumSucBulkInTrans);
$fdisplay(ResultsFp,
                 "     Number of Bulk Out transactions -------------------- : %0d",
                 NumBulkOutTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Bulk Out transactions --------- : %0d",
                 NumSucBulkOutTrans);
$fdisplay(ResultsFp,
                 "     Number of Iso In transactions ---------------------- : %0d",
                 NumIsoInTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Iso In transactions ----------- : %0d",
                 NumSucIsoInTrans);
$fdisplay(ResultsFp,
                 "     Number of Iso Out transactions --------------------- : %0d",
                 NumIsoOutTrans);
$fdisplay(ResultsFp,
                 "     Number of Interrupt transactions ------------------- : %0d",
                 NumIntrptTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Interrupt transactions -------- : %0d",
                 NumSucIntrptTrans);
$fdisplay(ResultsFp,
                 "     Number of resets ----------------------------------- : %0d",
                 NumResets);
$fdisplay(ResultsFp,
                 "     Number of SOF's sent ------------------------------- : %0d",
                 NumSOF);
$fdisplay(ResultsFp,
                 "     Number of Control Read transactions ---------------- : %0d",
                 NumCntrlRdTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Control Read transactions ----- : %0d",
                 NumSucCntrlRdTrans);
$fdisplay(ResultsFp,
                 "     Number of Control Write transactions --------------- : %0d",
                 NumCntrlWrTrans);
$fdisplay(ResultsFp,
                 "     Number of Successful Control Write transactions ---- : %0d",
                 NumSucCntrlWrTrans);
$fdisplay(ResultsFp,
                 "     Simulation End Time -------------------------------- : %0t",
                 $time);
$fdisplay(ResultsFp, "\n");

end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  CorruptCrc16 : Corrupts the crc16 value passed on to it according to the
//                 present crc16 error generation status
//
////////////////////////////////////////////////////////////////////////////////
function [15:0] CorruptCrc16;
input    [15:0] funCrc16;
reg      [5:0]  i;
begin
if (GenCrc16Err == TRUE) begin
    for (i = 0; i < 16; i = i + 1) begin
        if (Crc16ErrMask[i] == 1'b1) funCrc16[i] = ~funCrc16[i];
    end
end
CorruptCrc16 = funCrc16;
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
//  CorruptCrc5 : Corrupts the crc5 value passed on to it according to the
//                present crc5 error generation status
//
////////////////////////////////////////////////////////////////////////////////
function [4:0] CorruptCrc5;
input    [4:0] funCrc5;
reg      [5:0] i;
begin
if (GenCrc5Err == TRUE) begin
    for (i = 0; i < 5; i = i + 1) begin
        if (Crc5ErrMask[i] == 1'b1) funCrc5[i] = ~funCrc5[i];
    end
end
CorruptCrc5 = funCrc5;
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
//  modify_device_speed : modifies the device speed
//
////////////////////////////////////////////////////////////////////////////////
task modify_device_speed;
input tskDeviceSpeed;
begin
DeviceSpeed = (tskDeviceSpeed == LOW_SPEED) ? LOW_SPEED:HIGH_SPEED;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
// CorruptSyncField : corrupts the sync field according to SyncFieldMask
//
////////////////////////////////////////////////////////////////////////////////
function [7:0] CorruptSyncField;
input [7:0] funSyncField;
reg   [7:0] tmpReg;
reg   [4:0] i;
begin
tmpReg = funSyncField;
if ((SyncField == TRUE) & (SyncLevel == SetSyncLevel)) begin
    for (i = 0; i < 8; i = i + 1) begin
        if (SyncFieldMask[i] == 1'b1) tmpReg[i] = ~tmpReg[i];
    end
end
CorruptSyncField = tmpReg;
end
endfunction


////////////////////////////////////////////////////////////////////////////////
//
// SendData : serialises and puts out the data in in_out_buf onto DPLS(D+)
//            and DMNS(D-)
//
////////////////////////////////////////////////////////////////////////////////
task SendData;
integer        i;
reg     [31:0] SE0Counter; // Single Ended Zero Counter
reg     [31:0] SE0Terminate;
event          SE0Event;
begin
i = 0;
SE0Counter = 2'b00;
if (in_out_buf_ptr > 0) begin
    @(posedge clk);
    @(posedge clk) begin // synchronise to positive edge of clock
        enc_enbl = 1'b1; // active high
        enc_reset_n = 1'b1; // active low
        enc_last_byte = 1'b0;
        enc_data_in = CorruptSyncField(8'h80);
    end
    fork
        forever @(posedge clk) begin
            if (GenByteBoundary == TRUE) begin
                if ((i == in_out_buf_ptr) & (enc_bit_count_out == 6)) begin
                    enc_enbl = 1'b0;
                    enc_reset_n = 1'b0;
                    in_out_buf_ptr = 0;
                    -> SE0Event;
                end
            end
        end

        forever @(posedge clk) begin
           if (GenByteBoundaryPos == TRUE) begin
              in_out_buf[in_out_buf_ptr + 1] = {BoundaryBitVal, BoundaryBitVal, BoundaryBitVal, BoundaryBitVal, BoundaryBitVal, BoundaryBitVal, BoundaryBitVal, BoundaryBitVal};
              if ((i == (in_out_buf_ptr + 1)) & (enc_bit_count_out == 0)) begin
                 enc_enbl = 1'b0;
                 enc_reset_n = 1'b0;
                 in_out_buf_ptr = 0;
                 -> SE0Event;
              end
           end
        end

        forever @(negedge enc_count_out) begin
            if ((i == in_out_buf_ptr) & (GenByteBoundaryPos == FALSE)) begin
                //@(posedge clk);
                enc_enbl = 1'b0; // active high
                enc_reset_n = 1'b0; // active low
                in_out_buf_ptr = 0; // reset output buffer pointer
                -> SE0Event;
            end
            else begin
                enc_data_in = in_out_buf[i];
                if (i == in_out_buf_ptr - 1) enc_last_byte = 1'b1;
                else enc_last_byte = 1'b0;
                //if (Debug) $display("in_out_buf[%h] = %h at time %0t",i, in_out_buf[i], $time);
                i = i + 1;
            end
        end

        forever @(SE0Event) begin // drive a SE0 for 2 bit times
            SE0Terminate = ((GenSE0Error == TRUE) & (SE0ErrorLevel == SetSyncLevel)) ? (SE0BitTimes) : 2;
            if (ModifyGran < -8) ModifyGran = -8;
            // SE0Terminate = (SE0Terminate * 4) + ModifyGran;
            // @(posedge clk);
            // forever @(posedge clk4x) begin
            forever @(posedge clk) begin
                if (SE0Counter >= SE0Terminate) begin
                    zDPLS = #1 1'bZ;
                    zDMNS =  1'bZ;
                    @(posedge clk); // wait for one idle state after pulls
                    disable SendData;
                end
                if (i >= in_out_buf_ptr) begin
                    zDPLS = #1 1'b0;
                    zDMNS =  1'b0;
                    SE0Counter = SE0Counter + 1;
                end
            end
        end
    join
end

end
endtask

////////////////////////////////////////////////////////////////////////////////
//
// WaitForResp : collects the data from DPLS(D+) and DMNS(D-) and fills in_out_buf
//
////////////////////////////////////////////////////////////////////////////////
task WaitForResp;

output  [31:0]  recv_bit_count;

reg     [31:0]  recv_bit_count;
integer         EopDetect;
reg     [4:0]   ClkCount;
reg     [3:0]   DplsCount;
reg             FltrSyncFld;
integer         tmpTimeOutCounter;
reg             tmpTimeOut;
reg             OnlyOnce;
reg             SyncDetect;
time            SyncPulseT1;
time            SyncPulseT2;
time            SyncPulseDuration;

begin
if (Debug) $display("In %0s --> In task wait for response at time %0t", SelfName, $time);
EopDetect         = 0;
in_out_buf_ptr    = 0;
DplsCount         = 0;
ClkCount          = 0;
FltrSyncFld       = 1'b1;
tmpTimeOutCounter = 0;
tmpTimeOut        = TRUE;
recv_bit_count    = 0;
OnlyOnce          = TRUE;
SyncDetect        = FALSE;

// dec_enbl = 1'b1;              // active high
// dec_reset_n = 1'b1;           // active low
begin : TimeOutBlock
    forever @(posedge dpll_clk) begin
    //if (Debug) $display("In %0s --> waiting for event in WaitForResp %0t", SelfName, $time);
        if (TimeOut == TRUE) begin
            if (tmpTimeOutCounter == TimeOutVal) begin
                if (Debug) $display("In %0s --> Time out at time %0t", SelfName, $time);
                disable WaitForResp;
            end
            tmpTimeOutCounter = tmpTimeOutCounter + 1;
        end
        //if (Debug) $display("In %0s --> DeviceSpeed = %b at time %0t", SelfName, DeviceSpeed, $time);
        //if (DPLS === 1'b0) begin
        if (DPLS === ~DeviceSpeed) begin
           if (Debug) $display("In %0s --> DPLS = %b , DeviceSpeed = %b at time %0t", SelfName, DPLS, DeviceSpeed, $time);
           if (DMNS === DeviceSpeed) begin   // differential data

               @DPLS
               StartTime = $time;
               SyncPulseT1 = $time;
               @DPLS
               SyncPulseT2 = $time;
               @DPLS
               SyncPulseDuration = SyncPulseT2 - SyncPulseT1;
               @DPLS
               SyncPulseT1 = $time;
               @DPLS
               SyncPulseT2 = $time;
               @DPLS
               #SyncPulseDuration
               #SyncPulseDuration
               #SyncPulseDuration

               dec_enbl = 1'b1;              // active high
               dec_reset_n = 1'b1;           // active low
               // StartTime = $time;   this time should be start of syncpulse
               disable TimeOutBlock;
           end
           else if ((DMNS === 1'b0) & (DPLS === 1'b0)) begin
               EopDetect = 1;
               disable TimeOutBlock;
           end
        end
    end
end // TimeOutBlock
 
if (Debug) $display("In %0s --> Decoder enabled at time %0t in host", SelfName, $time);
fork
    begin : DataSink
    forever @(posedge dec_par_data_rdy) begin
        if (FltrSyncFld == 1'b1) begin  // filter out the sync field
            in_out_buf[in_out_buf_ptr] = dec_par_data_out;
            in_out_buf_ptr = in_out_buf_ptr + 1;
        end
        if (dec_par_data_out == {~PREAMBLE, PREAMBLE} &
            in_out_buf_ptr == 1) begin
            dec_enbl = 1'b0;
            dec_reset_n = 1'b0;
            StopTime = $time;
            disable WaitForResp;
        end
        if (Debug) $display("In %0s --> receive data = %h", SelfName, dec_par_data_out);
        if (FltrSyncFld == 1'b0) begin
/*
            if (dec_par_data_out != 8'h80) begin
                if (Debug) $display("In %0s --> Incorrect sync field %0h received at time %0t, ...discarding packet", SelfName, dec_par_data_out, $time);
                in_out_buf_ptr = 0; // equivalent to a time out
                dec_enbl = 1'b0;
                dec_reset_n = 1'b0;
                wait(1==0); // wait while the other block detects a EOP and disables task
            end
*/
        end
        FltrSyncFld = 1'b1;
    end
    end
    
    forever @(posedge dpll_clk) begin
        if (dec_bit_stuff_err == 1'b1) begin
            if (OnlyOnce == TRUE) begin
                DispErrMsg(0, 0, 27);
                OnlyOnce = FALSE;
                in_out_buf_ptr = 0;  // reset data pointer
            end
            disable DataSink;
        end
        if((DPLS == DMNS) & (DPLS == 1'b0)) begin
            EopDetect = EopDetect + 1;
            recv_bit_count = dec_recv_bit_count - 1;
            if (StopTime == 0) StopTime = $time;
            if (SE0StartTime == 0) SE0StartTime = $time;
            if (Debug) $display("In %0s --> StopTime = %0d, SE0StartTime = %0d", SelfName, StopTime, SE0StartTime);
        end
        if (EopDetect == 1) begin
            if (DPLS == ~DMNS) begin // SE0 seen for only 1 bit time
                if (Debug) $display("In %0s --> EOP asserted for 1 bit time at time %0t", SelfName, $time);
                dec_enbl = 1'b0; // disable the decoder
                dec_reset_n = 1'b0; // reset the decoder
                SE0StopTime = $time;
                disable WaitForResp; // incorrect EOP was received
            end
        end
        if (EopDetect == 2) begin
            dec_enbl = 1'b0; // disable the decoder
            dec_reset_n = 1'b0; // reset the decoder
            if (DPLS == ~DMNS) begin
                if (Debug) $display("In %0s --> EOP asserted for 2 bit time at time %0t", SelfName, $time);
                dec_enbl = 1'b0; // disable the decoder
                dec_reset_n = 1'b0; // reset the decoder
                SE0StopTime = $time;
                disable WaitForResp; // correct EOP was received
            end
        end
        if ((EopDetect > 2) & (EopDetect < 32)) begin // incorrect EOP received
            if (DPLS == ~DMNS) begin
                if (Debug) $display("In %0s --> EOP asserted for %h bit times at time ", SelfName, EopDetect, $time);
                SE0StopTime = $time;
                disable WaitForResp;
            end
        end
        if (EopDetect >= 32) begin
            if (DPLS == ~DMNS) begin
                if (Debug) $display("In %0s --> Reset at time ", SelfName, $time);
                SE0StopTime = $time;
                in_out_buf_ptr = 0;
                disable WaitForResp;
            end
        end
    end
join


end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  SendReset : asserts a SE0 on the USB for the number of bit times specified
//              by ResetTime.
//  Input     : ResetTime, number of bit times for which to drive a reset on
//              the USB
//
////////////////////////////////////////////////////////////////////////////////

task SendReset;

input [7:0] ResetTime;
reg [7:0] tskResetTime;
reg [7:0] tskResetTimeCounter;

begin
    tskResetTime = ResetTime;
    //if (tskResetTime <= 32) tskResetTime = 7'b0100000;
    //if (tskResetTime >= 64) tskResetTime = 7'b1000000;
    tskResetTimeCounter = 7'b0000000;
    forever @(posedge clk) begin
        zDPLS = 1'b0;
        zDMNS = 1'b0;
        tskResetTimeCounter = tskResetTimeCounter + 1'b1;
        if (tskResetTimeCounter > tskResetTime) begin
            zDPLS = 1'bz;
            zDMNS = 1'bz;
            @(posedge clk);
            @(posedge clk);
            disable SendReset;
        end
    end
end
endtask 





parameter M16 = 16'h8005; //mask value to calculate 16 bit crc
parameter M05 = 8'h05;    //mask value to calculate 5 bit crc

function [15:0] crc16;
input    [7:0]  DataByte;
input    [15:0] PrevCrc;

reg      [15:0] TempPrevCrc;
integer         i;

begin
    TempPrevCrc = PrevCrc;
    for (i = 0; i < 8; i = i + 1)
    begin
        if (DataByte[i] ^ TempPrevCrc[15] )
            TempPrevCrc = {TempPrevCrc[14:0],1'b0} ^ M16;
        else
            TempPrevCrc = {TempPrevCrc[14:0], 1'b0};
    end
    crc16 = TempPrevCrc;
end
      
endfunction


////////////////////////////////////////////////////////////////////////////////
//function crc5 calculates a 5 bit crc
//inputs :
//         PrevCrc : 5 bit value, initially set to zero by the
//                   calling module, from the next call onwards
//                   it is the previous CRC value returned by
//                   the function.
//
//         DataByte : 8 bit value for which crc is to calculated
//
////////////////////////////////////////////////////////////////////////////////

function [4:0] crc5;
input    [10:0] DataByte;
input    [4:0] PrevCrc;

reg      [4:0] TempPrevCrc;
integer        i;
begin
    TempPrevCrc = PrevCrc;
    for (i = 0; i < 11; i = i + 1)
    begin
        if (DataByte[i] ^ TempPrevCrc[4] )
            TempPrevCrc = {TempPrevCrc[3:0],1'b0} ^ M05;
        else
            TempPrevCrc = {TempPrevCrc[3:0], 1'b0};
    end
    crc5 = TempPrevCrc[4:0];
end
endfunction




///////////////////////////////////////////////////////////////////////////////
//
//  FillCrc5 : fills with crc5 given a 11 bit value
//  input    : InVal, in value for which crc5 has to be appended
//             this is a 11 bit value for which the 7 LSB bits are address and 
//             4 MSB bits are end point number
//  returns  : 16 bit value for which is InVal with crc5 appended to it.
//
///////////////////////////////////////////////////////////////////////////////
function [15:0] FillCrc5;
input  [10:0] InVal;
reg    [15:0] tmpReg;
begin
tmpReg[10:0] =  InVal;     // put address and EndPt into consecutive bits
tmpReg[15:11] = crc5(InVal, 5'b11111); // calculate crc5 for the first 8 bits

tmpReg[15:11] ={tmpReg[11], tmpReg[12], tmpReg[13], tmpReg[14], tmpReg[15]};
tmpReg[6:0] = InVal[6:0];   // address
tmpReg[10:7] = InVal[10:7]; // End Point
if (GenCrc5Err == FALSE) tmpReg[15:11] = ~tmpReg[15:11];
                                               // invert the bits in the crc
tmpReg[15:11] = CorruptCrc5(tmpReg[15:11]); // crc5 corruption
FillCrc5 = tmpReg;
end
endfunction



////////////////////////////////////////////////////////////////////////////////
//
//  FillCrc16 : Calculates the crc16 value from in_out_buf
//  input   : StartAddr : start address of in_out_buf, 32 bits
//            StopAddr  : stop address of in_out_buf, 32 bits
//  returns : 16 bit value which is the crc16 for this segment of memory
//
////////////////////////////////////////////////////////////////////////////////
function [16:0] FillCrc16;

input    [31:0] StartAddr;
input    [31:0] StopAddr;

reg      [16:0] tmpCrc;
integer         i;

begin
tmpCrc = 16'hffff;
for (i = StartAddr; i <= StopAddr; i = i + 1) begin
    tmpCrc = crc16(in_out_buf[i], tmpCrc);
end
FillCrc16 = tmpCrc;
end
endfunction



////////////////////////////////////////////////////////////////////////////////
//
//   SendAck : sends an ack 
//
////////////////////////////////////////////////////////////////////////////////
task SendAck;

begin
task_in_progress = TRUE;
in_out_buf[0] = CorruptHshk({~ACK, ACK});
in_out_buf_ptr = 1;
SetSyncLevel = 2;
usb_idle(ResponseLatency - 3);
task_in_progress = TRUE;
SendData;
task_in_progress = FALSE;
end
endtask



////////////////////////////////////////////////////////////////////////////////
//
//   reset : performs a reset on the USB bus by driving SE0 
//
//   input : Reset Time in bit times
//
////////////////////////////////////////////////////////////////////////////////
task usb_reset;

input [7:0] tskResetTime;

begin
task_in_progress = TRUE;
NumResets = NumResets + 1;
SendReset(tskResetTime);
WriteResults;
task_in_progress = FALSE;
end
endtask



//////////////////////////////////////////////////////////////////////////////////
//  usb_idle : idles the USB.
//  input    : IdleTime, which is the number of bit times for which to idle the
//             bus.
//
////////////////////////////////////////////////////////////////////////////////
task usb_idle;
input [31:0] IdleTime;
reg   [31:0] tskIdleTime;

begin : usb_idle
task_in_progress = TRUE;
tskIdleTime = 0;
forever @(posedge clk) begin
   if (tskIdleTime >= IdleTime) begin
       task_in_progress = FALSE;
       disable usb_idle;
   end
   tskIdleTime = tskIdleTime + 1;
end
task_in_progress = FALSE;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//  task usb_idle_nolock : same as usb_idle except that there is no lock
//                         that is there is no assertion of the task_in_progress
//                         flag
//
///////////////////////////////////////////////////////////////////////////////
task usb_idle_nolock;
input [31:0] IdleTime;
reg   [31:0] tskIdleTime;
begin : usb_idle_nolock
tskIdleTime = 0;
forever @(posedge clk) begin
   if (tskIdleTime >= IdleTime) begin
       task_in_progress = FALSE;
       disable usb_idle_nolock;
   end
   tskIdleTime = tskIdleTime + 1;
end
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  setup : issues a setup token with the corresponding data
//  inputs  : address : address of the device, 7 bits
//            EndPt   : end point number, 4 bits
//  outputs : Status  : returns the status of the transaction, 4 bits
//
////////////////////////////////////////////////////////////////////////////////
task setup;

input   [6:0]  address;
input   [3:0]  EndPt;

output  [3:0]  Status; // 0 : ack received
                       // 3 : no response
                       // 4 : invalid response
                       // 6 : another control transaction in progress
                       // 8 : invalid control data
reg     [3:0]  Status;
reg     [15:0] tmpCrc;
reg     [15:0] tmpReg;
integer        i;
integer        CntrlNum; // number of the control transaction
reg     [31:0] recv_bit_count;
reg            Match;
reg     [31:0] tmpPulseWidth;

// eight bytes of setup data is assumed to be in Xmitbuffer
begin : setup
task_in_progress = TRUE;
tmpPulseWidth = PulseWidth;
Match = FALSE;
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
   if ((address == CntrlTransAddr[i]) & (EndPt == CntrlTransEndP[i])) begin
       Status = 4'b0110;
       disable setup;
   end
end
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
    if (CntrlTransType[i] == 2'b00) begin
        Match = TRUE;
        CntrlTransAddr[i] = address;
        CntrlTransEndP[i] = EndPt;
        CntrlTransDlen[i] = {XmitBuffer[7], XmitBuffer[6]};
        CntrlNum = i;
        i = MAX_CNTRL_INTERLEAVE + 1;
    end
end
    if (Match == FALSE) begin
        Status = 6; // only one control transaction in progress
        clk_swtch = HIGH_SPEED;
        task_in_progress = FALSE;
        disable setup;
    end

usb_idle(ResponseLatency - 3);  // #27
if ((SendPreamble == TRUE) & (DeviceSpeed == HIGH_SPEED)) begin
    send_preamble; // a high speed preamble is sent only when a high speed
                   // hub is connected to the host model so in this case
                   // switch clock speeds
    task_in_progress = TRUE;
    usb_idle(4);  // idle for 4 high speed clock times after a preamble
    task_in_progress = TRUE;
    // PulseWidth = PulseWidth * 8; // decrease the clock frequency
    clk_swtch = LOW_SPEED;
end

in_out_buf[0] = CorruptToken({~SETUP_TOKEN, SETUP_TOKEN});

tmpReg = FillCrc5({EndPt, address});
in_out_buf[1] = tmpReg[7:0];
in_out_buf[2] = tmpReg[15:8];
in_out_buf_ptr = 3;
SetSyncLevel = 0;
// usb_idle(ResponseLatency - 3);  #27
task_in_progress = TRUE;

SendData;

usb_idle(ResponseLatency - 3);  //  #27

send_high_speed_preamble; 
task_in_progress = TRUE;
in_out_buf[0] = CorruptDataPid({~DATA0, DATA0});
tmpCrc = 16'hffff;
for (i = 1; i <= SetupDataLen; i = i + 1) begin 
    in_out_buf[i] = XmitBuffer[i - 1];
    tmpCrc = crc16(in_out_buf[i], tmpCrc);
end
//if (Debug) $display("In %0s raw crc is %h at time %0t", SelfName, tmpCrc, $time);
tmpCrc = CorruptCrc16(~{swap8(tmpCrc[15:8]), swap8(tmpCrc[7:0])});
in_out_buf[9] = tmpCrc[15:8];
in_out_buf[10] = tmpCrc[7:0];
//if (Debug) $display("In %0s bus crc is %h at time %0t", SelfName, {in_out_buf[9], in_out_buf[10]}, $time);
in_out_buf_ptr = SetupDataLen + 3; 
SetSyncLevel = 1;
// usb_idle(ResponseLatency - 3);   #27
task_in_progress = TRUE;
SendData;
tmpReg[7:0] = XmitBuffer[0];
//if (Debug) $display("In %0s --> tmpReg = %b at time %0t", SelfName, tmpReg[7:0], $time);
case(tmpReg[7])
1'b1 : CntrlTransType[CntrlNum] = READ;
1'b0 : CntrlTransType[CntrlNum] = WRITE;
default : begin
    Status = 8; // invalid control data
    in_out_buf_ptr = 0;
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable setup;
end
endcase

if (tmpReg[7] == 1'b1) NumCntrlRdTrans = NumCntrlRdTrans + 1;
else NumCntrlWrTrans = NumCntrlWrTrans + 1;

if (Debug) $display("CntrlTransType = %b", CntrlTransType[CntrlNum]);


WaitForResp(recv_bit_count);
if (Debug) $display("In %0s --> in_out_buf[0] = %b, in_out_buf_ptr = %d", SelfName, in_out_buf[0], in_out_buf_ptr);
case (in_out_buf_ptr)
0 : begin  // time out
    if (dec_bit_stuff_err == TRUE) begin
        usb_idle(RespTimeOutVal);
        task_in_progress = TRUE;
    end
    Status = 3;
    CntrlTransType[CntrlNum] = 2'b00; // clear the transaction in progress flag
    CntrlTransAddr[CntrlNum] = 7'b1111111;
    CntrlTransEndP[CntrlNum] = 4'b1111;
    CntrlTransDlen[CntrlNum] = 0;
end
1 : begin
    if (in_out_buf[0] == {~ACK, ACK}) begin
        Status = 0; //setup initiated successfully
        SetDataToggle(address, EndPt, 2'b11);
    end
    else begin
        Status = 4; // invalid response
        CntrlTransType[CntrlNum] = 2'b00;
                            // clear the transaction in progress flag
        CntrlTransAddr[CntrlNum] = 7'b1111111;
        CntrlTransEndP[CntrlNum] = 4'b1111;
        CntrlTransDlen[CntrlNum] = 0;
    end
end
default : begin
    Status = 4; // invalid response
    CntrlTransType[CntrlNum] = 2'b00;
                             // clear the transaction in progress flag
    CntrlTransAddr[CntrlNum] = 7'b1111111;
    CntrlTransEndP[CntrlNum] = 4'b1111;
    CntrlTransDlen[CntrlNum] = 0;
end
endcase
WriteResults;
clk_swtch = HIGH_SPEED;
task_in_progress = FALSE;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  control_IN : does the data phase in a control transaction initiated by
//               a call to setup
//  output     : ByteCount : number of bytes received during this control_in
//  Status     : Exit Status of this task
//
////////////////////////////////////////////////////////////////////////////////

task control_IN;
input   [6:0]     address;
input   [3:0]     EndPt;
output  [31:0]    ByteCount;
output  [3:0]     Status;

reg     [3:0]     Status;
reg     [31:0]    tskByteCount;
reg     [31:0]    recv_bit_count;
reg     [15:0]    tmpReg;
reg     [15:0]    tmpCrc;
integer           i;
integer           CntrlNum;
reg               tmpDataToggle;
reg     [31:0]    tmpPulseWidth;

begin : control_IN
task_in_progress = TRUE;
ByteCount = 0;
tmpPulseWidth = PulseWidth;
CntrlNum = 0;
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
    if ((CntrlTransType[i] != 2'b00) & (CntrlTransAddr[i] == address) & (CntrlTransEndP[i] == EndPt)) begin
        CntrlNum = i;
        i = MAX_CNTRL_INTERLEAVE + 1;
    end
end
if (Debug) $display("CntrlTransType = %b", CntrlTransType[CntrlNum]);
if (CntrlNum == 0) begin
    DispErrMsg(0, 0, 21);
    Status = 7;
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_IN;
end
if (CntrlTransType[CntrlNum] == 2'b00) begin  // redundant ??
    DispErrMsg(0, 0, 21);
    Status = 7; // no setup transaction in progress to do a control_in xfer
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_IN;
end

if (CntrlTransType[CntrlNum] != READ) begin
    DispErrMsg(0, 0, 22);
    Status = 9; // wrong type of control transaction
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_IN;
end


if ((SendPreamble == TRUE) & (DeviceSpeed == HIGH_SPEED)) begin
    clk_swtch = LOW_SPEED;         // #27
    usb_idle(ResponseLatency - 3); // #27
    clk_swtch = HIGH_SPEED;        // #27
    send_preamble; // a high speed preamble is sent only when a high speed
                   // hub is connected to the host model so in this case
                   // switch clock speeds
    task_in_progress = TRUE;
    usb_idle(4);  // idle for 4 high speed clock times after a preamble
    task_in_progress = TRUE;
    // PulseWidth = PulseWidth * 8;
    clk_swtch = LOW_SPEED;
end

in_out_buf[0] = CorruptToken({~IN_TOKEN, IN_TOKEN});
in_out_buf_ptr = 1;

tmpReg[15:0] = FillCrc5({EndPt, address});

in_out_buf[1] = tmpReg[7:0];
in_out_buf[2] = tmpReg[15:8];
in_out_buf_ptr = 3;
SetSyncLevel = 0;
// usb_idle(ResponseLatency - 3); #27
task_in_progress = TRUE;
SendData;   //serialises, encodes and sends the data in in_out_buf,

WaitForResp(recv_bit_count);
@(posedge dpll_clk); // 10/10/97
case(in_out_buf_ptr)
0 : begin // no response from device abort control transaction
    Status = 3;
    if (Debug) $display("In %0s --> time out for control_in transaction at time %0t", SelfName, $time);
end
1 : begin
    tmpReg[7:0] = in_out_buf[0]; //should contain the pid
    if (tmpReg[7:4] != (~tmpReg[3:0])) begin
        DispErrMsg(address, EndPt, 5);
    end
    if (tmpReg[3:0] == NAK) begin
        DispErrMsg(address, EndPt, 11);
        Status = 1; //NAK received from end point
    end
    if (tmpReg[3:0] == STALL) begin
        DispErrMsg(address, EndPt, 12);
        Status = 2; //STALL received from end point
    end
end
2 : begin
    DispErrMsg(address, EndPt, 6); // invalid number of data bytes received
    Status = 4; //invalid response
end
default : begin
    tmpReg[7:0] = in_out_buf[0]; //should contain the pid
    if (tmpReg[7:4] != (~tmpReg[3:0])) begin
        DispErrMsg(address, EndPt, 5);
    end
    if (Debug) $display("In %0s --> Data toggle recevied is %0b at time %0t", SelfName, tmpReg[7:0], $time);
    ByteCount = 0;
    tmpCrc = 16'hffff;
    //if (Debug) $display("In %0s --> calculating crc for in_out_buf[%0d] = %0h", SelfName, i, in_out_buf[i]);
    for (i = 1; i < (in_out_buf_ptr - 2); i = i + 1) begin
        tmpCrc = crc16(in_out_buf[i], tmpCrc);
        RecvBuffer[i - 1] = in_out_buf[i];
        ByteCount = ByteCount + 1;
        if (Debug) $display("In %0s --> received byte[%0d] = %b", SelfName, i, in_out_buf[i]);
    end
    if (Debug) $display("In %0s --> calculated crc is %0h at time %0t.", SelfName, tmpCrc, $time);
    if (Debug) $display("In %0s --> received raw crc is %0h at time %0t.", SelfName, {swap8(~in_out_buf[in_out_buf_ptr - 2]), swap8(~in_out_buf[in_out_buf_ptr - 1])}, $time);
    tmpCrc = CorruptCrc16(~{swap8(tmpCrc[15:8]), swap8(tmpCrc[7:0])});
    if (Debug) $display("In %0s --> received crc is %0h at time %0t.", SelfName, {in_out_buf[in_out_buf_ptr - 2], in_out_buf[in_out_buf_ptr - 1]}, $time);
  
    //ByteCount = ByteCount + 1;
    if (Debug) $display("In %0s --> tmpCrc %0h, at time %0t", SelfName, tmpCrc, $time);
    if (tmpCrc != {in_out_buf[in_out_buf_ptr - 2], in_out_buf[in_out_buf_ptr - 1]}) begin
        DispErrMsg(address, EndPt, 8); //CRC Error, send no response
        Status = 5;
        usb_idle(RespTimeOutVal);
        task_in_progress = TRUE;
    end
    else begin
        case (tmpReg[3:0]) //check the token
        DATA0 : begin
            if(CheckDataToggleIN(address, EndPt) != 0) begin
                DispErrMsg(address, EndPt, 10);
                ByteCount = 0; // discard data
            end
            SetDataToggle(address, EndPt, 2'b11);
            //usb_idle(ResponseLatency - 3);   // #27
            send_high_speed_preamble;
            task_in_progress = TRUE;
            SendAck;
            task_in_progress = TRUE;
            Status = 0;
            if (Debug) $display("In %0s --> sending ACK at time %0t", SelfName, $time);
        end
        DATA1 : begin
            if(CheckDataToggleIN(address, EndPt) != 1) begin
                DispErrMsg(address, EndPt, 10);
                ByteCount = 0; // discard data
            end
            SetDataToggle(address, EndPt, 2'b00);
                //usb_idle(ResponseLatency - 3);
                send_high_speed_preamble;
                task_in_progress = TRUE;
                SendAck;
                task_in_progress = TRUE;
                Status = 0;
                if (Debug) $display("In %0s --> sending ACK at time %0t", SelfName, $time);
        end
        default : begin
            Status = 4;
            ByteCount = 0; // discard data
            DispErrMsg(address, EndPt, 9); //incorrect token
        end
        endcase
    end //if (tmpCrc ...
end  // default :
endcase

if (ByteCount > CntrlTransDlen[CntrlNum]) begin
    CntrlTransDlen[CntrlNum] = 0;
    DispErrMsg(address, EndPt, 20);
end
if (Status == 0) CntrlTransDlen[CntrlNum] = CntrlTransDlen[CntrlNum] - ByteCount;
WriteResults;
// PulseWidth = tmpPulseWidth;
clk_swtch = HIGH_SPEED;
task_in_progress = FALSE;
end
endtask



////////////////////////////////////////////////////////////////////////////////
//
// control_OUT : does the data phase in control transaction intiated by a setup
// input       : ByteCount, number of bytes from XmitBuffer to send
// Status      : exit status
//
////////////////////////////////////////////////////////////////////////////////
task control_OUT;
input   [6:0]     address;
input   [3:0]     EndPt;
input   [31:0]    ByteCount;
output  [3:0]     Status;

reg     [3:0]     Status;
reg     [31:0]    tskByteCount;
reg     [31:0]    recv_bit_count;
reg     [15:0]    tmpReg;
reg     [15:0]    tmpCrc;
integer           i;
integer           CntrlNum;
reg               tmpDataToggle;
reg     [31:0]    tmpPulseWidth;

begin : control_OUT
task_in_progress = TRUE;
tmpPulseWidth = PulseWidth;
CntrlNum = 0;
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
    if ((CntrlTransType[i] != 2'b00) & (CntrlTransAddr[i] == address) & (CntrlTransEndP[i] == EndPt)) begin
        CntrlNum = i;
        i = MAX_CNTRL_INTERLEAVE + 1;
    end
end
if (CntrlNum == 0) begin
    DispErrMsg(0, 0, 21);
    Status = 7;
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_OUT;
end

if (CntrlTransType[CntrlNum] == 2'b00) begin
    DispErrMsg(0, 0, 21);
    Status = 7; // no setup transaction in progress to do a control_in xfer
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_OUT;
end

if (CntrlTransType[CntrlNum] != WRITE) begin
    DispErrMsg(0, 0, 22);
    Status = 9; // wrong type of control transaction
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_OUT;
end

if (CntrlTransDlen[CntrlNum] == 0) begin
    DispErrMsg(0, 0, 23);
    Status = 10; // doing a control transaction when wLength is 0
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable control_OUT;
end
// no setup transaction in progress so start a control_in transaction

usb_idle(ResponseLatency - 3); 

if ((DeviceSpeed == HIGH_SPEED) & (SendPreamble == TRUE)) begin
    clk_swtch = LOW_SPEED;           // #27
    usb_idle(ResponseLatency - 3);   // #27
    clk_swtch = HIGH_SPEED;          // #27
    send_preamble; // a high speed preamble is sent only when a high speed
                   // hub is connected to the host model so in this case
                   // switch clock speeds
    task_in_progress = TRUE;
    // PulseWidth = PulseWidth * 8;
    clk_swtch = LOW_SPEED;
end


tskByteCount = ByteCount;
if (tskByteCount > CntrlTransDlen[CntrlNum]) begin
    if (Debug) $display("In %0s --> more data is being requested than specified by wLength, ignoring the extra bytes at time %0t", SelfName, $time);
    tskByteCount = CntrlTransDlen[CntrlNum];
end
// else CntrlTransDlen[CntrlNum] = CntrlTransDlen[CntrlNum] - tskByteCount;
                                                        // decrement data count

in_out_buf[0] = CorruptToken({~OUT_TOKEN, OUT_TOKEN});
in_out_buf_ptr = 1;

tmpReg[15:0] = FillCrc5({EndPt, address});

in_out_buf[1] = tmpReg[7:0];
in_out_buf[2] = tmpReg[15:8];
in_out_buf_ptr = 3;
if (Debug) $display("In  host --> address = %h, EndPt = %h, crc5 = %h, tmpReg = %h", address, EndPt, tmpReg[15:11], tmpReg);

SetSyncLevel = 0;
task_in_progress = TRUE;
SendData;     //serialises, encodes and sends the data in in_out_buf

task_in_progress = TRUE;
tmpDataToggle = CheckDataToggleIN(address, EndPt);
if (Debug) $display("In %0s --> DataToggle is %0h", SelfName, tmpDataToggle);

case (tmpDataToggle)
0 : in_out_buf[0] = CorruptDataPid({~DATA0, DATA0});
1 : in_out_buf[0] = CorruptDataPid({~DATA1, DATA1});
default : in_out_buf[0] = CorruptDataPid({~DATA0, DATA0});
endcase
in_out_buf_ptr = 1;
if (Debug) $display("In %0s --> DataToggle is %0h at time %0t.", SelfName, in_out_buf[0], $time);

tmpCrc = 16'hffff;
for (i = 1; i <= ByteCount; i = i + 1) begin
    in_out_buf[i] = XmitBuffer[i - 1];
    tmpCrc = crc16(in_out_buf[i], tmpCrc);
    in_out_buf_ptr = in_out_buf_ptr + 1;
    if (Debug) $display("In %0s --> sending byte[%0d] = %b", SelfName, i, in_out_buf[i]);
end
if (Debug) $display("In %0s --> raw crc is %0h at time", SelfName, tmpCrc, $time);
tmpCrc = CorruptCrc16(~{swap8(tmpCrc[15:8]), swap8(tmpCrc[7:0])});
if (Debug) $display("In %0s --> sent crc is %0h at time", SelfName, tmpCrc, $time);
in_out_buf[ByteCount + 2] = tmpCrc[7:0];
in_out_buf[ByteCount + 1] = tmpCrc[15:8];
in_out_buf_ptr = in_out_buf_ptr + 2;
SetSyncLevel = 1;
usb_idle(ResponseLatency - 3);
task_in_progress = TRUE;
send_high_speed_preamble;
task_in_progress = TRUE;
SendData; //send the contents of in_out_buf

WaitForResp(recv_bit_count);  //wait for a response for this transfer
if (Debug) $display("In %0s --> bits received are %0h", SelfName, recv_bit_count);

case (in_out_buf_ptr)
0 : begin
    if (dec_bit_stuff_err == TRUE) begin
        usb_idle(RespTimeOutVal);
        task_in_progress = TRUE;
    end
    Status = 3;
    DispErrMsg(address, EndPt, 4);
end
1 : begin
    tmpReg[7:0] = in_out_buf[0];
    case (tmpReg[3:0])
    ACK   : begin
        case (tmpDataToggle)   //change the data toggle
        0 : SetDataToggle(address, EndPt, 2'b11);
        1 : SetDataToggle(address, EndPt, 2'b00);
        default : SetDataToggle(address, EndPt, 0);
        endcase
        Status = 0;
        if (Debug) $display("In %0s --> ACK received at time %0t.", SelfName, $time);
    end
    NAK   : begin
        DispErrMsg(address, EndPt, 11);
        Status = 1; // nak received
    end
    STALL : begin
        DispErrMsg(address, EndPt, 12);
        Status = 2; // stall received
    end
    default : begin
        DispErrMsg(address, EndPt, 13);
        Status = 4; // invalid response
    end
    endcase
end
default : DispErrMsg(address, EndPt, 14);
endcase
if (Status == 0) CntrlTransDlen[CntrlNum] = CntrlTransDlen[CntrlNum] - tskByteCount;
WriteResults;
// PulseWidth = tmpPulseWidth;
clk_swtch = HIGH_SPEED;
task_in_progress = FALSE;
end
endtask   //control_out



////////////////////////////////////////////////////////////////////////////////
//
//  status_in : does the status phase in a control transaction
//  output    : Status : exit status of the transaction
//
////////////////////////////////////////////////////////////////////////////////
task status_IN;
input   [6:0]     address;
input   [3:0]     EndPt;
output            Status;
reg     [3:0]     Status;
reg     [31:0]    recv_bit_count;
reg     [15:0]    tmpReg;
integer           i;
reg               tmpDataToggle;
integer           CntrlNum;
reg     [31:0]    tmpPulseWidth;

begin : status_IN
task_in_progress = TRUE;
tmpPulseWidth = PulseWidth;
CntrlNum = 0;
$display("Input Address:%x, EndPt:%x",address,EndPt);
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
    $display("i :%d, CntrlTransType:%x; CntrlTransAddr:%x;CntrlTransEndP:%x ",
	    i,CntrlTransType[i],CntrlTransAddr[i],CntrlTransEndP[i]);
    if ((CntrlTransType[i] != 2'b00) & (CntrlTransAddr[i] == address) & (CntrlTransEndP[i] == EndPt)) begin
        CntrlNum = i;
        i = MAX_CNTRL_INTERLEAVE + 1;
    end
end
if (CntrlNum == 0) begin
    DispErrMsg(0, 0, 21);
    Status = 7;
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_IN;
end
if (CntrlTransType[CntrlNum] == 2'b00) begin
    DispErrMsg(0, 0, 24);
    Status = 7; // no setup transaction in progress to do a control_in xfer
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_IN;
end
if (Debug) $display("In %0s CntrlTransType = %b, WRITE = %b", SelfName, CntrlTransType[CntrlNum], WRITE);
if (CntrlTransType[CntrlNum] != WRITE) begin
    DispErrMsg(0, 0, 22);
    Status = 9; // wrong type of control transaction
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_IN;
end

usb_idle(ResponseLatency - 3);
task_in_progress = TRUE;
if ((DeviceSpeed == HIGH_SPEED) & (SendPreamble == TRUE)) begin
    clk_swtch = LOW_SPEED;           // #27
    usb_idle(ResponseLatency - 3);   // #27
    clk_swtch = HIGH_SPEED;          // #27
    send_preamble; // a high speed preamble is sent only when a high speed
                   // hub is connected to the host model so in this case
                   // switch clock speeds
    task_in_progress = TRUE;
    // PulseWidth = PulseWidth * 8;
    clk_swtch = LOW_SPEED;
end
in_out_buf[0] = CorruptToken({~IN_TOKEN, IN_TOKEN});
in_out_buf_ptr = 1;

tmpReg[15:0] = FillCrc5({EndPt, address});

in_out_buf[1] = tmpReg[7:0];
in_out_buf[2] = tmpReg[15:8];
in_out_buf_ptr = 3;
SetSyncLevel = 0;
SendData;   //serialises, encodes and sends the data in in_out_buf,

WaitForResp(recv_bit_count);
case (in_out_buf_ptr)
0 : begin // timeout
    if (dec_bit_stuff_err == TRUE) begin
        usb_idle(RespTimeOutVal);
        task_in_progress = TRUE;
    end
    Status = 3;
end
1 : begin
    tmpReg[7:0] = in_out_buf[0]; //should contain the pid
    if (tmpReg[7:4] != (~tmpReg[3:0])) begin
        DispErrMsg(address, EndPt, 5);
    end
    if (tmpReg[3:0] == NAK) begin
        DispErrMsg(address, EndPt, 11);
        Status = 1; //NAK received from end point
    end
    else if (tmpReg[3:0] == STALL) begin
        DispErrMsg(address, EndPt, 12);
        Status = 2; //STALL received from end point
    end
    else begin
        Status = 4; // invalid response
    end
end
    3 : begin
        tmpReg[7:0] = in_out_buf[0]; //should contain the pid
        if (tmpReg[7:4] != (~tmpReg[3:0])) begin
            DispErrMsg(address, EndPt, 5);
        end
        if ({in_out_buf[1], in_out_buf[2]} != 16'h0000) begin
            DispErrMsg(address, EndPt, 8);
            usb_idle(RespTimeOutVal);
            task_in_progress = TRUE;
            Status = 5;
        end
        else begin
            if (tmpReg[3:0] == DATA1) begin
                NumSucCntrlWrTrans = NumSucCntrlWrTrans + 1;
                //usb_idle(ResponseLatency - 3);   // #27
                send_high_speed_preamble; 
                task_in_progress = TRUE;
                SendAck;
                task_in_progress = TRUE;
                Status = 0;
            end
            else begin
                DispErrMsg(address, EndPt, 25);
                usb_idle(RespTimeOutVal);
                task_in_progress = TRUE;
            end
        end
    end
    default : begin
        Status = 4; // invalid response
    end
endcase

//reset control transaction flags
if (Status != 1) begin
    CntrlTransEndP[CntrlNum] = 4'b1111;
    CntrlTransAddr[CntrlNum] = 7'b1111111;
    CntrlTransDlen[CntrlNum] = 0;
    CntrlTransType[CntrlNum] = 0;
end
WriteResults;
// PulseWidth = tmpPulseWidth;
clk_swtch = HIGH_SPEED;
task_in_progress = FALSE;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  status_out : does the status phase of a control transaction
//  output     : Status : Exit Status
//
////////////////////////////////////////////////////////////////////////////////
task status_OUT;
input   [6:0]     address;
input   [3:0]     EndPt;
output            Status;
reg     [3:0]     Status;
reg     [31:0]    recv_bit_count;
reg     [15:0]    tmpReg;
integer           i;
reg               tmpDataToggle;
integer           CntrlNum;
reg     [31:0]    tmpPulseWidth;

begin : status_OUT
task_in_progress = TRUE;
tmpPulseWidth = PulseWidth;
CntrlNum = 0;
for (i = 1; i <= MAX_CNTRL_INTERLEAVE; i = i + 1) begin
    if ((CntrlTransType[i] != 2'b00) & (CntrlTransAddr[i] == address) & (CntrlTransEndP[i] == EndPt)) begin
        CntrlNum = i;
        i = MAX_CNTRL_INTERLEAVE + 1;
    end
end
if (CntrlNum == 0) begin
    DispErrMsg(0, 0, 21);
    Status = 7;
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_OUT;
end
if (CntrlTransType [CntrlNum]== 2'b00) begin
    DispErrMsg(0, 0, 24);
    Status = 7; // no setup transaction in progress to do a control_in xfer
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_OUT;
end

if (CntrlTransType[CntrlNum] != READ) begin
    DispErrMsg(0, 0, 22);
    Status = 9; // wrong type of control transaction
    clk_swtch = HIGH_SPEED;
    task_in_progress = FALSE;
    disable status_OUT;
end

usb_idle(ResponseLatency - 3);
task_in_progress = TRUE;
if ((DeviceSpeed == HIGH_SPEED) & (SendPreamble == TRUE)) begin
    clk_swtch = LOW_SPEED;           // #27
    usb_idle(ResponseLatency - 3);   // #27
    clk_swtch = HIGH_SPEED;          // #27
    send_preamble; // a high speed preamble is sent only when a high speed
                   // hub is connected to the host model so in this case
                   // switch clock speeds
    task_in_progress = TRUE;
    usb_idle(4);  // idle for 4 high speed clock times after a preamble
    task_in_progress = TRUE;
    // PulseWidth = PulseWidth * 8;
    clk_swtch = LOW_SPEED;
end
in_out_buf[0] = CorruptToken({~OUT_TOKEN, OUT_TOKEN});
in_out_buf_ptr = 1;

tmpReg[15:0] = FillCrc5({EndPt, address});

in_out_buf[1] = tmpReg[7:0];
in_out_buf[2] = tmpReg[15:8];
in_out_buf_ptr = 3;
SetSyncLevel = 0;
SendData;

usb_idle(ResponseLatency - 3);
task_in_progress = TRUE;
send_high_speed_preamble; 
task_in_progress = TRUE;
in_out_buf[0] = CorruptDataPid({~DATA1, DATA1});
in_out_buf[1] = 0;
in_out_buf[2] = 0;
in_out_buf_ptr = 3;
SetSyncLevel = 1;
SendData;

WaitForResp(recv_bit_count);

case (in_out_buf_ptr)
0 : begin
    if (dec_bit_stuff_err == TRUE) begin
        usb_idle(RespTimeOutVal);
        task_in_progress = TRUE;
    end
    Status = 3; // time out
end
1 : begin
    tmpReg[7:0] = in_out_buf[0]; //should contain the pid
    if (tmpReg[7:4] != (~tmpReg[3:0])) begin
        DispErrMsg(address, EndPt, 5);
    end
    if (tmpReg[3:0] == NAK) begin
        DispErrMsg(address, EndPt, 11);
        Status = 1; //NAK received from end point
    end
    else if (tmpReg[3:0] == STALL) begin
        DispErrMsg(address, EndPt, 12);
        Status = 2; //STALL received from end point
    end
    else if (tmpReg[3:0] == ACK) begin
        NumSucCntrlRdTrans = NumSucCntrlRdTrans + 1;
        Status = 0;
    end
    else begin
        Status = 4; // invalid response
    end
end
    default : begin
        Status = 4; // invalid response
    end
endcase

//reset control transaction flags
if (Status != 1) begin
    CntrlTransEndP[CntrlNum] = 0;
    CntrlTransAddr[CntrlNum] = 7'b1111111;
    CntrlTransDlen[CntrlNum] = 4'b1111;
    CntrlTransType[CntrlNum] = 0;
end
// PulseWidth = tmpPulseWidth;
clk_swtch = HIGH_SPEED;
WriteResults;
task_in_progress = FALSE;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  usb_resume : drives a K state on the bus for ResumeTime number of bit times
//
////////////////////////////////////////////////////////////////////////////////
task usb_resume;
input [31:0] ResumeTime;
reg   [31:0] tskResumeTime;

begin : usb_resume
task_in_progress = TRUE;
tskResumeTime = 0;
forever @(posedge clk) begin
   if (tskResumeTime >= ResumeTime) begin
       zDPLS = 1'b0;
       zDMNS = 1'b0;
       if (DeviceSpeed == HIGH_SPEED) begin // wait for two low speed bit times
           #667;
           #667;
       end
       else begin
           @(posedge clk);
           @(posedge clk);
       end
       zDPLS = 1'bZ;
       zDMNS = 1'bZ;
       task_in_progress = FALSE;
       disable usb_resume;
   end
   if (DeviceSpeed == HIGH_SPEED) begin
       zDPLS = 1'b0;
       zDMNS = 1'b1;
   end
   else begin
       zDPLS = 1'b1;
       zDMNS = 1'b0;
   end
   tskResumeTime = tskResumeTime + 1;
end
task_in_progress = FALSE;
end
endtask



////////////////////////////////////////////////////////////////////////////////
//
//  send_preamble : sends a Preamble token and idles the bus for the required
//                 4 bit times which is the hub setup time for low speed devices
//
////////////////////////////////////////////////////////////////////////////////
task send_preamble;

reg         tskGenSE0Error;
reg [31:0]  tskSE0BitTimes;
reg [31:0]  tskSE0ErrorLevel;

begin
task_in_progress = TRUE; 
// SE0 should not be generated after sending a preamble 10/03/1996
// modify SE0 error generation logic
tskGenSE0Error = GenSE0Error;
tskSE0BitTimes = SE0BitTimes;
tskSE0ErrorLevel = SE0ErrorLevel;

GenSE0Error = TRUE;
SE0BitTimes = 0;
SE0ErrorLevel = SetSyncLevel;

in_out_buf[0] = {~PREAMBLE, PREAMBLE};
in_out_buf_ptr = 1;
SendData;

// restore SE0 error generation logic 10/03/1996
GenSE0Error = tskGenSE0Error;
SE0BitTimes = tskSE0BitTimes;
SE0ErrorLevel = tskSE0ErrorLevel;

usb_idle(4);  // hub setup time
task_in_progress = FALSE;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  transfer_buf : transfers whatever data from the xmit buffer with a sync
//                 field in the front
//  input : ByteCount : number of bytes to be transferred from buffer, 32 bits
//          FromFile  : TRUE/FALSE, if TRUE data is taken from host_usb_recv.dat
//
////////////////////////////////////////////////////////////////////////////////
task transfer_buf;

input [31:0]   ByteCount;
input          FromFile;
input [160:1]  FileName;
reg   [3:0]    Status;
integer        i;

begin : transfer_buf
task_in_progress = TRUE;
    for (i = 0; i < ByteCount; i = i + 1) begin
        in_out_buf[i] = XmitBuffer[i];    // addition 5/29/1996
    end
in_out_buf_ptr = ByteCount;
SendData;
task_in_progress = FALSE;
end
endtask


////////////////////////////////////////////////////////////////////////////////
//
//  receive_buf : receives the data from the bus and puts in RecvBuf
//  input  : DumpToFile : if true data is dumped to a file
//  output : ByteCount : number of bytes received
//
////////////////////////////////////////////////////////////////////////////////
task receive_buf;

input          DumpToFile;
output [31:0]  ByteCount;
reg    [31:0]  recv_bit_count;
integer        i;

begin
task_in_progress = TRUE;
WaitForResp(recv_bit_count);
for (i = 0; i < in_out_buf_ptr; i = i + 1) begin
    RecvBuffer[i] = in_out_buf[i];
end
ByteCount = in_out_buf_ptr;
if (DumpToFile == TRUE && ByteCount > 0) DumpData(7'b1111111, 4'b1111, DATA0, ByteCount-1);
task_in_progress = FALSE;
end

endtask


///////////////////////////////////////////////////////////////////////////////
//
//  task send_high_speed_preamble : sends a preamble by switching clock
//                                  during a low speed transaction
//
////////////////////////////////////////////////////////////////////////////////
task send_high_speed_preamble;
begin
task_in_progress = TRUE;
if ((SendPreamble == TRUE) & (DeviceSpeed == HIGH_SPEED)) begin
     // PulseWidth = PulseWidth / 8;
     clk_swtch = HIGH_SPEED;
     send_preamble;
     task_in_progress = TRUE;
         // a high speed preamble is sent only when a high speed
         // hub is connected to the host model so in this case
         // switch clock speeds
     usb_idle(4);
     task_in_progress = TRUE;
         // idle for 4 high speed clock times after a preamble
     // PulseWidth = PulseWidth * 8;
     clk_swtch = LOW_SPEED;
end
task_in_progress = FALSE;
end
endtask



initial begin // initilaise the input and output buffers
    for(tmpCounter = 0; tmpCounter <= 2048; tmpCounter = tmpCounter + 1) begin
        XmitBuffer[tmpCounter] = 8'b00000000;
    end
    for(tmpCounter = 0; tmpCounter <= RECV_BUF_SIZE; tmpCounter = tmpCounter + 1) begin
        RecvBuffer[tmpCounter] = 8'b00000000;
    end
    for (tmpCounter = 0; tmpCounter < IN_OUT_BUF_SIZE; tmpCounter = tmpCounter + 1) begin
        in_out_buf[tmpCounter] = 0;
    end
    //for (tmpCounter = 0; tmpCounter < OUT_BUF_SIZE; tmpCounter = tmpCounter + 1) begin
        //out_buf[tmpCounter] = 0;
    //end
    for (tmpCounter = 0; tmpCounter < 128; tmpCounter = tmpCounter + 1)
    begin
        InDataToggle[tmpCounter]  = 16'h0000;
        OutDataToggle[tmpCounter] = 16'h0000;
    end

    TimeOut        = TRUE;
    TimeOutVal     = 16;     // timeout after 16 bit times
    RespTimeOutVal = 16;

    ResponseLatency = 3;

    GenCrc16Err    = FALSE;
    Crc16ErrMask   = 16'hffff;
  
    GenCrc5Err     = FALSE;
    Crc5ErrMask    = 5'b00000;
   
    ReportResults  = TRUE; // default : turned on
    ResultsFile    = "host_usb_res.log"; // default file name
    ResultsFp      = 0; // initially log file pointer is 0

    PulseWidth     = 42;

    SyncField      = FALSE; // default : sync field corruption is turned off
    SyncFieldMask  = 8'hf0; // default no sync field corruption specified
    SyncLevel      = 0;
    SetSyncLevel   = 0;

    GenSE0Error    = FALSE;
    SE0BitTimes    = 2;     // default conforms to the spec
    SE0ErrorLevel  = 0;

    HshkPidIntegrity = FALSE; // no corruption
    HshkPidIntegrityMask = 8'hf0; // corruption mask for ACK's

    BitStuffErr = FALSE; // changed TRUE to FALSE 02/18/97

    for (tmpCounter = 1; tmpCounter <= MAX_CNTRL_INTERLEAVE; tmpCounter = tmpCounter + 1) begin
        CntrlTransType[tmpCounter] = 2'b00;
                                   // no control transaction in progress
        CntrlTransAddr[tmpCounter] = 7'b1111111;
                                   // address of a control transaction
        CntrlTransEndP[tmpCounter] = 4'b1111;
                                   // endpoint number of a control transaction
        CntrlTransDlen[tmpCounter] = 16'h0000;
                                   // data length for this control transaction
    end

    SendDataFileName = "host_usb_xmit.dat";
    RecvDataFileName = "host_usb_recv.dat";
    RecvDataFp = 0;
    ReportErrors = TRUE;
    ErrorFileName = "host_usb_err.log";
    ErrorFileFp = 0;

    for ( tmpCounter = 1; tmpCounter <= NUM_ENDPT_FILES; tmpCounter = tmpCounter + 1) begin
        EndPtFileName[tmpCounter] = "";
        EndPtFileMode[tmpCounter] = 2'b00; // no mode is assigned to it
        EndPtFileInfo[tmpCounter] = 11'b00000000000;
        EndPtFp[tmpCounter] = 0;
        EndPtFileOfst[tmpCounter] = 0;
    end

    SendDataOfst = 0;

    Debug = FALSE;

    GenDataPidErr = FALSE;
    DataPidErrMask = 8'hff;
    GenTokenErr = FALSE;
    TokenErrMask = 8'hff;

    //DeviceSpeed = LOW_SPEED;
    DeviceSpeed = HIGH_SPEED;
    GenByteBoundary = FALSE;

    SendPreamble = FALSE;   // assumes a low speed device is connected to the
                            // host

    FrameNumber = 0;

    NumBulkInTrans = 0;       // number of bulk in transactions
    NumSucBulkInTrans = 0;    // number of successful bulk in transctions
    NumBulkOutTrans = 0;      // number of bulk out transactions
    NumSucBulkOutTrans = 0;   // number of successful bulk out transactions
    NumIsoInTrans = 0;        // number of iso in transactions
    NumSucIsoInTrans = 0;     // number of successful iso in transactions
    NumIsoOutTrans = 0;       // number of iso out transactions
    NumSOF = 0;               // number of SOF's sent
    NumCntrlRdTrans = 0;      // number of control reads
    NumSucCntrlRdTrans = 0;   // number of successful control reads
    NumCntrlWrTrans = 0;      // number of control writes
    NumSucCntrlWrTrans = 0;   // number of successful control writes
    NumIntrptTrans = 0;       // number of interrupts
    NumSucIntrptTrans = 0;    // number of successful interrupts
    NumIntrOutTrans = 0;      // number of interrupt out transactions
    NumSucIntrOutTrans = 0;   // number of successful interrupt out transactions
    NumResets = 0;            // number of resets

    // intialize Jitter registers
    HighJitterTime   = 0;
    LowJitterTime    = 0;
    JitterPeriod     = 0;
    JitterCount      = 0;
    JitterOnOff      = FALSE;  // Jitter generation is off by default;

    task_in_progress = FALSE;

    clk_swtch = HIGH_SPEED;

    SetupDataLen = 8;

    GenByteBoundaryPos = FALSE;
    BoundaryBitVal = 1'b0;

    ModifyGran = 0;

end


assign clk = (clk_swtch == LOW_SPEED) ? ls_clk : hs_clk;
assign clk4x = (clk_swtch == LOW_SPEED) ? clk6 : clk48;




///////////////////////////////////////////////////////////////////////////////
//
//   task in_token : sends an in token on to the bus.
//   inputs : address : 7 bits : endpoint address
//            EndPt   : 4 bits : endpoint number
//
///////////////////////////////////////////////////////////////////////////////
task in_token;
input     [6:0]    address;
input     [3:0]    EndPt;
reg       [15:0]   tmpReg;
begin
    in_out_buf[0]  = CorruptToken({~IN_TOKEN, IN_TOKEN});
    tmpReg[15:0]   = FillCrc5({EndPt, address});
    in_out_buf[1]  = tmpReg[7:0];
    in_out_buf[2]  = tmpReg[15:8];
    in_out_buf_ptr = 3;
    SendData;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//    task out_token : sends an out token on to the bus.
//    inputs : address : 7 bits : endpoint address
//             EndPt   : 4 bits : endpoint number
//
///////////////////////////////////////////////////////////////////////////////
task out_token;
input     [6:0]    address;
input     [3:0]    EndPt;
reg       [15:0]   tmpReg;
begin
    in_out_buf[0]  = CorruptToken({~OUT_TOKEN, OUT_TOKEN});
    tmpReg[15:0]   = FillCrc5({EndPt, address});
    in_out_buf[1]  = tmpReg[7:0];
    in_out_buf[2]  = tmpReg[15:8];
    in_out_buf_ptr = 3;
    SendData;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//     task setup_token : sends an setup token on to the bus
//     inputs : address : 7 bits : endpoint address
//              EndPt   : 4 bits : endpoint number
//
///////////////////////////////////////////////////////////////////////////////
task setup_token;
input     [6:0]    address;
input     [3:0]    EndPt;
reg       [15:0]   tmpReg;
begin
    in_out_buf[0]  = CorruptToken({~SETUP_TOKEN, SETUP_TOKEN});
    tmpReg[15:0]   = FillCrc5({EndPt, address});
    in_out_buf[1]  = tmpReg[7:0];
    in_out_buf[2]  = tmpReg[15:8];
    in_out_buf_ptr = 3;
    SendData;
end
endtask



///////////////////////////////////////////////////////////////////////////////
//
//     task send_ack : sends an ACK on to the bus
//
///////////////////////////////////////////////////////////////////////////////
task send_ack;
begin
    in_out_buf[0] = CorruptHshk({~ACK, ACK});
    in_out_buf_ptr = 1;
    SendData;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//     task send_nak : sends a NAK on the bus (though an host is not supposed
//                     to send a NAK)
//
///////////////////////////////////////////////////////////////////////////////
task send_nak;
begin
    in_out_buf[0] = CorruptHshk({~NAK, NAK});
    in_out_buf_ptr = 1;
    SendData;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//     task send_stall : sends a STALL on to the bus (though an host is not
//                       supposed to send a STALL)
//
///////////////////////////////////////////////////////////////////////////////
task send_stall;
begin
    in_out_buf[0] = CorruptHshk({~STALL, STALL});
    in_out_buf_ptr = 1;
    SendData;
end
endtask


///////////////////////////////////////////////////////////////////////////////
//
//     task wait_for_data : waits for a response on the bus and decodes the
//                          data packet and returns a status indicating what
//                          type of packet was received.
//     Output : PackType  : 4'b0010 : ACK
//                          4'b1010 : NAK
//                          4'b1110 : STALL
//                          4'b0011 : DATA0
//                          4'b1011 : DATA1
//                          4'b1111 : Unknown
//              ByteCount : indicates the number of bytes of data present if
//                          PackType is of DATA0 or DATA1
//              Status    : 0  : command executed successfully.
//                          3  : time out, no response.
//                          4  : invalid response, unknown packet type
//                          5  : CRC error on received data
//                          11 : corrupted ACK/NAK/STALL
//                          12 : corrupted DATA0/DATA1 pid, CRC correct
//                          13 : corrupted DATA0/DATA1 pid, CRC incorrect
//             
//
///////////////////////////////////////////////////////////////////////////////
task wait_for_data;
output    [31:0]     ByteCount;
output    [3:0]      PackType;
output    [3:0]      Status;
reg       [15:0]     tmpReg;
reg       [15:0]     tmpCrc;
reg       [31:0]     recv_bit_count;
integer   i;
begin
WaitForResp(recv_bit_count);
PackType = 4'b1111;
Status   = 0;
case (in_out_buf_ptr)
0 : begin
    Status = 3; // timeout
    if (dec_bit_stuff_err == TRUE) usb_idle(RespTimeOutVal);
end
1 : begin
    tmpReg[7:0] = in_out_buf[0];
    case (tmpReg[3:0])
    ACK     : PackType = ACK;
    NAK     : PackType = NAK;
    STALL   : PackType = STALL;
    default : PackType = 4'b1111;
    endcase
    if (((tmpReg == ACK) | (tmpReg == NAK) | (tmpReg == STALL)) & (~tmpReg[7:4] != tmpReg[3:0])) Status = 11;
end
2 : begin
    Status = 4;
    PackType = 4'b1111;
end
default : begin   // since the number of bytes received is greater than 2 this
                  // obviously should be a data packet
    tmpReg[7:0] = in_out_buf[0];
    ByteCount = 0;
    tmpCrc = 16'hffff;
    if ((tmpReg[3:0] == DATA0) | (tmpReg[3:0] == DATA1)) begin
        for ( i = 1; i < (in_out_buf_ptr - 2); i = i + 1) begin
            tmpCrc = crc16(in_out_buf[i], tmpCrc);
            RecvBuffer[i - 1] = in_out_buf[i];
            ByteCount = ByteCount + 1;
        end
        tmpCrc = ~{swap8(tmpCrc[15:8]), swap8(tmpCrc[7:0])};
        if (tmpCrc != {in_out_buf[in_out_buf_ptr - 2], in_out_buf[in_out_buf_ptr - 1]}) Status = 5;
        if (~tmpReg[7:4] != tmpReg[3:0]) begin
            if (Status == 5) Status = 13;
            else Status = 12;
        end
        PackType = tmpReg[3:0];
    end
    else PackType = 4'b1111;
end
endcase

end
endtask




parameter  MYACK   = 4'b0000,
           MYNAK   = 4'b0001,
           MYSTALL = 4'b0010,
           MYTOUT  = 4'b0011,
           MYIVRES = 4'b0100,
           MYCRCER = 4'b0101;
           


parameter  OUT = 2'b00,
           IN  = 2'b10,
           SOF = 2'b01,
           SETUP=2'b11;


// Control Packet format;

reg [24:0]  ControlPkt;
reg  [3:0] Status;
integer     ByteCount;


task printstatus;
   input [3:0] RecvdStatus;
   input [3:0] ExpStatus;
begin
  $display("");
  $display("    #######################################################");
  if(RecvdStatus !== ExpStatus ) begin
     $display("    ERROR: Expected Status and Observed Status didn't match at %0d", $time);
     if(ExpStatus==4'b0000)
        $display("    Expected Status is ACK at %0d", $time);
     else if(ExpStatus==4'b0001)
        $display("    Expected Status is NACK at %0d", $time);
     else if(ExpStatus==4'b0010)
        $display("    Expected Status is STALL at %0d", $time);
     else if(ExpStatus==4'b0011)
        $display("    Expected Status is TIMEOUT at %0d", $time);
     else if(ExpStatus==4'b0100)
        $display("    Expected Status is INVALID RESPONSE at %0d", $time);
     else if(ExpStatus==4'b0101)
        $display("    Expected Status is CRC ERROR at %0d", $time);
  end

  if(RecvdStatus==4'b0000)
     $display("    Received Status is ACK at %0d", $time);
  else if(RecvdStatus==4'b0001)
     $display("    Received Status is NACK at %0d", $time);
  else if(RecvdStatus==4'b0010)
     $display("    Received Status is STALL at %0d", $time);
  else if(RecvdStatus==4'b011)
     $display("    Received Status is TIMEOUT at %0d", $time);
  else if(RecvdStatus==4'b0100)
     $display("    Received Status is INVALID RESPONSE at %0d", $time);
  else if(RecvdStatus==4'b0101)
     $display("    Received Status is CRC ERROR at %0d", $time);
  $display("    #######################################################");
  $display("");
end
endtask




task dump_recv_buffer;

  input [31:0] NumBytes;
  integer i;
begin


  for(i=0; i < NumBytes; i=i+1)
    $display("RecvBuffer[%0d]  = %b  : %0d", i, RecvBuffer[i], RecvBuffer[i]);
end
endtask



task send_token;
   input [1:0] tkn;
   input [6:0] adr;
   input [3:0] ep; 

   reg [2:0]   Status;
   reg [15:0]  tmpreg;
begin

   XmitBuffer[0] = {~tkn,2'b10, tkn, 2'b01};
   tmpreg = FillCrc5({ep, adr});
   XmitBuffer[1] = tmpreg[7:0];
   XmitBuffer[2] = tmpreg[15:8];
   transfer_buf(3, 0, Status);
end
endtask

task send_datapkt;
   input        datatgl;
   input [10:0] numbytes;
   
   integer      i;
   reg   [15:0] tmpcrc;
   reg   [2:0]  Status;
begin

   // Shifting the XmitBuffer Values to put the DataTkn in Byte0.
   for(i=numbytes; i > 0; i=i-1) begin
      XmitBuffer[i] = XmitBuffer[i-1];
   end

   XmitBuffer[0] = {!datatgl, 3'b100, datatgl, 3'b011};

   tmpcrc = crc16(XmitBuffer[1], 16'hffff);
   for(i=1; i < numbytes; i=i+1) begin
      tmpcrc = crc16(XmitBuffer[i+1], tmpcrc);
   end

   if(numbytes > 0) begin
      XmitBuffer[numbytes+1] = ~swap8(tmpcrc[15:8]);
      XmitBuffer[numbytes+2] = ~swap8(tmpcrc[7:0]);
   end
   else begin
      XmitBuffer[numbytes+1] = 8'b0000_0000;
      XmitBuffer[numbytes+2] = 8'b0000_0000;
   end

   transfer_buf(numbytes+3, 0, Status);

end
endtask


task SetAddress;
  input [6:0] address;
begin
    XmitBuffer[0] = 8'b0000_0000;
    XmitBuffer[1] = 8'b0000_0101; // SetAddress
    XmitBuffer[2] = {1'b0, address};
    XmitBuffer[3] = 8'b0000_0000;
    XmitBuffer[4] = 8'b0000_0000;
    XmitBuffer[5] = 8'b0000_0000;
    XmitBuffer[6] = 8'b0000_0000;
    XmitBuffer[7] = 8'b0000_0000;
end
endtask


task GetConfiguration;
begin
    XmitBuffer[0] = 8'b1000_0000;
    XmitBuffer[1] = 8'b0000_1000; // get config.
    XmitBuffer[2] = 8'b0000_0000;
    XmitBuffer[3] = 8'b0000_0000;
    XmitBuffer[4] = 8'b0000_0000;
    XmitBuffer[5] = 8'b0000_0000;
    XmitBuffer[6] = 8'b0000_0001;
    XmitBuffer[7] = 8'b0000_0000;
end
endtask


task SetConfiguration;
  input [1:0] cfg_val;
begin
    XmitBuffer[0] = 8'b0000_0000;
    XmitBuffer[1] = 8'b0000_1001; // Set Configuration
    XmitBuffer[2] = {6'b000_000, cfg_val};
    XmitBuffer[3] = 8'b0000_0000;
    XmitBuffer[4] = 8'b0000_0000;
    XmitBuffer[5] = 8'b0000_0000;
    XmitBuffer[6] = 8'b0000_0000;
    XmitBuffer[7] = 8'b0000_0000;
end
endtask

task GetDescriptor;
  input [2:0] des_type_new;
  input [2:0] des_index;
  input [15:0] des_size; 
begin
   XmitBuffer[0] = 8'b1000_0000;
   XmitBuffer[1] = 8'b0000_0110;
   XmitBuffer[2] = {5'b00000, des_index};
   XmitBuffer[3] = {5'b00000, des_type_new};
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = des_size[7:0];
   XmitBuffer[7] = des_size[15:8];
end
endtask

task SetDescriptor;
  input [2:0] des_type_new;
  input [2:0] des_index;
  input [15:0] des_size;
begin
   XmitBuffer[0] = 8'b0000_0000;
   XmitBuffer[1] = 8'b0000_0111;
   XmitBuffer[2] = {5'b00000, des_index};
   XmitBuffer[3] = {5'b00000, des_type_new};
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = des_size[7:0];
   XmitBuffer[7] = des_size[15:8];
end
endtask
 
task SynchFrame;
begin
   XmitBuffer[0] = 8'b1000_0010;
   XmitBuffer[1] = 8'b0000_1100;
   XmitBuffer[2] = 8'b0000_0000;
   XmitBuffer[3] = 8'b0000_0000;
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = 8'b0000_0000;
   XmitBuffer[7] = 8'b0000_0000;
end
endtask
 

task VenRegWordWr;
  input [6:0] address;
  input [31:0] reg_address;
  input [31:0] dataword;
begin
   XmitBuffer[0] = 8'b0100_0000;
   XmitBuffer[1] = 8'b0001_0000;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);

   XmitBuffer[0] = dataword[31:24];
   XmitBuffer[1] = dataword[23:16];
   XmitBuffer[2] = dataword[15:8];
   XmitBuffer[3] = dataword[7:0];

  control_OUT(address, 4'h0, 4, Status);
  status_IN (address, 4'h0, Status);
end
endtask

task VenRegWordRd;
  input [6:0] address;
  input [31:0] reg_address;
  output [31:0] dataword;
  reg  [31:0] ByteCount;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = 8'b0001_0001;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
    dataword[7:0]      = RecvBuffer[3];
    dataword[15:8]     = RecvBuffer[2];
    dataword[23:16]    = RecvBuffer[1];
    dataword[31:24]    = RecvBuffer[0];
    dump_recv_buffer(ByteCount);

   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegWordRdCmp;
  input [6:0] address;
  input [31:0] reg_address;
  input [31:0] dataword;
  output [31:0] ByteCount;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = 8'b0001_0001;
   XmitBuffer[2] = reg_address[31:24];
   XmitBuffer[3] = reg_address[23:16];
   XmitBuffer[4] = reg_address[15:8];
   XmitBuffer[5] = reg_address[7:0];
   XmitBuffer[6] = 8'b0000_0100;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[3] !== dataword[7:0]) || (RecvBuffer[2] !== dataword[15:8]) 
         || (RecvBuffer[1] !== dataword[23:16]) || (RecvBuffer[0] !== dataword[31:24]))
    begin
      -> tb.test_control.error_detected;
       $display( "usb_agent check: Register Read Byte Mismatch !!! Exp: %x ; Rxd: %x",dataword[31:0], {RecvBuffer[0],RecvBuffer[1], RecvBuffer[2],RecvBuffer[3]} );
       dump_recv_buffer(ByteCount);
    end

   status_OUT (address, 4'h0, Status);
end
endtask
task VenRegHalfWordRd;
  input [6:0] address;
  input [21:0] reg_address;
  input [15:0] dataword;
  output [31:0] ByteCount;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = 8'b0000_0010;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[0] !== dataword[7:0]) || (RecvBuffer[1] !== dataword[15:8])) 
    begin
       -> tb.test_control.error_detected;
       $display( "usb_agent check: Register Read Byte Mismatch !!!");
       dump_recv_buffer(ByteCount);
    end
   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegByteRd;
  input [6:0] address;
  input [21:0] reg_address;
  input [7:0] dataword;
  output [31:0] ByteCount;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = 8'b0000_0001;
   XmitBuffer[7] = 8'b0000_0000;

   setup (address, 4'h0, Status);
   control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if (Status != MYACK)
         control_IN(address, 4'h0, ByteCount, Status);
   if ((RecvBuffer[0] !== dataword[7:0]))
    begin
       -> tb.test_control.error_detected;
       $display( "usb_agent check: Register Read Byte Mismatch !!!");
       dump_recv_buffer(ByteCount);
    end
   status_OUT (address, 4'h0, Status);
end
endtask

task VenRegWr;
  input [21:0] reg_address;
  input [2:0]  length;
begin
   XmitBuffer[0] = 8'b0100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = {5'b0000_0,length};
   XmitBuffer[7] = 8'b0000_0000;   

end
endtask

task VenRegRd;
  input [21:0] reg_address;
  input [2:0]  length;
begin
   XmitBuffer[0] = 8'b1100_0000;
   XmitBuffer[1] = {2'b00,reg_address[21:16]};
   XmitBuffer[2] = reg_address[7:0];
   XmitBuffer[3] = reg_address[15:8];
   XmitBuffer[4] = 8'b0000_0000;
   XmitBuffer[5] = 8'b0000_0000;
   XmitBuffer[6] = {5'b0000_0,length};
   XmitBuffer[7] = 8'b0000_0000;   
end
endtask

task VenRegWrWordData;
  input [7:0] Byte0;
  input [7:0] Byte1;
  input [7:0] Byte2;
  input [7:0] Byte3;
begin
   XmitBuffer[0] = Byte0;        
   XmitBuffer[1] = Byte1;
   XmitBuffer[2] = Byte2;
   XmitBuffer[3] = Byte3;
end
endtask

task VenRegWrHWordData;
  input [7:0] Byte0;
  input [7:0] Byte1;
begin
   XmitBuffer[0] = Byte0;        
   XmitBuffer[1] = Byte1;
end
endtask

task VenRegWrByteData;
  input [7:0] Byte0;
begin
   XmitBuffer[0] = Byte0;        
end
endtask


/*****************************************/

    assign DPLS = zDPLS;
    assign DMNS = zDMNS;

    //instantiate the encoder
    usb_bfm_encoder u_usb_enc
               ( 
                 .enable_in         (enc_enbl),
                 .reset_n           (enc_reset_n),
                 .clk               (clk),
                 .bit_count_out     (enc_bit_count_out),
                 .count_out         (enc_count_out),
                 .data_out_valid    (enc_data_out_valid),
                 .gen_bit_stuff_err (BitStuffErr),
                 .last_byte         (enc_last_byte),
                 .start_bit         (DeviceSpeed),
                 .data_in           (enc_data_in),
                 .data_out          (DPLS),
                 .data_out_n        (DMNS)
               );

    //instantiate the decoder
    usb_bfm_decoder u_usb_dec
               ( 
                 .enable_in         (dec_enbl),
                 .ser_data_rdy      (dec_ser_data_rdy),
                 .par_data_rdy      (dec_par_data_rdy),
                 .reset_n           (dec_reset_n),
                 .clk               (dpll_clk),
                 .start_bit         (DeviceSpeed), // 1'b1),
                 .data_in           (DPLS),
                 .data_in_n         (DMNS),
                 .recv_bit_count    (dec_recv_bit_count),
                 .bit_stuff_err     (dec_bit_stuff_err),
                 .ser_data_out      (),
                 .par_data_out      (dec_par_data_out)
               );

    usb_bfm_dpll dpll_inst
               (
                 .clk48             (clk4x),
                 .clk6              (clk4x),
                 .switch            (~DeviceSpeed),
                 .reset_n           (dpll_reset_n),
                 .data_in           (DPLS),
                 .rec_clk           (dpll_clk),
                 .data_out          ()
               );


    always begin
        if (JitterOnOff == TRUE) begin
            if (tmpJitterCount > 0) begin
                #(PulseWidth - LowJitterTime) hs_clk = 1'b1;
                #(PulseWidth - HighJitterTime)  hs_clk = 1'b0;
                tmpJitterCount = tmpJitterCount - 1;
                if (tmpJitterCount == 0) begin
                    tmpJitterPeriod = JitterPeriod;
                end
            end
            else begin
                #PulseWidth hs_clk = 1'b1;
                #PulseWidth hs_clk = 1'b0;
                 if (tmpJitterPeriod == 0) begin
                    tmpJitterCount = JitterCount;
                 end
                 tmpJitterPeriod = tmpJitterPeriod - 1;
            end
        end
        else begin
            #PulseWidth hs_clk = 1'b1;
            #PulseWidth hs_clk = 1'b0;
        end
    end
 
    always begin
        if (JitterOnOff == TRUE) begin
            if (tmpJitterCount > 0) begin
                #((PulseWidth * 8) - LowJitterTime)   ls_clk = 1'b1;
                #((PulseWidth * 8) - HighJitterTime)  ls_clk = 1'b0;
                tmpJitterCount = tmpJitterCount - 1;
                if (tmpJitterCount == 0) begin
                    tmpJitterPeriod = JitterPeriod;
                end
            end
            else begin
                #(PulseWidth * 8) ls_clk = 1'b1;
                #(PulseWidth * 8) ls_clk = 1'b0;
                 if (tmpJitterPeriod == 0) begin
                    tmpJitterCount = JitterCount;
                 end
                 tmpJitterPeriod = tmpJitterPeriod - 1;
            end
        end
        else begin
            #(PulseWidth * 8) ls_clk = 1'b1;
            #(PulseWidth * 8) ls_clk = 1'b0;
        end
    end

    initial  // intialise pll clock signals
    begin
        tmpJitterPeriod = 0;
        tmpJitterCount  = 0;
        dpll_reset_n    = 1'b0;
        #1 dpll_reset_n = 1'b1;
    end

    initial  // drive 6 MHz clock
    begin
        clk6 = 1'b0;
        forever #(PulseWidth * 2) clk6 = ~clk6;
    end

    initial  // drive 48 MHz clock
    begin
        clk48 = 1'b0;
        HSClkComp = 1'b0;
        HSClkCompToggle = 1'b0;
        case ((PulseWidth) % 4)
        0 : HSClkComp = 1'b0;
        1 : HSClkComp = 1'b0;
        2 : HSClkComp = 1'b1;
        3 : HSClkComp = 1'b1;
        default : HSClkComp = 1'b0;
        endcase
        forever begin
            #((PulseWidth / 4) + HSClkComp) clk48 = 1'b1;
            case ((PulseWidth) % 4)
            0, 2 : begin
                      #(PulseWidth / 4) clk48 = 1'b0;
                      HSClkComp = ((PulseWidth % 4) == 0) ? 1'b0 : 1'b1;
                   end
            1, 3 : begin
                       if (HSClkCompToggle == 1'b0) begin
                           #(PulseWidth / 4) clk48 = 1'b0;
                           HSClkCompToggle = 1'b1;
                       end
                       else begin
                           #((PulseWidth / 4) + HSClkCompToggle) clk48 = 1'b0;
                           HSClkCompToggle = 1'b0;
                       end
                       HSClkComp = ((PulseWidth % 4) == 1) ? 1'b0 : 1'b1;
                   end
            default : clk48 = 1'b1;
            endcase
        end
    end

    always @(dpll_clk) rec_clk = dpll_clk;      
        
    //initialise the encoder signals
    initial 
    begin
        hs_clk      = 1'b1;
        ls_clk      = 1'b1;
        enc_enbl    = 1'b0;        // active high
        enc_reset_n = 1'b0;        // active low
        enc_data_in = 8'bZZZZZZZZ;
        zDPLS       = 1'bZ;
        zDMNS       = 1'bZ;
        dec_enbl    = 1'b0;        // active high
        dec_reset_n = 1'b0;        // active low
        // dec_cnt;
      // user_commands;             // Invoking the User Commands.
    end

initial
begin
`ifdef USBF_DEBUG
   Debug = TRUE ;
`else
   Debug = FALSE ;
`endif
sofOnFlag        = FALSE ;
//sofPeriod        = 1_000_000 ;
sofPeriod        = 100_000 ;
interruptOnFlag  = FALSE ;
interruptRequest = FALSE ;
interruptTimer   = 0 ;
interruptPeriod  = 0 ;
controlRequest   = FALSE ;
controlGrant     = FALSE ;
bulkInOnFlag      = FALSE ;
bulkOutOnFlag    = FALSE ;
end


endmodule


module usb_bfm_decoder( 
                enable_in,
                ser_data_rdy,
                par_data_rdy,
                reset_n,
                clk,
                start_bit,
                data_in,
                data_in_n,
                recv_bit_count,
                bit_stuff_err,
                ser_data_out,
                par_data_out
              );

input         enable_in;
output        ser_data_rdy;
output        par_data_rdy;
input         clk;
input         start_bit;
input         data_in;
input         data_in_n;
output [31:0] recv_bit_count;
output        bit_stuff_err;
output        ser_data_out;
output [7:0]  par_data_out;
input         reset_n;

reg           enable_out;
reg    [7:0]  par_data_out;
reg           ser_data_out;
reg           prev_bit;
reg           prev_bit1;
reg           tmpDataOut1;
reg    [7:0]  tmpDataOut;
reg    [31:0] recv_bit_count;
reg           bit_stuff_err;
reg           ser_data_rdy;
reg           par_data_rdy;
reg           JustEnabled;

reg    [3:0]  bit_count;
reg    [3:0]  count;
reg           SyncDetect;

initial begin
    enable_out     = 1;
    ser_data_out   = 1'bz;
    ser_data_rdy   = 1'b0;
    par_data_out   = 8'b0000_0000;
    bit_count      = 0;
    count          = 0;
    tmpDataOut     = 8'b00000000;
    tmpDataOut1    = 0;
    JustEnabled    = 1;
    par_data_rdy   = 1'b0;
    recv_bit_count = 32'h0000_0000;
    bit_stuff_err  = 1'b0;
end



always @(posedge clk) #1 prev_bit1 <= data_in;

always @(posedge clk) begin

    if (!reset_n) begin
        count <= 0;
        recv_bit_count <= 1'b0;
        bit_count <= 0;
        par_data_out  <= 8'b0000_0000; 
    end

    if (enable_in) begin
        if (count == 7 && !(bit_count==5 & (tmpDataOut1!=prev_bit))) begin
            par_data_rdy <= 1'b1;
        end
        if (bit_count < 5) begin
            if (count == 7) count <= 0;
            else count <= count + 1;
            par_data_out[count] <= tmpDataOut1;
            recv_bit_count <= recv_bit_count + 1;
            ser_data_rdy <= 1'b1;
            ser_data_out <= tmpDataOut1;
        end
        else begin
            if (tmpDataOut1 != 1'b0) begin
                bit_stuff_err <= 1'b1;
            end
            ser_data_rdy <= 1'b0;
        end
    end
    else begin
        bit_stuff_err <= 1'b0;  
        par_data_rdy  <= 1'b0;  
    end

    prev_bit <= tmpDataOut1;

    if ((tmpDataOut1 == prev_bit) & (tmpDataOut1 == 1'b1)) begin
        bit_count <= bit_count + 1;
    end
    else begin
        bit_count <= 0;
    end

    if (bit_count == 5) bit_count <= 0;

    if (prev_bit1 == data_in) tmpDataOut1 <= 1'b1;
    else tmpDataOut1 <= 1'b0;

    if (par_data_rdy == 1'b1) par_data_rdy <= 1'b0;

end


endmodule

module usb_bfm_encoder( enable_in,
                reset_n,
                clk,
                bit_count_out,
                count_out,
                data_out_valid,
                gen_bit_stuff_err,
                last_byte,
                start_bit,
                data_in,
                data_out,
                data_out_n
              );

//enable_in       : 0 disables the block
//                  1 enables the block
//data_in         : 8 bit wide register containing the parallel data
//clk             : Clock !!
//not used//data_in_valid   : the data in data_in is a valid next block of data
//count_out       : count[2]
//data_out        : serial data out
//data_out_n      : invert of data_out
//data_out_valid  : the data on data_out is valid and can be sampled
//reset_n         : synchronous reset of the block

input        enable_in;
input        clk;
input        gen_bit_stuff_err;
input  [7:0] data_in;
input        reset_n;
input        last_byte;
input        start_bit;

output [3:0] bit_count_out;
output       count_out;
output       data_out;
output       data_out_n;
output       data_out_valid;

reg    [3:0] bit_count_out;
reg          count_out;
reg          data_out;
reg          data_out_n;
reg          data_out_valid;
reg          tmpDataOut1;
reg          tmpDataOut2;
reg          prev_bit;
reg          tmpDataOut;

reg    [3:0] count;
reg    [3:0] bit_count;
reg    [7:0] tmpDataIn;

initial begin
    data_out       = 1'bZ;
    data_out_n     = 1'bZ;
    count          = 0;
    bit_count      = 0;
    bit_count_out  = 0;
    count_out      = 0;
    data_out_valid = 0;
    tmpDataOut1    = start_bit;
    tmpDataOut     = 0;
    prev_bit       = 0;
end

always @(posedge clk) begin
    if (enable_in) begin
        if (count == 0) tmpDataIn = data_in;
        if (count < 8) begin
            tmpDataOut = tmpDataIn[count];
            if ((tmpDataOut) & (prev_bit)) begin
                bit_count = bit_count + 1;
            end
            else begin
                if (tmpDataOut) bit_count = 1;
                else begin
                    if (bit_count == 6) bit_count = 7;
                    else bit_count = 0;
                end
            end
            if (bit_count == 7)  begin       
                if (gen_bit_stuff_err == 1'b0) begin 
                                                    
                    tmpDataOut1 = ~tmpDataOut1; 
                    prev_bit = 1'b0;
                end
                else begin
                    tmpDataOut1 = tmpDataOut1;
                    prev_bit = 1'b1;
                end
                bit_count = 0;
            end
            else begin
                if (tmpDataIn[count] == 0) tmpDataOut1 = ~tmpDataOut1;
                count = count + 1;
                prev_bit = tmpDataOut;
            end
            data_out = #1 tmpDataOut1;
            data_out_n = ~tmpDataOut1;
            data_out_valid = 1;
        end
        if (count == 8) count = 0;
        if (bit_count != 6) count_out = count[2];
        bit_count_out = count;
    end
    else begin
        data_out = #1 1'bz;
        data_out_n = 1'bz;
        data_out_valid = 0;
    end

    if (!reset_n) begin
        count          = 0;
        count_out      = 0;
        bit_count      = 0;
        data_out_valid = 0;
        tmpDataIn      = 8'h00;
        tmpDataOut1    = start_bit; 
        tmpDataOut     = 0;
        prev_bit       = 0;
        data_out       = #1 1'bz;
        data_out_n     = 1'bz;
    end
end

endmodule

module usb_bfm_dpll (clk48, clk6, switch, reset_n, data_in, rec_clk, data_out);

  input clk48, clk6, switch, reset_n, data_in;

  output rec_clk, data_out;
  
  wire rec_clk;
  wire data_out;
  wire nrz;
  wire dpll_clk;
 
  assign data_out = nrz;

  wire diff_pulse;

// Instance of the clock switch
  usb_bfm_clk_switch clk_switch     (.clk1    (clk48),
                             .clk2    (clk6),
                             .switch  (switch),
                             .reset_n (reset_n),
                             .clk_out (dpll_clk));

// Instance of NRZI to NRZ converter                             
  usb_bfm_nrzi2nrz nrzi2nrz_inst    (.nrzi    (data_in),
                             .rec_clk (rec_clk),
                             .reset_n (reset_n),
                             .nrz     (nrz));

// Instance of the phase detect 
  usb_bfm_ph_detect ph_detect       (.dpll_clk   (dpll_clk),
                             .rst_n      (reset_n),
                             .data_in    (data_in),
                             .rec_clk    (rec_clk),
                             .diff_pulse (diff_pulse));

// Instance of the pulse puller state machine
  usb_bfm_pulse_puller pulse_puller (.clk        (dpll_clk),
                             .diff_pulse (diff_pulse),
                             .rst_n      (reset_n),
                             .rec_clk    (rec_clk));

  endmodule 


// The clock switch module for selecting a low/high speed PLL
  
  module usb_bfm_clk_switch (clk1, clk2, switch, reset_n, clk_out);
 
  input  clk1, clk2, switch, reset_n;
  output clk_out;
 
  wire ff1set, ff1clr, ff3clr, clk_out;
  reg  ff1out, ff2out_bar, ff3out, ff3out_bar, ff4out_bar;
 
  assign ff1set  = ff4out_bar;
  assign ff1clr  = reset_n;
  assign ff3clr  = ff2out_bar;
  assign clk_out = ((ff1out | clk1) & (ff3out_bar | clk2));
 
  parameter LOW  = 1'b0;
  parameter HIGH = 1'b1;
 
//Filp Flop # 1
 
  always @ (posedge clk1 or negedge ff1set or negedge ff1clr) begin
 
    if (ff1clr === LOW) begin
       ff1out = LOW;
    end
    else if (ff1set === LOW) begin
       ff1out = HIGH;
    end
    else
       ff1out <= switch;
  end
 
//Flip Flop # 2
 
  always @ (posedge clk2) begin
    ff2out_bar <= (ff1out);
  end
 
//Flip Flop #3
 
  always @ (posedge clk2 or negedge ff3clr) begin
 
    if (ff3clr === LOW) begin
       ff3out     <= LOW;
       ff3out_bar <= HIGH;
    end
    else begin
       ff3out     <= switch;
       ff3out_bar <= !switch;
    end
  end
 
//Flip Flop #4
 
  always @ (posedge clk1) begin
    ff4out_bar <= ! (ff3out);
  end
 
  endmodule
 
// The NRZI to NRZ converter

  module usb_bfm_nrzi2nrz (nrzi, rec_clk, reset_n, nrz);
 
  input nrzi, rec_clk, reset_n;
  output nrz;
 
  wire nrz;
 
  wire D1, D2, D0;
  reg  Q1, Q2, Q0;
  reg del_rec_clk;
 
  assign D0   = nrzi;
  assign D1   = Q0;
  assign D2   = !(Q0^Q1);
  assign nrz = Q2;
 
//NRZI to NRZ converter
 
  always @ (reset_n) begin
    if (!reset_n) begin
      Q0 <= 1'b0;
      Q1 <= 1'b0;
      Q2 <= 1'b0;
    end
  end
 
  always @ (rec_clk) begin
     del_rec_clk <= #21 rec_clk;
  end
 
  always @(posedge del_rec_clk) begin
    Q0 <= D0;
    Q1 <= D1;
    Q2 <= D2;
  end
 
  endmodule

// The Phase detector
 
  module usb_bfm_ph_detect  (dpll_clk, rst_n, data_in, rec_clk, diff_pulse);
 
  input  dpll_clk, rst_n, data_in, rec_clk;
  output diff_pulse;
 
  wire diff_pulse;
 
  reg Q0;
  reg rec_clk_neg_edge;
  reg gate_control;
 
  assign diff_pulse = (Q0 ^ data_in) & gate_control;
 
  always @ (posedge dpll_clk or negedge rst_n) begin
    if (rst_n) begin
       if ((Q0 ^ data_in) & rec_clk_neg_edge) begin
         gate_control     <= 1'b0;
         rec_clk_neg_edge <= 1'b0;
       end
    end
    else begin
       gate_control     <= 1'b1;
       rec_clk_neg_edge <= 1'b0;
    end
    rec_clk_neg_edge <= 1'b0;
  end
 
  always @ (negedge rec_clk or negedge rst_n) begin
    if (rst_n) begin
      Q0               <= data_in;
      rec_clk_neg_edge <= 1'b1;
      gate_control     <= 1'b1;
    end
    else begin
       Q0 <= 1'b0;
    end
  end
  endmodule

// The State m/c which does the Phase Correction

  module usb_bfm_pulse_puller (clk, diff_pulse, rst_n, rec_clk);
 
  input clk, rst_n, diff_pulse;
  output rec_clk;
 
  reg rec_clk;
 
  reg [3:0] State;
 
  reg correct_pulse;
 
  reg Q0;
 
  parameter HIGH = 1'b1;
  parameter LOW  = 1'b0;
 
  parameter  S0 = 3'b000;
  parameter  S1 = 3'b001;
  parameter  S2 = 3'b010;
  parameter  S3 = 3'b011;
  parameter  S4 = 3'b100;
 
// Generation of the correcting pulse from the Phase difference between the
// data transition and negative edge of recovered clock
 
  always @ (posedge clk) begin
    Q0 <= diff_pulse;
    correct_pulse <= Q0 & diff_pulse;
  end
 
// The pulse_puller state machine
 
  always @ (posedge clk or negedge rst_n) begin
 
  if (!rst_n) begin
    State   <= S0;
    rec_clk <= LOW;
  end
  else begin
 
    case (State)
 
    S0  :  begin
             State   <= S1;
             rec_clk <= ~rec_clk;
           end
 
    S1  :  if (correct_pulse) begin
              rec_clk <= ~rec_clk;
              State   <= S3;
           end
           else begin
              rec_clk <= rec_clk;
              State   <= S2;
           end

    S2  :  begin
             if (correct_pulse) begin
                State   <= S4;
             end
             else begin
                State   <= S3;
             end
             rec_clk <= ~rec_clk;
           end
 
    S3  :  if (correct_pulse) begin
              State   <= S1;
              rec_clk <= ~rec_clk;
           end
           else begin
              rec_clk <= rec_clk;
              State   <= S4;
           end
 
    S4  :  begin
             if (correct_pulse) begin
               State <= S2;
             end
             else begin
               State <= S1;
             end
             rec_clk <= ~rec_clk;
           end
 
    default  :
$display ("Illegal State at ",$time);
 
    endcase
  end
  end
 
  endmodule


