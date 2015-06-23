struct can_type 
{
	unsigned char rtr;
	unsigned char len;
	unsigned short identifier;
	unsigned char data[8];
};

typedef struct can_type can_type;

#define CAN_BUF_LEN     10

void can_init(void);
void can_irq(void);

can_type * can_get(void);       //return pointer to first non read received data

int can_send_basic();           //return (-1) or length (still processing previous) or asserted
void can_abort(void);

//BOTH MODES
#define CAN_MODE            0x00
#define CAN_CMD             0x01
#define CAN_STATUS          0x02
#define IRQ_READ            0x03

#define CAN_ACPT_CODE0      0x04    //only writable while in reset mode
#define CAN_ACPT_MASK0      0x05    //only writable while in reset mode

#define CAN_BUS_TIMING_0    0x06    //only writable while in reset mode
#define CAN_BUS_TIMING_1    0x07    //only writable while in reset mode

#define CAN_BUS_CLKDIV      0x1F    //only writable while NOT in reset mode

#define CAN_TX_BUF          0x0A   //only accessable while NOT in reset mode
#define CAN_TX_LEN          10

#define CAN_RX_BUF          0x14   //free read access for basic mode
#define CAN_RX_LEN          10

//only accessable while in reset mode
#define CAN_BUS_MODE        0x1F


//EXTENDED MODE ONLY
//only for extended mode & only accessable while in reset mode
#define CAN_IRQ_EN_EXT      0x04    //also writable if NOT in reset mode 

//read only regs
#define CAN_ARBIT_LOSS_CNT          0x0B    //cnt of arbitration loss
#define CAN_ERROR_CAPTURE_CODE      0x0C
#define CAN_RX_MSG_CNT              0x1D
//~read only regs

#define CAN_ERROR_WARN_LIMIT        0x0D

#define CAN_RX_ERR_CNT      0x0E
#define CAN_TX_ERR_CNT      0x0F

#define CAN_ACPT_CODE0_EXT  0x10    //also writable if NOT in reset mode
#define CAN_ACPT_CODE1      0x11
#define CAN_ACPT_CODE2      0x12
#define CAN_ACPT_CODE3      0x13

#define CAN_ACPT_MASK0_EXT  0x14    //also writable if NOT in reset mode
#define CAN_ACPT_MASK1      0x15
#define CAN_ACPT_MASK2      0x16
#define CAN_ACPT_MASK3      0x17

#define CAN_TX_BUF_EXT      0x10   //accessable if transmit_buffer_status=1 
#define CAN_TX_LEN_EXT      13     //ignores reset mode

#define CAN_RX_BUF_EXT      0x10   //read access only in NOT reset mode
#define CAN_RX_LEN_EXT      13


//BITS DEFINITIONS

//BASIC MODE
#define CAN_MODE_RESET             0x01
#define CAN_MODE_LISTEN_ONLY_BASIC 0x20
#define CAN_MODE_RECV_IRQ_EN       0x02
#define CAN_MODE_TX_IRQ_EN         0x04
#define CAN_MODE_ERROR_IRQ_EN      0x08
#define CAN_MODE_OVERRUN_IRQ_EN    0x10
//EXTENDED MODE
#define CAN_MODE_LISTEN_ONLY_EXT   0x02
#define CAN_MODE_SELF_TEST_MODE    0x04
#define CAN_MODE_ACPT_FILTER_MODE  0x08

//CMD
#define CAN_CMD_CLR_DATA_OVERRUN   0x08
#define CAN_CMD_RELEASE_BUFFER     0x04
#define CAN_CMD_TX_REQ             0x11
#define CAN_CMD_ABORT_TX           0x02

//STATUS
#define CAN_STATUS_NODE_BUS_OFF    0x80
#define CAN_STATUS_ERROR           0x40
#define CAN_STATUS_TX              0x20
#define CAN_STATUS_RX              0x10
#define CAN_STATUS_TX_COMPLETE     0x08
#define CAN_STATUS_TX_BUF          0x04
#define CAN_STATUS_OVERRUN         0x02
#define CAN_STATUS_RX_BUF          0x01

//IRQ READ
#define CAN_IRQ_READ_BUS_ERROR          0x80
#define CAN_IRQ_READ_ARBIT_LOST         0x40
#define CAN_IRQ_READ_ERROR_PASSIV       0x20
#define CAN_IRQ_READ_OVERRUN            0x08
#define CAN_IRQ_READ_ERROR              0x04
#define CAN_IRQ_READ_TX                 0x02
#define CAN_IRQ_READ_RX                 0x01

//BUS_TIMING_0
#define CAN_BUS_TIMING_0_SYNC_JMP_SHIFT     6
#define CAN_BUS_TIMING_0_SYNC_JMP           0xC0
#define CAN_BUS_TIMING_0_BAUD_PRESC         0x3F

//BUS_TIMING_1
#define CAN_BUS_TIMING_1_TRIPLE_SAMP_SHIFT  7
#define CAN_BUS_TIMING_1_TRIPLE_SAMP        0x80
#define CAN_BUS_TIMING_1_TIME_SEG2_SHIFT    4
#define CAN_BUS_TIMING_1_TIME_SEG2          0x70
#define CAN_BUS_TIMING_1_TIME_SEG1          0x0F

//CLKDIV
//only writable while NOT in reset mode
#define CAN_BUS_CLKDIV_MASK                 0x07


//EXTENDED MODE ONLY
//CLKMODE
//only writable while in reset mode
#define CAN_BUS_MODE_CLOCK_OFF              0x08
#define CAN_BUS_MODE_EXTENDED_MODE          0x80

//EXTENDED MODE IRQ
#define CAN_IRQ_EN_EXT_BUS_ERROR          0x80
#define CAN_IRQ_EN_EXT_ARBIT_LOST         0x40
#define CAN_IRQ_EN_EXT_ERROR_PASSIV       0x20
#define CAN_IRQ_EN_EXT_OVERRUN            0x08
#define CAN_IRQ_EN_EXT_ERROR              0x04
#define CAN_IRQ_EN_EXT_TX                 0x02
#define CAN_IRQ_EN_EXT_RX                 0x01

//EXTENDED ERROR CODES
#define CAN_ERROR_CAPTURE_CODE_TYPE_SHIFT	  6
#define CAN_ERROR_CAPTURE_CODE_TYPE		  0xC0
#define CAN_ERROR_CAPTURE_CODE_TYPE_BIT		  0x0
#define CAN_ERROR_CAPTURE_CODE_TYPE_FORM	  0x1
#define CAN_ERROR_CAPTURE_CODE_TYPE_STUFF	  0x2
#define CAN_ERROR_CAPTURE_CODE_TYPE_OTHER	  0x3
#define CAN_ERROR_CAPTURE_CODE_DIR		  0x40  //1 = TX | 0 = RX
#define CAN_ERROR_CAPTURE_CODE_SEG		  0x1F
