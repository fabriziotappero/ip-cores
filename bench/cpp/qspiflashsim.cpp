///////////////////////////////////////////////////////////////////////////
//
//
// Filename: 	spiflashsim.cpp
//
// Project:	Wishbone Controlled Quad SPI Flash Controller
//
// Purpose:	This library simulates the operation of a Quad-SPI commanded
//		flash, such as the S25FL032P used on the Basys-3 development
//		board by Digilent.  As such, it is defined by 32 Mbits of
//		memory (4 Mbyte).
//
//		This simulator is useful for testing in a Verilator/C++
//		environment, where this simulator can be used in place of
//		the actual hardware.
//
// Creator:	Dan Gisselquist
//		Gisselquist Tecnology, LLC
//
///////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
///////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#include "qspiflashsim.h"

#define	MEMBYTES	(1<<22)

static	const unsigned	DEVID = 0x0115,
	DEVESD = 0x014,
	MICROSECONDS = 100,
	MILLISECONDS = MICROSECONDS * 1000,
	SECONDS = MILLISECONDS * 1000,
	tW     =   50 * MICROSECONDS, // write config cycle time
	tBE    =   32 * SECONDS,
	tDP    =   10 * SECONDS,
	tRES   =   30 * SECONDS,
// Shall we artificially speed up this process?
	tPP    = 12 * MICROSECONDS,
	tSE    = 15 * MILLISECONDS;
// or keep it at the original speed
	// tPP    = 1200 * MICROSECONDS,
	// tSE    = 1500 * MILLISECONDS;

QSPIFLASHSIM::QSPIFLASHSIM(void) {
	m_mem = new char[MEMBYTES];
	m_pmem = new char[256];
	m_state = QSPIF_IDLE;
	m_last_sck = 1;
	m_write_count = 0;
	m_ireg = m_oreg = 0;
	m_sreg = 0x01c;
	m_creg = 0x001;	// Iinitial creg on delivery
	m_quad_mode = false;
	m_mode_byte = 0;

	memset(m_mem, 0x0ff, MEMBYTES);
}

void	QSPIFLASHSIM::load(const char *fname) {
	FILE	*fp;
	int	nr = 0;

	if (NULL != (fp = fopen(fname, "r"))) {
		nr = fread(m_mem, sizeof(char), MEMBYTES, fp);
		fclose(fp);
	} else {
		fprintf(stderr, "SPI-FLASH: Could not open %s\n", fname);
		perror("O/S Err:");
	}

	for(int i=nr; i<MEMBYTES; i++)
		m_mem[i] = 0x0ff;
}

#define	QOREG(A)	m_oreg = ((m_oreg & (~0x0ff))|(A&0x0ff))

