----------------------------------------------------------------------
----                                                              ----
----  File name "wb2hpi_interface.vhd"                            ----
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
-- Design        : wb2hpi_interface 
--                ( entity i architecture ) 
-- 
-- File          : wb2hpi_interface.vhd 
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
-- Description   :  HPI interface for WB2HPI application
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
--************************** CVS history ***************************--

library ieee;
use ieee.std_logic_1164.all;  

----------------------------------------------------------------------
-- entity wb2hpi_interface 
----------------------------------------------------------------------
entity wb2hpi_interface is
    port(
        clk             : in  std_logic;                     -- Clock
        reset           : in  std_logic;                     -- Reset
        we              : in  std_logic;                     -- Write Enable
        start           : in  std_logic;                     -- Start HPI Access
        address         : in  std_logic_vector( 1 downto 0); -- HPI Address
        data_in         : in  std_logic_vector(15 downto 0); -- Data in 
        ready           : out std_logic;                     -- Ready 
        data_out        : out std_logic_vector(15 downto 0); -- Data out 
        hpi_err         : out std_logic;                     -- HPI Error (not implemented)

        -- From DSP
        hpi_ad_in       : in  std_logic_vector( 7 downto 0); -- Data in (From-HPI)     
        hpi_rdy         : in  std_logic;                     -- HPI Ready

        -- To DSP
        hpi_ad_out      : out std_logic_vector( 7 downto 0); -- Data in (To-HPI)   
        hpi_ad_en       : out std_logic;                     -- Data out enable (To-HPI)
        hpi_cntl        : out std_logic_vector( 1 downto 0); -- HPI Control    
        hpi_cs_n        : out std_logic;                     -- HPI Chip Select    
        hpi_ds_n        : out std_logic;                     -- HPI Data Stobe
        hpi_rw          : out std_logic;                     -- HPI Read/Write
        hpi_bil         : out std_logic                      -- HPI Byte Low/High
    );
end entity wb2hpi_interface;
 
------------------------------------------------------------------------
-- architecture wb2hpi_interface 
------------------------------------------------------------------------
architecture behavioral of wb2hpi_interface is

------------------------------------------------------------------------
-- type declaration 
------------------------------------------------------------------------
type   hpi_state is (IDLE, INIT, SET_DATA1, SET_DATA2, CHANGE_BYTE,
                     LATCH_DATA1, LATCH_DATA2, CHECK_READY, END_STATE);

------------------------------------------------------------------------
-- signal declaration 
------------------------------------------------------------------------
signal current_state, next_state: hpi_state;  
signal hpi_buffer_out   : std_logic_vector(15 downto 0);
signal hpi_buffer_in    : std_logic_vector(15 downto 0);
signal msb_byte         : boolean;      
signal hpi_cs           : std_logic;     
signal hpi_rdy_q        : std_logic;

