----------------------------------------------------------------------
----                                                              ----
----  File name "wb2hpi_WBslave.vhd"                              ----
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
-- Design        : wb2hpi_WBslave 
--                ( entity i architecture ) 
-- 
-- File          : wb2hpi_WBslave.vhd 
-- 
-- Errors        : 
-- 
-- Library       : ieee.std_logic_1164 
-- 
-- Dependency    : 
-- 
-- Author        : Gvozden Marinkovic 
--                 mgvozden@eunet.yu 
-- 
-- Simulators    : ActiveVHDL 3.5 on a WindowsXP PC   
----------------------------------------------------------------------
-- Description   :  WB Slave for WB2HPI application
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

---------------------------------------------------------------------- 
-- entity wb2hpi_WBslave 
---------------------------------------------------------------------- 
entity wb2hpi_WBslave is   
    port (
        -- WISHBONE common signals to MASTER and SLAVE
        WB_CLK_I        : in  std_logic;                     -- Clock
        WB_RST_I        : in  std_logic;                     -- Reset
                 
        -- WISHBONE SLAVE signals
        WBS_CYC_I       : in  std_logic;                     -- Cycle in progress
        WBS_STB_I       : in  std_logic;                     -- Strobe
        WBS_WE_I        : in  std_logic;                     -- Write enable
        WBS_CAB_I       : in  std_logic;                     
        WBS_ADR_I       : in  std_logic_vector(31 downto 0); -- Address
        WBS_DAT_I       : in  std_logic_vector(31 downto 0); -- Data input
        WBS_SEL_I       : in  std_logic_vector(3  downto 0); -- Select
        WBS_ACK_O       : out std_logic;                     -- Acknowledge
        WBS_ERR_O       : out std_logic;                     -- Error
        WBS_RTY_O       : out std_logic;                     -- Retry
        WBS_DAT_O       : out std_logic_vector(31 downto 0); -- Data output       
        
        -- To PCI signals
        int_req         : out std_logic;                     -- Interrupt request

        -- To HPI Interface	   
        hpi_data_r      : out std_logic_vector(17 downto 0); -- HPI data (to DSP)
        hpi_address_r   : out std_logic_vector(15 downto 0); -- HPI address (to DSP) 
        hpi_command_r   : out std_logic_vector( 2 downto 0); -- HPI command   
        pci_address_r   : out std_logic_vector(31 downto 1); -- Memory buffrer address
        pci_counter_r   : out std_logic_vector(15 downto 0); -- Number of words for transfer  
        start_hpi_comm  : out std_logic;                     -- Start HPI command
        hpi_reset       : out std_logic;                     -- Reset HPI Logic
        dsp_reset       : out std_logic;                     -- Reset DSP

        -- From HPI Interface
        hpi_data_out    : in  std_logic_vector(15 downto 0); -- Data out (To-WB)
        hpi_ready       : in  std_logic;                     -- Ready for HPI Access
        hpi_counter     : in  std_logic_vector(15 downto 0);    
        hpi_pci_addr    : in  std_logic_vector(31 downto 1);
        hpi_int_req1    : in  std_logic;                     -- Interrupt request 1 (End Block Transfer)
        hpi_int_req2    : in  std_logic;                     -- Interrupt request 2 (from DSP)
        dsp_ready       : in  std_logic;                     -- DSP Ready
        dsp_hint        : in  std_logic;                     -- DSP Host Interrupt
        hpi_end_transfer: in  std_logic;                     -- HPI End Transfer
        hpi_data_is_rdy : in  std_logic;                     -- HPI Data Ready 
        
        -- From WB master
        pci_error       : in  std_logic;                     -- PCI error
        
        -- To Test LED
        led             : out std_logic                      -- Control LED
    );
end entity wb2hpi_WBslave;       

---------------------------------------------------------------------- 
-- architecture wb2hpi_WBslave 
---------------------------------------------------------------------- 
architecture behavioral of wb2hpi_WBslave is      

