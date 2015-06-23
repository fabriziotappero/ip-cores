----------------------------------------------------------------------
----                                                              ----
----  File name "wb2hpi_WBmaster.vhd"                             ----
----                                                              ----
----  This file is part of the "WB2HPI" project                   ----
----  http://www.opencores.org/cores/wb2hpi/                      ----
----                                                              ----
----  Author(s):                                                  ----
----      - Gvozden Marinkovic (gvozden@opencores.org)            ----
----      - Dusko Krsmanovic   (dusko@opencores.org)              ----
----                                                              ----
----  All additional information is avaliable in the README       ----
----  file.                                                       ----
----                                                              ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2002 Gvozden Marinkovic, gvozden@opencores.org ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

--==================================================================-- 
-- Design        : wb2hpi_WBmaster 
--                ( entity i architecture ) 
-- 
-- File          : wb2hpi_WBmaster.vhd 
-- 
-- Errors        : 
-- 
-- Library       : ieee.std_logic_1164 
--                 ieee.std_logic_arith.all;
--                 ieee.std_logic_unsigned.all;
-- 
-- Dependency    : 
-- 
-- Author        : Gvozden Marinkovic 
--                 mgvozden@eunet.yu 
-- 
-- Simulators    : ActiveVHDL 3.5 on a WindowsXP PC   
---------------------------------------------------------------------- 
-- Description   :  WB Master for WB2HPI application
---------------------------------------------------------------------- 
-- Copyright (c) 2002  Gvozden Marinkovic
-- 
-- This VHDL design file is an open design; you can redistribute it
-- and/or modify it and/or implement it after contacting the author
--==================================================================-- 

--************************** CVS history ***************************--
-- $Author: gvozden $
-- $Date: 2003-01-16 18:06:20 $
-- $Revision: 1.1.1.1 $ 
-- $Name: not supported by cvs2svn $
--************************** CVS history ***************************--

library ieee;
use ieee.std_logic_1164.all;     
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------- 
-- entity wb2hpi_WBmaster 
---------------------------------------------------------------------- 
entity wb2hpi_WBmaster is 
    generic (
        MAX_RTY  : natural range 0 to 255  := 255
    );
    port (
        -- WISHBONE common signals
        WB_CLK_I        : in  std_logic;                     -- Clock
        WB_RST_I        : in  std_logic;                     -- Reset
            
        -- WISHBONE MASTER signals      
        WBM_ACK_I       : in  std_logic;                     -- Acknowledge
        WBM_ERR_I       : in  std_logic;                     -- Error
        WBM_RTY_I       : in  std_logic;                     -- Retry
        WBM_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBM_CYC_O       : out std_logic;                     -- Cycle in progress
        WBM_STB_O       : out std_logic;                     -- Strobe
        WBM_WE_O        : out std_logic;                     -- Write enable
        WBM_CAB_O       : out std_logic;                     -- 
        WBM_ADR_O       : out std_logic_vector(31 downto 0); -- Address
        WBM_DAT_O       : out std_logic_vector(31 downto 0); -- Data output 
        WBM_SEL_O       : out std_logic_vector(3  downto 0); -- Select  
                     
        -- From HPI Interface
        pci_address     : in  std_logic_vector(31 downto 1); -- PCI Address
        pci_counter     : in  std_logic_vector(15 downto 0); -- Number of bytes for transfer
        pci_data_in     : in  std_logic_vector(15 downto 0); -- Data
        start_write     : in  std_logic;                     -- Start PCI write
        start_read      : in  std_logic;                     -- Start PCI read
        
        -- To WB Slave
        pci_error       : out std_logic;                     -- PCI error

        -- To HPI Interface
        ready           : out std_logic;                     -- Ready 
        pci_data_out    : out std_logic_vector(15 downto 0); -- Data
        pci_get_next    : out std_logic                      -- Get next word
    );
end entity wb2hpi_WBmaster;

---------------------------------------------------------------------- 
-- architecture wb2hpi_WBmaster 
---------------------------------------------------------------------- 
architecture behavioral of wb2hpi_WBmaster is     

---------------------------------------------------------------------- 
-- type declaration 
---------------------------------------------------------------------- 
type wbm_state is (IDLE, INIT_WRITE, INIT_READ, END_STATE,
                   WRITE_DATA, READ_DATA);                   -- WB Master states 

---------------------------------------------------------------------- 
-- signal declaration 
---------------------------------------------------------------------- 
signal current_state, next_state: wbm_state; 
signal wbm_adr          : std_logic_vector(31 downto 1);
signal wbm_strobe       : std_logic; 
signal wbm_cyc          : std_logic;  
signal finished         : std_logic;
signal pci_err          : std_logic;
signal odd_word         : std_logic;  

