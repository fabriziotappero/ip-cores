// Header file for trace analyzer

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

const int LEN_REQ = 125;
const int LEN_RET = 146;

const char CHAR_REQ = '"';
const char CHAR_RET = '$';

// From T1 defs

#define PCX_VLD         123  //PCX packet valid 
#define PCX_RQ_HI       122  //PCX request type field 
#define PCX_RQ_LO       118
#define PCX_NC          117  //PCX non-cacheable bit
#define PCX_R           117  //PCX read/!write bit 
#define PCX_CP_HI       116  //PCX cpu_id field
#define PCX_CP_LO       114
#define PCX_TH_HI       113  //PCX Thread field
#define PCX_TH_LO       112
#define PCX_BF_HI       111  //PCX buffer id field
#define PCX_INVALL      111
#define PCX_BF_LO       109
#define PCX_WY_HI       108  //PCX replaced L1 way field
#define PCX_WY_LO       107
#define PCX_P_HI        108  //PCX packet ID, 1st STQ - 10, 2nd - 01
#define PCX_P_LO        107
#define PCX_SZ_HI       106  //PCX load/store size field
#define PCX_SZ_LO       104
#define PCX_ERR_HI      106  //PCX error field
#define PCX_ERR_LO      104
#define PCX_AD_HI       103  //PCX address field
#define PCX_AD_LO        64
#define PCX_DA_HI        63  //PCX Store data
#define PCX_DA_LO         0  

#define PCX_SZ_1B    0x0
#define PCX_SZ_2B    0x1
#define PCX_SZ_4B    0x2
#define PCX_SZ_8B    0x3
#define PCX_SZ_16B   0x7

#define CPX_VLD         144  //CPX payload packet valid

#define CPX_RQ_HI       143  //CPX Request type
#define CPX_RQ_LO       140
#define CPX_ERR_HI      139  //CPX error field
#define CPX_ERR_LO      137
#define CPX_NC          136  //CPX non-cacheable
#define CPX_R           136  //CPX read/!write bit
#define CPX_TH_HI       135  //CPX thread ID field 
#define CPX_TH_LO       134

//bits 133:128 are shared by different fields
//for different packet types.

#define CPX_IN_HI       133  //CPX Interrupt source 
#define CPX_IN_LO       128  

#define CPX_WYVLD       133  //CPX replaced way valid
#define CPX_WY_HI       132  //CPX replaced I$/D$ way
#define CPX_WY_LO       131
#define CPX_BF_HI       130  //CPX buffer ID field - 3 bits
#define CPX_BF_LO       128

#define CPX_SI_HI       132  //L1 set ID - PA[10:6]- 5 bits
#define CPX_SI_LO       128  //used for invalidates

#define CPX_P_HI        131  //CPX packet ID, 1st STQ - 10, 2nd - 01 
#define CPX_P_LO        130

#define CPX_ASI         130  //CPX forward request to ASI
#define CPX_IF4B        130
#define CPX_IINV        124
#define CPX_DINV        123
#define CPX_INVPA5      122
#define CPX_INVPA4      121
#define CPX_CPUID_HI    120
#define CPX_CPUID_LO    118
#define CPX_INV_PA_HI   116
#define CPX_INV_PA_LO   112
#define CPX_INV_IDX_HI   117
#define CPX_INV_IDX_LO   112

#define CPX_DA_HI       127  //CPX data payload
#define CPX_DA_LO         0

#define LOAD_RQ         0x00
#define IMISS_RQ        0x10
#define STORE_RQ        0x01
#define CAS1_RQ         0x02
#define CAS2_RQ         0x03
#define SWAP_RQ         0x06
#define STRLOAD_RQ      0x04
#define STRST_RQ        0x05
#define STQ_RQ          0x07
#define INT_RQ          0x09
#define FWD_RQ          0x0D
#define FWD_RPY         0x0E
#define RSVD_RQ         0x1F

#define LOAD_RET        0x0
#define INV_RET         0x3
#define ST_ACK          0x4
#define AT_ACK          0x3
#define INT_RET         0x7
#define TEST_RET        0x5
#define FP_RET          0x8
#define IFILL_RET       0x1
#define EVICT_REQ       0x3
#define ERR_RET         0xC
#define STRLOAD_RET     0x2
#define STRST_ACK       0x6
#define FWD_RQ_RET      0xA
#define FWD_RPY_RET     0xB
#define RSVD_RET        0xF

//End cache crossbar defines
