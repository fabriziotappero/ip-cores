/*
 * Empty C++ Application
 */

#include <stdio.h>

#include "xil_types.h"
#include "xparameters.h"
#include "xdmacentral.h"

#define DMA_DEVICE_ID			XPAR_DMACENTRAL_0_DEVICE_ID

#define DMA_BUFFER_BYTE_SIZE	4096

static XDmaCentral Dma;

u32 * pSpiifcBase = (u32 *)0x85000000;
u32 * pMosiBase   = (u32 *)0x85010000;
u32 * pMisoBase   = (u32 *)0x85011000;

//
// Initializes DMA controller
//
int InitDma();

//
// Copies a block of data between two burst-mode enabled memory regions. Uses
// XPS Central DMA controller. Function spins while waiting for copy to complete.
//
int DmaCopy(void * pSrc, void * pDest, size_t byteCount);

//
// Writes to the three memmap regions in the Spiifc peripheral
// (regs, mosi/miso buffers). Verifies the writes stuck using a read.
//
void SpiifcPioTest();

//
// DMA copies from mosi to miso buffers and verifies result using PIO.
//
void SpiifcDmaTest();

//
// InitDma - Initializes DMA controller
//
int InitDma()
{
	XDmaCentral_Config *pDmaCfg;
	int status;

	// Configure DMA controller
	pDmaCfg = XDmaCentral_LookupConfig(DMA_DEVICE_ID);
	if (NULL == pDmaCfg) { return XST_FAILURE; }
	status = XDmaCentral_CfgInitialize(&Dma, pDmaCfg, pDmaCfg->BaseAddress);
	if (XST_SUCCESS != status) { return status; }

	// Reset DMAC
	XDmaCentral_Reset(&Dma);

	// Setup DMAC control register to increment src & dest addr
	XDmaCentral_SetControl(
			&Dma,
			XDMC_DMACR_SOURCE_INCR_MASK | XDMC_DMACR_DEST_INCR_MASK);

	// DMAC does not raise interrupts (when transfer completes)
	XDmaCentral_InterruptEnableSet(&Dma, 0);

	return XST_SUCCESS;
}

int DmaCopy(void * pSrc, void * pDest, size_t byteCount)
{
	u32 regValue;
	XDmaCentral_Transfer(&Dma, pSrc, pDest, byteCount);
	do {	// Wait for DMA transfer to complete
		regValue = XDmaCentral_GetStatus(&Dma);
	} while ((regValue & XDMC_DMASR_BUSY_MASK) == XDMC_DMASR_BUSY_MASK);
	if (regValue & XDMC_DMASR_BUS_ERROR_MASK) {
		xil_printf("DMA_BUS_ERROR\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

int main()
{
	int status, i;

	// Initialize system
	if (XST_SUCCESS != (status = InitDma())) {
		xil_printf("[FAIL] InitDma() failed. Exiting.\n");
		return status;
	}

	// Perform Programmed IO tests
	SpiifcPioTest();

	// Test DMA
	SpiifcDmaTest();

	// Spiifc loopback: anything sent to spiifc is sent back
	while (1) {

//		//
//		// Print values of all SPI registers
//		//
//		for (i = 0; i < 16; i++) {
//			xil_printf("Reg%d=0x%08x\n", i, pSpiifcBase[i]);
//		}

		// Wait for M->S transfer to complete
		//xil_printf("Waiting for M->S transfer to complete..\n");
		while(0 == (pSpiifcBase[0] & 0x1)) { ; }
		pSpiifcBase[0] &= (~0x1);		// Handling MOSI transfer completion

		// Initiating DMA transfer
		//xil_printf("DMA MOSI buffer to MISO buffer\n");
		DmaCopy(pMosiBase, pMisoBase, 4096);

		// DMA done, set flag for master
		//xil_printf("DMA completed\n");
		pSpiifcBase[0] |= 0x2;

	}

	/*
	int i = 0;
	for (i = 0; i < 40000000; i++) { ; }
	for (i = 0; i < 1024; i++) {
		xil_printf("pMOSI[i] = 0x%08X\n", pMosiBase[i]);
	}
	*/
}

void SpiifcPioTest()
{
	int i = 0;

	xil_printf("Testing Spiifc PIO...\n");

	// PIO Write to Spiifc memmap regions
	pSpiifcBase[0] = 0x87654321;
    pMosiBase[0] = 0x12345678;
    pMisoBase[0] = 0xFEEDFACE;
    pMisoBase[1] = 0xBEEFBABE;
    pMisoBase[2] = 0xBEEFBEEF;

	xil_printf("Reg0 @ 0x%08X: verifying PIO... ", pSpiifcBase);
	if (0x87654321 == *pSpiifcBase) {
		xil_printf("[PASS]\n");
	} else {
		xil_printf("[FAIL] (actual=0x%08X)\n", *pSpiifcBase);
	}

	xil_printf("MOSI @ 0x%08X: verifying PIO... ", pMosiBase);
    if (0x12345678 == *pMosiBase) {
    	xil_printf("[PASS]\n");
    } else {
    	xil_printf("[FAIL] (actual=0x%08X)\n", *pMosiBase);
    }

    xil_printf("MISO @ 0x%08X: verifying PIO... ", pMisoBase);
    if (0xFEEDFACE == *pMisoBase) {
    	xil_printf("[PASS]\n");
    } else {
    	xil_printf("[FAIL] (actual=0x%08X)\n", *pMisoBase);
    }

	for (i = 0; i < 16; i++) {
		pSpiifcBase[i] = (i << 24) | (i << 16) | (i << 8) | i;
	}
	for (i = 0; i < 16; i++) {
		xil_printf("Reg%d=0x%08x\n", i, pSpiifcBase[i]);
	}

    xil_printf("\n");
}

void SpiifcDmaTest()
{
	int status;
	u32 i;

	// Pattern DMA memory buffer
	for(i = 0; i < DMA_BUFFER_BYTE_SIZE/4; i++) {

		pMosiBase[i] = ((i*4+3) & 0xFF) << 24 |
				       ((i*4+2) & 0xFF) << 16 |
				       ((i*4+1) & 0xFF) << 8  |
				       ((i*4+0) & 0xFF);

		//pMosiBase[i] = 0xAABBCCDD;
		//xil_printf("0x%08X\n", pMosiBase[i]);
	}

	// DMA buffer to Spiifc.MISO buffer
	if (XST_SUCCESS != (status =
			DmaCopy(pMosiBase, pMisoBase, DMA_BUFFER_BYTE_SIZE))) {
		xil_printf("[FAIL] DmaCopy() failed. Exiting.\n");
	}

	// Check DMAC copied Spiifc.MOSI --> Spiifc.MISO buffer
	u32 expectedDmaWord = 0;
	int failWords = 0;
	for (i = 0; i < (DMA_BUFFER_BYTE_SIZE/4); i++) {
		expectedDmaWord = ((i*4+3) & 0xFF) << 24 |
				          ((i*4+2) & 0xFF) << 16 |
				          ((i*4+1) & 0xFF) << 8  |
				          ((i*4+0) & 0xFF) << 0;

		if (pMisoBase[i] != expectedDmaWord) {
			xil_printf(
					"[FAIL] DMA mem word [i]: expected=0x%08X, actual=0x%08X\n",
					expectedDmaWord, pMisoBase[i]);
		}
	}
	if (0 == failWords) {
		xil_printf("[PASS] DMA transfer from MOSI to MISO memory\n");
	}
}
