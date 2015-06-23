----------------------------------------------------------------------
----                                                              ----
----  File name "wb2hpi_control.vhd"                              ----
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
-- Design        : wb2hpi_control 
--                ( entity i architecture ) 
-- 
-- File          : wb2hpi_control.vhd 
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
-- Description   :  HPI control logic for WB2HPI application
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
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------
-- entity wb2hpi_control
----------------------------------------------------------------------
entity wb2hpi_control is 
    port(
        clk             : in  std_logic;                     -- Clock
        reset           : in  std_logic;                     -- Reset   

        -- From WB Slave
        hpi_data_r      : in  std_logic_vector(17 downto 0); -- HPI data (to DSP)
        hpi_address_r   : in  std_logic_vector(15 downto 0); -- HPI address (to DSP) 
        hpi_command_r   : in  std_logic_vector( 2 downto 0); -- HPI command   
        pci_address_r   : in  std_logic_vector(31 downto 1); -- Memory buffrer address
        pci_counter_r   : in  std_logic_vector(15 downto 0); -- Number of words for transfer  
        start           : in  std_logic;                     -- Execute command

        -- From WB Master
        from_pci_data   : in  std_logic_vector(15 downto 0); -- From PCI Data (Bus Mastering)
        pci_get_next    : in  std_logic;                     -- Prepare next word
        pci_ready       : in  std_logic;                     -- WB Master is ready for transfer
          
        -- To WB Slave
        counter         : out std_logic_vector(15 downto 0); -- Number of words left for transfer
        ready           : out std_logic;                     -- HPI Interface ready (for status reg)
        end_transfer    : out std_logic;                     -- End block transfer 
        hpi_data_is_rdy : out std_logic;                     -- Data is ready (after HPI read)
        int_req1        : out std_logic;                     -- Interrupt request 1 (End Block Transfer)
        int_req2        : out std_logic;                     -- Interrupt request 2 (from DSP)

        -- To WB Master
        pci_start_write : out std_logic;                     -- Write request
        pci_start_read  : out std_logic;                     -- Read request
        pci_counter     : out std_logic_vector(15 downto 0); -- Number of words
        pci_address     : out std_logic_vector(31 downto 1); -- PCI Address
        to_pci_data     : out std_logic_vector(15 downto 0); -- PCI Data (Bus Mastering)

        -- From DSP     
        hpi_ad_in       : in  std_logic_vector( 7 downto 0); -- Data in (From-HPI)   
        dsp_hint        : in  std_logic;   
        hpi_rdy         : in  std_logic;                     -- HPI Ready

        -- To DSP       
        hpi_ad_out      : out std_logic_vector( 7 downto 0); -- Data in (To-HPI)     
        hpi_ad_en       : out std_logic;                     -- Data out enable (To-HPI)
        dsp_int2        : out std_logic;
        hpi_cntl        : out std_logic_vector( 1 downto 0); -- HPI Control      
        hpi_cs_n        : out std_logic;                     -- HPI Chip Select      
        hpi_ds_n        : out std_logic;                     -- HPI Data Stobe
        hpi_rw          : out std_logic;                     -- HPI Read/Write
        hpi_bil         : out std_logic                      -- HPI Byte Low/High   
    );                                                 
end entity wb2hpi_control;  

----------------------------------------------------------------------
-- architecture wb2hpi_control
----------------------------------------------------------------------
architecture behavioral of wb2hpi_control is  

