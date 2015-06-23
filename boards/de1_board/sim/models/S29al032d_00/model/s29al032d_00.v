//////////////////////////////////////////////////////////////////////////////
//  File name : s29al032d_00.v
//////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2005 Spansion, LLC.
//
// MODIFICATION HISTORY :
//
//
//  version:   | author:        | mod date: | changes made:
//    V1.0       D.Lukovic       05 May 17    Initial release
//   
//////////////////////////////////////////////////////////////////////////////
//
//  PART DESCRIPTION:
//
//  Library:        FLASH
//  Technology:     Flash memory
//  Part:           s29al032d_00
//
//  Description:    32Mbit (4M x 8-Bit)  Flash Memory
//
//
//
///////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns/1 ns

module s29al032d_00
(
    A21      ,
    A20      ,
    A19      ,
    A18      ,
    A17      ,
    A16      ,
    A15      ,
    A14      ,
    A13      ,
    A12      ,
    A11      ,
    A10      ,
    A9       ,
    A8       ,
    A7       ,
    A6       ,
    A5       ,
    A4       ,
    A3       ,
    A2       ,
    A1       ,
    A0       ,

    DQ7      ,
    DQ6      ,
    DQ5      ,
    DQ4      ,
    DQ3      ,
    DQ2      ,
    DQ1      ,
    DQ0      ,

    CENeg    ,
    OENeg    ,
    WENeg    ,
    RESETNeg ,
    ACC      ,
    RY

);

////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
////////////////////////////////////////////////////////////////////////

    input  A21  ;
    input  A20  ;
    input  A19  ;
    input  A18  ;
    input  A17  ;
    input  A16  ;
    input  A15  ;
    input  A14  ;
    input  A13  ;
    input  A12  ;
    input  A11  ;
    input  A10  ;
    input  A9   ;
    input  A8   ;
    input  A7   ;
    input  A6   ;
    input  A5   ;
    input  A4   ;
    input  A3   ;
    input  A2   ;
    input  A1   ;
    input  A0   ;

    inout  DQ7   ;
    inout  DQ6   ;
    inout  DQ5   ;
    inout  DQ4   ;
    inout  DQ3   ;
    inout  DQ2   ;
    inout  DQ1   ;
    inout  DQ0   ;

    input  CENeg    ;
    input  OENeg    ;
    input  WENeg    ;
    input  RESETNeg ;
    input  ACC      ;
    output RY       ;

// interconnect path delay signals

    wire  A21_ipd  ;
    wire  A20_ipd  ;
    wire  A19_ipd  ;
    wire  A18_ipd  ;
    wire  A17_ipd  ;
    wire  A16_ipd  ;
    wire  A15_ipd  ;
    wire  A14_ipd  ;
    wire  A13_ipd  ;
    wire  A12_ipd  ;
    wire  A11_ipd  ;
    wire  A10_ipd  ;
    wire  A9_ipd   ;
    wire  A8_ipd   ;
    wire  A7_ipd   ;
    wire  A6_ipd   ;
    wire  A5_ipd   ;
    wire  A4_ipd   ;
    wire  A3_ipd   ;
    wire  A2_ipd   ;
    wire  A1_ipd   ;
    wire  A0_ipd   ;

    wire [21 : 0] A;
    assign A = {
                A21_ipd,
                A20_ipd,
                A19_ipd,
                A18_ipd,
                A17_ipd,
                A16_ipd,
                A15_ipd,
                A14_ipd,
                A13_ipd,
                A12_ipd,
                A11_ipd,
                A10_ipd,
                A9_ipd,
                A8_ipd,
                A7_ipd,
                A6_ipd,
                A5_ipd,
                A4_ipd,
                A3_ipd,
                A2_ipd,
                A1_ipd,
                A0_ipd };

    wire  DQ7_ipd   ;
    wire  DQ6_ipd   ;
    wire  DQ5_ipd   ;
    wire  DQ4_ipd   ;
    wire  DQ3_ipd   ;
    wire  DQ2_ipd   ;
    wire  DQ1_ipd   ;
    wire  DQ0_ipd   ;

    wire [7 : 0 ] DIn;
    assign DIn = {DQ7_ipd,
                  DQ6_ipd,
                  DQ5_ipd,
                  DQ4_ipd,
                  DQ3_ipd,
                  DQ2_ipd,
                  DQ1_ipd,
                  DQ0_ipd };

    wire [7 : 0 ] DOut;
    assign DOut = {DQ7,
                  DQ6,
                  DQ5,
                  DQ4,
                  DQ3,
                  DQ2,
                  DQ1,
                  DQ0 };

    wire  CENeg_ipd    ;
    wire  OENeg_ipd    ;
    wire  WENeg_ipd    ;
    wire  RESETNeg_ipd ;
    wire  ACC_ipd      ;
    wire  VIO_ipd      ;

//  internal delays

    reg HANG_out    ; // Program/Erase Timing Limit
    reg HANG_in     ;
    reg START_T1    ; // Start TimeOut
    reg START_T1_in ;
    reg CTMOUT      ; // Sector Erase TimeOut
    reg CTMOUT_in   ;
    reg READY_in    ;
    reg READY       ; // Device ready after reset

    reg [7 : 0] DOut_zd;
    wire  DQ7_Pass   ;
    wire  DQ6_Pass   ;
    wire  DQ5_Pass   ;
    wire  DQ4_Pass   ;
    wire  DQ3_Pass   ;
    wire  DQ2_Pass   ;
    wire  DQ1_Pass   ;
    wire  DQ0_Pass   ;

    reg [7 : 0] DOut_Pass;
    assign {DQ7_Pass,
            DQ6_Pass,
            DQ5_Pass,
            DQ4_Pass,
            DQ3_Pass,
            DQ2_Pass,
            DQ1_Pass,
            DQ0_Pass  } = DOut_Pass;

    reg RY_zd;

    parameter UserPreload     = 1'b0;
    parameter mem_file_name   = "none";
    parameter prot_file_name  = "none";
    parameter secsi_file_name = "none";

    parameter TimingModel = "DefaultTimingModel";

    parameter DelayValues = "FROM_PLI";
    parameter PartID    = "s29al032d";
    parameter MaxData   = 255;
    parameter SecSize   = 65535;
    parameter SecNum    = 63;
    parameter HiAddrBit = 21;
    parameter SecSiSize = 255;

    // powerup
    reg PoweredUp;

    //FSM control signals
    reg ULBYPASS ; ////Unlock Bypass Active
    reg ESP_ACT  ; ////Erase Suspend
    reg OTP_ACT  ; ////SecSi Access

    reg PDONE    ; ////Prog. Done
    reg PSTART   ; ////Start Programming
    //Program location is in protected sector
    reg PERR     ;

    reg EDONE    ; ////Ers. Done
    reg ESTART   ; ////Start Erase
    reg ESUSP    ; ////Suspend Erase
    reg ERES     ; ////Resume Erase
    //All sectors selected for erasure are protected
    reg EERR     ;

    //Sectors selected for erasure
    reg [SecNum:0] Ers_queue; // = SecNum'b0;

    //Command Register
    reg write ;
    reg read  ;

    //Sector Address
    integer SecAddr = 0;

    integer SA      = 0;

    //Address within sector
    integer Address = 0;
    integer MemAddress = 0;
    integer SecSiAddr = 0;
    
    integer AS_ID = 0;
    integer AS_SecSi_FP = 0;
    integer AS_ID2 = 0;
    //A19:A11 Don't Care
    integer Addr ;

    //glitch protection
    wire gWE_n ;
    wire gCE_n ;
    wire gOE_n ;

    reg RST ;
    reg reseted ;

    integer Mem[0:(SecNum+1)*(SecSize+1)-1];
    //Sector Protection Status
    reg [SecNum:0] Sec_Prot;

    // timing check violation
    reg Viol = 1'b0;
    // CFI query address
    integer SecSi[0:SecSiSize];
    integer CFI_array[16:79];

    reg FactoryProt = 0;

    integer WBData;
    integer WBAddr;

    reg oe = 1'b0;
    event oe_event;

    event initOK;
    event MergeE;

    //Status reg.
    reg[15:0] Status = 8'b0;

    reg[7:0]  old_bit, new_bit;
    integer old_int, new_int;
    integer wr_cnt;
    reg[7:0] temp;

    integer S_ind = 0;
    integer ind   = 0;

    integer i,j,k;

    integer Debug;

    //TPD_XX_DATA
    time OEDQ_t;
    time CEDQ_t;
    time ADDRDQ_t;
    time OENeg_event;
    time CENeg_event;
    time OENeg_posEvent;
    time CENeg_posEvent;
    time ADDR_event;
    reg FROMOE;
    reg FROMCE;
    reg FROMADDR;
    integer   OEDQ_01;
    integer   CEDQ_01;
    integer   ADDRDQ_01;

    reg[7:0] TempData;

