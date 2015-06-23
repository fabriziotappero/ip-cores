
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
`define TGLQV_27              0
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
