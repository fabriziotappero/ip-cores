/*
 * WISHBONE SD Card Controller IP Core
 *
 * ocsdc.c
 *
 * This file is part of the WISHBONE SD Card
 * Controller IP Core project
 * http://opencores.org/project,sd_card_controller
 *
 * Description
 * Driver for the WISHBONE SD Card Controller IP Core.
 *
 * Author(s):
 *     - Marek Czerski, ma.czerski@gmail.com
 */
/*
 *
 * Copyright (C) 2013 Authors
 *
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 *
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 *
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.opencores.org/lgpl.shtml
 */

#include "mmc.h"
#include <malloc.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <or1k-support.h>

// Register space
#define OCSDC_ARGUMENT           0x00
#define OCSDC_COMMAND            0x04
#define OCSDC_RESPONSE_1         0x08
#define OCSDC_RESPONSE_2         0x0c
#define OCSDC_RESPONSE_3         0x10
#define OCSDC_RESPONSE_4         0x14
#define OCSDC_CONTROL 			 0x1C
#define OCSDC_TIMEOUT            0x20
#define OCSDC_CLOCK_DIVIDER      0x24
#define OCSDC_SOFTWARE_RESET     0x28
#define OCSDC_POWER_CONTROL      0x2C
#define OCSDC_CAPABILITY         0x30
#define OCSDC_CMD_INT_STATUS     0x34
#define OCSDC_CMD_INT_ENABLE     0x38
#define OCSDC_DAT_INT_STATUS     0x3C
#define OCSDC_DAT_INT_ENABLE     0x40
#define OCSDC_BLOCK_SIZE         0x44
#define OCSDC_BLOCK_COUNT        0x48
#define OCSDC_DST_SRC_ADDR       0x60

// OCSDC_CMD_INT_STATUS bits
#define OCSDC_CMD_INT_STATUS_CC   0x0001
#define OCSDC_CMD_INT_STATUS_EI   0x0002
#define OCSDC_CMD_INT_STATUS_CTE  0x0004
#define OCSDC_CMD_INT_STATUS_CCRC 0x0008
#define OCSDC_CMD_INT_STATUS_CIE  0x0010

// SDCMSC_DAT_INT_STATUS
#define SDCMSC_DAT_INT_STATUS_TRS 0x01
#define SDCMSC_DAT_INT_STATUS_CRC 0x02
#define SDCMSC_DAT_INT_STATUS_OV  0x04

struct ocsdc {
	int iobase;
	int clk_freq;
};

#define readl(addr) (*(volatile unsigned int *) (addr))
#define writel(b, addr) ((*(volatile unsigned int *) (addr)) = (b))

void flush_dcache_range(void * start, void * end) {
	while (start < end) {
		or1k_dcache_flush((unsigned long)start);
		start += 4;
	}
}

static inline uint32_t ocsdc_read(struct ocsdc *dev, int offset)
{
	return readl(dev->iobase + offset);
}

static inline void ocsdc_write(struct ocsdc *dev, int offset, uint32_t data)
{
	writel(data, dev->iobase + offset);
}

static void ocsdc_set_buswidth(struct ocsdc * dev, uint width) {
	if (width == 4)
		ocsdc_write(dev, OCSDC_CONTROL, 1);
	else if (width == 1)
		ocsdc_write(dev, OCSDC_CONTROL, 0);
}

/* Set clock prescalar value based on the required clock in HZ */
static void ocsdc_set_clock(struct ocsdc * dev, uint clock)
{
	int clk_div = dev->clk_freq / (2.0 * clock) - 1;

	printf("ocsdc_set_clock %d, div %d\n\r", clock, clk_div);
	//software reset
	ocsdc_write(dev, OCSDC_SOFTWARE_RESET, 1);
	//set clock devider
	ocsdc_write(dev, OCSDC_CLOCK_DIVIDER, clk_div);
	//clear software reset
	ocsdc_write(dev, OCSDC_SOFTWARE_RESET, 0);
}

static int ocsdc_finish(struct ocsdc * dev, struct mmc_cmd *cmd) {

	int retval = 0;
	while (1) {
		int r2 = ocsdc_read(dev, OCSDC_CMD_INT_STATUS);
		//printf("ocsdc_finish: cmd %d, status %x\n", cmd->cmdidx, r2);
		if (r2 & OCSDC_CMD_INT_STATUS_EI) {
			//clear interrupts
			ocsdc_write(dev, OCSDC_CMD_INT_STATUS, 0);
			printf("ocsdc_finish: cmd %d, status %x\n\r", cmd->cmdidx, r2);
			retval = -1;
			break;
		}
		else if (r2 & OCSDC_CMD_INT_STATUS_CC) {
			//clear interrupts
			ocsdc_write(dev, OCSDC_CMD_INT_STATUS, 0);
			//get response
			cmd->response[0] = ocsdc_read(dev, OCSDC_RESPONSE_1);
			if (cmd->resp_type & MMC_RSP_136) {
				cmd->response[1] = ocsdc_read(dev, OCSDC_RESPONSE_2);
				cmd->response[2] = ocsdc_read(dev, OCSDC_RESPONSE_3);
				cmd->response[3] = ocsdc_read(dev, OCSDC_RESPONSE_4);
			}
			printf("ocsdc_finish:  %d ok\n\r", cmd->cmdidx);
			retval = 0;

			break;
		}
		//else if (!(r2 & OCSDC_CMD_INT_STATUS_CIE)) {
		//	printf("ocsdc_finish: cmd %d no exec %x\n", cmd->cmdidx, r2);
		//}
	}
	return retval;
}