///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////
    buf   (A21_ipd, A21);
    buf   (A20_ipd, A20);
    buf   (A19_ipd, A19);
    buf   (A18_ipd, A18);
    buf   (A17_ipd, A17);
    buf   (A16_ipd, A16);
    buf   (A15_ipd, A15);
    buf   (A14_ipd, A14);
    buf   (A13_ipd, A13);
    buf   (A12_ipd, A12);
    buf   (A11_ipd, A11);
    buf   (A10_ipd, A10);
    buf   (A9_ipd , A9 );
    buf   (A8_ipd , A8 );
    buf   (A7_ipd , A7 );
    buf   (A6_ipd , A6 );
    buf   (A5_ipd , A5 );
    buf   (A4_ipd , A4 );
    buf   (A3_ipd , A3 );
    buf   (A2_ipd , A2 );
    buf   (A1_ipd , A1 );
    buf   (A0_ipd , A0 );

    buf   (DQ7_ipd , DQ7 );
    buf   (DQ6_ipd , DQ6 );
    buf   (DQ5_ipd , DQ5 );
    buf   (DQ4_ipd , DQ4 );
    buf   (DQ3_ipd , DQ3 );
    buf   (DQ2_ipd , DQ2 );
    buf   (DQ1_ipd , DQ1 );
    buf   (DQ0_ipd , DQ0 );

    buf   (CENeg_ipd    , CENeg    );
    buf   (OENeg_ipd    , OENeg    );
    buf   (WENeg_ipd    , WENeg    );
    buf   (RESETNeg_ipd , RESETNeg );
    buf   (ACC_ipd      , ACC      );
///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (DQ7 ,   DQ7_Pass  , 1);
    nmos   (DQ6 ,   DQ6_Pass  , 1);
    nmos   (DQ5 ,   DQ5_Pass  , 1);
    nmos   (DQ4 ,   DQ4_Pass  , 1);
    nmos   (DQ3 ,   DQ3_Pass  , 1);
    nmos   (DQ2 ,   DQ2_Pass  , 1);
    nmos   (DQ1 ,   DQ1_Pass  , 1);
    nmos   (DQ0 ,   DQ0_Pass  , 1);
    nmos   (RY  ,   1'b0      , ~RY_zd);

    wire deg;

    //VHDL VITAL CheckEnable equivalents
    // Address setup/hold near WE# falling edge
    wire   CheckEnable_A0_WE;
    assign CheckEnable_A0_WE  = ~CENeg && OENeg;
    // Data setup/hold near WE# rising edge
    wire   CheckEnable_DQ0_WE;
    assign CheckEnable_DQ0_WE = ~CENeg && OENeg && deg;
    // Address setup/hold near CE# falling edge
    wire   CheckEnable_A0_CE;
    assign CheckEnable_A0_CE  = ~WENeg && OENeg;
    // Data setup/hold near CE# rising edge
    wire   CheckEnable_DQ0_CE;
    assign CheckEnable_DQ0_CE = ~WENeg && OENeg && deg;

specify

    // tipd delays: interconnect path delays , mapped to input port delays.
    // In Verilog is not necessary to declare any tipd_ delay variables,
    // they can be taken from SDF file
    // With all the other delays real delays would be taken from SDF file

    // tpd delays
    specparam           tpd_RESETNeg_DQ0        =1;
    specparam           tpd_A0_DQ0              =1;//tacc ok
    specparam           tpd_CENeg_DQ0           =1;//ok
                      //(tCE,tCE,tDF,-,tDF,-)
    specparam           tpd_OENeg_DQ0           =1;//ok
                      //(tOE,tOE,tDF,-,tDF,-)
    specparam           tpd_WENeg_RY            =1;    //tBUSY
    specparam           tpd_CENeg_RY            =1;    //tBUSY

    // tsetup values: setup time
    specparam           tsetup_A0_WENeg         =1;   //tAS edge \
    specparam           tsetup_DQ0_WENeg        =1;   //tDS edge /

    // thold values: hold times
    specparam           thold_A0_WENeg          =1; //tAH  edge \
    specparam           thold_DQ0_CENeg         =1; //tDH edge /
    specparam           thold_OENeg_WENeg       =1; //tOEH edge /
    specparam           thold_CENeg_RESETNeg    =1; //tRH  edge /
    specparam           thold_WENeg_OENeg       =1; //tGHVL edge /

    // tpw values: pulse width
    specparam           tpw_RESETNeg_negedge    =1; //tRP
    specparam           tpw_WENeg_negedge       =1; //tWP
    specparam           tpw_WENeg_posedge       =1; //tWPH
    specparam           tpw_CENeg_negedge       =1; //tCP
    specparam           tpw_CENeg_posedge       =1; //tCEPH
    specparam           tpw_A0_negedge          =1; //tWC tRC ok
    specparam           tpw_A0_posedge          =1; //tWC tRC ok 
     
    // tdevice values: values for internal delays
            //Program Operation
    specparam   tdevice_POB                     = 9000; //9 us;
           //Sector Erase Operation
    specparam   tdevice_SEO                     = 700000000; //700 ms;
           //Timing Limit Exceeded
    specparam   tdevice_HANG                    = 400000000; //400 ms;
           //Erase suspend time
    specparam   tdevice_START_T1                = 20000; //20 us;
           //sector erase command sequence timeout
    specparam   tdevice_CTMOUT                  = 50000; //50 us;
           //device ready after Hardware reset(during embeded algorithm)
    specparam   tdevice_READY                   = 20000; //20 us; //tReady

    // If tpd values are fetched from specify block, these parameters
    // must change along with SDF values, SDF values change will NOT
    // imlicitly apply here !
    // If you want tpd values to be fetched by the model itself, please
    // use the PLI routine approach but be shure to set parameter
    // DelayValues to "FROM_PLI" as default

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////
//for DQ signals
    if (FROMCE)
        ( CENeg => DQ0 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ1 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ2 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ3 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ4 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ5 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ6 ) = tpd_CENeg_DQ0;
    if (FROMCE)
        ( CENeg => DQ7 ) = tpd_CENeg_DQ0;

    if (FROMOE)
        ( OENeg => DQ0 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ1 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ2 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ3 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ4 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ5 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ6 ) = tpd_OENeg_DQ0;
    if (FROMOE)
        ( OENeg => DQ7 ) = tpd_OENeg_DQ0;

    if (FROMADDR)
        ( A0 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A0 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A1 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A2 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A3 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A4 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A5 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A6 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A7 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A8 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A9 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A10 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A11 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A12 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A13 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A14 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A15 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A16 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A17 => DQ7 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A18 => DQ7 ) = tpd_A0_DQ0;

    if (FROMADDR)
        ( A19 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A19 => DQ7 ) = tpd_A0_DQ0;

    if (FROMADDR)
        ( A20 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A20 => DQ7 ) = tpd_A0_DQ0;

    if (FROMADDR)
        ( A21 => DQ0 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ1 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ2 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ3 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ4 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ5 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ6 ) = tpd_A0_DQ0;
    if (FROMADDR)
        ( A21 => DQ7 ) = tpd_A0_DQ0;

    if (~RESETNeg)
        ( RESETNeg => DQ0 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ1 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ2 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ3 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ4 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ5 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ6 ) = tpd_RESETNeg_DQ0;
    if (~RESETNeg)
        ( RESETNeg => DQ7 ) = tpd_RESETNeg_DQ0;

//for RY signal
  (WENeg => RY)     = tpd_WENeg_RY;
  (CENeg => RY)     = tpd_CENeg_RY;

////////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                           //
////////////////////////////////////////////////////////////////////////////////

    $setup ( A0 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A1 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A2 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A3 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A4 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A5 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A6 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A7 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A8 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A9 , negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A10, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A11, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A12, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A13, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A14, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A15, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A16, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A17, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A18, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A19, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A20, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);
    $setup ( A21, negedge CENeg &&& CheckEnable_A0_CE, tsetup_A0_WENeg, Viol);

    $setup ( A0 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A1 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A2 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A3 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A4 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A5 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A6 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A7 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A8 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A9 , negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A10, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A11, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A12, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A13, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A14, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A15, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A16, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A17, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A18, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A19, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A20, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);
    $setup ( A21, negedge WENeg &&& CheckEnable_A0_WE, tsetup_A0_WENeg, Viol);

    $setup ( DQ0, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ1, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ2, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ3, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ4, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ5, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ6, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ7, posedge CENeg&&&CheckEnable_DQ0_CE, tsetup_DQ0_WENeg, Viol);

    $setup ( DQ0, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ1, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ2, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ3, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ4, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ5, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ6, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);
    $setup ( DQ7, posedge WENeg&&&CheckEnable_DQ0_WE, tsetup_DQ0_WENeg, Viol);

    $hold ( posedge RESETNeg&&&(CENeg===1), CENeg, thold_CENeg_RESETNeg, Viol);
    $hold ( posedge RESETNeg&&&(OENeg===1), OENeg, thold_CENeg_RESETNeg, Viol);
    $hold ( posedge RESETNeg&&&(WENeg===1), WENeg, thold_CENeg_RESETNeg, Viol);
    $hold ( posedge OENeg, WENeg, thold_WENeg_OENeg, Viol);
    $hold ( posedge WENeg, OENeg, thold_OENeg_WENeg, Viol);

    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A0 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A1 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A2 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A3 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A4 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A5 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A6 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A7 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A9 ,  thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A10 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A11 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A12 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A13 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A14 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A15 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A16 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A17 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A18 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A19 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A20 , thold_A0_WENeg, Viol);
    $hold ( negedge CENeg &&& CheckEnable_A0_CE, A21 , thold_A0_WENeg, Viol);

    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A0 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A1 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A2 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A3 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A4 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A5 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A6 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A7 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A8 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A9 ,  thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A10 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A11 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A12 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A13 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A14 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A15 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A16 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A17 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A18 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A19 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A20 , thold_A0_WENeg, Viol);
    $hold ( negedge WENeg &&& CheckEnable_A0_WE, A21 , thold_A0_WENeg, Viol);

    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ0, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ1, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ2, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ3, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ4, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ5, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ6, thold_DQ0_CENeg, Viol);
    $hold ( posedge CENeg &&& CheckEnable_DQ0_CE, DQ7, thold_DQ0_CENeg, Viol);

    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ0, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ1, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ2, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ3, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ4, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ5, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ6, thold_DQ0_CENeg, Viol);
    $hold ( posedge WENeg &&& CheckEnable_DQ0_WE, DQ7, thold_DQ0_CENeg, Viol);

    $width (negedge RESETNeg, tpw_RESETNeg_negedge);
    $width (posedge WENeg,    tpw_WENeg_posedge);
    $width (negedge WENeg,    tpw_WENeg_negedge);
    $width (posedge CENeg,    tpw_CENeg_posedge);
    $width (negedge CENeg,    tpw_CENeg_negedge);
    $width (negedge A0,       tpw_A0_negedge);//ok
    $width (negedge A1,       tpw_A0_negedge);//ok
    $width (negedge A2,       tpw_A0_negedge);//ok
    $width (negedge A3,       tpw_A0_negedge);//ok
    $width (negedge A4,       tpw_A0_negedge);//ok
    $width (negedge A5,       tpw_A0_negedge);//ok
    $width (negedge A6,       tpw_A0_negedge);//ok
    $width (negedge A7,       tpw_A0_negedge);//ok
    $width (negedge A8,       tpw_A0_negedge);//ok
    $width (negedge A9,       tpw_A0_negedge);//ok
    $width (negedge A10,       tpw_A0_negedge);//ok
    $width (negedge A11,       tpw_A0_negedge);//ok
    $width (negedge A12,       tpw_A0_negedge);//ok
    $width (negedge A13,       tpw_A0_negedge);//ok
    $width (negedge A14,       tpw_A0_negedge);//ok
    $width (negedge A15,       tpw_A0_negedge);//ok
    $width (negedge A16,       tpw_A0_negedge);//ok
    $width (negedge A17,       tpw_A0_negedge);//ok
    $width (negedge A18,       tpw_A0_negedge);//ok
    $width (negedge A19,       tpw_A0_negedge);//ok
    $width (negedge A20,       tpw_A0_negedge);//ok
    $width (negedge A21,       tpw_A0_negedge);//ok
    $width (posedge A0,       tpw_A0_posedge);//ok
    $width (posedge A1,       tpw_A0_posedge);//ok
    $width (posedge A2,       tpw_A0_posedge);//ok
    $width (posedge A3,       tpw_A0_posedge);//ok
    $width (posedge A4,       tpw_A0_posedge);//ok
    $width (posedge A5,       tpw_A0_posedge);//ok
    $width (posedge A6,       tpw_A0_posedge);//ok
    $width (posedge A7,       tpw_A0_posedge);//ok
    $width (posedge A8,       tpw_A0_posedge);//ok
    $width (posedge A9,       tpw_A0_posedge);//ok
    $width (posedge A10,       tpw_A0_posedge);//ok
    $width (posedge A11,       tpw_A0_posedge);//ok
    $width (posedge A12,       tpw_A0_posedge);//ok
    $width (posedge A13,       tpw_A0_posedge);//ok
    $width (posedge A14,       tpw_A0_posedge);//ok
    $width (posedge A15,       tpw_A0_posedge);//ok
    $width (posedge A16,       tpw_A0_posedge);//ok
    $width (posedge A17,       tpw_A0_posedge);//ok
    $width (posedge A18,       tpw_A0_posedge);//ok
    $width (posedge A19,       tpw_A0_posedge);//ok
    $width (posedge A20,       tpw_A0_posedge);//ok
    $width (posedge A21,       tpw_A0_posedge);//ok
    
    endspecify