begin               -- architecture fsm of wb_hpi_sm    
    -- purpose: finite state machine
    -- type   : sequential
    -- inputs : clk, reset, next_state
    -- outputs: current_state 
    fsm_set_state: process (clk, reset) is
    begin                     
        if (reset = '1') then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process fsm_set_state;   
    
    -- purpose: sample hpi ready (from DSP) signal
    -- type   : sequential
    -- inputs : clk, reset, hpi_rdy
    -- outputs: hpi_rdy_q 
    sample_hpi_rdy: process (reset, clk) is
    begin 
        if (reset = '1') then
            hpi_rdy_q <= '0';
        elsif rising_edge(clk) then  
            hpi_rdy_q <= hpi_rdy;   
        end if;
    end process sample_hpi_rdy;

    -- purpose: fsm combination input/output logic
    -- type   : combinational
    -- inputs : current_state, start, hpi_rdy_q, second_byte
    -- outputs: next_state
    fsm_set_next: process (current_state, start, hpi_rdy_q) is
    begin 
        next_state <= IDLE;
        case (current_state) is
        when IDLE => 
            if (start = '1') then 
                next_state <= INIT;
            end if;               
        when INIT =>
            next_state <= SET_DATA1;
        when SET_DATA1 =>
		  	next_state <= CHECK_READY;
        when SET_DATA2 =>
		  	next_state <= LATCH_DATA2;
        when CHECK_READY => 
            next_state <= CHECK_READY;
            if (hpi_rdy_q = '1') then
                next_state <= LATCH_DATA1;
            end if;
        when LATCH_DATA1 =>
             next_state <= CHANGE_BYTE;
        when LATCH_DATA2 =>
            next_state <= END_STATE;
		when CHANGE_BYTE =>
            next_state <= SET_DATA2;
        when others => null;
        end case;
    end process fsm_set_next; 
              
    -- purpose: loads data into buffer
    -- type   : sequential
    -- inputs : reset, clk, we, current_state, second_byte, hpi_ad_in
    -- outputs: hpi_buffer_in  
    set_buffer_in: process (reset, clk) is
    begin
        if (reset = '1') then 
            hpi_buffer_in <= (others => '0');     
        elsif (rising_edge(clk)) then
			if (we = '0' and next_state = LATCH_DATA1) then
                hpi_buffer_in (15 downto 8) <= hpi_ad_in;       
			elsif (we = '0' and next_state = LATCH_DATA2) then
               	hpi_buffer_in (7  downto 0) <= hpi_ad_in;       
            end if;
        end if;
    end process set_buffer_in;      
       
    -- purpose: set ready
    -- type   : combinational
    -- inputs : current_state
    -- outputs: ready   
    ready <= '1' when (current_state=IDLE or --else '0'; 
                      current_state=END_STATE) and start = '0' else '0';

    -- purpose: propagate data from DSP 
    -- type   : combinational
    -- inputs : hpi_buffer_in
    -- outputs: data_out    
    data_out <= hpi_buffer_in;
         
    -- purpose: select DSP
    -- type   : sequential
    -- inputs : reset, clk, current_state
    -- outputs: hpi_cs_n    
    select_hpi: process (reset, clk) is
    begin
        if reset = '1' then    
            hpi_cs  <= '1';
        elsif rising_edge(clk) then  
            hpi_cs <= '0';
            case(next_state) is
                when IDLE | END_STATE => hpi_cs <= '1';
                when others => null;
            end case;
        end if;
    end process select_hpi; 
    hpi_cs_n <= hpi_cs;      
    
    -- purpose: propagates data to DSP
    -- type   : combinational
    -- inputs : data_in
    -- outputs: hpi_buffer_out    
    hpi_buffer_out <= data_in;
    
    -- purpose: strobe control (to DSP)
    -- type   : sequential
    -- inputs : reset, clk, current_state
    -- outputs: hpi_ds_n    
    strobe_control: process(reset, clk) is
    begin                        
        if reset = '1' then    
            hpi_ds_n  <= '1';
        elsif rising_edge(clk) then 
			hpi_ds_n <= '1';		 
            case(next_state) is
                when SET_DATA1 | CHECK_READY | 
				     SET_DATA2 => hpi_ds_n <= '0';
                when others => null;
            end case;
        end if;
    end process strobe_control; 
        
    -- purpose: select read/write (to DSP)
    -- type   : combinational
    -- inputs : we
    -- outputs: hpi_rw
    hpi_rw   <= not we;     

    -- purpose: set HPI address/data output enable
    -- type   : combinational
    -- inputs : we, hpi_cs
    -- outputs: hpi_ad_en
    hpi_ad_en <= '0' when (we = '1' and hpi_cs = '0') else '1';
                     
    -- purpose: set HPI address/data
    -- type   : combinational
    -- inputs : hpi_buffer_out, second_byte 
    -- outputs: hpi_ad_out
    hpi_ad_out <= hpi_buffer_out (15 downto 8) when msb_byte else
                  hpi_buffer_out ( 7 downto 0);

    -- purpose: select first/second byte (to DSP)
    -- type   : combinational
    -- inputs : reset, second_byte, clk, current_state 
    -- outputs: hpi_bil 
    hpi_byte_control: process(reset, clk) is
        variable changed: boolean;
    begin                        
        if reset = '1' then    
--            hpi_bil  <= '0';
            msb_byte <= true;           
            changed  := false;
        elsif rising_edge(clk) then  
            msb_byte <= true;
            case(next_state) is
                when CHANGE_BYTE | SET_DATA2 | LATCH_DATA2 | END_STATE =>
                    msb_byte <= false;
                when others => null;
            end case;
        end if;
    end process hpi_byte_control; 
	
	hpi_bil <= '0' when msb_byte else '1';
    
    -- purpose: error report (not implemented)
    -- type   : combinational
    -- inputs :  
    -- outputs: hpi_err
    hpi_err <= '0';
                    
    -- purpose: select DSP register
    -- type   : sequential
    -- inputs : address, current_state 
    -- outputs: hpi_cntl 
    hpi_cntl <= address; 

end architecture behavioral;   




















