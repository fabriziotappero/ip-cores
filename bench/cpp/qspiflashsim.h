///////////////////////////////////////////////////////////////////////////
//
// Filename: 	spiflashsim.h
//
// Project:	Wishbone Controlled Quad SPI Flash Controller
//
// Purpose:	This library simulates the operation of a Quad-SPI commanded
//		flash, such as the S25FL032P used on the Basys-3 development
//		board by Digilent.  As such, it is defined by 32 Mbits of
//		memory (4 Mbyte).
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
#ifndef	QSPIFLASHSIM_H
#define	QSPIFLASHSIM_H

#define	QSPIF_WIP_FLAG			0x0001
#define	QSPIF_WEL_FLAG			0x0002
#define	QSPIF_DEEP_POWER_DOWN_FLAG	0x0200
class	QSPIFLASHSIM {
	typedef	enum {
		QSPIF_IDLE,
		QSPIF_QUAD_READ_IDLE,
		QSPIF_RDSR,
		QSPIF_RDCR,
		QSPIF_WRSR,
		QSPIF_CLSR,
		QSPIF_RDID,
		QSPIF_RELEASE,
		QSPIF_FAST_READ,
		QSPIF_QUAD_READ_CMD,
		QSPIF_QUAD_READ,
		QSPIF_SECTOR_ERASE,
		QSPIF_PP,
		QSPIF_QPP,
		QSPIF_BULK_ERASE,
		QSPIF_DEEP_POWER_DOWN,
		QSPIF_INVALID
	} QSPIF_STATE;

	QSPIF_STATE	m_state;
	char		*m_mem, *m_pmem;
	int		m_last_sck;
	unsigned	m_write_count, m_ireg, m_oreg, m_sreg, m_addr,
			m_count, m_config, m_mode_byte, m_creg;
	bool		m_quad_mode, m_debug;

public:
	QSPIFLASHSIM(void);
	void	load(const char *fname);
	void	debug(const bool dbg) { m_debug = dbg; }
	bool	debug(void) const { return m_debug; }
	int	operator()(const int csn, const int sck, const int dat);
};

#endif
