/*
 * OpenCores tiny SPI master driver
 *
 * http://opencores.org/project,tiny_spi
 *
 * Copyright (C) 2011 Thomas Chou <thomas@wytron.com.tw>
 *
 * Based on spi_s3c24xx.c, which is:
 * Copyright (c) 2006 Ben Dooks
 * Copyright (c) 2006 Simtec Electronics
 *	Ben Dooks <ben@simtec.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/init.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>
#include <linux/delay.h>
#include <linux/errno.h>
#include <linux/err.h>
#include <linux/clk.h>
#include <linux/platform_device.h>
#include <linux/spi/spi.h>
#include <linux/spi/spi_bitbang.h>
#include <linux/spi/oc_tiny_spi.h>
#include <linux/io.h>
#include <linux/gpio.h>
#include <linux/of.h>

#define DRV_NAME "oc_tiny_spi"

#define TINY_SPI_RXDATA 0
#define TINY_SPI_TXDATA 4
#define TINY_SPI_STATUS 8
#define TINY_SPI_CONTROL 12
#define TINY_SPI_BAUD 16

#define TINY_SPI_STATUS_TXE 0x1
#define TINY_SPI_STATUS_TXR 0x2

struct tiny_spi {
	/* bitbang has to be first */
	struct spi_bitbang bitbang;
	struct completion done;

	void __iomem *base;
	int irq;
	unsigned int freq;
	unsigned int baudwidth;
	int interrupt; /* use interrupt driven data transfer, slow */
	unsigned int baud;
	unsigned int speed_hz;
	unsigned int mode;
	unsigned int len;
	unsigned int txc, rxc;
	const u8 *txp;
	u8 *rxp;
};

static inline struct tiny_spi *to_hw(struct spi_device *sdev)
{
	return spi_master_get_devdata(sdev->master);
}

static unsigned int tiny_spi_baud(struct spi_device *spi, unsigned int hz)
{
	struct tiny_spi *hw = to_hw(spi);

	return min(DIV_ROUND_UP(hw->freq, hz * 2), (1U << hw->baudwidth)) - 1;
}

static void tiny_spi_chipselect(struct spi_device *spi, int is_active)
{
	gpio_set_value(spi->chip_select,
		       (spi->mode & SPI_CS_HIGH) ? is_active : !is_active);
}

static int tiny_spi_setup_transfer(struct spi_device *spi,
				   struct spi_transfer *t)
{
	struct tiny_spi *hw = to_hw(spi);
	unsigned int baud = hw->baud;

	if (t) {
		if (t->speed_hz && t->speed_hz != hw->speed_hz)
			baud = tiny_spi_baud(spi, t->speed_hz);
	}
	writel(baud, hw->base + TINY_SPI_BAUD);
	writel(hw->mode, hw->base + TINY_SPI_CONTROL);
	return 0;
}

static int tiny_spi_setup(struct spi_device *spi)
{
	struct tiny_spi *hw = to_hw(spi);

	if (spi->max_speed_hz != hw->speed_hz) {
		hw->speed_hz = spi->max_speed_hz;
		hw->baud = tiny_spi_baud(spi, hw->speed_hz);
	}
	hw->mode = spi->mode & (SPI_CPOL | SPI_CPHA);
	return 0;
}

#ifndef CONFIG_TINY_SPI_IDLE_VAL
# define CONFIG_TINY_SPI_IDLE_VAL 0x00
#endif