---------------------------------------------------------------------- 
-- constant declaration
---------------------------------------------------------------------- 
-- Registers Addresses
constant ADR_IR         : std_logic_vector(3 downto 0):="0001";-- Interrupt requests
constant ADR_MR         : std_logic_vector(3 downto 0):="0010";-- Interrupt mask  
constant ADR_LED        : std_logic_vector(3 downto 0):="0111";-- LED 
constant ADR_HPI_COMM   : std_logic_vector(3 downto 0):="1000";-- HPI command 
constant ADR_HPI_PCI_ADR: std_logic_vector(3 downto 0):="1001";-- PCI address
constant ADR_HPI_READ   : std_logic_vector(3 downto 0):="1010";-- HPI data 
constant ADR_HPI_CNT    : std_logic_vector(3 downto 0):="1011";-- HPI word counter 
constant ADR_CONTROL    : std_logic_vector(3 downto 0):="1100";-- DSP control
constant ADR_STATUS     : std_logic_vector(3 downto 0):="1101";-- DSP status 
constant ADR_MAP_DSP    : std_logic_vector(3 downto 0):="1111";-- MAP DSP  

constant COM_MAP_READ   : std_logic_vector(2 downto 0):= "110";-- Map DSP read
constant COM_MAP_WRITE  : std_logic_vector(2 downto 0):= "111";-- Map DSP write

---------------------------------------------------------------------- 
-- type declaration 
---------------------------------------------------------------------- 
type wbs_state is (IDLE, RTY, ACK, START_MAP_READ, WAIT_HPI);-- WB Slave states 
type pci_state is (IDLE, SET_START, WAIT_END);

---------------------------------------------------------------------- 
-- signal declaration 
---------------------------------------------------------------------- 
-- Registers
signal ctl_mr           : std_logic_vector( 1 downto 0);     -- Interrupt mask 
signal ctl_ir           : std_logic_vector( 1 downto 0);     -- Interrupt requests
signal led_r            : std_logic_vector( 0 downto 0);     -- LED
signal control_r        : std_logic_vector( 1 downto 0);     -- DSP control       
signal status_r         : std_logic_vector( 5 downto 0);     -- DSP status
signal hpi_dat_r        : std_logic_vector(17 downto 0);
signal hpi_com_r        : std_logic_vector(2  downto 0);

-- Control signals
signal sel              : std_logic_vector(15 downto 0);     -- Register selections                      
signal valid_access     : boolean;                           -- Valid address detected
signal write_ir         : std_logic;                         -- Strobe
                    
-- FSM States
signal current_state, next_state: wbs_state;  

---------------------------------------------------------------------- 
-- alias declaration 
---------------------------------------------------------------------- 
alias local_address     : std_logic_vector(3  downto  0) is WBS_ADR_I(19 downto 16); 
                         
-- Register selection signals                          
alias sel_led           : std_logic is sel(0);      
alias sel_mr            : std_logic is sel(1);      
alias sel_ir            : std_logic is sel(2);      
alias sel_pci_address   : std_logic is sel(3);
alias sel_pci_counter   : std_logic is sel(4);
alias sel_hpi_command   : std_logic is sel(5);
alias sel_hpi_data      : std_logic is sel(6);
alias sel_control       : std_logic is sel(7);
alias sel_status        : std_logic is sel(8);
alias sel_map_dsp       : std_logic is sel(10);

-- HPI 
alias WBS_HPI_COMM : std_logic_vector(2  downto 0) is WBS_DAT_I(18 downto 16);
alias WBS_HPI_REG  : std_logic_vector(1  downto 0) is WBS_DAT_I(21 downto 20);
alias WBS_HPI_DATA : std_logic_vector(15 downto 0) is WBS_DAT_I(15 downto  0);
        
