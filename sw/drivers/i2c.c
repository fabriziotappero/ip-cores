#include <support.h>
#include "interconnect.h"
#include "i2c.h"

int i2c_rd_done, i2c_wr_done;

int i2c_pending_write;

int i2c_rd_ptr, i2c_wr_ptr;

int i2c_buf_overflow;
i2c_type i2c_data[I2C_BUF_LEN];

unsigned char start, pointer_write, write_hbyte, write_lbyte, read_hbyte, read_lbyte;
unsigned char cmd_list[5];
unsigned char dat_list[5];
int i2c_index;
int i2c_end;

i2c_type * i2c_get(void)
{
	if ( !i2c_rd_done )
		return NULL;

	i2c_rd_done--;

	int tmp;
	tmp = i2c_rd_ptr;

	if (i2c_rd_ptr < I2C_BUF_LEN-1)
		i2c_rd_ptr++; 
	else
		i2c_rd_ptr = 0;

	return &i2c_data[tmp];
}

void i2c_init(void)
{
	REG8(I2C_BASE+I2C_PRESC_HI) = 0x00;
	REG8(I2C_BASE+I2C_PRESC_LO) = 49;       //100kHz
	REG8(I2C_BASE+I2C_CTR) = I2C_CTR_EN | I2C_CTR_IRQ_EN;
	i2c_rd_done = 0;
	i2c_wr_done = 0;
	i2c_index = 0;
	i2c_wr_ptr = 0;
	i2c_rd_ptr = 0;
	i2c_buf_overflow = 0;
}

void i2c_set_ack_lvl(int ack_lvl, int final_ack_lvl)
{
	int ack, final_ack;

	ack = ( ack_lvl ) ? I2C_CR_NACK : I2C_CR_ACK;
	final_ack = ( final_ack_lvl ) ? I2C_CR_NACK : I2C_CR_ACK;

	start = I2C_CR_STA | I2C_CR_WR | ack;
	pointer_write = I2C_CR_WR | ack;
	write_hbyte = I2C_CR_WR | ack;
	write_lbyte = I2C_CR_WR | I2C_CR_STO | final_ack;
	read_hbyte = I2C_CR_RD | ack;
	read_lbyte = I2C_CR_RD | I2C_CR_STO | final_ack;
}

void i2c_byte_transfer(void)
{
	if ( i2c_index > 0 )
		if ( cmd_list[i2c_index-1] == read_hbyte )
			i2c_data[i2c_wr_ptr].data = (REG8(I2C_BASE+I2C_RXR) << 8) & 0xFF00;

	REG8(I2C_BASE+I2C_TXR) = dat_list[i2c_index];
	REG8(I2C_BASE+I2C_CR) = cmd_list[i2c_index];

	i2c_index++;
}

void i2c_irq(void)
{
	REG8(I2C_BASE+I2C_CR) = I2C_CR_CLR_IRQ;
	if (i2c_index <= i2c_end )
		i2c_byte_transfer();
	else
	{
		if ( cmd_list[i2c_index-1] == read_lbyte )
			i2c_data[i2c_wr_ptr].data |= REG8(I2C_BASE+I2C_RXR);

		i2c_index = 0;

		if ( i2c_pending_write )
			i2c_wr_done = 1;
		else
		{
			if (i2c_wr_ptr < I2C_BUF_LEN-1)
				i2c_wr_ptr++;
			else
				i2c_wr_ptr = 0;

			if (i2c_wr_ptr == i2c_rd_ptr+1)
			{
				i2c_rd_done = 1;
				i2c_buf_overflow++;
			}
			else
				i2c_rd_done++;
		}
	}
}

int i2c_trans(i2c_mode * mode, i2c_type * data)
{
	if ( i2c_index != 0 )       //if previous command not fully processed, bail out
		return -1;

	i2c_wr_done = 0;

	int i = 0;

	if ( mode->ptr_set || mode->read_write )    //start conditions with pointer set: (write always set ptr)
	{
		dat_list[i] = (data->address << 1) & I2C_TXR_ADR;
		dat_list[i] |= I2C_TXR_W;
		cmd_list[i++] = start;

		dat_list[i] = data->pointer;
		cmd_list[i++] = pointer_write;

		if ( !mode->read_write )                //REstart for read, NO-REstart for write
		{
			dat_list[i] = (data->address << 1) & I2C_TXR_ADR;
			dat_list[i] |= I2C_TXR_R;
			cmd_list[i++] = start;
		}
	}
	else                    //start conditions with NO pointer set (read only): ONE start
	{
		dat_list[i] = (data->address << 1) & I2C_TXR_ADR;
		dat_list[i] |= I2C_TXR_R;
		cmd_list[i++] = start;
	}

	if ( mode->byte_word )  //read/write high byte
	{
		dat_list[i] = data->data >> 8;
		cmd_list[i++] = (mode->read_write) ? write_hbyte : read_hbyte;
	}

	dat_list[i] = data->data;   //read/write low byte
	cmd_list[i] = (mode->read_write) ? write_lbyte : read_lbyte;

	i2c_end = i;

	if ( !mode->read_write )    //set data to 0 for read, avoid or implications ((short)data |= byte)
	{
		i2c_data[i2c_wr_ptr] = *data;
		i2c_data[i2c_wr_ptr].data = 0x0000;
	}

	i2c_pending_write = mode->read_write;

	i2c_index = 0;
	i2c_byte_transfer();

	return mode->read_write+1;
}
