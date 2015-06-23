
//
// parameter
//
parameter DW            = 8;
parameter AW            = 4;
parameter CONFAW        = 10;
parameter CONFDW        = 8;
parameter CNUMW         = 4;    // Width of the carrier number output
parameter CONSTW        = 9;

parameter SHIFTW        = 23;   // Width of the shift registers
parameter MAXBITNUM     = 15;   // Maximum bit number per carrier

parameter USED_C_REG_W  = 8;    // Used carrier register width
parameter F_BITS_W      = 8;
parameter REG_MEM_LEN   = 256;

//
// register addresses
//
parameter BIT_LOAD_ST_ADR = 12'h000;
parameter C_NUM_ST_ADR    = 12'h100;
parameter USED_C_ADR      = 12'h200;
parameter F_BITS_ADR      = 12'h201;