static int tiny_spi_txrx_bufs(struct spi_device *spi, struct spi_transfer *t)
{
	struct tiny_spi *hw = to_hw(spi);
	const u8 *txp = t->tx_buf;
	u8 *rxp = t->rx_buf;
	unsigned int i;

	if (hw->irq >= 0 && hw->interrupt) {
		/* use intrrupt driven data transfer */
		hw->len = t->len;
		hw->txp = t->tx_buf;
		hw->rxp = t->rx_buf;
		hw->txc = 0;
		hw->rxc = 0;
		init_completion(&hw->done);

		/* send the first byte */
		if (t->len > 1) {
			writeb(hw->txp ? *hw->txp++ : CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			hw->txc++;
			writeb(hw->txp ? *hw->txp++ : CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			hw->txc++;
			writeb(TINY_SPI_STATUS_TXR, hw->base + TINY_SPI_STATUS);
		} else {
			writeb(hw->txp ? *hw->txp++ : CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			hw->txc++;
			writeb(TINY_SPI_STATUS_TXE, hw->base + TINY_SPI_STATUS);
		}

		wait_for_completion(&hw->done);
	} else if (txp && rxp) {
		/* we need to tighten the transfer loop */
		writeb(*txp++, hw->base + TINY_SPI_TXDATA);
		if (t->len > 1) {
			writeb(*txp++, hw->base + TINY_SPI_TXDATA);
			for (i = 2; i < t->len; i++) {
				u8 rx, tx = *txp++;
				while (!(readb(hw->base + TINY_SPI_STATUS) &
					 TINY_SPI_STATUS_TXR))
					cpu_relax();
				rx = readb(hw->base + TINY_SPI_TXDATA);
				writeb(tx, hw->base + TINY_SPI_TXDATA);
				*rxp++ = rx;
			}
			while (!(readb(hw->base + TINY_SPI_STATUS) &
				 TINY_SPI_STATUS_TXR))
				cpu_relax();
			*rxp++ = readb(hw->base + TINY_SPI_TXDATA);
		}
		while (!(readb(hw->base + TINY_SPI_STATUS) &
			 TINY_SPI_STATUS_TXE))
			cpu_relax();
		*rxp++ = readb(hw->base + TINY_SPI_RXDATA);
	} else if (rxp) {
		writeb(CONFIG_TINY_SPI_IDLE_VAL, hw->base + TINY_SPI_TXDATA);
		if (t->len > 1) {
			writeb(CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			for (i = 2; i < t->len; i++) {
				u8 rx;
				while (!(readb(hw->base + TINY_SPI_STATUS) &
					 TINY_SPI_STATUS_TXR))
					cpu_relax();
				rx = readb(hw->base + TINY_SPI_TXDATA);
				writeb(CONFIG_TINY_SPI_IDLE_VAL,
				       hw->base + TINY_SPI_TXDATA);
				*rxp++ = rx;
			}
			while (!(readb(hw->base + TINY_SPI_STATUS) &
				 TINY_SPI_STATUS_TXR))
				cpu_relax();
			*rxp++ = readb(hw->base + TINY_SPI_TXDATA);
		}
		while (!(readb(hw->base + TINY_SPI_STATUS) &
			 TINY_SPI_STATUS_TXE))
			cpu_relax();
		*rxp++ = readb(hw->base + TINY_SPI_RXDATA);
	} else if (txp) {
		writeb(*txp++, hw->base + TINY_SPI_TXDATA);
		if (t->len > 1) {
			writeb(*txp++, hw->base + TINY_SPI_TXDATA);
			for (i = 2; i < t->len; i++) {
				u8 tx = *txp++;
				while (!(readb(hw->base + TINY_SPI_STATUS) &
					 TINY_SPI_STATUS_TXR))
					cpu_relax();
				writeb(tx, hw->base + TINY_SPI_TXDATA);
			}
		}
		while (!(readb(hw->base + TINY_SPI_STATUS) &
			 TINY_SPI_STATUS_TXE))
			cpu_relax();
	} else {
		writeb(CONFIG_TINY_SPI_IDLE_VAL, hw->base + TINY_SPI_TXDATA);
		if (t->len > 1) {
			writeb(CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			for (i = 2; i < t->len; i++) {
				while (!(readb(hw->base + TINY_SPI_STATUS) &
					 TINY_SPI_STATUS_TXR))
					cpu_relax();
				writeb(CONFIG_TINY_SPI_IDLE_VAL,
				       hw->base + TINY_SPI_TXDATA);
			}
		}
		while (!(readb(hw->base + TINY_SPI_STATUS) &
			 TINY_SPI_STATUS_TXE))
			cpu_relax();
	}
	return t->len;
}

static irqreturn_t tiny_spi_irq(int irq, void *dev)
{
	struct tiny_spi *hw = dev;

	writeb(0, hw->base + TINY_SPI_STATUS);
	if (hw->rxc + 1 == hw->len) {
		if (hw->rxp)
			*hw->rxp++ = readb(hw->base + TINY_SPI_RXDATA);
		hw->rxc++;
		complete(&hw->done);
	} else {
		if (hw->rxp)
			*hw->rxp++ = readb(hw->base + TINY_SPI_TXDATA);
		hw->rxc++;
		if (hw->txc < hw->len) {
			writeb(hw->txp ? *hw->txp++ : CONFIG_TINY_SPI_IDLE_VAL,
			       hw->base + TINY_SPI_TXDATA);
			hw->txc++;
			writeb(TINY_SPI_STATUS_TXR,
			       hw->base + TINY_SPI_STATUS);
		} else {
			writeb(TINY_SPI_STATUS_TXE,
			       hw->base + TINY_SPI_STATUS);
		}
	}
	return IRQ_HANDLED;
}

#ifdef CONFIG_OF
static int __devinit tiny_spi_of_probe(struct platform_device *pdev,
				       struct tiny_spi *hw)
{
	const __be32 *val;

	hw->bitbang.master->dev.of_node = pdev->dev.of_node;
	val = of_get_property(pdev->dev.of_node, "baud-width", NULL);
	if (val)
		hw->baudwidth = be32_to_cpup(val);
	val = of_get_property(pdev->dev.of_node, "clock-frequency", NULL);
	if (val)
		hw->freq = be32_to_cpup(val);
	val = of_get_property(pdev->dev.of_node, "interrupt-driven", NULL);
	if (val)
		hw->interrupt = be32_to_cpup(val);
	return 0;
}
#else
static int __devinit tiny_spi_of_probe(struct platform_device *pdev,
				       struct tiny_spi *hw)
{
	return 0;
}
#endif

static int __devinit tiny_spi_probe(struct platform_device *pdev)
{
	struct tiny_spi_platform_data *platp = pdev->dev.platform_data;
	struct tiny_spi *hw;
	struct spi_master *master;
	struct resource *res;
	int err = 0;

	master = spi_alloc_master(&pdev->dev, sizeof(struct tiny_spi));
	if (master == NULL) {
		dev_err(&pdev->dev, "No memory for spi_master\n");
		err = -ENOMEM;
		goto err_no_mem;
	}

	/* setup the master state. */
	master->bus_num = pdev->id;
	master->num_chipselect = 255;
	master->mode_bits = SPI_CPOL | SPI_CPHA | SPI_CS_HIGH;
	master->setup = tiny_spi_setup;

	hw = spi_master_get_devdata(master);
	platform_set_drvdata(pdev, hw);

	/* setup the state for the bitbang driver */
	hw->bitbang.master = spi_master_get(master);
	if (hw->bitbang.master == NULL) {
		dev_err(&pdev->dev, "Cannot get device\n");
		err = -ENODEV;
		goto err_no_dev;
	}
	hw->bitbang.setup_transfer = tiny_spi_setup_transfer;
	hw->bitbang.chipselect = tiny_spi_chipselect;
	hw->bitbang.txrx_bufs = tiny_spi_txrx_bufs;

	/* find and map our resources */
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (res == NULL) {
		dev_err(&pdev->dev, "Cannot get IORESOURCE_MEM\n");
		err = -ENOENT;
		goto err_no_iores;
	}
	hw->base = ioremap(res->start, (res->end - res->start) + 1);
	if (hw->base == 0) {
		dev_err(&pdev->dev, "Cannot map IO\n");
		err = -ENXIO;
		goto err_no_iomap;
	}
	/* irq is optional */
	hw->irq = platform_get_irq(pdev, 0);
	if (hw->irq >= 0) {
		init_completion(&hw->done);
		err = request_irq(hw->irq, tiny_spi_irq, 0, pdev->name, hw);
		if (err) {
			dev_err(&pdev->dev, "Cannot claim IRQ\n");
			goto err_no_irq;
		}
	}
	/* find platform data */
	if (platp) {
		hw->freq = platp->freq;
		hw->baudwidth = platp->baudwidth;
		hw->interrupt = platp->interrupt;
	} else {
		err = tiny_spi_of_probe(pdev, hw);
		if (err)
			goto err_no_of;
	}

	/* register our spi controller */
	err = spi_bitbang_start(&hw->bitbang);
	if (err) {
		dev_err(&pdev->dev, "Failed to register SPI master\n");
		goto err_register;
	}
	dev_info(&pdev->dev, "base %p, irq %d\n", hw->base, hw->irq);

	return 0;

err_register:
	if (hw->irq >= 0)
		free_irq(hw->irq, hw);
err_no_irq:
	iounmap((void *)hw->base);
err_no_iomap:
err_no_iores:
	spi_master_put(master);
err_no_mem:
err_no_of:
err_no_dev:
	return err;
}

static int __devexit tiny_spi_remove(struct platform_device *dev)
{
	struct tiny_spi *hw = platform_get_drvdata(dev);
	struct spi_master *master = hw->bitbang.master;

	spi_bitbang_stop(&hw->bitbang);

	if (hw->irq >= 0)
		free_irq(hw->irq, hw);
	iounmap((void *)hw->base);

	platform_set_drvdata(dev, NULL);
	spi_master_put(master);
	return 0;
}

#ifdef CONFIG_OF
static struct of_device_id oc_tiny_spi_match[] = {
	{
		.compatible = "opencores,oc_tiny_spi",
	},
	{},
}
MODULE_DEVICE_TABLE(of, oc_tiny_spi_match);
#endif

static struct platform_driver tiny_spidrv = {
	.remove = __devexit_p(tiny_spi_remove),
	.driver = {
		.name = DRV_NAME,
		.owner = THIS_MODULE,
		.pm = NULL,
#ifdef CONFIG_OF
		.of_match_table = oc_tiny_spi_match,
#endif
	},
};

static int __init tiny_spi_init(void)
{
	return platform_driver_probe(&tiny_spidrv, tiny_spi_probe);
}

static void __exit tiny_spi_exit(void)
{
	platform_driver_unregister(&tiny_spidrv);
}

module_init(tiny_spi_init);
module_exit(tiny_spi_exit);

MODULE_DESCRIPTION("OpenCores tiny SPI driver");
MODULE_AUTHOR("Thomas Chou <thomas@wytron.com.tw>");
MODULE_LICENSE("GPL");
MODULE_ALIAS("platform:" DRV_NAME);
