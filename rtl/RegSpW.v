//File name=RegSpW.v   no module(don't added this file in the design hiberarchy).   2005-04-07      btltz@mail.china.com    btltz from CASIC  
//Description:   Declare status/contrl registers for CODEC
//Abbreviations:      
//Origin:        SpaceWire Std - Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:	  Make it easy to use (but enough flexibility)  
////////////////////////////////////////////////////////////////////////////////////
//
//

///////////////////////////////
// addr: 0x00 = ADDR_LOC_LOC //
reg [15:0] LOC_LOC;          // local device address in the SpW network. If enabled, HW will compare it with heads of packets
                             // [7:0] : local device location
                             // [8] : '1'enable/'0'disable addr compare


/////////////////////////////// CHANNEL 1 /////////////////////////////////////////////////
// addr: 0x01
reg [15:0] SPE_CTL1;         // transmitter speed control register


///////////////////////////////
// addr: 0x02 = ADDR_CTR_STA1// 
reg [31:28] STA_TX1;         // transmitter status    
                             // [31:30] : reserved;   [29] : tx is running;  [28] : tx buffer Afull; 
reg [27:16] STA_RX1;         // receiver status       
                             // [27:25] : reserved;    [24] : rx buffer empty;   
                             // [23:21]:(got NULL/FCT/Time/Nchar);  [20:16] : {err_par,err_esc,err_dsc,err_seq,err_crd};     
reg [15: 8] CTL_TX1;         // transmitter control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO 
                             // [12] : link_en; [11] : AUTO_START;  [10] : checksum_en 
reg [ 7: 0] CTL_RX1;         // receiver control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO 

//////////////////////////////CHANNEL 2/////////////////////////////////////////////////
// addr: 0x03
reg [15:0] SPE_CTL2;         // transmitter speed control register


///////////////////////////////
// addr: 0x04 = ADDR_CTR_STA2//
reg [31:28] STA_TX2;         // transmitter status   
                             // [31:30] : reserved;   [29] : tx is running;  [28] : tx buffer Afull; 
reg [27:16] STA_RX2;         // receiver status        
                             // [27:25] : reserved;    [24] : rx buffer empty;   
                             // [23:21]:(got NULL/FCT/Time/Nchar);  [20:16] : {err_par,err_esc,err_dsc,err_seq,err_crd};     
reg [15: 8] CTL_TX2;         // transmitter control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO 
                             // [12] : link_en; [11] : AUTO_START;  [10] : checksum_en 
reg [ 7: 0] CTL_RX2;         // receiver control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO 

//////////////////////////////CHANNEL 3/////////////////////////////////////////////////
// addr: 0x05
reg [15:0] SPE_CTL3;         // transmitter speed control register


///////////////////////////////
// addr: 0x06 = ADDR_CTR_STA3//
reg [31:28] STA_TX3;         // transmitter status     
                             //  [31:30] : reserved;   [29] : tx is running;  [28] : tx buffer Afull; 
reg [27:16] STA_RX3;         // receiver status        
                             // [27:25] : reserved;    [24] : rx buffer empty;   
                             // [23:21]:(got NULL/FCT/Time/Nchar);  [20:16] : {err_par,err_esc,err_dsc,err_seq,err_crd};     
reg [15: 8] CTL_TX3;         // transmitter control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO 
                             // [12] : link_en; [11] : AUTO_START;  [10] : checksum_en 
reg [ 7: 0] CTL_RX3;         // receiver control
                             // [15] : SpW or GPIO; reset as SpW;  [14]: Direction of GPIO; [13]: data of IO  



///////////////////////////////
// addr: 0x07 = ADDR_WB_CTR  //
reg [31:30] WB_CTR;          // WISHBONE Interface Control Register
                             // case([31:30])  2'b00 - HOCI operates as 8-bit   2'b01 - ..16-bit    2'b10 - ..32-bit(RESET)    2'b11 - ..64-bit
                     	     // [29:24] reserved
reg [23:20] COMI_ACR;        // COMI Arbitration Control Register . wait time between two accesses.   reset = 0x8;  
                             // 0x0==disable communication memory interface;  
                             // 0xF==Max clk cycles between two accesses; 
                             // [19:16] reserved
reg [15:14] PKT_SIZE;        // packet size.
                             // 0x0 : 8 byte (reset);  0x1 : 16 byte;  0x2 : 24 byte; other reserved
                             // [13:8] reserved
reg [7:6] COMI_CH_SEL;       // from COMI to wich channel
                             // 0x0 : reset;   0x1 : CH 1;   0x2: CH2;  0x3: CH3. 
                             // [5:4] reserved
reg [3:2] CM_AB2TX_GO;       // 2'b10: begin/end load data from COMI bank A to TX FIFO
                             // 2'b01: begin/end load data from COMI bank B to RX FIFO
reg [1:0] CM_RX2AB_GO;       // 2'b10: begin/end load data from RX to COMI bank A
                             // 2'b01: begin/end load data from RX to COMI bank B



//////////////////////////
// addr: 0x08 reserved


//////////////////////////
// addr: 0x09 reserved

//////////////////////////
// addr: 0x0A 
//       Channel 1 Tx FIFO

//////////////////////////
// addr: 0x0B
//       Channel 1 Rx FIFO

//////////////////////////
// addr: 0x0C 
//       Channel 2 Tx FIFO

//////////////////////////
// addr: 0x0D
//       Channel 2 Rx FIFO

//////////////////////////
// addr: 0x0E 
//       Channel 3 Tx FIFO

//////////////////////////
// addr: 0x0F
//       Channel 3 Rx FIFO




//////////////////////////
// addr: 0x10 reserved






///////////////////////////////
// addr: 0x11 = ADDR_CH1TXSE //
reg [31:16] CH1_TX_EAR;      // Channel 1 transmit End Address Register
reg [15:0]  CH1_TX_SAR;      // Channel 1 transmit Start Address  

///////////////////////////////
// addr: 0x12 = ADDR_CH1RXSE //
reg [31:16] CH1_RX_EAR;      // Channel 1 Receive End Address Register
reg [15:0]  CH1_RX_SAR;      // Channel 1 Receive Start Address 

//reg [15:0]  CH1_TX_CAR;      // Channel 1 Current Address. No mapped address

///////////////////////////////
// addr: 0x13 = ADDR_CH2TXSE //
reg [31:16] CH2_TX_EAR;      // Channel 2 transmit End Address
reg [15:0]  CH2_TX_SAR;      // Channel 2 transmit Start Address 

///////////////////////////////
// addr: 0x14 = ADDR_CH2RXSE //
reg [31:16] CH2_RX_EAR;      // Channel 2 Receive End Address
reg [15:0]  CH2_RX_SAR;      // Channel 2 Receive Start Address 

//reg [15:0]  CH2_TX_CAR;      // Channel 2 Current Address. No mapped address

///////////////////////////////
// addr: 0x15 = ADDR_CH3TXSE //
reg [31:16] CH3_TX_EAR;      // Channel 3 transmit End Address
reg [15:0]  CH3_TX_SAR;      // Channel 3 transmit Start Address 

///////////////////////////////
// addr: 0x16 = ADDR_CH3RXSE //
reg [31:16] CH3_RX_EAR;      // Channel 3 Receive End Address
reg [15:0]  CH3_RX_SAR;      // Channel 3 Receive Start Address 

//reg [15:0]  CH3_TX_CAR;      // Channel 3 Current Address. No mapped address