////////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                        //
////////////////////////////////////////////////////////////////////////////////

// FSM states
    parameter RESET               =6'd0;
    parameter Z001                =6'd1;
    parameter PREL_SETBWB         =6'd2;
    parameter PREL_ULBYPASS       =6'd3;
    parameter PREL_ULBYPASS_RESET =6'd4;
    parameter AS                  =6'd5;
    parameter A0SEEN              =6'd6;
    parameter OTP                 =6'd7;
    parameter OTP_Z001            =6'd8;
    parameter OTP_PREL            =6'd9;
    parameter OTP_AS              =6'd10;
    parameter OTP_AS_CFI          =6'd11;
    parameter OTP_A0SEEN          =6'd12;
    parameter C8                  =6'd13;
    parameter C8_Z001             =6'd14;
    parameter C8_PREL             =6'd15;
    parameter ERS                 =6'd16;
    parameter SERS                =6'd17;
    parameter ESPS                =6'd18;
    parameter SERS_EXEC           =6'd19;
    parameter ESP                 =6'd20;
    parameter ESP_Z001            =6'd21;
    parameter ESP_PREL            =6'd22;
    parameter ESP_A0SEEN          =6'd23;
    parameter ESP_AS              =6'd24;
    parameter PGMS                =6'd25;
    parameter CFI                 =6'd26;
    parameter AS_CFI              =6'd27;
    parameter ESP_CFI             =6'd28;
    parameter ESP_AS_CFI          =6'd29;

    reg [5:0] current_state;
    reg [5:0] next_state;

 reg deq;

    always @(DIn, DOut)
    begin
        if (DIn==DOut)
            deq=1'b1;
        else
            deq=1'b0;
    end
    // check when data is generated from model to avoid setuphold check in
    // those occasion
    assign deg =deq;

