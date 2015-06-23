// ----------------------------- usbDevice_define ---------------------------

`define ZERO_ZERO_STAT_INDEX 8'h6c
`define ONE_ZERO_STAT_INDEX 8'h6e
`define VENDOR_DATA_STAT_INDEX 8'h70
`define DEV_DESC_INDEX 8'h00
`define DEV_DESC_SIZE 8'h12
//config descriptor is bundled with interface desc, HID desc, and EP1 desc
`define CFG_DESC_INDEX 8'h12
`define CFG_DESC_SIZE 8'h22
`define REP_DESC_INDEX 8'h3a
`define REP_DESC_SIZE 8'h32
`define LANGID_DESC_INDEX 8'h80
`define LANGID_DESC_SIZE 8'h04
`define STRING1_DESC_INDEX 8'h90
`define STRING1_DESC_SIZE 8'd26
`define STRING2_DESC_INDEX 8'hb0
`define STRING2_DESC_SIZE 8'd20
`define STRING3_DESC_INDEX 8'hd0
`define STRING3_DESC_SIZE 8'd30

`define DEV_DESC 8'h01
`define CFG_DESC 8'h02
`define REP_DESC 8'h22
`define STRING_DESC 8'h03

//delays at 48MHz
`ifdef SIM_COMPILE
`define ONE_MSEC_DEL 16'h0300
`else
`define ONE_MSEC_DEL 16'hbb80
`endif
`define ONE_USEC_DEL 8'h30

`define GET_STATUS 8'h00
`define CLEAR_FEATURE 8'h01
`define SET_FEATURE 8'h03
`define SET_ADDRESS 8'h05
`define GET_DESCRIPTOR 8'h06
`define SET_DESCRIPTOR 8'h07
`define GET_CONFIG 8'h08
`define SET_CONFIG 8'h09
`define GET_INTERFACE 8'h0a
`define SET_INTERFACE 8'h0b
`define SYNCH_FRAME 8'h0c

`define MAX_RESP_SIZE 8'h40