begin               -- architecture Behavioral of myWBSlave 

    -- purpose: access cycle validation
    -- type   : combinational
    -- inputs : WBS_SEL_I, WBS_CYC_I, WBS_STB_I, sel_map_dsp
    -- outputs: valid_access 
    valid_access <= (WBS_CYC_I = '1'  and
                     WBS_STB_I = '1') and ( 
                       (WBS_SEL_I = "1111" and sel_map_dsp = '0') or     
                       (WBS_SEL_I = "1100" and sel_map_dsp = '1') or
                       (WBS_SEL_I = "0011" and sel_map_dsp = '1')
                    );

    -- purpose: ack or retry on valid cycle
    -- type   : combinational
    -- inputs : valid_access, WBS_WE_I, current_state, sel, hpi_ready
    -- outputs: next_state
    fsm_set_next: process (valid_access, WBS_WE_I,
                           current_state, sel_map_dsp,
                           sel, hpi_ready) is
    begin
        next_state <= IDLE;                                   -- Default state is IDLE    

        case (current_state) is                            
        when IDLE =>                                            
            if (valid_access) then                            -- Valid cycle detected
                next_state <= ACK;  
                if ((sel_hpi_command = '1'  or                -- Retry if HPI interface
                     sel_hpi_data    = '1'  or                -- is busy
                     sel_pci_address = '1'  or
                     sel_map_dsp     = '1') and
                     hpi_ready ='0') then
                   next_state <= RTY;
                elsif (sel_map_dsp = '1' and WBS_WE_I = '0') then
                   next_state <= START_MAP_READ;
                end if;
            end if;                       
        when START_MAP_READ =>
            next_state <= WAIT_HPI;                              
        when WAIT_HPI =>
            next_state <= WAIT_HPI;                              
            if (hpi_ready = '1') then
                next_state <= ACK;                              
            end if;
        when ACK | RTY =>                                       
            next_state <= IDLE;
        when others => null;            
        end case;
    end process fsm_set_next;      

    -- purpose: generate delayed WISHBONE ack/err
    -- type   : sequential
    -- inputs : WB_CLK_I, WB_RST_I, WBS_CYC_I, WBS_STB_I,
    --          valid_access, next_state 
    -- outputs: WBS_ACK_O, WBS_ERR_O, WBS_RTY_O         
    ack_err: process (WB_CLK_I, WB_RST_I) is
    begin
        if (WB_RST_I = '1') then
            WBS_ACK_O <= '0';
            WBS_ERR_O <= '0'; 
            WBS_RTY_O <= '0';
        elsif rising_edge (WB_CLK_I) then
            WBS_ACK_O <= '0';
            WBS_ERR_O <= '0';
            WBS_RTY_O <= '0';
            if (valid_access) then
                case (next_state) is
                   when ACK => WBS_ACK_O <= '1'; 
                   when RTY => WBS_RTY_O <= '1'; 
                   when others => null;
                end case;
            elsif (WBS_CYC_I = '1' and WBS_STB_I = '1') then
                WBS_ERR_O <= '1';
            end if;
        end if;
    end process ack_err;  
	  
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
    
    -- purpose: address decoder
    -- type   : combinational
    -- inputs : local_address
    -- outputs: sel   
    address_decode: process (local_address) is
    begin       
        sel <= (others => '0');
        case (local_address) is 
            when ADR_LED         => sel_led         <= '1';
            when ADR_MR          => sel_mr          <= '1';
            when ADR_IR          => sel_ir          <= '1';
            when ADR_HPI_PCI_ADR => sel_pci_address <= '1';
            when ADR_HPI_READ    => sel_hpi_data    <= '1';
            when ADR_HPI_CNT     => sel_pci_counter <= '1';
            when ADR_HPI_COMM    => sel_hpi_command <= '1';
            when ADR_CONTROL     => sel_control     <= '1';
            when ADR_STATUS      => sel_status      <= '1';
            when ADR_MAP_DSP     => sel_map_dsp     <= '1';
            when others => null;
        end case; 
    end process address_decode;    
    
    -- purpose: write access control 
    -- type   : sequential
    -- inputs : WB_CLK_I, WB_RST_I, WBS_WE_I, next_state, sel, valid_access
    -- outputs: data_str, led_reg, ctl_mr, dsp_control_r    
    write: process (WB_CLK_I, WB_RST_I) is
    begin
        if (WB_RST_I = '1') then
            ctl_mr           <= (others => '0'); 
            led_r            <= (others => '0'); 
            control_r        <= (others => '0');
            control_r(0)     <= '1';   
            start_hpi_comm   <= '0';    
            write_ir         <= '0';    
			hpi_dat_r        <= (others => '0'); 
            hpi_address_r    <= (others => '0'); 
            hpi_com_r        <= (others => '0');
            pci_address_r    <= (others => '0');  
            pci_counter_r    <= (others => '0');  
        elsif (rising_edge(WB_CLK_I)) then
            start_hpi_comm <= '0';  
            write_ir  <= '0';    
            if (next_state = ACK and WBS_WE_I = '1') then 
				case (local_address) is
                	when ADR_LED =>
                    	led_r <= WBS_DAT_I(led_r'range);
	                when ADR_IR =>
			            write_ir <= '1';
	                when ADR_MR =>
    	                ctl_mr  <= WBS_DAT_I(ctl_mr'range);
	                when ADR_CONTROL =>
	                    control_r <= WBS_DAT_I(control_r'range);  
	                when ADR_HPI_COMM => 
		                start_hpi_comm <= '1';                        
		                hpi_com_r <= WBS_HPI_COMM;   
		                hpi_dat_r (15 downto  0) <= WBS_HPI_DATA;   
		                hpi_dat_r (17 downto 16) <= WBS_HPI_REG;    
	    	        when ADR_HPI_PCI_ADR =>
		                pci_address_r <= WBS_DAT_I(pci_address_r'range);
		            when ADR_HPI_CNT =>
		                pci_counter_r <= WBS_DAT_I(pci_counter_r'range);
		            when ADR_MAP_DSP =>  
		                start_hpi_comm <= '1';                        
	                    hpi_com_r <= COM_MAP_WRITE;                 
						hpi_address_r  (15 downto 0) <= '0' & WBS_ADR_I(15 downto 2) & '0';  
		                hpi_dat_r (15 downto 0) <= WBS_DAT_I(15 downto 0);   
		                if (WBS_SEL_I(1) = '0') then                             
		                    hpi_address_r (0) <= '1';
		                    hpi_dat_r(15 downto 0) <= WBS_DAT_I(31 downto 16);   
		                end if;
					when others => null;
	            end case;
            elsif (next_state = START_MAP_READ) then
                hpi_com_r <= COM_MAP_READ;                 
                start_hpi_comm <= '1';                        
	                hpi_address_r  (15 downto 0) <= '0' & WBS_ADR_I(15 downto 2) & '0';  
	                if (WBS_SEL_I(1) = '0') then                             
	                    hpi_address_r (0) <= '1';
	                end if;
            end if;
        end if;
    end process write;
    
    -- purpose: set/reset interrupt request 0
    -- type   : sequential
    -- inputs : WB_RST_I, WBS_DAT_I, data_str, sel_ir, hpi_int_req1 
    -- outputs: ctl_ir(0)
    interrupt_request0: process (WB_RST_I, WBS_DAT_I,
                                 write_ir, sel_ir, hpi_int_req1) is
    begin       
        if (WB_RST_I = '1') then
           ctl_ir(0) <= '0';
        elsif (sel_ir = '1' and WBS_DAT_I(0) = '1') then
            if (write_ir = '1') then
                ctl_ir(0) <= '0';
            end if;
        elsif rising_edge(hpi_int_req1) then
           ctl_ir(0) <= '1';
        end if;
    end process interrupt_request0;
    
    -- purpose: set/reset interrupt request 1
    -- type   : sequential
    -- inputs : WB_RST_I, WBS_DAT_I, data_str, sel_ir, hpi_int_req2 
    -- outputs: ctl_ir(1)
    interrupt_request1: process (WB_RST_I, WBS_DAT_I, 
                                 write_ir, sel_ir, hpi_int_req2) is
    begin       
        if (WB_RST_I = '1') then
           ctl_ir(1) <= '0';
        elsif (sel_ir = '1' and WBS_DAT_I(1) = '1') then
            if (write_ir = '1') then
                ctl_ir(1) <= '0';
            end if;
        elsif rising_edge(hpi_int_req2) then
           ctl_ir(1) <= '1';
        end if;
    end process interrupt_request1;

    -- purpose: read access control
    -- type   : combinational 
    -- inputs : local_address, ctl_mr, ctl_ir, led_reg, hpi_counter, hpi_data_out, 
    --          hpi_pci_addr, dsp_control_r, dsp_status_r, hpi_comm_r
    -- outputs: WBS_DAT_O   
    read: process (local_address, hpi_dat_r, ctl_ir, ctl_mr, led_r, hpi_counter, hpi_data_out,
                   control_r, status_r, hpi_pci_addr, hpi_com_r, WBS_SEL_I) is
    begin 
        WBS_DAT_O <= (others => '0');        
        case (local_address) is 
            when ADR_IR          => WBS_DAT_O(ctl_ir'range)       <= ctl_ir; 
            when ADR_MR          => WBS_DAT_O(ctl_mr'range)       <= ctl_mr;
            when ADR_LED         => WBS_DAT_O(led_r'range)        <= led_r;
            when ADR_HPI_PCI_ADR => WBS_DAT_O(hpi_pci_addr'range) <= hpi_pci_addr;
            when ADR_HPI_READ    => WBS_DAT_O(hpi_data_out'range) <= hpi_data_out;
            when ADR_HPI_CNT     => WBS_DAT_O(hpi_counter'range)  <= hpi_counter;
            when ADR_HPI_COMM    => WBS_DAT_O(21 downto 20)       <= hpi_dat_r(17 downto 16);
                                    WBS_DAT_O(18 downto 16)       <= hpi_com_r;
            when ADR_CONTROL     => WBS_DAT_O(control_r'range)    <= control_r;
            when ADR_STATUS      => WBS_DAT_O(status_r'range)     <= status_r;
            when ADR_MAP_DSP     => WBS_DAT_O(15 downto 0)        <= hpi_data_out;
                                    if (WBS_SEL_I(1) = '0') then
                                        WBS_DAT_O(31 downto 16)   <= hpi_data_out;
                                    end if;
        when others => null;
        end case;
    end process read;												 
	
	hpi_data_r    <= hpi_dat_r;
	hpi_command_r <= hpi_com_r;

    -- purpose: set WB interrupt request signal (to PCI)
    -- type   : combinational 
    -- inputs : ctl_ir, ctl_mr 
    -- outputs: int_req 
    int_req <= (ctl_ir(0) and ctl_mr(0)) or
               (ctl_ir(1) and ctl_mr(1));
     
    -- purpose: drive dev. board LED
    -- type   : combinational 
    -- inputs : led_reg 
    -- outputs: led
	  led <= not led_r(0);  
--    led <= not control_r(0);        
    
    -- purpose: Reset DSP
    -- type   : combinational 
    -- inputs : dsp_control_r(0)
    -- outputs: dsp_reset
    dsp_reset <= not control_r(0);  

    -- purpose: Reset HPI interface
    -- type   : combinational 
    -- inputs : dsp_control_r(1)
    -- outputs: hpi_reset
    hpi_reset <= control_r(1);  
                          
                              
    -- purpose: DSP Status register
    -- type   : combinational 
    -- inputs : hpi_data_is_rdy, hpi_end_transfer, hpi_ready,
    --          dsp_ready, dsp_hint, pci_error
    -- outputs: dsp_status_r
    status_r(0) <= hpi_data_is_rdy;
    status_r(1) <= hpi_end_transfer;
    status_r(2) <= hpi_ready;
    status_r(3) <= pci_error;
    status_r(4) <= dsp_ready;
    status_r(5) <= dsp_hint;

end architecture behavioral;






