----------------------------------------------------------------------
-- component declaration
----------------------------------------------------------------------
component wb2hpi_interface is
    port(
        clk             : in    std_logic;                     -- Clock
        reset           : in    std_logic;                     -- Reset
        we              : in    std_logic;                     -- Write Enable
        start           : in    std_logic;                     -- Start HPI Access
        address         : in    std_logic_vector( 1 downto 0); -- HPI Address
        data_in         : in    std_logic_vector(15 downto 0); -- Data in 
        ready           : out   std_logic;                     -- Ready 
        data_out        : out   std_logic_vector(15 downto 0); -- Data out 
        hpi_err         : out   std_logic;                     -- HPI Error (not implemented)

        -- From DSP
        hpi_ad_in       : in    std_logic_vector( 7 downto 0); -- Data in (From-HPI)     
        hpi_rdy         : in    std_logic;                     -- HPI Ready

        -- To DSP
        hpi_ad_out      : out   std_logic_vector( 7 downto 0); -- Data in (To-HPI)   
        hpi_ad_en       : out   std_logic;                     -- Data out enable (To-HPI)
        hpi_cntl        : out   std_logic_vector( 1 downto 0); -- HPI Control    
        hpi_cs_n        : out   std_logic;                     -- HPI Chip Select    
        hpi_ds_n        : out   std_logic;                     -- HPI Data Stobe
        hpi_rw          : out   std_logic;                     -- HPI Read/Write
        hpi_bil         : out   std_logic                      -- HPI Byte Low/High
    );
end component wb2hpi_interface; 

----------------------------------------------------------------------
-- type declaration
----------------------------------------------------------------------
type hpi_states is (IDLE, INIT, END_BLOCK_TRANSFER, END_WRITE_BLOCK,
                    CHANGE_PHASE, WAIT_PCI_ACK, PCI_ACK, 
                    WRITE_HPI, READ_HPI, WAIT_HPI, WAIT_HPI_DATA,
                    HPI_DATA_READY, READ_PCI, WRITE_PCI, WAIT_PCI, 
                    PCI_DATA_READY, WAIT_PCI_DATA, WAIT_HPI_END); 

----------------------------------------------------------------------
-- constant declaration
----------------------------------------------------------------------
-- Commands
constant COM_WRITE_HPI  : std_logic_vector( 2 downto 0):= B"010"; -- Write to DSP
constant COM_READ_HPI   : std_logic_vector( 2 downto 0):= B"011"; -- Read from DSP
constant COM_READ_BLOCK : std_logic_vector( 2 downto 0):= B"100"; -- Read block from DSP 
constant COM_WRITE_BLOCK: std_logic_vector( 2 downto 0):= B"101"; -- Write block to  DSP
constant COM_MAP_READ   : std_logic_vector( 2 downto 0):= B"110"; -- Map DSP read
constant COM_MAP_WRITE  : std_logic_vector( 2 downto 0):= B"111"; -- Map DSP write

constant COUNTER_ZERO   : std_logic_vector(15 downto 0):= (others => '0');

-- HPI Control registers addresses 
constant HPI_A          : std_logic_vector( 1 downto 0):= B"10";  -- Address
constant HPI_D          : std_logic_vector( 1 downto 0):= B"11";  -- Data
constant HPI_D_INC      : std_logic_vector( 1 downto 0):= B"01";  -- Data with address increment

----------------------------------------------------------------------
-- signal declaration
----------------------------------------------------------------------
signal current_state, next_state: hpi_states;
signal address_r        : std_logic_vector(31 downto 1);
signal counter_r        : std_logic_vector(15 downto 0); 
signal pci_data_buffer  : std_logic_vector(15 downto 0);   
signal hpi_address      : std_logic_vector( 1 downto 0);  
signal hpi_data_in      : std_logic_vector(15 downto 0);  
signal hpi_data_out     : std_logic_vector(15 downto 0);  
signal hpi_data_rdy     : std_logic;
signal hpi_we           : std_logic;                      
signal hpi_start        : std_logic;                      
signal hpi_ready        : std_logic;                      
signal hpi_err          : std_logic;                      
signal pci_data_rdy     : boolean;
signal second_phase     : boolean; 
signal finished         : boolean;
signal block_transfer   : boolean;

