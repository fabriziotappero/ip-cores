------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

library ieee;
use ieee.std_logic_1164.all;

package occomp is

   component ac97_top
    port(
      clk_i               : in  std_logic;
      rst_i               : in  std_logic;
      wb_data_i           : in  std_logic_vector(31 downto 0);
      wb_data_o           : out std_logic_vector(31 downto 0);
      wb_addr_i           : in  std_logic_vector(31 downto 0);
      wb_sel_i            : in  std_logic_vector(3 downto 0);
      wb_we_i             : in  std_logic;
      wb_cyc_i            : in  std_logic;
      wb_stb_i            : in  std_logic;
      wb_ack_o            : out std_logic;
      wb_err_o            : out std_logic;
      int_o               : out std_logic;
      dma_req_o           : out std_logic_vector(8 downto 0);
      dma_ack_i           : in  std_logic_vector(8 downto 0);
      suspended_o         : out std_logic;
      bit_clk_pad_i       : in  std_logic;
      sync_pad_o          : out std_logic;
      sdata_pad_o         : out std_logic;
      sdata_pad_i         : in  std_logic;
      ac97_resetn_pad_o   : out std_logic
      );
  end component;

  component simple_spi_top
    port (
      prdata_o  : out std_logic_vector(7 downto 0);
      pirq_o    : out std_logic;
      sck_o     : out std_logic;
      mosi_o    : out std_logic;
      ssn_o     : out std_logic_vector(7 downto 0);
      pclk_i    : in  std_logic;
      prst_i    : in  std_logic;
      psel_i    : in  std_logic;
      penable_i : in  std_logic;
      paddr_i   : in  std_logic_vector(2 downto 0);
      pwrite_i  : in  std_logic;
      pwdata_i  : in  std_logic_vector(7 downto 0);
      miso_i    : in  std_logic);
  end component;

  component ocidec2_controller
	generic(
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23           -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk    : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst    : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_rst,
		IDEctrl_IDEen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in std_logic_vector(7 downto 0);
		cmdport_IORDYen : in std_logic;             -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in std_logic_vector(7 downto 0);
		dport0_IORDYen : in std_logic;              -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in std_logic_vector(7 downto 0);
		dport1_IORDYen : in std_logic;              -- PIO mode data-port / fast timing device 1

		PIOreq : in std_logic;                      -- PIO transfer request
		PIOack : out std_logic;                  -- PIO transfer ended
		PIOa   : in std_logic_vector(3 downto 0);           -- PIO address
		PIOd   : in std_logic_vector(15 downto 0);  -- PIO data in
		PIOq   : out std_logic_vector(15 downto 0); -- PIO data out
		PIOwe  : in std_logic;                      -- PIO direction bit '1'=write, '0'=read

		-- ATA signals
		RESETn	: out std_logic;
		DDi	 : in std_logic_vector(15 downto 0);
		DDo  : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	  : out std_logic_vector(2 downto 0);
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
  end component ocidec2_controller;

  component atahost_controller
	generic(
                tech   : integer := 0;                   -- fifo mem technology
                fdepth : integer := 8;                   -- DMA fifo depth
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23;          -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

		-- Multiword DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 4;             -- 50ns
		DMA_mode0_Td : natural := 21;            -- 215ns
		DMA_mode0_Teoc : natural := 21           -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
	);
	port(
		clk : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_rst,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;                 -- control register settings

		a : in std_logic_vector(3 downto 0);                  -- address input
		d : in std_logic_vector(31 downto 0);         -- data input
		we : in std_logic;                            -- write enable input '1'=write, '0'=read

		-- PIO registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc : in std_logic_vector(7 downto 0);
		PIO_cmdport_IORDYen : in std_logic;           -- PIO compatible timing settings
	
		PIO_dport0_T1,
		PIO_dport0_T2,
		PIO_dport0_T4,
		PIO_dport0_Teoc : in std_logic_vector(7 downto 0);
		PIO_dport0_IORDYen : in std_logic;            -- PIO data-port device0 timing settings

		PIO_dport1_T1,
		PIO_dport1_T2,
		PIO_dport1_T4,
		PIO_dport1_Teoc : in std_logic_vector(7 downto 0);
		PIO_dport1_IORDYen : in std_logic;            -- PIO data-port device1 timing settings

		PIOsel : in std_logic;                        -- PIO controller select
		PIOack : out std_logic;                       -- PIO controller acknowledge
		PIOq : out std_logic_vector(15 downto 0);     -- PIO data out
		PIOtip : out std_logic :='0';              -- PIO transfer in progress
		PIOpp_full : out std_logic;                   -- PIO Write PingPong full

		-- DMA registers
		DMA_dev0_Td,
		DMA_dev0_Tm,
		DMA_dev0_Teoc : in std_logic_vector(7 downto 0);      -- DMA timing settings for device0

		DMA_dev1_Td,
		DMA_dev1_Tm,
		DMA_dev1_Teoc : in std_logic_vector(7 downto 0);      -- DMA timing settings for device1

		DMActrl_DMAen,
		DMActrl_dir,
                DMActrl_Bytesw,     --Jagre 2006-12-04 byte swap ATA data
		DMActrl_BeLeC0,
		DMActrl_BeLeC1 : in std_logic;                -- DMA settings

		DMAsel : in std_logic;                        -- DMA controller select
		DMAack : out std_logic;                       -- DMA controller acknowledge
		DMAq : out std_logic_vector(31 downto 0);     -- DMA data out
		DMAtip_out : out std_logic;                    -- DMA transfer in progress --Erik Jagre 2006-11-15
		DMA_dmarq : out std_logic;                    -- Synchronized ATA DMARQ line

                force_rdy : in std_logic;                     -- DMA transmit fifo filled up partly --Erik Jagre 2006-10-31
		fifo_rdy : out std_logic;                     -- DMA transmit fifo filled up --Erik Jagre 2006-10-30
		DMARxEmpty : out std_logic;                   -- DMA receive buffer empty
		DMARxFull : out std_logic;                    -- DMA receive fifo full Erik Jagre 2006-10-31

		DMA_req : out std_logic;                      -- DMA request to external DMA engine
		DMA_ack : in std_logic;                       -- DMA acknowledge from external DMA engine
                BM_en   : in std_logic;                       -- Bus mater enabled, for DMA reset Erik Jagre 2006-10-24

		-- ATA signals
		RESETn	: out std_logic;
		DDi	: in std_logic_vector(15 downto 0);
		DDo : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	: out std_logic_vector(2 downto 0) := "000";
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DMARQ	: in std_logic;
		DMACKn	: out std_logic;
		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
  end component;

  component ata_device_oc is
    port(
      ata_rst_n  : in std_logic;
      ata_data   : inout std_logic_vector(15 downto 0);
      ata_da     : in std_logic_vector(2 downto 0);
      ata_cs0    : in std_logic;
      ata_cs1    : in std_logic;
      ata_dior_n : in std_logic;
      ata_diow_n : in std_logic;
      ata_iordy  : out std_logic;
      ata_intrq  : out std_logic
    );
  end component;

end;