int	QSPIFLASHSIM::operator()(const int csn, const int sck, const int dat) {
	// Keep track of a timer to determine when page program and erase
	// cycles complete.

	if (m_write_count > 0) {
		if (0 == (--m_write_count)) {// When done with erase/page pgm,
			m_sreg &= 0x0fc; // Clear the write in progress bit
			if (m_debug) printf("Write complete, clearing WIP (inside SIM)\n");
		}
	}

	if (csn) {
		m_last_sck = 1;
		m_ireg = 0; m_oreg = 0;
		m_count= 0;

		if ((QSPIF_PP == m_state)||(QSPIF_QPP == m_state)) {
			// Start a page program
			if (m_debug) printf("QSPI: Page Program write cycle begins\n");
			if (m_debug) printf("CK = %d & 7 = %d\n", m_count, m_count & 0x07);
			if (m_debug) printf("QSPI: pmem = %08lx\n", (unsigned long)m_pmem);
			m_write_count = tPP;
			m_state = QSPIF_IDLE;
			m_sreg &= (~QSPIF_WEL_FLAG);
			m_sreg |= (QSPIF_WIP_FLAG);
			for(int i=0; i<256; i++) {
				/*
				if (m_debug) printf("%02x: m_mem[%02x] = %02x &= %02x = %02x\n",
					i, (m_addr&(~0x0ff))+i,
					m_mem[(m_addr&(~0x0ff))+i]&0x0ff, m_pmem[i]&0x0ff,
					m_mem[(m_addr&(~0x0ff))+i]& m_pmem[i]&0x0ff);
				*/
				m_mem[(m_addr&(~0x0ff))+i] &= m_pmem[i];
			}
			m_quad_mode = false;
		} else if (m_state == QSPIF_SECTOR_ERASE) {
			if (m_debug) printf("Actually Erasing sector, from %08x\n", m_addr);
			m_write_count = tSE;
			m_state = QSPIF_IDLE;
			m_sreg &= (~QSPIF_WEL_FLAG);
			m_sreg |= (QSPIF_WIP_FLAG);
			m_addr &= (-1<<16);
			for(int i=0; i<(1<<16); i++)
				m_mem[m_addr + i] = 0x0ff;
			if (m_debug) printf("Now waiting %d ticks delay\n", m_write_count);
		} else if (QSPIF_WRSR == m_state) {
			if (m_debug) printf("Actually writing status register\n");
			m_write_count = tW;
			m_state = QSPIF_IDLE;
			m_sreg &= (~QSPIF_WEL_FLAG);
			m_sreg |= (QSPIF_WIP_FLAG);
		} else if (QSPIF_CLSR == m_state) {
			if (m_debug) printf("Actually clearing the status register bits\n");
			m_state = QSPIF_IDLE;
			m_sreg &= 0x09f;
		} else if (m_state == QSPIF_BULK_ERASE) {
			m_write_count = tBE;
			m_state = QSPIF_IDLE;
			m_sreg &= (~QSPIF_WEL_FLAG);
			m_sreg |= (QSPIF_WIP_FLAG);
			for(int i=0; i<MEMBYTES; i++)
				m_mem[i] = 0x0ff;
		} else if (m_state == QSPIF_DEEP_POWER_DOWN) {
			m_write_count = tDP;
			m_state = QSPIF_IDLE;
		} else if (m_state == QSPIF_RELEASE) {
			m_write_count = tRES;
			m_state = QSPIF_IDLE;
		} else if (m_state == QSPIF_QUAD_READ_CMD) {
			if ((m_mode_byte & 0x0f0)!=0x0a0)
				m_quad_mode = false;
			else
				m_state = QSPIF_QUAD_READ_IDLE;
		} else if (m_state == QSPIF_QUAD_READ) {
			if ((m_mode_byte & 0x0f0)!=0x0a0)
				m_quad_mode = false;
			else
				m_state = QSPIF_QUAD_READ_IDLE;
		} else if (m_state == QSPIF_QUAD_READ_IDLE) {
		}

		m_oreg = 0x0fe;
		return dat;
	} else if ((!m_last_sck)||(sck == m_last_sck)) {
		// Only change on the falling clock edge
		// printf("SFLASH-SKIP, CLK=%d -> %d\n", m_last_sck, sck);
		m_last_sck = sck;
		if (m_quad_mode)
			return (m_oreg>>8)&0x0f;
		else
			// return ((m_oreg & 0x0100)?2:0) | (dat & 0x0d);
			return (m_oreg & 0x0100)?2:0;
	}

	// We'll only get here if ...
	//	last_sck = 1, and sck = 0, thus transitioning on the
	//	negative edge as with everything else in this interface
	if (m_quad_mode) {
		m_ireg = (m_ireg << 4) | (dat & 0x0f);
		m_count+=4;
		m_oreg <<= 4;
	} else {
		m_ireg = (m_ireg << 1) | (dat & 1);
		m_count++;
		m_oreg <<= 1;
	}


	// printf("PROCESS, COUNT = %d, IREG = %02x\n", m_count, m_ireg);
	if (m_state == QSPIF_QUAD_READ_IDLE) {
		assert(m_quad_mode);
		if (m_count == 24) {
			if (m_debug) printf("QSPI: Entering from Quad-Read Idle to Quad-Read\n");
			if (m_debug) printf("QSPI: QI/O Idle Addr = %02x\n", m_ireg&0x0ffffff);
			m_addr = (m_ireg) & 0x0ffffff;
			assert((m_addr & 0xfc00000)==0);
			m_state = QSPIF_QUAD_READ;
		} m_oreg = 0;
	} else if (m_count == 8) {
		QOREG(0x0a5);
		// printf("SFLASH-CMD = %02x\n", m_ireg & 0x0ff);
		// Figure out what command we've been given
		if (m_debug) printf("SPI FLASH CMD %02x\n", m_ireg&0x0ff);
		switch(m_ireg & 0x0ff) {
		case 0x01: // Write status register
			if (2 !=(m_sreg & 0x203)) {
				if (m_debug) printf("QSPI: WEL not set, cannot write status reg\n");
				m_state = QSPIF_INVALID;
			} else
				m_state = QSPIF_WRSR;
			break;
		case 0x02: // Page program
			if (2 != (m_sreg & 0x203)) {
				if (m_debug) printf("QSPI: Cannot program at this time, SREG = %x\n", m_sreg);
				m_state = QSPIF_INVALID;
			} else {
				m_state = QSPIF_PP;
				if (m_debug) printf("PAGE-PROGRAM COMMAND ACCEPTED\n");
			}
			break;
		case 0x03: // Read data bytes
			// Our clock won't support this command, so go
			// to an invalid state
			if (m_debug) printf("QSPI INVALID: This sim does not support slow reading\n");
			m_state = QSPIF_INVALID;
			break;
		case 0x04: // Write disable
			m_state = QSPIF_IDLE;
			m_sreg &= (~QSPIF_WEL_FLAG);
			break;
		case 0x05: // Read status register
			m_state = QSPIF_RDSR;
			if (m_debug) printf("QSPI: READING STATUS REGISTER: %02x\n", m_sreg);
			QOREG(m_sreg);
			break;
		case 0x06: // Write enable
			m_state = QSPIF_IDLE;
			m_sreg |= QSPIF_WEL_FLAG;
			if (m_debug) printf("QSPI: WRITE-ENABLE COMMAND ACCEPTED\n");
			break;
		case 0x0b: // Here's the read that we support
			if (m_debug) printf("QSPI: FAST-READ (single-bit)\n");
			m_state = QSPIF_FAST_READ;
			break;
		case 0x30:
			if (m_debug) printf("QSPI: CLEAR STATUS REGISTER COMMAND\n");
			m_state = QSPIF_CLSR;
			break;
		case 0x32: // QUAD Page program, 4 bits at a time
			if (2 != (m_sreg & 0x203)) {
				if (m_debug) printf("QSPI: Cannot program at this time, SREG = %x\n", m_sreg);
				m_state = QSPIF_INVALID;
			} else {
				m_state = QSPIF_QPP;
				if (m_debug) printf("QSPI: QUAD-PAGE-PROGRAM COMMAND ACCEPTED\n");
				if (m_debug) printf("QSPI: pmem = %08lx\n", (unsigned long)m_pmem);
			}
			break;
		case 0x35: // Read configuration register
			m_state = QSPIF_RDCR;
			if (m_debug) printf("QSPI: READING CONFIGURATION REGISTER: %02x\n", m_creg);
			QOREG(m_creg);
			break;
		case 0x9f: // Read ID
			m_state = QSPIF_RDID;
			if (m_debug) printf("QSPI: READING ID, %02x\n", (DEVID>>24)&0x0ff);
			QOREG(0xfe);
			break;
		case 0xab: // Release from DEEP POWER DOWN
			if (m_sreg & QSPIF_DEEP_POWER_DOWN_FLAG) {
				if (m_debug) printf("QSPI: Release from deep power down\n");
				m_sreg &= (~QSPIF_DEEP_POWER_DOWN_FLAG);
				m_write_count = tRES;
			} m_state = QSPIF_RELEASE;
			break;
		case 0xb9: // DEEP POWER DOWN
			if (0 != (m_sreg & 0x01)) {
				if (m_debug) printf("QSPI: Cannot enter DEEP POWER DOWN, in middle of write/erase\n");
				m_state = QSPIF_INVALID;
			} else {
				m_sreg  |= QSPIF_DEEP_POWER_DOWN_FLAG;
				m_state  = QSPIF_IDLE;
			}
			break;
		case 0xc7: // Bulk Erase
			if (2 != (m_sreg & 0x203)) {
				if (m_debug) printf("QSPI: WEL not set, cannot erase device\n");
				m_state = QSPIF_INVALID;
			} else
				m_state = QSPIF_BULK_ERASE;
			break;
		case 0xd8: // Sector Erase
			if (2 != (m_sreg & 0x203)) {
				if (m_debug) printf("QSPI: WEL not set, cannot erase sector\n");
				m_state = QSPIF_INVALID;
			} else {
				m_state = QSPIF_SECTOR_ERASE;
				if (m_debug) printf("QSPI: SECTOR_ERASE COMMAND\n");
			}
			break;
		case 0x0eb: // Here's the (other) read that we support
			// printf("QSPI: QUAD-I/O-READ\n");
			m_state = QSPIF_QUAD_READ_CMD;
			m_quad_mode = true;
			break;
		default:
			printf("QSPI: UNRECOGNIZED SPI FLASH CMD: %02x\n", m_ireg&0x0ff);
			m_state = QSPIF_INVALID;
			assert(0 && "Unrecognized command\n");
			break;
		}
	} else if ((0 == (m_count&0x07))&&(m_count != 0)) {
		QOREG(0);
		switch(m_state) {
		case QSPIF_IDLE:
			printf("TOO MANY CLOCKS, SPIF in IDLE\n");
			break;
		case QSPIF_WRSR:
			if (m_count == 16) {
				m_sreg = (m_sreg & 0x061) | (m_ireg & 0x09c);
				if (m_debug) printf("Request to set sreg to 0x%02x\n",
					m_ireg&0x0ff);
			} else if (m_count == 24) {
				m_creg = (m_creg & 0x0fd) | (m_ireg & 0x02);
				if (m_debug) printf("Request to set creg to 0x%02x\n",
					m_ireg&0x0ff);
			} else {
				printf("TOO MANY CLOCKS FOR WRR!!!\n");
				exit(-2);
				m_state = QSPIF_IDLE;
			}
			break;
		case QSPIF_CLSR:
			assert(0 && "Too many clocks for CLSR command!!\n");
			break;
		case QSPIF_RDID:
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffffff;
				if (m_debug) printf("READID, ADDR = %08x\n", m_addr);
				QOREG((DEVID>>8));
				if (m_debug) printf("QSPI: READING ID, %02x\n", (DEVID>>8)&0x0ff);
			} else if (m_count > 32) {
				if (((m_count-32)>>3)&1)
					QOREG((DEVID));
				else
					QOREG((DEVID>>8));
				if (m_debug) printf("QSPI: READING ID, %02x -- DONE\n", 0x00);
			}
			// m_oreg = (DEVID >> (2-(m_count>>3)-1)) & 0x0ff;
			break;
		case QSPIF_RDSR:
			// printf("Read SREG = %02x, wait = %08x\n", m_sreg,
				// m_write_count);
			QOREG(m_sreg);
			break;
		case QSPIF_RDCR:
			if (m_debug) printf("Read CREG = %02x\n", m_creg);
			QOREG(m_creg);
			break;
		case QSPIF_FAST_READ:
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffffff;
				if (m_debug) printf("FAST READ, ADDR = %08x\n", m_addr);
				QOREG(0x0c3);
				assert((m_addr & 0xfc00000)==0);
			} else if ((m_count >= 40)&&(0 == (m_sreg&0x01))) {
				if (m_count == 40)
					printf("DUMMY BYTE COMPLETE ...\n");
				QOREG(m_mem[m_addr++]);
				// if (m_debug) printf("SPIF[%08x] = %02x\n", m_addr-1, m_oreg);
			} else m_oreg = 0;
			break;
		case QSPIF_QUAD_READ_CMD:
			// The command to go into quad read mode took 8 bits
			// that changes the timings, else we'd use quad_Read
			// below
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffffff;
				// printf("FAST READ, ADDR = %08x\n", m_addr);
				// printf("QSPI: QUAD READ, ADDR = %06x\n", m_addr);
				assert((m_addr & 0xfc00000)==0);
			} else if (m_count == 32+24) {
				m_mode_byte = (m_ireg>>16) & 0x0ff;
				// printf("QSPI: MODE BYTE = %02x\n", m_mode_byte);
			} else if ((m_count > 32+24)&&(0 == (m_sreg&0x01))) {
				QOREG(m_mem[m_addr++]);
				// printf("QSPIF[%08x]/QR = %02x\n",
					// m_addr-1, m_oreg);
			} else m_oreg = 0;
			break;
		case QSPIF_QUAD_READ:
			if (m_count == 32) {
				m_mode_byte = (m_ireg & 0x0ff);
				// printf("QSPI/QR: MODE BYTE = %02x\n", m_mode_byte);
			} else if ((m_count >= 32+16)&&(0 == (m_sreg&0x01))) {
				QOREG(m_mem[m_addr++]);
				// printf("QSPIF[%08x]/QR = %02x\n", m_addr-1, m_oreg & 0x0ff);
			} else m_oreg = 0;
			break;
		case QSPIF_PP:
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffffff;
				if (m_debug) printf("QSPI: PAGE-PROGRAM ADDR = %06x\n", m_addr);
				assert((m_addr & 0xfc00000)==0);
				// m_page = m_addr >> 8;
				for(int i=0; i<256; i++)
					m_pmem[i] = 0x0ff;
			} else if (m_count >= 40) {
				m_pmem[m_addr & 0x0ff] = m_ireg & 0x0ff;
				// printf("QSPI: PMEM[%02x] = 0x%02x -> %02x\n", m_addr & 0x0ff, m_ireg & 0x0ff, (m_pmem[(m_addr & 0x0ff)]&0x0ff));
				m_addr = (m_addr & (~0x0ff)) | ((m_addr+1)&0x0ff);
			} break;
		case QSPIF_QPP:
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffffff;
				m_quad_mode = true;
				if (m_debug) printf("QSPI/QR: PAGE-PROGRAM ADDR = %06x\n", m_addr);
				assert((m_addr & 0xfc00000)==0);
				// m_page = m_addr >> 8;
				for(int i=0; i<256; i++)
					m_pmem[i] = 0x0ff;
			} else if (m_count >= 40) {
				m_pmem[m_addr & 0x0ff] = m_ireg & 0x0ff;
				// printf("QSPI/QR: PMEM[%02x] = 0x%02x -> %02x\n", m_addr & 0x0ff, m_ireg & 0x0ff, (m_pmem[(m_addr & 0x0ff)]&0x0ff));
				m_addr = (m_addr & (~0x0ff)) | ((m_addr+1)&0x0ff);
			} break;
		case QSPIF_SECTOR_ERASE:
			if (m_count == 32) {
				m_addr = m_ireg & 0x0ffc000;
				if (m_debug) printf("SECTOR_ERASE ADDRESS = %08x\n", m_addr);
				assert((m_addr & 0xfc00000)==0);
			} break;
		case QSPIF_RELEASE:
			if (m_count >= 32) {
				QOREG(DEVESD);
			} break;
		default:
			break;
		}
	} // else printf("SFLASH->count = %d\n", m_count);

	m_last_sck = sck;
	if (m_quad_mode)
		return (m_oreg>>8)&0x0f;
	else
		// return ((m_oreg & 0x0100)?2:0) | (dat & 0x0d);
		return (m_oreg & 0x0100)?2:0;
}

