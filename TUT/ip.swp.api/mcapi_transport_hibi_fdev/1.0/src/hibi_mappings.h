/*
 * hibi_mappings.c
 *
 *  Created on: 10.4.2013
 *      Author: matilail
 */


#ifndef __HIBI_MAPPINGS_H__
#define __HIBI_MAPPINGS_H__

#define FDEV_COUNT (4)
#define DEVNAME /dev/hibi_pe_dma0

// Filenames for hibi endpoints indices are same as MCAPI node ids
const char* dev_names[FDEV_COUNT] = {"/dev/hibi_pe_dma_0/cpu0",
									"/dev/hibi_pe_dma_0/cpu1",
									"/dev/hibi_pe_dma_0/buttons",
									"/dev/hibi_pe_dma_0/leds"};

int fdevs[FDEV_COUNT] = {0};

const int   hibiBaseAddresses[FDEV_COUNT] = {0x01000000, 0x03000000, 0x05000000, 0x07000000};
const int   hibiEndAddresses[FDEV_COUNT]  = {0x03000000-1, 0x05000000-1, 0x07000000-1, 0x09000000-1};


#endif
