#include <support.h>
#include "interconnect.h"
#include "can.h"

int can_rx_done, can_tx_done;
int can_rx_rd_ptr;
int can_rx_wr_ptr;
int can_rx_buf_overflow;

can_type can_rx_data[CAN_BUF_LEN], can_tx_data;

can_type * can_get(void)
{
	if ( !can_rx_done )
		return NULL;

	can_rx_done--;

	int tmp;
	tmp = can_rx_rd_ptr;

	if (can_rx_rd_ptr < CAN_BUF_LEN-1)
		can_rx_rd_ptr++; 
	else
		can_rx_rd_ptr = 0;

	return &can_rx_data[tmp];
}

void can_init(void)
{
	unsigned char sync_jmp, baudrate_presc, timing_seg1, timing_seg2, tripple_samp = 0;
	unsigned char acpt_code, acpt_mask = 0;
	unsigned char clk_div = 0 & CAN_BUS_CLKDIV_MASK;

	sync_jmp = 1;
	baudrate_presc = 1;
	timing_seg1 = 11;
	timing_seg2 = 2;
	tripple_samp = 1;

	acpt_code = 0x81;
	acpt_mask = 0xFF;

	char timing0, timing1 = 0;

	timing0 = (sync_jmp << CAN_BUS_TIMING_0_SYNC_JMP_SHIFT) & CAN_BUS_TIMING_0_SYNC_JMP;
	timing0 |= baudrate_presc & CAN_BUS_TIMING_0_BAUD_PRESC;

	timing1 = (tripple_samp << CAN_BUS_TIMING_1_TRIPLE_SAMP_SHIFT) & CAN_BUS_TIMING_1_TRIPLE_SAMP;
	timing1 |= (timing_seg2 << CAN_BUS_TIMING_1_TIME_SEG2_SHIFT) & CAN_BUS_TIMING_1_TIME_SEG2;
	timing1 |= timing_seg1 & CAN_BUS_TIMING_1_TIME_SEG1;

	REG8(CAN_BASE+CAN_MODE) = CAN_MODE_RESET;

	REG8(CAN_BASE+CAN_BUS_TIMING_0) = timing0;
	REG8(CAN_BASE+CAN_BUS_TIMING_1) = timing1;

	REG8(CAN_BASE+CAN_ACPT_CODE0) = acpt_code;
	REG8(CAN_BASE+CAN_ACPT_MASK0) = acpt_mask;

	REG8(CAN_BASE+CAN_BUS_MODE) &= ~CAN_BUS_MODE_CLOCK_OFF & ~CAN_BUS_MODE_EXTENDED_MODE;

	REG8(CAN_BASE+CAN_MODE) &= ~CAN_MODE_RESET;
	REG8(CAN_BASE+CAN_BUS_CLKDIV) = clk_div;

	REG8(CAN_BASE+CAN_MODE) |= CAN_MODE_TX_IRQ_EN | CAN_MODE_RECV_IRQ_EN;

	can_tx_done = 1;
	can_rx_done = 0;
	can_rx_rd_ptr = 0;
	can_rx_wr_ptr = 0;
	can_rx_buf_overflow = 0;
}

void can_recv_basic()
{
	unsigned char byte0, byte1;

	byte0 = REG8(CAN_BASE+CAN_RX_BUF);
	byte1 = REG8(CAN_BASE+CAN_RX_BUF+1);

	can_rx_data[can_rx_wr_ptr].data[0] = REG8(CAN_BASE+CAN_RX_BUF+2);
	can_rx_data[can_rx_wr_ptr].data[1] = REG8(CAN_BASE+CAN_RX_BUF+3);
	can_rx_data[can_rx_wr_ptr].data[2] = REG8(CAN_BASE+CAN_RX_BUF+4);
	can_rx_data[can_rx_wr_ptr].data[3] = REG8(CAN_BASE+CAN_RX_BUF+5);
	can_rx_data[can_rx_wr_ptr].data[4] = REG8(CAN_BASE+CAN_RX_BUF+6);
	can_rx_data[can_rx_wr_ptr].data[5] = REG8(CAN_BASE+CAN_RX_BUF+7);
	can_rx_data[can_rx_wr_ptr].data[6] = REG8(CAN_BASE+CAN_RX_BUF+8);
	can_rx_data[can_rx_wr_ptr].data[7] = REG8(CAN_BASE+CAN_RX_BUF+9);

	REG8(CAN_BASE+CAN_CMD) = CAN_CMD_RELEASE_BUFFER;

	can_rx_data[can_rx_wr_ptr].identifier = (byte0 << 3) | (byte1 >> 5);
	can_rx_data[can_rx_wr_ptr].rtr = byte1 & 0x10;
	can_rx_data[can_rx_wr_ptr].len = byte1 & 0x0F;

	if (can_rx_wr_ptr < CAN_BUF_LEN-1)
		can_rx_wr_ptr++;
	else
		can_rx_wr_ptr = 0;

	if (can_rx_wr_ptr == can_rx_rd_ptr+1)       //buffer overflow
	{
		can_rx_done = 1;
		can_rx_buf_overflow++;
	}
	else
		can_rx_done++;
}

int can_send_basic()
{
	if (!can_tx_done)       //if previous command not fully processed, bail out
		return -1; 

	can_tx_done = 0;
	REG8(CAN_BASE+CAN_TX_BUF) = can_tx_data.identifier >> 3;
	REG8(CAN_BASE+CAN_TX_BUF+1) = (can_tx_data.identifier << 5) | ((can_tx_data.rtr << 4) & 0x10) | (can_tx_data.len & 0x0F);

	REG8(CAN_BASE+CAN_TX_BUF+2) = can_tx_data.data[0];
	REG8(CAN_BASE+CAN_TX_BUF+3) = can_tx_data.data[1];
	REG8(CAN_BASE+CAN_TX_BUF+4) = can_tx_data.data[2];
	REG8(CAN_BASE+CAN_TX_BUF+5) = can_tx_data.data[3];
	REG8(CAN_BASE+CAN_TX_BUF+6) = can_tx_data.data[4];
	REG8(CAN_BASE+CAN_TX_BUF+7) = can_tx_data.data[5];
	REG8(CAN_BASE+CAN_TX_BUF+8) = can_tx_data.data[6];
	REG8(CAN_BASE+CAN_TX_BUF+9) = can_tx_data.data[7];

	REG8(CAN_BASE+CAN_CMD) = CAN_CMD_TX_REQ;

	return can_tx_data.len;
}

void can_irq(void)
{
	unsigned char irq_req, rx_done;
	irq_req = REG8(CAN_BASE+IRQ_READ);
	rx_done = irq_req & CAN_IRQ_READ_RX;
	can_tx_done = irq_req & CAN_IRQ_READ_TX;
	if (rx_done)
		can_recv_basic();
}

void can_abort(void)
{
	REG8(CAN_BASE+CAN_CMD) = CAN_CMD_ABORT_TX;
}

