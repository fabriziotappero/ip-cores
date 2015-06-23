// module name
`define CNT_MODULE_NAME vcnt

// counter type = [BINARY, GRAY, LFSR]
//`define CNT_TYPE_BINARY
`define CNT_TYPE_GRAY
//`define CNT_TYPE_LFSR

// q as output
`define CNT_Q
// for gray type counter optional binary output
`define CNT_Q_BIN

// up/down, forward/rewind
`define CNT_REW

// number of CNT bins
`define CNT_LENGTH 4

// async reset value
`define CNT_RESET_VALUE 0

// clear
`define CNT_CLEAR

// set
`define CNT_SET
`define CNT_SET_VALUE 9

// wrap around creates shorter cycle than maximum length
//`define CNT_WRAP
`define CNT_WRAP_VALUE 9

// clock enable
`define CNT_CE

// q_next as an output
//`define CNT_QNEXT

// q=0 as an output
//`define CNT_Z

// q_next=0 as a registered output
//`define CNT_ZQ

// level indicator 1
`define CNT_LEVEL1
`define CNT_LEVEL1_VALUE 1

// level indicator 2
`define CNT_LEVEL2
`define CNT_LEVEL2_VALUE 2
