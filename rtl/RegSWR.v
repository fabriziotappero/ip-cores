//File name=RegSWR.v     no module(don't added this file in the design hiberarchy).  2005-04-??      btltz@mail.china.com    btltz from CASIC  
//Description:   Contains status/contrl regs for SpaceWire Router
//Abbreviations:      
//Origin:        SpaceWire Std - Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:	  Make it easy to use (but enough flexibility)  
////////////////////////////////////////////////////////////////////////////////////
//
//

reg [7:0] GPO;                           // addr: 0x           
reg [7:0] err;                           // addr: 0x           
reg [7:0] err_src   ;                    // addr: 0x           source of error
reg [7:0] tim_itv;                       // addr: 0x           timer interval  
reg [15:0] SPE_CTL [0:IO_PORTNUM];       // addr: 0x           to set transmitter speed of each channel individually
reg [4:0] SWStatus [0:I_PORTNUM];        // addr: 0x           switch status
reg [63:0] LSctrl;                       // addr: 0x           LSer control 
reg [63:0] CSctrl;                       // addr: 0x           CSer control 



// Network Management 
reg RouterID;                            // addr: 0x           Router Identity Register