static int ocsdc_data_finish(struct ocsdc * dev) {
	int status;

    while ((status = ocsdc_read(dev, OCSDC_DAT_INT_STATUS)) == 0);
    ocsdc_write(dev, OCSDC_DAT_INT_STATUS, 0);

    if (status & SDCMSC_DAT_INT_STATUS_TRS) {
    	printf("ocsdc_data_finish: ok\n\r");
    	return 0;
    }
    else {
    	printf("ocsdc_data_finish: status %x\n\r", status);
    	return -1;
    }
}

static void ocsdc_setup_data_xfer(struct ocsdc * dev, struct mmc_cmd *cmd, struct mmc_data *data) {

	//invalidate cache
	if (data->flags & MMC_DATA_READ) {
		flush_dcache_range(data->dest, data->dest+data->blocksize*data->blocks);
		ocsdc_write(dev, OCSDC_DST_SRC_ADDR, (uint32_t)data->dest);
	}
	else {
		flush_dcache_range((void *)data->src, (void *)data->src+data->blocksize*data->blocks);
		ocsdc_write(dev, OCSDC_DST_SRC_ADDR, (uint32_t)data->src);
	}
	ocsdc_write(dev, OCSDC_BLOCK_SIZE, data->blocksize);
	ocsdc_write(dev, OCSDC_BLOCK_COUNT, data->blocks-1);

	//printf("ocsdc_setup_read: addr: %x\n", (uint32_t)data->dest);

}

static int ocsdc_send_cmd(struct mmc *mmc, struct mmc_cmd *cmd, struct mmc_data *data)
{
	struct ocsdc * dev = mmc->priv;

	int command = (cmd->cmdidx << 8);
	if (cmd->resp_type & MMC_RSP_PRESENT) {
		if (cmd->resp_type & MMC_RSP_136)
			command |= 2;
		else {
			command |= 1;
		}
	}
	if (cmd->resp_type & MMC_RSP_BUSY)
		command |= (1 << 2);
	if (cmd->resp_type & MMC_RSP_CRC)
		command |= (1 << 3);
	if (cmd->resp_type & MMC_RSP_OPCODE)
		command |= (1 << 4);

	if (data && ((data->flags & MMC_DATA_READ) || ((data->flags & MMC_DATA_WRITE))) && data->blocks) {
		if (data->flags & MMC_DATA_READ)
			command |= (1 << 5);
		if (data->flags & MMC_DATA_WRITE)
			command |= (1 << 6);
		ocsdc_setup_data_xfer(dev, cmd, data);
	}

	printf("ocsdc_send_cmd %04x\n\r", command);

//	getc();

	ocsdc_write(dev, OCSDC_COMMAND, command);
	ocsdc_write(dev, OCSDC_ARGUMENT, cmd->cmdarg);

	if (ocsdc_finish(dev, cmd) < 0) return -1;
	if (data && data->blocks) return ocsdc_data_finish(dev);
	else return 0;
}

/* Initialize ocsdc controller */
static int ocsdc_init(struct mmc *mmc)
{
	struct ocsdc * dev = mmc->priv;

	//set timeout
	ocsdc_write(dev, OCSDC_TIMEOUT, 0x7FFF);
	//disable all interrupts
	ocsdc_write(dev, OCSDC_CMD_INT_ENABLE, 0);
	ocsdc_write(dev, OCSDC_DAT_INT_ENABLE, 0);
	//clear all interrupts
	ocsdc_write(dev, OCSDC_CMD_INT_STATUS, 0);
	ocsdc_write(dev, OCSDC_DAT_INT_STATUS, 0);
	//set clock to maximum (devide by 2)
	ocsdc_set_clock(dev, dev->clk_freq/2);

	return 0;
}

static void ocsdc_set_ios(struct mmc *mmc)
{
	/* Support only 4 bit if */
	ocsdc_set_buswidth(mmc->priv, mmc->bus_width);

	/* Set clock speed */
	if (mmc->clock)
		ocsdc_set_clock(mmc->priv, mmc->clock);
}

struct mmc * ocsdc_mmc_init(int base_addr, int clk_freq)
{
	struct mmc *mmc;
	struct ocsdc *priv;

	mmc = malloc(sizeof(struct mmc));
	if (!mmc) goto MMC_ALLOC;
	priv = malloc(sizeof(struct ocsdc));
	if (!priv) goto OCSDC_ALLOC;

	memset(mmc, 0, sizeof(struct mmc));
	memset(priv, 0, sizeof(struct ocsdc));

	priv->iobase = base_addr;
	priv->clk_freq = clk_freq;

	sprintf(mmc->name, "ocsdc");
	mmc->priv = priv;
	mmc->send_cmd = ocsdc_send_cmd;
	mmc->set_ios = ocsdc_set_ios;
	mmc->init = ocsdc_init;
	mmc->getcd = NULL;

	mmc->f_min = priv->clk_freq/6; /*maximum clock division 64 */
	mmc->f_max = priv->clk_freq/2; /*minimum clock division 2 */
	mmc->voltages = MMC_VDD_32_33 | MMC_VDD_33_34;
	mmc->host_caps = MMC_MODE_4BIT;//MMC_MODE_HS | MMC_MODE_HS_52MHz | MMC_MODE_4BIT;

	mmc->b_max = 256;

	return mmc;

OCSDC_ALLOC:
	free(mmc);
MMC_ALLOC:
	return NULL;
}