begin               -- architecture Behavioral of myWBMaster 
    WBM_CAB_O <= '1';

	-- purpose: finite state machines
    -- type   : sequential
    -- inputs : WB_CLK_I, WB_RST_I, next_state
    -- outputs: current_state 
    fsm_set_state: process (WB_CLK_I, WB_RST_I, next_state) is
    begin                     
        if (WB_RST_I = '1') then
            current_state <= IDLE;
        elsif rising_edge(WB_CLK_I) then
            current_state <= next_state;
        end if;
    end process fsm_set_state;        
    
    -- purpose: fsm combination input/output logic
    -- type   : combinational
    -- inputs : current_state
    -- outputs: next_state
    fsm_set_next: process (current_state, start_write, start_read, finished) is
    begin                              
        next_state <= IDLE;
        case (current_state) is
            when IDLE =>
                if start_write = '1' then
                    next_state <= INIT_WRITE;
                elsif start_read = '1' then
                    next_state <= INIT_READ;
                end if;               
            when INIT_WRITE =>
                next_state <= WRITE_DATA;
            when INIT_READ  =>
                next_state <= READ_DATA;
            when WRITE_DATA =>
                if (finished = '1') then 
                    next_state <= END_STATE; 
                else 
                    next_state <= WRITE_DATA;   
                end if;
            when READ_DATA => 
                if (finished = '1') then 
                    next_state <= END_STATE; 
                else 
                    next_state <= READ_DATA;
                end if;
            when others => null;
        end case;
    end process fsm_set_next;    

	-- purpose: prepare next address and data
    -- type   : sequential
    -- inputs : WB_RST_I, WB_CLK_I, next_state, WBM_ACK_I, wbm_strobe 
    -- outputs: wbm_adr, odd_word, pci_get_next, finished 
 	set_finished: process (WB_RST_I, WB_CLK_I) is
	begin		
		if (WB_RST_I = '1') then
            wbm_adr <= (others => '0');
			odd_word <= '0';	 
			finished <= '0';	 
            pci_get_next <= '0'; 
		elsif rising_edge (WB_CLK_I) then
            pci_get_next <= '0'; 
			case (next_state) is
				when INIT_WRITE | INIT_READ=>
		            wbm_adr  <= pci_address;
					odd_word <= pci_address(1);
					finished <= '0';
				when WRITE_DATA | READ_DATA =>
					if (WBM_ACK_I = '1' and wbm_strobe = '1') then
			            pci_get_next <= '1'; 
						finished <= '1';
					end if;
				when others => null;
			end case;
		end if;
	end process set_finished;	

    -- purpose: set output data
    -- type   : combinational
    -- inputs : pci_data_in, odd_word
    -- outputs: WBM_DAT_O
    set_data:process (pci_data_in, odd_word) is
    begin
        WBM_DAT_O <= (others => '0');        
        if (odd_word = '1') then
            WBM_DAT_O(31 downto 16) <= pci_data_in;
		else
	        WBM_DAT_O(15 downto 0)  <= pci_data_in;
        end if;
    end process set_data;

    -- purpose: get input data
    -- type   : sequential
    -- inputs : WBM_DAT_I, WBM_ACK_I, wbm_strobe, odd_word
    -- outputs: pci_data_out
	get_data: process (WB_RST_I, WB_CLK_I) is
	begin		
		if (WB_RST_I = '1') then
			pci_data_out <= (others => '0');
		elsif rising_edge (WB_CLK_I) then
			if (WBM_ACK_I = '1' and wbm_strobe = '1') then
		        if (odd_word = '1') then
		            pci_data_out <= WBM_DAT_I(31 downto 16);
				else
			        pci_data_out <= WBM_DAT_I(15 downto 0);
		        end if;
			end if;
		end if;
	end process get_data;	

    
    -- purpose: Retry counter. Just signalize PCI error
    -- type   : sequential
    -- inputs : WB_RST_I, WB_CLK_I, current_state
    -- outputs: pci_err 
    count_rty: process(WB_RST_I, WB_CLK_I, current_state) is
        variable rty_cnt: natural range 0 to MAX_RTY;
    begin
        if (WB_RST_I = '1' or current_state = INIT_WRITE or
                              current_state = INIT_READ) then
            rty_cnt := MAX_RTY;
            pci_err <= '0';
        elsif rising_edge(WB_CLK_I) then 
            if (WBM_RTY_I = '1') then
                if (rty_cnt = 0) then
                    pci_err <= '1';
                else
                    rty_cnt := rty_cnt - 1;
                end if;
            end if;
        end if;
    end process count_rty;   
    
    -- purpose: propagate pci error flag to WB Slave
    -- type   : combinational
    -- inputs : pci_err
    -- outputs: pci_error
    pci_error <= pci_err;
         

    -- purpose: WB master is ready
    -- type   : combinational
    -- inputs : current_state
    -- outputs: ready
    ready      <= '1' when current_state = IDLE else '0'; 

	-- purpose: WB control signals
    -- type   : combinational
    -- inputs : current_state, wbm_adr, wbm_strobe
    -- outputs: WBM_WE_O, WBM_ADR_O, WBM_STB_O, WBM_CYC_O, WBM_SEL_O
    wbm_cyc    <= '1' when current_state = WRITE_DATA or current_state = READ_DATA else '0';
    wbm_strobe <= wbm_cyc and not finished; 
	WBM_WE_O   <= '1' when current_state = WRITE_DATA else '0';
    WBM_ADR_O  <= wbm_adr(31 downto 2) & "00";
    WBM_STB_O  <= wbm_strobe; 
    WBM_CYC_O  <= wbm_cyc; 
    WBM_SEL_O  <= "1100" when odd_word = '1' else "0011";
end architecture behavioral;