// initialize memory and load preoload files if any
    initial
    begin : NBlck
    integer i,j;
    integer tmp1,tmp2,tmp3;
    integer secure_silicon[0:SecSiSize];
    reg     sector_prot[0:SecNum];

        for (i=0;i<=((SecNum+1)*(SecSize+1)-1);i=i+1)
        begin
            Mem[i]=MaxData;
        end
        for (i=0;i<=SecSiSize;i=i+1)
        begin
           secure_silicon[i]=MaxData;
        end
        for (i=0;i<=SecNum;i=i+1)
        begin
           sector_prot[i]=0;
        end
        if (UserPreload && !(prot_file_name == "none"))
        begin
            //s29al032d_00_prot  sector protect file
            //   //      - comment
            //   @aa    - <aa> stands for sector address
            //   (aa is incremented at every load)
            //   b       - <b> is 1 for protected sector <aa>, 0 for unprotect.
            $readmemb(prot_file_name,sector_prot);
        end
        if (UserPreload && !(mem_file_name == "none"))
        begin
            //s29al032d_00_memory preload file
            //  @aaaaaa - <aaaaaa> stands for address within last defined sector
            //  dd      - <dd> is byte to be written at Mem(nn)(aaaaaa++)
            // (aaaaaa is incremented at every load)
            $readmemh(mem_file_name,Mem);
        end
        if (UserPreload && !(secsi_file_name == "none"))
        begin
            //s29al032d_00_secsi memory preload file
            //  @aaaa   - <aaaa> stands for address within last defined sector
            //  dd      - <dd> is byte to be written at Mem(nn)(aaaa++)
            // (aaaa is incremented at every load)
            $readmemh(secsi_file_name,secure_silicon);
        end

        for (i=0;i<=SecSiSize;i=i+1)
        begin
           SecSi[i] = secure_silicon[i];
        end
        for (i=0;i<=SecNum;i=i+1)
            Ers_queue[i] = 0;
        // every 4-group sectors protect bit must equel
        for (i=0;i<=SecNum;i=i+1)
            Sec_Prot[i] = sector_prot[i];

        if ((Sec_Prot[3:0] != 4'h0 && Sec_Prot[3:0] != 4'hF)
        || (Sec_Prot[7:4] != 4'h0 && Sec_Prot[7:4] != 4'hF)
        || (Sec_Prot[11:8] != 4'h0 && Sec_Prot[11:8] != 4'hF)
        || (Sec_Prot[15:12] != 4'h0   && Sec_Prot[15:12] != 4'hF)
        || (Sec_Prot[19:16] != 4'h0   && Sec_Prot[19:16] != 4'hF)
        || (Sec_Prot[23:20] != 4'h0   && Sec_Prot[23:20] != 4'hF)
        || (Sec_Prot[27:24] != 4'h0   && Sec_Prot[27:24] != 4'hF)
        || (Sec_Prot[31:28] != 4'h0   && Sec_Prot[31:28] != 4'hF)
        || (Sec_Prot[35:32] != 4'h0   && Sec_Prot[35:32] != 4'hF)
        || (Sec_Prot[39:36] != 4'h0   && Sec_Prot[39:36] != 4'hF)
        || (Sec_Prot[43:40] != 4'h0   && Sec_Prot[43:40] != 4'hF)
        || (Sec_Prot[47:44] != 4'h0   && Sec_Prot[47:44] != 4'hF)
        || (Sec_Prot[51:48] != 4'h0   && Sec_Prot[51:48] != 4'hF)
        || (Sec_Prot[55:52] != 4'h0   && Sec_Prot[55:52] != 4'hF)
        || (Sec_Prot[59:56] != 4'h0   && Sec_Prot[59:56] != 4'hF)
        || (Sec_Prot[63:60] != 4'h0   && Sec_Prot[63:60] != 4'hF))

            $display("Bad sector protect group preload");

        WBData = -1;

    end

    //Power Up time 100 ns;
    initial
    begin
        PoweredUp      = 1'b0;
        #100 PoweredUp = 1'b1;
    end

    always @(RESETNeg)
    begin
        RST <= #499 RESETNeg;
    end

    initial
    begin
        write    = 1'b0;
        read     = 1'b0;
        Addr   = 0;

        ULBYPASS = 1'b0;
        ESP_ACT  = 1'b0;
        OTP_ACT  = 1'b0;

        PDONE    = 1'b1;
        PSTART   = 1'b0;

        PERR     = 1'b0;

        EDONE    = 1'b1;
        ESTART   = 1'b0;
        ESUSP    = 1'b0;
        ERES     = 1'b0;

        EERR     = 1'b0;
        READY_in = 1'b0;
        READY    = 1'b0;
    end

    always @(posedge START_T1_in)
    begin:TESTARTT1r
        #tdevice_START_T1 START_T1 = START_T1_in;
    end
    always @(negedge START_T1_in)
    begin:TESTARTT1f
        #1 START_T1 = START_T1_in;
    end

    always @(posedge CTMOUT_in)
    begin:TCTMOUTr
        #tdevice_CTMOUT CTMOUT = CTMOUT_in;
    end
    always @(negedge CTMOUT_in)
    begin:TCTMOUTf
        #1 CTMOUT = CTMOUT_in;
    end

    always @(posedge READY_in)
    begin:TREADYr
        #tdevice_READY READY = READY_in;
    end
    always @(negedge READY_in)
    begin:TREADYf
        #1 READY = READY_in;
    end
    ////////////////////////////////////////////////////////////////////////////
    ////     obtain 'LAST_EVENT information
    ////////////////////////////////////////////////////////////////////////////
    always @(negedge OENeg)
    begin
        OENeg_event = $time;
    end
    always @(negedge CENeg)
    begin
        CENeg_event = $time;
    end

    always @(posedge OENeg)
    begin
        OENeg_posEvent = $time;
    end
    always @(posedge CENeg)
    begin
        CENeg_posEvent = $time;
    end

    always @(A)
    begin
        ADDR_event = $time;
    end

    ////////////////////////////////////////////////////////////////////////////
    //// sequential process for reset control and FSM state transition
    ////////////////////////////////////////////////////////////////////////////
    always @(negedge RST)
    begin
        ESP_ACT = 1'b0;
        ULBYPASS = 1'b0;
        OTP_ACT = 1'b0;
    end

    reg R;
    reg E;
    always @(RESETNeg)
    begin
        if (PoweredUp)
        begin
        //Hardware reset timing control
            if (~RESETNeg)
            begin
                E = 1'b0;
                if (~PDONE || ~EDONE)
                begin
                    //if program or erase in progress
                    READY_in = 1'b1;
                    R = 1'b1;
                end
                else
                begin
                    READY_in = 1'b0;
                    R = 1'b0;         //prog or erase not in progress
                end
            end
            else if (RESETNeg && RST)
            begin
                //RESET# pulse < tRP
                READY_in = 1'b0;
                R = 1'b0;
                E = 1'b1;
            end
         end
    end

    always @(next_state or RESETNeg or CENeg or RST or
         READY or PoweredUp)
    begin: StateTransition

        if (PoweredUp)
        begin
            if (RESETNeg && (~R || (R && READY)))
            begin
                current_state = next_state;
                READY_in = 1'b0;
                E = 1'b0;
                R = 1'b0;
                reseted = 1'b1;
            end
            else if ((~R && ~RESETNeg && ~RST) ||
                  (R && ~RESETNeg && ~RST && ~READY) ||
                  (R && RESETNeg && ~RST && ~READY))
            begin
                //no state transition while RESET# low
                current_state = RESET; //reset start
                reseted       = 1'b0;
            end
        end
        else
        begin
            current_state = RESET;      // reset
            reseted       = 1'b0;
            E = 1'b0;
            R = 1'b0;
        end
    end