begin 

    
    -- purpose: number of words to transfer through WB Master to PCI. 
    --          In this case only one
    -- type   : combinational
    -- outputs: pci_counter
    pci_counter <= "0000000000000001";

    -- purpose: address of mamory buffer
    -- type   : combinational
    -- inputs : address_r
    -- outputs: pci_address                                         
    pci_address <= address_r;

    -- purpose: activates HPI bootloader after DSP reset (to DSP)
    -- type   : combinational
    -- inputs : dsp_hint
    -- outputs: dsp_int2                                            
    dsp_int2 <= dsp_hint; 

    -- purpose: for reading number of words left in block transfer.
    --          valid only after BLOCK command execution
    -- type   : combinational
    -- inputs : counter_r
    -- outputs: counter                                         
    counter <= counter_r;

    -- purpose: finite state machines
    -- type   : sequential
    -- inputs : reset, clk, next_state 
    -- outputs: current_state
    fsm_set_state: process (clk, reset) is
    begin                     
        if (reset = '1') then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;  
        end if;
    end process fsm_set_state;  
    
    -- purpose: fsm combination input/output logic
    -- type   : combinational
    -- inputs : current_state, command_r, dsp_hint, dsp_hint, pci_ready,
    --          hpi_ready, pci_data_rdy, start, finished, second_phase 
    -- outputs: next_state
    fsm_set_next: process (current_state, hpi_command_r, 
                           pci_ready, hpi_ready, pci_data_rdy, start,
                           finished, second_phase) is  
    begin
        next_state <= IDLE; 

        case (current_state) is
            when IDLE => 
                if (start = '1') then
                    next_state <= INIT;
                end if;

            when INIT =>
                case (hpi_command_r) is
                    when COM_READ_HPI =>
                        next_state <= READ_HPI; 
                    when COM_WRITE_HPI | COM_MAP_READ | COM_MAP_WRITE=>
                        next_state <= WRITE_HPI; 
                    when COM_READ_BLOCK =>
                        if (not finished) then
                            next_state <= READ_HPI; 
                        end if;
                    when COM_WRITE_BLOCK =>
                        if (not finished) then
                            next_state <= READ_PCI; 
                            if (pci_ready = '0') then 
                                next_state <= WAIT_PCI;
                            end if;   
                        end if;
                    when others => null;
               end case;

            when WAIT_HPI => 
                next_state <= WAIT_HPI;  
                if (hpi_ready = '1') then
                    case (hpi_command_r) is
                        when COM_WRITE_HPI | COM_WRITE_BLOCK =>         
                            next_state <= WRITE_HPI; 
                        when COM_READ_BLOCK | COM_READ_HPI =>
                            next_state <= READ_HPI; 
                        when COM_MAP_READ | COM_MAP_WRITE=>   
                            if (not second_phase) then
                                next_state <= CHANGE_PHASE; 
                            end if;
                        when others => null;
                    end case;
                end if;
                                  
            when READ_HPI => 
                next_state <= WAIT_HPI_DATA;

            when WAIT_HPI_DATA =>
                next_state <= WAIT_HPI_DATA; 
                if (hpi_ready = '1') then 
                    next_state <= HPI_DATA_READY; 
                end if;

            when WRITE_HPI =>  
                next_state <= WAIT_HPI_END;
                case (hpi_command_r) is
                    when COM_WRITE_BLOCK =>
                        if (not finished) then
                            if (pci_ready = '1') then
                                next_state <= READ_PCI;
                            else
                                next_state <= WAIT_PCI;
                            end if;
                        else
                            next_state <= WAIT_HPI_END;
                        end if; 
                    when COM_MAP_READ | COM_MAP_WRITE =>
                        if (not second_phase) then    
                            next_state <= WAIT_HPI;
                        end if;
                    when others => null;
                end case;   
                            
            when WAIT_HPI_END =>
                next_state <= WAIT_HPI_END;
                if (hpi_ready = '1') then
                    next_state <= IDLE;	
	                case (hpi_command_r) is
	                    when COM_WRITE_BLOCK | COM_READ_BLOCK=>
                            next_state <= END_BLOCK_TRANSFER;
	                    when others => null;
	                end case;   
                end if;

            when CHANGE_PHASE =>
                case (hpi_command_r) is
                    when COM_MAP_READ =>   
                        next_state <= READ_HPI; 
                    when COM_MAP_WRITE =>
                        next_state <= WRITE_HPI; 
                    when others => null;
                end case;

            when HPI_DATA_READY =>   
                case (hpi_command_r) is
                    when COM_READ_BLOCK =>
                        if (pci_ready = '1') then
                            next_state <= WRITE_PCI; 
                        else
                            next_state <= WAIT_PCI;
                        end if;
                when others => null;
               end case;                 
             
            when WAIT_PCI => 
                next_state <= WAIT_PCI;
                if (pci_ready = '1') then   
                    case (hpi_command_r) is  
                        when COM_WRITE_BLOCK =>            
                            next_state <= READ_PCI;
                        when COM_READ_BLOCK =>
                            next_state <= WRITE_PCI;
                        when others => null;        
                    end case;
                end if;                    

            when WRITE_PCI => 
                next_state <= WAIT_PCI_ACK; 

            when WAIT_PCI_ACK => 
                next_state <= WAIT_PCI_ACK;  
                if (pci_data_rdy) then
                    next_state <= PCI_ACK;  
                end if;    
                
            when PCI_ACK => 
                if (not finished) then    
                    if (hpi_ready = '1') then
                        next_state <= READ_HPI;
                    else
                        next_state <= WAIT_HPI;
                    end if;
                else
                    next_state <= END_BLOCK_TRANSFER;
                end if;

            when END_BLOCK_TRANSFER => null; 

            when READ_PCI =>
                next_state <= WAIT_PCI_DATA;

            when WAIT_PCI_DATA =>
                next_state <= WAIT_PCI_DATA;  
                if (pci_data_rdy) then
                    next_state <= PCI_DATA_READY;  
                end if; 
        
            when PCI_DATA_READY =>
                if (hpi_ready = '1') then
                    next_state <= WRITE_HPI;
                else
                    next_state <= WAIT_HPI;
                end if;

            when others => null;
        end case;
    end process fsm_set_next;    
    
    -- purpose: setting control signals
    -- type   : sequential
    -- inputs : reset, clk, current_state
    -- outputs: hpi_address, hpi_data_in, hpi_we, hpi_start, hpi_data_rdy,
    --          block_transfer, pci_start_read, pci_start_write, int_req1,
    --          second_phase                  
    start_read_write: process(reset, clk) is
    begin       
        if (reset = '1') then 
            hpi_we <= '0';
            hpi_start <= '0';  
            hpi_data_rdy <= '0';
            block_transfer <= false;
            pci_start_read  <= '0';
            pci_start_write <= '0';  
            int_req1 <='0';    
            second_phase <= false;	
            pci_data_buffer <= (others => '0');
        elsif rising_edge(clk) then
            hpi_start <= '0';     
            pci_start_read <= '0';
            pci_start_write <= '0';
            int_req1 <='0';
            case(next_state) is
                when IDLE =>  
                    block_transfer <= false;
                    second_phase <= false;
                when INIT =>
                    case (hpi_command_r) is
                        when COM_READ_BLOCK | COM_WRITE_BLOCK =>
                            block_transfer <= true;
                        when others => null;
                    end case;
                when HPI_DATA_READY =>       
                    hpi_data_rdy <= '1';   
                when READ_PCI =>
                    pci_start_read <= '1';
                    hpi_data_rdy <= '0';
                when WRITE_PCI =>
                    pci_start_write <= '1';
                    hpi_data_rdy <= '0';
                when WRITE_HPI => 
		            pci_data_buffer <= from_pci_data;
                    hpi_we <= '1'; 
                    hpi_start <= '1';   
                when READ_HPI => 
                    hpi_we <= '0';
                    hpi_start <= '1'; 
                when CHANGE_PHASE =>
                    second_phase <= true; 
                when END_BLOCK_TRANSFER =>
                    int_req1 <='1';
                when others => null;
            end case;
        end if;
    end process start_read_write;  
    
    -- purpose: select hpi control register and data source
    -- type   : combinational
    -- inputs : hpi_data_r, pci_data_buffer, hpi_address_r, hpi_command_r,
    --          block_transfer, second_phase
    -- outputs: hpi_data_in, hpi_address  
    sel_hpi_addr_data: process (hpi_data_r, pci_data_buffer, hpi_address_r, hpi_command_r,
                                block_transfer, second_phase) is
    begin       
        hpi_data_in <= hpi_data_r(15 downto 0);
        hpi_address <= hpi_data_r(17 downto 16);
        case (hpi_command_r) is 
            when COM_MAP_READ | COM_MAP_WRITE =>
                if (not second_phase) then
                    hpi_data_in <= hpi_address_r; 
                    hpi_address <= HPI_A;
                else
                    hpi_address <= HPI_D;
                end if;
            when others => 
                if (block_transfer) then
                    hpi_data_in <= pci_data_buffer;  
                    hpi_address <= HPI_D_INC;
                end if;
        end case;
    end process sel_hpi_addr_data;
    
    -- purpose: increment/decrement address and count
    -- type   : sequential
    -- inputs : reset, current_state, pci_counter_r, pci_address_r, pci_get_next
    -- outputs: address_r, counter_r                      
    inc_dec_regs: process (reset, current_state, 
	                       pci_counter_r, pci_address_r,
						   pci_get_next) is
    begin       
        if (reset = '1') then              
            counter_r <= (others => '0');
            address_r <= (others => '0');              
        elsif (current_state = INIT) then
            counter_r <= pci_counter_r;
            address_r <= pci_address_r;
        elsif rising_edge(pci_get_next) then          
            address_r <= address_r + 1;
            counter_r <= counter_r - 1;
        end if;
    end process inc_dec_regs;     
    
    -- purpose: sets data ready flag
    -- type   : sequential
    -- inputs : current_state, pci_get_next
    -- outputs: pci_data_rdy                      
	set_pci_data_rdy: process (reset, current_state, pci_get_next) is
    begin                   
        if (reset = '1') then
            pci_data_rdy <= false;
        elsif (current_state = READ_PCI or current_state = WRITE_PCI) then 
            pci_data_rdy <= false;
        elsif rising_edge(pci_get_next) then
            pci_data_rdy <= true;
        end if;
    end process set_pci_data_rdy;        

    -- purpose: set READY (to WB Slave)
    -- type   : combinational
    -- inputs : current_state 
    -- outputs: ready 
    ready <= '1' when current_state = IDLE else '0'; 
    
    -- purpose: block transfer is finished
    -- type   : combinational
    -- inputs : counter_r 
    -- outputs: finished, end_transfer  
    finished     <= counter_r = COUNTER_ZERO;
    end_transfer <= '1' when finished else '0';     
    
    -- purpose: propagate data to WB Master (to PCI)
    -- type   : combinational
    -- inputs : hpi_data_out 
    -- outputs: to_pci_data
    to_pci_data <= hpi_data_out;      

    -- purpose: propagates data ready flag (data read from HPI is finished)
    -- type   : combinational
    -- inputs : hpi_data_out 
    -- outputs: to_pci_data 
    hpi_data_is_rdy <= hpi_data_rdy;

    -- purpose: propagates interrupt from DSP to PCI
    -- type   : combinational
    -- inputs : dsp_hint 
    -- outputs: int_req2 
    int_req2 <= not dsp_hint;

    -- purpose: HPI interface core
    HPI_INTERFACE: wb2hpi_interface port map (
        clk         =>  clk,      
        reset       =>  reset,     
        
        address     =>  hpi_address,   
        data_in     =>  hpi_data_in, 
        data_out    =>  hpi_data_out,
                
        we          =>  hpi_we,        
        start       =>  hpi_start,
        ready       =>  hpi_ready,    
        
        hpi_ad_in   =>  hpi_ad_in, 
        hpi_ad_out  =>  hpi_ad_out,
        hpi_ad_en   =>  hpi_ad_en, 

        hpi_cntl    =>  hpi_cntl,  
        hpi_cs_n    =>  hpi_cs_n,  
        hpi_ds_n    =>  hpi_ds_n,  
        hpi_rdy     =>  hpi_rdy,   
        hpi_rw      =>  hpi_rw,    
        hpi_bil     =>  hpi_bil,   
        
        hpi_err     =>  hpi_err   
    );

end architecture behavioral;






