//    /////////////////////////////////////////////////////////////////////////
//    //Glitch Protection: Inertial Delay does not propagate pulses <5ns
//    /////////////////////////////////////////////////////////////////////////
    assign #5 gWE_n = WENeg_ipd;
    assign #5 gCE_n = CENeg_ipd;
    assign #5 gOE_n = OENeg_ipd;

    ///////////////////////////////////////////////////////////////////////////
    //Process that reports warning when changes on signals WE#, CE#, OE# are
    //discarded
    ///////////////////////////////////////////////////////////////////////////
    always @(WENeg)
    begin: PulseWatch1
        if (gWE_n == WENeg)
           $display("Glitch on WE#");
    end
    always @(CENeg)
    begin: PulseWatch2
        if (gCE_n == CENeg)
            $display("Glitch on CE#");
    end
    always @(OENeg)
    begin: PulseWatch3
        if (gOE_n == OENeg)
            $display("Glitch on OE#");
     end

    //latch address on rising edge and data on falling edge  of write
    always @(gWE_n or  gCE_n or  gOE_n )
    begin: write_dc
        if (RESETNeg!=1'b0)
        begin
            if (~gWE_n && ~gCE_n && gOE_n)
                write = 1'b1;
            else
                write = 1'b0;
        end

        if (gWE_n && ~gCE_n && ~gOE_n)
            read = 1'b1;
        else
            read = 1'b0;
    end

    ///////////////////////////////////////////////////////////////////////////
    ////Latch address on falling edge of WE# or CE# what ever comes later
    ////Latch data on rising edge of WE# or CE# what ever comes first
    //// also Write cycle decode
    ////////////////////////////////////////////////////////////////////////////
    integer A_tmp  ;
    integer SA_tmp ;
    integer A_tmp1 ;
    integer Mem_tmp;
    integer AS_addr;
    reg CE;

    always @(WENeg_ipd)
    begin
        if (reseted)
        begin
            if (~WENeg_ipd && ~CENeg_ipd && OENeg_ipd )
            begin
                A_tmp   = A[10:0];
                SA_tmp  = A[HiAddrBit:16];
                A_tmp1  = A[15:0];
                Mem_tmp = A;
                AS_addr = A[21];
            end
        end
    end

    always @(CENeg_ipd)
    begin
        if (reseted)
        begin
            if (~CENeg_ipd && (WENeg_ipd != OENeg_ipd) )
            begin
                 A_tmp   = A[10:0];
                 SA_tmp  = A[HiAddrBit:16];
                 A_tmp1  = A[15:0];
                 Mem_tmp = A;
                 AS_addr = A[21];
            end
            if  (~CENeg_ipd && WENeg_ipd && ~OENeg_ipd)
            begin
                   SecAddr = SA_tmp;
                   Address = A_tmp1;
                   MemAddress = Mem_tmp;
                   Addr = A_tmp;
            end
        end
    end

    always @(negedge OENeg_ipd )
    begin
        if (reseted)
        begin
            if (~OENeg_ipd && WENeg_ipd && ~CENeg_ipd)
            begin
                A_tmp   = A[10:0];
                SA_tmp  = A[HiAddrBit:16];
                A_tmp1  = A[15:0];
                Mem_tmp = A;
                SecAddr = SA_tmp;
                Address = A_tmp1;
                MemAddress = Mem_tmp;
                Addr = A_tmp;
                AS_addr = A[21];
            end

            SecAddr = SA_tmp;
            Address = A_tmp1;
            MemAddress = Mem_tmp;
            CE = CENeg;
            Addr = A_tmp;
        end
    end

    always @(A)
    begin
        if (reseted)
            if (WENeg_ipd && ~CENeg_ipd && ~OENeg_ipd)
            begin
                A_tmp   = A[10:0];
                SA_tmp  = A[HiAddrBit:16];
                A_tmp1  = A[15:0];
                Mem_tmp = A;
                AS_addr = A[21];
                SecAddr = SA_tmp;
                Address = A_tmp1;
                MemAddress = Mem_tmp;
                Addr = A_tmp;
                CE = CENeg;
            end
    end

    always @(posedge write)
    begin
         SecAddr = SA_tmp;
         Address = A_tmp1;
         MemAddress = Mem_tmp;
         Addr = A_tmp;
         CE = CENeg;
    end

///////////////////////////////////////////////////////////////////////////
// Timing control for the Program Operations
///////////////////////////////////////////////////////////////////////////

    integer cnt_write = 0;
    //time elapsed_write  ;
    time duration_write ;
    //time start_write    ;
    event pdone_event;

    always @(posedge reseted)
    begin
        PDONE = 1'b1;
    end

    always @(reseted or PSTART)
    begin
        if (reseted)
        begin
            if (PSTART && PDONE)
            begin
                if ((~FactoryProt   && OTP_ACT)||
                   ( ~Sec_Prot[SA] &&(~Ers_queue[SA] || ~ESP_ACT )&& ~OTP_ACT))
                begin
                    duration_write = tdevice_POB + 5;
                    PDONE = 1'b0;
                    ->pdone_event;
                end
                else
                begin
                    PERR = 1'b1;
                    PERR <= #1005 1'b0;
                end
            end
        end
    end

    always @(pdone_event)
    begin:pdone_process
        PDONE = 1'b0;
        #duration_write PDONE = 1'b1;
    end

/////////////////////////////////////////////////////////////////////////
// Timing control for the Erase Operations
/////////////////////////////////////////////////////////////////////////
    integer cnt_erase = 0;
    time elapsed_erase;
    time duration_erase;
    time start_erase;

    always @(posedge reseted)
    begin
        disable edone_process;
        EDONE = 1'b1;
    end
    event edone_event;
    always @(reseted or ESTART)
    begin: erase
    integer i;
        if (reseted)
        begin
            if (ESTART && EDONE)
            begin
                cnt_erase = 0;
                for (i=0;i<=SecNum;i=i+1)
                begin
                    if ((Ers_queue[i]==1'b1) && (Sec_Prot[i]!=1'b1))
                        cnt_erase = cnt_erase + 1;
                end

                if (cnt_erase>0)
                begin
                    elapsed_erase = 0;
                    duration_erase = cnt_erase* tdevice_SEO + 4;
                    ->edone_event;
                    start_erase = $time;
                end
                else
                begin
                    EERR = 1'b1;
                    EERR <= #100005  1'b0;
                end
            end
        end
    end

    always @(edone_event)
    begin : edone_process
        EDONE = 1'b0;
        #duration_erase EDONE = 1'b1;
    end

    always @(reseted or ESUSP)
    begin
        if (reseted)
            if (ESUSP && ~EDONE)
            begin
                disable edone_process;
                elapsed_erase = $time - start_erase;
                duration_erase = duration_erase - elapsed_erase;
                EDONE = 1'b0;
            end
    end
    always @(reseted or ERES)
    begin
        if (reseted)
            if (ERES && ~EDONE)
            begin
                start_erase = $time;
                EDONE = 1'b0;
                ->edone_event;
            end
    end

//    /////////////////////////////////////////////////////////////////////////
//    // Main Behavior Process
//    // combinational process for next state generation
//    /////////////////////////////////////////////////////////////////////////
        reg PATTERN_1  = 1'b0;
        reg PATTERN_2  = 1'b0;
        reg A_PAT_1  = 1'b0;
        reg A_PAT_2  = 1'b0;
        reg A_PAT_3  = 1'b0;
        integer DataByte   ;

    always @(negedge write)
    begin
        DataByte = DIn;
        PATTERN_1 = DataByte==8'hAA ;
        PATTERN_2 = DataByte==8'h55 ;
        A_PAT_1   = 1'b1;
        A_PAT_2   = Address==16'hAAA ;
        A_PAT_3   = Address==16'h555 ;
        
    end

    always @(write or reseted)
    begin: StateGen1
        if (reseted!=1'b1)
            next_state = current_state;
        else
        if (~write)
            case (current_state)
            RESET :
            begin
                if (PATTERN_1)
                    next_state = Z001;
                else if ((Addr==8'h55) && (DataByte==8'h98))
                    next_state = CFI;
                else
                    next_state = RESET;
            end

            CFI:
            begin
                if (DataByte==8'hF0)
                     next_state = RESET;
                else
                     next_state =  CFI;
            end

            Z001 :
            begin
                if (PATTERN_2)
                        next_state = PREL_SETBWB;
                else
                        next_state = RESET;
            end

            PREL_SETBWB :
            begin
                if (A_PAT_1 && (DataByte==16'h20))
                    next_state = PREL_ULBYPASS;
                else if  (A_PAT_1 && (DataByte==16'h90))
                    next_state = AS;
                else if (A_PAT_1 && (DataByte==16'hA0))
                    next_state = A0SEEN;
                else if (A_PAT_1 && (DataByte==16'h80))
                        next_state = C8;
                else if  (A_PAT_1 && (DataByte==16'h88))
                    next_state = OTP;
                else
                    next_state = RESET;
            end

            PREL_ULBYPASS :
            begin
                if (DataByte == 16'h90 )
                    next_state <= PREL_ULBYPASS_RESET;
                if (A_PAT_1 && (DataByte == 16'hA0))
                    next_state = A0SEEN;
                else
                    next_state = PREL_ULBYPASS;
            end

            PREL_ULBYPASS_RESET :
            begin
                if (DataByte == 16'h00 )
                    if (ESP_ACT) 
                        next_state = ESP;
                    else
                        next_state = RESET;
                else
                     next_state <= PREL_ULBYPASS;
            end

            AS :
            begin
                if (DataByte==16'hF0)
                    next_state = RESET;
                else if ((Addr==8'h55) && (DataByte==8'h98))
                    next_state = AS_CFI;
                else
                    next_state = AS;
            end

            AS_CFI:
            begin
                if (DataByte==8'hF0)
                    next_state = AS;
                else
                    next_state = AS_CFI;
            end

            A0SEEN :
            begin
                next_state = PGMS;
            end

            OTP :
            begin
                if (PATTERN_1)
                    next_state = OTP_Z001;
                else
                   next_state = OTP;
            end

            OTP_Z001 :
            begin
                  if (PATTERN_2)
                      next_state = OTP_PREL;
                  else
                      next_state = OTP;
            end

              OTP_PREL :
               begin
                     if (A_PAT_1 && (DataByte == 16'h90))
                         next_state = OTP_AS;
                     else if (A_PAT_1 && (DataByte == 16'hA0))
                         next_state = OTP_A0SEEN;
                     else
                         next_state = OTP;
               end

            OTP_AS:
             begin
                   if (DataByte == 16'h00)
                       if (ESP_ACT) 
                           next_state = ESP;
                       else
                           next_state = RESET;
                   else if (DataByte == 16'hF0)
                       next_state = OTP;
                   else if (DataByte == 16'h98)
                       next_state = OTP_AS_CFI;
                   else
                       next_state = OTP_AS;
             end

            OTP_AS_CFI:
             begin
                   if (DataByte == 16'hF0) 
                       next_state = OTP_AS;
                   else 
                       next_state = OTP_AS_CFI;
             end             

            OTP_A0SEEN :
            begin
                 if ((SecAddr == 16'h3F) && (Address <= 16'hFFFF) && 
                     (Address >= 16'hFF00))
                     next_state = PGMS;
                 else
                     next_state = OTP;
            end

            C8 :
            begin
                if (PATTERN_1)
                    next_state = C8_Z001;
                else
                    next_state = RESET;
            end

            C8_Z001 :
            begin
                if (PATTERN_2)
                     next_state = C8_PREL;
                else
                     next_state = RESET;
            end

            C8_PREL :
            begin
                if (A_PAT_1 && (DataByte==16'h10))
                    next_state = ERS;
                else if (DataByte==16'h30)
                    next_state = SERS;
                else
                    next_state = RESET;
            end

            ERS :
            begin
            end

            SERS :
            begin
                if (~CTMOUT && DataByte == 16'hB0)
                    next_state = ESP; // ESP according to datasheet
                else if (DataByte==16'h30)
                     next_state = SERS;
                else
                     next_state = RESET;
            end

            SERS_EXEC :
            begin
            end

            ESP :
            begin
               if (DataByte == 16'h30)
                     next_state = SERS_EXEC;
               else
                 begin
                    if (PATTERN_1)
                         next_state = ESP_Z001;
                    if (Addr == 8'h55 && DataByte == 8'h98)
                         next_state = ESP_CFI;
                 end
            end

            ESP_CFI:
            begin
                if (DataByte == 8'hF0)
                    next_state = ESP;
                else
                    next_state = ESP_CFI;
            end

            ESP_Z001 :
            begin
                    if (PATTERN_2)
                        next_state = ESP_PREL;
                    else
                        next_state = ESP;
            end

            ESP_PREL :
            begin
                    if (A_PAT_1 && DataByte == 16'hA0)
                        next_state = ESP_A0SEEN;
                    else if (A_PAT_1 && DataByte == 16'h20)
                        next_state <= PREL_ULBYPASS;
                    else if (A_PAT_1 && DataByte == 16'h88)
                        next_state <= OTP;
                    else if (A_PAT_1 && DataByte == 16'h90)
                        next_state = ESP_AS;
                    else
                        next_state = ESP;
            end

            ESP_A0SEEN :
            begin
                 next_state = PGMS; //set ESP
            end

            ESP_AS :
            begin
                if (DataByte == 16'hF0)
                     next_state = ESP;
                else if ((Addr==8'h55) && (DataByte==8'h98))
                        next_state = ESP_AS_CFI;
            end

            ESP_AS_CFI:
            begin
                if (DataByte == 8'hF0)
                    next_state = ESP_AS;
                else
                    next_state = ESP_AS_CFI;
            end

            endcase
    end

    always @(posedge PDONE or negedge PERR)
    begin: StateGen6
        if (reseted!=1'b1)
            next_state = current_state;
        else
        begin
           if (current_state==PGMS && ULBYPASS)
                next_state = PREL_ULBYPASS;
           else if (current_state==PGMS && OTP_ACT)
                next_state = OTP;
           else if (current_state==PGMS && ESP_ACT)
                next_state = ESP;
           else if (current_state==PGMS)
                next_state = RESET;
        end
    end

    always @(posedge EDONE or negedge EERR)
    begin: StateGen2
        if (reseted!=1'b1)
            next_state = current_state;
        else
        begin
            if ((current_state==ERS) || (current_state==SERS_EXEC))
                next_state = RESET;
        end
    end

    always @(negedge write or reseted)
    begin: StateGen7 //ok
    integer i,j;
        if (reseted!=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state==SERS_EXEC && (write==1'b0) && (EERR!=1'b1))
                if (DataByte==16'hB0)
                begin
                    next_state = ESPS;
                    ESUSP = 1'b1;
                    ESUSP <= #1 1'b0;
                end
        end
    end

    always @(CTMOUT or reseted)
    begin: StateGen4
        if (reseted!=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state==SERS && CTMOUT)  next_state = SERS_EXEC;
        end
    end

    always @(posedge START_T1 or reseted)
    begin: StateGen5
        if (reseted!=1'b1)
            next_state = current_state;
        else
            if (current_state==ESPS && START_T1) next_state = ESP;
    end

    ///////////////////////////////////////////////////////////////////////////
    //FSM Output generation and general funcionality
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge read)
    begin
        ->oe_event;
    end
    always @(MemAddress)
    begin
        if (read)
            ->oe_event;
    end

    always @(oe_event)
    begin
        oe = 1'b1;
        #1 oe = 1'b0;
    end

    always @(DOut_zd)
    begin : OutputGen
        if (DOut_zd[0] !== 1'bz)
        begin
            CEDQ_t = CENeg_event  + CEDQ_01;
            OEDQ_t = OENeg_event  + OEDQ_01;
            ADDRDQ_t = ADDR_event + ADDRDQ_01;
            FROMCE = ((CEDQ_t >= OEDQ_t) && ( CEDQ_t >= $time));
            FROMOE = ((OEDQ_t >= CEDQ_t) && ( OEDQ_t >= $time));
            FROMADDR = 1'b1;
            if ((ADDRDQ_t > $time )&&
             (((ADDRDQ_t>OEDQ_t)&&FROMOE) ||
              ((ADDRDQ_t>CEDQ_t)&&FROMCE)))
            begin
                TempData = DOut_zd;
                FROMADDR = 1'b0;
                DOut_Pass = 8'bx;
                #(ADDRDQ_t - $time) DOut_Pass = TempData;
            end
            else
            begin
                DOut_Pass = DOut_zd;
            end
       end
    end

    always @(DOut_zd)
    begin
        if (DOut_zd[0] === 1'bz)
        begin
           disable OutputGen;
           FROMCE = 1'b1;
           FROMOE = 1'b1;
           if ((CENeg_posEvent <= OENeg_posEvent) &&
           ( CENeg_posEvent + 5 >= $time))
               FROMOE = 1'b0;
           if ((OENeg_posEvent < CENeg_posEvent) &&
           ( OENeg_posEvent + 5 >= $time))
               FROMCE = 1'b0;
           FROMADDR = 1'b0;
           DOut_Pass = DOut_zd;
       end
    end

    always @(oe or reseted or current_state)
    begin
        if (reseted)
        begin
        case (current_state)

            RESET :
            begin
                if (oe)
                    MemRead(DOut_zd);
            end

            AS, ESP_AS, OTP_AS :
            begin
              if (oe)
                    begin
                        if (AS_addr == 1'b0)
                            begin
                            end
                        else
                            AS_ID = 1'b0;  
                        if ((Address[7:0] == 0) && (AS_ID == 1'b1))
                            DOut_zd = 1;
                        else if ((Address[7:0] == 1) && (AS_ID == 1'b1))
                            DOut_zd = 8'hA3;
                        else if ((Address[7:0] == 2) && 
                            (((SecAddr < 32 ) && (AS_ID == 1'b1))
                            || ((SecAddr > 31 ) && (AS_ID2 == 1'b1))))
                        begin
                            DOut_zd    = 8'b00000000;
                            DOut_zd[0] = Sec_Prot[SecAddr];
                        end
                        else if ((Address[7:0] == 6) && (AS_SecSi_FP == 1'b1))
                        begin
                            DOut_zd = 8'b0;
                            if (FactoryProt)
                                DOut_zd = 16'h99;
                            else
                                DOut_zd = 16'h19;
                        end
                        else
                            DOut_zd    = 8'bz;
                    end
            end

            OTP :
             begin
                 if (oe)
                 begin
                     if ((SecAddr == 16'h3F) && (Address <= 16'hFFFF) && 
                        (Address >= 16'hFF00))
                     begin
                         SecSiAddr = Address%(SecSiSize +1);
                         if (SecSi[SecSiAddr]==-1)
                             DOut_zd = 8'bx;
                         else
                             DOut_zd = SecSi[SecSiAddr];
                     end
                     else
                         $display ("Invalid SecSi query address");
                 end
             end

            CFI, AS_CFI, ESP_CFI, ESP_AS_CFI, OTP_AS_CFI :
            begin
            if (oe)
            begin
                 DOut_zd = 8'bZ;
                 if (((MemAddress>=16'h10) && (MemAddress <= 16'h3C)) ||
                     ((MemAddress>=16'h40) && (MemAddress <= 16'h4F)))
                 begin
                     DOut_zd = CFI_array[MemAddress];
                 end
                 else
                 begin
                     $display ("Invalid CFI query address");
                 end
            end
            end

            ERS :
            begin
                if (oe)
                begin
                    ///////////////////////////////////////////////////////////
                    // read status / embeded erase algorithm - Chip Erase
                    ///////////////////////////////////////////////////////////
                    Status[7] = 1'b0;
                    Status[6] = ~Status[6]; //toggle
                    Status[5] = 1'b0;
                    Status[3] = 1'b1;
                    Status[2] = ~Status[2]; //toggle

                    DOut_zd = Status;
                end
            end

        SERS :
        begin
            if (oe)
            begin
                ///////////////////////////////////////////////////////////
                //read status - sector erase timeout
                ///////////////////////////////////////////////////////////
                Status[3] = 1'b0;
                Status[7] = 1'b1;
                DOut_zd = Status;
            end
        end

        ESPS :
        begin
            if (oe)
            begin
                ///////////////////////////////////////////////////////////
                //read status / erase suspend timeout - stil erasing
                ///////////////////////////////////////////////////////////
                if (Ers_queue[SecAddr]==1'b1)
                begin
                    Status[7] = 1'b0;
                    Status[2] = ~Status[2]; //toggle
                end
                else
                    Status[7] = 1'b1;
                Status[6] = ~Status[6]; //toggle
                Status[5] = 1'b0;
                Status[3] = 1'b1;
                DOut_zd = Status;
            end
        end

        SERS_EXEC:
        begin
            if (oe)
            begin
                 ///////////////////////////////////////////////////
                 //read status erase
                 ///////////////////////////////////////////////////
                 if (Ers_queue[SecAddr]==1'b1)
                 begin
                     Status[7] = 1'b0;
                     Status[2] = ~Status[2]; //toggle
                 end
                 else
                 Status[7] = 1'b1;
                 Status[6] = ~Status[6]; //toggle
                 Status[5] = 1'b0;
                 Status[3] = 1'b1;
                 DOut_zd = Status;
            end
        end

        ESP :
        begin
            if (oe)
            begin
                ///////////////////////////////////////////////////////////
                //read
                ///////////////////////////////////////////////////////////

                if    (Ers_queue[SecAddr]!=1'b1)
                begin
                    MemRead(DOut_zd);
                end
                else
                begin
                    ///////////////////////////////////////////////////////
                    //read status
                    ///////////////////////////////////////////////////////
                    Status[7] = 1'b1;
                    // Status[6) No toggle
                    Status[5] = 1'b0;
                    Status[2] = ~Status[2]; //toggle
                    DOut_zd = Status;
                end
            end
        end

        PGMS :
        begin
            if (oe)
            begin
                ///////////////////////////////////////////////////////////
                //read status
                ///////////////////////////////////////////////////////////
                Status[6] = ~Status[6]; //toggle
                Status[5] = 1'b0;
                //Status[2) no toggle
                Status[1] = 1'b0;
                DOut_zd = Status;
                if (SecAddr == SA)
                    DOut_zd[7] = Status[7];
                else
                    DOut_zd[7] = ~Status[7];
            end

        end
        endcase
    end
    end

    always @(write or reseted)
    begin : Output_generation
        if (reseted)
        begin
        case (current_state)
            RESET :
            begin
                ESP_ACT  = 1'b0;
                ULBYPASS = 1'b0;
                OTP_ACT  = 1'b0; 
                if (~write)
                    if (A_PAT_2 && PATTERN_1)
                        AS_SecSi_FP = 1'b1;
                    else
                        AS_SecSi_FP = 1'b0;
            end

            Z001 :
            begin
            if (~write)
                if (A_PAT_3 && PATTERN_2)
                    begin
                    end
                else
                    AS_SecSi_FP = 1'b0;
            end

            PREL_SETBWB :
            begin
                if (~write)
                begin
                    if (A_PAT_1 && (DataByte==16'h20))
                        ULBYPASS = 1'b1;
                    else if (A_PAT_1 && (DataByte==16'h90))
                        begin
                            ULBYPASS = 1'b0;
                            if (A_PAT_2) 
                                begin
                                end
                            else
                                AS_SecSi_FP = 1'b0;
                            if (AS_addr == 1'b0)
                                begin
                                    AS_ID = 1'b1;
                                    AS_ID2= 1'b0;
                                end
                            else
                                begin
                                    AS_ID = 1'b0;
                                    AS_ID2= 1'b1;
                                end 
                        end
                    else if (A_PAT_1 && (DataByte==16'h88))
                      begin
                        OTP_ACT   = 1;
                        ULBYPASS = 1'b0;
                      end
                end
            end

            PREL_ULBYPASS :
            begin
                if (~write)
                begin 
                ULBYPASS = 1'b1;
                   if (A_PAT_1 && (DataByte==16'h90))
                        ULBYPASS = 1'b0;
                end
            end

            PREL_ULBYPASS_RESET :
                if ((~write) && (DataByte != 16'h00 ))
                        ULBYPASS = 1'b1;

            OTP_A0SEEN :
            begin
                if (~write)
                begin
                    if ((SecAddr == 16'h3F) && (Address <= 16'hFFFF) && 
                       (Address >= 16'hFF00))
                    begin
                        SecSiAddr = Address%(SecSiSize +1);
                        OTP_ACT = 1;
                        PSTART = 1'b1;
                        PSTART <= #1 1'b0;

                        WBAddr = SecSiAddr;
                        SA = SecAddr;
                        temp = DataByte;
                        Status[7] = ~temp[7];
                        WBData = DataByte;
                    end
                    else
                        $display ("Invalid program address in SecSi region:"
                                  ,Address);
                end
            end

            OTP_PREL :
            begin
                if (~write)
                    if (A_PAT_1 && (DataByte==16'h90))
                       begin
                           ULBYPASS = 1'b0;
                           if (A_PAT_2) 
                               begin
                               end
                           else
                               AS_SecSi_FP = 1'b0;
                           if (AS_addr == 1'b0)
                               begin
                                   AS_ID = 1'b1;
                                   AS_ID2= 1'b0;
                               end 
                           else
                               begin
                                   AS_ID = 1'b0;
                                   AS_ID2= 1'b1;
                               end
                       end 
                           
            end

           OTP_Z001 :
           begin
                if (~write)
                    if (A_PAT_3 && PATTERN_2)
                        begin
                        end
                    else
                        AS_SecSi_FP = 1'b0;
           end 
           
           OTP :
            begin
                if (~write)
                    if (A_PAT_2 && PATTERN_1)
                        AS_SecSi_FP = 1'b1;
                    else
                        AS_SecSi_FP = 1'b0;
                RY_zd = 1;
            end

            AS :
            begin
                if (~write)
                    if (DataByte==16'hF0)
                        begin
                            AS_SecSi_FP = 1'b0;
                            AS_ID = 1'b0;
                            AS_ID2 = 1'b0;
                        end
            end

            A0SEEN :
            begin
                if (~write)
                begin
                    PSTART = 1'b1;
                    PSTART <= #1 1'b0;
                    WBData = DataByte;
                    WBAddr = Address;
                    SA = SecAddr;
                    Status[7] = ~DataByte[7];
                end
            end

            C8 :
            begin
            end

            C8_Z001 :
            begin
            end

            C8_PREL :
            begin
                if (~write)
                    if (A_PAT_1 && (DataByte==16'h10))
                    begin
                        //Start Chip Erase
                        ESTART = 1'b1;
                        ESTART <= #1 1'b0;
                        ESUSP  = 1'b0;
                        ERES   = 1'b0;
                        Ers_queue = ~(0);
                        Status = 8'b00001000;
                    end
                    else if (DataByte==16'h30)
                    begin
                        //put selected sector to sec. ers. queue
                        //start timeout
                        Ers_queue = 0;
                        Ers_queue[SecAddr] = 1'b1;
                        disable TCTMOUTr;
                        CTMOUT_in = 1'b0;
                        #1 CTMOUT_in <= 1'b1;
                     end
            end

            ERS :
            begin
            end

            SERS :
            begin
                if (~write && ~CTMOUT)
                begin
                    if (DataByte == 16'hB0)
                    begin
                        //need to start erase process prior to suspend
                        ESTART = 1'b1;
                        ESTART = #1 1'b0;
                        ESUSP  = #1 1'b0;
                        ESUSP  = #1 1'b1;
                        ESUSP  <= #2 1'b0;
                        ERES   = 1'b0;
                    end
                    else if (DataByte==16'h30)
                    begin
                        disable TCTMOUTr;
                        CTMOUT_in = 1'b0;
                        #1 CTMOUT_in <= 1'b1;
                        Ers_queue[SecAddr] = 1'b1;
                    end
                end
            end

            SERS_EXEC :
            begin
            if (~write)
                if (~EDONE && (EERR!=1'b1) && DataByte==16'hB0)
                        START_T1_in = 1'b1;
            end

            ESP :
            begin
                if (~write)
                begin
                    if (A_PAT_2 && PATTERN_1)
                        AS_SecSi_FP = 1'b1;
                    else
                        AS_SecSi_FP = 1'b0;
                    if (DataByte == 16'h30)
                    begin
                        ERES = 1'b1;
                        ERES <= #1 1'b0;
                    end
                end
            end

            ESP_Z001 :
            begin
                if (~write)
                    if (A_PAT_3 && PATTERN_2)
                        begin
                        end
                    else
                        AS_SecSi_FP = 1'b0;
            end

            ESP_PREL :
            begin
                if (~write)
                    if (A_PAT_1 && (DataByte==16'h90))
                       begin
                           ULBYPASS = 1'b0;
                           if (A_PAT_2) 
                               begin
                               end
                           else
                               AS_SecSi_FP = 1'b0;
                           if (AS_addr == 1'b0)
                               begin
                                   AS_ID = 1'b1;
                                   AS_ID2= 1'b0;
                               end
                           else
                               begin
                                   AS_ID = 1'b0;
                                   AS_ID2= 1'b1;
                               end
                       end
            end

            ESP_A0SEEN :
            begin
                if (~write)
                begin
                    ESP_ACT = 1'b1;
                    PSTART = 1'b1;
                    PSTART <= #1 1'b0;
                    WBData = DataByte;
                    WBAddr = Address;
                    SA = SecAddr;
                    Status[7] = ~DataByte[7];
                end
            end

            ESP_AS :
            begin
            end

        endcase
        end
    end

    initial
    begin
        ///////////////////////////////////////////////////////////////////////
        //CFI array data
        ///////////////////////////////////////////////////////////////////////

            //CFI query identification string
            for (i=16;i<92;i=i+1)
                 CFI_array[i] = -1;

            CFI_array[16'h10] = 16'h51;
            CFI_array[16'h11] = 16'h52;
            CFI_array[16'h12] = 16'h59;
            CFI_array[16'h13] = 16'h02;
            CFI_array[16'h14] = 16'h00;
            CFI_array[16'h15] = 16'h40;
            CFI_array[16'h16] = 16'h00;
            CFI_array[16'h17] = 16'h00;
            CFI_array[16'h18] = 16'h00;
            CFI_array[16'h19] = 16'h00;
            CFI_array[16'h1A] = 16'h00;

            //system interface string
            CFI_array[16'h1B] = 16'h27;
            CFI_array[16'h1C] = 16'h36;
            CFI_array[16'h1D] = 16'h00;
            CFI_array[16'h1E] = 16'h00;
            CFI_array[16'h1F] = 16'h04;
            CFI_array[16'h20] = 16'h00;
            CFI_array[16'h21] = 16'h0A;
            CFI_array[16'h22] = 16'h00;
            CFI_array[16'h23] = 16'h05;
            CFI_array[16'h24] = 16'h00;
            CFI_array[16'h25] = 16'h04;
            CFI_array[16'h26] = 16'h00;
            //device geometry definition
            CFI_array[16'h27] = 16'h16;
            CFI_array[16'h28] = 16'h00;
            CFI_array[16'h29] = 16'h00;
            CFI_array[16'h2A] = 16'h00;
            CFI_array[16'h2B] = 16'h00;
            CFI_array[16'h2C] = 16'h01;
            CFI_array[16'h2D] = 16'h3F;
            CFI_array[16'h2E] = 16'h00;
            CFI_array[16'h2F] = 16'h00;
            CFI_array[16'h30] = 16'h01;
            CFI_array[16'h31] = 16'h00;
            CFI_array[16'h32] = 16'h00;
            CFI_array[16'h33] = 16'h00;
            CFI_array[16'h34] = 16'h00;
            CFI_array[16'h35] = 16'h00;
            CFI_array[16'h36] = 16'h00;
            CFI_array[16'h37] = 16'h00;
            CFI_array[16'h38] = 16'h00;
            CFI_array[16'h39] = 16'h00;
            CFI_array[16'h3A] = 16'h00;
            CFI_array[16'h3B] = 16'h00;
            CFI_array[16'h3C] = 16'h00;

            //primary vendor-specific extended query
            CFI_array[16'h40] = 16'h50;
            CFI_array[16'h41] = 16'h52;
            CFI_array[16'h42] = 16'h49;
            CFI_array[16'h43] = 16'h31;
            CFI_array[16'h44] = 16'h31;
            CFI_array[16'h45] = 16'h01;
            CFI_array[16'h46] = 16'h02;
            CFI_array[16'h47] = 16'h01;
            CFI_array[16'h48] = 16'h01;
            CFI_array[16'h49] = 16'h04;
            CFI_array[16'h4A] = 16'h00;
            CFI_array[16'h4B] = 16'h00;
            CFI_array[16'h4C] = 16'h00;
            CFI_array[16'h4D] = 16'hB5;
            CFI_array[16'h4E] = 16'hC5;
            CFI_array[16'h4F] = 16'h00;

   end

    always @(current_state or reseted)
    begin
        if (reseted)
            if (current_state==RESET)         RY_zd = 1'b1;
            if (current_state==PREL_ULBYPASS) RY_zd = 1'b1;
            if (current_state==A0SEEN)        RY_zd = 1'b1;
            if (current_state==ERS)           RY_zd = 1'b0;
            if (current_state==SERS)          RY_zd = 1'b0;
            if (current_state==ESPS)          RY_zd = 1'b0;
            if (current_state==SERS_EXEC)     RY_zd = 1'b0;
            if (current_state==ESP)           RY_zd = 1'b1;
            if (current_state==OTP)           RY_zd = 1'b1;
            if (current_state==ESP_A0SEEN)    RY_zd = 1'b1;
            if (current_state==PGMS)          RY_zd = 1'b0;
    end

    always @(EERR or EDONE or current_state)
    begin : ERS2
    integer i;
    integer j;
        if (current_state==ERS  && EERR!=1'b1)
            for (i=0;i<=SecNum;i=i+1)
            begin
                if (Sec_Prot[i]!=1'b1)
                    for (j=0;j<=SecSize;j=j+1)
                       Mem[sa(i)+j] = -1;
            end
        if (current_state==ERS  && EDONE)
            for (i=0;i<=SecNum;i=i+1)
            begin
                if (Sec_Prot[i]!=1'b1)
                    for (j=0;j<=SecSize;j=j+1)
                         Mem[sa(i)+j] = MaxData;
           end
    end

    always @(CTMOUT or current_state)
    begin : SERS2
        if (current_state==SERS && CTMOUT)
        begin
            CTMOUT_in = 1'b0;
            START_T1_in = 1'b0;
            ESTART = 1'b1;
            ESTART <= #1 1'b0;
            ESUSP  = 1'b0;
            ERES   = 1'b0;
        end
    end

    always @(START_T1 or current_state)
    begin : ESPS2
        if (current_state==ESPS && START_T1)
        begin
            ESP_ACT = 1'b1;
            START_T1_in = 1'b0;
        end
    end

    always @(EERR or EDONE or current_state)
    begin: SERS_EXEC2
    integer i,j;
        if (current_state==SERS_EXEC)
        begin
            if (EERR!=1'b1)
            begin
                for (i=0;i<=SecNum;i=i+1)
                begin
                    if (Sec_Prot[i]!=1'b1 && Ers_queue[i])
                        for (j=0;j<=SecSize;j=j+1)
                            Mem[sa(i)+j] = -1;

                if (EDONE)
                    for (i=0;i<=SecNum;i=i+1)
                    begin
                        if (Sec_Prot[i]!=1'b1 && Ers_queue[i])
                            for (j=0;j<=SecSize;j=j+1)
                                Mem[sa(i)+j] = MaxData;
                        end
                    end
            end
        end
    end

    always @(current_state or posedge PDONE)
    begin: PGMS2
    integer i,j;
        if (current_state==PGMS)
        begin
            if (PERR!=1'b1)
            begin
                new_int = WBData;
                if (OTP_ACT!=1'b1)   //mem write
                   old_int=Mem[sa(SA) + WBAddr];
                else
                   old_int=SecSi[WBAddr];
                   new_bit = new_int;
                   if (old_int>-1)
                   begin
                       old_bit = old_int;
                       for(j=0;j<=7;j=j+1)
                           if (~old_bit[j])
                               new_bit[j]=1'b0;
                           new_int=new_bit;
                   end
                   WBData = new_int;
                 if (OTP_ACT!=1'b1)   //mem write
                   Mem[sa(SA) + WBAddr] = -1;
                 else
                   SecSi[WBAddr] = -1;
                 if (PDONE && ~PSTART)
                 begin
                      if (OTP_ACT!=1'b1)   //mem write
                        Mem[sa(SA) + WBAddr] = WBData;
                      else
                        SecSi[WBAddr] = WBData;
                      WBData= -1;
                 end
            end
        end
    end

    always @(gOE_n or gCE_n or RESETNeg or RST )
    begin
        //Output Disable Control
        if (gOE_n || gCE_n || (~RESETNeg && ~RST))
            DOut_zd = 8'bZ;
    end

    reg  BuffInOE , BuffInCE , BuffInADDR;
    wire BuffOutOE, BuffOutCE, BuffOutADDR;

    BUFFER    BUFOE   (BuffOutOE, BuffInOE);
    BUFFER    BUFCE   (BuffOutCE, BuffInCE);
    BUFFER    BUFADDR (BuffOutADDR, BuffInADDR);
    initial
    begin
        BuffInOE   = 1'b1;
        BuffInCE   = 1'b1;
        BuffInADDR = 1'b1;
    end

    always @(posedge BuffOutOE)
    begin
        OEDQ_01 = $time;
    end
    always @(posedge BuffOutCE)
    begin
        CEDQ_01 = $time;
    end
    always @(posedge BuffOutADDR)
    begin
        ADDRDQ_01 = $time;
    end

    function integer sa;
    input [7:0] sect;
    begin
        sa = sect * (SecSize + 1);
    end
    endfunction

    task MemRead;
    inout[7:0]  DOut_zd;
    begin
        if (Mem[sa(SecAddr)+Address]==-1)
            DOut_zd = 8'bx;
        else
            DOut_zd = Mem[sa(SecAddr)+Address];
    end
    endtask
endmodule

module BUFFER (OUT,IN);
    input IN;
    output OUT;
    buf   ( OUT, IN);
endmodule
